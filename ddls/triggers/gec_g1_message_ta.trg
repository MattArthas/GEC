CREATE OR REPLACE TRIGGER GEC_G1_MESSAGE_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         G1_MESSAGE_ID, 
         MESSAGE_TYPE, 
         JMS_MESSAGE_ID, 
         JMS_MESSAGE_TIMESTAMP, 
         STATUS, 
         STATUS_MSG,
         IN_OUT, 
         CREATED_AT, 
         CREATED_BY
   ON GEC_G1_MESSAGE
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

   INSERT INTO GEC_G1_MESSAGE_AUD(
         G1_MESSAGE_ID, 
         MESSAGE_TYPE, 
         JMS_MESSAGE_ID, 
         JMS_MESSAGE_TIMESTAMP, 
         STATUS, 
         STATUS_MSG,
         IN_OUT, 
         CREATED_AT, 
         CREATED_BY,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.G1_MESSAGE_ID, :NEW.G1_MESSAGE_ID), 
         DECODE(v_opCode, 'D', :OLD.MESSAGE_TYPE, :NEW.MESSAGE_TYPE), 
         DECODE(v_opCode, 'D', :OLD.JMS_MESSAGE_ID, :NEW.JMS_MESSAGE_ID), 
         DECODE(v_opCode, 'D', :OLD.JMS_MESSAGE_TIMESTAMP, :NEW.JMS_MESSAGE_TIMESTAMP), 
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS), 
         DECODE(v_opCode, 'D', :OLD.STATUS_MSG, :NEW.STATUS_MSG),
         DECODE(v_opCode, 'D', :OLD.IN_OUT, :NEW.IN_OUT), 
         DECODE(v_opCode, 'D', :OLD.CREATED_AT, :NEW.CREATED_AT), 
         DECODE(v_opCode, 'D', :OLD.CREATED_BY, :NEW.CREATED_BY),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_G1_MESSAGE_TA;
/
