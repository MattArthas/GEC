CREATE OR REPLACE TRIGGER GEC_COUNTRY_BROKER_PROFILE_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         COUNTRY_BROKER_PROFILE_ID, 
         TRADE_COUNTRY_CD, 
         BROKER_CD, 
         PREPAY_DATE_VALUE,
         UPDATED_AT,
		 UPDATED_BY
   ON GEC_COUNTRY_BROKER_PROFILE
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

   INSERT INTO GEC_COUNTRY_BROKER_PROFILE_AUD(
         COUNTRY_BROKER_PROFILE_ID, 
         TRADE_COUNTRY_CD, 
         BROKER_CD, 
         PREPAY_DATE_VALUE,
         UPDATED_AT,
		 UPDATED_BY,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.COUNTRY_BROKER_PROFILE_ID, :NEW.COUNTRY_BROKER_PROFILE_ID), 
         DECODE(v_opCode, 'D', :OLD.TRADE_COUNTRY_CD, :NEW.TRADE_COUNTRY_CD), 
         DECODE(v_opCode, 'D', :OLD.BROKER_CD, :NEW.BROKER_CD), 
         DECODE(v_opCode, 'D', :OLD.PREPAY_DATE_VALUE, :NEW.PREPAY_DATE_VALUE),
         DECODE(v_opCode, 'D', :OLD.UPDATED_AT, :NEW.UPDATED_AT),
         DECODE(v_opCode, 'D', :OLD.UPDATED_BY, :NEW.UPDATED_BY),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_COUNTRY_BROKER_PROFILE_TA;
/