CREATE OR REPLACE TRIGGER GEC_TRADING_DESK_JOB_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         DESK_CD,
         JOB_NAME,
         JOB_TIME_STR,
         LOCALE,
         STATUS,
         STATUS_MSG,
         JOB_COMMENT
   ON GEC_TRADING_DESK_JOB
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

   INSERT INTO GEC_TRADING_DESK_JOB_AUD(
         DESK_CD,
         JOB_NAME,
         JOB_TIME_STR,
         LOCALE,
         STATUS,
         STATUS_MSG,
         JOB_COMMENT,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.DESK_CD, :NEW.DESK_CD),
         DECODE(v_opCode, 'D', :OLD.JOB_NAME, :NEW.JOB_NAME),
         DECODE(v_opCode, 'D', :OLD.JOB_TIME_STR, :NEW.JOB_TIME_STR),
         DECODE(v_opCode, 'D', :OLD.LOCALE, :NEW.LOCALE),
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
         DECODE(v_opCode, 'D', :OLD.STATUS_MSG, :NEW.STATUS_MSG),
         DECODE(v_opCode, 'D', :OLD.JOB_COMMENT, :NEW.JOB_COMMENT),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_TRADING_DESK_JOB_TA;
/

