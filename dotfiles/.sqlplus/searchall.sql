SET echo off
SET verify off
SET define on
COLUMN object_name FORMAT a30

SET feedback off
COLUMN var_out NEW_VALUE 2
SELECT '' AS var_out FROM dual WHERE 1=0;
SET feedback on
COLUMN var_out CLEAR

SELECT owner
     , object_name
     , object_type
FROM dba_objects
WHERE LOWER(object_name) LIKE LOWER('%&1%')
  AND ('&2' IS NULL
    OR LOWER(object_type) = LOWER('&2'));

COLUMN object_name CLEAR
SET verify on
