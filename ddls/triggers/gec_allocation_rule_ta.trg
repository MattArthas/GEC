CREATE OR REPLACE TRIGGER GEC_ALLOCATION_RULE_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         ALLOCATION_RULE_ID, 
         ALLOCATE_BORROW_BRANCH, 
         ALLOCATE_DEMAND_BRANCH, 
         BORROW_ALLOCATE_ORDER, 
         DEMAND_ALLOCATE_ORDER
   ON GEC_ALLOCATION_RULE
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

   INSERT INTO GEC_ALLOCATION_RULE_AUD(
         ALLOCATION_RULE_ID, 
         ALLOCATE_BORROW_BRANCH, 
         ALLOCATE_DEMAND_BRANCH, 
         BORROW_ALLOCATE_ORDER, 
         DEMAND_ALLOCATE_ORDER,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.ALLOCATION_RULE_ID, :NEW.ALLOCATION_RULE_ID), 
         DECODE(v_opCode, 'D', :OLD.ALLOCATE_BORROW_BRANCH, :NEW.ALLOCATE_BORROW_BRANCH), 
         DECODE(v_opCode, 'D', :OLD.ALLOCATE_DEMAND_BRANCH, :NEW.ALLOCATE_DEMAND_BRANCH), 
         DECODE(v_opCode, 'D', :OLD.BORROW_ALLOCATE_ORDER, :NEW.BORROW_ALLOCATE_ORDER), 
         DECODE(v_opCode, 'D', :OLD.DEMAND_ALLOCATE_ORDER, :NEW.DEMAND_ALLOCATE_ORDER),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_ALLOCATION_RULE_TA;
/
