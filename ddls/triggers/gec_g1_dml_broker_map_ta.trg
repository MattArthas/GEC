CREATE OR REPLACE TRIGGER GEC_G1_DML_BROKER_MAP_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         G1_DML_BROKER_MAP_ID, 
         G1_COUNTERPARTY_CD, 
         DML_BROKER_CD 
   ON GEC_G1_DML_BROKER_MAP
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

   INSERT INTO GEC_G1_DML_BROKER_MAP_AUD(
         G1_DML_BROKER_MAP_ID, 
         G1_COUNTERPARTY_CD, 
         DML_BROKER_CD, 
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.G1_DML_BROKER_MAP_ID, :NEW.G1_DML_BROKER_MAP_ID), 
         DECODE(v_opCode, 'D', :OLD.G1_COUNTERPARTY_CD, :NEW.G1_COUNTERPARTY_CD), 
         DECODE(v_opCode, 'D', :OLD.DML_BROKER_CD, :NEW.DML_BROKER_CD), 
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_G1_DML_BROKER_MAP_TA;
/
