CREATE OR REPLACE TRIGGER GEC_G1_TRADE_ACT_RTN_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         G1_TRADE_ACTIVITY_ID, 
         G1_RETURN_DETAIL_ID
   ON GEC_G1_TRADE_ACT_RTN
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

   INSERT INTO GEC_G1_TRADE_ACT_RTN_AUD(
         G1_TRADE_ACTIVITY_ID, 
         G1_RETURN_DETAIL_ID,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.G1_TRADE_ACTIVITY_ID, :NEW.G1_TRADE_ACTIVITY_ID), 
         DECODE(v_opCode, 'D', :OLD.G1_RETURN_DETAIL_ID, :NEW.G1_RETURN_DETAIL_ID),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_G1_TRADE_ACT_RTN_TA;
/