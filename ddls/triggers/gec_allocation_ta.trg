CREATE OR REPLACE TRIGGER GEC_ALLOCATION_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         ALLOCATION_ID,
         BORROW_ID,
         LOAN_ID,
         IM_ORDER_ID,
         ALLOCATION_QTY,
         SETTLE_DATE,
         RATE,
         STATUS,
         PREPAY_DATE,
         PREPAY_RATE, 
         RECLAIM_RATE,
         OVERSEAS_TAX_PERCENTAGE,
         DOMESTIC_TAX_PERCENTAGE,
         MINIMUM_FEE,
         MINIMUM_FEE_CD,
         COLLATERAL_TYPE,
         COLLATERAL_CURRENCY_CD,
         TRADE_DATE,
         TERM_DATE,
         EXPECTED_RETURN_DATE,
         COMMENT_TXT
   ON GEC_ALLOCATION
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

   INSERT INTO GEC_ALLOCATION_AUD(
         ALLOCATION_ID,
         BORROW_ID,
         LOAN_ID,
         IM_ORDER_ID,
         ALLOCATION_QTY,
         SETTLE_DATE,
         RATE,
         STATUS,
         PREPAY_DATE,
         PREPAY_RATE, 
         RECLAIM_RATE,
         OVERSEAS_TAX_PERCENTAGE,
         DOMESTIC_TAX_PERCENTAGE,
         MINIMUM_FEE,
         MINIMUM_FEE_CD,
         COLLATERAL_TYPE,
         COLLATERAL_CURRENCY_CD,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         TRADE_DATE,
         TERM_DATE,
         EXPECTED_RETURN_DATE,
         COMMENT_TXT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.ALLOCATION_ID, :NEW.ALLOCATION_ID),
         DECODE(v_opCode, 'D', :OLD.BORROW_ID, :NEW.BORROW_ID),
         DECODE(v_opCode, 'D', :OLD.LOAN_ID, :NEW.LOAN_ID),
         DECODE(v_opCode, 'D', :OLD.IM_ORDER_ID, :NEW.IM_ORDER_ID),
         DECODE(v_opCode, 'D', :OLD.ALLOCATION_QTY, :NEW.ALLOCATION_QTY),
         DECODE(v_opCode, 'D', :OLD.SETTLE_DATE, :NEW.SETTLE_DATE),
         DECODE(v_opCode, 'D', :OLD.RATE, :NEW.RATE),
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
         DECODE(v_opCode, 'D', :OLD.PREPAY_DATE, :NEW.PREPAY_DATE),
         DECODE(v_opCode, 'D', :OLD.PREPAY_RATE, :NEW.PREPAY_RATE),
         DECODE(v_opCode, 'D', :OLD.RECLAIM_RATE, :NEW.RECLAIM_RATE),
         DECODE(v_opCode, 'D', :OLD.OVERSEAS_TAX_PERCENTAGE, :NEW.OVERSEAS_TAX_PERCENTAGE),
         DECODE(v_opCode, 'D', :OLD.DOMESTIC_TAX_PERCENTAGE, :NEW.DOMESTIC_TAX_PERCENTAGE),
         DECODE(v_opCode, 'D', :OLD.MINIMUM_FEE, :NEW.MINIMUM_FEE),
         DECODE(v_opCode, 'D', :OLD.MINIMUM_FEE_CD, :NEW.MINIMUM_FEE_CD),
         DECODE(v_opCode, 'D', :OLD.COLLATERAL_TYPE, :NEW.COLLATERAL_TYPE),
         DECODE(v_opCode, 'D', :OLD.COLLATERAL_CURRENCY_CD, :NEW.COLLATERAL_CURRENCY_CD),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         DECODE(v_opCode, 'D', :OLD.TRADE_DATE, :NEW.TRADE_DATE),
         DECODE(v_opCode, 'D', :OLD.TERM_DATE, :NEW.TERM_DATE),
         DECODE(v_opCode, 'D', :OLD.EXPECTED_RETURN_DATE, :NEW.EXPECTED_RETURN_DATE),
         DECODE(v_opCode, 'D', :OLD.COMMENT_TXT, :NEW.COMMENT_TXT),
         v_opCode
   );

END GEC_ALLOCATION_TA;
/