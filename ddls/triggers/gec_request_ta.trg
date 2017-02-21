CREATE OR REPLACE TRIGGER GEC_REQUEST_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         REQUEST_ID, 
         IM_REQUEST_ID, 
         IM_USER_ID, 
         INVESTMENT_MANAGER_CD, 
         BUSINESS_DATE, 
         STRATEGY_ID, 
         STATUS, 
         STATUS_MSG, 
         COMMENT_TXT, 
         LOCATE_COUNT, 
         REPLY_URL, 
         CREATED_BY, 
         CREATED_AT
   ON GEC_REQUEST
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

   INSERT INTO GEC_REQUEST_AUD(
         REQUEST_ID, 
         IM_REQUEST_ID, 
         IM_USER_ID, 
         INVESTMENT_MANAGER_CD, 
         BUSINESS_DATE, 
         STRATEGY_ID, 
         STATUS, 
         STATUS_MSG, 
         COMMENT_TXT, 
         LOCATE_COUNT, 
         REPLY_URL, 
         CREATED_BY, 
         CREATED_AT,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.REQUEST_ID, :NEW.REQUEST_ID), 
         DECODE(v_opCode, 'D', :OLD.IM_REQUEST_ID, :NEW.IM_REQUEST_ID), 
         DECODE(v_opCode, 'D', :OLD.IM_USER_ID, :NEW.IM_USER_ID), 
         DECODE(v_opCode, 'D', :OLD.INVESTMENT_MANAGER_CD, :NEW.INVESTMENT_MANAGER_CD), 
         DECODE(v_opCode, 'D', :OLD.BUSINESS_DATE, :NEW.BUSINESS_DATE), 
         DECODE(v_opCode, 'D', :OLD.STRATEGY_ID, :NEW.STRATEGY_ID), 
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS), 
         DECODE(v_opCode, 'D', :OLD.STATUS_MSG, :NEW.STATUS_MSG), 
         DECODE(v_opCode, 'D', :OLD.COMMENT_TXT, :NEW.COMMENT_TXT), 
         DECODE(v_opCode, 'D', :OLD.LOCATE_COUNT, :NEW.LOCATE_COUNT), 
         DECODE(v_opCode, 'D', :OLD.REPLY_URL, :NEW.REPLY_URL), 
         DECODE(v_opCode, 'D', :OLD.CREATED_BY, :NEW.CREATED_BY), 
         DECODE(v_opCode, 'D', :OLD.CREATED_AT, :NEW.CREATED_AT),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_REQUEST_TA;
/