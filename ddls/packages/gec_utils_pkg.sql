-------------------------------------------------------------------------
-- Copyright (c) 2009 State Street Bank and Trust Corp.
-- 225 Franklin Street, Boston, MA 02110, U.S.A.
-- All rights reserved.
--
-- "GEC_UTILS_PKG.sql is the copyrighted,
-- proprietary property of State Street Bank and Trust Company and its
-- subsidiaries and affiliates which retain all right, title and interest
-- therein."
--
-- Revision History
--
-- Date            Programmer                Notes
-- ------------    --------------------      ----------------------------
-- Sep  22, 2009    Jingzheng, Shang         initial
-- Apr  02, 2010    Zhao Hong                Add two functions: NUMBER_TO_DATE & DATE_TO_NUMBER
-------------------------------------------------------------------------
 
CREATE OR REPLACE PACKAGE GEC_UTILS_PKG
AS

	TYPE t_number_array IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
	
	TYPE T_CHAR_ARRAY IS VARRAY(36) OF CHAR;

	LETTER_ARRAY T_CHAR_ARRAY :=  T_CHAR_ARRAY('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z');

	FUNCTION GET_LOAN_NO_SEQ RETURN VARCHAR2;
    FUNCTION GET_CONTRACT_OWNER_NO_SEQ  RETURN VARCHAR2;
	
    FUNCTION FORMAT_G1_RATE( p_int_rate IN NUMBER	) RETURN VARCHAR2;

    FUNCTION FORMAT_DECIMAL(P_NUMBER NUMBER,P_POSITIVE_FORMAT VARCHAR2,NEGATIVE_FORMAT VARCHAR2) RETURN VARCHAR2;
        
    -- p_length must >0 , if p_lenght <=0, it will return ''
	-- if p_str is null, return null
    FUNCTION SUBRIGHT( p_str IN varchar2, p_length IN NUMBER	) RETURN VARCHAR2;

	--return 0: both b1 and b2 are null, or both are empty; or dbms_lob.compare(b1,b2,b1.length,1,1) = 0
	--  else return non-zero;
    function COMPARE_BLOB(b1 in blob, b2 in blob) return integer;
	
	-- return new comment	
    FUNCTION POPULATE_COMMENT( p_old_comment IN varchar2 ,p_source IN varchar2, p_err_msg IN varchar2) RETURN VARCHAR2;
	
	--From msaccess_utilities.right_
	FUNCTION RIGHT_(p_string VARCHAR2, p_length NUMBER) RETURN VARCHAR2;
 	
 	--From msaccess_utilities.substr_from_end
	FUNCTION SUBSTR_FROM_END(p_string VARCHAR2, p_length NUMBER, p_end NUMBER DEFAULT 1) RETURN VARCHAR2;
    
    --@p_date_str:date string
	--@p_date_format: date format
	--@p_from_timezone: from time zone, US/Eastern or -05:00
	--@p_to_timezone: to time zone, US/Eastern or -05:00
	FUNCTION TO_TIMEZONE(p_date_str VARCHAR2,p_date_format VARCHAR2,p_from_timezone VARCHAR2, p_to_timezone VARCHAR2 ) RETURN DATE;

	FUNCTION TO_TIMEZONE(p_date DATE,p_from_timezone VARCHAR2, p_to_timezone VARCHAR2 ) RETURN DATE;
	
	FUNCTION TO_CUTOFF_TIME(p_date DATE,p_from_timezone VARCHAR2, p_to_timezone VARCHAR2 ) RETURN VARCHAR2;
	FUNCTION IS_AFTER_CUTOFF_TIME(asset_id VARCHAR2) RETURN BOOLEAN;
	
	  FUNCTION FORMAT_CUTOFF_TO_HH24(p_cutoff_time VARCHAR2 ) RETURN VARCHAR2;
				
	FUNCTION TO_BOS_TIME( p_datetime_str VARCHAR2, p_from_timezone VARCHAR2) RETURN DATE;
 	--return a date by an 8-digit number such as 20100402
 	FUNCTION NUMBER_TO_DATE( P_NUMBER IN NUMBER ) RETURN DATE;
 	
 	--return an 8-digit number such as 20100402 by a date 'Apr 2, 2010'
 	FUNCTION DATE_TO_NUMBER( P_DATE IN DATE ) RETURN NUMBER;
 	 		
	FUNCTION MAX_NUMBER(p_number_1 IN NUMBER, p_number_2 IN NUMBER)RETURN NUMBER;
	
	FUNCTION SUB_COMMENT( p_COMMENT VARCHAR2) RETURN VARCHAR2;
	--convert number to char
	FUNCTION NUMBER_TO_CHAR( p_number IN NUMBER) RETURN VARCHAR2;
	
	FUNCTION DATE_STR_FROM_TO(p_from_date VARCHAR2,p_from_format VARCHAR2,p_to_format VARCHAR2) RETURN VARCHAR2;
	
	--P_COUNTRY_CD: The trade country code of gec_holiday table, eg: 'US'. Default to 'ALL' -- no holiday.
	--P_CALENDAR_TYPE: T-rading calendar, S-ettlement(bank) calendar. Default to 'T'.
	FUNCTION IS_WORKDAY(P_CALENDAR_DATE IN DATE,
						P_COUNTRY_CD  IN VARCHAR2 := 'ALL',
						P_CALENDAR_TYPE IN VARCHAR2 := 'T'
						) RETURN VARCHAR2;

	--P_COUNTRY_CD: The trade country code of gec_holiday table, eg: 'US'. Default to 'ALL' -- no holiday.
	--P_CALENDAR_TYPE: T-rading calendar, S-ettlement(bank) calendar. Default to 'T'.
	--Return: if P_TDATE is non-working day, return P_TDATE for T+0
	FUNCTION GET_TPLUSN(P_TDATE IN DATE,
						P_NDAYS IN NUMBER,
						P_COUNTRY_CD  IN VARCHAR2 := 'ALL',
						P_CALENDAR_TYPE IN VARCHAR2 := 'T'
						) RETURN DATE;
	
	FUNCTION GET_TPLUSN_NUM(P_TDATE IN NUMBER,
							P_NDAYS IN NUMBER,
							P_COUNTRY_CD  IN VARCHAR2 := 'ALL',
							P_CALENDAR_TYPE IN VARCHAR2 := 'T'
							) RETURN NUMBER;
	
	--P_COUNTRY_CD: The trade country code of gec_holiday table, eg: 'US'. Default to 'ALL' -- no holiday.
	--P_CALENDAR_TYPE: T-rading calendar, S-ettlement(bank) calendar. Default to 'T'.
	--Return: if P_TDATE is non-working day, return P_TDATE for T-0
	FUNCTION GET_TMINUSN(P_TDATE IN DATE,
						 P_NDAYS IN NUMBER,
						 P_COUNTRY_CD  IN VARCHAR2 := 'ALL',
						 P_CALENDAR_TYPE IN VARCHAR2 := 'T'
						 ) RETURN DATE;
						 
	FUNCTION GET_TMINUSN_TO(P_TDATE IN DATE,
						 P_NDAYS IN NUMBER,
						 P_COUNTRY_CD  IN VARCHAR2 := 'ALL',
						 P_CALENDAR_TYPE IN VARCHAR2 := 'T'
						 ) RETURN DATE;

	FUNCTION GET_TMINUSN_NUM(P_TDATE IN NUMBER,
							P_NDAYS IN NUMBER,
							P_COUNTRY_CD  IN VARCHAR2 := 'ALL',
							P_CALENDAR_TYPE IN VARCHAR2 := 'T'
							) RETURN NUMBER;
							
	FUNCTION GET_TMINUSN_NUM_TO(P_TDATE IN NUMBER,
							P_NDAYS IN NUMBER,
							P_COUNTRY_CD  IN VARCHAR2 := 'ALL',
							P_CALENDAR_TYPE IN VARCHAR2 := 'T'
							) RETURN NUMBER;
						 
	FUNCTION SPLIT_TO_NUMBER_ARRAY(p_in_string 	IN VARCHAR2, 
								   p_delim 		IN VARCHAR2:= ',')RETURN t_number_array;

	PROCEDURE LOAD_SETTLE_DATES(p_settleDt in NUMERIC,p_settleDt1 out NUMERIC,p_settleDt2 out NUMERIC,p_settleDt3 out NUMERIC,p_settleDt4 out NUMERIC,p_settleDt5 out NUMERIC,p_settleDt6 out NUMERIC);
	PROCEDURE LOAD_CANCEL_DATES(p_clientTime in NUMERIC,p_cancelDate1 out NUMERIC,p_cancelDate2 out NUMERIC,p_cancelDate3 out NUMERIC,p_cancelDate4 out NUMERIC);
	FUNCTION CALCULATE_PRICE_BY_IM_ORDER_ID(P_GEC_IM_ORDER IN GEC_IM_ORDER.IM_ORDER_ID%TYPE) RETURN GEC_ASSET.CLEAN_PRICE%TYPE;
	--GMBH
	FUNCTION  check_fund_strategy_Mapping(fundInput IN VARCHAR2,legalEntityInput IN VARCHAR2) RETURN VARCHAR2;
	FUNCTION  CALCULATE_PRICE_BY_ASSET_ID(p_assest_id IN GEC_ASSET.ASSET_ID%TYPE,
										  p_broker_cd IN GEC_BROKER.BROKER_CD%TYPE,
										  p_collateral_currency_cd	GEC_BROKER.COLLATERAL_CURRENCY_CD%TYPE,
										  p_collateral_type	 GEC_BROKER.COLLATERAL_TYPE%TYPE)  RETURN VARCHAR2;
