CREATE OR REPLACE TRIGGER GEC_G1_RECLAIM_RATE_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         G1_RECLAIM_RATE_ID, 
         G1_BOOKING_ID, 
         TRADE_COUNTRY_CD, 
         RECLAIM_RATE, 
         OVERSEAS_TAX_PERCENTAGE, 
         DOMESTIC_TAX_PERCENTAGE
   ON GEC_G1_RECLAIM_RATE
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

   INSERT INTO GEC_G1_RECLAIM_RATE_AUD(
         G1_RECLAIM_RATE_ID, 
         G1_BOOKING_ID, 
         TRADE_COUNTRY_CD, 
         RECLAIM_RATE, 
         OVERSEAS_TAX_PERCENTAGE, 
         DOMESTIC_TAX_PERCENTAGE,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.G1_RECLAIM_RATE_ID, :NEW.G1_RECLAIM_RATE_ID), 
         DECODE(v_opCode, 'D', :OLD.G1_BOOKING_ID, :NEW.G1_BOOKING_ID), 
         DECODE(v_opCode, 'D', :OLD.TRADE_COUNTRY_CD, :NEW.TRADE_COUNTRY_CD), 
         DECODE(v_opCode, 'D', :OLD.RECLAIM_RATE, :NEW.RECLAIM_RATE), 
         DECODE(v_opCode, 'D', :OLD.OVERSEAS_TAX_PERCENTAGE, :NEW.OVERSEAS_TAX_PERCENTAGE), 
         DECODE(v_opCode, 'D', :OLD.DOMESTIC_TAX_PERCENTAGE, :NEW.DOMESTIC_TAX_PERCENTAGE),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_G1_RECLAIM_RATE_TA;
/