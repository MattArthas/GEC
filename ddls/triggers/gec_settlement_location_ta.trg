CREATE OR REPLACE TRIGGER GEC_SETTLEMENT_LOCATION_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         SETTLEMENT_LOCATION_ID,
         SETTLEMENT_LOCATION_CD,
         SETTLEMENT_LOCATION_DESC
   ON GEC_SETTLEMENT_LOCATION
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

   INSERT INTO GEC_SETTLEMENT_LOCATION_AUD(
         SETTLEMENT_LOCATION_ID,
         SETTLEMENT_LOCATION_CD,
         SETTLEMENT_LOCATION_DESC,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.SETTLEMENT_LOCATION_ID, :NEW.SETTLEMENT_LOCATION_ID),
         DECODE(v_opCode, 'D', :OLD.SETTLEMENT_LOCATION_CD, :NEW.SETTLEMENT_LOCATION_CD),
         DECODE(v_opCode, 'D', :OLD.SETTLEMENT_LOCATION_DESC, :NEW.SETTLEMENT_LOCATION_DESC),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_SETTLEMENT_LOCATION_TA;
/