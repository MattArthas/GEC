CREATE OR REPLACE TRIGGER GEC_CHAIN_SCHEDULE_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         CHAIN_SCHEDULE_ID, 
         EQU_SCHEDULE_ID, 
         CHAIN_ID, 
         CHAIN_SEQ_NUMBER, 
         BROKER_CD, 
         SFP_LEGAL_ENTITY_ID, 
         SFP_LEGAL_ENTITY_NAME, 
         LENDER_CORP_ID, 
         LENDER_LEGAL_ENTITY_ID, 
         LENDER_LEGAL_ENTITY_NAME, 
         ORDER_EXPIRE_PERIOD, 
         UPDATED_AT, 
         UPDATED_BY
   ON GEC_CHAIN_SCHEDULE
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

   INSERT INTO GEC_CHAIN_SCHEDULE_AUD(
         CHAIN_SCHEDULE_ID, 
         EQU_SCHEDULE_ID, 
         CHAIN_ID, 
         CHAIN_SEQ_NUMBER, 
         BROKER_CD, 
         SFP_LEGAL_ENTITY_ID, 
         SFP_LEGAL_ENTITY_NAME, 
         LENDER_CORP_ID, 
         LENDER_LEGAL_ENTITY_ID, 
         LENDER_LEGAL_ENTITY_NAME, 
         ORDER_EXPIRE_PERIOD, 
         UPDATED_AT, 
         UPDATED_BY, 
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.CHAIN_SCHEDULE_ID, :NEW.CHAIN_SCHEDULE_ID), 
         DECODE(v_opCode, 'D', :OLD.EQU_SCHEDULE_ID, :NEW.EQU_SCHEDULE_ID), 
         DECODE(v_opCode, 'D', :OLD.CHAIN_ID, :NEW.CHAIN_ID), 
         DECODE(v_opCode, 'D', :OLD.CHAIN_SEQ_NUMBER, :NEW.CHAIN_SEQ_NUMBER), 
         DECODE(v_opCode, 'D', :OLD.BROKER_CD, :NEW.BROKER_CD), 
         DECODE(v_opCode, 'D', :OLD.SFP_LEGAL_ENTITY_ID, :NEW.SFP_LEGAL_ENTITY_ID), 
         DECODE(v_opCode, 'D', :OLD.SFP_LEGAL_ENTITY_NAME, :NEW.SFP_LEGAL_ENTITY_NAME), 
         DECODE(v_opCode, 'D', :OLD.LENDER_CORP_ID, :NEW.LENDER_CORP_ID), 
         DECODE(v_opCode, 'D', :OLD.LENDER_LEGAL_ENTITY_ID, :NEW.LENDER_LEGAL_ENTITY_ID), 
         DECODE(v_opCode, 'D', :OLD.LENDER_LEGAL_ENTITY_NAME, :NEW.LENDER_LEGAL_ENTITY_NAME), 
         DECODE(v_opCode, 'D', :OLD.ORDER_EXPIRE_PERIOD, :NEW.ORDER_EXPIRE_PERIOD), 
         DECODE(v_opCode, 'D', :OLD.UPDATED_AT, :NEW.UPDATED_AT), 
         DECODE(v_opCode, 'D', :OLD.UPDATED_BY, :NEW.UPDATED_BY), 
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_CHAIN_SCHEDULE_TA;
/