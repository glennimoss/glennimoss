set echo off
SET VERIFY OFF
set define on
column index_type format a10
column column_names format a30
column column_name format a30
column column_expressions format a60
column column_expression format a60
column search_condition format a60
column using_index format a40
prompt Indexes:
SELECT DECODE(generated, 'Y', 'Gen''d: ') || index_name AS index_name
     , REPLACE(index_type, 'FUNCTION-BASED', 'FnB') AS index_type
     , uniqueness
     , (SELECT LISTAGG(c.column_name, ', ') WITHIN GROUP (ORDER BY c.column_position)
        FROM user_ind_columns c
        WHERE c.index_name = i.index_name) AS column_names
     , status
     , DECODE(partitioned, 'YES', 'Partitioned', tablespace_name) AS tablespace_name
FROM user_indexes i
WHERE i.table_name = UPPER('&1');

prompt Index Expressions:
SELECT index_name
     , column_expression
FROM user_ind_expressions e
WHERE e.table_name = UPPER('&1')
ORDER BY e.index_name, e.column_position;

prompt
prompt Constraints:
SELECT DECODE(i.generated, 'GENERATED NAME', 'Gen''d: ') || i.constraint_name AS constraint_name
     , MAX(i.constraint_type) AS constraint_type
     --, search_condition
     , LISTAGG(c.column_name, ', ') WITHIN GROUP (ORDER BY c.position) AS column_names
     , CASE WHEN i.index_name IS NOT NULL THEN
         i.index_owner || '.' || i.index_name
       ELSE NULL
       END AS using_index
     , MAX(i.status) AS status
     , i.delete_rule
FROM user_constraints i
   , user_cons_columns c
WHERE i.table_name = UPPER('&1')
  AND i.constraint_name = c.constraint_name(+)
GROUP BY i.constraint_name, i.generated, i.index_owner, i.index_name, i.status, i.delete_rule;

prompt Constraint Expressions:
SELECT i.constraint_name
     , search_condition
FROM user_constraints i
WHERE i.table_name = UPPER('&1')
  AND search_condition IS NOT NULL;

SET VERIFY ON
