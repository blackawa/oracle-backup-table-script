@ready_for_spool.sql
SPOOL ./tmp/TAB_COLUMNS_&1
SELECT COLUMN_NAME FROM USER_TAB_COLUMNS WHERE TABLE_NAME = '&1' GROUP BY COLUMN_NAME;
SPOOL OFF
EXIT;
