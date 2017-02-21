CREATE OR REPLACE TRIGGER GEC_G1_SB_BORROW_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         BORROW_ID,
         COUNTERPARTY_CD,
         BORROW_QTY
   ON GEC_G1_SB_BORROW
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

   INSERT INTO GEC_G1_SB_BORROW_AUD(
         BORROW_ID,
         COUNTERPARTY_CD,
         BORROW_QTY,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.BORROW_ID, :NEW.BORROW_ID),
         DECODE(v_opCode, 'D', :OLD.COUNTERPARTY_CD, :NEW.COUNTERPARTY_CD),
         DECODE(v_opCode, 'D', :OLD.BORROW_QTY, :NEW.BORROW_QTY),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_G1_SB_BORROW_TA;
/

