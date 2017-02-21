CREATE OR REPLACE TRIGGER GEC_HOLIDAY_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
   		 HOLIDAY_ID,
         TRADE_COUNTRY_CD,
         CALENDAR_DATE,
         CALENDAR_TYPE,
         DAY_TYPE,
         DESCRIPTION,
         UPDATED_BY,
         UPDATED_AT
   ON GEC_HOLIDAY
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

   INSERT INTO GEC_HOLIDAY_AUD(
         HOLIDAY_ID,
         TRADE_COUNTRY_CD,
         CALENDAR_DATE,
         CALENDAR_TYPE,
         DAY_TYPE,
         DESCRIPTION,
         UPDATED_BY,
         UPDATED_AT,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
   	     DECODE(v_opCode, 'D', :OLD.HOLIDAY_ID, :NEW.HOLIDAY_ID),
         DECODE(v_opCode, 'D', :OLD.TRADE_COUNTRY_CD, :NEW.TRADE_COUNTRY_CD),
         DECODE(v_opCode, 'D', :OLD.CALENDAR_DATE, :NEW.CALENDAR_DATE),
         DECODE(v_opCode, 'D', :OLD.CALENDAR_TYPE, :NEW.CALENDAR_TYPE),
         DECODE(v_opCode, 'D', :OLD.DAY_TYPE, :NEW.DAY_TYPE),
         DECODE(v_opCode, 'D', :OLD.DESCRIPTION, :NEW.DESCRIPTION),
         DECODE(v_opCode, 'D', :OLD.UPDATED_BY, :NEW.UPDATED_BY),
         DECODE(v_opCode, 'D', :OLD.UPDATED_AT, :NEW.UPDATED_AT),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_HOLIDAY_TA;
/

