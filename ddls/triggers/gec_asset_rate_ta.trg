CREATE OR REPLACE TRIGGER GEC_ASSET_RATE_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         ASSET_ID,
         ASSET_CODE,
         ASSET_CODE_TYPE,
         INDICATIVE_RATE,
         POSITION_FLAG,
         RESTRICTION_CD,
         TYPE,
         INTERNAL_COMMENT_TXT,
         STATUS,
         UPDATED_BY,
         UPDATED_AT
   ON GEC_ASSET_RATE
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

   INSERT INTO GEC_ASSET_RATE_AUD(
         ASSET_ID,
         ASSET_CODE,
         ASSET_CODE_TYPE,
         INDICATIVE_RATE,
         POSITION_FLAG,
         RESTRICTION_CD,
         TYPE,
         INTERNAL_COMMENT_TXT,
         STATUS,
         UPDATED_BY,
         UPDATED_AT,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.ASSET_ID, :NEW.ASSET_ID),
         DECODE(v_opCode, 'D', :OLD.ASSET_CODE, :NEW.ASSET_CODE),
         DECODE(v_opCode, 'D', :OLD.ASSET_CODE_TYPE, :NEW.ASSET_CODE_TYPE),
         DECODE(v_opCode, 'D', :OLD.INDICATIVE_RATE, :NEW.INDICATIVE_RATE),
         DECODE(v_opCode, 'D', :OLD.POSITION_FLAG, :NEW.POSITION_FLAG),
         DECODE(v_opCode, 'D', :OLD.RESTRICTION_CD, :NEW.RESTRICTION_CD),
         DECODE(v_opCode, 'D', :OLD.TYPE, :NEW.TYPE),
         DECODE(v_opCode, 'D', :OLD.INTERNAL_COMMENT_TXT, :NEW.INTERNAL_COMMENT_TXT),
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
         DECODE(v_opCode, 'D', :OLD.UPDATED_BY, :NEW.UPDATED_BY),
         DECODE(v_opCode, 'D', :OLD.UPDATED_AT, :NEW.UPDATED_AT),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_ASSET_RATE_TA;
/

