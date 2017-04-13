SET echo off
SET verify off
SET define on

COLUMN table_name FORMAT a30
COLUMN column_name FORMAT a30

SELECT table_name
     , column_name
FROM user_tab_columns
WHERE LOWER(column_name) LIKE LOWER('%&1%')
ORDER BY table_name, column_name
;

COLUMN table_name CLEAR
COLUMN column_name CLEAR

SET verify on
