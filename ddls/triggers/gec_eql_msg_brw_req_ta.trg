CREATE OR REPLACE TRIGGER GEC_EQL_MSG_BRW_REQ_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         EQUILEND_MESSAGE_ID, 
         BORROW_REQUEST_ID
   ON GEC_EQL_MSG_BRW_REQ
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

   INSERT INTO GEC_EQL_MSG_BRW_REQ_AUD(
         EQUILEND_MESSAGE_ID, 
         BORROW_REQUEST_ID,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.EQUILEND_MESSAGE_ID, :NEW.EQUILEND_MESSAGE_ID), 
         DECODE(v_opCode, 'D', :OLD.BORROW_REQUEST_ID, :NEW.BORROW_REQUEST_ID),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_EQL_MSG_BRW_REQ_TA;
/