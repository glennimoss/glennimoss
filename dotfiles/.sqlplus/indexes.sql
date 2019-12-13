SET echo off
SET verify off
SET define on

describe &1

COLUMN _a FORMAT a30 HEADING 'INDEX_NAME'
COLUMN _b FORMAT a10 HEADING 'INDEX_TYPE'
COLUMN _c FORMAT a30 HEADING 'COLUMN_NAMES'
COLUMN _d FORMAT a60 HEADING 'COLUMN_EXPRESSION'
COLUMN _e FORMAT a60 HEADING 'SEARCH_CONDITION'
COLUMN _f FORMAT a40 HEADING 'USING_INDEX'
COLUMN _g FORMAT a30 HEADING 'CONSTRAINT_NAME'
PROMPT Indexes:
SELECT DECODE(generated, 'Y', 'Gen''d: ') || index_name AS "_a"
     , REPLACE(index_type, 'FUNCTION-BASED', 'FnB') AS "_b"
     , uniqueness
     , (SELECT LISTAGG(c.column_name, ', ') WITHIN GROUP (ORDER BY c.column_position)
        FROM all_ind_columns c
        WHERE c.index_name = i.index_name
          AND c.index_owner = i.owner) AS "_c"
     , status
     , DECODE(partitioned, 'YES', 'Partitioned', tablespace_name) AS tablespace_name
FROM all_indexes i
WHERE (i.owner = SYS_CONTEXT('userenv', 'current_schema')
  AND i.table_name = UPPER('&1'))
   OR i.owner || '.' || i.table_name = UPPER('&1')
ORDER BY index_name;

PROMPT Index Expressions:
SELECT index_name AS "_a"
     , column_expression AS "_d"
FROM all_ind_expressions e
WHERE (e.table_owner = SYS_CONTEXT('userenv', 'current_schema')
  AND e.table_name = UPPER('&1'))
   OR e.table_owner || '.' || e.table_name = UPPER('&1')
ORDER BY e.index_name, e.column_position;

PROMPT
PROMPT Constraints:
SELECT DECODE(i.generated, 'GENERATED NAME', 'Gen''d: ') || i.constraint_name AS "_g"
     , MAX(i.constraint_type) AS constraint_type
     --, search_condition
     , LISTAGG(c.column_name, ', ') WITHIN GROUP (ORDER BY c.position) AS "_c"
     , CASE WHEN i.index_name IS NOT NULL THEN
         COALESCE(i.index_owner, i.owner) || '.' || i.index_name
       ELSE NULL
       END AS "_f" --using_index
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
ORDER BY "_g";

PROMPT Constraint Expressions:
SELECT i.constraint_name AS "_g"
     , search_condition AS "_e"
FROM all_constraints i
WHERE ((i.owner = SYS_CONTEXT('userenv', 'current_schema')
  AND i.table_name = UPPER('&1'))
   OR i.owner || '.' || i.table_name = UPPER('&1'))
  AND search_condition IS NOT NULL;

SET verify on
