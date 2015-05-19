-- $Id$
-- Dump a package description from an oracle instance
-- Usage:
--     sqlplus user/pass@dsn @export_package.sql package_name

-- setup for pretty output
SET echo off
SET define on
SET feedback off
SET heading off
SET linesize 1000
SET newpage 0
SET null ""
SET pagesize 0
SET trimspool on
SET timing off
SET verify off

-- send output to file
SET term off;
DEFINE filename=exported_&1..java
SPOOL &filename

SELECT text
FROM user_source
WHERE name = '&1'
  AND type = 'JAVA SOURCE'
ORDER BY line;

-- send output back to terminal
SPOOL OFF;
SET term on;

PROMPT
PROMPT Created &filename
PROMPT

@login

