CREATE OR REPLACE TRIGGER GEC_USER_PREF_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         USER_ID,
         SFA_EMAILS,
         SFA_FILE_LOCATION,
         ROW_NUMBER,
         CHAT_AUDIO_INDICATOR,
         CHAT_AUDIO_INDICATE_INTERVAL,
         SEPARATOR_TYPE,
         TIME_FORMAT,
         DATE_FORMAT
   ON GEC_USER_PREF
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

   INSERT INTO GEC_USER_PREF_AUD(
         USER_ID,
         SFA_EMAILS,
         SFA_FILE_LOCATION,
         ROW_NUMBER,
         CHAT_AUDIO_INDICATOR,
         CHAT_AUDIO_INDICATE_INTERVAL,
         SEPARATOR_TYPE,
         TIME_FORMAT,
         DATE_FORMAT,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.USER_ID, :NEW.USER_ID),
         DECODE(v_opCode, 'D', :OLD.SFA_EMAILS, :NEW.SFA_EMAILS),
         DECODE(v_opCode, 'D', :OLD.SFA_FILE_LOCATION, :NEW.SFA_FILE_LOCATION),
         DECODE(v_opCode, 'D', :OLD.ROW_NUMBER, :NEW.ROW_NUMBER),
         DECODE(v_opCode, 'D', :OLD.CHAT_AUDIO_INDICATOR, :NEW.CHAT_AUDIO_INDICATOR),
         DECODE(v_opCode, 'D', :OLD.CHAT_AUDIO_INDICATE_INTERVAL, :NEW.CHAT_AUDIO_INDICATE_INTERVAL),
         DECODE(v_opCode, 'D', :OLD.SEPARATOR_TYPE, :NEW.SEPARATOR_TYPE),
         DECODE(v_opCode, 'D', :OLD.TIME_FORMAT, :NEW.TIME_FORMAT),
         DECODE(v_opCode, 'D', :OLD.DATE_FORMAT, :NEW.DATE_FORMAT),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_USER_PREF_TA;
/

