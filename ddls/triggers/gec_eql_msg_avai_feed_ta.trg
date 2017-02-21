CREATE OR REPLACE TRIGGER GEC_EQL_MSG_AVAI_FEED_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         EQUILEND_MESSAGE_ID, 
         EQL_AVAILABILITY_FEED_ID,         
         STATUS
   ON GEC_EQL_MSG_AVAI_FEED
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

   INSERT INTO GEC_EQL_MSG_AVAI_FEED_AUD(
         EQUILEND_MESSAGE_ID, 
         EQL_AVAILABILITY_FEED_ID,         
         STATUS,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.EQUILEND_MESSAGE_ID, :NEW.EQUILEND_MESSAGE_ID), 
         DECODE(v_opCode, 'D', :OLD.EQL_AVAILABILITY_FEED_ID, :NEW.EQL_AVAILABILITY_FEED_ID),		 
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_EQL_MSG_AVAI_FEED_TA;
/