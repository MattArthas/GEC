CREATE OR REPLACE TRIGGER GEC_MESSAGE_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         MESSAGE_ID, 
         REQUEST_ID, 
         MESSAGE_TYPE, 
         CREATED_AT, 
         SOURCE_CD,
         STATUS
   ON GEC_MESSAGE
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

   IF v_opCode = 'I'
   THEN
	   INSERT INTO GEC_MESSAGE_AUD(
	         MESSAGE_ID, 
	         REQUEST_ID, 
	         MESSAGE_TYPE, 
	         CREATED_AT, 
	         MESSAGE_CONTENT, 
	         SOURCE_CD,
	         STATUS,
	         LAST_UPDATED_BY,
	         LAST_UPDATED_AT,
	         OP_CODE
	      )
	   VALUES (
	         DECODE(v_opCode, 'D', :OLD.MESSAGE_ID, :NEW.MESSAGE_ID), 
	         DECODE(v_opCode, 'D', :OLD.REQUEST_ID, :NEW.REQUEST_ID), 
	         DECODE(v_opCode, 'D', :OLD.MESSAGE_TYPE, :NEW.MESSAGE_TYPE), 
	         DECODE(v_opCode, 'D', :OLD.CREATED_AT, :NEW.CREATED_AT), 
	         DECODE(v_opCode, 'D', :OLD.MESSAGE_CONTENT, :NEW.MESSAGE_CONTENT), 
	         DECODE(v_opCode, 'D', :OLD.SOURCE_CD, :NEW.SOURCE_CD),
	         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
	         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
	                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
	         SYSDATE,
	         v_opCode
	   );
   ELSE
	   INSERT INTO GEC_MESSAGE_AUD(
	         MESSAGE_ID, 
	         REQUEST_ID, 
	         MESSAGE_TYPE, 
	         CREATED_AT, 
	         MESSAGE_CONTENT, 
	         SOURCE_CD,
	         STATUS,
	         LAST_UPDATED_BY,
	         LAST_UPDATED_AT,
	         OP_CODE
	      )
	   VALUES (
	         DECODE(v_opCode, 'D', :OLD.MESSAGE_ID, :NEW.MESSAGE_ID), 
	         DECODE(v_opCode, 'D', :OLD.REQUEST_ID, :NEW.REQUEST_ID), 
	         DECODE(v_opCode, 'D', :OLD.MESSAGE_TYPE, :NEW.MESSAGE_TYPE), 
	         DECODE(v_opCode, 'D', :OLD.CREATED_AT, :NEW.CREATED_AT), 
	         NULL, 
	         DECODE(v_opCode, 'D', :OLD.SOURCE_CD, :NEW.SOURCE_CD),
	         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
	         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
	                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
	         SYSDATE,
	         v_opCode
	   );
   END IF;
   

END GEC_MESSAGE_TA;
/