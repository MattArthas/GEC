-- remove job
BEGIN
	DBMS_SCHEDULER.DROP_JOB('GEC_DAILY_JOB');
END;
/

--Daily job. Should modify start_date with appropriate Boston time. 
BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
        JOB_NAME => 'GEC_DAILY_JOB',
        JOB_TYPE => 'STORED_PROCEDURE',
        JOB_ACTION => 'GEC_DAILY_JOB_PKG.DAILY_JOB',
        START_DATE => TRUNC(SYSDATE) + 1/24,
        REPEAT_INTERVAL => 'FREQ=DAILY; INTERVAL=1',
        END_DATE => SYSDATE+7300,
        ENABLED => TRUE,
        AUTO_DROP => FALSE,
        COMMENTS => 'Archive, purge. And set sequence start value of GEC_FILE_COUNTER_SEQ to 1'
        );
END;
/
