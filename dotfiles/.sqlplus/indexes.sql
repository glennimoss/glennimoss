SET echo off
SET verify off
SET define on

describe &1

COLUMN index_type         FORMAT a10
COLUMN column_names       FORMAT a30
COLUMN column_name        FORMAT a30
COLUMN column_expressions FORMAT a60
COLUMN column_expression  FORMAT a60
COLUMN search_condition   FORMAT a60
COLUMN using_index        FORMAT a40
PROMPT Indexes:
SELECT DECODE(generated, 'Y', 'Gen''d: ') || index_name AS index_name
     , REPLACE(index_type, 'FUNCTION-BASED', 'FnB') AS index_type
     , uniqueness
     , (SELECT LISTAGG(c.column_name, ', ') WITHIN GROUP (ORDER BY c.column_position)
        FROM all_ind_columns c
        WHERE c.index_name = i.index_name
          AND c.index_owner = i.owner) AS column_names
     , status
     , DECODE(partitioned, 'YES', 'Partitioned', tablespace_name) AS tablespace_name
FROM all_indexes i
WHERE (i.owner = SYS_CONTEXT('userenv', 'current_schema')
  AND i.table_name = UPPER('&1'))
   OR i.owner || '.' || i.table_name = UPPER('&1')
ORDER BY index_name;

PROMPT Index Expressions:
SELECT index_name
     , column_expression
FROM all_ind_expressions e
WHERE (e.table_owner = SYS_CONTEXT('userenv', 'current_schema')
  AND e.table_name = UPPER('&1'))
   OR e.table_owner || '.' || e.table_name = UPPER('&1')
ORDER BY e.index_name, e.column_position;

PROMPT
PROMPT Constraints:
SELECT DECODE(i.generated, 'GENERATED NAME', 'Gen''d: ') || i.constraint_name AS constraint_name
     , MAX(i.constraint_type) AS constraint_type
     --, search_condition
     , LISTAGG(c.column_name, ', ') WITHIN GROUP (ORDER BY c.position) AS column_names
     , CASE WHEN i.index_name IS NOT NULL THEN
         COALESCE(i.index_owner, i.owner) || '.' || i.index_name
       ELSE NULL
       END AS using_index
     , MAX(i.status) AS status
     , i.delete_rule
FROM all_constraints i
   , all_cons_columns c
WHERE ((i.owner = SYS_CONTEXT('userenv', 'current_schema')
  AND i.table_name = UPPER('&1'))
   OR i.owner || '.' || i.table_name = UPPER('&1'))
  AND i.constraint_name = c.constraint_name(+)
  AND i.owner = c.owner(+)
GROUP BY i.constraint_name, i.generated, i.owner, i.index_owner, i.index_name, i.status, i.delete_rule
ORDER BY constraint_name;

PROMPT Constraint Expressions:
SELECT i.constraint_name
     , search_condition
FROM all_constraints i
WHERE ((i.owner = SYS_CONTEXT('userenv', 'current_schema')
  AND i.table_name = UPPER('&1'))
   OR i.owner || '.' || i.table_name = UPPER('&1'))
  AND search_condition IS NOT NULL;

COLUMN index_type         CLEAR
COLUMN column_names       CLEAR
COLUMN column_name        CLEAR
COLUMN column_expressions CLEAR
COLUMN column_expression  CLEAR
COLUMN search_condition   CLEAR
COLUMN using_index        CLEAR

SET verify on
