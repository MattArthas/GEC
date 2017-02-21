CREATE OR REPLACE TRIGGER GEC_ASSET_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         ASSET_ID,
         CUSIP,
         ISIN,
         SEDOL,
         QUIK,
         TICKER,
         DESCRIPTION,
         SOURCE_FLAG,
         TRADE_COUNTRY_CD,
         ASSET_TYPE_ID,
         PRICE_CURRENCY_CD,
         PRICE_DATE,
         CLEAN_PRICE,
         DIRTY_PRICE,
         UPDATED_BY,
         UPDATED_AT,
         ID_BB_GLOBAL,
         LIQUIDITY_FLAG,
         NO_SHORT_SELL_REALTIME,
         NO_NAKED_SHORT_SELL
   ON GEC_ASSET
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

   IF v_opCode = 'I' OR v_opCode = 'D' OR :NEW.UPDATED_BY != 'System' OR 
      (v_opCode = 'U' AND (:NEW.PRICE_CURRENCY_CD = :OLD.PRICE_CURRENCY_CD
                            OR ( :NEW.PRICE_CURRENCY_CD IS NULL AND :OLD.PRICE_CURRENCY_CD IS NULL)
                          )
                      AND (:NEW.PRICE_DATE = :OLD.PRICE_DATE
                            OR ( :NEW.PRICE_DATE IS NULL AND :OLD.PRICE_DATE IS NULL)
                          )
                      AND (:NEW.CLEAN_PRICE = :OLD.CLEAN_PRICE
                            OR ( :NEW.CLEAN_PRICE IS NULL AND :OLD.CLEAN_PRICE IS NULL)
                          )
                      AND (:NEW.DIRTY_PRICE = :OLD.DIRTY_PRICE
                            OR ( :NEW.DIRTY_PRICE IS NULL AND :OLD.DIRTY_PRICE IS NULL)
                          )
                          
      )
   THEN
     INSERT INTO GEC_ASSET_AUD(
           ASSET_ID,
           CUSIP,
           ISIN,
           SEDOL,
           QUIK,
           TICKER,
           DESCRIPTION,
           SOURCE_FLAG,
           TRADE_COUNTRY_CD,
           ASSET_TYPE_ID,
           PRICE_CURRENCY_CD,
           PRICE_DATE,
           CLEAN_PRICE,
           DIRTY_PRICE,
           UPDATED_BY,
           UPDATED_AT,
           ID_BB_GLOBAL,
           LIQUIDITY_FLAG,
           NO_SHORT_SELL_REALTIME,
           NO_NAKED_SHORT_SELL,
           LAST_UPDATED_BY,
           LAST_UPDATED_AT,
           OP_CODE
        )
     VALUES (
           DECODE(v_opCode, 'D', :OLD.ASSET_ID, :NEW.ASSET_ID),
           DECODE(v_opCode, 'D', :OLD.CUSIP, :NEW.CUSIP),
           DECODE(v_opCode, 'D', :OLD.ISIN, :NEW.ISIN),
           DECODE(v_opCode, 'D', :OLD.SEDOL, :NEW.SEDOL),
           DECODE(v_opCode, 'D', :OLD.QUIK, :NEW.QUIK),
           DECODE(v_opCode, 'D', :OLD.TICKER, :NEW.TICKER),
           DECODE(v_opCode, 'D', :OLD.DESCRIPTION, :NEW.DESCRIPTION),
           DECODE(v_opCode, 'D', :OLD.SOURCE_FLAG, :NEW.SOURCE_FLAG),
           DECODE(v_opCode, 'D', :OLD.TRADE_COUNTRY_CD, :NEW.TRADE_COUNTRY_CD),
           DECODE(v_opCode, 'D', :OLD.ASSET_TYPE_ID, :NEW.ASSET_TYPE_ID),
           DECODE(v_opCode, 'D', :OLD.PRICE_CURRENCY_CD, :NEW.PRICE_CURRENCY_CD),
           DECODE(v_opCode, 'D', :OLD.PRICE_DATE, :NEW.PRICE_DATE),
           DECODE(v_opCode, 'D', :OLD.CLEAN_PRICE, :NEW.CLEAN_PRICE),
           DECODE(v_opCode, 'D', :OLD.DIRTY_PRICE, :NEW.DIRTY_PRICE),
           DECODE(v_opCode, 'D', :OLD.UPDATED_BY, :NEW.UPDATED_BY),
           DECODE(v_opCode, 'D', :OLD.UPDATED_AT, :NEW.UPDATED_AT),
           DECODE(v_opCode, 'D', :OLD.ID_BB_GLOBAL, :NEW.ID_BB_GLOBAL),
           DECODE(v_opCode, 'D', :OLD.LIQUIDITY_FLAG, :NEW.LIQUIDITY_FLAG),
           DECODE(v_opCode, 'D', :OLD.NO_SHORT_SELL_REALTIME, :NEW.NO_SHORT_SELL_REALTIME),
           DECODE(v_opCode, 'D', :OLD.NO_NAKED_SHORT_SELL, :NEW.NO_NAKED_SHORT_SELL),
           substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                      sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
           SYSDATE,
           v_opCode
     );   
   END IF;
   

END GEC_ASSET_TA;
/
