-- $Id$
-- Dump a package description from an oracle instance
-- Usage:
--     sqlplus user/pass@dsn @export_package.sql package_name

-- setup for pretty output
SET ECHO OFF
SET DEFINE ON
SET FEEDBACK OFF
SET HEADING OFF
SET LINESIZE 1000
SET NEWPAGE 0
SET NULL ""
SET PAGESIZE 0
SET TRIMSPOOL ON
SET VERIFY OFF

-- send output to file
SET TERM OFF;
define filename=exported_&1..java
SPOOL &filename

SELECT text FROM user_source
WHERE name = '&1' AND type = 'JAVA SOURCE'
ORDER BY line;

-- send output back to terminal
SPOOL OFF;
SET TERM ON;

PROMPT
PROMPT Created &filename
PROMPT

@login

