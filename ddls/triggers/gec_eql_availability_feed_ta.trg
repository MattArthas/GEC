CREATE OR REPLACE TRIGGER GEC_EQL_AVAILABILITY_FEED_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         EQL_AVAILABILITY_FEED_ID, 
         FROM_CORP_ID, 
         FROM_LEGAL_ENTITY_ID, 
         TO_CORP_ID, 
         TO_LEGAL_ENTITY_ID, 
         ALERT_TIME, 
         SUBACOUNT, 
         STATUS,
         LAST_ALERT_TIME
   ON GEC_EQL_AVAILABILITY_FEED
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

   INSERT INTO GEC_EQL_AVAILABILITY_FEED_AUD(
         EQL_AVAILABILITY_FEED_ID, 
         FROM_CORP_ID, 
         FROM_LEGAL_ENTITY_ID, 
         TO_CORP_ID, 
         TO_LEGAL_ENTITY_ID, 
         ALERT_TIME, 
         SUBACOUNT, 
         STATUS,
         LAST_ALERT_TIME,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.EQL_AVAILABILITY_FEED_ID, :NEW.EQL_AVAILABILITY_FEED_ID), 
         DECODE(v_opCode, 'D', :OLD.FROM_CORP_ID, :NEW.FROM_CORP_ID), 
         DECODE(v_opCode, 'D', :OLD.FROM_LEGAL_ENTITY_ID, :NEW.FROM_LEGAL_ENTITY_ID), 
         DECODE(v_opCode, 'D', :OLD.TO_CORP_ID, :NEW.TO_CORP_ID), 
         DECODE(v_opCode, 'D', :OLD.TO_LEGAL_ENTITY_ID, :NEW.TO_LEGAL_ENTITY_ID), 
         DECODE(v_opCode, 'D', :OLD.ALERT_TIME, :NEW.ALERT_TIME), 
         DECODE(v_opCode, 'D', :OLD.SUBACOUNT, :NEW.SUBACOUNT), 
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
         DECODE(v_opCode, 'D', :OLD.LAST_ALERT_TIME, :NEW.LAST_ALERT_TIME),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_EQL_AVAILABILITY_FEED_TA;
/