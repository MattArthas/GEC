CREATE OR REPLACE TRIGGER GEC_G1_COLLATERAL_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         G1_COLLATERAL_ID, 
         G1_BOOKING_ID, 
         TRADE_COUNTRY_CD, 
         COLLATERAL_CURRENCY_CD, 
         COLL_TYPE
   ON GEC_G1_COLLATERAL
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

   INSERT INTO GEC_G1_COLLATERAL_AUD(
         G1_COLLATERAL_ID, 
         G1_BOOKING_ID, 
         TRADE_COUNTRY_CD, 
         COLLATERAL_CURRENCY_CD, 
         COLL_TYPE,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.G1_COLLATERAL_ID, :NEW.G1_COLLATERAL_ID), 
         DECODE(v_opCode, 'D', :OLD.G1_BOOKING_ID, :NEW.G1_BOOKING_ID), 
         DECODE(v_opCode, 'D', :OLD.TRADE_COUNTRY_CD, :NEW.TRADE_COUNTRY_CD), 
         DECODE(v_opCode, 'D', :OLD.COLLATERAL_CURRENCY_CD, :NEW.COLLATERAL_CURRENCY_CD), 
         DECODE(v_opCode, 'D', :OLD.COLL_TYPE, :NEW.COLL_TYPE),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_G1_COLLATERAL_TA;
/