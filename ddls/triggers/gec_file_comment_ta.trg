CREATE OR REPLACE TRIGGER GEC_FILE_COMMENT_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         FILE_COMMENT_ID,
         FILE_ID,
         STATUS,
         STATUS_MSG,
         COMMENT_TXT,
         CREATED_BY,
         CREATED_AT
   ON GEC_FILE_COMMENT
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

   INSERT INTO GEC_FILE_COMMENT_AUD(
         FILE_COMMENT_ID,
         FILE_ID,
         STATUS,
         STATUS_MSG,
         COMMENT_TXT,
         CREATED_BY,
         CREATED_AT,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.FILE_COMMENT_ID, :NEW.FILE_COMMENT_ID),
         DECODE(v_opCode, 'D', :OLD.FILE_ID, :NEW.FILE_ID),
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
         DECODE(v_opCode, 'D', :OLD.STATUS_MSG, :NEW.STATUS_MSG),
         DECODE(v_opCode, 'D', :OLD.COMMENT_TXT, :NEW.COMMENT_TXT),
         DECODE(v_opCode, 'D', :OLD.CREATED_BY, :NEW.CREATED_BY),
         DECODE(v_opCode, 'D', :OLD.CREATED_AT, :NEW.CREATED_AT),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_FILE_COMMENT_TA;
/

