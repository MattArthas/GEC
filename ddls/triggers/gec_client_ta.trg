CREATE OR REPLACE TRIGGER GEC_CLIENT_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         CLIENT_ID,
         CLIENT_SHORT_NAME,
         CLIENT_NAME,
         CLIENT_LEGAL_NAME,
         CLIENT_TYPE,
         CLIENT_STATUS,
         CREATED_AT
   ON GEC_CLIENT
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

   INSERT INTO GEC_CLIENT_AUD(
         CLIENT_ID,
         CLIENT_SHORT_NAME,
         CLIENT_NAME,
         CLIENT_LEGAL_NAME,
         CLIENT_TYPE,
         CLIENT_STATUS,
         CREATED_AT,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.CLIENT_ID, :NEW.CLIENT_ID),
         DECODE(v_opCode, 'D', :OLD.CLIENT_SHORT_NAME, :NEW.CLIENT_SHORT_NAME),
         DECODE(v_opCode, 'D', :OLD.CLIENT_NAME, :NEW.CLIENT_NAME),
         DECODE(v_opCode, 'D', :OLD.CLIENT_LEGAL_NAME, :NEW.CLIENT_LEGAL_NAME),
         DECODE(v_opCode, 'D', :OLD.CLIENT_TYPE, :NEW.CLIENT_TYPE),
         DECODE(v_opCode, 'D', :OLD.CLIENT_STATUS, :NEW.CLIENT_STATUS),
         DECODE(v_opCode, 'D', :OLD.CREATED_AT, :NEW.CREATED_AT),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_CLIENT_TA;
/

