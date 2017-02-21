CREATE OR REPLACE TRIGGER GEC_BROKER_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         BROKER_ID, 
         BROKER_CD, 
         BROKER_NAME, 
         BORROW_REQUEST_TYPE, 
         COLLATERAL_CURRENCY_CD, 
         COLLATERAL_TYPE, 
         US_COLLATERAL_PERCENTAGE, 
         NONUS_COLLATERAL_PERCENTAGE, 
         AGENCY_FLAG, 
         NON_CASH_AGENCY_FLAG, 
         BOOK_G1_BORROW_FLAG,
         US_PRICE_ROUND_FACTOR,
         NON_US_PRICE_ROUND_FACTOR,
         CA_PRICE_ROUND_FACTOR,
         NOU_US_DPS,
         CA_DPS,  
         LEGAL_ENTITY_ID, 
         BRANCH_CD, 
         CREATED_AT, 
         CREATED_BY, 
         UPDATED_AT, 
         UPDATED_BY,
         CORP_ID,
         AUTO_RETURN_FLAG,
         LEGAL_ENTITY_CD,
         G1_INSTANCE_CD
   ON GEC_BROKER
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

   INSERT INTO GEC_BROKER_AUD(
         BROKER_ID, 
         BROKER_CD, 
         BROKER_NAME, 
         BORROW_REQUEST_TYPE, 
         COLLATERAL_CURRENCY_CD, 
         COLLATERAL_TYPE, 
         US_COLLATERAL_PERCENTAGE, 
         NONUS_COLLATERAL_PERCENTAGE, 
         AGENCY_FLAG, 
         NON_CASH_AGENCY_FLAG, 
         BOOK_G1_BORROW_FLAG,
         US_PRICE_ROUND_FACTOR,
         NON_US_PRICE_ROUND_FACTOR,
         CA_PRICE_ROUND_FACTOR,
         NOU_US_DPS,
         CA_DPS, 
         LEGAL_ENTITY_ID, 
         BRANCH_CD, 
         CREATED_AT, 
         CREATED_BY, 
         UPDATED_AT, 
         UPDATED_BY,
         CORP_ID,
         AUTO_RETURN_FLAG,
         LEGAL_ENTITY_CD,
         G1_INSTANCE_CD,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.BROKER_ID, :NEW.BROKER_ID), 
         DECODE(v_opCode, 'D', :OLD.BROKER_CD, :NEW.BROKER_CD), 
         DECODE(v_opCode, 'D', :OLD.BROKER_NAME, :NEW.BROKER_NAME), 
         DECODE(v_opCode, 'D', :OLD.BORROW_REQUEST_TYPE, :NEW.BORROW_REQUEST_TYPE), 
         DECODE(v_opCode, 'D', :OLD.COLLATERAL_CURRENCY_CD, :NEW.COLLATERAL_CURRENCY_CD), 
         DECODE(v_opCode, 'D', :OLD.COLLATERAL_TYPE, :NEW.COLLATERAL_TYPE), 
         DECODE(v_opCode, 'D', :OLD.US_COLLATERAL_PERCENTAGE, :NEW.US_COLLATERAL_PERCENTAGE), 
         DECODE(v_opCode, 'D', :OLD.NONUS_COLLATERAL_PERCENTAGE, :NEW.NONUS_COLLATERAL_PERCENTAGE), 
         DECODE(v_opCode, 'D', :OLD.AGENCY_FLAG, :NEW.AGENCY_FLAG), 
         DECODE(v_opCode, 'D', :OLD.NON_CASH_AGENCY_FLAG, :NEW.NON_CASH_AGENCY_FLAG), 
         DECODE(v_opCode, 'D', :OLD.BOOK_G1_BORROW_FLAG, :NEW.BOOK_G1_BORROW_FLAG),
         DECODE(v_opCode, 'D', :OLD.US_PRICE_ROUND_FACTOR, :NEW.US_PRICE_ROUND_FACTOR),
         DECODE(v_opCode, 'D', :OLD.NON_US_PRICE_ROUND_FACTOR, :NEW.NON_US_PRICE_ROUND_FACTOR),
         DECODE(v_opCode, 'D', :OLD.CA_PRICE_ROUND_FACTOR, :NEW.CA_PRICE_ROUND_FACTOR),
         DECODE(v_opCode, 'D', :OLD.NOU_US_DPS, :NEW.NOU_US_DPS), 
         DECODE(v_opCode, 'D', :OLD.CA_DPS, :NEW.CA_DPS), 
         DECODE(v_opCode, 'D', :OLD.LEGAL_ENTITY_ID, :NEW.LEGAL_ENTITY_ID), 
         DECODE(v_opCode, 'D', :OLD.BRANCH_CD, :NEW.BRANCH_CD), 
         DECODE(v_opCode, 'D', :OLD.CREATED_AT, :NEW.CREATED_AT), 
         DECODE(v_opCode, 'D', :OLD.CREATED_BY, :NEW.CREATED_BY), 
         DECODE(v_opCode, 'D', :OLD.UPDATED_AT, :NEW.UPDATED_AT), 
         DECODE(v_opCode, 'D', :OLD.UPDATED_BY, :NEW.UPDATED_BY),
         DECODE(v_opCode, 'D', :OLD.CORP_ID, :NEW.CORP_ID), 
         DECODE(v_opCode, 'D', :OLD.AUTO_RETURN_FLAG, :NEW.AUTO_RETURN_FLAG),
         DECODE(v_opCode, 'D', :OLD.LEGAL_ENTITY_CD, :NEW.LEGAL_ENTITY_CD),
         DECODE(v_opCode, 'D', :OLD.G1_INSTANCE_CD, :NEW.G1_INSTANCE_CD),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_BROKER_TA;
/

