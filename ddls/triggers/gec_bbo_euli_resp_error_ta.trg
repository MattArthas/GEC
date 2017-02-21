CREATE OR REPLACE TRIGGER GEC_BBO_EULI_RESP_ERROR_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         BBO_EULI_RESP_ERROR_ID, 
         BBO_ACTIVITY_ID, 
         DATA_RETURNED, 
         GEC_SEC_ID, 
         ID_BB_GLOBAL, 
         SSR_LIQUIDITY_INDICATOR, 
         NO_SHORT_SELL, 
         NO_NAKED_SHORT_SELL, 
         ERROR_INFO, 
         CREATED_AT
   ON GEC_BBO_EULI_RESP_ERROR
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

   INSERT INTO GEC_BBO_EULI_RESP_ERROR_AUD(
         BBO_EULI_RESP_ERROR_ID, 
         BBO_ACTIVITY_ID, 
         DATA_RETURNED, 
         GEC_SEC_ID, 
         ID_BB_GLOBAL, 
         SSR_LIQUIDITY_INDICATOR, 
         NO_SHORT_SELL, 
         NO_NAKED_SHORT_SELL, 
         ERROR_INFO, 
         CREATED_AT,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.BBO_EULI_RESP_ERROR_ID, :NEW.BBO_EULI_RESP_ERROR_ID), 
         DECODE(v_opCode, 'D', :OLD.BBO_ACTIVITY_ID, :NEW.BBO_ACTIVITY_ID), 
         DECODE(v_opCode, 'D', :OLD.DATA_RETURNED, :NEW.DATA_RETURNED), 
         DECODE(v_opCode, 'D', :OLD.GEC_SEC_ID, :NEW.GEC_SEC_ID), 
         DECODE(v_opCode, 'D', :OLD.ID_BB_GLOBAL, :NEW.ID_BB_GLOBAL), 
         DECODE(v_opCode, 'D', :OLD.SSR_LIQUIDITY_INDICATOR, :NEW.SSR_LIQUIDITY_INDICATOR), 
         DECODE(v_opCode, 'D', :OLD.NO_SHORT_SELL, :NEW.NO_SHORT_SELL), 
         DECODE(v_opCode, 'D', :OLD.NO_NAKED_SHORT_SELL, :NEW.NO_NAKED_SHORT_SELL), 
         DECODE(v_opCode, 'D', :OLD.ERROR_INFO, :NEW.ERROR_INFO), 
         DECODE(v_opCode, 'D', :OLD.CREATED_AT, :NEW.CREATED_AT),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_BBO_EULI_RESP_ERROR_TA;
/
