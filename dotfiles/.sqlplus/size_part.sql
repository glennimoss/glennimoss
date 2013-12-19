SET echo off
SET verify off
SET define on

DECLARE
  l_maxlen NUMBER;
  l_high_val VARCHAR2(10);
  l_total_bytes NUMBER := 0;
  l_suff VARCHAR2(3);
BEGIN
  SELECT NVL(MAX(LENGTH(NVL(partition_name, segment_name))), 10) AS var_out
  INTO l_maxlen
  FROM dba_segments
  WHERE (owner = SYS_CONTEXT('userenv', 'current_schema')
    AND segment_name LIKE UPPER('&1'))
     OR owner || '.' || segment_name LIKE UPPER('&1');

  k.print(k.args('#   ', RPAD('PT_NAME', l_maxlen), 'SPACE        HIGH_VALUE'));
  k.print(k.args('----', RPAD('-', l_maxlen, '-'),  '------------ ----------'));
  FOR r IN (SELECT TO_CHAR(NVL(dtp.partition_position, 1), '999') AS "#"
                 , NVL(ds.partition_name, ds.segment_name) AS pt_name
                 , CASE WHEN ds.MB >= 1000 THEN TO_CHAR(ds.GB, '9990.999') || ' GB'
                                           ELSE TO_CHAR(ds.MB, '9990.999') || ' MB'
                   END AS space
                 , dtp.high_value
                 , bytes
            FROM (SELECT owner
                       , segment_name
                       , partition_name
                       , SUM(bytes)/1024/1024 as MB
                       , SUM(bytes)/1024/1024/1024 as GB
                       , SUM(bytes) AS bytes
                  FROM dba_segments
                  WHERE (owner = SYS_CONTEXT('userenv', 'current_schema')
                    AND segment_name LIKE UPPER('&1'))
                     OR owner || '.' || segment_name LIKE UPPER('&1')
                  GROUP BY owner, segment_name, partition_name
                 ) ds
               , dba_tab_partitions dtp
            WHERE ds.owner = dtp.table_owner(+)
              AND ds.segment_name = dtp.table_name(+)
              AND ds.partition_name = dtp.partition_name(+)
            ORDER BY dtp.partition_position) LOOP
    IF r.high_value IS NOT NULL THEN
      EXECUTE IMMEDIATE 'SELECT TO_CHAR(' || r.high_value || ', ''YYYY-MM-DD'') FROM DUAL'
      INTO l_high_val;
    ELSE
      l_high_val := 'NON-PART''D';
    END IF;
    l_total_bytes := l_total_bytes + r.bytes;

    k.print(k.args(LPAD(r."#", 4), RPAD(r.pt_name, l_maxlen), LPAD(r.space, 12), l_high_val));
  END LOOP;

  IF l_high_val != 'NON-PART''D' THEN
    IF l_total_bytes > 1024**3 THEN
      l_suff := ' GB';
      l_total_bytes := l_total_bytes/1024**3;
    ELSE
      l_suff := ' MB';
      l_total_bytes := l_total_bytes/1024**2;
    END IF;

    k.print(k.args('    ', LPAD('Total:', l_maxlen),
        LPAD(TO_CHAR(l_total_bytes, '9990.999') || l_suff, 12)));
  END IF;
END;
/
