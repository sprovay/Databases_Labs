-- ЛР №2. Выполнять после lab1/schema.sql, lab1/data.sql и lab1/migration.sql.
-- Фиксированные даты позволяют повторить результаты независимо от дня запуска.
BEGIN;

INSERT INTO users (username, email, password_hash, birth_date)
SELECT 'lab2_user_' || lpad(n::text, 2, '0'),
       'lab2_user_' || lpad(n::text, 2, '0') || '@example.com',
       'demo_hash_' || n,
       CASE WHEN n IN (4, 8) THEN NULL ELSE DATE '1990-01-01' + n * 365 END
FROM generate_series(1, 8) AS numbers(n);

INSERT INTO genres (name) VALUES ('Документальный');

INSERT INTO movies (title, release_year, duration_minutes, age_rating, description, country)
VALUES
    ('Орбита', 2022, 120, 12, 'Космическая экспедиция.', 'Россия'),
    ('Соседи', 2021, 90, 6, 'Комедия о соседях.', 'Россия'),
    ('Сигнал', 2023, 105, 16, 'Поиск источника сигнала.', 'США'),
    ('Дорога', 2020, 110, 12, 'Путешествие друзей.', 'Франция'),
    ('Тень', 2019, 95, 18, 'История расследования.', 'Германия'),
    ('Выбор', 2024, 100, 12, 'История непростого решения.', 'Россия'),
    ('Неоткрытый архив', 2025, 80, 0, NULL, NULL);

INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.movie_id, g.genre_id
FROM (VALUES
    ('Орбита', 'Фантастика'), ('Орбита', 'Приключения'),
    ('Соседи', 'Комедия'),
    ('Сигнал', 'Фантастика'), ('Сигнал', 'Триллер'),
    ('Дорога', 'Драма'), ('Дорога', 'Приключения'),
    ('Тень', 'Триллер'),
    ('Выбор', 'Драма'),
    ('Неоткрытый архив', 'Документальный')
) AS links(movie_title, genre_name)
JOIN movies AS m ON m.title = links.movie_title
JOIN genres AS g ON g.name = links.genre_name;

-- Восьмой пользователь оставлен без подписок и просмотров.
INSERT INTO subscriptions (user_id, plan_id, start_date, end_date, status)
SELECT u.user_id, p.plan_id, periods.start_date, periods.end_date, periods.status
FROM (VALUES
    ('lab2_user_01', 'Стандарт', DATE '2026-08-01', DATE '2026-09-01', 'expired'),
    ('lab2_user_01', 'Премиум', DATE '2026-10-20', DATE '2026-11-20', 'active'),
    ('lab2_user_02', 'Премиум', DATE '2026-09-01', DATE '2026-10-01', 'expired'),
    ('lab2_user_02', 'Базовый', DATE '2026-10-21', DATE '2026-11-20', 'active'),
    ('lab2_user_03', 'Стандарт', DATE '2026-08-15', DATE '2026-09-15', 'cancelled'),
    ('lab2_user_04', 'Стандарт', DATE '2026-09-01', DATE '2026-10-01', 'expired'),
    ('lab2_user_05', 'Премиум', DATE '2026-08-01', DATE '2026-10-01', 'cancelled'),
    ('lab2_user_06', 'Базовый', DATE '2026-10-01', DATE '2026-11-01', 'active'),
    ('lab2_user_07', 'Базовый', DATE '2026-09-01', DATE '2026-10-01', 'expired')
) AS periods(username, plan_name, start_date, end_date, status)
JOIN users AS u ON u.username = periods.username
JOIN subscription_plans AS p ON p.name = periods.plan_name;

-- 48 просмотров за август, сентябрь и октябрь. Пары пользователь/фильм
-- повторяются после 42-й записи; есть завершённые, частичные и нулевые просмотры.
INSERT INTO watch_history (user_id, movie_id, watched_at, progress_minutes)
SELECT u.user_id,
       m.movie_id,
       TIMESTAMP '2026-08-01 20:00:00'
           + ((n - 1) / 16) * INTERVAL '1 month'
           + ((n - 1) % 16) * INTERVAL '1 day'
           + (n % 3) * INTERVAL '1 hour',
       CASE n % 5
           WHEN 0 THEN 0
           WHEN 1 THEN m.duration_minutes
           WHEN 2 THEN m.duration_minutes / 2
           WHEN 3 THEN m.duration_minutes - 1
           ELSE m.duration_minutes
       END
FROM generate_series(1, 48) AS events(n)
JOIN users AS u
  ON u.username = 'lab2_user_' || lpad((1 + (n - 1) % 7)::text, 2, '0')
JOIN (VALUES
    (1, 'Орбита'), (2, 'Соседи'), (3, 'Сигнал'),
    (4, 'Дорога'), (5, 'Тень'), (6, 'Выбор')
) AS film_order(no, title) ON film_order.no = 1 + (n - 1) % 6
JOIN movies AS m ON m.title = film_order.title;

-- Первые 18 новых просмотров: по три на каждый из шести фильмов.
-- У каждого отзыва есть свой просмотр; автора и фильм задаёт watch_history.
-- Остаток от деления watch_id даёт разные оценки в допустимых диапазонах.
INSERT INTO reviews (watch_id, rating, review_text, created_at)
SELECT w.watch_id,
       CASE WHEN m.title IN ('Орбита', 'Сигнал', 'Дорога')
            THEN 8 + w.watch_id % 3
            ELSE 4 + w.watch_id % 4 END,
       CASE WHEN m.title = 'Выбор' THEN NULL
            ELSE 'Отзыв о фильме ' || m.title END,
       w.watched_at + INTERVAL '1 day'
FROM watch_history AS w
JOIN users AS u ON u.user_id = w.user_id
JOIN movies AS m ON m.movie_id = w.movie_id
WHERE u.username LIKE 'lab2_user_%'
ORDER BY w.watched_at, w.watch_id
LIMIT 18;

COMMIT;
