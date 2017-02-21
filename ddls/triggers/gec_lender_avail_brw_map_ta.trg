CREATE OR REPLACE TRIGGER GEC_LENDER_AVAIL_BRW_MAP_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         LENDER_AVAILABILITY_ID,
         BORROW_ID
   ON GEC_LENDER_AVAIL_BRW_MAP
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

   INSERT INTO GEC_LENDER_AVAIL_BRW_MAP_AUD(
         LENDER_AVAILABILITY_ID,
         BORROW_ID,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.LENDER_AVAILABILITY_ID, :NEW.LENDER_AVAILABILITY_ID),
         DECODE(v_opCode, 'D', :OLD.BORROW_ID, :NEW.BORROW_ID),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_LENDER_AVAIL_BRW_MAP_TA;
/