SET echo off
SET verify off
SET define on

DECLARE
  l_sql k.args;
  l_sid NUMBER := SYS_CONTEXT('userenv', 'sid');
BEGIN
  FOR r IN (SELECT username, sid, serial#, sql_address, sql.sql_id
            FROM v$session s, v$sql sql
            WHERE s.status = 'ACTIVE'
              AND RAWTOHEX(s.sql_address) != '00'
              AND s.username = UPPER('&1')
              AND s.sid != l_sid
              AND s.sql_address = sql.address) LOOP

    k.print(k.args(r.username, r.sid, r.serial#, r.sql_id));
    l_sql := NULL;
    SELECT sql_text
    BULK COLLECT INTO l_sql
    FROM v$sqltext_with_newlines
    WHERE address = r.sql_address
    ORDER BY piece;
    k.print(l_sql, '');
    /*
    FOR p IN (SELECT * FROM TABLE(dbms_xplan.display_cursor(r.sql_id))) LOOP
      k.print(p.plan_table_output);
    END LOOP;
    */

  END LOOP;
  k.print('DONE');
END;
/
