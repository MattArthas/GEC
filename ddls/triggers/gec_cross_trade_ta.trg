CREATE OR REPLACE TRIGGER GEC_CROSS_TRADE_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         CROSS_TRADE_ID, 
         ALLOCATION_ID,
         BULK_G1_TRADE_ID,
         FLIP_BORROW_ID, 
         SOURCE, 
         BORROW_ID, 
         LOAN_ID
   ON GEC_CROSS_TRADE
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

   INSERT INTO GEC_CROSS_TRADE_AUD(
         CROSS_TRADE_ID, 
         ALLOCATION_ID, 
         BULK_G1_TRADE_ID,
         FLIP_BORROW_ID,
         SOURCE, 
         BORROW_ID, 
         LOAN_ID,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.CROSS_TRADE_ID, :NEW.CROSS_TRADE_ID), 
         DECODE(v_opCode, 'D', :OLD.ALLOCATION_ID, :NEW.ALLOCATION_ID), 
         DECODE(v_opCode, 'D', :OLD.BULK_G1_TRADE_ID, :NEW.BULK_G1_TRADE_ID),
         DECODE(v_opCode, 'D', :OLD.FLIP_BORROW_ID, :NEW.FLIP_BORROW_ID),
         DECODE(v_opCode, 'D', :OLD.SOURCE, :NEW.SOURCE), 
         DECODE(v_opCode, 'D', :OLD.BORROW_ID, :NEW.BORROW_ID), 
         DECODE(v_opCode, 'D', :OLD.LOAN_ID, :NEW.LOAN_ID),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_CROSS_TRADE_TA;
/
