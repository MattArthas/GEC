CREATE OR REPLACE TRIGGER GEC_FILE_TA
   BEFORE INSERT OR UPDATE OR DELETE
   ON GEC_FILE
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
   IF v_opCode = 'I' OR 
            (v_opCode = 'U' AND GEC_UTILS_PKG.COMPARE_BLOB(:OLD.FILE_CONTENT, :NEW.FILE_CONTENT) != 0) THEN
       INSERT INTO GEC_FILE_AUD(
             FILE_ID,
             REQUEST_ID,
             FILE_NAME,
             SEQ_NUM,
             SCHEDULED_AT,
             FILE_SOURCE,
             FILE_TYPE,
             STATUS,
             STATUS_MSG,
             COMMENT_TXT,
             FILE_CONTENT,
             CREATED_BY,
             CREATED_AT,
             UPDATED_BY,
             UPDATED_AT,
             LAST_UPDATED_BY,
             LAST_UPDATED_AT,
             OP_CODE
          )
       VALUES (
             :NEW.FILE_ID,
             :NEW.REQUEST_ID,
             :NEW.FILE_NAME,
             :NEW.SEQ_NUM,
             :NEW.SCHEDULED_AT,
             :NEW.FILE_SOURCE,
             :NEW.FILE_TYPE,
             :NEW.STATUS,
             :NEW.STATUS_MSG,
             :NEW.COMMENT_TXT,
             :NEW.FILE_CONTENT,
             :NEW.CREATED_BY,
             :NEW.CREATED_AT,
             :NEW.UPDATED_BY,
             :NEW.UPDATED_AT,
             substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                        sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
             SYSDATE,
             v_opCode
       );
   ELSE
          INSERT INTO GEC_FILE_AUD(
             FILE_ID,
             REQUEST_ID,
             FILE_NAME,
             SEQ_NUM,
             SCHEDULED_AT,
             FILE_SOURCE,
             FILE_TYPE,
             STATUS,
             STATUS_MSG,
             COMMENT_TXT,
             FILE_CONTENT,
             CREATED_BY,
             CREATED_AT,
             UPDATED_BY,
             UPDATED_AT,
             LAST_UPDATED_BY,
             LAST_UPDATED_AT,
             OP_CODE
          )
       VALUES (
             DECODE(v_opCode, 'D', :OLD.FILE_ID, :NEW.FILE_ID),
             DECODE(v_opCode, 'D', :OLD.REQUEST_ID, :NEW.REQUEST_ID),
             DECODE(v_opCode, 'D', :OLD.FILE_NAME, :NEW.FILE_NAME),
             DECODE(v_opCode, 'D', :OLD.SEQ_NUM, :NEW.SEQ_NUM),
             DECODE(v_opCode, 'D', :OLD.SCHEDULED_AT, :NEW.SCHEDULED_AT),
             DECODE(v_opCode, 'D', :OLD.FILE_SOURCE, :NEW.FILE_SOURCE),
             DECODE(v_opCode, 'D', :OLD.FILE_TYPE, :NEW.FILE_TYPE),
             DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
             DECODE(v_opCode, 'D', :OLD.STATUS_MSG, :NEW.STATUS_MSG),
             DECODE(v_opCode, 'D', :OLD.COMMENT_TXT, :NEW.COMMENT_TXT),
             NULL,
             DECODE(v_opCode, 'D', :OLD.CREATED_BY, :NEW.CREATED_BY),
             DECODE(v_opCode, 'D', :OLD.CREATED_AT, :NEW.CREATED_AT),
             DECODE(v_opCode, 'D', :OLD.UPDATED_BY, :NEW.UPDATED_BY),
             DECODE(v_opCode, 'D', :OLD.UPDATED_AT, :NEW.UPDATED_AT),
             substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                        sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
             SYSDATE,
             v_opCode
       );
   END IF;


END GEC_FILE_TA;
/
