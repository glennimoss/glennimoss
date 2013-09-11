SET serveroutput on format wrapped
SET recsep wrapped
SET recsepchar _
SET sqlprompt "_USER'@'_CONNECT_IDENTIFIER'>' "
SET long 20000
SET null "{NULL}"
SET feedback on
SET heading on
SET trimspool off
SET newpage 1
ALTER SESSION SET nls_date_format="YYYY-MM-DD HH24:MI:SS";
ALTER SESSION SET nls_timestamp_format="YYYY-MM-DD HH24:MI:SSXFF";

@@ dyn_login.sql

