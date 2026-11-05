-- ЛР №2, часть 4. В каких жанрах по месяцам больше просмотров
-- и какова доля завершённых просмотров? Отчёт включает нулевые группы.
WITH months AS (
    SELECT generate_series(DATE '2026-08-01', DATE '2026-10-01',
                           INTERVAL '1 month')::date AS month_start
),
source_data AS (
    SELECT w.watch_id, w.user_id, w.progress_minutes,
           m.duration_minutes, g.genre_id, g.name AS genre,
           date_trunc('month', w.watched_at)::date
               AS month_start
    FROM watch_history AS w
    JOIN movies AS m ON m.movie_id = w.movie_id
    JOIN movie_genres AS mg ON mg.movie_id = m.movie_id
    JOIN genres AS g ON g.genre_id = mg.genre_id
    WHERE w.watched_at::date >= DATE '2026-08-01'
      AND w.watched_at::date < DATE '2026-11-01'
),
view_flags AS (
    SELECT source_data.*,
           CASE WHEN progress_minutes >= duration_minutes THEN 1 ELSE 0 END
               AS completed
    FROM source_data
),
monthly_metrics AS (
    SELECT month_start, genre_id,
           COUNT(*) AS views_count,
           COUNT(DISTINCT user_id) AS viewers_count,
           SUM(completed) AS completed_views
    FROM view_flags
    GROUP BY month_start, genre_id
),
report AS (
    SELECT months.month_start, g.name AS genre,
           COALESCE(mm.views_count, 0) AS views_count,
           COALESCE(mm.viewers_count, 0) AS viewers_count,
           COALESCE(mm.completed_views, 0) AS completed_views,
           CASE WHEN COALESCE(mm.views_count, 0) = 0 THEN 0
                ELSE ROUND(100.0 * mm.completed_views / mm.views_count, 2)
           END AS completion_percent,
           CASE WHEN months.month_start = DATE '2026-08-01' THEN NULL
                ELSE COALESCE(prev.views_count, 0)
           END AS previous_month_views
    FROM months
    CROSS JOIN genres AS g
    LEFT JOIN monthly_metrics AS mm
      ON mm.month_start = months.month_start AND mm.genre_id = g.genre_id
    LEFT JOIN monthly_metrics AS prev
      ON prev.month_start = (months.month_start - INTERVAL '1 month')::date
     AND prev.genre_id = g.genre_id
)
SELECT month_start, genre, views_count, viewers_count, completed_views,
       completion_percent, previous_month_views,
       CASE WHEN previous_month_views IS NULL THEN NULL
            ELSE views_count - previous_month_views
       END AS views_change
FROM report
ORDER BY month_start, genre;
