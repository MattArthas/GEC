CREATE OR REPLACE TRIGGER GEC_BRW_REQUEST_FILE_TYPE_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
   		 DISPLAY_ORDER,
         BORROW_REQUEST_FILE_TYPE,
         BORROW_REQUEST_TYPE,
         ELIGIBLE_SETTLE_DATES,
         DESCRIPTION
   ON GEC_BRW_REQUEST_FILE_TYPE
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

   INSERT INTO GEC_BRW_REQUEST_FILE_TYPE_AUD(
   		 DISPLAY_ORDER,
         BORROW_REQUEST_FILE_TYPE,
         BORROW_REQUEST_TYPE,
         ELIGIBLE_SETTLE_DATES,
         DESCRIPTION,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
   		 DECODE(v_opCode, 'D', :OLD.DISPLAY_ORDER, :NEW.DISPLAY_ORDER),
         DECODE(v_opCode, 'D', :OLD.BORROW_REQUEST_FILE_TYPE, :NEW.BORROW_REQUEST_FILE_TYPE),
         DECODE(v_opCode, 'D', :OLD.BORROW_REQUEST_TYPE, :NEW.BORROW_REQUEST_TYPE),
         DECODE(v_opCode, 'D', :OLD.ELIGIBLE_SETTLE_DATES, :NEW.ELIGIBLE_SETTLE_DATES),
         DECODE(v_opCode, 'D', :OLD.DESCRIPTION, :NEW.DESCRIPTION),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_BRW_REQUEST_FILE_TYPE_TA;
/
