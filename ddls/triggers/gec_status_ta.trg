CREATE OR REPLACE TRIGGER GEC_STATUS_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         STATUS_CD,
         STATUS_DESC,
         SHORT_DESC,
         COMMENT_TXT
   ON GEC_STATUS
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

   INSERT INTO GEC_STATUS_AUD(
         STATUS_CD,
         STATUS_DESC,
         SHORT_DESC,
         COMMENT_TXT,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.STATUS_CD, :NEW.STATUS_CD),
         DECODE(v_opCode, 'D', :OLD.STATUS_DESC, :NEW.STATUS_DESC),
         DECODE(v_opCode, 'D', :OLD.SHORT_DESC, :NEW.SHORT_DESC),
         DECODE(v_opCode, 'D', :OLD.COMMENT_TXT, :NEW.COMMENT_TXT),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_STATUS_TA;
/

