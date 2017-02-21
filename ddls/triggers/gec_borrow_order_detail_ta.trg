CREATE OR REPLACE TRIGGER GEC_BORROW_ORDER_DETAIL_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         BORROW_ORDER_ID,
         IM_ORDER_ID,
         FULL_FILLED_QTY,
         REQUEST_QTY,
         FILLED_QTY
   ON GEC_BORROW_ORDER_DETAIL
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

   INSERT INTO GEC_BORROW_ORDER_DETAIL_AUD(
         BORROW_ORDER_ID,
         IM_ORDER_ID,
         FULL_FILLED_QTY,
         REQUEST_QTY,
         FILLED_QTY,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.BORROW_ORDER_ID, :NEW.BORROW_ORDER_ID),
         DECODE(v_opCode, 'D', :OLD.IM_ORDER_ID, :NEW.IM_ORDER_ID),
         DECODE(v_opCode, 'D', :OLD.FULL_FILLED_QTY, :NEW.FULL_FILLED_QTY),
         DECODE(v_opCode, 'D', :OLD.REQUEST_QTY, :NEW.REQUEST_QTY),
         DECODE(v_opCode, 'D', :OLD.FILLED_QTY, :NEW.FILLED_QTY),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_BORROW_ORDER_DETAIL_TA;
/

