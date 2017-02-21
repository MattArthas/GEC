CREATE OR REPLACE TRIGGER GEC_ASSET_TYPE_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         ASSET_TYPE_ID,
         ASSET_TYPE_DESC,
         UPDATED_BY,
         UPDATED_AT
   ON GEC_ASSET_TYPE
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

   INSERT INTO GEC_ASSET_TYPE_AUD(
         ASSET_TYPE_ID,
         ASSET_TYPE_DESC,
         UPDATED_BY,
         UPDATED_AT,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.ASSET_TYPE_ID, :NEW.ASSET_TYPE_ID),
         DECODE(v_opCode, 'D', :OLD.ASSET_TYPE_DESC, :NEW.ASSET_TYPE_DESC),
         DECODE(v_opCode, 'D', :OLD.UPDATED_BY, :NEW.UPDATED_BY),
         DECODE(v_opCode, 'D', :OLD.UPDATED_AT, :NEW.UPDATED_AT),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_ASSET_TYPE_TA;
/

