CREATE OR REPLACE TRIGGER GEC_BORROW_REQUEST_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         BORROW_REQUEST_ID, 
         BORROW_REQUEST_TYPE, 
         STATUS, 
         BORROW_REQUEST_FILE_TYPE, 
         STATUS_MSG, 
         RESPONSE_AT, 
         RESPONSE_BY, 
         REQUEST_AT, 
         REQUEST_BY,
         BRANCH_CD,
  		 BROKER_CD,
  		 SETTLEMENT_MARKET,
  		 COLLATERAL_TYPE,
  		 COLLATERAL_CURRENCY_CD,
  		 AUTOBORROW_BATCH_ID,
		 AGGREGATE_ID,
		 EQUILEND_CHAIN_ID,
		 EQUILEND_SCHEDULE_ID,
		 REQUEST_COUNT,
		 SHTT_ABNO_COUNT,
		 ORAC_ABRE_COUNT,
		 CANCEL_BY,
		 CANCEL_AT,
		 TYPE,
		 EXPIRATION_TIME,
		 ALLOCATE_STATUS,
		 FULL_FILL
   ON GEC_BORROW_REQUEST
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

   INSERT INTO GEC_BORROW_REQUEST_AUD(
         BORROW_REQUEST_ID, 
         BORROW_REQUEST_TYPE, 
         STATUS, 
         BORROW_REQUEST_FILE_TYPE, 
         STATUS_MSG, 
         RESPONSE_AT, 
         RESPONSE_BY, 
         REQUEST_AT, 
         REQUEST_BY,
         BRANCH_CD,
  		 BROKER_CD,
  		 SETTLEMENT_MARKET,
  		 COLLATERAL_TYPE,
  		 COLLATERAL_CURRENCY_CD,
  		 AUTOBORROW_BATCH_ID,
		 AGGREGATE_ID,
		 EQUILEND_CHAIN_ID,
		 EQUILEND_SCHEDULE_ID,
		 REQUEST_COUNT,
		 SHTT_ABNO_COUNT,
		 ORAC_ABRE_COUNT,
		 CANCEL_BY,
		 CANCEL_AT,
		 TYPE,
		 EXPIRATION_TIME,
		 ALLOCATE_STATUS,
		 FULL_FILL,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.BORROW_REQUEST_ID, :NEW.BORROW_REQUEST_ID), 
         DECODE(v_opCode, 'D', :OLD.BORROW_REQUEST_TYPE, :NEW.BORROW_REQUEST_TYPE), 
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS), 
         DECODE(v_opCode, 'D', :OLD.BORROW_REQUEST_FILE_TYPE, :NEW.BORROW_REQUEST_FILE_TYPE), 
         DECODE(v_opCode, 'D', :OLD.STATUS_MSG, :NEW.STATUS_MSG), 
         DECODE(v_opCode, 'D', :OLD.RESPONSE_AT, :NEW.RESPONSE_AT), 
         DECODE(v_opCode, 'D', :OLD.RESPONSE_BY, :NEW.RESPONSE_BY), 
         DECODE(v_opCode, 'D', :OLD.REQUEST_AT, :NEW.REQUEST_AT), 
         DECODE(v_opCode, 'D', :OLD.REQUEST_BY, :NEW.REQUEST_BY),
         DECODE(v_opCode, 'D', :OLD.BRANCH_CD, :NEW.BRANCH_CD),
  		 DECODE(v_opCode, 'D', :OLD.BROKER_CD, :NEW.BROKER_CD),
  		 DECODE(v_opCode, 'D', :OLD.SETTLEMENT_MARKET, :NEW.SETTLEMENT_MARKET),
         DECODE(v_opCode, 'D', :OLD.COLLATERAL_TYPE, :NEW.COLLATERAL_TYPE),
         DECODE(v_opCode, 'D', :OLD.COLLATERAL_CURRENCY_CD, :NEW.COLLATERAL_CURRENCY_CD),
         DECODE(v_opCode, 'D', :OLD.AUTOBORROW_BATCH_ID, :NEW.AUTOBORROW_BATCH_ID),
         DECODE(v_opCode, 'D', :OLD.AGGREGATE_ID, :NEW.AGGREGATE_ID),
         DECODE(v_opCode, 'D', :OLD.EQUILEND_CHAIN_ID, :NEW.EQUILEND_CHAIN_ID),
         DECODE(v_opCode, 'D', :OLD.EQUILEND_SCHEDULE_ID, :NEW.EQUILEND_SCHEDULE_ID),
         DECODE(v_opCode, 'D', :OLD.REQUEST_COUNT, :NEW.REQUEST_COUNT),
         DECODE(v_opCode, 'D', :OLD.SHTT_ABNO_COUNT, :NEW.SHTT_ABNO_COUNT),
         DECODE(v_opCode, 'D', :OLD.ORAC_ABRE_COUNT, :NEW.ORAC_ABRE_COUNT),
         DECODE(v_opCode, 'D', :OLD.CANCEL_BY, :NEW.CANCEL_BY),
         DECODE(v_opCode, 'D', :OLD.CANCEL_AT, :NEW.CANCEL_AT),
         DECODE(v_opCode, 'D', :OLD.TYPE, :NEW.TYPE),
         DECODE(v_opCode, 'D', :OLD.EXPIRATION_TIME, :NEW.EXPIRATION_TIME),
         DECODE(v_opCode, 'D', :OLD.ALLOCATE_STATUS, :NEW.ALLOCATE_STATUS),
         DECODE(v_opCode, 'D', :OLD.FULL_FILL, :NEW.FULL_FILL),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_BORROW_REQUEST_TA;
/