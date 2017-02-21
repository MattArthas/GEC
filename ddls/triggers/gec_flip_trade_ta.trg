CREATE OR REPLACE TRIGGER GEC_FLIP_TRADE_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         FLIP_TRADE_ID,
         ASSET_ID,
         TRANSACTION_CD,
         TRADE_COUNTRY_CD,
         TRADE_DATE,
         SETTLE_DATE,
         MIN_QTY,
         INC_QTY,
         SHARE_QTY,
         EXPORT_STATUS,
         RECALL_FLAG,
         FILLED_QTY,
         STATUS,
         RECALL_DUE_DATE,
         BORROW_RETURN_CPTY,
         SSGM_LOAN_QTY,
         SSGM_LOAN_RETURN_QTY,
         NSB_LOAN_RATE,
         RECALL_COMMENT_TXT,
         RETURN_BARGAIN_REF,
         RETURN_BRANCH_CD
   ON GEC_FLIP_TRADE
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

   INSERT INTO GEC_FLIP_TRADE_AUD(
         FLIP_TRADE_ID,
         ASSET_ID,
         TRANSACTION_CD,
         TRADE_COUNTRY_CD,
         TRADE_DATE,
         SETTLE_DATE,
         MIN_QTY,
         INC_QTY,
         SHARE_QTY,
         EXPORT_STATUS,
         RECALL_FLAG,
         FILLED_QTY,
         STATUS,
         RECALL_DUE_DATE,
         BORROW_RETURN_CPTY,
         SSGM_LOAN_QTY,
         SSGM_LOAN_RETURN_QTY,
         NSB_LOAN_RATE,
         RECALL_COMMENT_TXT,
         RETURN_BARGAIN_REF,
         RETURN_BRANCH_CD,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.FLIP_TRADE_ID, :NEW.FLIP_TRADE_ID),
         DECODE(v_opCode, 'D', :OLD.ASSET_ID, :NEW.ASSET_ID),
         DECODE(v_opCode, 'D', :OLD.TRANSACTION_CD, :NEW.TRANSACTION_CD),
         DECODE(v_opCode, 'D', :OLD.TRADE_COUNTRY_CD, :NEW.TRADE_COUNTRY_CD),
         DECODE(v_opCode, 'D', :OLD.TRADE_DATE, :NEW.TRADE_DATE),
         DECODE(v_opCode, 'D', :OLD.SETTLE_DATE, :NEW.SETTLE_DATE),
         DECODE(v_opCode, 'D', :OLD.MIN_QTY, :NEW.MIN_QTY),
         DECODE(v_opCode, 'D', :OLD.INC_QTY, :NEW.INC_QTY),
         DECODE(v_opCode, 'D', :OLD.SHARE_QTY, :NEW.SHARE_QTY),
         DECODE(v_opCode, 'D', :OLD.EXPORT_STATUS, :NEW.EXPORT_STATUS),
         DECODE(v_opCode, 'D', :OLD.RECALL_FLAG, :NEW.RECALL_FLAG),
         DECODE(v_opCode, 'D', :OLD.FILLED_QTY, :NEW.FILLED_QTY),
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
         DECODE(v_opCode, 'D', :OLD.RECALL_DUE_DATE, :NEW.RECALL_DUE_DATE),
         DECODE(v_opCode, 'D', :OLD.BORROW_RETURN_CPTY, :NEW.BORROW_RETURN_CPTY),
         DECODE(v_opCode, 'D', :OLD.SSGM_LOAN_QTY, :NEW.SSGM_LOAN_QTY),
         DECODE(v_opCode, 'D', :OLD.SSGM_LOAN_RETURN_QTY, :NEW.SSGM_LOAN_RETURN_QTY),
         DECODE(v_opCode, 'D', :OLD.NSB_LOAN_RATE, :NEW.NSB_LOAN_RATE),
         DECODE(v_opCode, 'D', :OLD.RECALL_COMMENT_TXT, :NEW.RECALL_COMMENT_TXT),
         DECODE(v_opCode, 'D', :OLD.RETURN_BARGAIN_REF, :NEW.RETURN_BARGAIN_REF),
         DECODE(v_opCode, 'D', :OLD.RETURN_BRANCH_CD, :NEW.RETURN_BRANCH_CD),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_FLIP_TRADE_TA;
/