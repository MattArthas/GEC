CREATE OR REPLACE TRIGGER GEC_INDEX_RATE_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         INDEX_CD,
         INDEX_DATE,
         INDEX_RATE
   ON GEC_INDEX_RATE
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

   INSERT INTO GEC_INDEX_RATE_AUD(
         INDEX_CD,
         INDEX_DATE,
         INDEX_RATE,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.INDEX_CD, :NEW.INDEX_CD),
         DECODE(v_opCode, 'D', :OLD.INDEX_DATE, :NEW.INDEX_DATE),
         DECODE(v_opCode, 'D', :OLD.INDEX_RATE, :NEW.INDEX_RATE),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_INDEX_RATE_TA;
/

