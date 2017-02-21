CREATE OR REPLACE TRIGGER GEC_CHAT_SESSION_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         CHAT_SESSION_ID,
         INITIATE_USER_ID,
         INITIATE_TIME,
         ACCEPT_USER_ID,
         ACCEPT_TIME,
         CLOSE_USER_ID,
         CLOSE_TIME,
         STATUS
   ON GEC_CHAT_SESSION
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

   INSERT INTO GEC_CHAT_SESSION_AUD(
         CHAT_SESSION_ID,
         INITIATE_USER_ID,
         INITIATE_TIME,
         ACCEPT_USER_ID,
         ACCEPT_TIME,
         CLOSE_USER_ID,
         CLOSE_TIME,
         STATUS,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.CHAT_SESSION_ID, :NEW.CHAT_SESSION_ID),
         DECODE(v_opCode, 'D', :OLD.INITIATE_USER_ID, :NEW.INITIATE_USER_ID),
         DECODE(v_opCode, 'D', :OLD.INITIATE_TIME, :NEW.INITIATE_TIME),
         DECODE(v_opCode, 'D', :OLD.ACCEPT_USER_ID, :NEW.ACCEPT_USER_ID),
         DECODE(v_opCode, 'D', :OLD.ACCEPT_TIME, :NEW.ACCEPT_TIME),
         DECODE(v_opCode, 'D', :OLD.CLOSE_USER_ID, :NEW.CLOSE_USER_ID),
         DECODE(v_opCode, 'D', :OLD.CLOSE_TIME, :NEW.CLOSE_TIME),
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_CHAT_SESSION_TA;
/

