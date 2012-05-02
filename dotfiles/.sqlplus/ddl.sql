SET ECHO OFF
SET VERIFY OFF
SET DEFINE ON

DECLARE
  l_obj k.t_string_array :=
    string_util.split(UPPER('&1'), '.');
  l_type k.string;
BEGIN
  IF l_obj.count = 1 THEN
    k.print('Specify the object with SCHEMA.OBJECT_NAME');
    RETURN;
  END IF;
  SELECT object_type
  INTO l_type
  FROM all_objects
  WHERE owner = l_obj(1)
    AND object_name = l_obj(2)
    AND object_type NOT LIKE '%PARTITION'
    AND rownum = 1;

  k.print(dbms_metadata.get_ddl(l_type, l_obj(2), l_obj(1)));
END;
/

SET VERIFY ON
