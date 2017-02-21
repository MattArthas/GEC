CREATE OR REPLACE TRIGGER GEC_CONFIG_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         ATTR_GROUP,
         ATTR_NAME,
         ATTR_DATATYPE,
         ATTR_VALUE_TYPE,
         ATTR_VALUE1,
         ATTR_VALUE2,
         CONFIG_COMMENT
   ON GEC_CONFIG
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

   INSERT INTO GEC_CONFIG_AUD(
         ATTR_GROUP,
         ATTR_NAME,
         ATTR_DATATYPE,
         ATTR_VALUE_TYPE,
         ATTR_VALUE1,
         ATTR_VALUE2,
         CONFIG_COMMENT,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.ATTR_GROUP, :NEW.ATTR_GROUP),
         DECODE(v_opCode, 'D', :OLD.ATTR_NAME, :NEW.ATTR_NAME),
         DECODE(v_opCode, 'D', :OLD.ATTR_DATATYPE, :NEW.ATTR_DATATYPE),
         DECODE(v_opCode, 'D', :OLD.ATTR_VALUE_TYPE, :NEW.ATTR_VALUE_TYPE),
         DECODE(v_opCode, 'D', :OLD.ATTR_VALUE1, :NEW.ATTR_VALUE1),
         DECODE(v_opCode, 'D', :OLD.ATTR_VALUE2, :NEW.ATTR_VALUE2),
         DECODE(v_opCode, 'D', :OLD.CONFIG_COMMENT, :NEW.CONFIG_COMMENT),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_CONFIG_TA;
/

