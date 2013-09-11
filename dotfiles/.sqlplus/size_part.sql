SET echo off
SET verify off
SET define on

SET feedback off
COLUMN var_out NEW_VALUE maxlen
SELECT 'a' || MAX(LENGTH(partition_name)) AS var_out
FROM dba_segments
WHERE (owner = SYS_CONTEXT('userenv', 'current_schema')
  AND segment_name LIKE UPPER('&1'))
   OR owner || '.' || segment_name LIKE UPPER('&1');
SET feedback on
COLUMN var_out CLEAR

COLUMN pt_name FORMAT &maxlen


SELECT TO_CHAR(dtp.partition_position, '999') AS "#"
     , ds.partition_name AS pt_name
     , CASE WHEN ds.MB >= 1000 THEN TO_CHAR(ds.GB, '9990.999') || ' GB'
                               ELSE TO_CHAR(ds.MB, '9990.999') || ' MB'
       END AS space
FROM (SELECT owner
           , segment_name
           , partition_name
           , SUM(bytes)/1024/1024 as MB
           , SUM(bytes)/1024/1024/1024 as GB
      FROM dba_segments
      WHERE (owner = SYS_CONTEXT('userenv', 'current_schema')
        AND segment_name LIKE UPPER('&1'))
         OR owner || '.' || segment_name LIKE UPPER('&1')
      GROUP BY owner, segment_name, partition_name
     ) ds
   , dba_tab_partitions dtp
WHERE ds.owner = dtp.table_owner
  AND ds.segment_name = dtp.table_name
  AND ds.partition_name = dtp.partition_name
ORDER BY dtp.partition_position;


COLUMN pt_name CLEAR
