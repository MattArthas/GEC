CREATE OR REPLACE TRIGGER GEC_CROSS_TRADE_RULE_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         CROSS_TRADE_RULE_ID, 
         BORROW_LEGAL_ENTITY, 
         DEMAND_LEGAL_ENTITY, 
         CROSS_BORROW_BROKER_CD, 
         CROSS_LOAN_BROKER_CD,
         BOOK_G1_BORROW_FLAG
   ON GEC_CROSS_TRADE_RULE
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

   INSERT INTO GEC_CROSS_TRADE_RULE_AUD(
         CROSS_TRADE_RULE_ID, 
         BORROW_LEGAL_ENTITY, 
         DEMAND_LEGAL_ENTITY, 
         CROSS_BORROW_BROKER_CD, 
         CROSS_LOAN_BROKER_CD,
         BOOK_G1_BORROW_FLAG,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.CROSS_TRADE_RULE_ID, :NEW.CROSS_TRADE_RULE_ID), 
         DECODE(v_opCode, 'D', :OLD.BORROW_LEGAL_ENTITY, :NEW.BORROW_LEGAL_ENTITY), 
         DECODE(v_opCode, 'D', :OLD.DEMAND_LEGAL_ENTITY, :NEW.DEMAND_LEGAL_ENTITY), 
         DECODE(v_opCode, 'D', :OLD.CROSS_BORROW_BROKER_CD, :NEW.CROSS_BORROW_BROKER_CD), 
         DECODE(v_opCode, 'D', :OLD.CROSS_LOAN_BROKER_CD, :NEW.CROSS_LOAN_BROKER_CD),
         DECODE(v_opCode, 'D', :OLD.BOOK_G1_BORROW_FLAG, :NEW.BOOK_G1_BORROW_FLAG),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_CROSS_TRADE_RULE_TA;
/
