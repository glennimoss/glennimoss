-- $Id$
-- Dump a package description from an oracle instance
-- Usage:
--     sqlplus user/pass@dsn @export_package.sql package_name

-- setup for pretty output
SET define on
SET echo off
SET feedback off
SET heading off
SET linesize 1000
SET newpage 0
SET null ""
SET pagesize 0
SET timing off
SET trimspool on
SET verify off

set termout off
COLUMN line_digits NEW_VALUE line_digits
SELECT MAX(LENGTH(line)) AS line_digits
FROM dba_source
WHERE ((owner = SYS_CONTEXT('userenv', 'current_schema')
  AND name = UPPER('&1'))
   OR owner || '.' || name = UPPER('&1'))
  AND type IN ('PACKAGE', 'TYPE', 'TRIGGER', 'PROCEDURE', 'FUNCTION', 'PACKAGE BODY', 'TYPE BODY');
COLUMN line_digits CLEAR
set termout on

SELECT '/*' || LPAD(line, &line_digits, '0') || '*/' || text
FROM dba_source
WHERE ((owner = SYS_CONTEXT('userenv', 'current_schema')
  AND name = UPPER('&1'))
   OR owner || '.' || name = UPPER('&1'))
  AND type IN ('PACKAGE', 'TYPE', 'TRIGGER', 'PROCEDURE', 'FUNCTION')
ORDER BY line;
PROMPT /
PROMPT

SELECT '/*' || LPAD(line, &line_digits, '0') || '*/' || text
FROM dba_source
WHERE ((owner = SYS_CONTEXT('userenv', 'current_schema')
  AND name = UPPER('&1'))
   OR owner || '.' || name = UPPER('&1'))
  AND type IN ('PACKAGE BODY', 'TYPE BODY')
ORDER BY line;
PROMPT /

set termout off
-- reset settings
@ login
set termout on

