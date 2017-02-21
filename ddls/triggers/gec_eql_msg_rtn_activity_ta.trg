CREATE OR REPLACE TRIGGER GEC_EQL_MSG_RTN_ACTIVITY_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         EQL_MSG_RTN_ACTIVITY_ID, 
         EQUILEND_MESSAGE_ID, 
         G1_RETURN_DETAIL_ID, 
         EQL_RETURN_SEQ_NBR, 
         EQUILEND_ID, 
         EQL_UPDATE_REASON_CD, 
         RETURN_STATUS, 
         LOG_NUMBER, 
         WARN_CODE, 
         WARN_FLD_NAME, 
         WARN_FLD_VALUE, 
         WARN_CODE_DESC, 
         NARRATIVE, 
         EQL_RETURN_ID
   ON GEC_EQL_MSG_RTN_ACTIVITY
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

   INSERT INTO GEC_EQL_MSG_RTN_ACTIVITY_AUD(
         EQL_MSG_RTN_ACTIVITY_ID, 
         EQUILEND_MESSAGE_ID, 
         G1_RETURN_DETAIL_ID, 
         EQL_RETURN_SEQ_NBR, 
         EQUILEND_ID, 
         EQL_UPDATE_REASON_CD, 
         RETURN_STATUS, 
         LOG_NUMBER, 
         WARN_CODE, 
         WARN_FLD_NAME, 
         WARN_FLD_VALUE, 
         WARN_CODE_DESC, 
         NARRATIVE, 
         EQL_RETURN_ID,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.EQL_MSG_RTN_ACTIVITY_ID, :NEW.EQL_MSG_RTN_ACTIVITY_ID), 
         DECODE(v_opCode, 'D', :OLD.EQUILEND_MESSAGE_ID, :NEW.EQUILEND_MESSAGE_ID), 
         DECODE(v_opCode, 'D', :OLD.G1_RETURN_DETAIL_ID, :NEW.G1_RETURN_DETAIL_ID), 
         DECODE(v_opCode, 'D', :OLD.EQL_RETURN_SEQ_NBR, :NEW.EQL_RETURN_SEQ_NBR), 
         DECODE(v_opCode, 'D', :OLD.EQUILEND_ID, :NEW.EQUILEND_ID), 
         DECODE(v_opCode, 'D', :OLD.EQL_UPDATE_REASON_CD, :NEW.EQL_UPDATE_REASON_CD), 
         DECODE(v_opCode, 'D', :OLD.RETURN_STATUS, :NEW.RETURN_STATUS), 
         DECODE(v_opCode, 'D', :OLD.LOG_NUMBER, :NEW.LOG_NUMBER), 
         DECODE(v_opCode, 'D', :OLD.WARN_CODE, :NEW.WARN_CODE), 
         DECODE(v_opCode, 'D', :OLD.WARN_FLD_NAME, :NEW.WARN_FLD_NAME), 
         DECODE(v_opCode, 'D', :OLD.WARN_FLD_VALUE, :NEW.WARN_FLD_VALUE), 
         DECODE(v_opCode, 'D', :OLD.WARN_CODE_DESC, :NEW.WARN_CODE_DESC), 
         DECODE(v_opCode, 'D', :OLD.NARRATIVE, :NEW.NARRATIVE), 
         DECODE(v_opCode, 'D', :OLD.EQL_RETURN_ID, :NEW.EQL_RETURN_ID),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_EQL_MSG_RTN_ACTIVITY_TA;
/
