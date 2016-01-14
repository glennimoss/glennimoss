SET echo off
SET verify off
SET define on

DECLARE
  l_obj k.t_string_array :=
    string_util.split(UPPER('&1'), '.');
  l_type k.string;
BEGIN
  IF l_obj.count = 1 THEN
    --k.print('Specify the object with SCHEMA.OBJECT_NAME');
    --RETURN;

    l_obj(2) := l_obj(1);
    l_obj(1) := SYS_CONTEXT('userenv', 'current_schema');
  END IF;
  SELECT object_type
  INTO l_type
  FROM dba_objects
  WHERE owner = l_obj(1)
    AND object_name = l_obj(2)
    AND object_type NOT LIKE '%PARTITION'
    AND rownum = 1;

  k.print(dbms_metadata.get_ddl(l_type, l_obj(2), l_obj(1)));
END;
/

SET verify on
