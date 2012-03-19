SET ECHO OFF
SET VERIFY OFF
SET DEFINE ON

SELECT object_name
     , object_type
FROM user_objects
WHERE LOWER(object_name) LIKE LOWER('%&1%');

SET VERIFY ON
