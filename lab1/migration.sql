BEGIN;

ALTER TABLE reviews
ADD COLUMN watch_id BIGINT;

UPDATE reviews AS r
SET watch_id = (
    SELECT w.watch_id
    FROM watch_history AS w
    WHERE w.user_id = r.user_id
      AND w.movie_id = r.movie_id
    ORDER BY w.watched_at, w.watch_id
    LIMIT 1
);

ALTER TABLE reviews
ALTER COLUMN watch_id SET NOT NULL;

ALTER TABLE reviews
ADD CONSTRAINT uq_reviews_watch_id UNIQUE (watch_id);

ALTER TABLE reviews
ADD CONSTRAINT fk_reviews_watch
FOREIGN KEY (watch_id)
REFERENCES watch_history(watch_id)
ON DELETE CASCADE;

ALTER TABLE reviews
DROP CONSTRAINT uq_reviews_user_movie;

ALTER TABLE reviews
DROP COLUMN user_id;

ALTER TABLE reviews
DROP COLUMN movie_id;

COMMIT;
