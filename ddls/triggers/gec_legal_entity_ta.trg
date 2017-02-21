CREATE OR REPLACE TRIGGER GEC_LEGAL_ENTITY_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         LEGAL_ENTITY_ID, 
         LEGAL_ENTITY_CD, 
         LEGAL_ENTITY_TYPE, 
         LEGAL_ENTITY_DESC
   ON GEC_LEGAL_ENTITY
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

   INSERT INTO GEC_LEGAL_ENTITY_AUD(
         LEGAL_ENTITY_ID, 
         LEGAL_ENTITY_CD, 
         LEGAL_ENTITY_TYPE, 
         LEGAL_ENTITY_DESC,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.LEGAL_ENTITY_ID, :NEW.LEGAL_ENTITY_ID), 
         DECODE(v_opCode, 'D', :OLD.LEGAL_ENTITY_CD, :NEW.LEGAL_ENTITY_CD), 
         DECODE(v_opCode, 'D', :OLD.LEGAL_ENTITY_TYPE, :NEW.LEGAL_ENTITY_TYPE), 
         DECODE(v_opCode, 'D', :OLD.LEGAL_ENTITY_DESC, :NEW.LEGAL_ENTITY_DESC),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_LEGAL_ENTITY_TA;
/
