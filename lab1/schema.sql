-- Лабораторная работа №1
-- Вариант 4: Онлайн-кинотеатр

DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS watch_history CASCADE;
DROP TABLE IF EXISTS subscription_plans CASCADE;
DROP TABLE IF EXISTS subscriptions CASCADE;
DROP TABLE IF EXISTS movie_genres CASCADE;
DROP TABLE IF EXISTS movies CASCADE;
DROP TABLE IF EXISTS genres CASCADE;
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
    user_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash TEXT NOT NULL,
    birth_date DATE,
    registered_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT uq_users_username UNIQUE (username),
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT chk_users_username_len CHECK (char_length(username) BETWEEN 3 AND 50),
    CONSTRAINT chk_users_email_format CHECK (email LIKE '%_@_%._%')
);

CREATE TABLE genres (
    genre_id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(80) NOT NULL,

    CONSTRAINT uq_genres_name UNIQUE (name),
    CONSTRAINT chk_genres_name_not_blank CHECK (btrim(name) <> '')
);

CREATE TABLE movies (
    movie_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    release_year SMALLINT NOT NULL,
    duration_minutes SMALLINT NOT NULL,
    age_rating SMALLINT NOT NULL DEFAULT 0,
    description TEXT,
    country VARCHAR(100),
    added_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_movies_title_year UNIQUE (title, release_year),
    CONSTRAINT chk_movies_release_year CHECK (release_year BETWEEN 1888 AND 2100),
    CONSTRAINT chk_movies_duration CHECK (duration_minutes BETWEEN 1 AND 600),
    CONSTRAINT chk_movies_age_rating CHECK (age_rating IN (0, 6, 12, 16, 18))
);

CREATE TABLE movie_genres (
    movie_id BIGINT NOT NULL,
    genre_id SMALLINT NOT NULL,

    CONSTRAINT pk_movie_genres PRIMARY KEY (movie_id, genre_id),
    CONSTRAINT fk_movie_genres_movie
        FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_movie_genres_genre
        FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
        ON DELETE RESTRICT
);

CREATE TABLE subscription_plans (
    plan_id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    duration_days SMALLINT NOT NULL,
    max_quality VARCHAR(10) NOT NULL,
    max_devices SMALLINT NOT NULL,

    CONSTRAINT uq_subscription_plans_name UNIQUE (name),
    CONSTRAINT chk_subscription_plans_price CHECK (price >= 0),
    CONSTRAINT chk_subscription_plans_duration CHECK (duration_days > 0),
    CONSTRAINT chk_subscription_plans_quality CHECK (max_quality IN ('HD', 'FULLHD', '4K')),
    CONSTRAINT chk_subscription_plans_devices CHECK (max_devices BETWEEN 1 AND 10)
);

CREATE TABLE subscriptions (
    subscription_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL,
    plan_id SMALLINT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',

    CONSTRAINT fk_subscriptions_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_subscriptions_plan
        FOREIGN KEY (plan_id) REFERENCES subscription_plans(plan_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_subscriptions_dates CHECK (end_date > start_date),
    CONSTRAINT chk_subscriptions_status CHECK (status IN ('active', 'expired', 'cancelled')),
    CONSTRAINT uq_subscriptions_user_period UNIQUE (user_id, start_date, end_date)
);

CREATE TABLE watch_history (
    watch_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL,
    movie_id BIGINT NOT NULL,
    watched_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    progress_minutes SMALLINT NOT NULL DEFAULT 0,

    CONSTRAINT fk_watch_history_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_watch_history_movie
        FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
        ON DELETE CASCADE,
    CONSTRAINT chk_watch_history_progress CHECK (progress_minutes >= 0)
);

CREATE TABLE reviews (
    review_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL,
    movie_id BIGINT NOT NULL,
    rating SMALLINT NOT NULL,
    review_text TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_reviews_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_reviews_movie
        FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
        ON DELETE CASCADE,
    CONSTRAINT chk_reviews_rating CHECK (rating BETWEEN 1 AND 10),
    CONSTRAINT uq_reviews_user_movie UNIQUE (user_id, movie_id)
);