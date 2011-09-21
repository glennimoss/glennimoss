set echo off
SET VERIFY OFF
column column_names format a50
column column_name format a30
column column_expressions format a60
column column_expression format a60
column search_condition format a60
prompt INDEXES:
SELECT i.index_name
     , MAX(i.index_type) AS index_type
     , MAX(uniqueness) AS uniqueness
     , LISTAGG(c.column_name, ', ') WITHIN GROUP (ORDER BY c.column_position) AS column_names
FROM user_indexes i
   , user_ind_columns c
   --, user_ind_expressions e
WHERE i.table_name = UPPER('&1')
  AND i.index_name = c.index_name(+)
  --AND i.index_name = e.index_name(+)
GROUP BY i.index_name;

prompt
prompt CONSTRAINTS:
SELECT i.constraint_name
     , MAX(i.constraint_type) AS constraint_type
     --, LISTAGG(i.search_condition, ', ') WITHIN GROUP (ORDER BY c.position) as search_condition
     , LISTAGG(c.column_name, ', ') WITHIN GROUP (ORDER BY c.position) AS column_names
FROM user_constraints i
   , user_cons_columns c
WHERE i.table_name = UPPER('&1')
  --AND i.constraint_type != 'P'
  AND i.constraint_name = c.constraint_name(+)
GROUP BY i.constraint_name;

SET VERIFY ON
