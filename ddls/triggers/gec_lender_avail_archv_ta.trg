CREATE OR REPLACE TRIGGER GEC_LENDER_AVAIL_ARCHV_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         LENDER_AVAILABILITY_ID,
         ASSET_ID,
         BROKER_CD,
         LEGAL_ENTITY_ID,
         AVAIL_QTY,
         INDICATIVE_RATE,
         FUND_CD,
         RECLAIM_RATE,
         CREATED_DATETIME,
         STATUS,
         CREATED_AT,
         CREATED_BY,
         SOURCE_CD,
         POSITION_FLAG,
         RESTRICTION_CD,
         ORDER_EXP_DATE
   ON GEC_LENDER_AVAILABILITY_ARCHV
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

end GEC_LENDER_AVAIL_ARCHV_TA;
/