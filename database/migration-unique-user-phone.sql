UPDATE users SET phone = NULL WHERE TRIM(phone) = '';

SELECT phone, COUNT(*) AS duplicate_count
FROM users
WHERE phone IS NOT NULL
GROUP BY phone
HAVING COUNT(*) > 1;

SET @phone_key_exists = (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'users'
    AND index_name = 'uniq_users_phone'
);
SET @phone_key_sql = IF(
  @phone_key_exists = 0,
  'ALTER TABLE users ADD UNIQUE KEY uniq_users_phone (phone)',
  'SELECT 1'
);
PREPARE phone_key_statement FROM @phone_key_sql;
EXECUTE phone_key_statement;
DEALLOCATE PREPARE phone_key_statement;