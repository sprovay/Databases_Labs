-- ЛР №3, часть 1. Выполнять после lab2/data.sql.
-- -P pager=off
-- 1.1. Место фильма в каждом его жанре по числу завершённых просмотров.

WITH movie_stats AS (
    SELECT m.movie_id, m.title,
           COUNT(w.watch_id) AS views_count,
           COUNT(w.watch_id) FILTER (
               WHERE w.progress_minutes >= m.duration_minutes
           ) AS completed_views
    FROM movies AS m
    LEFT JOIN watch_history AS w ON w.movie_id = m.movie_id
    GROUP BY m.movie_id
)
SELECT g.name AS genre, s.movie_id, s.title AS movie_title,
       s.views_count, s.completed_views,
       DENSE_RANK() OVER (
           PARTITION BY g.genre_id ORDER BY s.completed_views DESC
       ) AS genre_rank
FROM movie_stats AS s
JOIN movie_genres AS mg ON mg.movie_id = s.movie_id
JOIN genres AS g ON g.genre_id = mg.genre_id
ORDER BY g.name, genre_rank, s.title, s.movie_id;

-- 1.2. Интервал между последовательными просмотрами одного пользователя.
WITH ordered_watches AS (
    SELECT w.watch_id, w.user_id, w.movie_id, w.watched_at,
           LAG(w.watch_id) OVER (
               PARTITION BY w.user_id ORDER BY w.watched_at, w.watch_id
           ) AS previous_watch_id,
           LAG(w.watched_at) OVER (
               PARTITION BY w.user_id ORDER BY w.watched_at, w.watch_id
           ) AS previous_watched_at
    FROM watch_history AS w
)
SELECT u.username, m.title AS movie_title, ow.watch_id, ow.watched_at,
       ow.previous_watch_id, ow.previous_watched_at,
       ow.watched_at - ow.previous_watched_at AS time_since_previous
FROM ordered_watches AS ow
JOIN users AS u ON u.user_id = ow.user_id
JOIN movies AS m ON m.movie_id = ow.movie_id
ORDER BY u.username, ow.watched_at, ow.watch_id;

-- 1.3. Вклад каждого просмотра в суммарные минуты просмотра пользователя.
WITH watch_contributions AS (
    SELECT w.watch_id, w.user_id, w.movie_id, w.watched_at,
           w.progress_minutes,
           SUM(w.progress_minutes) OVER (
               PARTITION BY w.user_id
           ) AS user_total_minutes
    FROM watch_history AS w
)
SELECT u.username, m.title AS movie_title, wc.watch_id, wc.watched_at,
       wc.progress_minutes, wc.user_total_minutes,
       ROUND(100.0 * wc.progress_minutes /
             NULLIF(wc.user_total_minutes, 0), 2) AS share_percent
FROM watch_contributions AS wc
JOIN users AS u ON u.user_id = wc.user_id
JOIN movies AS m ON m.movie_id = wc.movie_id
ORDER BY u.username, wc.watched_at, wc.watch_id;
