CREATE OR REPLACE TRIGGER GEC_BROKER_RETURN_RULE_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         BROKER_RETURN_RULE_ID, 
         BROKER_CD, 
         TRADE_COUNTRY_CD, 
         AUTO_RETURN_FLAG, 
         DIVIDEND_RATE_TAG, 
         COLLATERAL_TYPE_TAG, 
         COLLATERAL_CURRENCY_TAG, 
         FEE_TAG, 
         RATE_TAG
   ON GEC_BROKER_RETURN_RULE
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

   INSERT INTO GEC_BROKER_RETURN_RULE_AUD(
         BROKER_RETURN_RULE_ID, 
         BROKER_CD, 
         TRADE_COUNTRY_CD, 
         AUTO_RETURN_FLAG, 
         DIVIDEND_RATE_TAG, 
         COLLATERAL_TYPE_TAG, 
         COLLATERAL_CURRENCY_TAG, 
         FEE_TAG, 
         RATE_TAG,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.BROKER_RETURN_RULE_ID, :NEW.BROKER_RETURN_RULE_ID), 
         DECODE(v_opCode, 'D', :OLD.BROKER_CD, :NEW.BROKER_CD), 
         DECODE(v_opCode, 'D', :OLD.TRADE_COUNTRY_CD, :NEW.TRADE_COUNTRY_CD), 
         DECODE(v_opCode, 'D', :OLD.AUTO_RETURN_FLAG, :NEW.AUTO_RETURN_FLAG), 
         DECODE(v_opCode, 'D', :OLD.DIVIDEND_RATE_TAG, :NEW.DIVIDEND_RATE_TAG), 
         DECODE(v_opCode, 'D', :OLD.COLLATERAL_TYPE_TAG, :NEW.COLLATERAL_TYPE_TAG), 
         DECODE(v_opCode, 'D', :OLD.COLLATERAL_CURRENCY_TAG, :NEW.COLLATERAL_CURRENCY_TAG), 
         DECODE(v_opCode, 'D', :OLD.FEE_TAG, :NEW.FEE_TAG), 
         DECODE(v_opCode, 'D', :OLD.RATE_TAG, :NEW.RATE_TAG),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_BROKER_RETURN_RULE_TA;
/
