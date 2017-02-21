CREATE OR REPLACE TRIGGER GEC_SOURCE_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         SOURCE_CD,
         SOURCE_DESC,
         COMMENT_TXT
   ON GEC_SOURCE
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

   INSERT INTO GEC_SOURCE_AUD(
         SOURCE_CD,
         SOURCE_DESC,
         COMMENT_TXT,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.SOURCE_CD, :NEW.SOURCE_CD),
         DECODE(v_opCode, 'D', :OLD.SOURCE_DESC, :NEW.SOURCE_DESC),
         DECODE(v_opCode, 'D', :OLD.COMMENT_TXT, :NEW.COMMENT_TXT),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_SOURCE_TA;
/

