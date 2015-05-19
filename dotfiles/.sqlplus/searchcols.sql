SET echo off
SET verify off
SET define on

SELECT table_name
     , column_name
FROM dba_tab_columns
WHERE owner = SYS_CONTEXT('userenv', 'current_schema')
  AND LOWER(column_name) LIKE LOWER('%&1%');

SET verify on
