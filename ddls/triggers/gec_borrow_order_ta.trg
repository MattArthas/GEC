CREATE OR REPLACE TRIGGER GEC_BORROW_ORDER_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         BORROW_ORDER_ID,
         BORROW_REQUEST_ID,
         LOG_NUMBER,
         ASSET_ID,
         BROKER_CD,
         SETTLE_DATE,
         COLLATERAL_TYPE,
         COLLATERAL_CURRENCY_CD,
         SHARE_QTY,
         STATUS,
         STATUS_MSG
   ON GEC_BORROW_ORDER
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

   INSERT INTO GEC_BORROW_ORDER_AUD(
         BORROW_ORDER_ID,
         BORROW_REQUEST_ID,
         LOG_NUMBER,
         ASSET_ID,
         BROKER_CD,
         SETTLE_DATE,
         COLLATERAL_TYPE,
         COLLATERAL_CURRENCY_CD,
         SHARE_QTY,
         STATUS,
         STATUS_MSG,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.BORROW_ORDER_ID, :NEW.BORROW_ORDER_ID),
         DECODE(v_opCode, 'D', :OLD.BORROW_REQUEST_ID, :NEW.BORROW_REQUEST_ID),
         DECODE(v_opCode, 'D', :OLD.LOG_NUMBER, :NEW.LOG_NUMBER),
         DECODE(v_opCode, 'D', :OLD.ASSET_ID, :NEW.ASSET_ID),
         DECODE(v_opCode, 'D', :OLD.BROKER_CD, :NEW.BROKER_CD),
         DECODE(v_opCode, 'D', :OLD.SETTLE_DATE, :NEW.SETTLE_DATE),
         DECODE(v_opCode, 'D', :OLD.COLLATERAL_TYPE, :NEW.COLLATERAL_TYPE),
         DECODE(v_opCode, 'D', :OLD.COLLATERAL_CURRENCY_CD, :NEW.COLLATERAL_CURRENCY_CD),
         DECODE(v_opCode, 'D', :OLD.SHARE_QTY, :NEW.SHARE_QTY),
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
         DECODE(v_opCode, 'D', :OLD.STATUS_MSG, :NEW.STATUS_MSG),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_BORROW_ORDER_TA;
/

