CREATE OR REPLACE TRIGGER GEC_COUNTRY_CATEGORY_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         COUNTRY_CATEGORY_ID, 
         COUNTRY_CATEGORY_CD, 
         COUNTRY_CATEGORY_DESC
   ON GEC_COUNTRY_CATEGORY
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

   INSERT INTO GEC_COUNTRY_CATEGORY_AUD(
         COUNTRY_CATEGORY_ID, 
         COUNTRY_CATEGORY_CD, 
         COUNTRY_CATEGORY_DESC,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.COUNTRY_CATEGORY_ID, :NEW.COUNTRY_CATEGORY_ID), 
         DECODE(v_opCode, 'D', :OLD.COUNTRY_CATEGORY_CD, :NEW.COUNTRY_CATEGORY_CD), 
         DECODE(v_opCode, 'D', :OLD.COUNTRY_CATEGORY_DESC, :NEW.COUNTRY_CATEGORY_DESC),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_COUNTRY_CATEGORY_TA;
/