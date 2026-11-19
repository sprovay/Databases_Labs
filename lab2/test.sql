WITH genre_avg AS (SELECT g.genre_id, ROUND(AVG(r.rating), 2) AS avg_of_genre
    FROM reviews AS r 
    JOIN watch_history AS w ON r.watch_id = w.watch_id
    JOIN movies AS m ON m.movie_id = w.movie_id
    JOIN movie_genres AS mg ON m.movie_id = mg.movie_id
    JOIN genres AS g ON g.genre_id = mg.genre_id
    GROUP BY g.genre_id
    HAVING COUNT(r.review_id) >= 3
)

SELECT g.name, m.title, COUNT(r.review_id) AS views, ROUND(AVG(r.rating), 2) AS avg_rating, genre_avg.avg_of_genre, genre_avg.avg_of_genre - ROUND(AVG(r.rating), 2) AS otklonenie
FROM reviews AS r 
JOIN watch_history AS w ON r.watch_id = w.watch_id
JOIN movies AS m ON m.movie_id = w.movie_id
JOIN movie_genres AS mg ON m.movie_id = mg.movie_id
JOIN genres AS g ON g.genre_id = mg.genre_id
JOIN genre_avg ON g.genre_id = genre_avg.genre_id
GROUP BY g.name, m.title, genre_avg.avg_of_genre
HAVING COUNT(r.review_id) >= 3
ORDER BY g.name, AVG(r.rating) DESC
