SET echo off
SET verify off
SET define on

SELECT object_name AS &1._name
FROM all_objects
WHERE owner = SYS_CONTEXT('userenv', 'current_schema')
  AND LOWER(object_type) LIKE LOWER('&1')
ORDER BY object_name;

SET verify on
