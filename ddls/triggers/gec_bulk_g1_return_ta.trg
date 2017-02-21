CREATE OR REPLACE TRIGGER GEC_BULK_G1_RETURN_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         BULK_G1_RETURN_ID, 
         ASSET_ID, 
         ASSET_CODE, 
         ASSET_CODE_TYPE,
         TRANSACTION_TYPE,
         TRANSACTION_CD, 
         TRADE_DATE, 
         SETTLE_DATE, 
         COUNTERPARTY_CD, 
         QTY, 
         STATUS, 
         BARGAIN_REF,
         CREATED_BY,
		 CREATED_AT, 
         UPDATED_AT, 
         UPDATED_BY,
         BRANCH_CD,
		 G1_INSTANCE_CD,
		 DIVIDEND_TRADE_FLAG         
   ON GEC_BULK_G1_RETURN
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

   INSERT INTO GEC_BULK_G1_RETURN_AUD(
         BULK_G1_RETURN_ID, 
         ASSET_ID, 
         ASSET_CODE, 
         ASSET_CODE_TYPE, 
         TRANSACTION_TYPE,
         TRANSACTION_CD, 
         TRADE_DATE, 
         SETTLE_DATE, 
         COUNTERPARTY_CD, 
         QTY, 
         STATUS, 
         BARGAIN_REF, 
         CREATED_BY,
		 CREATED_AT, 
         UPDATED_AT, 
         UPDATED_BY,
         BRANCH_CD,
		 G1_INSTANCE_CD,
		 DIVIDEND_TRADE_FLAG,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.BULK_G1_RETURN_ID, :NEW.BULK_G1_RETURN_ID), 
         DECODE(v_opCode, 'D', :OLD.ASSET_ID, :NEW.ASSET_ID), 
         DECODE(v_opCode, 'D', :OLD.ASSET_CODE, :NEW.ASSET_CODE), 
         DECODE(v_opCode, 'D', :OLD.ASSET_CODE_TYPE, :NEW.ASSET_CODE_TYPE), 
         DECODE(v_opCode, 'D', :OLD.TRANSACTION_TYPE, :NEW.TRANSACTION_TYPE),
         DECODE(v_opCode, 'D', :OLD.TRANSACTION_CD, :NEW.TRANSACTION_CD),
         DECODE(v_opCode, 'D', :OLD.TRADE_DATE, :NEW.TRADE_DATE), 
         DECODE(v_opCode, 'D', :OLD.SETTLE_DATE, :NEW.SETTLE_DATE), 
         DECODE(v_opCode, 'D', :OLD.COUNTERPARTY_CD, :NEW.COUNTERPARTY_CD), 
         DECODE(v_opCode, 'D', :OLD.QTY, :NEW.QTY), 
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS), 
         DECODE(v_opCode, 'D', :OLD.BARGAIN_REF, :NEW.BARGAIN_REF), 
         DECODE(v_opCode, 'D', :OLD.CREATED_BY, :NEW.CREATED_BY), 
         DECODE(v_opCode, 'D', :OLD.CREATED_AT, :NEW.CREATED_AT),
         DECODE(v_opCode, 'D', :OLD.UPDATED_AT, :NEW.UPDATED_AT), 
         DECODE(v_opCode, 'D', :OLD.UPDATED_BY, :NEW.UPDATED_BY),
         DECODE(v_opCode, 'D', :OLD.BRANCH_CD, :NEW.BRANCH_CD),
         DECODE(v_opCode, 'D', :OLD.G1_INSTANCE_CD, :NEW.G1_INSTANCE_CD),
         DECODE(v_opCode, 'D', :OLD.DIVIDEND_TRADE_FLAG, :NEW.DIVIDEND_TRADE_FLAG),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_BULK_G1_RETURN_TA;
/
