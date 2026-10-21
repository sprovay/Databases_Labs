BEGIN;
ALTER TABLE watch_history
ADD COLUMN review_id BIGINT;

ALTER TABLE reviews
DROP CONSTRAINT uq_reviews_user_movie;

UPDATE watch_history
SET review_id = reviews.review_id
FROM reviews
WHERE watch_history.user_id = reviews.user_id
AND watch_history.movie_id = reviews.movie_id;

ALTER TABLE watch_history
ADD CONSTRAINT fk_review_id
FOREIGN KEY (review_id)
REFERENCES reviews(review_id);

ALTER TABLE reviews
DROP COLUMN user_id;

ALTER TABLE reviews
DROP COLUMN movie_id;

COMMIT;
