SET echo off
SET verify off
SET define on

SELECT &2, COUNT(*)
FROM &1
GROUP BY &2;

SET verify on
