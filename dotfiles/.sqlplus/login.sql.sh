#!/usr/bin/env bash

echo "set line ${COLUMNS}"
echo "set pages ${LINES}"
echo 'set serveroutput on format wrapped'
echo 'set recsepchar _'
echo "set sqlprompt \"_USER'@'_CONNECT_IDENTIFIER'>' \""
echo 'set long 20000'
echo 'set NULL "{NULL}"'
echo 'set feedback on'
echo "set editfile /home/gim/.sqlplus/scratch${$}.sql"
echo 'alter session set nls_date_format="YYYY-MM-DD HH24:MI:SS";'
echo 'alter session set nls_timestamp_format="YYYY-MM-DD HH24:MI:SSXFF";'
