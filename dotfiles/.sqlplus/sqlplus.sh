#!/usr/bin/env bash

SQLPLUS=sqlplus
if [[ $(which sqlplus64) ]]; then
  SQLPLUS=sqlplus64
fi

if [[ $(which rlwrap) ]]; then
  touch $HOME/.sqlplus/history
  SQLPLUS="rlwrap -f $HOME/.sqlplus/sql_reserved.dict -f $HOME/.sqlplus/history -r -H $HOME/.sqlplus/history --histsize 30000 $SQLPLUS"
fi

SCRATCH=$HOME/.sqlplus/scratch${$}.sql
echo "set editfile $SCRATCH" > $HOME/.sqlplus/dyn_login.sql
# You need to export COLUMNS LINES in .bashrc if this doesn't work
if [[ $COLUMNS ]]; then
  echo "set line ${COLUMNS}" >> $HOME/.sqlplus/dyn_login.sql
fi
if [[ $LINES ]]; then
  echo "set pages ${LINES}" >> $HOME/.sqlplus/dyn_login.sql
fi

$SQLPLUS $*

echo -n > $HOME/.sqlplus/dyn_login.sql
rm -f $SCRATCH
