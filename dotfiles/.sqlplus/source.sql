-- $Id$
-- Dump a package description from an oracle instance
-- Usage:
--     sqlplus user/pass@dsn @export_package.sql package_name

-- setup for pretty output
SET echo off
SET feedback off
SET heading off
SET verify off
SET define on
SET newpage 0
SET null ""
SET pagesize 0
SET linesize 1000
SET trimspool on

SELECT '/*' || line || '*/' || text
FROM user_source
WHERE name = UPPER('&1')
  AND type IN ('PACKAGE', 'TYPE', 'TRIGGER', 'PROCEDURE', 'FUNCTION')
ORDER BY line;
PROMPT /
PROMPT

SELECT '/*' || line || '*/' || text
FROM user_source
WHERE name = UPPER('&1')
  AND type IN ('PACKAGE BODY', 'TYPE BODY')
ORDER BY line;
PROMPT /

-- reset settings
@ login

