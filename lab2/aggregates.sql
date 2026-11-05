-- ЛР №2, задание 2.2: показатели по группам, HAVING и сравнение месяцев.

-- 1. Популярность жанров: просмотры и уникальные зрители.
-- Фильм с двумя жанрами учитывается в каждом из них.
SELECT g.name AS genre,
       COUNT(w.watch_id) AS views_count,
       COUNT(DISTINCT w.user_id) AS viewers_count
FROM genres AS g
LEFT JOIN movie_genres AS mg ON mg.genre_id = g.genre_id
LEFT JOIN watch_history AS w ON w.movie_id = mg.movie_id
GROUP BY g.genre_id
ORDER BY views_count DESC, g.name;

-- 2. Фильмы минимум с двумя рецензиями и средней оценкой от 8.
-- Каждый отзыв относится ровно к одному просмотру конкретного фильма.
SELECT m.title, COUNT(r.review_id) AS reviews_count,
       ROUND(AVG(r.rating), 2) AS average_rating
FROM movies AS m
JOIN watch_history AS w ON w.movie_id = m.movie_id
JOIN reviews AS r ON r.watch_id = w.watch_id
GROUP BY m.movie_id
HAVING COUNT(r.review_id) >= 2
   AND AVG(r.rating) >= 8
ORDER BY average_rating DESC, m.title;

-- 3. Сравнение активности и завершённости просмотров по месяцам.
SELECT date_trunc('month', w.watched_at)::date
           AS month_start,
       COUNT(*) AS views_count,
       SUM(CASE WHEN w.progress_minutes >= m.duration_minutes THEN 1 ELSE 0 END)
           AS completed_views,
       ROUND(100.0 * SUM(CASE WHEN w.progress_minutes >= m.duration_minutes
                             THEN 1 ELSE 0 END) / COUNT(*), 2)
           AS completion_percent,
       ROUND(AVG(w.progress_minutes), 2) AS average_minutes
FROM watch_history AS w
JOIN movies AS m ON m.movie_id = w.movie_id
GROUP BY date_trunc('month', w.watched_at)::date
ORDER BY month_start;
