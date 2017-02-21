CREATE OR REPLACE TRIGGER GEC_EQL_ABREASON_DESC_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         EQL_ABREASON_DESC_ID, 
         EQL_ABREASON_CD, 
         EQL_ABREASON_DESC
   ON GEC_EQL_ABREASON_DESC
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

   INSERT INTO GEC_EQL_ABREASON_DESC_AUD(
         EQL_ABREASON_DESC_ID, 
         EQL_ABREASON_CD, 
         EQL_ABREASON_DESC, 
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.EQL_ABREASON_DESC_ID, :NEW.EQL_ABREASON_DESC_ID), 
         DECODE(v_opCode, 'D', :OLD.EQL_ABREASON_CD, :NEW.EQL_ABREASON_CD), 
         DECODE(v_opCode, 'D', :OLD.EQL_ABREASON_DESC, :NEW.EQL_ABREASON_DESC), 
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_EQL_ABREASON_DESC_TA;
/