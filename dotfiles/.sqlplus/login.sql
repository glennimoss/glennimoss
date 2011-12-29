set serveroutput on format wrapped
set recsepchar _
set sqlprompt "_USER'@'_CONNECT_IDENTIFIER'>' "
set long 20000
set NULL "{NULL}"
set feedback on
alter session set nls_date_format="YYYY-MM-DD HH24:MI:SS";
alter session set nls_timestamp_format="YYYY-MM-DD HH24:MI:SSXFF";