END GEC_UTILS_PKG;
/

CREATE OR REPLACE PACKAGE BODY GEC_UTILS_PKG
AS

	FUNCTION GET_LOAN_NO_SEQ RETURN VARCHAR2
	IS
		v_remaining_seq number(38);
		v_combination_num number(38) := 9999999999; 
		v_letter_num number(3) :=36;
		v_test number(3);
	BEGIN
		SELECT MOD(GEC_LINK_REF_SEQ.NEXTVAL,v_combination_num) into v_remaining_seq from dual;
			
		return LETTER_ARRAY( MOD(TRUNC(v_remaining_seq/(v_letter_num*v_letter_num*v_letter_num*v_letter_num*v_letter_num)),v_letter_num)+1)||LETTER_ARRAY(MOD(TRUNC(v_remaining_seq/(v_letter_num*v_letter_num*v_letter_num*v_letter_num)),v_letter_num)+1)||LETTER_ARRAY(MOD(TRUNC(v_remaining_seq/(v_letter_num*v_letter_num*v_letter_num)),v_letter_num)+1)||LETTER_ARRAY(MOD(TRUNC(v_remaining_seq/(v_letter_num*v_letter_num)),v_letter_num)+1)||LETTER_ARRAY(MOD(TRUNC(v_remaining_seq/v_letter_num),v_letter_num)+1)||LETTER_ARRAY(MOD(v_remaining_seq,v_letter_num)+1);
			
	END GET_LOAN_NO_SEQ;
	FUNCTION GET_CONTRACT_OWNER_NO_SEQ  RETURN VARCHAR2
	IS
    seq number(38);
	BEGIN
    select GEC_CONTRACT_OWNER_SEQ.NEXTVAL into seq from dual;
    return seq||'';
	END GET_CONTRACT_OWNER_NO_SEQ;
	
    FUNCTION FORMAT_G1_RATE ( p_int_rate IN NUMBER	) RETURN VARCHAR2
    IS
    BEGIN
		if (p_int_rate >= 0) then
			return replace( to_char(p_int_rate, 'FM000.000000'),'.',''); 	
		else
			return replace( to_char(p_int_rate, 'FM00.000000'),'.',''); 		
		end if;
    END FORMAT_G1_RATE;
    
    FUNCTION FORMAT_DECIMAL(P_NUMBER NUMBER,P_POSITIVE_FORMAT VARCHAR2,NEGATIVE_FORMAT VARCHAR2) RETURN VARCHAR2
    IS
    BEGIN
    
 		if (P_NUMBER >= 0) then
			return replace( to_char(P_NUMBER, P_POSITIVE_FORMAT),'.',''); 	
		else
			return replace( to_char(P_NUMBER, NEGATIVE_FORMAT),'.',''); 		
		end if;
		   
    END FORMAT_DECIMAL;
    
	FUNCTION IS_AFTER_CUTOFF_TIME(asset_id VARCHAR2) RETURN BOOLEAN
	IS
		VAR_TO_TIMEZONE GEC_TRADE_COUNTRY.LOCALE%TYPE;
		VAR_FROM_TIMEZONE  GEC_TRADE_COUNTRY.LOCALE%TYPE;
		VAR_CUTOFF_TIME GEC_TRADE_COUNTRY.CUTOFF_TIME%TYPE;
		VAR_CUR_DATESTR VARCHAR2(100);
        VAR_DATE DATE;
        VAR_ASSET_ID GEC_ASSET.ASSET_ID%TYPE;
	BEGIN
		IF asset_id IS NOT NULL THEN 
           BEGIN  
           		VAR_FROM_TIMEZONE := 'AMERICA/NEW_YORK';
           		VAR_ASSET_ID :=asset_id;
                SELECT DISTINCT GTC.LOCALE,GTC.CUTOFF_TIME INTO VAR_TO_TIMEZONE,VAR_CUTOFF_TIME
                FROM GEC_TRADE_COUNTRY GTC
                INNER JOIN GEC_ASSET GA
                ON GA.TRADE_COUNTRY_CD = GTC.TRADE_COUNTRY_CD
                WHERE GA.ASSET_ID = VAR_ASSET_ID;
                VAR_CUR_DATESTR := GEC_UTILS_PKG.NUMBER_TO_CHAR(GEC_UTILS_PKG.DATE_TO_NUMBER(GEC_UTILS_PKG.TO_TIMEZONE( SYSDATE ,VAR_FROM_TIMEZONE , VAR_TO_TIMEZONE))) || VAR_CUTOFF_TIME;
                VAR_DATE := GEC_UTILS_PKG.TO_BOS_TIME(VAR_CUR_DATESTR, VAR_TO_TIMEZONE);
                IF VAR_DATE < SYSDATE THEN
                   return true;
                END IF;
                return false;
                EXCEPTION 
                   WHEN NO_DATA_FOUND THEN
                        return true;
           END;
        END IF;
	END IS_AFTER_CUTOFF_TIME;
	
    FUNCTION SUBRIGHT (  p_str IN varchar2, p_length IN NUMBER	) RETURN VARCHAR2
    IS
    BEGIN    
	    CASE
	      WHEN p_str IS NULL THEN RETURN NULL;
	      WHEN p_length < 1 THEN RETURN '';
	      ELSE RETURN substr(p_str,  (case when (length(p_str) - p_length + 1)>0 then length(p_str) - p_length + 1 else 0 end),p_length);
	    END CASE;  
    END SUBRIGHT;	
    	
    function COMPARE_BLOB(b1 in blob, b2 in blob)
	    return integer
	as
	    v_length1 number(10);
	    v_length2 number(10);
	begin
	    if b1 is null and b2 is null then
	        return 0;
	    end if;
	    
	    if b1 is not null and b2 is not null then
	        v_length1 := dbms_lob.getlength(b1);
	        v_length2 := dbms_lob.getlength(b2);
	        if v_length1 = 0 and v_length2 = 0 then
	            return 0;
	        elsif v_length1 != v_length2 then
	            return 1;
	        else
	            return dbms_lob.compare(b1, b2, dbms_lob.getlength(b1), 1, 1);
	        end if;
	    else
	        return 1;
	    end if;
	end COMPARE_BLOB;

    FUNCTION POPULATE_COMMENT( 
    							p_old_comment IN varchar2 ,
    							p_source IN varchar2, 
    							p_err_msg IN varchar2
    							) 
    RETURN VARCHAR2
    IS
    BEGIN
    	-- If it is from API , it needs to append gec_constants_pkg.C_COMMENT_HEAD.
    	IF p_source IS NOT NULL AND p_source = gec_constants_pkg.C_API_LOCATE THEN
    		RETURN p_old_comment || ' ' || gec_constants_pkg.C_COMMENT_HEAD || p_err_msg;
    	ELSE
    		RETURN p_old_comment || ' ' || p_err_msg;
    	END IF;		   
    END POPULATE_COMMENT;

	FUNCTION RIGHT_(p_string VARCHAR2, p_length NUMBER)
	RETURN VARCHAR2
	IS
		BEGIN
		    RETURN substr_from_end(p_string, p_length, -p_length);
		EXCEPTION
		    WHEN OTHERS THEN
		      raise_application_error(-20000, DBMS_UTILITY.FORMAT_ERROR_STACK);
	END RIGHT_;	
	
	FUNCTION SUBSTR_FROM_END(p_string VARCHAR2, p_length NUMBER, p_end NUMBER DEFAULT 1)
	RETURN VARCHAR2
	IS
	BEGIN
	    CASE
	      WHEN p_string IS NULL THEN RETURN NULL;
	      WHEN p_length = 0 THEN RETURN '';
	      WHEN ABS(p_length) > LENGTH(p_string) THEN RETURN p_string;
	      ELSE RETURN SUBSTR(p_string, p_end, p_length);
	    END CASE;
	EXCEPTION
	    WHEN OTHERS THEN
	      raise_application_error(-20000, DBMS_UTILITY.FORMAT_ERROR_STACK);
	END SUBSTR_FROM_END;

	FUNCTION TO_TIMEZONE(p_date_str VARCHAR2,p_date_format VARCHAR2,p_from_timezone VARCHAR2, p_to_timezone VARCHAR2 ) 
	RETURN DATE
	IS
	BEGIN
		   return cast(  from_tz( to_timestamp(p_date_str, p_date_format) ,p_from_timezone ) at time zone p_to_timezone as date);        
		EXCEPTION
		    WHEN OTHERS THEN
		    RETURN NULL;
	END TO_TIMEZONE;


	FUNCTION TO_TIMEZONE(p_date DATE,p_from_timezone VARCHAR2, p_to_timezone VARCHAR2 )
	RETURN DATE
	IS
	BEGIN
		   return cast(  from_tz(to_timestamp(p_date), p_from_timezone) at time zone p_to_timezone as date);        
		EXCEPTION
		    WHEN OTHERS THEN
		    RETURN NULL;
	END TO_TIMEZONE;	
 	
	FUNCTION TO_BOS_TIME( p_datetime_str VARCHAR2, p_from_timezone VARCHAR2)
	RETURN DATE
	IS
	BEGIN
		RETURN cast(  from_tz( to_timestamp(p_datetime_str, 'YYYYMMDDHH:MIAM') , p_from_timezone) at time zone gec_constants_pkg.C_BOS_TIMEZONE as date);
	END TO_BOS_TIME;
	
 	FUNCTION NUMBER_TO_DATE( P_NUMBER IN NUMBER ) RETURN DATE
 	IS
 		V_DATE DATE;
 	BEGIN
 		IF P_NUMBER = 0 OR P_NUMBER IS NULL THEN
 			V_DATE := NULL;
 		ELSE
	 		V_DATE := TO_DATE( TO_CHAR(P_NUMBER), 'YYYYMMDD' );
 		END IF;
 		RETURN V_DATE;
 	EXCEPTION WHEN OTHERS THEN
 		RETURN NULL;
 	END NUMBER_TO_DATE;

 	FUNCTION DATE_TO_NUMBER( P_DATE IN DATE ) RETURN NUMBER
 	IS
 		V_NUMBER NUMBER(8);
 	BEGIN
 		IF P_DATE IS NULL OR P_DATE IS NULL THEN
 			V_NUMBER := NULL;
 		ELSE
	 		V_NUMBER := TO_NUMBER( TO_CHAR(P_DATE, 'YYYYMMDD') );
 		END IF;
 		RETURN V_NUMBER;
 	END DATE_TO_NUMBER;
 	
 	FUNCTION MAX_NUMBER(p_number_1 IN NUMBER, p_number_2 IN NUMBER) RETURN NUMBER
    IS
    BEGIN
      IF p_number_1 IS NULL THEN
        RETURN p_number_2;
      END IF;
      IF p_number_2 IS NULL THEN
        RETURN p_number_1;
      END IF;
      IF p_number_1 < p_number_2 THEN    	
        RETURN p_number_2;
      ELSE 
        RETURN p_number_1;
      END IF;
    END MAX_NUMBER;
    
    FUNCTION TO_CUTOFF_TIME(p_date DATE,p_from_timezone VARCHAR2, p_to_timezone VARCHAR2 ) RETURN VARCHAR2
    IS
    BEGIN
    	return to_char(to_timezone(p_date,p_from_timezone, p_to_timezone),'hh24:Mi:ss');
    
    END TO_CUTOFF_TIME;
    
    FUNCTION FORMAT_CUTOFF_TO_HH24(p_cutoff_time VARCHAR2 ) RETURN VARCHAR2
    IS
    BEGIN
    	--'HH:MIAM': is current date format for cutoff time set in trade country
		--'HH24:Mi:SS': use date string of this format to compare
    	RETURN  to_char( to_date(p_cutoff_time,'HH:MIAM'),'HH24:Mi:SS');   
    END FORMAT_CUTOFF_TO_HH24;
    
	FUNCTION SUB_COMMENT( p_COMMENT VARCHAR2) RETURN VARCHAR2
	IS
	BEGIN
		RETURN SUBSTR(p_COMMENT,1,GEC_CONSTANTS_PKG.C_COMMENT_LENTH);
	END SUB_COMMENT;

	FUNCTION NUMBER_TO_CHAR( p_number IN NUMBER) RETURN VARCHAR2
	IS
		v_foramtFee VARCHAR2(100);	
	BEGIN
		IF p_number = 0 THEN		
			RETURN '0';
		END IF;
		
		IF Sign(Abs(p_number) - 1) = -1 THEN
			IF Sign(p_number) = -1 THEN
				v_foramtFee := '-0' ||Substr(To_char(p_number),2);
			ELSE
				v_foramtFee := '0' ||To_char(p_number);
			END IF;
		ELSE
			v_foramtFee := To_char(p_number);
		END IF;		
		
		RETURN v_foramtFee;
	END NUMBER_TO_CHAR;		
	
	FUNCTION DATE_STR_FROM_TO(p_from_date VARCHAR2,p_from_format VARCHAR2,p_to_format VARCHAR2) RETURN VARCHAR2
	IS
	BEGIN
		return to_char(to_date(p_from_date, p_from_format),p_to_format);	
	END;
 	
 	--
	FUNCTION IS_WORKDAY(P_CALENDAR_DATE IN DATE,
						P_COUNTRY_CD  IN VARCHAR2 := 'ALL',
						P_CALENDAR_TYPE IN VARCHAR2 := 'T'
						) RETURN VARCHAR2
	IS
		V_IS_HOLIDAY VARCHAR2(1) := 'N';
		V_CALENDAR_DATE DATE := TRUNC(P_CALENDAR_DATE);
	BEGIN
		--Sun is 1, Sat is 7
		IF TO_CHAR(V_CALENDAR_DATE, 'D') != '1' AND TO_CHAR(V_CALENDAR_DATE, 'D') != '7' THEN
			BEGIN
				SELECT 'Y' INTO V_IS_HOLIDAY
				  FROM GEC_HOLIDAY
				 WHERE CALENDAR_DATE = V_CALENDAR_DATE
				   AND TRADE_COUNTRY_CD = P_COUNTRY_CD
				   AND CALENDAR_TYPE = P_CALENDAR_TYPE;
			EXCEPTION WHEN NO_DATA_FOUND THEN
				V_IS_HOLIDAY := 'N';
			END;
			IF V_IS_HOLIDAY = 'N' THEN
				RETURN 'Y';
			END IF;
		END IF;
		RETURN 'N';
	END IS_WORKDAY;

	FUNCTION GET_TPLUSN(P_TDATE IN DATE,
						P_NDAYS IN NUMBER,
						P_COUNTRY_CD  IN VARCHAR2 := 'ALL',
						P_CALENDAR_TYPE IN VARCHAR2 := 'T'
						) RETURN DATE
	IS
		V_MDATE DATE := TRUNC(P_TDATE);
	BEGIN
		--TODO: validate input parameters, and raise user defined exceptions

		FOR V_DAYS IN 1..P_NDAYS
		LOOP
			V_MDATE := V_MDATE + 1;
			WHILE IS_WORKDAY(V_MDATE, P_COUNTRY_CD, P_CALENDAR_TYPE) = 'N'
			LOOP
				V_MDATE := V_MDATE + 1;
			END LOOP;
		END LOOP;
		RETURN V_MDATE;
	END GET_TPLUSN;

	FUNCTION GET_TPLUSN_NUM(P_TDATE IN NUMBER,
							P_NDAYS IN NUMBER,
							P_COUNTRY_CD  IN VARCHAR2 := 'ALL',
							P_CALENDAR_TYPE IN VARCHAR2 := 'T'
							) RETURN NUMBER
	IS
		V_TDATE DATE;
		V_RET_DATE DATE;
	BEGIN
		V_TDATE := NUMBER_TO_DATE(P_TDATE);
		V_RET_DATE := GET_TPLUSN(V_TDATE, P_NDAYS, P_COUNTRY_CD, P_CALENDAR_TYPE);
		RETURN DATE_TO_NUMBER(V_RET_DATE);
	END GET_TPLUSN_NUM;
	
	FUNCTION GET_TMINUSN(P_TDATE IN DATE,
						 P_NDAYS IN NUMBER,
						 P_COUNTRY_CD  IN VARCHAR2 := 'ALL',
						 P_CALENDAR_TYPE IN VARCHAR2 := 'T'
						 ) RETURN DATE
	IS
		V_MDATE DATE := TRUNC(P_TDATE);
	BEGIN
		--TODO: validate input parameters, and raise user defined exceptions

		FOR V_DAYS IN 1..P_NDAYS
		LOOP
			V_MDATE := V_MDATE - 1;
			WHILE IS_WORKDAY(V_MDATE, P_COUNTRY_CD, P_CALENDAR_TYPE) = 'N'
			LOOP
				V_MDATE := V_MDATE - 1;
			END LOOP;
		END LOOP;
		RETURN V_MDATE;
	END GET_TMINUSN;
	
	FUNCTION GET_TMINUSN_TO(P_TDATE IN DATE,
						 P_NDAYS IN NUMBER,
						 P_COUNTRY_CD  IN VARCHAR2 := 'ALL',
						 P_CALENDAR_TYPE IN VARCHAR2 := 'T'
						 ) RETURN DATE
	IS
		V_MDATE DATE := TRUNC(P_TDATE);
	BEGIN
		--TODO: validate input parameters, and raise user defined exceptions

		FOR V_DAYS IN 1..P_NDAYS
		LOOP
			V_MDATE := V_MDATE + 1;
			WHILE IS_WORKDAY(V_MDATE, P_COUNTRY_CD, P_CALENDAR_TYPE) = 'N'
			LOOP
				V_MDATE := V_MDATE + 1;
			END LOOP;
		END LOOP;
		RETURN V_MDATE;
	END GET_TMINUSN_TO;
	
	FUNCTION GET_TMINUSN_NUM(P_TDATE IN NUMBER,
							P_NDAYS IN NUMBER,
							P_COUNTRY_CD  IN VARCHAR2 := 'ALL',
							P_CALENDAR_TYPE IN VARCHAR2 := 'T'
							) RETURN NUMBER
	IS
		V_TDATE DATE;
		V_RET_DATE DATE;
	BEGIN
		V_TDATE := NUMBER_TO_DATE(P_TDATE);
		V_RET_DATE := GET_TMINUSN(V_TDATE, P_NDAYS, P_COUNTRY_CD, P_CALENDAR_TYPE);
		RETURN DATE_TO_NUMBER(V_RET_DATE);
	END GET_TMINUSN_NUM;
	
	FUNCTION GET_TMINUSN_NUM_TO(P_TDATE IN NUMBER,
							P_NDAYS IN NUMBER,
							P_COUNTRY_CD  IN VARCHAR2 := 'ALL',
							P_CALENDAR_TYPE IN VARCHAR2 := 'T'
							) RETURN NUMBER
	IS
		V_TDATE DATE;
		V_RET_DATE DATE;
	BEGIN
		V_TDATE := NUMBER_TO_DATE(P_TDATE);
		V_RET_DATE := GET_TMINUSN_TO(V_TDATE, P_NDAYS, P_COUNTRY_CD, P_CALENDAR_TYPE);
		RETURN DATE_TO_NUMBER(V_RET_DATE);
	END GET_TMINUSN_NUM_TO;

	FUNCTION SPLIT_TO_NUMBER_ARRAY(p_in_string 	IN VARCHAR2, 
								   p_delim 		IN VARCHAR2:= ',')RETURN t_number_array
	IS
		i       NUMBER :=0; 
      	pos     NUMBER :=0; 
      pos_begin NUMBER :=1;
      temp_string VARCHAR2(50);
      	n_array t_number_array; 
	BEGIN
		-- determine first chuck of string   
      	pos := instr(p_in_string,p_delim,pos_begin,1); 
    
    	-- while there are chunks left, loop  
    	WHILE(pos > 0) LOOP
    		-- increment counter
    		i := i + 1;
        temp_string := substr(p_in_string,pos_begin,pos-pos_begin);
        DBMS_OUTPUT.put_LINE(temp_string);
    		n_array(i) := to_number(temp_string);
        pos_begin := pos+1;
    		pos := instr(p_in_string,p_delim,pos_begin,1);
    	END LOOP;
    	
    	--IF There is left String, add to n_array
    	IF LENGTH(p_in_string) > 0 THEN
        temp_string := substr(p_in_string,pos_begin);
        DBMS_OUTPUT.put_LINE(temp_string);
    		n_array(i+1) := to_number(temp_string);
    	END IF;
      
      -- return array  
      RETURN n_array;
	END SPLIT_TO_NUMBER_ARRAY;

  PROCEDURE LOAD_SETTLE_DATES(p_settleDt in NUMERIC,p_settleDt1 out NUMERIC,p_settleDt2 out NUMERIC,p_settleDt3 out NUMERIC,p_settleDt4 out NUMERIC,p_settleDt5 out NUMERIC,p_settleDt6 out NUMERIC)
	 IS
    p_settleDt_temp DATE := NUMBER_TO_DATE(p_settleDt);
  begin
  	IF IS_WORKDAY(p_settleDt_temp) = 'Y' THEN
        p_settleDt1 := p_settleDt;
        p_settleDt2 := DATE_TO_NUMBER(GET_TPLUSN(p_settleDt_temp,1));
        p_settleDt3 := DATE_TO_NUMBER(GET_TPLUSN(p_settleDt_temp,2));
        p_settleDt4 := DATE_TO_NUMBER(GET_TPLUSN(p_settleDt_temp,3));
        p_settleDt5 := DATE_TO_NUMBER(GET_TPLUSN(p_settleDt_temp,4));
        p_settleDt6 := DATE_TO_NUMBER(GET_TPLUSN(p_settleDt_temp,5));
    ELSE 
        p_settleDt1 := DATE_TO_NUMBER(GET_TPLUSN(p_settleDt_temp,1));
        p_settleDt2 := DATE_TO_NUMBER(GET_TPLUSN(p_settleDt_temp,2));
        p_settleDt3 := DATE_TO_NUMBER(GET_TPLUSN(p_settleDt_temp,3));
        p_settleDt4 := DATE_TO_NUMBER(GET_TPLUSN(p_settleDt_temp,4));
        p_settleDt5 := DATE_TO_NUMBER(GET_TPLUSN(p_settleDt_temp,5));
        p_settleDt6 := DATE_TO_NUMBER(GET_TPLUSN(p_settleDt_temp,6));
    END IF;
  END LOAD_SETTLE_DATES;
  
    PROCEDURE LOAD_CANCEL_DATES(p_clientTime in NUMERIC,p_cancelDate1 out NUMERIC,p_cancelDate2 out NUMERIC,p_cancelDate3 out NUMERIC,p_cancelDate4 out NUMERIC)
  IS
  	p_settleDt_temp DATE := NUMBER_TO_DATE(p_clientTime);
  begin
  	IF IS_WORKDAY(p_settleDt_temp) = 'Y' THEN
        p_cancelDate1 := p_clientTime;
        p_cancelDate2 := DATE_TO_NUMBER(GET_TMINUSN(p_settleDt_temp,1));
        p_cancelDate3 := DATE_TO_NUMBER(GET_TMINUSN(p_settleDt_temp,2));
        p_cancelDate4 := DATE_TO_NUMBER(GET_TMINUSN(p_settleDt_temp,3));
    ELSE 
        p_cancelDate1 := DATE_TO_NUMBER(GET_TMINUSN(p_settleDt_temp,1));
        p_cancelDate2 := DATE_TO_NUMBER(GET_TMINUSN(p_settleDt_temp,2));
        p_cancelDate3 := DATE_TO_NUMBER(GET_TMINUSN(p_settleDt_temp,3));
        p_cancelDate4 := DATE_TO_NUMBER(GET_TMINUSN(p_settleDt_temp,4));
    END IF;
  END LOAD_CANCEL_DATES;
  
  FUNCTION CALCULATE_PRICE_BY_IM_ORDER_ID(P_GEC_IM_ORDER IN GEC_IM_ORDER.IM_ORDER_ID%TYPE) RETURN GEC_ASSET.CLEAN_PRICE%TYPE
  IS
      V_CLEAN_PRICE     GEC_ASSET.CLEAN_PRICE%TYPE;
      V_DIRTY_PRICE     GEC_ASSET.DIRTY_PRICE%TYPE;
      V_ASSET_TYPE_ID   GEC_ASSET.ASSET_TYPE_ID%TYPE;
      V_PRICE          GEC_ASSET.CLEAN_PRICE%TYPE;
      V_COLLATERAL_PERCENTAGE GEC_BROKER.US_COLLATERAL_PERCENTAGE%TYPE;
  BEGIN
      IF P_GEC_IM_ORDER IS NOT NULL THEN
          SELECT GA.CLEAN_PRICE, GA.DIRTY_PRICE,GA.ASSET_TYPE_ID INTO V_CLEAN_PRICE,V_DIRTY_PRICE,V_ASSET_TYPE_ID
          FROM GEC_ASSET GA
          INNER JOIN GEC_IM_ORDER GIO
          ON GA.ASSET_ID = GIO.ASSET_ID
          WHERE GIO.IM_ORDER_ID = P_GEC_IM_ORDER;
          
          SELECT GB.US_COLLATERAL_PERCENTAGE INTO V_COLLATERAL_PERCENTAGE
          FROM GEC_FUND GF
          INNER JOIN GEC_IM_ORDER GIO
          ON GF.FUND_CD = GIO.FUND_CD  
          INNER JOIN GEC_BROKER GB
          ON GB.BROKER_CD = GF.DML_NSB_BROKER
          WHERE GIO.IM_ORDER_ID = P_GEC_IM_ORDER;
          
         IF V_ASSET_TYPE_ID = 4 THEN
             V_PRICE := V_CLEAN_PRICE*V_COLLATERAL_PERCENTAGE;
         ELSE
             V_PRICE := (V_CLEAN_PRICE*V_COLLATERAL_PERCENTAGE) +(V_DIRTY_PRICE-V_CLEAN_PRICE);
         END IF;
         V_PRICE :=CEIL(V_PRICE/0.25)*0.25;
         RETURN V_PRICE;
      END IF;
  EXCEPTION 
      WHEN NO_DATA_FOUND THEN
          RETURN 0;
  END CALCULATE_PRICE_BY_IM_ORDER_ID;
  FUNCTION  check_fund_strategy_Mapping(fundInput IN VARCHAR2, legalEntityInput IN VARCHAR2) RETURN VARCHAR2
  IS
     client_id_val VARCHAR2(32);
     strategy_id_val NUMBER;
 	 return_val VARCHAR2(1);
 	 
     cursor strategycur  
         is
       SELECT 
              fund.fund_cd, 
              fund.LEGAL_ENTITY_CD
         FROM GEC_STRATEGY st
         LEFT JOIN GEC_FUND fund ON 
              st.STRATEGY_ID = fund.STRATEGY_ID
         WHERE st.CLIENT_ID = client_id_val
           AND st.STRATEGY_ID= strategy_id_val
           AND st.STATUS != 'D';
      
 BEGIN
 	return_val := 'Y';
   Begin
 	    SELECT 
         st.STRATEGY_ID,st.CLIENT_ID into strategy_id_val,client_id_val
         FROM  
         GEC_STRATEGY st
       	LEFT JOIN  GEC_CLIENT c
     	 on st.CLIENT_ID=c.CLIENT_ID
         LEFT JOIN  GEC_FUND f
         ON c.CLIENT_SHORT_NAME=f.INVESTMENT_MANAGER_CD 
         WHERE 
         CLIENT_TYPE = 'EXT'
         AND CLIENT_SHORT_NAME IS NOT NULL
         AND st.STRATEGY_ID =f.STRATEGY_ID
         and f.FUND_CD=fundInput
         ORDER BY CLIENT_SHORT_NAME, UPPER(f.FUND_CD);
          EXCEPTION
           when NO_DATA_FOUND THEN 
           return_val := 'Y'; 
           End;
     IF   strategy_id_val is null or client_id_val is null then
     	   return_val :=  'Y';
     ELSE    
         FOR cur in strategycur LOOP
         
            IF cur.fund_cd<>fundInput and cur.LEGAL_ENTITY_CD<>legalEntityInput THEN
              return_val :=  'N';
              EXIT;
            END IF;
         END LOOP;
     END IF;
 	RETURN return_val;

 END check_fund_strategy_Mapping;
 
 FUNCTION  CALCULATE_PRICE_BY_ASSET_ID(p_assest_id IN GEC_ASSET.ASSET_ID%TYPE,
										  p_broker_cd IN GEC_BROKER.BROKER_CD%TYPE,
										  p_collateral_currency_cd	GEC_BROKER.COLLATERAL_CURRENCY_CD%TYPE,
										  p_collateral_type	 GEC_BROKER.COLLATERAL_TYPE%TYPE)  RETURN VARCHAR2
 IS
  		VAR_PRICE GEC_BULK_G1_TRADE.PRICE%TYPE;
  		VAR_TEMP_PRICE GEC_BULK_G1_TRADE.PRICE%TYPE;
 		VAR_ASSET_TYPE_ID GEC_ASSET.ASSET_TYPE_ID%TYPE;
 		VAR_TRADE_COUNTRY_CD GEC_TRADE_COUNTRY.CURRENCY_CD%TYPE;
	    VAR_CLEAN_PRICE  GEC_ASSET.CLEAN_PRICE%TYPE;
	    VAR_DIRTY_PRICE GEC_ASSET.CLEAN_PRICE%TYPE;
	    VAR_PRICE_DATE GEC_ASSET.PRICE_DATE%TYPE;
        VAR_PRICE_CURRENCY GEC_ASSET.PRICE_CURRENCY_CD%TYPE;
 		VAR_COLLATERAL_PERCENTAGE GEC_BROKER.US_COLLATERAL_PERCENTAGE%TYPE;
 		VAR_PRICE_ROUND_FACTOR GEC_BROKER.US_PRICE_ROUND_FACTOR%TYPE;
 		VAR_DPS GEC_BROKER.NOU_US_DPS%TYPE;
 		VAR_EXCHANGE_RATE GEC_EXCHANGE_RATE.EXCHANGE_RATE%TYPE;
        VAR_EXCHANGE_DATE GEC_EXCHANGE_RATE.EXCHANGE_DATE%TYPE;  
        VAR_SECURITY_EXCHANGE_RATE GEC_EXCHANGE_RATE.EXCHANGE_RATE%TYPE;
        VAR_SECURITY_EXCHANGE_DATE GEC_EXCHANGE_RATE.EXCHANGE_DATE%TYPE; 
 		VAR_FROM_TIMEZONE  GEC_TRADE_COUNTRY.LOCALE%TYPE:= 'AMERICA/NEW_YORK';
        VAR_TO_TIMEZONE GEC_TRADE_COUNTRY.LOCALE%TYPE:= 'AMERICA/NEW_YORK';
        VAR_VALIDATE_DATE_RESULT VARCHAR2(10):= 'N';
        VAR_STALE_EXCHANGE_PRICE VARCHAR2(10):= 'N';
        VAR_STALE_SECURITY_CUR VARCHAR2(10):= 'N';
         VAR_IS_STALE_EXCHANGE_PRICE VARCHAR(10);
        VAR_BUSINESS_DAY DATE;
        VAR_ERROR_CODE GEC_BULK_G1_TRADE_TEMP.ERROR_CODE%TYPE;
 BEGIN      
      IF p_assest_id IS NULL OR p_broker_cd IS NULL THEN
 	  	RETURN NULL;
 	  END IF;
      
      BEGIN      
      --1.VAR_TRADE_COUNTRY_CD
	  --2.VAR_TO_TIMEZONE
      SELECT GA.TRADE_COUNTRY_CD, GTC.LOCALE INTO VAR_TRADE_COUNTRY_CD,VAR_TO_TIMEZONE
                   			FROM GEC_ASSET GA
                   			LEFT JOIN GEC_TRADE_COUNTRY GTC
                    	    ON GA.TRADE_COUNTRY_CD = GTC.TRADE_COUNTRY_CD
                    	    WHERE GA.ASSET_ID =  p_assest_id;
      
      --3.VAR_COLLATERAL_PERCENTAGE
	  --4.VAR_PRICE_ROUND_FACTOR
	  --5.VAR_DPS
      SELECT (CASE WHEN VAR_TRADE_COUNTRY_CD = 'US' THEN GB.US_COLLATERAL_PERCENTAGE 
              			   WHEN VAR_TRADE_COUNTRY_CD = 'CA' AND p_collateral_type = 'CASH' AND p_collateral_currency_cd = 'USD' THEN GB.NONUS_COLLATERAL_PERCENTAGE
              			   WHEN (VAR_TRADE_COUNTRY_CD = 'CA' AND p_collateral_currency_cd = 'CAD') OR (VAR_TRADE_COUNTRY_CD = 'CA' AND p_collateral_type <> 'CASH') THEN GB.US_COLLATERAL_PERCENTAGE
              			   WHEN VAR_TRADE_COUNTRY_CD <> 'US' AND VAR_TRADE_COUNTRY_CD <> 'CA' THEN GB.NONUS_COLLATERAL_PERCENTAGE
              			   ELSE GB.US_COLLATERAL_PERCENTAGE END) AS COLLATERAL_PERCENTAGE,
              		 (CASE WHEN VAR_TRADE_COUNTRY_CD ='US' THEN GB.US_PRICE_ROUND_FACTOR WHEN VAR_TRADE_COUNTRY_CD ='CA'THEN GB.CA_PRICE_ROUND_FACTOR ELSE GB.NON_US_PRICE_ROUND_FACTOR END) AS PRICE_ROUND_FACTOR,
              		 (CASE WHEN VAR_TRADE_COUNTRY_CD ='US' THEN 7 WHEN VAR_TRADE_COUNTRY_CD = 'CA' THEN CA_DPS ELSE NOU_US_DPS END) AS DPS
              INTO VAR_COLLATERAL_PERCENTAGE, VAR_PRICE_ROUND_FACTOR, VAR_DPS
              FROM GEC_BROKER GB
              WHERE GB.BROKER_CD = p_broker_cd;
              
      --6.VAR_EXCHANGE_RATE
	  --7.VAR_EXCHANGE_DATE
	  SELECT er.EXCHANGE_RATE, er.EXCHANGE_DATE INTO VAR_EXCHANGE_RATE, VAR_EXCHANGE_DATE 
	       FROM GEC_EXCHANGE_RATE er, GEC_LATEST_EXCHANGE_RATE_VW ler 
	       WHERE er.EXCHANGE_CURRENCY_CD = ler.EXCHANGE_CURRENCY_CD AND er.EXCHANGE_DATE = ler.EXCHANGE_DATE AND er.EXCHANGE_CURRENCY_CD = p_collateral_currency_cd;
      
      --8.VAR_ASSET_TYPE_ID
	  SELECT GA.ASSET_TYPE_ID INTO VAR_ASSET_TYPE_ID FROM GEC_ASSET GA WHERE GA.ASSET_ID =  p_assest_id;
	  
	  --9.VAR_CLEAN_PRICE
	  --10.VAR_PRICE_DATE
	  --11.VAR_PRICE_CURRENCY
	  IF VAR_ASSET_TYPE_ID = 4 THEN
           SELECT  GA.CLEAN_PRICE, GA.PRICE_DATE, GA.PRICE_CURRENCY_CD
                      INTO VAR_CLEAN_PRICE, VAR_PRICE_DATE, VAR_PRICE_CURRENCY
                      FROM GEC_ASSET GA
                      WHERE GA.ASSET_ID = p_assest_id;
      ELSE
          SELECT  GA.CLEAN_PRICE, GA.DIRTY_PRICE, GA.PRICE_DATE, GA.PRICE_CURRENCY_CD 
                      INTO VAR_CLEAN_PRICE,VAR_DIRTY_PRICE,VAR_PRICE_DATE, VAR_PRICE_CURRENCY
                      FROM GEC_ASSET GA
                      WHERE GA.ASSET_ID =  p_assest_id;
      END IF;

	  IF (VAR_CLEAN_PRICE IS NULL OR (VAR_DIRTY_PRICE IS NULL AND VAR_ASSET_TYPE_ID <> 4)) THEN 
         RETURN NULL;
      END IF;

	  --12.VAR_SECURITY_EXCHANGE_RATE
	  --13.VAR_SECURITY_EXCHANGE_DATE
	  IF VAR_PRICE_CURRENCY IS NOT NULL THEN
	     SELECT er.EXCHANGE_RATE, er.EXCHANGE_DATE INTO VAR_SECURITY_EXCHANGE_RATE, VAR_SECURITY_EXCHANGE_DATE 
	        FROM GEC_EXCHANGE_RATE er, GEC_LATEST_EXCHANGE_RATE_VW ler 
	        WHERE er.EXCHANGE_CURRENCY_CD = ler.EXCHANGE_CURRENCY_CD AND er.EXCHANGE_DATE = ler.EXCHANGE_DATE AND er.EXCHANGE_CURRENCY_CD = VAR_PRICE_CURRENCY;
	   ELSE
            RETURN NULL;
	   END IF;
	   
	   GEC_VALIDATION_PKG.VALIDATE_PRICE(NULL,
                        				VAR_PRICE,
                        				VAR_TEMP_PRICE,
                        				p_assest_id,
                       					p_broker_cd,
                        				VAR_TRADE_COUNTRY_CD,
                        				VAR_PRICE_ROUND_FACTOR,
                        				VAR_DPS,
                        				VAR_EXCHANGE_RATE,
                        				VAR_EXCHANGE_DATE,
                        				VAR_SECURITY_EXCHANGE_RATE,
                        				VAR_SECURITY_EXCHANGE_DATE,
                        				VAR_COLLATERAL_PERCENTAGE,
                        				VAR_ASSET_TYPE_ID,
                        				VAR_CLEAN_PRICE,
                        				VAR_DIRTY_PRICE,
                        				VAR_FROM_TIMEZONE,
                        				VAR_BUSINESS_DAY,
                        				VAR_STALE_EXCHANGE_PRICE,
                        				VAR_STALE_SECURITY_CUR,
                        				VAR_IS_STALE_EXCHANGE_PRICE,
                        				VAR_VALIDATE_DATE_RESULT,
                        				VAR_ERROR_CODE);
       EXCEPTION 
       	WHEN NO_DATA_FOUND THEN
       		RETURN  NULL;
       	WHEN OTHERS THEN 
            RETURN  NULL;
       END;
                
	 RETURN VAR_TEMP_PRICE;
 END CALCULATE_PRICE_BY_ASSET_ID;
 
END GEC_UTILS_PKG;
/


