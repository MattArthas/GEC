CREATE OR REPLACE TRIGGER GEC_TRADING_DESK_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         TRADING_DESK_ID,
         TRADING_DESK_CD,
         TRADING_DESK_NAME,
         PHONE,
         TRADE_COUNTRY_CD
   ON GEC_TRADING_DESK
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

   INSERT INTO GEC_TRADING_DESK_AUD(
         TRADING_DESK_ID,
         TRADING_DESK_CD,
         TRADING_DESK_NAME,
         PHONE,
         TRADE_COUNTRY_CD,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.TRADING_DESK_ID, :NEW.TRADING_DESK_ID),
         DECODE(v_opCode, 'D', :OLD.TRADING_DESK_CD, :NEW.TRADING_DESK_CD),
         DECODE(v_opCode, 'D', :OLD.TRADING_DESK_NAME, :NEW.TRADING_DESK_NAME),
         DECODE(v_opCode, 'D', :OLD.PHONE, :NEW.PHONE),
         DECODE(v_opCode, 'D', :OLD.TRADE_COUNTRY_CD, :NEW.TRADE_COUNTRY_CD),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_TRADING_DESK_TA;
/

