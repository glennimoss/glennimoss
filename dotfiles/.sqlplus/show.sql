SET echo off
SET verify off
SET define on

COLUMN view_name FORMAT a30

SELECT object_name AS "&1._name", status
FROM all_objects
WHERE owner = SYS_CONTEXT('userenv', 'current_schema')
  AND LOWER(object_type) LIKE LOWER('&1')
ORDER BY object_name;

SET verify on

COLUMN view_name CLEAR
