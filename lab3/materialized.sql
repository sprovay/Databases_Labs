-- ЛР №3, части 3–4. Помесячная статистика жанров по просмотрам.
-- Повторный запуск пересоздаёт только производный объект ЛР №3.
DROP MATERIALIZED VIEW IF EXISTS mv_genre_monthly_stats;

CREATE MATERIALIZED VIEW mv_genre_monthly_stats AS
WITH months AS (
    SELECT DISTINCT date_trunc(
        'month', w.watched_at AT TIME ZONE 'Europe/Moscow'
    )::date AS month_start
    FROM watch_history AS w
),
monthly_metrics AS (
    SELECT date_trunc(
               'month', w.watched_at AT TIME ZONE 'Europe/Moscow'
           )::date AS month_start,
           mg.genre_id,
           COUNT(*) AS views_count,
           COUNT(DISTINCT w.user_id) AS viewers_count,
           COUNT(*) FILTER (
               WHERE w.progress_minutes >= m.duration_minutes
           ) AS completed_views,
           SUM(w.progress_minutes) AS watched_minutes
    FROM watch_history AS w
    JOIN movies AS m ON m.movie_id = w.movie_id
    JOIN movie_genres AS mg ON mg.movie_id = m.movie_id
    GROUP BY 1, mg.genre_id
)
SELECT months.month_start, g.genre_id, g.name AS genre,
       COALESCE(mm.views_count, 0) AS views_count,
       COALESCE(mm.viewers_count, 0) AS viewers_count,
       COALESCE(mm.completed_views, 0) AS completed_views,
       COALESCE(mm.watched_minutes, 0) AS watched_minutes,
       CASE WHEN COALESCE(mm.views_count, 0) = 0 THEN 0
            ELSE ROUND(100.0 * mm.completed_views / mm.views_count, 2)
       END AS completion_percent
FROM months
CROSS JOIN genres AS g
LEFT JOIN monthly_metrics AS mm
  ON mm.month_start = months.month_start AND mm.genre_id = g.genre_id
WITH DATA;

-- Уникальный индекс позволяет обновлять представление без блокировки чтения.
CREATE UNIQUE INDEX ux_mv_genre_monthly_stats_month_genre
    ON mv_genre_monthly_stats (month_start, genre_id);
