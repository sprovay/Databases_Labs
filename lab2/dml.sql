-- ЛР №2, задание 1.2. Сценарий выполнять один раз после data.sql.
-- Контрольная дата для примеров: 22.10.2026.

-- 1. Новый пользователь, его подписка и первый просмотр.
BEGIN;
WITH new_user AS (
    INSERT INTO users (username, email, password_hash)
    VALUES ('lab2_demo', 'lab2_demo@example.com', 'demo_hash')
    RETURNING user_id
), new_subscription AS (
    INSERT INTO subscriptions (user_id, plan_id, start_date, end_date, status)
    SELECT new_user.user_id, p.plan_id,
           DATE '2026-10-22', DATE '2026-11-22', 'active'
    FROM new_user
    JOIN subscription_plans AS p ON p.name = 'Стандарт'
    RETURNING user_id
)
INSERT INTO watch_history (user_id, movie_id, watched_at, progress_minutes)
SELECT new_subscription.user_id, m.movie_id,
       TIMESTAMP '2026-10-22 20:00:00', m.duration_minutes
FROM new_subscription
JOIN movies AS m ON m.title = 'Интерстеллар' AND m.release_year = 2014;

SELECT u.username, s.status, m.title, w.progress_minutes
FROM users AS u
JOIN subscriptions AS s ON s.user_id = u.user_id
JOIN watch_history AS w ON w.user_id = u.user_id
JOIN movies AS m ON m.movie_id = w.movie_id
WHERE u.username = 'lab2_demo';
COMMIT;

-- 2. Смена состояния одной действующей подписки.
UPDATE subscriptions AS s
SET status = 'cancelled'
FROM users AS u
WHERE s.user_id = u.user_id
  AND u.username = 'lab2_user_01'
  AND s.start_date = DATE '2026-10-20'
  AND s.status = 'active'
RETURNING s.subscription_id, s.status;

-- 3. Массовое закрытие подписок, срок которых истёк к контрольной дате.
UPDATE subscriptions
SET status = 'expired'
WHERE status = 'active'
  AND end_date < DATE '2026-10-22'
RETURNING subscription_id, end_date, status;

-- 4. Удаление больше не нужного тарифа, если на него нет ссылок.
INSERT INTO subscription_plans (name, price, duration_days, max_quality, max_devices)
VALUES ('Пробный тариф для удаления', 0, 7, 'HD', 1);

DELETE FROM subscription_plans AS p
WHERE p.name = 'Пробный тариф для удаления'
  AND NOT EXISTS (
      SELECT 1
      FROM subscriptions AS s
      WHERE s.plan_id = p.plan_id
  )
RETURNING p.plan_id, p.name;

SELECT COUNT(*) AS temporary_plan_count
FROM subscription_plans
WHERE name = 'Пробный тариф для удаления';

-- 5. Отмена изменения цены: внутри транзакции значение равно нулю,
-- после ROLLBACK снова равно исходным 799.00.
BEGIN;
UPDATE subscription_plans
SET price = 0
WHERE name = 'Премиум';
SELECT name, price AS price_inside_transaction
FROM subscription_plans
WHERE name = 'Премиум';
ROLLBACK;
SELECT name, price AS price_after_rollback
FROM subscription_plans
WHERE name = 'Премиум';
