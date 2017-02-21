CREATE OR REPLACE TRIGGER GEC_SSGM_LOAN_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         GEC_SSGM_LOAN_ID,
         ALLOCATION_ID,
         ASSET_ID,
         STATUS,
         TRADE_DATE,
         SETTLE_DATE,
         SSGM_LOAN_QTY,
         RATE,
         COMMENT_TXT,
         CREATED_AT,
         CREATED_BY,
         UPDATED_AT,
         UPDATED_BY
   ON GEC_SSGM_LOAN
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

   INSERT INTO GEC_SSGM_LOAN_AUD(
         GEC_SSGM_LOAN_ID,
         ALLOCATION_ID,
         ASSET_ID,
         STATUS,
         TRADE_DATE,
         SETTLE_DATE,
         SSGM_LOAN_QTY,
         RATE,
         COMMENT_TXT,
         CREATED_AT,
         CREATED_BY,
         UPDATED_AT,
         UPDATED_BY,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.GEC_SSGM_LOAN_ID, :NEW.GEC_SSGM_LOAN_ID),
         DECODE(v_opCode, 'D', :OLD.ALLOCATION_ID, :NEW.ALLOCATION_ID),
         DECODE(v_opCode, 'D', :OLD.ASSET_ID, :NEW.ASSET_ID),
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
         DECODE(v_opCode, 'D', :OLD.TRADE_DATE, :NEW.TRADE_DATE),
         DECODE(v_opCode, 'D', :OLD.SETTLE_DATE, :NEW.SETTLE_DATE),
         DECODE(v_opCode, 'D', :OLD.SSGM_LOAN_QTY, :NEW.SSGM_LOAN_QTY),
         DECODE(v_opCode, 'D', :OLD.RATE, :NEW.RATE),
         DECODE(v_opCode, 'D', :OLD.COMMENT_TXT, :NEW.COMMENT_TXT),
         DECODE(v_opCode, 'D', :OLD.CREATED_AT, :NEW.CREATED_AT),
         DECODE(v_opCode, 'D', :OLD.CREATED_BY, :NEW.CREATED_BY),
         DECODE(v_opCode, 'D', :OLD.UPDATED_AT, :NEW.UPDATED_AT),
         DECODE(v_opCode, 'D', :OLD.UPDATED_BY, :NEW.UPDATED_BY),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_SSGM_LOAN_TA;
/

