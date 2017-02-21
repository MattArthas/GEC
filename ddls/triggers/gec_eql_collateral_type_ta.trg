CREATE OR REPLACE TRIGGER GEC_EQL_COLLATERAL_TYPE_TA                                                                                                              
   BEFORE INSERT OR UPDATE OR DELETE OF 
         EQL_COLLATERAL_TYPE_ID, 
         EQL_COLLATERAL_TYPE, 
         SUBACCOUNT_ID, 
         EQL_COLLATERAL_TYPE_DESC, 
         GEC_COLLATERAL_TYPE
   ON GEC_EQL_COLLATERAL_TYPE
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

   INSERT INTO GEC_EQL_COLLATERAL_TYPE_AUD(
         EQL_COLLATERAL_TYPE_ID, 
         EQL_COLLATERAL_TYPE, 
         SUBACCOUNT_ID, 
         EQL_COLLATERAL_TYPE_DESC, 
         GEC_COLLATERAL_TYPE,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.EQL_COLLATERAL_TYPE_ID, :NEW.EQL_COLLATERAL_TYPE_ID), 
         DECODE(v_opCode, 'D', :OLD.EQL_COLLATERAL_TYPE, :NEW.EQL_COLLATERAL_TYPE), 
         DECODE(v_opCode, 'D', :OLD.SUBACCOUNT_ID, :NEW.SUBACCOUNT_ID), 
         DECODE(v_opCode, 'D', :OLD.EQL_COLLATERAL_TYPE_DESC, :NEW.EQL_COLLATERAL_TYPE_DESC), 
         DECODE(v_opCode, 'D', :OLD.GEC_COLLATERAL_TYPE, :NEW.GEC_COLLATERAL_TYPE),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_EQL_COLLATERAL_TYPE_TA;
/
