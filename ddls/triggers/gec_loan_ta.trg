CREATE OR REPLACE TRIGGER GEC_LOAN_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         LOAN_ID,
         ASSET_ID,
         FUND_CD,
         TRADE_DATE,
         SETTLE_DATE,
         COLLATERAL_TYPE,
         COLLATERAL_CURRENCY_CD,
         LOAN_QTY,
         RATE,
         PRICE,
         BORROW_REQUEST_TYPE,
         G1_EXTRACTED_AT,
         LINK_REFERENCE,
         CREATED_AT,
         CREATED_BY,
         UPDATED_AT,
         UPDATED_BY,
         TYPE,
         STATUS,
         PREPAY_DATE,
         PREPAY_RATE, 
         RECLAIM_RATE,
         OVERSEAS_TAX_PERCENTAGE,
         DOMESTIC_TAX_PERCENTAGE,
         MINIMUM_FEE,
         MINIMUM_FEE_CD,
         COUNTERPARTY_CD,
         COLLATERAL_PERCENTAGE,
         G1_EXTRACTED_BY,
         TERM_DATE,
         EXPECTED_RETURN_DATE,
         CROSS_TRADE_FLAG,
         COMMENT_TXT
   ON GEC_LOAN
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

   INSERT INTO GEC_LOAN_AUD(
         LOAN_ID,
         ASSET_ID,
         FUND_CD,
         TRADE_DATE,
         SETTLE_DATE,
         COLLATERAL_TYPE,
         COLLATERAL_CURRENCY_CD,
         LOAN_QTY,
         RATE,
         PRICE,
         BORROW_REQUEST_TYPE,
         G1_EXTRACTED_AT,
         LINK_REFERENCE,
         CREATED_AT,
         CREATED_BY,
         UPDATED_AT,
         UPDATED_BY,
         TYPE,
         STATUS,
         PREPAY_DATE,
         PREPAY_RATE, 
         RECLAIM_RATE,
         OVERSEAS_TAX_PERCENTAGE,
         DOMESTIC_TAX_PERCENTAGE,
         MINIMUM_FEE,
         MINIMUM_FEE_CD,
         COUNTERPARTY_CD,
         COLLATERAL_PERCENTAGE,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE,
         G1_EXTRACTED_BY,
         TERM_DATE,
         EXPECTED_RETURN_DATE,
         CROSS_TRADE_FLAG,
         COMMENT_TXT
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.LOAN_ID, :NEW.LOAN_ID),
         DECODE(v_opCode, 'D', :OLD.ASSET_ID, :NEW.ASSET_ID),
         DECODE(v_opCode, 'D', :OLD.FUND_CD, :NEW.FUND_CD),
         DECODE(v_opCode, 'D', :OLD.TRADE_DATE, :NEW.TRADE_DATE),
         DECODE(v_opCode, 'D', :OLD.SETTLE_DATE, :NEW.SETTLE_DATE),
         DECODE(v_opCode, 'D', :OLD.COLLATERAL_TYPE, :NEW.COLLATERAL_TYPE),
         DECODE(v_opCode, 'D', :OLD.COLLATERAL_CURRENCY_CD, :NEW.COLLATERAL_CURRENCY_CD),
         DECODE(v_opCode, 'D', :OLD.LOAN_QTY, :NEW.LOAN_QTY),
         DECODE(v_opCode, 'D', :OLD.RATE, :NEW.RATE),
         DECODE(v_opCode, 'D', :OLD.PRICE, :NEW.PRICE),
         DECODE(v_opCode, 'D', :OLD.BORROW_REQUEST_TYPE, :NEW.BORROW_REQUEST_TYPE),
         DECODE(v_opCode, 'D', :OLD.G1_EXTRACTED_AT, :NEW.G1_EXTRACTED_AT),
         DECODE(v_opCode, 'D', :OLD.LINK_REFERENCE, :NEW.LINK_REFERENCE),
         DECODE(v_opCode, 'D', :OLD.CREATED_AT, :NEW.CREATED_AT),
         DECODE(v_opCode, 'D', :OLD.CREATED_BY, :NEW.CREATED_BY),
         DECODE(v_opCode, 'D', :OLD.UPDATED_AT, :NEW.UPDATED_AT),
         DECODE(v_opCode, 'D', :OLD.UPDATED_BY, :NEW.UPDATED_BY),
         DECODE(v_opCode, 'D', :OLD.TYPE, :NEW.TYPE),
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
         DECODE(v_opCode, 'D', :OLD.PREPAY_DATE, :NEW.PREPAY_DATE),
         DECODE(v_opCode, 'D', :OLD.PREPAY_RATE, :NEW.PREPAY_RATE),
         DECODE(v_opCode, 'D', :OLD.RECLAIM_RATE, :NEW.RECLAIM_RATE),
         DECODE(v_opCode, 'D', :OLD.OVERSEAS_TAX_PERCENTAGE, :NEW.OVERSEAS_TAX_PERCENTAGE),
         DECODE(v_opCode, 'D', :OLD.DOMESTIC_TAX_PERCENTAGE, :NEW.DOMESTIC_TAX_PERCENTAGE),
         DECODE(v_opCode, 'D', :OLD.MINIMUM_FEE, :NEW.MINIMUM_FEE),
         DECODE(v_opCode, 'D', :OLD.MINIMUM_FEE_CD, :NEW.MINIMUM_FEE_CD),
         DECODE(v_opCode, 'D', :OLD.COUNTERPARTY_CD, :NEW.COUNTERPARTY_CD),
         DECODE(v_opCode, 'D', :OLD.COLLATERAL_PERCENTAGE, :NEW.COLLATERAL_PERCENTAGE),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode,
         DECODE(v_opCode, 'D', :OLD.G1_EXTRACTED_BY, :NEW.G1_EXTRACTED_BY),
         DECODE(v_opCode, 'D', :OLD.TERM_DATE, :NEW.TERM_DATE),
         DECODE(v_opCode, 'D', :OLD.EXPECTED_RETURN_DATE, :NEW.EXPECTED_RETURN_DATE),
         DECODE(v_opCode, 'D', :OLD.CROSS_TRADE_FLAG, :NEW.CROSS_TRADE_FLAG),
         DECODE(v_opCode, 'D', :OLD.COMMENT_TXT, :NEW.COMMENT_TXT)
   );

END GEC_LOAN_TA;
/

