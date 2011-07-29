set echo off
column column_names format a80
column column_name format a80
column column_expressions format a60
column column_expression format a60
column search_condition format a60
prompt INDEXES:
--SELECT i.index_name, max(i.index_type), max(uniqueness), listagg(c.column_name, ', ') within group (order by c.column_position) as column_names/*, listagg(cast(e.column_expression as varchar2(4000))) within group (order by e.column_position) as column_expressions*/
SELECT i.index_name, i.index_type, i.uniqueness, c.column_name, e.column_expression
FROM user_indexes i
   , user_ind_columns c
   , user_ind_expressions e
WHERE i.table_name = UPPER('&1')
  AND i.index_name = c.index_name(+)
  AND i.index_name = e.index_name(+)
--GROUP BY i.index_name;

prompt
prompt CONSTRAINTS:
SELECT i.constraint_name, i.constraint_type, c.column_name, i.search_condition
FROM user_constraints i
   , user_cons_columns c
WHERE i.table_name = UPPER('&1')
  AND i.constraint_name = c.constraint_name(+);

