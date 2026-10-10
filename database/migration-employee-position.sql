SET @position_column_exists = (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'users'
    AND column_name = 'position'
);
SET @position_column_sql = IF(
  @position_column_exists = 0,
  'ALTER TABLE users ADD COLUMN position VARCHAR(100) DEFAULT NULL AFTER role',
  'SELECT 1'
);
PREPARE position_column_statement FROM @position_column_sql;
EXECUTE position_column_statement;
DEALLOCATE PREPARE position_column_statement;

UPDATE users
SET position = 'Nhân viên'
WHERE role = 'employee' AND (position IS NULL OR TRIM(position) = '');