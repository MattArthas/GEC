CREATE OR REPLACE TRIGGER GEC_G1_INSTANCE_BRANCH_MAP_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         G1_INSTANCE_CD, 
         BRANCH_CD
   ON GEC_G1_INSTANCE_BRANCH_MAP
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

   INSERT INTO GEC_G1_INSTANCE_BRANCH_MAP_AUD(
         G1_INSTANCE_CD, 
         BRANCH_CD,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.G1_INSTANCE_CD, :NEW.G1_INSTANCE_CD), 
         DECODE(v_opCode, 'D', :OLD.BRANCH_CD, :NEW.BRANCH_CD),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_G1_INSTANCE_BRANCH_MAP_TA;
/