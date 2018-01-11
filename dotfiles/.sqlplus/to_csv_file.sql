@@ noformat
SET termout off
SET MARKUP CSV ON QUOTE OFF
SPOOL &1

INPUT garbage -- Stupidness to avoid error message
del 1 last
INPUT &2
/

SPOOL OFF
SET termout on
@@ defaults
-- Line intentionally left blank
