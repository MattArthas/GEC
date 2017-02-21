CREATE OR REPLACE TRIGGER GEC_EXCHANGE_RATE_ARCHIVE_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         EXCHANGE_RATE_ID, 
         EXCHANGE_CURRENCY_CD, 
         EXCHANGE_DATE, 
         EXCHANGE_RATE, 
         COST_OF_FUNDS_RATE, 
         CREATE_DATE, 
         EXTENDED_EXCHANGE_RATE
   ON GEC_EXCHANGE_RATE_ARCHIVE
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

END GEC_EXCHANGE_RATE_ARCHIVE_TA;
/