CREATE OR REPLACE TRIGGER GEC_AUTORELEASE_EXCEPTION_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         AUTORELEASE_EXCEPTION_ID, 
         AUTORELEASE_RULE_ID, 
         POSITION_FLAG, 
         TRADE_COUNTRY_CD, 
         TRADE_SETTLE_PERIOD, 
         CREATED_AT, 
         CREATED_BY, 
         UPDATED_AT, 
         UPDATED_BY,
         FUND_CD 
   ON GEC_AUTORELEASE_EXCEPTION
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

   INSERT INTO GEC_AUTORELEASE_EXCEPTION_AUD(
         AUTORELEASE_EXCEPTION_ID, 
         AUTORELEASE_RULE_ID, 
         POSITION_FLAG, 
         TRADE_COUNTRY_CD, 
         TRADE_SETTLE_PERIOD, 
         CREATED_AT, 
         CREATED_BY, 
         UPDATED_AT, 
         UPDATED_BY,
         FUND_CD, 
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.AUTORELEASE_EXCEPTION_ID, :NEW.AUTORELEASE_EXCEPTION_ID), 
         DECODE(v_opCode, 'D', :OLD.AUTORELEASE_RULE_ID, :NEW.AUTORELEASE_RULE_ID), 
         DECODE(v_opCode, 'D', :OLD.POSITION_FLAG, :NEW.POSITION_FLAG), 
         DECODE(v_opCode, 'D', :OLD.TRADE_COUNTRY_CD, :NEW.TRADE_COUNTRY_CD), 
         DECODE(v_opCode, 'D', :OLD.TRADE_SETTLE_PERIOD, :NEW.TRADE_SETTLE_PERIOD), 
         DECODE(v_opCode, 'D', :OLD.CREATED_AT, :NEW.CREATED_AT), 
         DECODE(v_opCode, 'D', :OLD.CREATED_BY, :NEW.CREATED_BY), 
         DECODE(v_opCode, 'D', :OLD.UPDATED_AT, :NEW.UPDATED_AT), 
         DECODE(v_opCode, 'D', :OLD.UPDATED_BY, :NEW.UPDATED_BY),
         DECODE(v_opCode, 'D', :OLD.FUND_CD, :NEW.FUND_CD), 
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_AUTORELEASE_EXCEPTION_TA;
/