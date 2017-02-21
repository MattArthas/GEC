CREATE OR REPLACE TRIGGER GEC_USER_DATAGRID_PREF_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         USER_ID,
         DATAGRID_ID,
         COLUMN_ID,
         DISPLAY_WIDTH,
         VISIBLE_FLAG,
         DISPLAY_ORDER
   ON GEC_USER_DATAGRID_PREF
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

   INSERT INTO GEC_USER_DATAGRID_PREF_AUD(
         USER_ID,
         DATAGRID_ID,
         COLUMN_ID,
         DISPLAY_WIDTH,
         VISIBLE_FLAG,
         DISPLAY_ORDER,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.USER_ID, :NEW.USER_ID),
         DECODE(v_opCode, 'D', :OLD.DATAGRID_ID, :NEW.DATAGRID_ID),
         DECODE(v_opCode, 'D', :OLD.COLUMN_ID, :NEW.COLUMN_ID),
         DECODE(v_opCode, 'D', :OLD.DISPLAY_WIDTH, :NEW.DISPLAY_WIDTH),
         DECODE(v_opCode, 'D', :OLD.VISIBLE_FLAG, :NEW.VISIBLE_FLAG),
         DECODE(v_opCode, 'D', :OLD.DISPLAY_ORDER, :NEW.DISPLAY_ORDER),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_USER_DATAGRID_PREF_TA;
/

