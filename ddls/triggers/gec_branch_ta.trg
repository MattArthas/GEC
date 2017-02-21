CREATE OR REPLACE TRIGGER GEC_BRANCH_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         BRANCH_ID, 
         BRANCH_CD, 
         BRANCH_NAME
   ON GEC_BRANCH
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

   INSERT INTO GEC_BRANCH_AUD(
         BRANCH_ID, 
         BRANCH_CD, 
         BRANCH_NAME,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.BRANCH_ID, :NEW.BRANCH_ID), 
         DECODE(v_opCode, 'D', :OLD.BRANCH_CD, :NEW.BRANCH_CD), 
         DECODE(v_opCode, 'D', :OLD.BRANCH_NAME, :NEW.BRANCH_NAME),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_BRANCH_TA;
/