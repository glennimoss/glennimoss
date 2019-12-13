@@ noformat

COLUMN var_out NEW_VALUE 3
SELECT '' AS var_out FROM dual WHERE 1=0;
COLUMN var_out CLEAR

SET heading on
SET termout off
SET MARKUP CSV ON QUOTE OFF
SPOOL &1

INPUT garbage -- Stupidness to avoid error message
del 1 last
INPUT &2 &3
/

SPOOL OFF

undef 1
undef 2
undef 3

SET termout on
@@ defaults
-- Line intentionally left blank
