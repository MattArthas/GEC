CREATE OR REPLACE TRIGGER GEC_MQ_LISTENER_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         MQ_NAME, 
         STATUS, 
         UPDATED_AT, 
         UPDATED_BY, 
         LISTENER_NAME
   ON GEC_MQ_LISTENER
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

   INSERT INTO GEC_MQ_LISTENER_AUD(
         MQ_NAME, 
         STATUS, 
         UPDATED_AT, 
         UPDATED_BY, 
         LISTENER_NAME,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.MQ_NAME, :NEW.MQ_NAME), 
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS), 
         DECODE(v_opCode, 'D', :OLD.UPDATED_AT, :NEW.UPDATED_AT), 
         DECODE(v_opCode, 'D', :OLD.UPDATED_BY, :NEW.UPDATED_BY), 
         DECODE(v_opCode, 'D', :OLD.LISTENER_NAME, :NEW.LISTENER_NAME),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_MQ_LISTENER_TA;
/
