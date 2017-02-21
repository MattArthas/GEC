CREATE OR REPLACE TRIGGER GEC_CHAT_DETAIL_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         CHAT_DETAIL_ID,
         CHAT_SESSION_ID,
         FROM_USER_ID,
         TO_USER_ID,
         SEND_TIME,
         LOCATE_ID,
         CHAT_MSG,
         STATUS
   ON GEC_CHAT_DETAIL
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

   INSERT INTO GEC_CHAT_DETAIL_AUD(
         CHAT_DETAIL_ID,
         CHAT_SESSION_ID,
         FROM_USER_ID,
         TO_USER_ID,
         SEND_TIME,
         LOCATE_ID,
         CHAT_MSG,
         STATUS,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.CHAT_DETAIL_ID, :NEW.CHAT_DETAIL_ID),
         DECODE(v_opCode, 'D', :OLD.CHAT_SESSION_ID, :NEW.CHAT_SESSION_ID),
         DECODE(v_opCode, 'D', :OLD.FROM_USER_ID, :NEW.FROM_USER_ID),
         DECODE(v_opCode, 'D', :OLD.TO_USER_ID, :NEW.TO_USER_ID),
         DECODE(v_opCode, 'D', :OLD.SEND_TIME, :NEW.SEND_TIME),
         DECODE(v_opCode, 'D', :OLD.LOCATE_ID, :NEW.LOCATE_ID),
         DECODE(v_opCode, 'D', :OLD.CHAT_MSG, :NEW.CHAT_MSG),
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_CHAT_DETAIL_TA;
/

