SET echo off
SET verify off
SET define on

SET feedback off
COLUMN var_out NEW_VALUE 2
SELECT '' AS var_out FROM dual WHERE 1=0;
SET feedback on
COLUMN var_out CLEAR

SELECT object_name
     , object_type
FROM all_objects
WHERE owner = SYS_CONTEXT('userenv', 'current_schema')
  AND LOWER(object_name) LIKE LOWER('%&1%')
  AND LOWER(object_type) LIKE LOWER('%&2%');

SET verify on
