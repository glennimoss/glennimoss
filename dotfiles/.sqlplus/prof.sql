SET define on

SELECT *
FROM (
  SELECT p.unit_name
       , p.occured
       , p.tot_time
       , p.line# line
       , substr(s.text, 1,75) AS text
  FROM (SELECT u.unit_name
             , d.total_occur AS occured
             , d.total_time/1000000000 AS tot_time
             , d.line#
        FROM plsql_profiler_units u
           , plsql_profiler_data d
        WHERE d.runid = u.runid
          AND d.unit_number = u.unit_number
          AND d.total_occur > 0
          AND u.runid = &1
       ) p -- THIS RUNID MUST MATCH THE RUNID OBTAIN FROM ABOVE
     , user_source s
  WHERE p.unit_name = s.name(+)
    AND p.line# = s.line(+)
  -- ORDER BY p.unit_name, p.line#
  ORDER BY p.tot_time DESC
  )
WHERE rownum <= 10;
