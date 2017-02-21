CREATE OR REPLACE TRIGGER GEC_FUND_CATEGORY_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         FUND_CATEGORY_ID, 
         FUND_CATEGORY_CD, 
         FUND_CATEGORY_DESC
   ON GEC_FUND_CATEGORY
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

   INSERT INTO GEC_FUND_CATEGORY_AUD(
         FUND_CATEGORY_ID, 
         FUND_CATEGORY_CD, 
         FUND_CATEGORY_DESC,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.FUND_CATEGORY_ID, :NEW.FUND_CATEGORY_ID), 
         DECODE(v_opCode, 'D', :OLD.FUND_CATEGORY_CD, :NEW.FUND_CATEGORY_CD), 
         DECODE(v_opCode, 'D', :OLD.FUND_CATEGORY_DESC, :NEW.FUND_CATEGORY_DESC),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_FUND_CATEGORY_TA;
/