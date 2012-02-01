set serveroutput on format wrapped
set recsep wrapped
set recsepchar _
set sqlprompt "_USER'@'_CONNECT_IDENTIFIER'>' "
set long 20000
set NULL "{NULL}"
set feedback on
set heading on
set trimspool off
set newpage 1
alter session set nls_date_format="YYYY-MM-DD HH24:MI:SS";
alter session set nls_timestamp_format="YYYY-MM-DD HH24:MI:SSXFF";

@@ dyn_login.sql

