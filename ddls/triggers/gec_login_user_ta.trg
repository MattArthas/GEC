CREATE OR REPLACE TRIGGER GEC_LOGIN_USER_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         LOGIN_ID,
         USER_ID,
         LOGIN_TIME,
         LOGOFF_TIME,
         STATUS,
         USER_AGENT
   ON GEC_LOGIN_USER
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

   INSERT INTO GEC_LOGIN_USER_AUD(
         LOGIN_ID,
         USER_ID,
         LOGIN_TIME,
         LOGOFF_TIME,
         STATUS,
         USER_AGENT,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.LOGIN_ID, :NEW.LOGIN_ID),
         DECODE(v_opCode, 'D', :OLD.USER_ID, :NEW.USER_ID),
         DECODE(v_opCode, 'D', :OLD.LOGIN_TIME, :NEW.LOGIN_TIME),
         DECODE(v_opCode, 'D', :OLD.LOGOFF_TIME, :NEW.LOGOFF_TIME),
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
         DECODE(v_opCode, 'D', :OLD.USER_AGENT, :NEW.USER_AGENT),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_LOGIN_USER_TA;
/

