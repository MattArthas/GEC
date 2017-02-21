CREATE OR REPLACE TRIGGER GEC_BBO_ACTIVITY_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         BBO_ACTIVITY_ID, 
         FILE_NAME, 
         SEQ_NUM, 
         STATUS, 
         ACTIVITY_TYPE, 
         ACTIVITY_SUB_TYPE, 
         DATE_TIMESTAMP, 
         RECORD_COUNT, 
         CREATED_AT
   ON GEC_BBO_ACTIVITY
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

   INSERT INTO GEC_BBO_ACTIVITY_AUD(
         BBO_ACTIVITY_ID, 
         FILE_NAME, 
         SEQ_NUM, 
         STATUS, 
         ACTIVITY_TYPE, 
         ACTIVITY_SUB_TYPE, 
         DATE_TIMESTAMP, 
         RECORD_COUNT, 
         CREATED_AT,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.BBO_ACTIVITY_ID, :NEW.BBO_ACTIVITY_ID), 
         DECODE(v_opCode, 'D', :OLD.FILE_NAME, :NEW.FILE_NAME), 
         DECODE(v_opCode, 'D', :OLD.SEQ_NUM, :NEW.SEQ_NUM), 
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS), 
         DECODE(v_opCode, 'D', :OLD.ACTIVITY_TYPE, :NEW.ACTIVITY_TYPE), 
         DECODE(v_opCode, 'D', :OLD.ACTIVITY_SUB_TYPE, :NEW.ACTIVITY_SUB_TYPE), 
         DECODE(v_opCode, 'D', :OLD.DATE_TIMESTAMP, :NEW.DATE_TIMESTAMP), 
         DECODE(v_opCode, 'D', :OLD.RECORD_COUNT, :NEW.RECORD_COUNT), 
         DECODE(v_opCode, 'D', :OLD.CREATED_AT, :NEW.CREATED_AT),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_BBO_ACTIVITY_TA;
/
