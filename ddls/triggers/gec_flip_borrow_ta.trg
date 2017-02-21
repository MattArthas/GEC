CREATE OR REPLACE TRIGGER GEC_FLIP_BORROW_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         FLIP_BORROW_ID,
         BORROW_ID,
         FLIP_TRADE_ID,
         ALLOCATION_QTY,
         STATUS,
         G1_BORROW_RETURN_ID,
         G1_LOAN_RETURN_ID,
		 LOAN_ID,
		 SSGM_LOAN_ID,
		 SSGM_LOAN_RETURN_ID
   ON GEC_FLIP_BORROW
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

   INSERT INTO GEC_FLIP_BORROW_AUD(
         FLIP_BORROW_ID,
         BORROW_ID,
         FLIP_TRADE_ID,
         ALLOCATION_QTY,
         STATUS,
         G1_BORROW_RETURN_ID,
         G1_LOAN_RETURN_ID,
		 LOAN_ID,
		 SSGM_LOAN_ID,
		 SSGM_LOAN_RETURN_ID,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.FLIP_BORROW_ID, :NEW.FLIP_BORROW_ID),
         DECODE(v_opCode, 'D', :OLD.BORROW_ID, :NEW.BORROW_ID),
         DECODE(v_opCode, 'D', :OLD.FLIP_TRADE_ID, :NEW.FLIP_TRADE_ID),
         DECODE(v_opCode, 'D', :OLD.ALLOCATION_QTY, :NEW.ALLOCATION_QTY),
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
         DECODE(v_opCode, 'D', :OLD.G1_BORROW_RETURN_ID, :NEW.G1_BORROW_RETURN_ID),
         DECODE(v_opCode, 'D', :OLD.G1_LOAN_RETURN_ID, :NEW.G1_LOAN_RETURN_ID),
         DECODE(v_opCode, 'D', :OLD.LOAN_ID, :NEW.LOAN_ID),
         DECODE(v_opCode, 'D', :OLD.SSGM_LOAN_RETURN_ID, :NEW.SSGM_LOAN_RETURN_ID),
         DECODE(v_opCode, 'D', :OLD.SSGM_LOAN_RETURN_ID, :NEW.SSGM_LOAN_RETURN_ID),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_FLIP_BORROW_TA;
/