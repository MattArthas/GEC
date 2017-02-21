-------------------------------------------------------------------------
-- Copyright (c) 2011 State Street Corporation, 1 Lincoln st, Boston, MA
-- Global Market Technology
-- All rights reserved.
--
-- Date            Programmer                Notes
-- ------------    --------------------      ----------------------------
-- Dec 12, 2012    Zhao, Hong                The function will return max rates. Literal rates will be joint with max rates distinctly, eg: 3.9,GC.
-------------------------------------------------------------------------

CREATE OR REPLACE TYPE GEC_MAX_RATE_TP AS OBJECT
(
    CURRENTSTR VARCHAR2(1000),
    CURRENTSEPRATOR VARCHAR2(8), 

    --literal_rates will be added to the result directly
    LITERAL_RATES VARCHAR2(100),
    
    --MAX_RATE save the max number rate value
    MAX_RATE NUMBER(9,6),
    
    STATIC FUNCTION ODCIAGGREGATEINITIALIZE(SCTX IN OUT GEC_MAX_RATE_TP) RETURN NUMBER,

    MEMBER FUNCTION ODCIAGGREGATEITERATE(SELF IN OUT GEC_MAX_RATE_TP, 
                                         VALUE IN VARCHAR2
                                        ) RETURN NUMBER,

    MEMBER FUNCTION ODCIAGGREGATETERMINATE(SELF        IN GEC_MAX_RATE_TP, 
                                           RETURNVALUE OUT VARCHAR2, 
                                           FLAGS       IN NUMBER
                                           ) RETURN NUMBER,

    MEMBER FUNCTION ODCIAGGREGATEMERGE(SELF IN OUT GEC_MAX_RATE_TP, 
                                       CTX2 IN GEC_MAX_RATE_TP) RETURN NUMBER
  );
/

CREATE OR REPLACE TYPE BODY GEC_MAX_RATE_TP 
IS 
    STATIC FUNCTION ODCIAGGREGATEINITIALIZE(SCTX IN OUT GEC_MAX_RATE_TP) RETURN NUMBER IS 
    BEGIN
        SCTX := GEC_MAX_RATE_TP(CURRENTSTR => null, CURRENTSEPRATOR => ';', LITERAL_RATES => ',GC,999,', MAX_RATE => null);
        RETURN ODCICONST.SUCCESS;
    END;

    MEMBER FUNCTION ODCIAGGREGATEITERATE(SELF IN OUT GEC_MAX_RATE_TP, VALUE IN VARCHAR2) RETURN NUMBER IS
    	v_currentRate NUMBER(9,6);
    BEGIN
    	IF VALUE IS NOT NULL THEN
    		--if it is a literal rate, and it has not been added to result, then add it to result;
    		--if it is a literal rate, and it has been added to result, then ignore the value;
			IF INSTR(SELF.LITERAL_RATES, ','||VALUE||',') > 0 THEN
		        IF SELF.CURRENTSTR IS NULL THEN
		            SELF.CURRENTSTR := VALUE;
		        ELSIF INSTR(CURRENTSEPRATOR||SELF.CURRENTSTR||CURRENTSEPRATOR, CURRENTSEPRATOR||VALUE||CURRENTSEPRATOR) = 0 THEN
		            SELF.CURRENTSTR := SELF.CURRENTSTR ||CURRENTSEPRATOR || VALUE;
				ELSE
					RETURN ODCICONST.SUCCESS;
				END IF;
			ELSE
				v_currentRate := TO_NUMBER(VALUE);
				--if the value is number, and it is larger than the current max value, set it into the current max value, else ignore.
		        IF SELF.MAX_RATE IS NULL THEN
		            SELF.MAX_RATE := v_currentRate;
		        ELSIF v_currentRate > SELF.MAX_RATE THEN
		            SELF.MAX_RATE := v_currentRate;
				ELSE
					RETURN ODCICONST.SUCCESS;
				END IF;
			END IF;
    	END IF;
        RETURN ODCICONST.SUCCESS;
    EXCEPTION WHEN OTHERS THEN
    	--ignore any exception. Any non-number value except literal_rates will be ignored.
    	RETURN ODCICONST.SUCCESS;
    END;

    MEMBER FUNCTION ODCIAGGREGATETERMINATE(SELF IN GEC_MAX_RATE_TP, RETURNVALUE OUT VARCHAR2, FLAGS IN NUMBER) RETURN NUMBER IS
    	v_retStr VARCHAR2(1000);
    BEGIN
    	v_retStr := SELF.CURRENTSTR;
    	IF SELF.MAX_RATE IS NOT NULL THEN
	        IF v_retStr IS NULL THEN
	            v_retStr := TO_CHAR(SELF.MAX_RATE);
	        ELSE
	            v_retStr := v_retStr ||CURRENTSEPRATOR || TO_CHAR(SELF.MAX_RATE);
	        END IF;
    	END IF;
        RETURNVALUE := v_retStr;
        RETURN ODCICONST.SUCCESS;
    END;

    MEMBER FUNCTION ODCIAGGREGATEMERGE(SELF IN OUT GEC_MAX_RATE_TP, CTX2 IN GEC_MAX_RATE_TP) RETURN NUMBER IS
    BEGIN
        IF CTX2.CURRENTSTR IS NULL THEN
            SELF.CURRENTSTR := SELF.CURRENTSTR;
        ELSIF SELF.CURRENTSTR IS NULL THEN 
            SELF.CURRENTSTR := CTX2.CURRENTSTR;
        ELSE
            SELF.CURRENTSTR := SELF.CURRENTSTR || CURRENTSEPRATOR || CTX2.CURRENTSTR;
        END IF; 
            RETURN ODCICONST.SUCCESS;
    END;
END;
/
