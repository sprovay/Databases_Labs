-- Тестовые данные для варианта 4: Онлайн-кинотеатр

INSERT INTO users (username, email, password_hash, birth_date) VALUES
('ivan_petrov', 'ivan@example.com', 'hash_ivan', '2001-03-15'),
('anna_smirnova', 'anna@example.com', 'hash_anna', '1998-11-02'),
('max_k', 'max@example.com', 'hash_max', '2005-06-21'),
('olga_m', 'olga@example.com', 'hash_olga', '1993-01-10'),
('sergey88', 'sergey@example.com', 'hash_sergey', '1988-09-30');

INSERT INTO genres (name) VALUES
('Драма'),
('Комедия'),
('Фантастика'),
('Триллер'),
('Приключения');

INSERT INTO movies
(title, release_year, duration_minutes, age_rating, description, country)
VALUES
('Интерстеллар', 2014, 169, 12, 'Научно-фантастическая драма о космической экспедиции.', 'США'),
('1+1', 2011, 112, 16, 'Драма и комедия о необычной дружбе.', 'Франция'),
('Начало', 2010, 148, 12, 'Фантастический триллер о проникновении в сны.', 'США'),
('Достучаться до небес', 1997, 87, 16, 'Драматическая комедия о путешествии двух друзей.', 'Германия'),
('Марсианин', 2015, 144, 12, 'История выживания астронавта на Марсе.', 'США');

INSERT INTO movie_genres (movie_id, genre_id) VALUES
(1, 1), (1, 3), (1, 5),
(2, 1), (2, 2),
(3, 3), (3, 4),
(4, 1), (4, 2),
(5, 3), (5, 5);

INSERT INTO subscription_plans
(name, price, duration_days, max_quality, max_devices)
VALUES
('Базовый', 299.00, 30, 'HD', 1),
('Стандарт', 499.00, 30, 'FULLHD', 2),
('Премиум', 799.00, 30, '4K', 5);

INSERT INTO subscriptions
(user_id, plan_id, start_date, end_date, status)
VALUES
(1, 2, '2026-09-01', '2026-10-01', 'active'),
(2, 3, '2026-09-10', '2026-10-10', 'active'),
(3, 1, '2026-08-01', '2026-08-31', 'expired'),
(4, 2, '2026-09-15', '2026-10-15', 'active'),
(5, 1, '2026-09-05', '2026-10-05', 'active');

INSERT INTO watch_history
(user_id, movie_id, watched_at, progress_minutes)
VALUES
(1, 1, '2026-09-20 20:10:00+03', 169),
(1, 3, '2026-09-22 18:30:00+03', 75),
(2, 2, '2026-09-19 21:00:00+03', 112),
(3, 5, '2026-08-15 16:00:00+03', 30),
(4, 4, '2026-09-21 22:15:00+03', 87),
(5, 1, '2026-09-23 19:45:00+03', 20);

INSERT INTO reviews
(user_id, movie_id, rating, review_text)
VALUES
(1, 1, 10, 'Очень сильный фильм.'),
(2, 2, 9, 'Отличная история и юмор.'),
(3, 5, 8, 'Интересная фантастика.'),
(4, 4, 9, 'Запоминающийся фильм.');
