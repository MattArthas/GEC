CREATE OR REPLACE TRIGGER GEC_USER_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         USER_ID,
         REGION_CD,
         CLIENT_ID,
         FIRST_NAME,
         LAST_NAME,
         PHONE,
         EMAIL,
         STATUS,
         APP_STATUS,
         APP_STATUS_DATE,
         CREATED_BY,
         CREATED_AT,
         EXPIRE_DATE,
         USER_REF_NUM,
         GL_PHONE,
         GL_EMAIL,
         ACCEPT_TERMS_FLAG,
         TRADING_DESK_CD
   ON GEC_USER
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

   INSERT INTO GEC_USER_AUD(
         USER_ID,
         REGION_CD,
         CLIENT_ID,
         FIRST_NAME,
         LAST_NAME,
         PHONE,
         EMAIL,
         STATUS,
         APP_STATUS,
         APP_STATUS_DATE,
         CREATED_BY,
         CREATED_AT,
         EXPIRE_DATE,
         USER_REF_NUM,
         GL_PHONE,
         GL_EMAIL,
         ACCEPT_TERMS_FLAG,
         TRADING_DESK_CD,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.USER_ID, :NEW.USER_ID),
         DECODE(v_opCode, 'D', :OLD.REGION_CD, :NEW.REGION_CD),
         DECODE(v_opCode, 'D', :OLD.CLIENT_ID, :NEW.CLIENT_ID),
         DECODE(v_opCode, 'D', :OLD.FIRST_NAME, :NEW.FIRST_NAME),
         DECODE(v_opCode, 'D', :OLD.LAST_NAME, :NEW.LAST_NAME),
         DECODE(v_opCode, 'D', :OLD.PHONE, :NEW.PHONE),
         DECODE(v_opCode, 'D', :OLD.EMAIL, :NEW.EMAIL),
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
         DECODE(v_opCode, 'D', :OLD.APP_STATUS, :NEW.APP_STATUS),
         DECODE(v_opCode, 'D', :OLD.APP_STATUS_DATE, :NEW.APP_STATUS_DATE),
         DECODE(v_opCode, 'D', :OLD.CREATED_BY, :NEW.CREATED_BY),
         DECODE(v_opCode, 'D', :OLD.CREATED_AT, :NEW.CREATED_AT),
         DECODE(v_opCode, 'D', :OLD.EXPIRE_DATE, :NEW.EXPIRE_DATE),
         DECODE(v_opCode, 'D', :OLD.USER_REF_NUM, :NEW.USER_REF_NUM),
         DECODE(v_opCode, 'D', :OLD.GL_PHONE, :NEW.GL_PHONE),
         DECODE(v_opCode, 'D', :OLD.GL_EMAIL, :NEW.GL_EMAIL),
         DECODE(v_opCode, 'D', :OLD.ACCEPT_TERMS_FLAG, :NEW.ACCEPT_TERMS_FLAG),
         DECODE(v_opCode, 'D', :OLD.TRADING_DESK_CD, :NEW.TRADING_DESK_CD),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_USER_TA;
/

