CREATE OR REPLACE TRIGGER GEC_TICKET_SIZE_RANGE_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         TICKET_SIZE_FROM, 
         TICKET_SIZE_TO, 
         TICKET_SIZE_LABEL
   ON GEC_TICKET_SIZE_RANGE
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

   INSERT INTO GEC_TICKET_SIZE_RANGE_AUD(
         TICKET_SIZE_FROM, 
         TICKET_SIZE_TO, 
         TICKET_SIZE_LABEL,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.TICKET_SIZE_FROM, :NEW.TICKET_SIZE_FROM), 
         DECODE(v_opCode, 'D', :OLD.TICKET_SIZE_TO, :NEW.TICKET_SIZE_TO), 
         DECODE(v_opCode, 'D', :OLD.TICKET_SIZE_LABEL, :NEW.TICKET_SIZE_LABEL),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_TICKET_SIZE_RANGE_TA;
/
