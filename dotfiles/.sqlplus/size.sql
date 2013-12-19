SET echo off
SET verify off
SET define on

SET feedback off
COLUMN var_out NEW_VALUE 2
SELECT '' AS var_out FROM dual WHERE 1=0;
SET feedback on
COLUMN var_out CLEAR

COLUMN owner        FORMAT a9
COLUMN segment_name FORMAT a30
COLUMN segment_type FORMAT a10
COLUMN "#Segs"      FORMAT 999

SELECT owner
     , segment_name
     , CASE segment_type
         WHEN 'INDEX PARTITION'    THEN 'INDEX PT'
         WHEN 'TABLE SUBPARTITION' THEN 'TABLE SUBP'
         WHEN 'TABLE PARTITION'    THEN 'TABLE PT'
         WHEN 'NESTED TABLE'       THEN 'NESTED T'
         WHEN 'LOB PARTITION'      THEN 'LOB PT'
                                   ELSE segment_type
       END AS segment_type
     , COUNT(*) as "#Segs"
     , SUM(bytes)/1024/1024 as MB
     , SUM(bytes)/1024/1024/1024 as GB
FROM dba_segments
WHERE ((owner = SYS_CONTEXT('userenv', 'current_schema')
    AND REGEXP_LIKE(segment_name, '^&1', 'i'))
     OR REGEXP_LIKE(owner || '.' || segment_name, '^&1', 'i'))
  AND LOWER(segment_type) LIKE LOWER('%&2%')
GROUP BY owner, segment_name, segment_type
ORDER BY segment_name, segment_type;


COLUMN owner        CLEAR
COLUMN segment_name CLEAR
COLUMN segment_type CLEAR
COLUMN "#Segs"      CLEAR
