SET echo off
SET verify off
SET define on
SET timing off

SET feedback off
COLUMN var_out NEW_VALUE 1
SELECT '' AS var_out FROM dual WHERE 1=0;
SET feedback on

COLUMN var_out CLEAR
COLUMN job_name FORMAT a30
COLUMN job_type FORMAT a16
COLUMN job_action FORMAT a35
COLUMN repeat_interval FORMAT a32
COLUMN enabled FORMAT a7

SELECT job_name, job_type, job_action, repeat_interval, enabled
FROM dba_scheduler_jobs
WHERE owner = UPPER('&1')
   OR ('&1' IS NULL AND owner = SYS_CONTEXT('userenv', 'current_schema'));

COLUMN job_name CLEAR
COLUMN job_type CLEAR
COLUMN job_action CLEAR
COLUMN repeat_interval CLEAR
COLUMN enabled CLEAR

undefine 1

@@ defaults

