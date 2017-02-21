CREATE OR REPLACE TRIGGER GEC_APPLICATION_PROPERTIES_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
   		PROP_GROUP,
        KEY,
		VALUE
   ON GEC_APPLICATION_PROPERTIES
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

   INSERT INTO GEC_APPLICATION_PROPERTIES_AUD(
   			PROP_GROUP,
         	KEY,
			VALUE,
  			LAST_UPDATED_BY,
  			LAST_UPDATED_AT,
         	OP_CODE
      )
   VALUES (
   		 DECODE(v_opCode, 'D', :OLD.PROP_GROUP, :NEW.PROP_GROUP),
         DECODE(v_opCode, 'D', :OLD.KEY, :NEW.KEY),
         DECODE(v_opCode, 'D', :OLD.VALUE, :NEW.VALUE),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_APPLICATION_PROPERTIES_TA;
/

