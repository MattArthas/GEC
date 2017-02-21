CREATE OR REPLACE TRIGGER GEC_TRADE_COUNTRY_ALIAS_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         TRADE_COUNTRY_ALIAS_CD,
         TRADE_COUNTRY_CD 
   ON GEC_TRADE_COUNTRY_ALIAS
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

   INSERT INTO GEC_TRADE_COUNTRY_ALIAS_AUD(
         TRADE_COUNTRY_ALIAS_CD,
         TRADE_COUNTRY_CD, 
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.TRADE_COUNTRY_ALIAS_CD, :NEW.TRADE_COUNTRY_ALIAS_CD),
         DECODE(v_opCode, 'D', :OLD.TRADE_COUNTRY_CD, :NEW.TRADE_COUNTRY_CD), 
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_TRADE_COUNTRY_ALIAS_TA;
/