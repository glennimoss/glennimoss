#!/usr/bin/env bash

SQLPLUS=sqlplus
if [[ $(which sqlplus64) ]]; then
  SQLPLUS=sqlplus64
fi

if [[ $(which rlwrap) ]]; then
  SQLPLUS="rlwrap -b '' -f $HOME/.sqlplus/sql.dict -H $HOME/.sqlplus/history $SQLPLUS"
fi

echo "set editfile $HOME/.sqlplus/scratch${$}.sql" > $HOME/.sqlplus/dyn_login.sql
# You need to export COLUMNS LINES in .bashrc if this doesn't work
if [[ $COLUMNS ]]; then
  echo "set line ${COLUMNS}" >> $HOME/.sqlplus/dyn_login.sql
fi
if [[ $LINES ]]; then
  echo "set pages ${LINES}" >> $HOME/.sqlplus/dyn_login.sql
fi

$SQLPLUS $*

echo -n > $HOME/.sqlplus/dyn_login.sql
