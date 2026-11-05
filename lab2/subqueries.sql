-- ЛР №2, задания 3.1–3.4.

-- 3.1. Просмотры, прогресс которых выше среднего для того же фильма.
SELECT w.watch_id, u.username, m.title, w.progress_minutes,
       (SELECT ROUND(AVG(other.progress_minutes), 2)
        FROM watch_history AS other
        WHERE other.movie_id = w.movie_id) AS movie_average_minutes
FROM watch_history AS w
JOIN users AS u ON u.user_id = w.user_id
JOIN movies AS m ON m.movie_id = w.movie_id
WHERE w.progress_minutes > (
    SELECT AVG(other.progress_minutes)
    FROM watch_history AS other
    WHERE other.movie_id = w.movie_id
)
ORDER BY m.title, w.progress_minutes DESC, w.watch_id;

-- 3.2. EXISTS: пользователи, завершившие хотя бы один просмотр
-- за август–октябрь 2026 года.
SELECT u.user_id, u.username
FROM users AS u
WHERE EXISTS (
    SELECT 1
    FROM watch_history AS w
    JOIN movies AS m ON m.movie_id = w.movie_id
    WHERE w.user_id = u.user_id
      AND w.progress_minutes >= m.duration_minutes
      AND w.watched_at::date >= DATE '2026-08-01'
      AND w.watched_at::date < DATE '2026-11-01'
)
ORDER BY u.username;

-- 3.3. NOT EXISTS: фильмы, для которых пока не было ни одного просмотра.
SELECT m.movie_id, m.title
FROM movies AS m
WHERE NOT EXISTS (
    SELECT 1
    FROM watch_history AS w
    WHERE w.movie_id = m.movie_id
)
ORDER BY m.title;

-- 3.4. Для каждого пользователя подзапрос вычисляет
-- дату его последнего просмотра; для зрителя без просмотров будет NULL.
SELECT u.user_id, u.username,
       (SELECT MAX(w.watched_at)
        FROM watch_history AS w
        WHERE w.user_id = u.user_id) AS last_view_at
FROM users AS u
ORDER BY u.username;
