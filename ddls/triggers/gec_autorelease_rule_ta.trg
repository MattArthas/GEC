CREATE OR REPLACE TRIGGER GEC_AUTORELEASE_RULE_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         AUTORELEASE_RULE_ID, 
         PRIORITY, 
         BRANCH_CD, 
         BROKER_CD, 
         FUND_CD, 
         POSITION_FLAG, 
         COLLATERAL_CURRENCY_CD, 
         COLLATERAL_TYPE, 
         TRADE_COUNTRY_CD, 
         TRADE_SETTLE_PERIOD, 
         SCHEDULE_ID, 
         CHAIN_ID, 
         START_TIME, 
         END_TIME, 
         TIME_INTERVAL, 
         STATUS,
         TRANSACTION_CD,
         COMMENT_TXT, 
         CREATED_AT, 
         CREATED_BY, 
         UPDATED_AT, 
         UPDATED_BY,
         FULL_FILL
   ON GEC_AUTORELEASE_RULE
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

   INSERT INTO GEC_AUTORELEASE_RULE_AUD(
         AUTORELEASE_RULE_ID, 
         PRIORITY, 
         BRANCH_CD, 
         BROKER_CD, 
         FUND_CD, 
         POSITION_FLAG, 
         COLLATERAL_CURRENCY_CD, 
         COLLATERAL_TYPE, 
         TRADE_COUNTRY_CD, 
         TRADE_SETTLE_PERIOD, 
         SCHEDULE_ID, 
         CHAIN_ID, 
         START_TIME, 
         END_TIME, 
         TIME_INTERVAL, 
         STATUS, 
         TRANSACTION_CD,
         COMMENT_TXT, 
         CREATED_AT, 
         CREATED_BY, 
         UPDATED_AT, 
         UPDATED_BY, 
         FULL_FILL,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.AUTORELEASE_RULE_ID, :NEW.AUTORELEASE_RULE_ID), 
         DECODE(v_opCode, 'D', :OLD.PRIORITY, :NEW.PRIORITY), 
         DECODE(v_opCode, 'D', :OLD.BRANCH_CD, :NEW.BRANCH_CD), 
         DECODE(v_opCode, 'D', :OLD.BROKER_CD, :NEW.BROKER_CD), 
         DECODE(v_opCode, 'D', :OLD.FUND_CD, :NEW.FUND_CD), 
         DECODE(v_opCode, 'D', :OLD.POSITION_FLAG, :NEW.POSITION_FLAG), 
         DECODE(v_opCode, 'D', :OLD.COLLATERAL_CURRENCY_CD, :NEW.COLLATERAL_CURRENCY_CD), 
         DECODE(v_opCode, 'D', :OLD.COLLATERAL_TYPE, :NEW.COLLATERAL_TYPE), 
         DECODE(v_opCode, 'D', :OLD.TRADE_COUNTRY_CD, :NEW.TRADE_COUNTRY_CD), 
         DECODE(v_opCode, 'D', :OLD.TRADE_SETTLE_PERIOD, :NEW.TRADE_SETTLE_PERIOD), 
         DECODE(v_opCode, 'D', :OLD.SCHEDULE_ID, :NEW.SCHEDULE_ID), 
         DECODE(v_opCode, 'D', :OLD.CHAIN_ID, :NEW.CHAIN_ID), 
         DECODE(v_opCode, 'D', :OLD.START_TIME, :NEW.START_TIME), 
         DECODE(v_opCode, 'D', :OLD.END_TIME, :NEW.END_TIME), 
         DECODE(v_opCode, 'D', :OLD.TIME_INTERVAL, :NEW.TIME_INTERVAL), 
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
         DECODE(v_opCode, 'D', :OLD.TRANSACTION_CD, :NEW.TRANSACTION_CD), 
         DECODE(v_opCode, 'D', :OLD.COMMENT_TXT, :NEW.COMMENT_TXT), 
         DECODE(v_opCode, 'D', :OLD.CREATED_AT, :NEW.CREATED_AT), 
         DECODE(v_opCode, 'D', :OLD.CREATED_BY, :NEW.CREATED_BY), 
         DECODE(v_opCode, 'D', :OLD.UPDATED_AT, :NEW.UPDATED_AT), 
         DECODE(v_opCode, 'D', :OLD.UPDATED_BY, :NEW.UPDATED_BY), 
         DECODE(v_opCode, 'D', :OLD.FULL_FILL, :NEW.FULL_FILL),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_AUTORELEASE_RULE_TA;
/