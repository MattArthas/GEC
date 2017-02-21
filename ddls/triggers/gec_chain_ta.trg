CREATE OR REPLACE TRIGGER GEC_CHAIN_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         CHAIN_ID, 
         EQUILEND_CHAIN_ID, 
         CHAIN_DESC, 
         TYPE, 
         GEC_STATUS, 
         UPDATED_AT, 
         UPDATED_BY
   ON GEC_CHAIN
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

   INSERT INTO GEC_CHAIN_AUD(
         CHAIN_ID, 
         EQUILEND_CHAIN_ID, 
         CHAIN_DESC, 
         TYPE, 
         GEC_STATUS, 
         UPDATED_AT, 
         UPDATED_BY,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.CHAIN_ID, :NEW.CHAIN_ID), 
         DECODE(v_opCode, 'D', :OLD.EQUILEND_CHAIN_ID, :NEW.EQUILEND_CHAIN_ID), 
         DECODE(v_opCode, 'D', :OLD.CHAIN_DESC, :NEW.CHAIN_DESC), 
         DECODE(v_opCode, 'D', :OLD.TYPE, :NEW.TYPE), 
         DECODE(v_opCode, 'D', :OLD.GEC_STATUS, :NEW.GEC_STATUS), 
         DECODE(v_opCode, 'D', :OLD.UPDATED_AT, :NEW.UPDATED_AT), 
         DECODE(v_opCode, 'D', :OLD.UPDATED_BY, :NEW.UPDATED_BY),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_CHAIN_TA;
/