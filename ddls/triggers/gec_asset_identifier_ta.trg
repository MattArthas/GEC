CREATE OR REPLACE TRIGGER GEC_ASSET_IDENTIFIER_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         ASSET_CODE,
         ASSET_CODE_TYPE,
         ASSET_ID
   ON GEC_ASSET_IDENTIFIER
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

   INSERT INTO GEC_ASSET_IDENTIFIER_AUD(
         ASSET_CODE,
         ASSET_CODE_TYPE,
         ASSET_ID,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.ASSET_CODE, :NEW.ASSET_CODE),
         DECODE(v_opCode, 'D', :OLD.ASSET_CODE_TYPE, :NEW.ASSET_CODE_TYPE),
         DECODE(v_opCode, 'D', :OLD.ASSET_ID, :NEW.ASSET_ID),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_ASSET_IDENTIFIER_TA;
/

