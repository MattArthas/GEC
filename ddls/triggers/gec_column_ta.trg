CREATE OR REPLACE TRIGGER GEC_COLUMN_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         COLUMN_ID,
         COLUMN_DESC,
         HEADER_TEXT,
         DISPLAY_WIDTH,
         SORTABLE_FLAG,
         MANDATORY_FLAG,
         MANAGE_FLAG
   ON GEC_COLUMN
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

   INSERT INTO GEC_COLUMN_AUD(
         COLUMN_ID,
         COLUMN_DESC,
         HEADER_TEXT,
         DISPLAY_WIDTH,
         SORTABLE_FLAG,
         MANDATORY_FLAG,
         MANAGE_FLAG,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.COLUMN_ID, :NEW.COLUMN_ID),
         DECODE(v_opCode, 'D', :OLD.COLUMN_DESC, :NEW.COLUMN_DESC),
         DECODE(v_opCode, 'D', :OLD.HEADER_TEXT, :NEW.HEADER_TEXT),
         DECODE(v_opCode, 'D', :OLD.DISPLAY_WIDTH, :NEW.DISPLAY_WIDTH),
         DECODE(v_opCode, 'D', :OLD.SORTABLE_FLAG, :NEW.SORTABLE_FLAG),
         DECODE(v_opCode, 'D', :OLD.MANDATORY_FLAG, :NEW.MANDATORY_FLAG),
         DECODE(v_opCode, 'D', :OLD.MANAGE_FLAG, :NEW.MANAGE_FLAG),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_COLUMN_TA;
/

