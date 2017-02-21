CREATE OR REPLACE TRIGGER GEC_G1_BOOKING_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         FUND_CD,
         TRANSACTION_CD,
         POS_TYPE,
         COUNTERPARTY_CD,
         RATE,
         RATE_TYPE,
         INDEX_CD,
         COLL_TYPE,
         COLLATERAL_CURRENCY_CD, 
         RECLAIM_RATE,
         OVERSEAS_TAX_PERCENTAGE,
         DOMESTIC_TAX_PERCENTAGE
   ON GEC_G1_BOOKING
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

   INSERT INTO GEC_G1_BOOKING_AUD(
         FUND_CD,
         TRANSACTION_CD,
         POS_TYPE,
         COUNTERPARTY_CD,
         RATE,
         RATE_TYPE,
         INDEX_CD,
         COLL_TYPE,
         COLLATERAL_CURRENCY_CD, 
         RECLAIM_RATE,
         OVERSEAS_TAX_PERCENTAGE,
         DOMESTIC_TAX_PERCENTAGE,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.FUND_CD, :NEW.FUND_CD),
         DECODE(v_opCode, 'D', :OLD.TRANSACTION_CD, :NEW.TRANSACTION_CD),
         DECODE(v_opCode, 'D', :OLD.POS_TYPE, :NEW.POS_TYPE),
         DECODE(v_opCode, 'D', :OLD.COUNTERPARTY_CD, :NEW.COUNTERPARTY_CD),
         DECODE(v_opCode, 'D', :OLD.RATE, :NEW.RATE),
         DECODE(v_opCode, 'D', :OLD.RATE_TYPE, :NEW.RATE_TYPE),
         DECODE(v_opCode, 'D', :OLD.INDEX_CD, :NEW.INDEX_CD),
         DECODE(v_opCode, 'D', :OLD.COLL_TYPE, :NEW.COLL_TYPE),
         DECODE(v_opCode, 'D', :OLD.COLLATERAL_CURRENCY_CD, :NEW.COLLATERAL_CURRENCY_CD),
         DECODE(v_opCode, 'D', :OLD.RECLAIM_RATE, :NEW.RECLAIM_RATE),
         DECODE(v_opCode, 'D', :OLD.OVERSEAS_TAX_PERCENTAGE, :NEW.OVERSEAS_TAX_PERCENTAGE),
         DECODE(v_opCode, 'D', :OLD.DOMESTIC_TAX_PERCENTAGE, :NEW.DOMESTIC_TAX_PERCENTAGE),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_G1_BOOKING_TA;
/

