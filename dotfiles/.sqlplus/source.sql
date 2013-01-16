-- $Id$
-- Dump a package description from an oracle instance
-- Usage:
--     sqlplus user/pass@dsn @export_package.sql package_name

-- setup for pretty output
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING OFF
SET VERIFY OFF
SET DEFINE ON
SET NEWPAGE 0
SET NULL ""
SET PAGESIZE 0
SET LINESIZE 1000
SET TRIMSPOOL ON

SELECT text FROM user_source
WHERE name = UPPER('&1') AND type in ('PACKAGE', 'TYPE', 'TRIGGER', 'PROCEDURE', 'FUNCTION')
ORDER BY line;
PROMPT /
PROMPT

SELECT text FROM user_source
WHERE name = UPPER('&1') AND type in ('PACKAGE BODY', 'TYPE BODY')
ORDER BY line;
PROMPT /

-- reset settings
@ login

