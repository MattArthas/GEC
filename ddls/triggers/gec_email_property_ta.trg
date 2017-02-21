CREATE OR REPLACE TRIGGER GEC_EMAIL_PROPERTY_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         EMAIL_CONFIG_ID,
         FROM_ADDRESS,
         TO_ADDRESS,
         CC_ADDRESS,
         BCC_ADDRESS,
         SUBJECT,
         CONTENT
   ON GEC_EMAIL_PROPERTY
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

   INSERT INTO GEC_EMAIL_PROPERTY_AUD(
         EMAIL_CONFIG_ID,
         FROM_ADDRESS,
         TO_ADDRESS,
         CC_ADDRESS,
         BCC_ADDRESS,
         SUBJECT,
         CONTENT,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.EMAIL_CONFIG_ID, :NEW.EMAIL_CONFIG_ID),
         DECODE(v_opCode, 'D', :OLD.FROM_ADDRESS, :NEW.FROM_ADDRESS),
         DECODE(v_opCode, 'D', :OLD.TO_ADDRESS, :NEW.TO_ADDRESS),
         DECODE(v_opCode, 'D', :OLD.CC_ADDRESS, :NEW.CC_ADDRESS),
         DECODE(v_opCode, 'D', :OLD.BCC_ADDRESS, :NEW.BCC_ADDRESS),
         DECODE(v_opCode, 'D', :OLD.SUBJECT, :NEW.SUBJECT),
         DECODE(v_opCode, 'D', :OLD.CONTENT, :NEW.CONTENT),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_EMAIL_PROPERTY_TA;
/

