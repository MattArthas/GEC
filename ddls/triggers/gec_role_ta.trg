CREATE OR REPLACE TRIGGER GEC_ROLE_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         ROLE_CD,
         ROLE_NAME,
         ROLE_DESC,
         BUSINESS_ROLE_NAME,
         BUSINESS_ROLE_DESC
   ON GEC_ROLE
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

   INSERT INTO GEC_ROLE_AUD(
         ROLE_CD,
         ROLE_NAME,
         ROLE_DESC,
         BUSINESS_ROLE_NAME,
         BUSINESS_ROLE_DESC,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.ROLE_CD, :NEW.ROLE_CD),
         DECODE(v_opCode, 'D', :OLD.ROLE_NAME, :NEW.ROLE_NAME),
         DECODE(v_opCode, 'D', :OLD.ROLE_DESC, :NEW.ROLE_DESC),
         DECODE(v_opCode, 'D', :OLD.BUSINESS_ROLE_NAME, :NEW.BUSINESS_ROLE_NAME),
         DECODE(v_opCode, 'D', :OLD.BUSINESS_ROLE_DESC, :NEW.BUSINESS_ROLE_DESC),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_ROLE_TA;
/

