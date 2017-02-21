CREATE OR REPLACE TRIGGER GEC_ERROR_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         ERROR_ID,
         ERROR_CODE,
         SOP_URL
   ON GEC_ERROR
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

   INSERT INTO GEC_ERROR_AUD(
         ERROR_ID,
         ERROR_CODE,
         SOP_URL,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.ERROR_ID, :NEW.ERROR_ID),
         DECODE(v_opCode, 'D', :OLD.ERROR_CODE, :NEW.ERROR_CODE),
         DECODE(v_opCode, 'D', :OLD.SOP_URL, :NEW.SOP_URL),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_ERROR_TA;
/

