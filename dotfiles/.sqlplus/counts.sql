SET echo off
SET verify off
SET define on

SELECT &2, COUNT(*) AS "COUNT"
FROM &1
GROUP BY &2
ORDER BY "COUNT";

SET verify on
