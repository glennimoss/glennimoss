column username format a20
column sid format a10
column object_name format a30

SELECT s.username || ' (' || s.osuser || '@' || s.machine || ')' AS username
     , s.sid || ',' || s.serial# AS sid
     , owner || '.' || object_name AS object_name
     , object_type
     , decode(l.block, 0, 'Not Blocking'
                     , 1, 'Blocking'
                     , 2, 'Global') AS status
     , decode(v.locked_mode, 0, 'None'
                           , 1, 'Null'
                           , 2, 'Row-S (SS)'
                           , 3, 'Row-X (SX)'
                           , 4, 'Share'
                           , 5, 'S/Row-X (SSX)'
                           , 6, 'Exclusive', TO_CHAR(lmode)) AS mode_held
FROM v$locked_object v
   , dba_objects d
   , v$lock l
   , v$session s
WHERE v.object_id = d.object_id
  AND v.object_id = l.id1
  AND v.session_id = s.sid
ORDER BY s.username, s.sid;

