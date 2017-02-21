CREATE OR REPLACE TRIGGER GEC_G1_RETURN_LENDER_ACPT_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         G1_RETURN_LENDER_ACCEPT_ID, 
         G1_RETURN_DETAIL_ID, 
         QTY, 
         TRADE_DATE, 
         SETTLE_DATE, 
         EQL_RETURN_ID, 
         LEND_SETTLE_INSTR_ID, 
         BORR_SETTLE_INSTR_ID,
         GEC_STATUS, 
         GEC_STATUS_MSG, 
         EQL_STATUS, 
         EQL_STATUS_MSG,
         UPDATED_AT, 
         UPDATED_BY,  
         EQL_UPDATE_REASON_CD, 
         EQL_UPDATE_REASON_COMMENT
   ON GEC_G1_RETURN_LENDER_ACCEPT
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

   INSERT INTO GEC_G1_RETURN_LENDER_ACPT_AUD(
         G1_RETURN_LENDER_ACCEPT_ID, 
         G1_RETURN_DETAIL_ID, 
         QTY, 
         TRADE_DATE, 
         SETTLE_DATE, 
         EQL_RETURN_ID, 
         LEND_SETTLE_INSTR_ID, 
         BORR_SETTLE_INSTR_ID,
         GEC_STATUS, 
         GEC_STATUS_MSG, 
         EQL_STATUS, 
         EQL_STATUS_MSG,
         UPDATED_AT, 
         UPDATED_BY, 
         EQL_UPDATE_REASON_CD, 
         EQL_UPDATE_REASON_COMMENT,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.G1_RETURN_LENDER_ACCEPT_ID, :NEW.G1_RETURN_LENDER_ACCEPT_ID), 
         DECODE(v_opCode, 'D', :OLD.G1_RETURN_DETAIL_ID, :NEW.G1_RETURN_DETAIL_ID), 
         DECODE(v_opCode, 'D', :OLD.QTY, :NEW.QTY), 
         DECODE(v_opCode, 'D', :OLD.TRADE_DATE, :NEW.TRADE_DATE), 
         DECODE(v_opCode, 'D', :OLD.SETTLE_DATE, :NEW.SETTLE_DATE), 
         DECODE(v_opCode, 'D', :OLD.EQL_RETURN_ID, :NEW.EQL_RETURN_ID), 
         DECODE(v_opCode, 'D', :OLD.LEND_SETTLE_INSTR_ID, :NEW.LEND_SETTLE_INSTR_ID), 
         DECODE(v_opCode, 'D', :OLD.BORR_SETTLE_INSTR_ID, :NEW.BORR_SETTLE_INSTR_ID), 
         DECODE(v_opCode, 'D', :OLD.GEC_STATUS, :NEW.GEC_STATUS), 
         DECODE(v_opCode, 'D', :OLD.GEC_STATUS_MSG, :NEW.GEC_STATUS_MSG), 
         DECODE(v_opCode, 'D', :OLD.EQL_STATUS, :NEW.EQL_STATUS), 
         DECODE(v_opCode, 'D', :OLD.EQL_STATUS_MSG, :NEW.EQL_STATUS_MSG), 
         DECODE(v_opCode, 'D', :OLD.UPDATED_AT, :NEW.UPDATED_AT), 
         DECODE(v_opCode, 'D', :OLD.UPDATED_BY, :NEW.UPDATED_BY), 
         DECODE(v_opCode, 'D', :OLD.EQL_UPDATE_REASON_CD, :NEW.EQL_UPDATE_REASON_CD), 
         DECODE(v_opCode, 'D', :OLD.EQL_UPDATE_REASON_COMMENT, :NEW.EQL_UPDATE_REASON_COMMENT),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_G1_RETURN_LENDER_ACPT_TA;
/
