SET ECHO OFF
SET VERIFY OFF
SET DEFINE ON

SELECT &2, count(*) FROM &1 GROUP BY &2;

SET VERIFY ON
