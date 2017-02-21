CREATE OR REPLACE TRIGGER GEC_NOC_ALERT_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         NOC_ALERT_CD, 
         SOP_CD, 
         UXCODE, 
         COMMENT_TXT,
         ALERT_FLAG
   ON GEC_NOC_ALERT
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

   INSERT INTO GEC_NOC_ALERT_AUD(
         NOC_ALERT_CD, 
         SOP_CD, 
         UXCODE, 
         COMMENT_TXT,
         ALERT_FLAG,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.NOC_ALERT_CD, :NEW.NOC_ALERT_CD), 
         DECODE(v_opCode, 'D', :OLD.SOP_CD, :NEW.SOP_CD), 
         DECODE(v_opCode, 'D', :OLD.UXCODE, :NEW.UXCODE), 
         DECODE(v_opCode, 'D', :OLD.COMMENT_TXT, :NEW.COMMENT_TXT),
         DECODE(v_opCode, 'D', :OLD.ALERT_FLAG, :NEW.ALERT_FLAG),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_NOC_ALERT_TA;
/
