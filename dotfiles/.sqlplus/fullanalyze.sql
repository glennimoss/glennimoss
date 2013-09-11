SET echo off
SET verify off
SET define on

DECLARE
  l_start NUMBER := k.time();
BEGIN
  dbms_stats.gather_table_stats(ownname => USER, tabname => UPPER('&1'),
    cascade => TRUE, estimate_percent => NULL);
  k.print(k.args('Analyzing &1 took', k.time() - l_start));
END;
/

SET verify on
