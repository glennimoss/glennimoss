SET ECHO OFF
SET VERIFY OFF
SET DEFINE ON
COLUMN object_name FORMAT a30

SELECT owner
     , object_name
     , object_type
FROM dba_objects
WHERE LOWER(object_name) LIKE LOWER('%&1%');

SET VERIFY ON
