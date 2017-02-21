CREATE OR REPLACE TRIGGER GEC_TRADE_AVAIL_FILTER_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         TRADE_AVAIL_FILTER_ID, 
         INVESTMENT_MANAGER_CD, 
         STRATEGY_NAME
   ON GEC_TRADE_AVAIL_FILTER
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

   INSERT INTO GEC_TRADE_AVAIL_FILTER_AUD(
         TRADE_AVAIL_FILTER_ID, 
         INVESTMENT_MANAGER_CD, 
         STRATEGY_NAME,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.TRADE_AVAIL_FILTER_ID, :NEW.TRADE_AVAIL_FILTER_ID), 
         DECODE(v_opCode, 'D', :OLD.INVESTMENT_MANAGER_CD, :NEW.INVESTMENT_MANAGER_CD), 
         DECODE(v_opCode, 'D', :OLD.STRATEGY_NAME, :NEW.STRATEGY_NAME),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_TRADE_AVAIL_FILTER_TA;
/