CREATE OR REPLACE TRIGGER GEC_G1_RETURN_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         G1_RETURN_ID,
         ASSET_ID,
         IM_ORDER_ID,
         FLIP_TRADE_ID,
         BULK_G1_RETURN_ID,
         TRANSACTION_TYPE,
         TRANSACTION_CD,
         TRADE_DATE,
         SETTLE_DATE,
         COUNTERPARTY_CD,
         TRADE_COUNTRY_CD,
         QTY,
         REC_TYPE,
         FUND_CD,
         BTC_EXTRACTED_AT,
         BTC_EXTRACTED_BY,
         STATUS,
         SOURCE_CD,
         BARGAIN_REF,
         UPDATED_AT,
         UPDATED_BY,
         NEW_BORROW_CPTY_CD,
		 NEW_BORROW_CPTY_NAME,
		 BRANCH_CD,
		 NEW_BORROW_COLL_TYPE,
		 NEW_BORROW_COLL_CODE,
		 DIVIDEND_TRADE_FLAG,
		 POS_TYPE,
		 COUNTERPARTY_NAME
   ON GEC_G1_RETURN
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

   INSERT INTO GEC_G1_RETURN_AUD(
         G1_RETURN_ID,
         ASSET_ID,
         IM_ORDER_ID,
         FLIP_TRADE_ID,
         BULK_G1_RETURN_ID,
         TRANSACTION_TYPE,
         TRANSACTION_CD,
         TRADE_DATE,
         SETTLE_DATE,
         COUNTERPARTY_CD,
         TRADE_COUNTRY_CD,
         QTY,
         REC_TYPE,
         FUND_CD,
         BTC_EXTRACTED_AT,
         BTC_EXTRACTED_BY,
         STATUS,
         SOURCE_CD,
         BARGAIN_REF,
         UPDATED_AT,
         UPDATED_BY,
         NEW_BORROW_CPTY_CD,
		 NEW_BORROW_CPTY_NAME,
		 BRANCH_CD,
		 NEW_BORROW_COLL_TYPE,
		 NEW_BORROW_COLL_CODE,
		 DIVIDEND_TRADE_FLAG,
		 POS_TYPE,
		 COUNTERPARTY_NAME,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.G1_RETURN_ID, :NEW.G1_RETURN_ID),
         DECODE(v_opCode, 'D', :OLD.ASSET_ID, :NEW.ASSET_ID),
         DECODE(v_opCode, 'D', :OLD.IM_ORDER_ID, :NEW.IM_ORDER_ID),
         DECODE(v_opCode, 'D', :OLD.FLIP_TRADE_ID, :NEW.FLIP_TRADE_ID),
         DECODE(v_opCode, 'D', :OLD.BULK_G1_RETURN_ID, :NEW.BULK_G1_RETURN_ID),
         DECODE(v_opCode, 'D', :OLD.TRANSACTION_TYPE, :NEW.TRANSACTION_TYPE),
         DECODE(v_opCode, 'D', :OLD.TRANSACTION_CD, :NEW.TRANSACTION_CD),
         DECODE(v_opCode, 'D', :OLD.TRADE_DATE, :NEW.TRADE_DATE),
         DECODE(v_opCode, 'D', :OLD.SETTLE_DATE, :NEW.SETTLE_DATE),
         DECODE(v_opCode, 'D', :OLD.COUNTERPARTY_CD, :NEW.COUNTERPARTY_CD),
         DECODE(v_opCode, 'D', :OLD.TRADE_COUNTRY_CD, :NEW.TRADE_COUNTRY_CD),
         DECODE(v_opCode, 'D', :OLD.QTY, :NEW.QTY),
         DECODE(v_opCode, 'D', :OLD.REC_TYPE, :NEW.REC_TYPE),
         DECODE(v_opCode, 'D', :OLD.FUND_CD, :NEW.FUND_CD),
         DECODE(v_opCode, 'D', :OLD.BTC_EXTRACTED_AT, :NEW.BTC_EXTRACTED_AT),
         DECODE(v_opCode, 'D', :OLD.BTC_EXTRACTED_BY, :NEW.BTC_EXTRACTED_BY),
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
         DECODE(v_opCode, 'D', :OLD.SOURCE_CD, :NEW.SOURCE_CD),
         DECODE(v_opCode, 'D', :OLD.BARGAIN_REF, :NEW.BARGAIN_REF),
         DECODE(v_opCode, 'D', :OLD.UPDATED_AT, :NEW.UPDATED_AT),
		 DECODE(v_opCode, 'D', :OLD.UPDATED_BY, :NEW.UPDATED_BY),
         DECODE(v_opCode, 'D', :OLD.NEW_BORROW_CPTY_CD, :NEW.NEW_BORROW_CPTY_CD),
         DECODE(v_opCode, 'D', :OLD.NEW_BORROW_CPTY_NAME, :NEW.NEW_BORROW_CPTY_NAME),
         DECODE(v_opCode, 'D', :OLD.BRANCH_CD, :NEW.BRANCH_CD),
         DECODE(v_opCode, 'D', :OLD.NEW_BORROW_COLL_TYPE, :NEW.NEW_BORROW_COLL_TYPE),
         DECODE(v_opCode, 'D', :OLD.NEW_BORROW_COLL_CODE, :NEW.NEW_BORROW_COLL_CODE),
         DECODE(v_opCode, 'D', :OLD.DIVIDEND_TRADE_FLAG, :NEW.DIVIDEND_TRADE_FLAG),
         DECODE(v_opCode, 'D', :OLD.POS_TYPE, :NEW.POS_TYPE),
         DECODE(v_opCode, 'D', :OLD.COUNTERPARTY_NAME, :NEW.COUNTERPARTY_NAME),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_G1_RETURN_TA;
/