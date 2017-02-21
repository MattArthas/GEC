CREATE OR REPLACE TRIGGER GEC_RESTRICTION_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         RESTRICTION_CD,
         RESTRICTION_DESC,
         RESTRICTION_ABBRV,
         COMMENT_TXT
   ON GEC_RESTRICTION
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

   INSERT INTO GEC_RESTRICTION_AUD(
         RESTRICTION_CD,
         RESTRICTION_DESC,
         RESTRICTION_ABBRV,
         COMMENT_TXT,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.RESTRICTION_CD, :NEW.RESTRICTION_CD),
         DECODE(v_opCode, 'D', :OLD.RESTRICTION_DESC, :NEW.RESTRICTION_DESC),
         DECODE(v_opCode, 'D', :OLD.RESTRICTION_ABBRV, :NEW.RESTRICTION_ABBRV),
         DECODE(v_opCode, 'D', :OLD.COMMENT_TXT, :NEW.COMMENT_TXT),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_RESTRICTION_TA;
/

