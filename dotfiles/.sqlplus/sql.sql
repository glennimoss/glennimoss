SET echo off
SET verify off
SET define on

SET feedback off
COLUMN var_out NEW_VALUE 2
SELECT '' AS var_out FROM dual WHERE 1=0;
SET feedback on
COLUMN var_out CLEAR

DECLARE
  l_sql k.args;
  l_inst_id NUMBER := SYS_CONTEXT('userenv', 'instance');
  l_sid NUMBER := SYS_CONTEXT('userenv', 'sid');
  TYPE r_partition IS RECORD
  ( name dba_objects.subobject_name%TYPE
  , pos dba_tab_partitions.partition_position%TYPE
  , num_parts dba_tab_partitions.partition_position%TYPE
  );
  l_partition r_partition;
BEGIN
  k.print(k.args('Current instance:', l_inst_id, 'sid:', l_sid));
  FOR r IN (SELECT username
                 , s.sid
                 , s.serial#
                 , s.sql_id
                 , s.sql_child_number
                 , s.last_call_et
                 , s.row_wait_obj#
                 , sql.sql_fulltext
                 , sql.last_active_time
                 , sql.is_reoptimizable
                 , sql.is_resolved_adaptive_plan
            FROM v$session s
            LEFT OUTER JOIN v$sql sql ON s.sql_id = sql.sql_id AND s.sql_child_number = sql.child_number
            WHERE s.username = UPPER('&1')
              AND ('&2' IS NULL
                OR LOWER(s.machine) = LOWER('&2'))
              AND s.status = 'ACTIVE'
              AND s.sid != l_sid
              --AND sql.sql_text NOT LIKE '%V$SESSION%' SLOW!
            ) LOOP

    k.print(k.args(r.username, r.sid, r.serial#, r.sql_id, r.last_active_time));
    IF r.is_reoptimizable != 'N' THEN
      k.print(k.args('Reoptimizable', r.is_reoptimizable));
    END IF;
    IF r.is_resolved_adaptive_plan = 'Y' THEN
      k.print('Resolved Adaptive Plan');
    END IF;
    k.print(k.args('Estimated elapsed time:', r.last_call_et, 's'));
    FOR b in (SELECT position, name, was_captured, datatype_string, value_string, last_captured
              FROM v$sql_bind_capture
              WHERE sql_id = r.sql_id
                AND child_number = r.sql_child_number
              ORDER BY position) LOOP
      k.print(k.args('Bind #' || b.position || ':', b.name, b.datatype_string, 'Captured?', b.was_captured, b.last_captured, 'Value:', b.value_string));
    END LOOP;
    k.print();


    FOR p IN (SELECT *
              FROM TABLE(dbms_xplan.display_cursor(r.sql_id, r.sql_child_number, 'ROWS BYTES ADAPTIVE COST NOTE REMOTE PARTITION PARALLEL'))) LOOP
      k.print(p.plan_table_output);
    END LOOP;

    FOR o IN (SELECT sql_plan_line_id, sql_plan_operation, sql_plan_options, opname, target, target_desc, sofar, totalwork, units, start_time, last_update_time, time_remaining, elapsed_seconds, time_remaining+elapsed_seconds AS total_seconds, message
      FROM v$session_longops
      WHERE sid = r.sid
        AND serial# = r.serial#
        AND sql_id = r.sql_id
        AND totalwork != 0
        AND sofar != totalwork
        AND time_remaining > 0
      ) LOOP

      l_partition.name := NULL;
      BEGIN
        SELECT subobject_name, dtp.partition_position, (SELECT MAX(partition_position) FROM dba_tab_partitions dtp2 WHERE dtp2.table_owner = do.owner AND dtp2.table_name = do.object_name) AS num_partitions
        INTO l_partition
        FROM dba_objects do
        JOIN dba_tab_partitions dtp ON dtp.table_owner = do.owner AND dtp.table_name = do.object_name AND dtp.partition_name = do.subobject_name
        WHERE do.object_id = r.row_wait_obj#
          AND do.object_type = 'TABLE PARTITION'
          AND do.owner ||'.'|| do.object_name = o.target;
      EXCEPTION WHEN no_data_found THEN NULL;
      END;

      k.print(k.args('Line', o.sql_plan_line_id, o.sql_plan_operation, o.sql_plan_options));
      k.print(k.args('  opname:', o.opname));
      k.print(k.args('  target:', o.target, o.target_desc, CASE WHEN l_partition.name IS NOT NULL THEN l_partition.name || ' ' || l_partition.pos || '/' || l_partition.num_parts END));
      k.print(k.args('  start_time:', o.start_time));
      k.print(k.args('  last_update_time:', o.last_update_time));
      k.print(k.args('  work:', o.sofar, '/', o.totalwork, o.units, '=', ROUND(o.sofar/o.totalwork*100, 1) || '%'));
      k.print(k.args('  time:', o.elapsed_seconds || 's', '+', o.time_remaining || 's', '=', o.total_seconds || 's', ROUND(o.elapsed_seconds/o.total_seconds*100,1) || '%'));
      k.print(k.args('  message:', o.message));
    END LOOP;
    k.print();

  END LOOP;
  k.print('DONE');
END;
/
