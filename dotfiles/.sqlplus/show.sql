SET ECHO OFF
SET VERIFY OFF
SET DEFINE ON

SELECT object_name AS "&1 NAME"
FROM user_objects
WHERE LOWER(object_type) LIKE LOWER('&1')
ORDER BY object_name;

SET VERIFY ON
