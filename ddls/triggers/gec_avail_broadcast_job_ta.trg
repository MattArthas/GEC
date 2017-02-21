CREATE OR REPLACE TRIGGER GEC_AVAIL_BROADCAST_JOB_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         BRAODCAST_JOB_ID, 
         STRATEGY_ID, 
         BROADCAST_DATE, 
         BROADCAST_TIME, 
         ACTUAL_BROADCAST_DATE, 
         ACTUAL_BROADCAST_TIME, 
         BROADCASTED_FLAG, 
         ERROR_MESSAGE, 
         CREATED_AT, 
         CREATED_BY, 
         UPDATED_AT, 
         UPDATED_BY
   ON GEC_AVAIL_BROADCAST_JOB
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

   INSERT INTO GEC_AVAIL_BROADCAST_JOB_AUD(
         BRAODCAST_JOB_ID, 
         STRATEGY_ID, 
         BROADCAST_DATE, 
         BROADCAST_TIME, 
         ACTUAL_BROADCAST_DATE, 
         ACTUAL_BROADCAST_TIME, 
         BROADCASTED_FLAG, 
         ERROR_MESSAGE, 
         CREATED_AT, 
         CREATED_BY, 
         UPDATED_AT, 
         UPDATED_BY,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.BRAODCAST_JOB_ID, :NEW.BRAODCAST_JOB_ID), 
         DECODE(v_opCode, 'D', :OLD.STRATEGY_ID, :NEW.STRATEGY_ID), 
         DECODE(v_opCode, 'D', :OLD.BROADCAST_DATE, :NEW.BROADCAST_DATE), 
         DECODE(v_opCode, 'D', :OLD.BROADCAST_TIME, :NEW.BROADCAST_TIME), 
         DECODE(v_opCode, 'D', :OLD.ACTUAL_BROADCAST_DATE, :NEW.ACTUAL_BROADCAST_DATE), 
         DECODE(v_opCode, 'D', :OLD.ACTUAL_BROADCAST_TIME, :NEW.ACTUAL_BROADCAST_TIME), 
         DECODE(v_opCode, 'D', :OLD.BROADCASTED_FLAG, :NEW.BROADCASTED_FLAG), 
         DECODE(v_opCode, 'D', :OLD.ERROR_MESSAGE, :NEW.ERROR_MESSAGE), 
         DECODE(v_opCode, 'D', :OLD.CREATED_AT, :NEW.CREATED_AT), 
         DECODE(v_opCode, 'D', :OLD.CREATED_BY, :NEW.CREATED_BY), 
         DECODE(v_opCode, 'D', :OLD.UPDATED_AT, :NEW.UPDATED_AT), 
         DECODE(v_opCode, 'D', :OLD.UPDATED_BY, :NEW.UPDATED_BY),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_AVAIL_BROADCAST_JOB_TA;
/
