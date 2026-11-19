-- ЛР №3, часть 2. Обычные представления.

-- 2.1. Операционная карточка просмотра с текущими данными связанных таблиц.
CREATE VIEW v_watch_operations AS
SELECT w.watch_id, w.user_id, u.username, w.movie_id,
       m.title AS movie_title, w.watched_at,
       w.progress_minutes, m.duration_minutes,
       w.progress_minutes >= m.duration_minutes AS is_completed,
       r.rating, r.review_text
FROM watch_history AS w
JOIN users AS u ON u.user_id = w.user_id
JOIN movies AS m ON m.movie_id = w.movie_id
LEFT JOIN reviews AS r ON r.watch_id = w.watch_id;

-- 2.2. Аналитическое представление на основе задания 1.1.
CREATE VIEW v_genre_movie_ranking AS
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
SELECT g.genre_id, g.name AS genre, s.movie_id,
       s.title AS movie_title, s.views_count, s.completed_views,
       DENSE_RANK() OVER (
           PARTITION BY g.genre_id ORDER BY s.completed_views DESC
       ) AS genre_rank
FROM movie_stats AS s
JOIN movie_genres AS mg ON mg.movie_id = s.movie_id
JOIN genres AS g ON g.genre_id = mg.genre_id;

-- 2.3. Редактируемое представление активных пользователей.
-- Запись, которая перестала удовлетворять условию, отклоняется СУБД.
CREATE VIEW v_active_users AS
SELECT user_id, username, email, is_active
FROM users
WHERE is_active = TRUE
WITH CHECK OPTION;
