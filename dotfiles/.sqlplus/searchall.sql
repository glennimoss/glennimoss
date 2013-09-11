SET echo off
SET verify off
SET define on
COLUMN object_name FORMAT a30

SELECT owner
     , object_name
     , object_type
FROM dba_objects
WHERE LOWER(object_name) LIKE LOWER('%&1%');

COLUMN object_name CLEAR
SET verify on
