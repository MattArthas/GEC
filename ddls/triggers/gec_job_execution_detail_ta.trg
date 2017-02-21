CREATE OR REPLACE TRIGGER GEC_JOB_EXECUTION_DETAIL_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         JOB_EXECUTION_DETAIL_ID,
         JOB_TYPE,
         START_TIME,
         END_TIME,
         FILE_NAME,
         TOTAL_RECORDS_NUMBER,
         FAIL_RECORDS_NUMBER,
         STATUS
   ON GEC_JOB_EXECUTION_DETAIL
   FOR EACH ROW
DECLARE
   v_opCode CHAR(1);
BEGIN
   v_opCode := CASE WHEN INSERTING THEN 'I'
                    WHEN UPDATING  THEN 'U'
                    WHEN DELETING  THEN 'D'
               END;
   IF v_opCode = 'I' OR v_opCode = 'U'
   THEN
   :new.LAST_UPDATED_AT := sysdate;
   :new.LAST_UPDATED_BY := substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
   	   sys_context('USERENV','OS_USER')|| '@' || sys_context('USERENV','HOST')),1,32);
   END IF;

   INSERT INTO GEC_JOB_EXECUTION_DETAIL_AUD(
         JOB_EXECUTION_DETAIL_ID,
         JOB_TYPE,
         START_TIME,
         END_TIME,
         FILE_NAME,
         TOTAL_RECORDS_NUMBER,
         FAIL_RECORDS_NUMBER,
         STATUS,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.JOB_EXECUTION_DETAIL_ID, :NEW.JOB_EXECUTION_DETAIL_ID),
         DECODE(v_opCode, 'D', :OLD.JOB_TYPE, :NEW.JOB_TYPE),
         DECODE(v_opCode, 'D', :OLD.START_TIME, :NEW.START_TIME),
         DECODE(v_opCode, 'D', :OLD.END_TIME, :NEW.END_TIME),
         DECODE(v_opCode, 'D', :OLD.FILE_NAME, :NEW.FILE_NAME),
         DECODE(v_opCode, 'D', :OLD.TOTAL_RECORDS_NUMBER, :NEW.TOTAL_RECORDS_NUMBER),
         DECODE(v_opCode, 'D', :OLD.FAIL_RECORDS_NUMBER, :NEW.FAIL_RECORDS_NUMBER),
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_JOB_EXECUTION_DETAIL_TA;
/

