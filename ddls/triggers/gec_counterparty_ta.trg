CREATE OR REPLACE TRIGGER GEC_COUNTERPARTY_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         COUNTERPARTY_ID, 
         COUNTERPARTY_CD, 
         TRANSACTION_CD, 
         PREPAY_RATE, 
         BENCHMARK_INDEX_CD, 
         GB_COLLATERAL_PERCENTAGE
   ON GEC_COUNTERPARTY
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

   INSERT INTO GEC_COUNTERPARTY_AUD(
         COUNTERPARTY_ID, 
         COUNTERPARTY_CD, 
         TRANSACTION_CD, 
         PREPAY_RATE, 
         BENCHMARK_INDEX_CD, 
         GB_COLLATERAL_PERCENTAGE,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.COUNTERPARTY_ID, :NEW.COUNTERPARTY_ID), 
         DECODE(v_opCode, 'D', :OLD.COUNTERPARTY_CD, :NEW.COUNTERPARTY_CD), 
         DECODE(v_opCode, 'D', :OLD.TRANSACTION_CD, :NEW.TRANSACTION_CD), 
         DECODE(v_opCode, 'D', :OLD.PREPAY_RATE, :NEW.PREPAY_RATE), 
         DECODE(v_opCode, 'D', :OLD.BENCHMARK_INDEX_CD, :NEW.BENCHMARK_INDEX_CD), 
         DECODE(v_opCode, 'D', :OLD.GB_COLLATERAL_PERCENTAGE, :NEW.GB_COLLATERAL_PERCENTAGE),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_COUNTERPARTY_TA;
/