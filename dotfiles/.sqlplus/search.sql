SET echo off
SET verify off
SET define on

SET feedback off
COLUMN var_out NEW_VALUE 2
SELECT '' AS var_out FROM dual WHERE 1=0;
SET feedback on
COLUMN var_out CLEAR

COLUMN object_type FORMAT a12
COLUMN object_name FORMAT a30

SELECT object_type
     , object_name
FROM user_objects
WHERE LOWER(object_name) LIKE LOWER('%&1%')
  AND ('&2' IS NULL
    OR LOWER(object_type) = LOWER('&2'))
  AND object_type NOT LIKE '%PARTITION'
ORDER BY object_type, object_name
;

undef 1
undef 2

COLUMN object_name CLEAR
COLUMN object_type CLEAR
SET verify on
