CREATE OR REPLACE TRIGGER GEC_TRADE_COUNTRY_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         TRADE_COUNTRY_ID,
         TRADE_COUNTRY_CD,
         TRADE_COUNTRY_NAME,
         CURRENCY_CD,
         PREPAY_DATE_VALUE,
         CUTOFF_TIME,
         TRADING_DESK_CD,
         LOCALE,
         PREBORROW_ELIGIBLE_FLAG,
         STATUS,
         G1_AUTO_BOOKING,
  	     GROUP_ALL_LOAN,
  	     VISIBLE_FLAG,
  	     UPDATED_AT,
		 UPDATED_BY
   ON GEC_TRADE_COUNTRY
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

   INSERT INTO GEC_TRADE_COUNTRY_AUD(
         TRADE_COUNTRY_ID,
         TRADE_COUNTRY_CD,
         TRADE_COUNTRY_NAME,
         CURRENCY_CD,
         PREPAY_DATE_VALUE,
         CUTOFF_TIME,
         TRADING_DESK_CD,
         LOCALE,
         PREBORROW_ELIGIBLE_FLAG,
         STATUS,
         G1_AUTO_BOOKING,
  	     GROUP_ALL_LOAN,
  	     VISIBLE_FLAG,
  	     UPDATED_AT,
		 UPDATED_BY,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.TRADE_COUNTRY_ID, :NEW.TRADE_COUNTRY_ID),
         DECODE(v_opCode, 'D', :OLD.TRADE_COUNTRY_CD, :NEW.TRADE_COUNTRY_CD),
         DECODE(v_opCode, 'D', :OLD.TRADE_COUNTRY_NAME, :NEW.TRADE_COUNTRY_NAME),
         DECODE(v_opCode, 'D', :OLD.CURRENCY_CD, :NEW.CURRENCY_CD),
         DECODE(v_opCode, 'D', :OLD.PREPAY_DATE_VALUE, :NEW.PREPAY_DATE_VALUE),
         DECODE(v_opCode, 'D', :OLD.CUTOFF_TIME, :NEW.CUTOFF_TIME),
         DECODE(v_opCode, 'D', :OLD.TRADING_DESK_CD, :NEW.TRADING_DESK_CD),
         DECODE(v_opCode, 'D', :OLD.LOCALE, :NEW.LOCALE),
         DECODE(v_opCode, 'D', :OLD.PREBORROW_ELIGIBLE_FLAG, :NEW.PREBORROW_ELIGIBLE_FLAG),
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
         DECODE(v_opCode, 'D', :OLD.G1_AUTO_BOOKING, :NEW.G1_AUTO_BOOKING),
         DECODE(v_opCode, 'D', :OLD.GROUP_ALL_LOAN, :NEW.GROUP_ALL_LOAN),
         DECODE(v_opCode, 'D', :OLD.VISIBLE_FLAG, :NEW.VISIBLE_FLAG),
         DECODE(v_opCode, 'D', :OLD.UPDATED_AT, :NEW.UPDATED_AT),
         DECODE(v_opCode, 'D', :OLD.UPDATED_BY, :NEW.UPDATED_BY),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_TRADE_COUNTRY_TA;
/

