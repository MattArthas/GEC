CREATE OR REPLACE TRIGGER GEC_BENCHMARK_INDEX_RATE_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         BENCHMARK_INDEX_RATE_ID, 
         BENCHMARK_INDEX_CD, 
         RATE,
         CURRENCY_CD,
		 COLLATERAL_CURRENCY_CD,
		 STATUS,
		 COMMENT_TXT,
		 CREATED_BY,
		 CREATED_AT,
		 UPDATED_BY,
		 UPDATED_AT        
   ON GEC_BENCHMARK_INDEX_RATE
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

   INSERT INTO GEC_BENCHMARK_INDEX_RATE_AUD(
         BENCHMARK_INDEX_RATE_ID, 
         BENCHMARK_INDEX_CD, 
         RATE,
         CURRENCY_CD,
		 COLLATERAL_CURRENCY_CD,
		 STATUS,
		 COMMENT_TXT,
		 CREATED_BY,
		 CREATED_AT,
		 UPDATED_BY,
		 UPDATED_AT, 
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.BENCHMARK_INDEX_RATE_ID, :NEW.BENCHMARK_INDEX_RATE_ID), 
         DECODE(v_opCode, 'D', :OLD.BENCHMARK_INDEX_CD, :NEW.BENCHMARK_INDEX_CD), 
         DECODE(v_opCode, 'D', :OLD.RATE, :NEW.RATE),
         DECODE(v_opCode, 'D', :OLD.CURRENCY_CD, :NEW.CURRENCY_CD),
         DECODE(v_opCode, 'D', :OLD.COLLATERAL_CURRENCY_CD, :NEW.COLLATERAL_CURRENCY_CD),
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
         DECODE(v_opCode, 'D', :OLD.COMMENT_TXT, :NEW.COMMENT_TXT),
         DECODE(v_opCode, 'D', :OLD.CREATED_BY, :NEW.CREATED_BY),
         DECODE(v_opCode, 'D', :OLD.CREATED_AT, :NEW.CREATED_AT),
         DECODE(v_opCode, 'D', :OLD.UPDATED_BY, :NEW.UPDATED_BY),
         DECODE(v_opCode, 'D', :OLD.UPDATED_AT, :NEW.UPDATED_AT),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_BENCHMARK_INDEX_RATE_TA;
/