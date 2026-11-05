-- ЛР №2, задание 2.1: три разных задачи с JOIN (не менее трёх таблиц).

-- 1. Операционная история: кто, что и когда смотрел, сколько минут,
-- была ли прикреплена рецензия.
SELECT w.watch_id, u.username, m.title,
       w.watched_at,
       w.progress_minutes, m.duration_minutes,
       r.rating, r.review_text
FROM watch_history AS w
JOIN users AS u ON u.user_id = w.user_id
JOIN movies AS m ON m.movie_id = w.movie_id
LEFT JOIN reviews AS r ON r.watch_id = w.watch_id
ORDER BY w.watched_at, w.watch_id;

-- 2. Фильмы без просмотров, включая жанры. 
-- список жанров собирается в одну строку.
SELECT m.movie_id, m.title,
       string_agg(g.name, ', ' ORDER BY g.name) AS genres
FROM movies AS m
LEFT JOIN movie_genres AS mg ON mg.movie_id = m.movie_id
LEFT JOIN genres AS g ON g.genre_id = mg.genre_id
LEFT JOIN watch_history AS w ON w.movie_id = m.movie_id
WHERE w.watch_id IS NULL
GROUP BY m.movie_id
ORDER BY m.title;

-- 3. Завершённые просмотры фантастики во время действия подписки
-- с качеством не ниже FULLHD. Просроченная сейчас подписка подходит,
-- если на момент просмотра её период ещё не закончился.
SELECT DISTINCT u.username, m.title, p.name AS plan_name,
       w.watched_at
FROM watch_history AS w
JOIN users AS u ON u.user_id = w.user_id
JOIN movies AS m ON m.movie_id = w.movie_id
JOIN movie_genres AS mg ON mg.movie_id = m.movie_id
JOIN genres AS g ON g.genre_id = mg.genre_id
JOIN subscriptions AS s ON s.user_id = u.user_id
JOIN subscription_plans AS p ON p.plan_id = s.plan_id
WHERE g.name = 'Фантастика'
  AND w.progress_minutes >= m.duration_minutes
  AND w.watched_at::date
      BETWEEN s.start_date AND s.end_date
  AND s.status <> 'cancelled'
  AND p.max_quality IN ('FULLHD', '4K')
ORDER BY u.username, m.title, w.watched_at;
