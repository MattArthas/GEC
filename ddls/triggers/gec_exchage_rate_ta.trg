CREATE OR REPLACE TRIGGER GEC_EXCHANGE_RATE_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         EXCHANGE_RATE_ID, 
         EXCHANGE_CURRENCY_CD, 
         EXCHANGE_DATE, 
         EXCHANGE_RATE, 
         COST_OF_FUNDS_RATE,
         CREATE_DATE, 
         EXTENDED_EXCHANGE_RATE
   ON GEC_EXCHANGE_RATE
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

   INSERT INTO GEC_EXCHANGE_RATE_AUD(
         EXCHANGE_RATE_ID, 
         EXCHANGE_CURRENCY_CD, 
         EXCHANGE_DATE, 
         EXCHANGE_RATE, 
         COST_OF_FUNDS_RATE,
         CREATE_DATE, 
         EXTENDED_EXCHANGE_RATE,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.EXCHANGE_RATE_ID, :NEW.EXCHANGE_RATE_ID), 
         DECODE(v_opCode, 'D', :OLD.EXCHANGE_CURRENCY_CD, :NEW.EXCHANGE_CURRENCY_CD), 
         DECODE(v_opCode, 'D', :OLD.EXCHANGE_DATE, :NEW.EXCHANGE_DATE), 
         DECODE(v_opCode, 'D', :OLD.EXCHANGE_RATE, :NEW.EXCHANGE_RATE), 
         DECODE(v_opCode, 'D', :OLD.COST_OF_FUNDS_RATE, :NEW.COST_OF_FUNDS_RATE), 
         DECODE(v_opCode, 'D', :OLD.CREATE_DATE, :NEW.CREATE_DATE), 
         DECODE(v_opCode, 'D', :OLD.EXTENDED_EXCHANGE_RATE, :NEW.EXTENDED_EXCHANGE_RATE),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_EXCHANGE_RATE_TA;
/