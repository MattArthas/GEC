CREATE OR REPLACE TRIGGER GEC_SCHEDULE_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         SCHEDULE_ID, 
         EQUILEND_SCHEDULE_ID, 
         SCHEDULE_DESC, 
         BROKER_CD, 
         SFP_CORP_ID,
         SFP_LEGAL_ENTITY_ID, 
         SFP_LEGAL_ENTITY_NAME, 
         LENDER_CORP_ID, 
         LENDER_LEGAL_ENTITY_ID, 
         LENDER_LEGAL_ENTITY_NAME, 
         TYPE, 
         STATUS, 
         RATE_TYPE, 
         RECLAIM_RATE, 
         EQL_COLLATERAL_TYPE, 
         COLLATERAL_CURRENCY_CD,
         EQL_COLLATERAL_TYPE_DESC, 
         BILLING_CURRENCY_CD, 
         SETTLE_TYPE,
         GEC_STATUS, 
         SUBACCOUNT_ID,
         UPDATED_AT, 
         UPDATED_BY
   ON GEC_SCHEDULE
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

   INSERT INTO GEC_SCHEDULE_AUD(
         SCHEDULE_ID, 
         EQUILEND_SCHEDULE_ID, 
         SCHEDULE_DESC, 
         BROKER_CD,
         SFP_CORP_ID, 
         SFP_LEGAL_ENTITY_ID, 
         SFP_LEGAL_ENTITY_NAME, 
         LENDER_CORP_ID, 
         LENDER_LEGAL_ENTITY_ID, 
         LENDER_LEGAL_ENTITY_NAME, 
         TYPE, 
         STATUS, 
         RATE_TYPE, 
         RECLAIM_RATE, 
         EQL_COLLATERAL_TYPE, 
         COLLATERAL_CURRENCY_CD,
         EQL_COLLATERAL_TYPE_DESC, 
         BILLING_CURRENCY_CD, 
         SETTLE_TYPE,
         GEC_STATUS,
         SUBACCOUNT_ID, 
         UPDATED_AT, 
         UPDATED_BY, 
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.SCHEDULE_ID, :NEW.SCHEDULE_ID), 
         DECODE(v_opCode, 'D', :OLD.EQUILEND_SCHEDULE_ID, :NEW.EQUILEND_SCHEDULE_ID), 
         DECODE(v_opCode, 'D', :OLD.SCHEDULE_DESC, :NEW.SCHEDULE_DESC), 
         DECODE(v_opCode, 'D', :OLD.BROKER_CD, :NEW.BROKER_CD),
         DECODE(v_opCode, 'D', :OLD.SFP_CORP_ID, :NEW.SFP_CORP_ID), 
         DECODE(v_opCode, 'D', :OLD.SFP_LEGAL_ENTITY_ID, :NEW.SFP_LEGAL_ENTITY_ID), 
         DECODE(v_opCode, 'D', :OLD.SFP_LEGAL_ENTITY_NAME, :NEW.SFP_LEGAL_ENTITY_NAME), 
         DECODE(v_opCode, 'D', :OLD.LENDER_CORP_ID, :NEW.LENDER_CORP_ID), 
         DECODE(v_opCode, 'D', :OLD.LENDER_LEGAL_ENTITY_ID, :NEW.LENDER_LEGAL_ENTITY_ID), 
         DECODE(v_opCode, 'D', :OLD.LENDER_LEGAL_ENTITY_NAME, :NEW.LENDER_LEGAL_ENTITY_NAME), 
         DECODE(v_opCode, 'D', :OLD.TYPE, :NEW.TYPE), 
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS), 
         DECODE(v_opCode, 'D', :OLD.RATE_TYPE, :NEW.RATE_TYPE), 
         DECODE(v_opCode, 'D', :OLD.RECLAIM_RATE, :NEW.RECLAIM_RATE), 
         DECODE(v_opCode, 'D', :OLD.EQL_COLLATERAL_TYPE, :NEW.EQL_COLLATERAL_TYPE), 
         DECODE(v_opCode, 'D', :OLD.COLLATERAL_CURRENCY_CD, :NEW.COLLATERAL_CURRENCY_CD), 
         DECODE(v_opCode, 'D', :OLD.EQL_COLLATERAL_TYPE_DESC, :NEW.EQL_COLLATERAL_TYPE_DESC),
         DECODE(v_opCode, 'D', :OLD.BILLING_CURRENCY_CD, :NEW.BILLING_CURRENCY_CD), 
         DECODE(v_opCode, 'D', :OLD.SETTLE_TYPE, :NEW.SETTLE_TYPE), 
         DECODE(v_opCode, 'D', :OLD.GEC_STATUS, :NEW.GEC_STATUS),
         DECODE(v_opCode, 'D', :OLD.SUBACCOUNT_ID, :NEW.SUBACCOUNT_ID),
         DECODE(v_opCode, 'D', :OLD.UPDATED_AT, :NEW.UPDATED_AT), 
         DECODE(v_opCode, 'D', :OLD.UPDATED_BY, :NEW.UPDATED_BY), 
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_SCHEDULE_TA;
/