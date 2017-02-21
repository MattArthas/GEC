CREATE OR REPLACE TRIGGER GEC_INDEX_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         INDEX_CD,
         INDEX_DESC,
         G1_INDEX_CD
   ON GEC_INDEX
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

   INSERT INTO GEC_INDEX_AUD(
         INDEX_CD,
         INDEX_DESC,
         G1_INDEX_CD,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.INDEX_CD, :NEW.INDEX_CD),
         DECODE(v_opCode, 'D', :OLD.INDEX_DESC, :NEW.INDEX_DESC),
         DECODE(v_opCode, 'D', :OLD.G1_INDEX_CD, :NEW.G1_INDEX_CD),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_INDEX_TA;
/

