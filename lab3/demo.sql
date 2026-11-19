-- Выполнять после views.sql и materialized.sql.

-- 1.1. Фильм без просмотров остаётся в рейтинге.
SELECT genre, movie_title, views_count, completed_views, genre_rank
FROM v_genre_movie_ranking
WHERE movie_title = 'Неоткрытый архив';

-- Равное число завершённых просмотров даёт одинаковое место.
SELECT movie_title, completed_views, genre_rank
FROM v_genre_movie_ranking
WHERE genre = 'Фантастика'
ORDER BY genre_rank, movie_title;

-- 1.2. Первый просмотр пользователя не имеет предыдущего.
SELECT w.watch_id, w.watched_at,
       LAG(w.watched_at) OVER (
           PARTITION BY w.user_id ORDER BY w.watched_at, w.watch_id
       ) AS previous_watched_at
FROM watch_history AS w
JOIN users AS u ON u.user_id = w.user_id
WHERE u.username = 'ivan_petrov'
ORDER BY w.watched_at, w.watch_id;

-- 1.3. У каждого просмотра остаётся своя строка, итог и доля в нём.
SELECT w.watch_id, w.progress_minutes,
       SUM(w.progress_minutes) OVER (
           PARTITION BY w.user_id
       ) AS user_total_minutes,
       100.0 * w.progress_minutes / SUM(w.progress_minutes) OVER (
           PARTITION BY w.user_id
       ) AS share_percent
FROM watch_history AS w
JOIN users AS u ON u.user_id = w.user_id
WHERE u.username = 'ivan_petrov'
ORDER BY w.watch_id;

-- 2.1. Обычное представление сразу отражает изменение исходной таблицы.
SELECT watch_id, username, movie_title, progress_minutes
FROM v_watch_operations
WHERE watch_id = 2;

BEGIN;
UPDATE watch_history
SET progress_minutes = progress_minutes + 1
WHERE watch_id = 2;

SELECT watch_id, username, movie_title, progress_minutes
FROM v_watch_operations
WHERE watch_id = 2;
ROLLBACK;

SELECT watch_id, username, movie_title, progress_minutes
FROM v_watch_operations
WHERE watch_id = 2;

-- 2.2. Использование аналитического представления с дополнительным условием.
SELECT movie_title, completed_views, genre_rank
FROM v_genre_movie_ranking
WHERE genre = 'Фантастика' AND genre_rank <= 3
ORDER BY genre_rank, movie_title;

-- 2.3. Допустимое изменение через простое представление.
BEGIN;
UPDATE v_active_users
SET username = 'lab3_check_user'
WHERE username = 'ivan_petrov';

SELECT user_id, username, is_active
FROM v_active_users
WHERE username = 'lab3_check_user';
ROLLBACK;

-- Ожидаемая ошибка: строка перестала бы соответствовать условию VIEW.
-- Команда выполняется вне транзакции и не меняет исходные данные.
UPDATE v_active_users
SET is_active = FALSE
WHERE username = 'ivan_petrov';

-- 3–4. Материализованное представление меняется только после REFRESH.
SELECT month_start, genre, watched_minutes
FROM mv_genre_monthly_stats
WHERE month_start = DATE '2026-09-01' AND genre = 'Триллер';

BEGIN;
UPDATE watch_history
SET progress_minutes = progress_minutes + 1
WHERE watch_id = 2;

SELECT watch_id, progress_minutes
FROM watch_history
WHERE watch_id = 2;

SELECT month_start, genre, watched_minutes
FROM mv_genre_monthly_stats
WHERE month_start = DATE '2026-09-01' AND genre = 'Триллер';

REFRESH MATERIALIZED VIEW mv_genre_monthly_stats;

SELECT month_start, genre, watched_minutes
FROM mv_genre_monthly_stats
WHERE month_start = DATE '2026-09-01' AND genre = 'Триллер';
ROLLBACK;

SELECT month_start, genre, watched_minutes
FROM mv_genre_monthly_stats
WHERE month_start = DATE '2026-09-01' AND genre = 'Триллер';

-- Вывод материализованного представления.
SELECT * FROM mv_genre_monthly_stats
ORDER BY month_start, genre;