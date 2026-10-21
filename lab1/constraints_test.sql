-- Проверка ограничений целостности.

-- 1. Нарушение UNIQUE: email уже существует.
INSERT INTO users (username, email, password_hash)
VALUES ('new_user', 'ivan@example.com', 'hash_new');

-- 2. Нарушение CHECK: рейтинг рецензии должен быть от 1 до 10.
INSERT INTO reviews (user_id, movie_id, rating, review_text)
VALUES (5, 2, 15, 'Некорректный рейтинг');

-- 3. Нарушение CHECK: дата окончания подписки должна быть позже даты начала.
INSERT INTO subscriptions
(user_id, plan_id, start_date, end_date, status)
VALUES
(5, 1, '2026-10-10', '2026-10-01', 'active');

-- 4. Нарушение FOREIGN KEY: пользователя с user_id = 9999 нет.
INSERT INTO watch_history (user_id, movie_id, progress_minutes)
VALUES (9999, 1, 10);

-- 5. Нарушение составного PRIMARY KEY: такая пара фильм-жанр уже есть.
INSERT INTO movie_genres (movie_id, genre_id)
VALUES (1, 1);

-- 6. Нарушение составного UNIQUE: пользователь уже оставил рецензию на фильм 1.
INSERT INTO reviews (user_id, movie_id, rating, review_text)
VALUES (1, 1, 8, 'Вторая рецензия');

-- 7. Нарушение CHECK при UPDATE: отрицательная цена тарифа.
UPDATE subscription_plans
SET price = -100
WHERE plan_id = 1;

-- 8. Нарушение NOT NULL.
UPDATE movies
SET title = NULL
WHERE movie_id = 1;
