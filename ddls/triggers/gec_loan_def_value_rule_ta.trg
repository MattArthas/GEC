CREATE OR REPLACE TRIGGER GEC_LOAN_DEF_VALUE_RULE_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         LOAN_DEF_VALUE_RULE_ID, 
         BORROW_REQUEST_TYPE, 
         COUNTRY_CATEGORY_CD, 
         FUND_CATEGORY_CD, 
         SETTLE_DATE_VALUE, 
         PREPAY_DATE_VALUE, 
         COUNTRY_PREPAY_DATE_VALUE_FLAG
   ON GEC_LOAN_DEF_VALUE_RULE
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

   INSERT INTO GEC_LOAN_DEF_VALUE_RULE_AUD(
         LOAN_DEF_VALUE_RULE_ID, 
         BORROW_REQUEST_TYPE, 
         COUNTRY_CATEGORY_CD, 
         FUND_CATEGORY_CD, 
         SETTLE_DATE_VALUE, 
         PREPAY_DATE_VALUE, 
         COUNTRY_PREPAY_DATE_VALUE_FLAG,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.LOAN_DEF_VALUE_RULE_ID, :NEW.LOAN_DEF_VALUE_RULE_ID), 
         DECODE(v_opCode, 'D', :OLD.BORROW_REQUEST_TYPE, :NEW.BORROW_REQUEST_TYPE), 
         DECODE(v_opCode, 'D', :OLD.COUNTRY_CATEGORY_CD, :NEW.COUNTRY_CATEGORY_CD), 
         DECODE(v_opCode, 'D', :OLD.FUND_CATEGORY_CD, :NEW.FUND_CATEGORY_CD), 
         DECODE(v_opCode, 'D', :OLD.SETTLE_DATE_VALUE, :NEW.SETTLE_DATE_VALUE), 
         DECODE(v_opCode, 'D', :OLD.PREPAY_DATE_VALUE, :NEW.PREPAY_DATE_VALUE), 
         DECODE(v_opCode, 'D', :OLD.COUNTRY_PREPAY_DATE_VALUE_FLAG, :NEW.COUNTRY_PREPAY_DATE_VALUE_FLAG),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_LOAN_DEF_VALUE_RULE_TA;
/