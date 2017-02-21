CREATE OR REPLACE TRIGGER GEC_SFA_AVAIL_FILTER_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         SFA_AVAIL_FILTER_ID, 
         FUND_CD, 
         TRADE_COUNTRY_CDS, 
         STATUS,
         AVAILABILITY_REGION
   ON GEC_SFA_AVAIL_FILTER
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

   INSERT INTO GEC_SFA_AVAIL_FILTER_AUD(
         SFA_AVAIL_FILTER_ID, 
         FUND_CD, 
         TRADE_COUNTRY_CDS, 
         STATUS,
         AVAILABILITY_REGION,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.SFA_AVAIL_FILTER_ID, :NEW.SFA_AVAIL_FILTER_ID), 
         DECODE(v_opCode, 'D', :OLD.FUND_CD, :NEW.FUND_CD), 
         DECODE(v_opCode, 'D', :OLD.TRADE_COUNTRY_CDS, :NEW.TRADE_COUNTRY_CDS), 
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
         DECODE(v_opCode, 'D', :OLD.AVAILABILITY_REGION, :NEW.AVAILABILITY_REGION),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_SFA_AVAIL_FILTER_TA;
/
