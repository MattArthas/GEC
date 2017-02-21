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
-- MAR 19, 2010    Jingzheng, Shang          created
-------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE GEC_VALIDATION_PKG
AS
	
	PROCEDURE VALIDATE_BASIC_INFO(p_transaction_type  	IN		VARCHAR2,
									p_errorCode			OUT		VARCHAR2);
	
	-- FOR ORDER								
	PROCEDURE VALIDATE_ORDER_BASIC_INFO(p_transaction_type  	IN		VARCHAR2,
									p_errorCode			OUT		VARCHAR2);		
															
	PROCEDURE VALIDATE_ORDER_INPUT_DATE(p_errorCode	OUT		VARCHAR2);
	
	PROCEDURE BATCH_VALIDATE_ORDER_DATE(p_desktop_date IN DATE,p_faild_counts OUT NUMBER,p_retOrderList OUT SYS_REFCURSOR);
	
	PROCEDURE VALIDATE_ORDER_SETTLE_LOCATION(p_errorCode	OUT		VARCHAR2,
											p_retComment	  OUT SYS_REFCURSOR);
	
	PROCEDURE VALIDATE_IM(p_transaction_type  	IN		VARCHAR2,
							p_errorCode			OUT		VARCHAR2);
	
	-- FOR ORDER
	PROCEDURE VALIDATE_ORDER_IM(p_transaction_type  	IN		VARCHAR2,
							p_errorCode			OUT		VARCHAR2,
							p_retComment	  OUT SYS_REFCURSOR);
	
	PROCEDURE VALIDATE_FUND(p_transaction_type  IN		VARCHAR2,
							p_errorCode			OUT		VARCHAR2);
							
	-- FOR ORDER
	PROCEDURE VALIDATE_ORDER_FUND(p_transaction_type  IN		VARCHAR2,
							p_errorCode			OUT		VARCHAR2,
							p_retComment	  OUT SYS_REFCURSOR
							);
														
	PROCEDURE VALIDATE_BUSINESS_DATE(p_curr_date DATE);
	
	PROCEDURE DERIVE_BUSINESS_DATE(p_curr_date DATE);
	
	PROCEDURE VALIDATE_STRATEGY(p_transaction_type  	IN		VARCHAR2,
								p_errorCode			OUT		VARCHAR2);
	PROCEDURE VALIDATE_ORDER_STRATEGY(p_errorCode	OUT		VARCHAR2,
										p_retComment	  OUT SYS_REFCURSOR);
	PROCEDURE TRANSFORM_TRADE_COUNTRY;
	
	-- FOR ORDER
	PROCEDURE TRANSFORM_ORDER_TRADE_COUNTRY;
	
	PROCEDURE VALIDATE_PREBORROW_COUNTRY;
	
	PROCEDURE VALIDATE_COUNTRY_FOR_LOCATE(p_locate_on_preborrow_cntry OUT VARCHAR2);
		
	PROCEDURE VALIDATE_STRATEGY_PROFILE;
	
	--move from gec_upload_pkg
	PROCEDURE CHECK_ORDER_TRAILER(	p_errorCode			OUT		VARCHAR2);   
	--move from gec_upload_pkg	                         
	PROCEDURE CHECK_LOCATE_TRAILER(	p_uploadData        IN 		GEC_IM_REQUEST_TP_ARRAY,
									p_errorCode         OUT 	VARCHAR2);	
										
	PROCEDURE FILL_DEFAULTS;
		
	PROCEDURE FILL_STRATEGY;
		                         
	-- It intends to do pretreatment before process im order.
	-- 1.set default client_cd and default fund_cd.
	--PROCEDURE PREPARE_ORDER;  
	
	--************************************************************************************
	-- VALICATE IM ORDER REQUEST
	-- Refer to Jira Item GEC-928, 
	-- Refer to Error definition:http://collaborate/sites/GMT/gmsftprojects/gec12/Development%20Case
	-- /GECR1.2%20File%20Automation%20Error%20Codes%20and%20Resolution%20Processes.xls 
	--************************************************************************************		                         
	PROCEDURE VALIDATE_IM_ORDER( p_checkTrailer 	IN 	VARCHAR2,
								 p_errorCode      OUT 	VARCHAR2,
								 p_retComment	  OUT SYS_REFCURSOR);   
								 
 	--************************************************************************************                     
	--	FILL ASSET FOR REQUEST
	--************************************************************************************ 
  	PROCEDURE FILL_REQUEST_TEMP_WITH_ASSET( p_transactionCd  IN 	VARCHAR2);
  	
  	
  	-- FOR ORDER
  	PROCEDURE FILL_ORDER_TEMP_WITH_ASSET( p_transactionCd  IN 	VARCHAR2);
  
  	--************************************************************************************                     
	--	VALIDATE MULTI ASSET
	--************************************************************************************	                         
 	 PROCEDURE VALIDATE_ASSET_ID(
                      p_cusip IN VARCHAR2,
                      p_isin IN VARCHAR2,
                      p_sedol IN VARCHAR2,
                      p_quik IN VARCHAR2,
                      p_ticker IN VARCHAR2,
                      p_description IN VARCHAR2,
                      p_trade_country_cd IN VARCHAR2,
                      p_asset_code IN VARCHAR2,
                      p_asset_code_type IN VARCHAR2,
                      var_found_flag OUT NUMBER, 
                      var_asset_code_type OUT gec_asset_identifier.asset_code_type%type,
                      var_status OUT VARCHAR2,
                      var_asset_infor OUT GEC_ASSET_TP_ARRAY);

	--***********************************************************************************
	--VALIDATE IM REQUEST
	--INCLUDING locate,preborrow
	--***********************************************************************************					
	PROCEDURE VALIDATE_IM_REQUEST(	p_uploadData     		IN 	GEC_IM_REQUEST_TP_ARRAY,
									p_uploadedBy        	IN 	VARCHAR2,
									p_checkTrailer 	 		IN 	VARCHAR2,
									p_transaction_type  	IN 	VARCHAR2,
								 	p_curr_date	  	 		IN	DATE,	 
									p_errorCode      		OUT VARCHAR2);  
									
	PROCEDURE SCHEDULE_FUTURE_LOCATE(p_curr_date DATE);
			
	FUNCTION UPDATE_REQUET_STARUS( p_oldStatus IN VARCHAR2,
									p_newStatus IN VARCHAR2) RETURN VARCHAR2;
	PROCEDURE VALIDATE_LOADVALIDATED_BORROW(p_borrowList_cursor out SYS_REFCURSOR);
	
	PROCEDURE VALIDATE_SETTLE_DATE(p_assetId 	IN  NUMBER,
								   p_settleDate IN NUMBER,
								   p_tradeCty 	IN VARCHAR2,
								   p_errorCode	OUT		VARCHAR2);
	FUNCTION VALIDATE_PRICE_DATE(P_PRICE_DATE IN DATE,
                               P_BUSINESS_DATE IN DATE,
                               P_TRADE_COUNTRY IN VARCHAR2,
                               P_TYPE IN VARCHAR2)  RETURN VARCHAR2;   
    
    --***********************************************************************************
	--VALIDATE ORDERS FROM COPY/PASTE
	--INCLUDING SHORT,COVER
	--***********************************************************************************                           
    PROCEDURE BATCH_VALIDATE_ORDERS; 
	PROCEDURE BATCH_VALIDATE_FUND;
	PROCEDURE BATCH_VALIDATE_STATEGY;
	PROCEDURE BATCH_VALIDATE_IM;
	PROCEDURE BATCH_VALIDATE_ASSET;
	PROCEDURE BATCH_VALIDATE_ASSET_FLIP;
	PROCEDURE BATCH_VALIDATE_TRADE_DATE;  	
	PROCEDURE BATCH_VALIDATE_SETTLE_DATE;  	
	PROCEDURE BATCH_VALIDATE_SHARE_QTY;	
	PROCEDURE VALIDATE_PRICE(
                        VAR_INPUT_PRICE IN GEC_BULK_G1_TRADE.PRICE%TYPE,
                        VAR_PRICE OUT GEC_BULK_G1_TRADE.PRICE%TYPE,
                        VAR_TEMP_PRICE OUT GEC_BULK_G1_TRADE.PRICE%TYPE,
                        VAR_ASSET_ID IN GEC_ASSET.ASSET_ID%TYPE,
                        VAR_BROKER_CD  GEC_BROKER.BROKER_CD%TYPE,
                        VAR_TRADE_COUNTRY_CD GEC_TRADE_COUNTRY.CURRENCY_CD%TYPE,
                        VAR_PRICE_ROUND_FACTOR IN GEC_BROKER.US_PRICE_ROUND_FACTOR%TYPE,
                        VAR_DPS IN GEC_BROKER.NOU_US_DPS%TYPE,
                        VAR_EXCHANGE_RATE IN GEC_EXCHANGE_RATE.EXCHANGE_RATE%TYPE,
                        VAR_EXCHANGE_DATE IN GEC_EXCHANGE_RATE.EXCHANGE_DATE%TYPE,
                        VAR_SECURITY_EXCHANGE_RATE IN GEC_EXCHANGE_RATE.EXCHANGE_RATE%TYPE,
                        VAR_SECURITY_EXCHANGE_DATE IN GEC_EXCHANGE_RATE.EXCHANGE_DATE%TYPE,
                        VAR_COLLATERAL_PERCENTAGE IN GEC_BROKER.US_COLLATERAL_PERCENTAGE%TYPE,
                        VAR_ASSET_TYPE_ID IN GEC_ASSET.ASSET_TYPE_ID%TYPE,
                        VAR_CLEAN_PRICE IN GEC_ASSET.CLEAN_PRICE%TYPE,
                        VAR_DIRTY_PRICE IN GEC_ASSET.CLEAN_PRICE%TYPE,
                        VAR_FROM_TIMEZONE IN GEC_TRADE_COUNTRY.LOCALE%TYPE,
                        VAR_BUSINESS_DAY IN OUT DATE,
                        VAR_STALE_EXCHANGE_PRICE IN OUT VARCHAR2,
                        VAR_STALE_SECURITY_CUR IN OUT VARCHAR2,
                        VAR_IS_STALE_EXCHANGE_PRICE IN OUT VARCHAR,
                        VAR_VALIDATE_DATE_RESULT IN OUT VARCHAR2,
                        VAR_ERROR_CODE IN OUT VARCHAR2);					   
END GEC_VALIDATION_PKG;
/

CREATE OR REPLACE PACKAGE BODY GEC_VALIDATION_PKG
AS

	PROCEDURE VALIDATE_BASIC_INFO(	p_transaction_type  IN		VARCHAR2,
									p_errorCode			OUT		VARCHAR2)
	IS
		v_fail_flag 	VARCHAR2(1);
	BEGIN
			IF p_transaction_type IS NULL THEN
				RETURN;
			END IF;
			--If locate,validate transaction type
			v_fail_flag := 'N';
			BEGIN	
				IF p_transaction_type = GEC_CONSTANTS_PKG.C_LOCATE OR p_transaction_type = GEC_CONSTANTS_PKG.C_PREBORROW THEN		
					SELECT 'Y' INTO v_fail_flag  
					FROM GEC_LOCATE_PREBORROW_TEMP temp
					WHERE ( temp.TRANSACTION_CD IS NULL OR UPPER(temp.TRANSACTION_CD) <> GEC_CONSTANTS_PKG.C_TRAILER )  
					      AND ( temp.TRANSACTION_CD IS NULL OR UPPER(temp.TRANSACTION_CD) NOT IN (GEC_CONSTANTS_PKG.C_LOCATE,GEC_CONSTANTS_PKG.C_PREBORROW) ) 
					      AND ROWNUM = 1;						      
				--ELSIF p_transaction_type = GEC_CONSTANTS_PKG.C_SHORT OR p_transaction_type = GEC_CONSTANTS_PKG.C_COVER THEN
				--	SELECT 'Y' INTO v_fail_flag  
				--	FROM GEC_LOCATE_PREBORROW_TEMP temp
				--	WHERE ( temp.TRANSACTION_CD IS NULL OR UPPER(temp.TRANSACTION_CD) <> GEC_CONSTANTS_PKG.C_TRAILER )  
				--      AND ( temp.TRANSACTION_CD IS NULL OR UPPER(temp.TRANSACTION_CD) NOT IN (GEC_CONSTANTS_PKG.C_SHORT,GEC_CONSTANTS_PKG.C_COVER )  ) 
				--      AND ROWNUM = 1;				
				END IF;
			EXCEPTION WHEN NO_DATA_FOUND THEN
				v_fail_flag := 'N';
			END;
		  
			IF v_fail_flag = 'Y' THEN
				p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_INVALID_TRANSACTION_TYPE;
				return;
			END IF;		
					
	END VALIDATE_BASIC_INFO;
	
	PROCEDURE VALIDATE_ORDER_BASIC_INFO(p_transaction_type  	IN		VARCHAR2,
									p_errorCode			OUT		VARCHAR2)	
	IS
		v_fail_flag 	VARCHAR2(1);
	BEGIN
			IF p_transaction_type IS NULL THEN
				RETURN;
			END IF;
			--If locate,validate transaction type
			v_fail_flag := 'N';
			BEGIN	
				IF p_transaction_type = GEC_CONSTANTS_PKG.C_SHORT OR p_transaction_type = GEC_CONSTANTS_PKG.C_COVER THEN
					SELECT 'Y' INTO v_fail_flag  
					FROM GEC_IM_ORDER_TEMP temp
					WHERE temp.TRANSACTION_CD IS NULL OR UPPER(temp.TRANSACTION_CD) NOT IN 
				      			(GEC_CONSTANTS_PKG.C_SHORT,GEC_CONSTANTS_PKG.C_COVER,GEC_CONSTANTS_PKG.C_COVER_CANCEL,GEC_CONSTANTS_PKG.C_SHORT_CANCEL,GEC_CONSTANTS_PKG.C_SB_SHORT,GEC_CONSTANTS_PKG.C_TRAILER)   
				      AND ROWNUM = 1;				
				END IF;
			EXCEPTION WHEN NO_DATA_FOUND THEN
				v_fail_flag := 'N';
			END;
		  
			IF v_fail_flag = 'Y' THEN
				p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_INVALID_TRANSACTION_TYPE;
				return;
			END IF;		
					
	END VALIDATE_ORDER_BASIC_INFO;
	
	PROCEDURE VALIDATE_ORDER_INPUT_DATE(p_errorCode	OUT		VARCHAR2)
	IS
		v_result VARCHAR2(1) := 'Y';
		CURSOR v_cur_dates
		IS
			SELECT distinct BUSINESS_DATE,TRADE_DATE,SETTLE_DATE, trade_country_cd 
			FROM GEC_IM_ORDER_TEMP
			WHERE UPPER(TRANSACTION_CD) != GEC_CONSTANTS_PKG.C_TRAILER
				AND STATUS != 'X';
	BEGIN
		FOR v_dates IN v_cur_dates
		LOOP
			--v_result := GEC_UTILS_PKG.IS_WORKDAY(GEC_UTILS_PKG.NUMBER_TO_DATE(v_dates.BUSINESS_DATE),v_dates.trade_country_cd);
			--IF v_result = 'N' THEN
			--	p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_CD_DATE_NOT_WORKING_DAY;
			--	return;
			--END IF;
		
			v_result := GEC_UTILS_PKG.IS_WORKDAY(GEC_UTILS_PKG.NUMBER_TO_DATE(v_dates.TRADE_DATE),v_dates.trade_country_cd);
			IF v_result = 'N' THEN
				p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_CD_DATE_NOT_WORKING_DAY;
				return;
			END IF;
			
			v_result := GEC_UTILS_PKG.IS_WORKDAY(GEC_UTILS_PKG.NUMBER_TO_DATE(v_dates.SETTLE_DATE),v_dates.trade_country_cd,'S');
			IF v_result = 'N' THEN
				p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_CD_DATE_NOT_WORKING_DAY;
				return;
			END IF;
		END LOOP;
	
	END VALIDATE_ORDER_INPUT_DATE;
	
	--GEC2.2 CHANGE
	PROCEDURE BATCH_VALIDATE_ORDER_DATE(p_desktop_date IN DATE,p_faild_counts OUT NUMBER,p_retOrderList OUT SYS_REFCURSOR)
	IS
		V_T_DAYS NUMBER := NULL;
		V_T_DATE_NUM NUMBER :=NULL;
		V_TODAY_NUM NUMBER :=NULL;
		CURSOR v_cur_dates
		IS
			SELECT TRADE_DATE,SETTLE_DATE,TRADE_COUNTRY_CD
			FROM GEC_IM_ORDER_TEMP;
	BEGIN
		---1.
		p_faild_counts:=0;		
		---2.
		BEGIN
			SELECT TO_NUMBER(ATTR_VALUE1) INTO V_T_DAYS FROM GEC_CONFIG 
				WHERE ATTR_GROUP = 'SETTLE_DATE' AND ATTR_NAME = 'MAX_DATE_EXPAND_LIMIT'; 
		EXCEPTION WHEN OTHERS THEN
            V_T_DAYS :=10; 
        END;
        ---3.
        V_TODAY_NUM := GEC_UTILS_PKG.DATE_TO_NUMBER(p_desktop_date);
        ---4.
		FOR v_date IN v_cur_dates
		LOOP
			IF (v_date.TRADE_DATE IS NOT NULL AND v_date.TRADE_DATE>V_TODAY_NUM)
				OR (v_date.SETTLE_DATE IS NOT NULL AND v_date.SETTLE_DATE<V_TODAY_NUM)
				OR(v_date.TRADE_DATE IS NOT NULL AND v_date.TRADE_DATE<GEC_UTILS_PKG.DATE_TO_NUMBER(GEC_UTILS_PKG.GET_TMINUSN(p_desktop_date,1,v_date.TRADE_COUNTRY_CD,'T')))
				OR (v_date.SETTLE_DATE IS NOT NULL AND v_date.SETTLE_DATE>GEC_UTILS_PKG.DATE_TO_NUMBER(GEC_UTILS_PKG.GET_TPLUSN(p_desktop_date,v_t_days,v_date.TRADE_COUNTRY_CD,'S')))THEN
					
				p_faild_counts :=p_faild_counts+1;
			END IF;			
		END LOOP;
		OPEN p_retOrderList FOR
    			SELECT TRANSACTION_CD, FUND_CD, ASSET_CODE, TRADE_DATE, SETTLE_DATE,SETTLEMENT_LOCATION_CD,TRADE_COUNTRY_CD,
    					SHARE_QTY,FUND_ERROR_CODE, ASSET_ERROR_CODE, TRADE_DATE_ERROR_CODE, SETTLE_DATE_ERROR_CODE, SHARE_QTY_ERROR_CODE
    			FROM GEC_IM_ORDER_TEMP;	
	END BATCH_VALIDATE_ORDER_DATE;
	
	PROCEDURE VALIDATE_IM(	p_transaction_type  IN		VARCHAR2,
							p_errorCode			OUT		VARCHAR2)
	IS
		v_fail_flag 	VARCHAR2(1);
	BEGIN
		--Error Code 006: the file contains an unrecognized Investment Manager.
		--C_VLD_UNRECOGNIZED_IM VLD0006
		v_fail_flag := 'N';
		BEGIN		
			SELECT 'Y' INTO v_fail_flag FROM GEC_LOCATE_PREBORROW_TEMP temp
			LEFT JOIN GEC_CLIENT client
			ON temp.investment_manager_cd = client.client_short_name
			WHERE  	ROWNUM = 1
				AND client.client_short_name IS NULL;	
		EXCEPTION WHEN NO_DATA_FOUND THEN
			v_fail_flag := 'N';
		END;
	  
		IF v_fail_flag = 'Y' THEN
			p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_UNRECOGNIZED_IM;
			return ;
		END IF;
		
		--VLD0029: the Investment Manager is inactive.
		--C_VLD_INACTIVE_IM 
		-- Investment Manager IS NOT ACTIVE
		v_fail_flag := 'N';
		BEGIN		
			SELECT 'Y' INTO v_fail_flag FROM GEC_LOCATE_PREBORROW_TEMP temp
			JOIN GEC_CLIENT client
			ON temp.investment_manager_cd = client.client_short_name
			WHERE  	ROWNUM = 1
				AND client.CLIENT_STATUS = 'I';	
		EXCEPTION WHEN NO_DATA_FOUND THEN
			v_fail_flag := 'N';
		END;
	  
		IF v_fail_flag = 'Y' THEN
			p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_INACTIVE_IM;
			return ;
		END IF;			

		--Error Code 008: no strategy has been setup for this Investment Manager.
		--C_VLD_STRATEGY_NOT_SETUP  VLD0008
		-- If one im in one request has no strategy, it will Set v_fail_flag='Y'
		IF(p_transaction_type=gec_constants_pkg.C_LOCATE)	 THEN
			v_fail_flag := 'Y';
			BEGIN		
				SELECT 'Y' INTO v_fail_flag  
				FROM (
				      SELECT investment_manager_cd, strategy.strategy_id
				      FROM gec_locate_preborrow_temp temp
				      JOIN GEC_CLIENT client 
				      ON temp.investment_manager_cd = client.client_short_name
				      LEFT JOIN GEC_STRATEGY strategy 	      	      	      
				      ON client.client_id =  strategy.client_id
	                	AND strategy.status in( 'A')
			    ) temp
				WHERE
	          		temp.strategy_id IS NULL
	          		AND ROWNUM = 1;		
			EXCEPTION WHEN NO_DATA_FOUND THEN
				v_fail_flag := 'N';
			END;
		  
			IF v_fail_flag = 'Y' THEN
				p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_STRATEGY_NOT_SETUP;
				return ;
			END IF;		
		END IF;
	END VALIDATE_IM;

	PROCEDURE VALIDATE_ORDER_IM(	p_transaction_type  IN		VARCHAR2,
							p_errorCode			OUT		VARCHAR2,
							p_retComment	  OUT SYS_REFCURSOR)
	IS
		v_fail_flag 	VARCHAR2(1);
	BEGIN
		--Error Code 006: the file contains an unrecognized Investment Manager.
		--C_VLD_UNRECOGNIZED_IM VLD0006
		v_fail_flag := 'N';
		BEGIN		
			SELECT 'Y' INTO v_fail_flag FROM GEC_IM_ORDER_TEMP temp
			LEFT JOIN GEC_CLIENT client
			ON temp.investment_manager_cd = client.client_short_name
			WHERE  	ROWNUM = 1
				AND client.client_short_name IS NULL
				AND UPPER(temp.TRANSACTION_CD) <> GEC_CONSTANTS_PKG.C_TRAILER;	
		EXCEPTION WHEN NO_DATA_FOUND THEN
			v_fail_flag := 'N';
		END;
	  
		IF v_fail_flag = 'Y' THEN
			p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_UNRECOGNIZED_IM;
			OPEN p_retComment FOR
				SELECT distinct investment_manager_cd AS COMMENT_TXT 
				FROM GEC_IM_ORDER_TEMP temp
				LEFT JOIN GEC_CLIENT client
      			ON temp.investment_manager_cd = client.client_short_name
     			WHERE  client.client_short_name IS NULL;
			return ;
		END IF;
		
		--VLD0029: the Investment Manager is inactive.
		--C_VLD_INACTIVE_IM 
		-- Investment Manager IS NOT ACTIVE
		v_fail_flag := 'N';
		BEGIN		
			SELECT 'Y' INTO v_fail_flag FROM GEC_IM_ORDER_TEMP temp
			JOIN GEC_CLIENT client
			ON temp.investment_manager_cd = client.client_short_name
			WHERE  	ROWNUM = 1
				AND client.CLIENT_STATUS = 'I'
				AND UPPER(temp.TRANSACTION_CD) <> GEC_CONSTANTS_PKG.C_TRAILER;	
		EXCEPTION WHEN NO_DATA_FOUND THEN
			v_fail_flag := 'N';
		END;
	  
		IF v_fail_flag = 'Y' THEN
			p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_INACTIVE_IM;
			OPEN p_retComment FOR
				SELECT distinct investment_manager_cd AS COMMENT_TXT 
				FROM GEC_IM_ORDER_TEMP temp
				LEFT JOIN GEC_CLIENT client
      			ON temp.investment_manager_cd = client.client_short_name
     			WHERE  client.CLIENT_STATUS = 'I';
			return ;
		END IF;			

		--Error Code 008: no strategy has been setup for this Investment Manager.
		--C_VLD_STRATEGY_NOT_SETUP  VLD0008
		-- If one im in one request has no strategy, it will Set v_fail_flag='Y'
		
		v_fail_flag := 'Y';
		BEGIN		
			SELECT 'Y' INTO v_fail_flag  
			FROM (
			      SELECT investment_manager_cd, strategy.strategy_id
			      FROM GEC_IM_ORDER_TEMP temp
			      JOIN GEC_CLIENT client 
			      ON temp.investment_manager_cd = client.client_short_name
			      LEFT JOIN GEC_STRATEGY strategy 	      	      	      
			      ON client.client_id =  strategy.client_id
                	AND strategy.status in( 'A')
		    ) temp
			WHERE
          		temp.strategy_id IS NULL
          		AND ROWNUM = 1;		
		EXCEPTION WHEN NO_DATA_FOUND THEN
			v_fail_flag := 'N';
		END;
	  
		IF v_fail_flag = 'Y' THEN
			p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_STRATEGY_NOT_SETUP;
			OPEN p_retComment FOR
				  SELECT distinct temp.investment_manager_cd as COMMENT_TXT
			      	FROM GEC_IM_ORDER_TEMP temp
			      	JOIN GEC_CLIENT client 
			      	ON temp.investment_manager_cd = client.client_short_name
			      	LEFT JOIN GEC_STRATEGY strategy 	      	      	      
			      	ON client.client_id =  strategy.client_id
                	AND strategy.status in( 'A')	
					WHERE temp.strategy_id IS NULL;
			return ;
		END IF;		
		
	END VALIDATE_ORDER_IM;
	
	PROCEDURE VALIDATE_FUND(p_transaction_type  IN		VARCHAR2,
							p_errorCode			OUT		VARCHAR2)
	IS
		v_fail_flag 	VARCHAR2(1);
	BEGIN
		--Error Code 005: the Investment Manager and fund contained in this file do not match.
		--C_VLD_IM_FUND_NOT_MATCH VLD0005	
		v_fail_flag := 'N';
		BEGIN		
			SELECT 'Y' INTO v_fail_flag  FROM GEC_LOCATE_PREBORROW_TEMP temp
			LEFT JOIN GEC_FUND fund
			ON temp.investment_manager_cd = fund.investment_manager_cd
				AND temp.fund_cd = fund.fund_cd
			WHERE ROWNUM = 1
				AND fund.fund_cd IS NULL
				AND ( temp.fund_source ='F' OR temp.fund_source IS NULL );	
		EXCEPTION WHEN NO_DATA_FOUND THEN
			v_fail_flag := 'N';
		END;
		
		IF v_fail_flag = 'Y' THEN
			p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_IM_FUND_NOT_MATCHED;
			return ;		
		END IF;

		
		--Error Code 007: no default fund has been setup for this Investment Manager.
		--C_VLD_FUND_NOT_SETUP  VLD0007
		IF (p_transaction_type in ( gec_constants_pkg.C_LOCATE , gec_constants_pkg.C_PREBORROW ) ) THEN
			v_fail_flag := 'N';
			BEGIN			
				SELECT 'Y' INTO v_fail_flag  FROM GEC_LOCATE_PREBORROW_TEMP temp
				WHERE temp.im_default_fund_cd IS NULL 
				    AND ROWNUM = 1;		
			EXCEPTION WHEN NO_DATA_FOUND THEN
				v_fail_flag := 'N';
			END;
		  
			IF v_fail_flag = 'Y' THEN
				p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_FUND_NOT_SETUP;
				return ;
			END IF;		
		END IF;
		
		--Error Code 007: no fund has been setup for this Investment Manager.
		--C_VLD_FUND_NOT_SETUP  VLD0007
		v_fail_flag := 'Y';
		BEGIN		
			SELECT 'Y' INTO v_fail_flag  FROM GEC_LOCATE_PREBORROW_TEMP temp
			JOIN GEC_FUND fund
			ON temp.INVESTMENT_MANAGER_CD = fund.INVESTMENT_MANAGER_CD
			WHERE  ROWNUM = 1;	
		EXCEPTION WHEN NO_DATA_FOUND THEN
			v_fail_flag := 'N';
		END;
		
		IF v_fail_flag = 'N' THEN
			p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_FUND_NOT_SETUP;
			return ;
		END IF;	
		
	END VALIDATE_FUND;
	
	PROCEDURE VALIDATE_ORDER_FUND(p_transaction_type  IN		VARCHAR2,
							p_errorCode			OUT		VARCHAR2,
							p_retComment	  OUT SYS_REFCURSOR
							)
	IS
		v_fail_flag 	VARCHAR2(1);
	BEGIN
		--Error Code 005: the Investment Manager and fund contained in this file do not match.
		--C_VLD_IM_FUND_NOT_MATCH VLD0005	
		v_fail_flag := 'N';
		BEGIN		
			SELECT 'Y' INTO v_fail_flag  FROM GEC_IM_ORDER_TEMP temp
			LEFT JOIN GEC_FUND fund
			ON temp.investment_manager_cd = fund.investment_manager_cd
				AND temp.fund_cd = fund.fund_cd
			WHERE ROWNUM = 1
				AND fund.fund_cd IS NULL
				AND UPPER(temp.TRANSACTION_CD) <> GEC_CONSTANTS_PKG.C_TRAILER;
				--AND ( temp.fund_source ='F' OR temp.fund_source IS NULL );	
		EXCEPTION WHEN NO_DATA_FOUND THEN
			v_fail_flag := 'N';
		END;
		
		IF v_fail_flag = 'Y' THEN
			p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_IM_FUND_NOT_MATCHED;
			OPEN p_retComment FOR
				SELECT distinct temp.investment_manager_cd ||'/'|| temp.fund_cd AS COMMENT_TXT
				FROM GEC_IM_ORDER_TEMP temp
				LEFT JOIN GEC_FUND fund
				ON temp.investment_manager_cd = fund.investment_manager_cd
					AND temp.fund_cd = fund.fund_cd
				WHERE fund.fund_cd IS NULL
					AND UPPER(temp.TRANSACTION_CD) <> GEC_CONSTANTS_PKG.C_TRAILER;
			return ;		
		END IF;

		--GEC-2163
		BEGIN
			SELECT 'Y' INTO v_fail_flag FROM gec_im_order_temp temp
				left join gec_strategy gs
				on temp.strategy_id = gs.strategy_id
				left join gec_client gc
				on temp.INVESTMENT_MANAGER_CD = gc.client_short_name
				and gc.client_status='A'
				and gs.client_id= gc.client_id
			WHERE ROWNUM =1 AND gc.client_id is null and UPPER(temp.TRANSACTION_CD) <> GEC_CONSTANTS_PKG.C_TRAILER;	
		EXCEPTION WHEN NO_DATA_FOUND THEN
			v_fail_flag := 'N';
		END;
		
		IF v_fail_flag = 'Y' THEN
			p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_IM_FUND_NOT_MATCHED;
			OPEN p_retComment FOR
				SELECT distinct temp.investment_manager_cd ||'/'||temp.fund_cd AS COMMENT_TXT
				FROM gec_im_order_temp temp
					left join gec_strategy gs
					on temp.strategy_id = gs.strategy_id
					left join gec_client gc
					on temp.INVESTMENT_MANAGER_CD = gc.client_short_name
					and gc.client_status='A'
					and gs.client_id= gc.client_id
				WHERE gc.client_id is null and UPPER(temp.TRANSACTION_CD) <> GEC_CONSTANTS_PKG.C_TRAILER;
			return ;
		END IF;	
		
		--Error Code 007: no default fund has been setup for this Investment Manager.
		--C_VLD_FUND_NOT_SETUP  VLD0007
		--IF (p_transaction_type in ( gec_constants_pkg.C_LOCATE , gec_constants_pkg.C_PREBORROW ) ) THEN
		--	v_fail_flag := 'N';
		--	BEGIN			
		--		SELECT 'Y' INTO v_fail_flag  FROM GEC_LOCATE_PREBORROW_TEMP temp
		--		WHERE temp.im_default_fund_cd IS NULL 
		--		    AND ROWNUM = 1;		
		--	EXCEPTION WHEN NO_DATA_FOUND THEN
		--		v_fail_flag := 'N';
		--	END;
		  
		--	IF v_fail_flag = 'Y' THEN
		--		p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_FUND_NOT_SETUP;
		--		return ;
		--	END IF;		
		--END IF;
		
		--Error Code 007: no fund has been setup for this Investment Manager.
		--C_VLD_FUND_NOT_SETUP  VLD0007
		v_fail_flag := 'Y';
		BEGIN		
			SELECT 'Y' INTO v_fail_flag  FROM GEC_IM_ORDER_TEMP temp
			JOIN GEC_FUND fund
			ON temp.INVESTMENT_MANAGER_CD = fund.INVESTMENT_MANAGER_CD
			WHERE  ROWNUM = 1
				AND UPPER(temp.TRANSACTION_CD) <> GEC_CONSTANTS_PKG.C_TRAILER;	
		EXCEPTION WHEN NO_DATA_FOUND THEN
			v_fail_flag := 'N';
		END;
		
		IF v_fail_flag = 'N' THEN
			p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_FUND_NOT_SETUP;
			OPEN p_retComment FOR
				SELECT distinct temp.INVESTMENT_MANAGER_CD AS COMMENT_TXT
				FROM GEC_IM_ORDER_TEMP temp
				JOIN GEC_FUND fund
				ON temp.INVESTMENT_MANAGER_CD = fund.INVESTMENT_MANAGER_CD
				WHERE UPPER(temp.TRANSACTION_CD) <> GEC_CONSTANTS_PKG.C_TRAILER;
			return ;
		END IF;	
		
	END VALIDATE_ORDER_FUND;
	
	PROCEDURE VALIDATE_ORDER_SETTLE_LOCATION(p_errorCode	OUT		VARCHAR2,
										p_retComment	  OUT SYS_REFCURSOR)
	IS
		v_fail_flag 	VARCHAR2(1);
	BEGIN
		BEGIN		
			SELECT 'Y' INTO v_fail_flag 
			FROM GEC_IM_ORDER_temp gio 
			left join gec_settlement_location gsl
			on gio.settlement_location_cd=gsl.settlement_location_cd
			WHERE rownum=1 
			AND gio.settlement_location_cd is NOT null AND gsl.settlement_location_cd IS NULL
			AND UPPER(gio.TRANSACTION_CD) <> GEC_CONSTANTS_PKG.C_TRAILER;
		EXCEPTION WHEN NO_DATA_FOUND THEN
			v_fail_flag := 'N';
		END;
		
		IF v_fail_flag = 'Y' THEN
			p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_SETTLE_LOCATION_INVALID;
			OPEN p_retComment FOR
				SELECT distinct gio.settlement_location_cd AS COMMENT_TXT FROM GEC_IM_ORDER_temp gio 
				left join gec_settlement_location gsl
				on gio.settlement_location_cd=gsl.settlement_location_cd
				WHERE gio.settlement_location_cd is NOT null AND gsl.settlement_location_cd IS NULL
				AND UPPER(gio.TRANSACTION_CD) <> GEC_CONSTANTS_PKG.C_TRAILER;
			return ;
		END IF;	
	END VALIDATE_ORDER_SETTLE_LOCATION;	
					
	PROCEDURE VALIDATE_BUSINESS_DATE(p_curr_date DATE)
	IS
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_VALIDATION_PKG.VALIDATE_BUSINESS_DATE';
		v_curr_date DATE;
		v_cutofftime VARCHAR2(20);

		CURSOR v_cur_bizdate(i_curr_date in DATE) IS
			select loc.rowid as row_id, loc.business_date, 
					gec_utils_pkg.is_workday(gec_utils_pkg.TO_TIMEZONE(i_curr_date, gec_constants_pkg.C_BOS_TIMEZONE, country.LOCALE), loc.trade_country_cd) as trading_day_flag, 
					gec_utils_pkg.date_to_number( gec_utils_pkg.get_tplusn(gec_utils_pkg.TO_TIMEZONE(i_curr_date, gec_constants_pkg.C_BOS_TIMEZONE, country.LOCALE), 1, loc.trade_country_cd) ) as next_trade_date, 
					country.cutoff_time,
					gec_utils_pkg.TO_TIMEZONE(i_curr_date, gec_constants_pkg.C_BOS_TIMEZONE, country.LOCALE) tc_datetime,
					gec_utils_pkg.DATE_TO_NUMBER(gec_utils_pkg.TO_TIMEZONE(i_curr_date, gec_constants_pkg.C_BOS_TIMEZONE, country.LOCALE)) as calendar_date
			from gec_locate_preborrow_temp loc, gec_trade_country country
			where loc.trade_country_cd = country.trade_country_cd
			and loc.business_date is not null
			and loc.status != 'X';
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
	
		v_curr_date := NVL(p_curr_date,sysdate);
		FOR v_item in v_cur_bizdate(v_curr_date)
		LOOP
			IF v_item.business_date < gec_utils_pkg.DATE_TO_NUMBER(v_item.tc_datetime) THEN 
				--MF21.2.	If Locate Request  Date is less than current date, set the Locate status to Error. 
				UPDATE gec_locate_preborrow_temp
				   SET status = 'X',
					   COMMENT_TXT =  GEC_UTILS_PKG.SUB_COMMENT(comment_txt||GEC_ERROR_CODE_PKG.C_VLD_MSG_PAST_DATE)
				 WHERE rowid = v_item.row_id;
			ELSIF v_item.business_date > v_item.next_trade_date THEN
				--MF21.7.	If Locate Request Date is greater than current date, check if Locate Request Date is equal to the next business day (Weekday Calendar and Market Calendar). If so, continue processing the locate. Go to Process Future Locates.
				--MF21.8.	If Trade Date is greater than current date,  and not equal to the  next business, set the Locate status to Error.		
				UPDATE gec_locate_preborrow_temp
				   SET status = 'X',
					   COMMENT_TXT = GEC_UTILS_PKG.SUB_COMMENT(comment_txt||GEC_ERROR_CODE_PKG.C_VLD_MSG_EARLY_LOCATE)
				 WHERE rowid = v_item.row_id;
			ELSIF v_item.business_date = v_item.calendar_date AND v_item.trading_day_flag = 'N' THEN
				--MF21.3.	If Locate Request Date is a weekend, set the Locate status to Error. Use Weekday Calendar.
				--MF21.4.	If Locate Request Date is a Holiday set the Locate status to Error. Use Market Holiday Calendar.
				UPDATE gec_locate_preborrow_temp
				   SET status = 'X',
					   COMMENT_TXT = GEC_UTILS_PKG.SUB_COMMENT(comment_txt||GEC_ERROR_CODE_PKG.C_VLD_MSG_NONWORKING_DAY)
				 WHERE rowid = v_item.row_id;
			ELSIF v_item.business_date > v_item.calendar_date AND v_item.business_date < v_item.next_trade_date THEN
				--MF21.3.	If Locate Request Date is a weekend, set the Locate status to Error. Use Weekday Calendar.
				--MF21.4.	If Locate Request Date is a Holiday set the Locate status to Error. Use Market Holiday Calendar.
				UPDATE gec_locate_preborrow_temp
				   SET status = 'X',
					   COMMENT_TXT = GEC_UTILS_PKG.SUB_COMMENT(comment_txt||GEC_ERROR_CODE_PKG.C_VLD_MSG_NONWORKING_DAY)
				 WHERE rowid = v_item.row_id;
			ELSE
				--MF21.5.	If Locate Request Date is equal to current date, and current time is less than Locate Cutoff time, continue processing the locate. 
				--MF21.6.	If Locate Request Date is equal to current date, and current time is greater than Locate Cutoff time,  set the Locate status to Error.					           
				v_cutofftime := gec_utils_pkg.FORMAT_CUTOFF_TO_HH24(v_item.cutoff_time);
				IF v_item.business_date IS NOT NULL AND v_item.business_date = gec_utils_pkg.date_to_number(v_item.tc_datetime) and  v_cutofftime <= to_char(v_item.tc_datetime, 'HH24:Mi:SS') THEN
					UPDATE gec_locate_preborrow_temp
					   SET status = 'X',
						   COMMENT_TXT = GEC_UTILS_PKG.SUB_COMMENT(comment_txt||GEC_ERROR_CODE_PKG.C_VLD_MSG_AFTER_CUTOFF)
					 WHERE rowid = v_item.row_id;
				END IF;
			END IF;
		
		END LOOP;			 
		
		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END VALIDATE_BUSINESS_DATE;
	
	PROCEDURE DERIVE_BUSINESS_DATE (p_curr_date DATE)
	IS
		v_curr_date DATE;
		CURSOR v_cur_derive_business_date(i_curr_date DATE) IS
		select loc.locate_preborrow_id,
						 (case 
						  when to_char( to_date(country.cutoff_time,'HH:MIAM'),'HH24:Mi:SS') <= gec_utils_pkg.to_cutoff_time(i_curr_date,gec_constants_pkg.C_BOS_TIMEZONE,country.LOCALE) 
						  	then gec_utils_pkg.date_to_number( gec_utils_pkg.get_tplusn(gec_utils_pkg.TO_TIMEZONE(i_curr_date, gec_constants_pkg.C_BOS_TIMEZONE, country.LOCALE), 1, loc.trade_country_cd) )
						  when to_char( to_date(country.cutoff_time,'HH:MIAM'),'HH24:Mi:SS') > gec_utils_pkg.to_cutoff_time(i_curr_date,gec_constants_pkg.C_BOS_TIMEZONE,country.LOCALE) 
						  	then  (  case
						  			 when gec_utils_pkg.is_workday(gec_utils_pkg.TO_TIMEZONE(i_curr_date, gec_constants_pkg.C_BOS_TIMEZONE, country.LOCALE), loc.trade_country_cd) = 'Y' 
						  			 	then gec_utils_pkg.DATE_TO_NUMBER(gec_utils_pkg.TO_TIMEZONE(i_curr_date, gec_constants_pkg.C_BOS_TIMEZONE, country.LOCALE))
						  			 when gec_utils_pkg.is_workday(gec_utils_pkg.TO_TIMEZONE(i_curr_date, gec_constants_pkg.C_BOS_TIMEZONE, country.LOCALE), loc.trade_country_cd) = 'N' 
						  			 	then gec_utils_pkg.date_to_number( gec_utils_pkg.get_tplusn(gec_utils_pkg.TO_TIMEZONE(i_curr_date, gec_constants_pkg.C_BOS_TIMEZONE, country.LOCALE), 1, loc.trade_country_cd) )
						  			 else null
						  			 end
						  			)
						  else null
						  end ) as business_date 
					 from gec_locate_preborrow_temp  loc, gec_trade_country country
					where loc.trade_country_cd = country.trade_country_cd
						  and loc.status <> 'X'
						  and loc.business_date is null;
	BEGIN
		--MF20.	If IM request did not contain an explicit Locate Request Date, GEC derives the date
		v_curr_date := NVL(p_curr_date,sysdate);
		
		--If business date is null, to derive business date, according to current date , trade country and calendar.	
		--a.If current date time >= cutoff time, derive it to be next trade date of that country	      
		--b.If current date time < cutoff time and current date of that country is trading day, derive date to be current date of that country 
		--c.If current date time < cutoff time and current date of that country is non-trading day, derive date to be next-trade-day of that country  
		--c.Others, set it to be null.(It should not happen).				          
		FOR v_cur_item IN v_cur_derive_business_date(v_curr_date) LOOP
			UPDATE gec_locate_preborrow_temp temp
			SET  business_date = v_cur_item.business_date
			WHERE temp.Locate_Preborrow_id = v_cur_item.Locate_Preborrow_id;				
		END LOOP;	
			          
		--System will set default country(US) for locate of which asset is not found,
		--So, after derive business date, there should no locate with null business date.				          
		update 	gec_locate_preborrow_temp loc
		   set  business_date = gec_utils_pkg.DATE_TO_NUMBER(sysdate)
		 where  loc.status = 'X'
		   and  loc.business_date is null;		          
				
	END DERIVE_BUSINESS_DATE;
	
	PROCEDURE VALIDATE_STRATEGY(p_transaction_type  IN		VARCHAR2,
								p_errorCode			OUT		VARCHAR2
							)
	IS
		v_fail_flag varchar2(1);
	BEGIN
		--VLD0046:Strategy associated with the IM/Fund is inactive 
		IF(p_transaction_type=gec_constants_pkg.C_LOCATE or p_transaction_type=gec_constants_pkg.C_PREBORROW)	 THEN
			v_fail_flag := 'N';
			BEGIN									  
				SELECT 'Y' INTO v_fail_flag 
				FROM gec_locate_preborrow_temp temp,gec_strategy strategy
				WHERE 
					temp.strategy_id = strategy.strategy_id
					AND strategy.status ='I'
					AND ROWNUM = 1;		     	
			EXCEPTION WHEN NO_DATA_FOUND THEN
				v_fail_flag := 'N';
			END;	
	
			IF v_fail_flag = 'Y' THEN
				p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_INACTIVE_STRATEGY;
				return ;
			END IF;	
		END IF;	
		 
		--Error Code 004: the Investment Manager and strategy contained in this file do not match..
	 	--C_VLD_IM_STRATEGY_NOT_MATCHED VLD0004
		--validate it when filling strategy_id, or validate it by another logic: strategy name must be valid that can find a strategy_id.
		IF(p_transaction_type=gec_constants_pkg.C_LOCATE)	 THEN
			v_fail_flag := 'N';
			BEGIN									  
				SELECT 'Y' INTO v_fail_flag FROM gec_locate_preborrow_temp temp
				WHERE 
					temp.fund_source = 'S' 
					AND ROWNUM = 1
					AND temp.strategy_id IS NULL;		     	
			EXCEPTION WHEN NO_DATA_FOUND THEN
				v_fail_flag := 'N';
			END;	
		
			IF v_fail_flag = 'Y' THEN
				p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_IM_STRATEGY_NOT_MATCHED;
				return ;
			END IF;	
		END IF;
	 	
		--Error Code 009: the strategy associated with this Investment Manager has not been assigned to a fund(s).
		--C_VLD_STRATEGY_NOT_MAPTO_FUND  VLD0009  
		--Assumption: will not have get a file with mutiple IMs
		IF(p_transaction_type=gec_constants_pkg.C_LOCATE)	 THEN
			v_fail_flag := 'Y';
			BEGIN		
				SELECT 'Y' INTO v_fail_flag FROM gec_locate_preborrow_temp temp
				JOIN GEC_CLIENT client
				ON temp.investment_manager_cd = client.client_short_name
				JOIN GEC_STRATEGY strategy 
				ON strategy.client_id = client.client_id	    
				LEFT JOIN GEC_FUND fund 
				ON temp.investment_manager_cd = fund.investment_manager_cd 
					AND temp.strategy_id = fund.strategy_id  
				WHERE strategy.status ='A'
					AND temp.fund_source = 'S'
					AND fund.strategy_id IS NULL
					AND ROWNUM = 1;							
			EXCEPTION WHEN NO_DATA_FOUND THEN
				v_fail_flag := 'N';
			END;
		  
		  	
			IF v_fail_flag = 'Y' THEN
				p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_STRATEGY_HAS_NO_FUND;
				return ;
			END IF;		
		END IF;

		--Error Code 032:the fund associated with this Investment Manager has not been assigned to a strategy.
		--C_VLD_FUND_HAS_NO_STRATEGY VLD0032
			v_fail_flag := 'N';
			BEGIN			
				SELECT 'Y' INTO v_fail_flag  FROM GEC_LOCATE_PREBORROW_TEMP temp
				WHERE temp.fund_cd IS NOT NULL
				      AND temp.fund_source = 'F'
				      AND temp.strategy_id IS NULL
				      AND ROWNUM = 1;		
			EXCEPTION WHEN NO_DATA_FOUND THEN
				v_fail_flag := 'N';
			END;
		  
			IF v_fail_flag = 'Y' THEN
				p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_FUND_HAS_NO_STRATEGY;
				return ;
			END IF;			
	END VALIDATE_STRATEGY;	
	
	PROCEDURE VALIDATE_ORDER_STRATEGY(p_errorCode	OUT		VARCHAR2,
										p_retComment	  OUT SYS_REFCURSOR)
	IS
	v_fail_flag varchar2(1):= 'N';
	BEGIN
		
		--VLD0046:Strategy associated with the IM/Fund is inactive 
		BEGIN	
			SELECT 'Y' INTO v_fail_flag
			FROM gec_im_order_temp temp
			WHERE temp.fund_cd is null
				AND UPPER(temp.TRANSACTION_CD) <> GEC_CONSTANTS_PKG.C_TRAILER
				AND ROWNUM = 1;
			EXCEPTION WHEN NO_DATA_FOUND THEN
				v_fail_flag := 'N';
		END;
			IF v_fail_flag = 'Y' THEN
				p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_FUND_HAS_NO_STRATEGY;
				return ;
			END IF;	
		
		BEGIN							  
			SELECT 'Y' INTO v_fail_flag 
			FROM gec_im_order_temp temp,gec_strategy strategy
			WHERE temp.strategy_id = strategy.strategy_id
				AND UPPER(temp.TRANSACTION_CD) <> GEC_CONSTANTS_PKG.C_TRAILER
				AND strategy.status ='I'
				AND ROWNUM = 1;		     	
			EXCEPTION WHEN NO_DATA_FOUND THEN
				v_fail_flag := 'N';
		END;
		IF v_fail_flag = 'Y' THEN
			p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_INACTIVE_STRATEGY;
			OPEN p_retComment FOR
				SELECT distinct temp.investment_manager_cd ||'/'||temp.fund_cd AS COMMENT_TXT
				FROM gec_im_order_temp temp,gec_strategy strategy
				WHERE temp.strategy_id = strategy.strategy_id
					AND UPPER(temp.TRANSACTION_CD) <> GEC_CONSTANTS_PKG.C_TRAILER
					AND strategy.status ='I';
			return ;
		END IF;	
	END VALIDATE_ORDER_STRATEGY;
	
	PROCEDURE CHECK_ORDER_TRAILER( p_errorCode         OUT 	VARCHAR2)
	IS
		v_trailer_flag 	gec_fund.order_trailer%TYPE;
		v_trailer_count	gec_im_order_temp.share_qty%TYPE;
		v_row_count 	NUMBER(10);
	BEGIN

		BEGIN
			--validation: check if Order file record counts match
			select order_trailer into v_trailer_flag 
			from gec_fund f, gec_im_order_temp lpt
			where f.fund_cd = lpt.fund_cd
			   and f.investment_manager_cd = lpt.investment_manager_cd
			   and rownum = 1;			   
		EXCEPTION WHEN NO_DATA_FOUND THEN
			--If no fund found, do not check trailer.
			v_trailer_flag := 'N'; 
			--p_errorCode := GEC_ERROR_CODE_PKG.C_ORDER_IM_FUND_NOT_MATCHED;
			RETURN;
		END;		
									
		IF v_trailer_flag = 'Y' THEN
			BEGIN
				select share_qty into v_trailer_count 
--				from TABLE ( cast ( p_uploadData as GEC_IM_ORDER_TP_ARRAY) ) irt 
				from gec_im_order_temp irt
				where ( transaction_cd IS NOT NULL AND UPPER(transaction_cd) = GEC_CONSTANTS_PKG.C_TRAILER )
				   and rownum = 1;
			EXCEPTION WHEN NO_DATA_FOUND THEN
				p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_NO_TRAILER;
				RETURN;
			END;
			
			select count(1) into v_row_count 
			from gec_im_order_temp
			where UPPER(transaction_cd) <> GEC_CONSTANTS_PKG.C_TRAILER;
			  
			IF v_trailer_count != v_row_count THEN
				p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_TRAILER_NOT_MATCHED;
				RETURN;
			END IF;
		END IF;
	END CHECK_ORDER_TRAILER;

	PROCEDURE CHECK_LOCATE_TRAILER(	p_uploadData        IN 		GEC_IM_REQUEST_TP_ARRAY,
									p_errorCode         OUT 	VARCHAR2)	
	IS
		v_trailer_flag 	gec_fund.order_trailer%TYPE;
		v_trailer_count	gec_locate_preborrow_temp.share_qty%TYPE;
		v_row_count 	NUMBER(10);
	BEGIN	
		BEGIN
			select request_trailer into v_trailer_flag 
			from gec_fund f, gec_locate_preborrow_temp lpt
			where f.fund_cd = lpt.fund_cd
			   and f.investment_manager_cd = lpt.investment_manager_cd
			   and rownum = 1;
		EXCEPTION WHEN NO_DATA_FOUND THEN
			--If no fund found, do not check trailer.
			v_trailer_flag := 'N'; 
		END;
		
		IF v_trailer_flag = 'Y' THEN
			BEGIN
				select share_qty into v_trailer_count 
				from TABLE ( cast ( p_uploadData as GEC_IM_REQUEST_TP_ARRAY) ) irt 
				where ( transaction_cd IS NOT NULL AND UPPER(transaction_cd) = GEC_CONSTANTS_PKG.C_TRAILER )
				   and rownum = 1;
			EXCEPTION WHEN NO_DATA_FOUND THEN
				p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_NO_TRAILER;
				RETURN;
			END;
			
			select count(1) into v_row_count 
			from gec_locate_preborrow_temp ;		
			  
			IF v_trailer_count != v_row_count THEN
				p_errorCode := GEC_ERROR_CODE_PKG.C_VLD_TRAILER_NOT_MATCHED;
				RETURN;
			END IF;
		END IF;	
	END CHECK_LOCATE_TRAILER;	

	--FILL Default fund_cd, client_cd
	PROCEDURE FILL_DEFAULTS
	IS
			CURSOR v_cur_defaults IS
			SELECT           
            	lpt.rowid,			
            	NVL(lpt.FUND_CD , case when lpt.strategy_id is not null then fundclient.IM_DEFAULT_FUND_CD else '' end) FUND_CD,	            	
			   	NVL(lpt.CLIENT_CD, fundclient.CLIENT_CD) CLIENT_CD,
			   	NVL(lpt.SB_BROKER, fundclient.DML_SB_Broker) DML_SB_Broker,
            	lpt.IM_USER_ID,
            	lpt.LOCATE_PREBORROW_ID,
            	fundclient.IM_DEFAULT_FUND_CD, 
            	fundclient.CLIENT_CD IM_DEFAULT_CLIENT_CD				
			FROM gec_locate_preborrow_temp lpt 
			LEFT JOIN 
      		( 
          		SELECT 
          		client.CLIENT_SHORT_NAME, 
          		strategy.IM_DEFAULT_FUND_CD,
          		fund.CLIENT_CD,
          		fund.DML_SB_Broker,
          		strategy.strategy_id 
          		FROM GEC_Strategy strategy, GEC_CLIENT client,GEC_FUND fund 
          		WHERE strategy.IM_DEFAULT_FUND_CD = fund.FUND_CD
          		  AND strategy.client_id = client.client_id
      		) fundclient
    	ON lpt.strategy_id = fundclient.strategy_id;   
    BEGIN 
    
	--set default client  , default fund.
	FOR v_rec in v_cur_defaults LOOP		
			update gec_locate_preborrow_temp
				set fund_cd = v_rec.fund_cd,
					im_default_fund_cd = v_rec.im_default_fund_cd,
					im_default_client_cd = v_rec.im_default_client_cd,
					client_cd = v_rec.client_cd,
					sb_broker = v_rec.dml_sb_broker   	
			where rowid = v_rec.rowid;				
		END LOOP;
    END FILL_DEFAULTS;
	
	--FILL STRATEGY ID
	PROCEDURE FILL_STRATEGY
	IS
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_VALIDATION_PKG.FILL_STRATEGY';
	   	--GEC-768 :
		--If SS user imported "Import locate request " file with blank fund field 
		--    and If the IM has assigned to single strategy 
		--    then "Import locate request" file should upload all the records with single strategy created to the IM.
		CURSOR v_cur_single_strategy IS
			SELECT t.rowid, s.strategy_id, s.im_default_fund_cd AS fund_cd, 'S' AS fund_source
			FROM gec_client c, gec_locate_preborrow_temp t, gec_strategy s,
			  		(SELECT client_id, count(*) cnt
					   FROM gec_strategy
					  WHERE status = 'A'
					  GROUP BY client_id
					 HAVING count(*) = 1) sn
			 WHERE sn.client_id = c.client_id
			   AND s.client_id = c.client_id
			   AND c.client_short_name = t.investment_manager_cd
			   AND t.transaction_cd = gec_constants_pkg.C_LOCATE -- preborrow do not need to assign single active strategy			   
			   AND s.status = 'A'
			   AND t.fund_cd is null;
		  		
    	-- SET FUND_SOURCE WHEN 'IM FILE'
		-- Set Stragegy_id According to fund cd
		CURSOR v_cur_fund_to_strategyid IS
			SELECT temp.rowid,
				fund.strategy_id,
				'F' fund_source,
				strategy.status
			FROM gec_locate_preborrow_temp temp
			INNER JOIN gec_fund fund
			ON 	temp.fund_cd = fund.fund_cd
				AND temp.INVESTMENT_MANAGER_CD = fund.investment_manager_cd
			LEFT JOIN gec_strategy strategy
			ON fund.strategy_id = strategy.strategy_id
			AND strategy.status in ('A','I')
			WHERE 
			 temp.strategy_id IS NULL;
			
		-- Set Stragegy_id According to stragegy name
		CURSOR v_cur_strategyname_to_id IS
			SELECT 
				temp.rowid,
				strategy.strategy_id,
				'S' fund_source,
				strategy.im_default_fund_cd fund_cd,
				strategy.status
			FROM gec_locate_preborrow_temp temp, gec_strategy strategy , gec_client client
			WHERE temp.fund_cd = strategy.strategy_name
				AND temp.INVESTMENT_MANAGER_CD = client.client_short_name 
				AND temp.transaction_cd = GEC_CONSTANTS_PKG.C_LOCATE --PREBORROW DO NOT UPLOAD WITH STRATEGY NAME
				AND strategy.client_id = client.client_id
				AND client.client_status = 'A'
				AND strategy.status IN( 'A','I')
				AND temp.strategy_id IS NULL;
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
		--Fill strategy,fund If the IM has only one active strategy
		FOR v_rec in v_cur_single_strategy
		LOOP
			update gec_locate_preborrow_temp
			   set strategy_id = v_rec.strategy_id,
			       fund_source = v_rec.fund_source,
			       fund_cd = v_rec.fund_cd
			 where rowid = v_rec.rowid;
	   	END LOOP;
	   	
		--set stragegy id according to fund cd
		FOR v_rec in v_cur_fund_to_strategyid 
		LOOP	
			--If STRATEGY STATUS IS (A)ctive, set strategy,else(INACTIVE) null
			update gec_locate_preborrow_temp
				set strategy_id = v_rec.strategy_id,	
					fund_source = v_rec.fund_source  
			where rowid = v_rec.rowid;
				
		END LOOP;
	
		--set strategy id according to stragety name
		FOR v_rec in v_cur_strategyname_to_id 
		LOOP
			update gec_locate_preborrow_temp
				set strategy_id = v_rec.strategy_id,	
					fund_source = v_rec.fund_source,
					fund_cd = DECODE(v_rec.status,'A',v_rec.fund_cd , '')
			where rowid = v_rec.rowid;		
		
		END LOOP;			
		 
		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END FILL_STRATEGY;
																							
		                         
	--VALICATE IM ORDER REQUEST
	PROCEDURE VALIDATE_IM_ORDER(p_checkTrailer 	 	IN 	VARCHAR2,
								p_errorCode         OUT VARCHAR2,
								p_retComment	  OUT SYS_REFCURSOR)	
	IS
		v_trailer_flag gec_fund.order_trailer%type;
		v_trailer_count NUMBER(10);
		v_row_count NUMBER(10);
		v_fail_flag VARCHAR2(1);
	BEGIN	
		--p_retComment is added to point out which IM/STRATEGY/FUND IS INVALID IN APP.
		OPEN p_retComment FOR
			SELECT NULL COMMENTS FROM DUAL WHERE 1=0;
		-- It intends to do pretreatment before process im order.
		-- 1.set default client_cd and default fund_cd.
		--PREPARE_ORDER;  
		
		--BASIC VALIDATION
		VALIDATE_ORDER_BASIC_INFO(GEC_CONSTANTS_PKG.C_SHORT,p_errorCode);
		IF p_errorCode IS NOT NULL THEN
			RETURN;	
		END IF; 	
		
		--validate investment manager
		validate_order_im(gec_constants_pkg.C_SHORT,p_errorCode,p_retComment);	
		IF p_errorCode IS NOT NULL THEN
			RETURN;	
		END IF; 	
		
		--FILL STRATEGY ID
		--FILL_STRATEGY;	
		--validate strategy			
		VALIDATE_ORDER_STRATEGY(p_errorCode,p_retComment);	
		IF p_errorCode IS NOT NULL THEN
			RETURN;	
		END IF; 		
		
		--CORRECT ALL TRADE COUNTRIES TO SHORT NAME LIKE USD->US
		TRANSFORM_ORDER_TRADE_COUNTRY;
		
		--FILL Default fund_cd, client_cd
		--FILL_DEFAULTS;	
		--validate fund
		validate_order_fund(gec_constants_pkg.C_SHORT,p_errorCode,p_retComment);	
		IF p_errorCode IS NOT NULL THEN
			RETURN;	
		END IF; 
						
		--Validation: If the request is not from 'Call', we will check the trailer if IM Request file record counts match.
		--If sourced from IM File , do validation of trailer.
		--If check trailer('Y')and sourced from traider im file upload , it needs to check trailer.
		IF p_checkTrailer = 'Y' THEN  
			CHECK_ORDER_TRAILER(p_errorCode);
			
			IF p_errorCode IS NOT NULL THEN
				RETURN;	
			END IF; 				
		END IF;		
		
		FILL_ORDER_TEMP_WITH_ASSET(GEC_CONSTANTS_PKG.C_SHORT);
		
		--TRADE DATE, SETTLE DATE VALIDATION
		VALIDATE_ORDER_INPUT_DATE(p_errorCode);
		IF p_errorCode IS NOT NULL THEN
			RETURN;	
		END IF; 
		
		VALIDATE_ORDER_SETTLE_LOCATION(p_errorCode,p_retComment);
		IF p_errorCode IS NOT NULL THEN
			RETURN;	
		END IF; 
	END VALIDATE_IM_ORDER;   	


	PROCEDURE VALIDATE_STRATEGY_PROFILE
	IS
		CURSOR v_cur_strategy_profile IS
		SELECT temp.Locate_Preborrow_id
		FROM GEC_LOCATE_PREBORROW_temp temp
		LEFT JOIN GEC_STRATEGY_PROFILE pro
		ON temp.strategy_id = pro.strategy_id
		AND	temp.trade_country_cd = pro.trade_country_cd
		AND pro.status='A'
		WHERE temp.strategy_id is not null
		AND temp.trade_country_cd is not null
		AND pro.strategy_id is null	;
	BEGIN
	
		FOR v_curr_item IN v_cur_strategy_profile LOOP
			UPDATE gec_locate_preborrow_temp temp
			SET temp.status = 'X',
				temp.comment_txt = GEC_UTILS_PKG.SUB_COMMENT(comment_txt||GEC_ERROR_CODE_PKG.C_VLD_MSG_NO_STRATEGY_PROFILE)
			WHERE temp.Locate_Preborrow_id = v_curr_item.Locate_Preborrow_id;		
		END LOOP;
			          		
	END VALIDATE_STRATEGY_PROFILE;

	PROCEDURE TRANSFORM_TRADE_COUNTRY
	IS
		CURSOR v_cur_set_trade_country IS
		select 	loc.locate_preborrow_id, country.trade_country_cd
		from 	gec_locate_preborrow_temp  loc , GEC_TRADE_COUNTRY country
		where 	length(loc.trade_country_cd) = 3 
		and 	country.currency_cd = loc.trade_country_cd;
	BEGIN
		
		FOR VAR_REC IN  v_cur_set_trade_country LOOP
		
			update gec_locate_preborrow_temp temp
			 set	trade_country_cd = 	VAR_REC.trade_country_cd
			where temp.Locate_Preborrow_id = VAR_REC.Locate_Preborrow_id ;
		
		end LOOP;
										
	END TRANSFORM_TRADE_COUNTRY;
	
	PROCEDURE TRANSFORM_ORDER_TRADE_COUNTRY
	IS
		CURSOR v_cur_set_trade_country IS
		select 	loc.im_order_id, country.trade_country_cd
		from 	gec_im_order_temp  loc , GEC_TRADE_COUNTRY country
		where 	length(loc.trade_country_cd) = 3 
		and 	country.currency_cd = loc.trade_country_cd;
	BEGIN
		
		FOR VAR_REC IN  v_cur_set_trade_country LOOP
		
			update gec_im_order_temp temp
			 set	trade_country_cd = 	VAR_REC.trade_country_cd
			where temp.im_order_id = VAR_REC.im_order_id ;
		
		end LOOP;
										
	END TRANSFORM_ORDER_TRADE_COUNTRY;
	
	PROCEDURE VALIDATE_PREBORROW_COUNTRY
	IS
		CURSOR v_cur_preborrow_country IS
			SELECT temp.locate_preborrow_id
			FROM GEC_LOCATE_PREBORROW_temp temp
			LEFT JOIN GEC_STRATEGY_PROFILE pro
			ON temp.strategy_id = pro.strategy_id
				AND	temp.trade_country_cd = pro.trade_country_cd
				AND pro.status='A'
			LEFT JOIN GEC_TRADE_COUNTRY gtc
			ON gtc.trade_country_cd = temp.trade_country_cd   
			WHERE gtc.preborrow_eligible_flag = 'N' OR gtc.preborrow_eligible_flag IS NULL
				AND temp.strategy_id is not null
				AND temp.trade_country_cd is not null;
	BEGIN
	
		FOR v_cur_item in v_cur_preborrow_country LOOP
			UPDATE GEC_LOCATE_PREBORROW_temp temp
				SET status = 'X',
					COMMENT_TXT = GEC_UTILS_PKG.SUB_COMMENT(comment_txt||GEC_ERROR_CODE_PKG.C_VLD_MSG_NO_PREBORROW_COUNTRY),
					INTERNAL_COMMENT_TXT = GEC_UTILS_PKG.SUB_COMMENT(INTERNAL_COMMENT_TXT||GEC_ERROR_CODE_PKG.C_VLD_MSG_NO_PREBORROW_COUNTRY)
			WHERE temp.locate_preborrow_id =  v_cur_item.locate_preborrow_id;
			
		END LOOP;
			           							
	END VALIDATE_PREBORROW_COUNTRY;

	PROCEDURE VALIDATE_COUNTRY_FOR_LOCATE(p_locate_on_preborrow_cntry OUT VARCHAR2)
	IS
	BEGIN
		SELECT 'Y' INTO p_locate_on_preborrow_cntry FROM DUAL
			WHERE EXISTS (
				SELECT 1
				FROM GEC_LOCATE_PREBORROW_temp temp
				INNER JOIN GEC_STRATEGY_PROFILE pro
				ON temp.strategy_id = pro.strategy_id
					AND	temp.trade_country_cd = pro.trade_country_cd
					AND pro.status='A'
				INNER JOIN GEC_TRADE_COUNTRY gtc
				ON gtc.trade_country_cd = temp.trade_country_cd   
				WHERE gtc.preborrow_eligible_flag = 'Y'
				AND temp.ASSET_ID Is Not Null);
			EXCEPTION WHEN NO_DATA_FOUND THEN
			p_locate_on_preborrow_cntry := 'N';
		RETURN;
	END VALIDATE_COUNTRY_FOR_LOCATE;

    PROCEDURE FILL_REQUEST_TEMP_WITH_ASSET( p_transactionCd  IN 	VARCHAR2)
	IS
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_VALIDATION_PKG.FILL_REQUEST_TEMP_WITH_ASSET';
		var_asset_infor gec_asset%ROWTYPE;
		var_asset_rs GEC_ASSET_TP_ARRAY;
		var_asset GEC_ASSET_TP;
		var_found_flag NUMBER;  
		var_asset_code_type gec_asset_identifier.asset_code_type%type;
		var_status varchar2(1);
    	var_default_trade_cty gec_locate_preborrow_temp.trade_country_cd%type;
    	var_comment gec_locate_preborrow_temp.COMMENT_TXT%type;
    	var_internal_comment gec_locate_preborrow_temp.COMMENT_TXT%type;
		CURSOR var_rec_cur IS
			SELECT  cusip,
					isin,
					sedol,
					quik,
					ticker,
					description,
					trade_country_cd,
					asset_code,
					asset_code_type,
	        		asset_id,
					rowid
			 FROM gec_locate_preborrow_temp;
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
		
		--the default will be used only if there is no security found. If multiple securities are found, the default value will not be used.
    	IF p_transactionCd = GEC_CONSTANTS_PKG.C_PREBORROW THEN
 			var_default_trade_cty := 'AU';
    	ELSE
        	var_default_trade_cty := 'US';
    	END IF;
    
		FOR VAR_REC IN  var_rec_cur LOOP
    
			IF (VAR_REC.asset_id IS NOT NULL AND VAR_REC.asset_id <> 0) THEN 
		          var_found_flag := 1; 
		          SELECT * 
		          INTO var_asset_infor
		          FROM gec_asset
		          WHERE asset_id = VAR_REC.asset_id;    
			ELSE
	       
				VALIDATE_ASSET_ID( VAR_REC.cusip, 
		                      VAR_REC.isin  ,
		                      VAR_REC.sedol ,
		                      VAR_REC.quik ,
		                      VAR_REC.ticker ,
		                      VAR_REC.description ,
		                      VAR_REC.trade_country_cd ,
		                      VAR_REC.asset_code ,
		                      VAR_REC.asset_code_type,
		                      var_found_flag, 
		                      var_asset_code_type,
		                      var_status ,
		                      var_asset_rs);
				IF var_found_flag = 1 AND var_asset_rs.COUNT = 1 THEN
					var_asset := var_asset_rs(1);
					var_asset_infor.asset_id := var_asset.asset_id;
					var_asset_infor.cusip := var_asset.cusip;
					var_asset_infor.isin := var_asset.isin;
					var_asset_infor.sedol := var_asset.sedol;
					var_asset_infor.quik := var_asset.quik;
					var_asset_infor.ticker := var_asset.ticker;
					var_asset_infor.description := var_asset.description;
					var_asset_infor.source_flag := var_asset.source_flag;
					var_asset_infor.trade_country_cd := var_asset.trade_country_cd;
					var_asset_infor.asset_type_id := var_asset.asset_type_id;					
				END IF;
			END IF;
       
			IF var_found_flag = 1 THEN
				UPDATE gec_locate_preborrow_temp
				SET 
					asset_id = var_asset_infor.asset_id,
					cusip = var_asset_infor.cusip,
					isin = var_asset_infor.isin,
					sedol = var_asset_infor.sedol,
					quik = var_asset_infor.quik,
					trade_country_cd = NVL(var_asset_infor.trade_country_cd, var_default_trade_cty),
                    ticker = var_asset_infor.ticker,
					description = var_asset_infor.description,
					asset_code_type = var_asset_code_type,
					asset_type_id = var_asset_infor.asset_type_id
				WHERE rowid = VAR_REC.rowid;
			ELSE
		        IF var_found_flag = 0 THEN 
		             var_comment :=  GEC_ERROR_CODE_PKG.C_VLD_MSG_ASSET_INVALID;
				      IF p_transactionCd IN( GEC_CONSTANTS_PKG.C_PREBORROW, GEC_CONSTANTS_PKG.C_LOCATE) THEN
				         var_internal_comment := GEC_ERROR_CODE_PKG.C_VLD_MSG_ASSET_INVALID;
				     ELSE
				         var_internal_comment := '';
				     END IF;
		
		        ELSE
		             var_comment :=  GEC_ERROR_CODE_PKG.C_VLD_MSG_ASSET_MULTIPLE; 
		             var_status :='X';
		        END IF;
        
		        IF VAR_REC.asset_code_type IS NOT NULL THEN
		          UPDATE gec_locate_preborrow_temp
		          SET 
			            cusip = case when asset_code_type = GEC_CONSTANTS_PKG.C_CSP then (case when length(asset_code)<=8 and REGEXP_LIKE(asset_code,'^[0-9]+$') then LPAD(asset_code,9,'0') else asset_code end) 
			            			else cusip end, 
			            isin = case when asset_code_type = GEC_CONSTANTS_PKG.C_ISN then asset_code  else isin end, 
			            sedol = case when asset_code_type = GEC_CONSTANTS_PKG.C_SED then asset_code  else sedol end, 
			            quik = case when asset_code_type = GEC_CONSTANTS_PKG.C_QUK then asset_code  else quik end, 
			            ticker = case when asset_code_type = GEC_CONSTANTS_PKG.C_TIK then asset_code  else ticker end
			      WHERE rowid = VAR_REC.rowid;
		        ELSE
		          UPDATE gec_locate_preborrow_temp
		          SET 
			            cusip = case when (LENGTH(asset_code)=8 or LENGTH(asset_code)=9)  then asset_code  else cusip end, 
			            isin = case when (LENGTH(asset_code)>9)  then asset_code else isin end, 
			            sedol = case when (LENGTH(asset_code)=6 or LENGTH(asset_code)=7) then asset_code  else sedol end, 
			            quik = case when (LENGTH(asset_code)=4 and var_asset_code_type = GEC_CONSTANTS_PKG.C_QUK)  then asset_code when (LENGTH(asset_code)=5) then asset_code else quik end, 
			            ticker = case when (LENGTH(asset_code)>0 and LENGTH(asset_code)< 4)  then asset_code when (LENGTH(asset_code)=4 and var_asset_code_type = GEC_CONSTANTS_PKG.C_TIK) then asset_code else ticker end
			       WHERE rowid = VAR_REC.rowid;
		        END IF;
				UPDATE gec_locate_preborrow_temp
				SET 
					 cusip = case when LENGTH(cusip)>9 then substr(cusip,1,9) when length(cusip)<=8 and REGEXP_LIKE(cusip,'^[0-9]+$') then LPAD(cusip,9,'0') else cusip end, 
					 isin =  case when LENGTH(isin)>12 then substr(isin,1,12) else isin end, 
					 sedol =  case when LENGTH(sedol)>7 then substr(sedol,1,7) else sedol end, 
					 quik = case when LENGTH(quik)>5 then substr(quik,1,5) else quik end, 
					 trade_country_cd =  NVL(case when LENGTH(trade_country_cd)>3 then substr(trade_country_cd,1,3) else trade_country_cd end, 
					 							DECODE(var_found_flag, 0, var_default_trade_cty, '') ), 
					 asset_code_type = case when LENGTH(asset_code_type)>3 then substr(asset_code_type,1,3) else asset_code_type end, 
					 STATUS = UPDATE_REQUET_STARUS(STATUS, var_status),
				     INTERNAL_COMMENT_TXT = GEC_UTILS_PKG.SUB_COMMENT(INTERNAL_COMMENT_TXT||var_internal_comment),
				     COMMENT_TXT =  GEC_UTILS_PKG.SUB_COMMENT(COMMENT_TXT||var_comment)
				WHERE rowid = VAR_REC.rowid;
			END IF;
		END LOOP;  

		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END FILL_REQUEST_TEMP_WITH_ASSET; 
  
  	 PROCEDURE FILL_ORDER_TEMP_WITH_ASSET( p_transactionCd  IN 	VARCHAR2)
	IS
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_VALIDATION_PKG.FILL_ORDER_TEMP_WITH_ASSET';
		var_asset_infor gec_asset%ROWTYPE;
		var_asset_rs GEC_ASSET_TP_ARRAY;
		var_asset GEC_ASSET_TP;
		var_found_flag NUMBER;  
		var_asset_code_type gec_asset_identifier.asset_code_type%type;
		var_status varchar2(1);
    	var_default_trade_cty gec_locate_preborrow_temp.trade_country_cd%type;
    	var_comment gec_locate_preborrow_temp.COMMENT_TXT%type;
    	var_internal_comment gec_locate_preborrow_temp.COMMENT_TXT%type;
		CURSOR var_rec_cur IS
			SELECT  cusip,
					isin,
					sedol,
					quik,
					ticker,
					description,
					trade_country_cd,
					asset_code,
					asset_code_type,
	        		asset_id,
					rowid
			 FROM gec_im_order_temp;
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
		
		--the default will be used only if there is no security found. If multiple securities are found, the default value will not be used.
    	--IF p_transactionCd = GEC_CONSTANTS_PKG.C_PREBORROW THEN
 		--	var_default_trade_cty := 'AU';
    	--ELSE
        	var_default_trade_cty := 'US';
    	--END IF;
    
		FOR VAR_REC IN  var_rec_cur LOOP
    
			IF (VAR_REC.asset_id IS NOT NULL AND VAR_REC.asset_id <> 0) THEN 
		          var_found_flag := 1; 
		          SELECT * 
		          INTO var_asset_infor
		          FROM gec_asset
		          WHERE asset_id = VAR_REC.asset_id;    
			ELSE
	       
				VALIDATE_ASSET_ID( VAR_REC.cusip, 
		                      VAR_REC.isin  ,
		                      VAR_REC.sedol ,
		                      VAR_REC.quik ,
		                      VAR_REC.ticker ,
		                      VAR_REC.description ,
		                      VAR_REC.trade_country_cd ,
		                      VAR_REC.asset_code ,
		                      VAR_REC.asset_code_type,
		                      var_found_flag, 
		                      var_asset_code_type,
		                      var_status ,
		                      var_asset_rs);
				IF var_found_flag = 1 AND var_asset_rs.COUNT = 1 THEN
					var_asset := var_asset_rs(1);
					var_asset_infor.asset_id := var_asset.asset_id;
					var_asset_infor.cusip := var_asset.cusip;
					var_asset_infor.isin := var_asset.isin;
					var_asset_infor.sedol := var_asset.sedol;
					var_asset_infor.quik := var_asset.quik;
					var_asset_infor.ticker := var_asset.ticker;
					var_asset_infor.description := var_asset.description;
					var_asset_infor.source_flag := var_asset.source_flag;
					var_asset_infor.trade_country_cd := var_asset.trade_country_cd;
					var_asset_infor.asset_type_id := var_asset.asset_type_id;					
				END IF;
			END IF;
       
			IF var_found_flag = 1 THEN
				UPDATE gec_im_order_temp
				SET 
					asset_id = var_asset_infor.asset_id,
					cusip = var_asset_infor.cusip,
					isin = var_asset_infor.isin,
					sedol = var_asset_infor.sedol,
					quik = var_asset_infor.quik,
					trade_country_cd = NVL(var_asset_infor.trade_country_cd, var_default_trade_cty),
                    ticker = var_asset_infor.ticker,
					description = var_asset_infor.description,
					asset_code_type = var_asset_code_type,
					asset_type_id = var_asset_infor.asset_type_id
				WHERE rowid = VAR_REC.rowid;
			ELSE
		        IF var_found_flag = 0 THEN 
		             var_comment :=  GEC_ERROR_CODE_PKG.C_VLD_MSG_ASSET_INVALID;
--				      IF p_transactionCd IN( GEC_CONSTANTS_PKG.C_PREBORROW, GEC_CONSTANTS_PKG.C_LOCATE) THEN
--				         var_internal_comment := GEC_ERROR_CODE_PKG.C_VLD_MSG_ASSET_INVALID;
--				     ELSE
--				         var_internal_comment := '';
--				     END IF;
					var_status :='X';
		        ELSE
		             var_comment :=  GEC_ERROR_CODE_PKG.C_VLD_MSG_ASSET_MULTIPLE; 
		             var_status :='X';
		        END IF;
        
		        IF VAR_REC.asset_code_type IS NOT NULL THEN
		          UPDATE gec_im_order_temp
		          SET 
			            cusip = case when asset_code_type = GEC_CONSTANTS_PKG.C_CSP then (case when length(asset_code)<=8 and REGEXP_LIKE(asset_code,'^[0-9]+$') then LPAD(asset_code,9,'0') else asset_code end) 
			            			else cusip end, 
			            isin = case when asset_code_type = GEC_CONSTANTS_PKG.C_ISN then asset_code  else isin end, 
			            sedol = case when asset_code_type = GEC_CONSTANTS_PKG.C_SED then asset_code  else sedol end, 
			            quik = case when asset_code_type = GEC_CONSTANTS_PKG.C_QUK then asset_code  else quik end, 
			            ticker = case when asset_code_type = GEC_CONSTANTS_PKG.C_TIK then asset_code  else ticker end
			      WHERE rowid = VAR_REC.rowid;
		        ELSE
		          UPDATE gec_im_order_temp
		          SET 
			            cusip = case when (LENGTH(asset_code)=8 or LENGTH(asset_code)=9)  then asset_code  else cusip end, 
			            isin = case when (LENGTH(asset_code)>9)  then asset_code else isin end, 
			            sedol = case when (LENGTH(asset_code)=6 or LENGTH(asset_code)=7) then asset_code  else sedol end, 
			            quik = case when (LENGTH(asset_code)=4 and var_asset_code_type = GEC_CONSTANTS_PKG.C_QUK)  then asset_code when (LENGTH(asset_code)=5) then asset_code else quik end, 
			            ticker = case when (LENGTH(asset_code)>0 and LENGTH(asset_code)< 4)  then asset_code when (LENGTH(asset_code)=4 and var_asset_code_type = GEC_CONSTANTS_PKG.C_TIK) then asset_code else ticker end
			       WHERE rowid = VAR_REC.rowid;
		        END IF;
				UPDATE gec_im_order_temp
				SET 
					 cusip = case when LENGTH(cusip)>9 then substr(cusip,1,9) when length(cusip)<=8 and REGEXP_LIKE(cusip,'^[0-9]+$') then LPAD(cusip,9,'0') else cusip end, 
					 isin =  case when LENGTH(isin)>12 then substr(isin,1,12) else isin end, 
					 sedol =  case when LENGTH(sedol)>7 then substr(sedol,1,7) else sedol end, 
					 quik = case when LENGTH(quik)>5 then substr(quik,1,5) else quik end, 
					 trade_country_cd =  NVL(case when LENGTH(trade_country_cd)>3 then substr(trade_country_cd,1,3) else trade_country_cd end, 
					 							DECODE(var_found_flag, 0, var_default_trade_cty, '') ), 
					 asset_code_type = case when LENGTH(asset_code_type)>3 then substr(asset_code_type,1,3) else asset_code_type end, 
					 STATUS = UPDATE_REQUET_STARUS(STATUS, var_status),
				     INTERNAL_COMMENT_TXT = GEC_UTILS_PKG.SUB_COMMENT(INTERNAL_COMMENT_TXT||var_internal_comment),
				     COMMENT_TXT =  GEC_UTILS_PKG.SUB_COMMENT(COMMENT_TXT||var_comment)
				WHERE rowid = VAR_REC.rowid;
			END IF;
		END LOOP;  

		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END FILL_ORDER_TEMP_WITH_ASSET; 
  
	PROCEDURE VALIDATE_ASSET_ID(
	                      p_cusip IN VARCHAR2,
	                      p_isin IN VARCHAR2,
	                      p_sedol IN VARCHAR2,
	                      p_quik IN VARCHAR2,
	                      p_ticker IN VARCHAR2,
	                      p_description IN VARCHAR2,
	                      p_trade_country_cd IN VARCHAR2,
	                      p_asset_code IN VARCHAR2,
	                      p_asset_code_type IN VARCHAR2,
	                      var_found_flag OUT NUMBER, 
	                      var_asset_code_type OUT gec_asset_identifier.asset_code_type%type,
	                      var_status OUT VARCHAR2,
	                      var_asset_infor OUT GEC_ASSET_TP_ARRAY)
	IS
	    v_asset GEC_ASSET_TP;
	    v_asset_rs GEC_ASSET_TP_ARRAY := GEC_ASSET_TP_ARRAY();
	    v_deleted_no number(5) := 0;
	    v_index number(5) := 0;
	BEGIN
	    var_found_flag := 0;
	    var_status := null;
	    var_asset_infor := GEC_ASSET_TP_ARRAY();
		IF p_CUSIP IS NOT NULL THEN
			BEGIN
				SELECT GEC_ASSET_TP(ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, SOURCE_FLAG, TRADE_COUNTRY_CD, p_asset_code, p_asset_code_type,ASSET_TYPE_ID) 
				  BULK COLLECT INTO VAR_ASSET_INFOR 
				  FROM gec_asset 
				 WHERE cusip = p_cusip;
				
				var_found_flag := VAR_ASSET_INFOR.COUNT;
				CASE var_found_flag
					WHEN 0 THEN var_status:='E';
					WHEN 1 THEN var_asset_code_type := GEC_CONSTANTS_PKG.C_CSP;
					ELSE var_status:='E';
				END CASE;
			END;
				
			IF  var_found_flag <> 1 AND LENGTH(p_cusip) = 8 THEN
				BEGIN
					SELECT GEC_ASSET_TP(ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, SOURCE_FLAG, TRADE_COUNTRY_CD, p_asset_code, p_asset_code_type,ASSET_TYPE_ID) 
				  	  BULK COLLECT INTO VAR_ASSET_INFOR 
					  FROM gec_asset 
					 WHERE substr(cusip,1,8) = p_cusip;
					
					var_found_flag := VAR_ASSET_INFOR.COUNT;
    				CASE var_found_flag
    					WHEN 0 THEN var_status:='E';
    					WHEN 1 THEN var_asset_code_type := GEC_CONSTANTS_PKG.C_CSP;
    					ELSE var_status:='E';
    				END CASE;
				END;				
			END IF;	
				
			IF  var_found_flag <> 1 AND LENGTH(p_cusip) <= 8 AND REGEXP_LIKE(p_cusip,'^[0-9]+$') THEN
  				BEGIN
					SELECT GEC_ASSET_TP(ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, SOURCE_FLAG, TRADE_COUNTRY_CD, p_asset_code, p_asset_code_type,ASSET_TYPE_ID) 
				  	  BULK COLLECT INTO VAR_ASSET_INFOR 
					  FROM gec_asset 
					 WHERE cusip = LPAD(p_cusip,9,'0');
				
					var_found_flag := VAR_ASSET_INFOR.COUNT;
					IF var_found_flag = 1 THEN
						var_asset_code_type := GEC_CONSTANTS_PKG.C_CSP;
					END IF;
				END;
			END IF;
	      
			IF var_found_flag <> 1 THEN 
				CASE
					WHEN LENGTH(p_cusip) = 8 OR LENGTH(p_cusip) = 9 THEN
					      var_status:='E';
				    WHEN LENGTH(p_cusip) < 8 AND LENGTH(p_cusip) > 3 AND REGEXP_LIKE(p_cusip,'^[0-9]+$') THEN
					      var_status:='E';
					ELSE  var_status:='X';
				END CASE;
			END IF;
		END IF; --IF p_CUSIP IS NOT NULL
			
		IF var_found_flag <> 1 AND p_SEDOL IS NOT NULL THEN
			BEGIN
				SELECT GEC_ASSET_TP(ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, SOURCE_FLAG, TRADE_COUNTRY_CD, p_asset_code, p_asset_code_type,ASSET_TYPE_ID) 
			  	  BULK COLLECT INTO VAR_ASSET_INFOR 
				  FROM gec_asset 
				 WHERE SEDOL = p_SEDOL;
				
				var_found_flag := VAR_ASSET_INFOR.COUNT;
				IF var_found_flag = 1 THEN
					var_asset_code_type := GEC_CONSTANTS_PKG.C_SED;
				END IF;
			END;
			
			IF var_found_flag <> 1 AND LENGTH(p_SEDOL) < 7 AND REGEXP_LIKE(p_SEDOL,'^[0-9]+$') THEN
				BEGIN SELECT GEC_ASSET_TP(ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, SOURCE_FLAG, TRADE_COUNTRY_CD, p_asset_code, p_asset_code_type,ASSET_TYPE_ID) 
			  	  BULK COLLECT INTO VAR_ASSET_INFOR 
				  FROM gec_asset 
				  WHERE SEDOL = LPAD(p_SEDOL,7,'0');
				 
					var_found_flag := VAR_ASSET_INFOR.COUNT;
					IF var_found_flag = 1 THEN
						var_asset_code_type := GEC_CONSTANTS_PKG.C_SED;
					END IF;
				END;
			END IF;
			
--			IF  var_found_flag <> 1 AND LENGTH(p_SEDOL) = 7 AND REGEXP_LIKE(p_SEDOL,'^[0-9]+$') THEN
--  				BEGIN
--					SELECT GEC_ASSET_TP(ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, SOURCE_FLAG, TRADE_COUNTRY_CD, p_asset_code, p_asset_code_type) 
--				  	  BULK COLLECT INTO VAR_ASSET_INFOR 
--					  FROM gec_asset 
--					 WHERE cusip = LPAD(p_SEDOL,9,'0');
					
--					var_found_flag := VAR_ASSET_INFOR.COUNT;
--					IF var_found_flag = 1 THEN
--						var_asset_code_type := GEC_CONSTANTS_PKG.C_CSP;
--					END IF;
--				END;
--			END IF;	

	        IF  var_found_flag != 1 THEN
	        	IF  LENGTH(p_SEDOL) = 7 THEN
	            	var_status:='E';
	        	ELSE
	              var_status:='X';
	            END IF;    
	        END IF;
		END IF; --IF var_found_flag <> 1 AND p_SEDOL IS NOT NULL
      
		IF var_found_flag <> 1 AND p_ISIN IS NOT NULL THEN
			IF p_TRADE_COUNTRY_CD IS NOT NULL THEN
				BEGIN
					SELECT GEC_ASSET_TP(ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, SOURCE_FLAG, TRADE_COUNTRY_CD, p_asset_code, p_asset_code_type,ASSET_TYPE_ID) 
				  	  BULK COLLECT INTO VAR_ASSET_INFOR 
					  FROM gec_asset 
					 WHERE ISIN = p_ISIN
					   AND TRADE_COUNTRY_CD = p_TRADE_COUNTRY_CD;
					
					var_found_flag := VAR_ASSET_INFOR.COUNT;
					IF var_found_flag = 1 THEN
						var_asset_code_type := GEC_CONSTANTS_PKG.C_ISN;
					END IF;
				END;
			ELSE
				BEGIN
					SELECT GEC_ASSET_TP(ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, SOURCE_FLAG, TRADE_COUNTRY_CD, p_asset_code, p_asset_code_type,ASSET_TYPE_ID) 
				  	  BULK COLLECT INTO VAR_ASSET_INFOR 
					  FROM gec_asset 
					 WHERE ISIN = p_ISIN;
				
					var_found_flag := VAR_ASSET_INFOR.COUNT;
					IF var_found_flag = 1 THEN
						var_asset_code_type := GEC_CONSTANTS_PKG.C_ISN;
					END IF;
				END;
			END IF;
				
			IF  var_found_flag <> 1 THEN 
				IF p_ISIN IS NOT NULL AND LENGTH(p_ISIN) = 12 THEN
				    var_status:='E';
				ELSE
				    var_status:='X';
			    END IF;
			END IF;
		END IF; --IF var_found_flag <> 1 AND p_ISIN IS NOT NULL

		IF var_found_flag <> 1 AND p_quik IS NOT NULL THEN
 			BEGIN
				SELECT GEC_ASSET_TP(ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, SOURCE_FLAG, TRADE_COUNTRY_CD, p_asset_code, p_asset_code_type,ASSET_TYPE_ID) 
			  	  BULK COLLECT INTO VAR_ASSET_INFOR 
				  FROM gec_asset 
				 WHERE quik = p_quik;
				
				var_found_flag := VAR_ASSET_INFOR.COUNT;
				IF var_found_flag = 1 THEN
					var_asset_code_type := GEC_CONSTANTS_PKG.C_QUK;
				END IF;
			END;
			
			IF  var_found_flag != 1 THEN 
				IF LENGTH(p_quik) = 4 THEN
				    var_status:='E';
				ELSE
				    var_status:='X';
			    END IF;
			END IF;
			
		END IF; --var_found_flag <> 1 AND p_quik IS NOT NULL
			
		IF var_found_flag <> 1 AND p_ticker IS NOT NULL THEN
 			BEGIN
				SELECT GEC_ASSET_TP(ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, SOURCE_FLAG, TRADE_COUNTRY_CD, p_asset_code, p_asset_code_type,ASSET_TYPE_ID) 
			  	  BULK COLLECT INTO VAR_ASSET_INFOR 
				  FROM gec_asset 
				 WHERE ticker = p_ticker;
				
				var_found_flag := VAR_ASSET_INFOR.COUNT;
				IF var_found_flag = 1 THEN
					var_asset_code_type := GEC_CONSTANTS_PKG.C_TIK;
				END IF;
			END;
			
			IF  var_found_flag <> 1 THEN 
				IF LENGTH(p_ticker) > 0 AND LENGTH(p_ticker) < 4 THEN
				    var_status:='E';
				ELSE
				    var_status:='X';
			    END IF;
			END IF;
		END IF; --IF var_found_flag <> 1 AND p_ticker IS NOT NULL
		    
	    IF var_found_flag <> 1 AND p_asset_code IS NOT NULL THEN
			SELECT GEC_ASSET_TP(asset.ASSET_ID, asset.CUSIP, asset.ISIN, asset.SEDOL, asset.QUIK, 
								asset.TICKER, asset.DESCRIPTION, asset.SOURCE_FLAG, asset.TRADE_COUNTRY_CD,
			                    p_asset_code, asset_identifier.asset_code_type,ASSET_TYPE_ID) 
		  	  BULK COLLECT INTO VAR_ASSET_INFOR 
			  FROM gec_asset asset, gec_asset_identifier asset_identifier
			 WHERE asset.asset_id = asset_identifier.asset_id
			   AND asset_identifier.asset_code = p_asset_code
			   AND (asset_identifier.asset_code_type = p_asset_code_type
	                OR p_asset_code_type IS NULL
                   );
			var_found_flag := VAR_ASSET_INFOR.COUNT;
			IF var_found_flag = 1 THEN
				var_asset_code_type := VAR_ASSET_INFOR(1).asset_code_type;
			END IF;
			
	      	IF var_found_flag <> 1 THEN
		        CASE 
		            WHEN LENGTH(p_asset_code) = 12 AND var_found_flag > 1 AND p_TRADE_COUNTRY_CD IS NOT NULL 
		                 AND (p_asset_code_type = GEC_CONSTANTS_PKG.C_ISN OR p_asset_code_type IS NULL)THEN
		            	BEGIN
							SELECT GEC_ASSET_TP(ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, SOURCE_FLAG, TRADE_COUNTRY_CD, p_asset_code, p_asset_code_type,ASSET_TYPE_ID) 
						  	  BULK COLLECT INTO VAR_ASSET_INFOR 
			                  FROM gec_asset 
			                 WHERE ISIN = p_asset_code
			                   AND TRADE_COUNTRY_CD = p_TRADE_COUNTRY_CD;
			                
							var_found_flag := VAR_ASSET_INFOR.COUNT;
							IF var_found_flag = 1 THEN
								var_asset_code_type := GEC_CONSTANTS_PKG.C_ISN;
							END IF;
		            	END;	
		            --Asset code of length 9 needs no validate here, since it should be in table asset_identifier
		            WHEN LENGTH(p_asset_code) = 8 AND (p_asset_code_type = GEC_CONSTANTS_PKG.C_CSP OR p_asset_code_type IS NULL)THEN
		                BEGIN
							SELECT GEC_ASSET_TP(ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, SOURCE_FLAG, TRADE_COUNTRY_CD, p_asset_code, p_asset_code_type,ASSET_TYPE_ID) 
						  	  BULK COLLECT INTO VAR_ASSET_INFOR 
			                  FROM gec_asset 
			                 WHERE substr(cusip,1,8) = p_asset_code;
			                
							var_found_flag := VAR_ASSET_INFOR.COUNT;
							IF var_found_flag = 1 THEN
								var_asset_code_type := GEC_CONSTANTS_PKG.C_CSP;
							END IF;
						END;
		              
						IF 	var_found_flag <> 1 AND REGEXP_LIKE(p_asset_code,'^[0-9]+$') THEN
							BEGIN
								SELECT GEC_ASSET_TP(ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, SOURCE_FLAG, TRADE_COUNTRY_CD, p_asset_code, p_asset_code_type,ASSET_TYPE_ID) 
							  	  BULK COLLECT INTO VAR_ASSET_INFOR 
				                  FROM gec_asset 
				                 WHERE cusip = LPAD(p_asset_code,9,'0');
				                  
								var_found_flag := VAR_ASSET_INFOR.COUNT;
								IF var_found_flag = 1 THEN
									var_asset_code_type := GEC_CONSTANTS_PKG.C_CSP;
								END IF;
			                END;
						END IF;
		      
		            WHEN LENGTH(p_asset_code) = 7 AND (p_asset_code_type = GEC_CONSTANTS_PKG.C_CSP 
		               OR p_asset_code_type IS NULL OR p_asset_code_type = GEC_CONSTANTS_PKG.C_SED) THEN
		            	BEGIN
							SELECT GEC_ASSET_TP(ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, SOURCE_FLAG, TRADE_COUNTRY_CD, p_asset_code, p_asset_code_type,ASSET_TYPE_ID) 
						  	  BULK COLLECT INTO VAR_ASSET_INFOR 
			                  FROM gec_asset 
			                 WHERE sedol = p_asset_code;
			                
							var_found_flag := VAR_ASSET_INFOR.COUNT;
							IF var_found_flag = 1 THEN
								var_asset_code_type := GEC_CONSTANTS_PKG.C_SED;
							END IF;
		            	END;
		            	
		            	IF 	var_found_flag <> 1 AND REGEXP_LIKE(p_asset_code,'^[0-9]+$') THEN
							BEGIN
								SELECT GEC_ASSET_TP(ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, SOURCE_FLAG, TRADE_COUNTRY_CD, p_asset_code, p_asset_code_type,ASSET_TYPE_ID) 
							  	  BULK COLLECT INTO VAR_ASSET_INFOR 
				                  FROM gec_asset 
				                 WHERE cusip = LPAD(p_asset_code,9,'0');
				                IF var_found_flag=0 THEN
					              	var_found_flag := VAR_ASSET_INFOR.COUNT;
					           	ELSE
									IF var_found_flag = 1 THEN
										var_asset_code_type := GEC_CONSTANTS_PKG.C_CSP;
									END IF;
								END IF;
			                END;
						END IF;
		            WHEN (LENGTH(p_asset_code) = 5 OR LENGTH(p_asset_code) = 3 OR LENGTH(p_asset_code) = 2 OR LENGTH(p_asset_code) = 1)
                        AND var_found_flag > 1 AND p_asset_code_type IS NULL THEN
		                BEGIN
							SELECT GEC_ASSET_TP(ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, SOURCE_FLAG, TRADE_COUNTRY_CD, p_asset_code, p_asset_code_type,ASSET_TYPE_ID) 
						  	  BULK COLLECT INTO VAR_ASSET_INFOR 
			                  FROM gec_asset 
			                 WHERE ticker = p_asset_code;
			                
							IF VAR_ASSET_INFOR.COUNT > 0 THEN
								var_found_flag := VAR_ASSET_INFOR.COUNT;
								var_asset_code_type := GEC_CONSTANTS_PKG.C_TIK;
							END IF;
		               END;
		               
		               IF var_found_flag <>1 THEN 
		               		BEGIN
								SELECT GEC_ASSET_TP(ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, SOURCE_FLAG, TRADE_COUNTRY_CD, p_asset_code, p_asset_code_type,ASSET_TYPE_ID) 
							  	  BULK COLLECT INTO VAR_ASSET_INFOR 
				                  FROM gec_asset 
				                 WHERE QUIK = p_asset_code;
				                
				                IF VAR_ASSET_INFOR.COUNT > 0 THEN
									var_found_flag := VAR_ASSET_INFOR.COUNT;
									var_asset_code_type := GEC_CONSTANTS_PKG.C_QUK;
								END IF;
			               END;
		               END IF;
		            WHEN LENGTH(p_asset_code) = 4  AND var_found_flag <> 1 AND p_asset_code_type IS NULL THEN
						SELECT GEC_ASSET_TP(ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, SOURCE_FLAG, TRADE_COUNTRY_CD, p_asset_code, p_asset_code_type,ASSET_TYPE_ID) 
					  	  BULK COLLECT INTO VAR_ASSET_INFOR 
		                  FROM gec_asset 
		                 WHERE quik = p_asset_code;
		                
						
						var_found_flag := VAR_ASSET_INFOR.COUNT;
						var_asset_code_type := GEC_CONSTANTS_PKG.C_QUK;
						

						IF var_found_flag <> 1 THEN
							SELECT GEC_ASSET_TP(ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, SOURCE_FLAG, TRADE_COUNTRY_CD, p_asset_code, p_asset_code_type,ASSET_TYPE_ID) 
						  	  BULK COLLECT INTO VAR_ASSET_INFOR 
			                  FROM gec_asset 
			                 WHERE ticker = p_asset_code;
			                
							IF VAR_ASSET_INFOR.COUNT > 0 THEN
								var_found_flag := VAR_ASSET_INFOR.COUNT;
								var_asset_code_type := GEC_CONSTANTS_PKG.C_TIK;
							END IF;
						END IF;
						
						IF 	var_found_flag <> 1 AND REGEXP_LIKE(p_asset_code,'^[0-9]+$') THEN
							BEGIN
								SELECT GEC_ASSET_TP(ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, SOURCE_FLAG, TRADE_COUNTRY_CD, p_asset_code, p_asset_code_type,ASSET_TYPE_ID) 
							  	  BULK COLLECT INTO VAR_ASSET_INFOR 
				                  FROM gec_asset 
				                 WHERE cusip = LPAD(p_asset_code,9,'0');
				                  
								var_found_flag := VAR_ASSET_INFOR.COUNT;
								IF var_found_flag = 1 THEN
									var_asset_code_type := GEC_CONSTANTS_PKG.C_CSP;
								END IF;
			                END;
						END IF;
						
	                WHEN REGEXP_LIKE(p_asset_code,'^[0-9]+$') AND LENGTH(p_asset_code) < 9 AND (p_asset_code_type = GEC_CONSTANTS_PKG.C_CSP 
			               OR p_asset_code_type IS NULL) THEN 
	                    BEGIN
							SELECT GEC_ASSET_TP(ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, SOURCE_FLAG, TRADE_COUNTRY_CD, p_asset_code, p_asset_code_type,ASSET_TYPE_ID) 
						  	  BULK COLLECT INTO VAR_ASSET_INFOR 
		                      FROM gec_asset 
		                     WHERE cusip = LPAD(p_asset_code,9,'0');
	                      
							var_found_flag := VAR_ASSET_INFOR.COUNT;
							IF var_found_flag = 1 THEN
								var_asset_code_type := GEC_CONSTANTS_PKG.C_CSP;
							END IF;
						END;
					ELSE
                    	var_found_flag := var_found_flag;
				END CASE;
			END IF;	--IF var_found_flag <> 1 THEN
			
	        IF var_found_flag != 1 THEN 
	        	CASE 
	        		WHEN LENGTH(p_asset_code) > 12 THEN
	        			var_status:='X';
	        		WHEN LENGTH(p_asset_code) = 12 THEN
	        			IF (p_asset_code_type IS NULL OR p_asset_code_type = GEC_CONSTANTS_PKG.C_ISN )THEN
	        		    	var_status:='E';
	        			ELSE
	        				var_status:='X';
	        			END IF;
	        		WHEN LENGTH(p_asset_code) = 11 THEN
	        				var_status:='X';
	        		WHEN LENGTH(p_asset_code) = 10 THEN
	        		    	var_status:='X';
	        		WHEN LENGTH(p_asset_code) = 9 OR LENGTH(p_asset_code) = 8 THEN
	        		    IF (p_asset_code_type IS NULL OR p_asset_code_type = GEC_CONSTANTS_PKG.C_CSP )THEN
	        		    	var_status:='E';
	        			ELSE
	        				var_status:='X';
	        			END IF;
	        		WHEN LENGTH(p_asset_code) = 7 THEN 
	        			IF (p_asset_code_type IS NULL OR p_asset_code_type = GEC_CONSTANTS_PKG.C_SED )THEN
	        		    	var_status:='E';
	        			ELSE IF ((p_asset_code_type IS NULL OR p_asset_code_type = GEC_CONSTANTS_PKG.C_CSP )
	        			   			AND REGEXP_LIKE(p_asset_code,'^[0-9]+$')) THEN
	        			      	var_status:='E';
                      		ELSE 
                        		var_status:='X';
                     		END IF;
                		END IF;
	        		WHEN LENGTH(p_asset_code) = 6 OR LENGTH(p_asset_code) = 5 THEN 
	        			IF p_asset_code_type = GEC_CONSTANTS_PKG.C_CSP AND REGEXP_LIKE(p_asset_code,'^[0-9]+$') THEN
	        		    	var_status:='E';
	        			ELSE
	        				var_status:='X';
	        			END IF;
	        		WHEN LENGTH(p_asset_code) = 4 THEN 
	        			IF (p_asset_code_type = GEC_CONSTANTS_PKG.C_CSP AND REGEXP_LIKE(p_asset_code,'^[0-9]+$')
	        						OR p_asset_code_type = GEC_CONSTANTS_PKG.C_QUK ) THEN
	        		    	var_status:='E';
	        			ELSE
	        				var_status:='X';
	        			END IF;
	        		WHEN LENGTH(p_asset_code) < 4 AND LENGTH(p_asset_code) > 0 THEN
	        		    IF p_asset_code_type = GEC_CONSTANTS_PKG.C_TIK THEN
	        		    var_status:='E';
	        			ELSE
	        				var_status:='X';
	        			END IF;
            		ELSE
              			var_status:='X';
	        	END CASE;
        	END IF; --IF var_found_flag <> 1 THEN   
	    END IF; --IF var_found_flag <> 1 AND p_asset_code IS NOT NULL THEN

		--GEC-1419: trade country cd of security master record must match user-inputed values (if provided), else security not found and go Error status.
		--Condition: var_found_flag must be equal to var_asset_infor.COUNT
		IF var_found_flag > 0 and p_trade_country_cd is not null THEN
			FOR v_i in var_asset_infor.first .. var_asset_infor.last
			LOOP
				v_asset := var_asset_infor(v_i);
				IF v_asset.trade_country_cd != p_trade_country_cd THEN
					var_found_flag := var_found_flag - 1;
					var_asset_infor.delete(v_i);
					v_deleted_no := v_deleted_no + 1;
				END IF;
			END LOOP;
			
			IF v_deleted_no > 0 THEN
				IF var_asset_infor.count > 0 THEN
					FOR v_i in var_asset_infor.first .. var_asset_infor.last
					LOOP
						BEGIN
							v_asset := var_asset_infor(v_i);
							v_asset_rs.extend();
							v_index := v_index + 1;
							v_asset_rs(v_index) := var_asset_infor(v_i);
						EXCEPTION WHEN NO_DATA_FOUND THEN
							NULL;
						END;
					END LOOP;
				END IF;
				var_asset_infor := v_asset_rs;
			END IF;
			
			IF var_found_flag = 0 THEN
				var_status :='X';
			ELSIF var_found_flag = 1 THEN
				var_status := '';
			END IF;
		END IF;
		
		IF var_found_flag > 1 THEN
			var_status :='X';
		END IF;
  
		IF var_found_flag = 0 and var_status is null THEN
			var_status :='X';
		END IF;
		
    END VALIDATE_ASSET_ID;
    
	PROCEDURE VALIDATE_IM_REQUEST(	p_uploadData     		IN 	GEC_IM_REQUEST_TP_ARRAY,									
									p_uploadedBy        	IN 	VARCHAR2,
									p_checkTrailer 	 		IN 	VARCHAR2,
									p_transaction_type  	IN 	VARCHAR2,
								 	p_curr_date	  	 		IN	DATE,	 
									p_errorCode      		OUT VARCHAR2)
	IS
		v_curr_date DATE;
		v_error_flag VARCHAR(1);
		v_fail_flag VARCHAR(1);
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_VALIDATION_PKG.VALIDATE_IM_REQUEST';
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);

		--do simple validation		
		VALIDATE_BASIC_INFO(p_transaction_type,p_errorCode);	
		IF p_errorCode IS NOT NULL THEN
			RETURN;	
		END IF; 	
		--validate investment manager
		VALIDATE_IM(p_transaction_type,p_errorCode);	
		IF p_errorCode IS NOT NULL THEN
			RETURN;	
		END IF; 	
		
		--FILL STRATEGY ID
		FILL_STRATEGY;	
		--validate strategy
		VALIDATE_STRATEGY(p_transaction_type,p_errorCode);	
		IF p_errorCode IS NOT NULL THEN
			RETURN;	
		END IF; 		
			
		--FILL Default fund_cd, client_cd
		FILL_DEFAULTS;	
		--validate fund
		validate_fund(p_transaction_type,p_errorCode);	
		IF p_errorCode IS NOT NULL THEN
			RETURN;	
		END IF; 
						
		--Validation: If the request is not from 'Call', we will check the trailer if IM Request file record counts match.
		--If sourced from IM File , do validation of trailer.
		--If check trailer('Y')and sourced from traider im file upload , it needs to check trailer.
		IF p_checkTrailer = 'Y' THEN  
			CHECK_LOCATE_TRAILER(p_uploadData ,  p_errorCode);
			
			IF p_errorCode IS NOT NULL THEN
				RETURN;	
			END IF; 				
		END IF;

		--CORRECT ALL TRADE COUNTRIES TO SHORT NAME LIKE USD->US		
		TRANSFORM_TRADE_COUNTRY;
		
		--VALIDATE MULTI ASSET and fill avail id,trade country
		FILL_REQUEST_TEMP_WITH_ASSET(p_transaction_type);
		
		--validate strategy profile
		VALIDATE_STRATEGY_PROFILE;

		--validate business date
		VALIDATE_BUSINESS_DATE(v_curr_date);
		
		--derive business date
		DERIVE_BUSINESS_DATE(v_curr_date);
		
		--SPECIAL VALIDATE FOR PREBORROW
		IF (p_transaction_type = gec_constants_pkg.C_PREBORROW) THEN
			VALIDATE_PREBORROW_COUNTRY;
		END IF;		
		--Set schedule date for locate.
		SCHEDULE_FUTURE_LOCATE(v_curr_date);					

		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END VALIDATE_IM_REQUEST; 	    
 
 	
	PROCEDURE SCHEDULE_FUTURE_LOCATE(p_curr_date DATE)
	IS
		v_curr_date DATE;
		CURSOR v_cur_set_date(i_curr_date DATE) IS 
		select loc.locate_preborrow_id, 
					  CASE 
					  	WHEN to_char( to_date(country.cutoff_time,'HH:MIAM'),'HH24:Mi:SS') < to_char( to_date(pro.SCHEDULED_AT,'HH:MIAM'),'HH24:Mi:SS')
					  	THEN TO_CHAR(gec_utils_pkg.TO_TIMEZONE(i_curr_date, gec_constants_pkg.C_BOS_TIMEZONE, country.LOCALE),'YYYYMMDD') || ' ' || pro.SCHEDULED_AT
					  	ELSE loc.business_date || ' ' || pro.SCHEDULED_AT
					  	END AS scheduled_at,
					  	locale	
				 from gec_locate_preborrow_temp  loc, gec_trade_country country, gec_strategy_profile pro
				where loc.trade_country_cd = country.trade_country_cd
					  and loc.trade_country_cd = pro.trade_country_cd
					  and loc.strategy_id = pro.strategy_id
					  and loc.business_date = gec_utils_pkg.date_to_number( gec_utils_pkg.get_tplusn(gec_utils_pkg.TO_TIMEZONE(i_curr_date, gec_constants_pkg.C_BOS_TIMEZONE, country.LOCALE), 1, loc.trade_country_cd) )
					  and pro.holdback_flag = 'Y'
					  and pro.SCHEDULED_AT is not null
					  and pro.status = 'A'
					  and loc.status <> 'X';					  				
	BEGIN
	
		v_curr_date := NVL(p_curr_date,sysdate);
		
		--If business date is next trading day of that country, the related holdback flag is Y(es), scheduled time is not null
		--and it satifys other conditons in the declare sction.It will set schedule time for future process.
		--a.If scheduled_at setting(in strategy profle) > cutoff time, the schedule time should next_trade_day - 1(trade day) + scheduled_at(in strategy profle).
		--b.If scheduled_at setting(in strategy profle) < cutoff time, the schedule time should next_trade_day + scheduled_at(in strategy profle).
		--c.Else, it occurs when cutoff time and scheduled_at setting is incorrect which is not allowed on UI.	
		FOR v_cur_item IN v_cur_set_date(v_curr_date) LOOP 
			UPDATE  gec_locate_preborrow_temp temp
			SET 	temp.status = 'H',
					temp.scheduled_at = gec_utils_pkg.to_bos_time(v_cur_item.scheduled_at,v_cur_item.locale),   --scheduled_at to_date(qry.scheduled_at, 'yyyymmdd hh:MiAM') N/A,to-do set scheduled_at
					temp.COMMENT_TXT = GEC_UTILS_PKG.SUB_COMMENT(temp.comment_txt||GEC_CONSTANTS_PKG.C_HOLD_UTIL_CMT||to_char(to_date(v_cur_item.scheduled_at, 'yyyymmdd hh:MiAM'),'hh:Mi AM dd-MON-yyyy')||'(Country - '||trade_country_cd||')')		
			WHERE temp.Locate_Preborrow_id = v_cur_item.Locate_Preborrow_id;
			
		END LOOP;								
				
		--If shcedule at < current date , set it to be P(Pengding) and clear comment, 
		--These locates need to be processed immediately
		UPDATE 	gec_locate_preborrow_temp
		   SET 	status = 'P',
		   		comment_txt = null
		WHERE 	status = 'H'
		  AND 	scheduled_at <= v_curr_date;
					
	END SCHEDULE_FUTURE_LOCATE;   
	
	--Do some update to order before process
--	PROCEDURE PREPARE_ORDER	
--	IS 							
--		CURSOR v_cur_defaults IS
--			SELECT           
--            	lpt.rowid,					            	
--			   	NVL(lpt.CLIENT_CD, fundclient.CLIENT_CD) CLIENT_CD,
--			   	NVL(lpt.SB_BROKER_CD, fundclient.DML_SB_Broker) DML_SB_Broker,
--            	--lpt.IM_USER_ID,
--            	lpt.im_order_id,
--            	fundclient.IM_DEFAULT_FUND_CD,
--            	fundclient.CLIENT_CD IM_DEFAULT_CLIENT_CD	
--            	--fundclient.strategy_id			
--			FROM gec_im_order_temp lpt 
--			LEFT JOIN 
--      		( 
--          		SELECT 
--          		client.CLIENT_SHORT_NAME, 
--          		strategy.IM_DEFAULT_FUND_CD,
--          		fund.CLIENT_CD,
--          		fund.DML_SB_Broker,
--          		strategy.strategy_id,
--          		fund.fund_cd 
--          		FROM GEC_Strategy strategy ,GEC_CLIENT client,GEC_FUND fund 
--          		WHERE 
--          			strategy.strategy_id = fund.strategy_id
--          		  AND strategy.client_id = client.client_id
--          		  AND strategy.status = 'A'
--      		) fundclient
--    	ON lpt.INVESTMENT_MANAGER_CD = fundclient.CLIENT_SHORT_NAME
--    		and lpt.fund_cd = fundclient.fund_cd;   
--	BEGIN		
--		--set default client,default fund, sb_broker
--		FOR v_rec in v_cur_defaults LOOP		
--			update gec_im_order_temp
--			set --im_default_fund_cd = v_rec.im_default_fund_cd,
--				--im_default_client_cd = v_rec.im_default_client_cd,
--				client_cd = v_rec.client_cd,
--				sb_broker_cd = v_rec.dml_sb_broker
--				--strategy_id = v_rec.strategy_id
--			where rowid = v_rec.rowid;							
--		END LOOP;					
--	END PREPARE_ORDER; 	 		
		
	FUNCTION UPDATE_REQUET_STARUS( p_oldStatus IN VARCHAR2,
									p_newStatus IN VARCHAR2) RETURN VARCHAR2
    IS
    BEGIN
		IF p_oldStatus = 'X' THEN--If status is already X, it will not be updated
			return p_oldStatus;
		ELSIF p_oldStatus = 'E' and p_newStatus != 'X' THEN
			return p_oldStatus;
		ELSE
			return p_newStatus;
		END IF; 
    END UPDATE_REQUET_STARUS;
	

	PROCEDURE VALIDATE_LOADVALIDATED_BORROW(P_BORROWLIST_CURSOR OUT SYS_REFCURSOR)
	  IS  
	      VAR_PRICE  GEC_BORROW.PRICE%TYPE;
          VAR_TEMP_PRICE  GEC_BORROW.PRICE%TYPE;
	      VAR_ASSET_CODE  VARCHAR2(20);
	      VAR_BROKER_CD  GEC_BROKER.BROKER_CD%TYPE;
	      VAR_BROKER_TYPE GEC_BROKER.BORROW_REQUEST_TYPE%TYPE;
	      VAR_COLLATERAL_TYPE	 GEC_BROKER.COLLATERAL_TYPE%TYPE;
	      VAR_COLLATERAL_CURRENCY_CD	GEC_BROKER.COLLATERAL_CURRENCY_CD%TYPE;
	      VAR_FOUND_FLAG NUMBER;
	      VAR_ASSET_CODE_TYPE GEC_ASSET_IDENTIFIER.ASSET_CODE_TYPE%TYPE;
	      VAR_STATUS VARCHAR2(1);
	      VAR_ASSET_RS  GEC_ASSET_TP_ARRAY;
	      VAR_ASSET_ID  GEC_ASSET.ASSET_ID%TYPE;
	      VAR_BROKER_COUNT NUMBER;
	      VAR_COLLATERAL_PERCENTAGE GEC_BROKER.US_COLLATERAL_PERCENTAGE%TYPE;
	      VAR_ASSET_TYPE_ID GEC_ASSET.ASSET_TYPE_ID%TYPE;
	      VAR_CLEAN_PRICE  GEC_ASSET.CLEAN_PRICE%TYPE;
	      VAR_DIRTY_PRICE GEC_ASSET.CLEAN_PRICE%TYPE;
          VAR_ERROR_CODE VARCHAR2(32767);
          VAR_BORROW_COUNT_OF_SAME_ASSET  NUMBER(3);
          VAR_FROM_TIMEZONE  GEC_TRADE_COUNTRY.LOCALE%TYPE;
          VAR_TO_TIMEZONE GEC_TRADE_COUNTRY.LOCALE%TYPE;
          VAR_CUTOFF_TIME GEC_TRADE_COUNTRY.CUTOFF_TIME%TYPE;
          VAR_CUR_DATESTR VARCHAR2(100);
          VAR_DATE DATE;
          VAR_TRADE_COUNTRY_CD GEC_TRADE_COUNTRY.CURRENCY_CD%TYPE;
          VAR_PRICE_DATE GEC_ASSET.PRICE_DATE%TYPE;
          VAR_PRICE_CURRENCY GEC_ASSET.PRICE_CURRENCY_CD%TYPE;
          VAR_BUSINESS_DAY DATE;
          VAR_PRICE_ROUND_FACTOR GEC_BROKER.US_PRICE_ROUND_FACTOR%TYPE;
          VAR_DPS GEC_BROKER.NOU_US_DPS%TYPE;  
          VAR_EXCHANGE_RATE GEC_EXCHANGE_RATE.EXCHANGE_RATE%TYPE;
          VAR_EXCHANGE_DATE GEC_EXCHANGE_RATE.EXCHANGE_DATE%TYPE;  
          VAR_SECURITY_EXCHANGE_RATE GEC_EXCHANGE_RATE.EXCHANGE_RATE%TYPE;
          VAR_SECURITY_EXCHANGE_DATE GEC_EXCHANGE_RATE.EXCHANGE_DATE%TYPE; 
          VAR_DOMESTIC_TAX_PER GEC_BORROW.DOMESTIC_TAX_PERCENTAGE%TYPE;  
          VAR_RECLAIM_RATE GEC_BORROW.RECLAIM_RATE%TYPE;
          VAR_PREPAYRATE GEC_BORROW.PREPAY_RATE%TYPE;
          VAR_PREPAYDAY GEC_TRADE_COUNTRY.PREPAY_DATE_VALUE%TYPE;
          VAR_PREPAYDATE GEC_BORROW.PREPAY_DATE%TYPE;
          VAR_OVERSEAS_TAX_PER GEC_BORROW.OVERSEAS_TAX_PERCENTAGE%TYPE;          
          VAR_UTIL_NUMBER  NUMBER(10);
          VAR_VALIDATE_DATE_RESULT VARCHAR2(10);
          VAR_STALE_EXCHANGE_PRICE VARCHAR2(10);
          VAR_STALE_SECURITY_CUR VARCHAR2(10);
          VAR_IS_STALE_PRICE VARCHAR(10);
          VAR_IS_STALE_EXCHANGE_PRICE VARCHAR(10);
          VAR_ROW_COUNT NUMBER(10);
          VAR_COLL_CODE_COUNT NUMBER;
          VAR_COLL_TYPE_COUNT NUMBER;
	      CURSOR V_CUR_BORROWLIST IS
	          SELECT GBT.BORROW_ID,GBT.ASSET_CODE, GBT.BROKER_CD,GBT.TRADE_DATE,GBT.SETTLE_DATE,
	                 GBT.BORROW_QTY,GBT.PRICE,GBT.RATE,GBT.COLLATERAL_CURRENCY_CD,
	                 GBT.COLLATERAL_TYPE,GBT.POSITION_FLAG,GBT.COMMENT_TXT,GBT.PREPAY_DATE,GBT.PREPAY_RATE,
	                 GBT.RECLAIM_RATE,GBT.OVERSEAS_TAX_PERCENTAGE,GBT.MINIMUM_FEE_CD,GBT.ERROR_CODE,
	                 GBT.DOMESTIC_TAX_PERCENTAGE,GBT.MINIMUM_FEE,GBT.TERM_DATE,GBT.EXPECTED_RETURN_DATE
	          FROM GEC_BORROW_TEMP GBT; 
	  BEGIN
	  VAR_FROM_TIMEZONE := 'AMERICA/NEW_YORK';
      VAR_TO_TIMEZONE := 'AMERICA/NEW_YORK';
      VAR_VALIDATE_DATE_RESULT := 'N';
      VAR_STALE_EXCHANGE_PRICE := 'N';
      VAR_STALE_SECURITY_CUR := 'N';
      
      -- prepare coll type and code
      FOR V_TEMP_BORROW IN V_CUR_BORROWLIST LOOP
          IF V_TEMP_BORROW.BROKER_CD IS NOT NULL THEN
              SELECT COUNT(*) INTO VAR_BROKER_COUNT
	          FROM GEC_BROKER GB
	          WHERE GB.BROKER_CD = V_TEMP_BORROW.BROKER_CD;
	          
              IF VAR_BROKER_COUNT=1 THEN
                  SELECT GB.COLLATERAL_TYPE, GB.COLLATERAL_CURRENCY_CD 
                  INTO VAR_COLLATERAL_TYPE ,VAR_COLLATERAL_CURRENCY_CD
                  FROM GEC_BROKER GB
                  WHERE GB.BROKER_CD = V_TEMP_BORROW.BROKER_CD;
                  VAR_COLLATERAL_TYPE :=  (CASE  WHEN  V_TEMP_BORROW.COLLATERAL_TYPE IS NULL  THEN VAR_COLLATERAL_TYPE ELSE V_TEMP_BORROW.COLLATERAL_TYPE END);
                  VAR_COLLATERAL_CURRENCY_CD :=  (CASE  WHEN  V_TEMP_BORROW.COLLATERAL_CURRENCY_CD IS NULL  THEN VAR_COLLATERAL_CURRENCY_CD ELSE V_TEMP_BORROW.COLLATERAL_CURRENCY_CD END);
                  UPDATE GEC_BORROW_TEMP GBT
                  SET GBT.COLLATERAL_TYPE=VAR_COLLATERAL_TYPE, GBT.COLLATERAL_CURRENCY_CD = VAR_COLLATERAL_CURRENCY_CD
                  WHERE GBT.BORROW_ID = V_TEMP_BORROW.BORROW_ID;
              END IF;
          END IF;
          VAR_BROKER_COUNT := NULL;
          VAR_COLLATERAL_TYPE := NULL;
          VAR_COLLATERAL_CURRENCY_CD := NULL;
      END LOOP;
      
      FOR V_BORROW IN V_CUR_BORROWLIST LOOP
	        
	        -- IF THE BROKER_CD IS NULL REMAIN THE COLLATERAL_TYPE AND COLLATERAL_CURRENCY_CD
	        IF V_BORROW.BROKER_CD IS NULL THEN
	            VAR_BROKER_CD := NULL;
	            VAR_COLLATERAL_TYPE := V_BORROW.COLLATERAL_TYPE;
	            VAR_COLLATERAL_CURRENCY_CD := V_BORROW.COLLATERAL_CURRENCY_CD;
              	VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0061' ELSE VAR_ERROR_CODE ||','||'VLD0061' END);
	        ELSE
	            SELECT COUNT(*) INTO VAR_BROKER_COUNT
	            FROM GEC_BROKER GB
	            WHERE BORROW_REQUEST_TYPE != 'Intercompany Counterparty' AND GB.BROKER_CD = V_BORROW.BROKER_CD;
	            
	            IF VAR_BROKER_COUNT=1 THEN
	                SELECT COUNT(*) INTO VAR_BORROW_COUNT_OF_SAME_ASSET
                  	FROM GEC_BORROW_TEMP GBT
                  	WHERE GBT.BROKER_CD = V_BORROW.BROKER_CD AND GBT.ASSET_CODE = V_BORROW.ASSET_CODE 
                        AND GBT.COLLATERAL_CURRENCY_CD = V_BORROW.COLLATERAL_CURRENCY_CD
                        AND GBT.SETTLE_DATE = V_BORROW.SETTLE_DATE;
                        
                      -- one asset only for one broker                      
                      IF VAR_BORROW_COUNT_OF_SAME_ASSET > 1 THEN
                          VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0078' ELSE VAR_ERROR_CODE ||','||'VLD0078' END);
                      END IF;
                      
                      SELECT GB.COLLATERAL_TYPE, GB.COLLATERAL_CURRENCY_CD
                      INTO VAR_COLLATERAL_TYPE ,VAR_COLLATERAL_CURRENCY_CD
                      FROM GEC_BROKER GB
                      WHERE GB.BROKER_CD = V_BORROW.BROKER_CD;
                      
                      VAR_BROKER_CD := V_BORROW.BROKER_CD;        
                      VAR_COLLATERAL_TYPE :=  (CASE  WHEN  V_BORROW.COLLATERAL_TYPE IS NULL  THEN VAR_COLLATERAL_TYPE ELSE V_BORROW.COLLATERAL_TYPE END);
                      VAR_COLLATERAL_CURRENCY_CD :=  (CASE  WHEN  V_BORROW.COLLATERAL_CURRENCY_CD IS NULL  THEN VAR_COLLATERAL_CURRENCY_CD ELSE V_BORROW.COLLATERAL_CURRENCY_CD END);
                      
	            ELSE 
	                VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0304' ELSE VAR_ERROR_CODE ||','||'VLD0304' END);
                    VAR_COLLATERAL_TYPE := V_BORROW.COLLATERAL_TYPE;
	                VAR_COLLATERAL_CURRENCY_CD := V_BORROW.COLLATERAL_CURRENCY_CD;
	            END IF;
	           
	        END IF;
	        
	        -- IF ASSET_CODE IS NULL REMAIN THE PRICE COPYED BY USER
	        IF V_BORROW.ASSET_CODE IS NULL THEN
	            VAR_PRICE := V_BORROW.PRICE;
	            VAR_ASSET_CODE := NULL;
                VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0060' ELSE VAR_ERROR_CODE ||','||'VLD0060' END);
	        ELSE         
	        	GEC_VALIDATION_PKG.VALIDATE_ASSET_ID(NULL, 
	                                             NULL,
	                                             NULL,
	                                             NULL,
	                                             NULL,
	                                             NULL,
	                                             NULL,
	                                             V_BORROW.ASSET_CODE,
	                                             NULL,
	                                             VAR_FOUND_FLAG, 
	                                             VAR_ASSET_CODE_TYPE,
	                                             VAR_STATUS ,
	                                             VAR_ASSET_RS);
	         	IF VAR_FOUND_FLAG = 1 AND VAR_ASSET_RS.COUNT = 1 THEN
                   
	              	VAR_ASSET_ID := VAR_ASSET_RS(VAR_ASSET_RS.FIRST).ASSET_ID;

                  	BEGIN
                           
                    	  SELECT GA.TRADE_COUNTRY_CD, GTC.LOCALE INTO VAR_TRADE_COUNTRY_CD,VAR_TO_TIMEZONE
                    	  FROM GEC_ASSET GA
                    	  LEFT JOIN GEC_TRADE_COUNTRY GTC
                    	  ON GA.TRADE_COUNTRY_CD = GTC.TRADE_COUNTRY_CD
                    	  WHERE GA.ASSET_ID =  VAR_ASSET_ID ;               

                   	      VAR_ASSET_CODE := V_BORROW.ASSET_CODE;

                    EXCEPTION WHEN NO_DATA_FOUND THEN                          
                       	  VAR_ASSET_CODE := V_BORROW.ASSET_CODE;
                  	END;
                      
	            --IF THE ASSET_CODE IS NOT NULL BUT IS INCORRECT SO BLANK THE PRICE AND ASSET_CODE
	         	ELSIF VAR_FOUND_FLAG > 1 THEN
                    VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0055' ELSE VAR_ERROR_CODE ||','||'VLD0055' END);
	         	ELSE 
                    VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0060' ELSE VAR_ERROR_CODE ||','||'VLD0060' END);
	         	END IF;
	     	END IF;
          
          ----select coll perc, round factor, dps for calculation price
          IF VAR_ASSET_ID IS NOT NULL AND VAR_BROKER_CD IS NOT NULL THEN
              SELECT (CASE WHEN VAR_TRADE_COUNTRY_CD = 'US' THEN GB.US_COLLATERAL_PERCENTAGE 
              			   WHEN VAR_TRADE_COUNTRY_CD = 'CA' AND VAR_COLLATERAL_TYPE = 'CASH' AND VAR_COLLATERAL_CURRENCY_CD = 'USD' THEN GB.NONUS_COLLATERAL_PERCENTAGE
              			   WHEN (VAR_TRADE_COUNTRY_CD = 'CA' AND VAR_COLLATERAL_CURRENCY_CD = 'CAD') OR (VAR_TRADE_COUNTRY_CD = 'CA' AND VAR_COLLATERAL_TYPE <> 'CASH') THEN GB.US_COLLATERAL_PERCENTAGE
              			   WHEN VAR_TRADE_COUNTRY_CD <> 'US' AND VAR_TRADE_COUNTRY_CD <> 'CA' THEN GB.NONUS_COLLATERAL_PERCENTAGE
              			   ELSE GB.US_COLLATERAL_PERCENTAGE END) AS COLLATERAL_PERCENTAGE,
              		 (CASE WHEN VAR_TRADE_COUNTRY_CD ='US' THEN GB.US_PRICE_ROUND_FACTOR WHEN VAR_TRADE_COUNTRY_CD ='CA'THEN GB.CA_PRICE_ROUND_FACTOR ELSE GB.NON_US_PRICE_ROUND_FACTOR END) AS PRICE_ROUND_FACTOR,
              		 (CASE WHEN VAR_TRADE_COUNTRY_CD ='US' THEN 7 WHEN VAR_TRADE_COUNTRY_CD = 'CA' THEN CA_DPS ELSE NOU_US_DPS END) AS DPS
              INTO VAR_COLLATERAL_PERCENTAGE, VAR_PRICE_ROUND_FACTOR, VAR_DPS
              FROM GEC_BROKER GB
              WHERE GB.BROKER_CD = VAR_BROKER_CD;
          END IF;
          
	      -- get the exchange rate, exchange date
	      IF VAR_COLLATERAL_CURRENCY_CD IS NOT NULL AND VAR_ASSET_ID IS NOT NULL THEN
	      	BEGIN
	        	SELECT er.EXCHANGE_RATE, er.EXCHANGE_DATE INTO VAR_EXCHANGE_RATE, VAR_EXCHANGE_DATE 
	        	FROM GEC_EXCHANGE_RATE er, GEC_LATEST_EXCHANGE_RATE_VW ler 
	        	WHERE er.EXCHANGE_CURRENCY_CD = ler.EXCHANGE_CURRENCY_CD AND er.EXCHANGE_DATE = ler.EXCHANGE_DATE AND er.EXCHANGE_CURRENCY_CD = VAR_COLLATERAL_CURRENCY_CD;
	        EXCEPTION WHEN NO_DATA_FOUND THEN
	        	VAR_EXCHANGE_RATE := NULL;
	        	VAR_EXCHANGE_DATE := NULL;
	        END;
	      END IF;        
	      -- get asset price , price date, exchange currency
          IF VAR_ASSET_ID IS NOT NULL AND VAR_BROKER_CD IS NOT NULL THEN
              SELECT GA.ASSET_TYPE_ID INTO VAR_ASSET_TYPE_ID
              FROM GEC_ASSET GA
              WHERE GA.ASSET_ID =  VAR_ASSET_ID;                 
              -- get asset price
              BEGIN                      
                  IF VAR_ASSET_TYPE_ID = 4 THEN
                      SELECT  GA.CLEAN_PRICE, GA.PRICE_DATE, GA.PRICE_CURRENCY_CD
                      INTO VAR_CLEAN_PRICE, VAR_PRICE_DATE, VAR_PRICE_CURRENCY
                      FROM GEC_ASSET GA
                      WHERE GA.ASSET_ID = VAR_ASSET_ID;
                  ELSE
                      SELECT  GA.CLEAN_PRICE, GA.DIRTY_PRICE, GA.PRICE_DATE, GA.PRICE_CURRENCY_CD 
                      INTO VAR_CLEAN_PRICE,VAR_DIRTY_PRICE,VAR_PRICE_DATE, VAR_PRICE_CURRENCY
                      FROM GEC_ASSET GA
                      WHERE GA.ASSET_ID =  VAR_ASSET_ID;
                  END IF;
                      
                  IF (VAR_CLEAN_PRICE IS NULL OR (VAR_DIRTY_PRICE IS NULL AND VAR_ASSET_TYPE_ID <> 4)) AND  V_BORROW.PRICE IS NULL THEN 
                     VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0102' ELSE VAR_ERROR_CODE ||','||'VLD0102' END);
                  END IF;
                      
                  IF VAR_PRICE_CURRENCY IS NOT NULL THEN
	      			 BEGIN		  	 
	        		 	SELECT er.EXCHANGE_RATE, er.EXCHANGE_DATE INTO VAR_SECURITY_EXCHANGE_RATE, VAR_SECURITY_EXCHANGE_DATE 
	        			FROM GEC_EXCHANGE_RATE er, GEC_LATEST_EXCHANGE_RATE_VW ler 
	        			WHERE er.EXCHANGE_CURRENCY_CD = ler.EXCHANGE_CURRENCY_CD AND er.EXCHANGE_DATE = ler.EXCHANGE_DATE AND er.EXCHANGE_CURRENCY_CD = VAR_PRICE_CURRENCY;
	        		 EXCEPTION WHEN NO_DATA_FOUND THEN
	        			VAR_SECURITY_EXCHANGE_RATE := NULL;
	        			VAR_SECURITY_EXCHANGE_DATE := NULL;
	        		 END; 
	        	  ELSE
                     VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0157' ELSE VAR_ERROR_CODE ||','||'VLD0157' END);
	        	  END IF;                    	  
              END;
                  
              --validate stale price
              IF VAR_PRICE_DATE IS NOT  NULL THEN    
                 SELECT GA.TRADE_COUNTRY_CD,GTC.LOCALE INTO VAR_TRADE_COUNTRY_CD,VAR_TO_TIMEZONE
                 FROM GEC_ASSET GA
                 INNER JOIN GEC_TRADE_COUNTRY GTC
                 ON GA.TRADE_COUNTRY_CD = GTC.TRADE_COUNTRY_CD
                 WHERE GA.ASSET_ID = VAR_ASSET_ID;
                      
                 VAR_BUSINESS_DAY := GEC_UTILS_PKG.TO_TIMEZONE(sysdate, VAR_FROM_TIMEZONE, VAR_TO_TIMEZONE);
                 VAR_VALIDATE_DATE_RESULT := VALIDATE_PRICE_DATE(TO_DATE(VAR_PRICE_DATE,'YYYYMMDD'),VAR_BUSINESS_DAY,VAR_TRADE_COUNTRY_CD,'T'); 
                 IF VAR_VALIDATE_DATE_RESULT = 'N' THEN--MORE THAN TWO DAY 
                     VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0103' ELSE VAR_ERROR_CODE ||','||'VLD0103' END);
                     VAR_IS_STALE_PRICE := 'ON';
                 END IF;
              ELSE
                 VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0103' ELSE VAR_ERROR_CODE ||','||'VLD0103' END);
                 VAR_IS_STALE_PRICE := 'ON';
              END IF;	              
          END IF;
          
          VALIDATE_PRICE(V_BORROW.PRICE,
                        VAR_PRICE,
                        VAR_TEMP_PRICE,
                        VAR_ASSET_ID,
                        VAR_BROKER_CD,
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
          
          IF V_BORROW.PRICE = GEC_CONSTANTS_PKG.C_BORROW_MIN_PRICE THEN
              VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0089' ELSE VAR_ERROR_CODE ||','||'VLD0089' END);
              VAR_PRICE := NULL;
          END IF;
          
          -- VALIDATE THE TRADE_DATE IS A WORKINGDAY
          IF V_BORROW.TRADE_DATE IS NOT NULL THEN
              
              IF GEC_UTILS_PKG.IS_WORKDAY(TO_DATE(V_BORROW.TRADE_DATE,'YYYY-MM-DD'),VAR_TRADE_COUNTRY_CD,'T') ='N' THEN
                  VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0073' ELSE VAR_ERROR_CODE ||','||'VLD0073' END);
              END IF; 
          END IF;
       
          IF V_BORROW.SETTLE_DATE IS NOT NULL THEN
              -- THE SETTLEDATE IS NOT A WORKDAY
              IF GEC_UTILS_PKG.IS_WORKDAY(TO_DATE(V_BORROW.SETTLE_DATE,'YYYY-MM-DD'),VAR_TO_TIMEZONE,'S') ='N' THEN
                  VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0072' ELSE VAR_ERROR_CODE ||','||'VLD0072' END);
              -- THE SETTLEDATE IS BEFORE TODAY
              ELSIF TO_NUMBER(TO_CHAR(GEC_UTILS_PKG.TO_TIMEZONE( SYSDATE ,VAR_FROM_TIMEZONE , VAR_TO_TIMEZONE),'YYYYMMDD')) > V_BORROW.SETTLE_DATE THEN 
                  VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0074' ELSE VAR_ERROR_CODE ||','||'VLD0074' END);
--                    VAR_ERROR_CODE := 'VLD0074';
             -- AFTER CUT OFF TIME 
              ELSIF TO_NUMBER(TO_CHAR(GEC_UTILS_PKG.TO_TIMEZONE( SYSDATE ,VAR_FROM_TIMEZONE , VAR_TO_TIMEZONE),'YYYYMMDD')) = V_BORROW.SETTLE_DATE THEN 
                  --VAR_CUTOFF_TIME := GEC_UTILS_PKG.TO_CUTOFF_TIME(SYSDATE,VAR_FROM_TIMEZONE, VAR_TO_TIMEZONE);
                  
                 IF VAR_ASSET_ID IS NOT NULL THEN 
                      BEGIN
                         IF GEC_UTILS_PKG.IS_AFTER_CUTOFF_TIME(VAR_ASSET_ID) =true THEN
                            VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0071' ELSE VAR_ERROR_CODE ||','||'VLD0071' END);
                         END IF;
                      END;
                  END IF;
              END IF;
              IF V_BORROW.TERM_DATE IS NOT NULL  THEN
              	IF V_BORROW.SETTLE_DATE > V_BORROW.TERM_DATE THEN
                	BEGIN
                 	 	VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0342' ELSE VAR_ERROR_CODE ||','||'VLD0342' END);
               		END;
              	END IF;
          	  END IF;
          	  IF V_BORROW.EXPECTED_RETURN_DATE IS NOT NULL  THEN
              	IF V_BORROW.SETTLE_DATE >= V_BORROW.EXPECTED_RETURN_DATE THEN
                	BEGIN
                 	 	VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0156' ELSE VAR_ERROR_CODE ||','||'VLD0156' END);
               		END;
               	ELSE
               		IF GEC_UTILS_PKG.IS_WORKDAY(TO_DATE(V_BORROW.EXPECTED_RETURN_DATE,'YYYY-MM-DD'),VAR_TRADE_COUNTRY_CD,'S') ='N' THEN
               			VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0157' ELSE VAR_ERROR_CODE ||','||'VLD0157' END);
               		END IF;
              	END IF;
          	  END IF;
          END IF;
          
          IF V_BORROW.TRADE_DATE IS NOT NULL AND V_BORROW.SETTLE_DATE IS NOT NULL THEN
              IF V_BORROW.TRADE_DATE  >  V_BORROW.SETTLE_DATE THEN
                  VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0082' ELSE VAR_ERROR_CODE ||','||'VLD0082' END);
              END IF;
          END IF;

          IF V_BORROW.RATE IS NULL THEN
              VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0088' ELSE VAR_ERROR_CODE ||','||'VLD0088' END);
          END IF;
          

          
          IF V_BORROW.BORROW_QTY IS NULL  OR V_BORROW.BORROW_QTY =0 THEN
              VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0090' ELSE VAR_ERROR_CODE ||','||'VLD0090' END);
          ELSE
              IF VAR_ASSET_TYPE_ID IS NOT NULL AND VAR_ASSET_TYPE_ID = 2 AND ( V_BORROW.BORROW_QTY MOD 1000) <> 0 THEN
                  VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0107' ELSE VAR_ERROR_CODE ||','||'VLD0107' END); 
              END IF;
          END IF;
          
          IF V_BORROW.DOMESTIC_TAX_PERCENTAGE IS NULL THEN
          	VAR_DOMESTIC_TAX_PER:=0;
          ELSE 
            VAR_DOMESTIC_TAX_PER:= V_BORROW.DOMESTIC_TAX_PERCENTAGE;
          END IF;
          
          IF V_BORROW.OVERSEAS_TAX_PERCENTAGE IS NULL THEN
          	VAR_OVERSEAS_TAX_PER :=0;
          ELSE
            VAR_OVERSEAS_TAX_PER :=V_BORROW.OVERSEAS_TAX_PERCENTAGE;
          END IF;
          
          IF V_BORROW.RECLAIM_RATE IS NULL THEN
            IF VAR_BROKER_CD IS NOT NULL THEN
            	SELECT BORROW_REQUEST_TYPE INTO VAR_BROKER_TYPE FROM GEC_BROKER WHERE BROKER_CD = VAR_BROKER_CD;
            	IF VAR_BROKER_TYPE = 'SB' THEN
            		IF VAR_ASSET_ID IS NOT NULL THEN
	            		SELECT TRADE_COUNTRY_CD INTO VAR_TRADE_COUNTRY_CD
	          	  		FROM GEC_ASSET
          	  			WHERE ASSET_ID=VAR_ASSET_ID;
            			IF VAR_TRADE_COUNTRY_CD = 'AU' THEN
            				VAR_RECLAIM_RATE :=1.4286;
            			ELSE
            				VAR_RECLAIM_RATE :=1;
            			END IF;
            		ELSE 
            			VAR_ERROR_CODE := (CASE WHEN VAR_ERROR_CODE IS NULL THEN 'VLD0146' ELSE VAR_ERROR_CODE||','||'VLD0146' END);
            		END IF;
            	ELSE
            		VAR_RECLAIM_RATE :=1;
            	END IF;
            ELSE
            	IF VAR_ASSET_ID IS NOT NULL THEN
            		SELECT TRADE_COUNTRY_CD INTO VAR_TRADE_COUNTRY_CD
	          	  	FROM GEC_ASSET
          	  		WHERE ASSET_ID=VAR_ASSET_ID;
          	  		IF VAR_TRADE_COUNTRY_CD <> 'AU' THEN
          	  			VAR_RECLAIM_RATE :=1;
          	  		ELSE
          	  			VAR_ERROR_CODE := (CASE WHEN VAR_ERROR_CODE IS NULL THEN 'VLD0146' ELSE VAR_ERROR_CODE||','||'VLD0146' END);
          	  		END IF;
          	  	ELSE
            		VAR_ERROR_CODE := (CASE WHEN VAR_ERROR_CODE IS NULL THEN 'VLD0146' ELSE VAR_ERROR_CODE||','||'VLD0146' END);
            	END IF;
            END IF;
          ELSE
            VAR_RECLAIM_RATE :=V_BORROW.RECLAIM_RATE;
          END IF;
          
          IF V_BORROW.PREPAY_DATE IS NULL AND V_BORROW.SETTLE_DATE IS NOT NULL AND VAR_ASSET_ID IS NOT NULL AND VAR_BROKER_CD IS NOT NULL AND V_BORROW.COLLATERAL_CURRENCY_CD IS NOT NULL THEN
          	SELECT BORROW_REQUEST_TYPE INTO VAR_BROKER_TYPE FROM GEC_BROKER WHERE BROKER_CD = VAR_BROKER_CD;
            IF VAR_BROKER_TYPE = 'SB' THEN
            	VAR_PREPAYDATE :=V_BORROW.SETTLE_DATE;
            ELSE
        		select nvl(gcbp.PREPAY_DATE_VALUE,tc.PREPAY_DATE_VALUE) as PREPAY_DATE_VALUE   INTO VAR_PREPAYDAY  
            	from gec_trade_country tc
              	join gec_asset ga
              	on tc.trade_country_cd = ga.trade_country_cd
              	left join gec_country_broker_profile gcbp
              	on gcbp.trade_country_cd = tc.trade_country_cd and gcbp.broker_cd = v_borrow.broker_cd
              	where ga.asset_id=var_asset_id ;
				SELECT TRADE_COUNTRY_CD INTO VAR_TRADE_COUNTRY_CD
          	  	FROM GEC_TRADE_COUNTRY
          	  	WHERE currency_cd=V_BORROW.COLLATERAL_CURRENCY_CD;
          	  	
          	  	VAR_PREPAYDATE :=GEC_UTILS_PKG.GET_TMINUSN_NUM(V_BORROW.SETTLE_DATE,VAR_PREPAYDAY,VAR_TRADE_COUNTRY_CD,'S');
            END IF;
          END IF;
          
          IF V_BORROW.PREPAY_DATE IS NULL THEN
            IF VAR_PREPAYDATE IS NOT NULL THEN
            	IF V_BORROW.COLLATERAL_CURRENCY_CD IS NOT NULL THEN
          			SELECT TRADE_COUNTRY_CD INTO VAR_TRADE_COUNTRY_CD
          	  		FROM GEC_TRADE_COUNTRY
          	  		WHERE currency_cd=V_BORROW.COLLATERAL_CURRENCY_CD;
          			IF GEC_UTILS_PKG.IS_WORKDAY(TO_DATE(VAR_PREPAYDATE,'YYYY-MM-DD'),VAR_TRADE_COUNTRY_CD,'S') ='N' THEN
                  		VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0148' ELSE VAR_ERROR_CODE ||','||'VLD0148' END);
                	END IF;
                END IF;
            	IF V_BORROW.TRADE_DATE IS NOT NULL THEN
            		IF VAR_PREPAYDATE<V_BORROW.TRADE_DATE THEN
            			 VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0149' ELSE VAR_ERROR_CODE ||','||'VLD0149' END);
            		END IF;
            	END IF;
            	IF V_BORROW.SETTLE_DATE IS NOT NULL THEN
            		IF VAR_PREPAYDATE>V_BORROW.SETTLE_DATE THEN
            			 VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0150' ELSE VAR_ERROR_CODE ||','||'VLD0150' END);
            		END IF;
            	END IF;
            ELSE
            	VAR_ERROR_CODE:= (CASE WHEN VAR_ERROR_CODE IS NULL THEN 'VLD0147' ELSE VAR_ERROR_CODE||','||'VLD0147' END);
            END IF;
            ELSE
            	VAR_PREPAYDATE :=V_BORROW.PREPAY_DATE;
            	IF V_BORROW.COLLATERAL_CURRENCY_CD IS NOT NULL THEN
          			SELECT TRADE_COUNTRY_CD INTO VAR_TRADE_COUNTRY_CD
          	  		FROM GEC_TRADE_COUNTRY
          	  		WHERE currency_cd=V_BORROW.COLLATERAL_CURRENCY_CD;
          			IF GEC_UTILS_PKG.IS_WORKDAY(TO_DATE(V_BORROW.PREPAY_DATE,'YYYY-MM-DD'),VAR_TRADE_COUNTRY_CD,'S') ='N' THEN
                  		VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0148' ELSE VAR_ERROR_CODE ||','||'VLD0148' END);
                	END IF;
                END IF;
            	IF V_BORROW.TRADE_DATE IS NOT NULL THEN
            		IF V_BORROW.PREPAY_DATE<V_BORROW.TRADE_DATE THEN
            			 VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0149' ELSE VAR_ERROR_CODE ||','||'VLD0149' END);
            		END IF;
            	END IF;
            	IF V_BORROW.SETTLE_DATE IS NOT NULL THEN
            		IF V_BORROW.PREPAY_DATE>V_BORROW.SETTLE_DATE THEN
            			 VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0150' ELSE VAR_ERROR_CODE ||','||'VLD0150' END);
            		END IF;
            	END IF;
          END IF;
          
          
          IF VAR_ASSET_ID IS NOT NULL THEN
          	SELECT TRADE_COUNTRY_CD INTO VAR_TRADE_COUNTRY_CD
	        FROM GEC_ASSET
          	WHERE ASSET_ID=VAR_ASSET_ID;
          END IF;
          IF VAR_BROKER_CD IS NOT NULL AND VAR_BROKER_TYPE <> 'SB' AND VAR_TRADE_COUNTRY_CD IS NOT NULL AND (VAR_TRADE_COUNTRY_CD<>'US' AND VAR_TRADE_COUNTRY_CD<>'CA') THEN
          	IF V_BORROW.COLLATERAL_TYPE IS NOT NULL AND (V_BORROW.COLLATERAL_TYPE<>'CASH' AND V_BORROW.COLLATERAL_TYPE<>'POOL') THEN 
	          	IF V_BORROW.PREPAY_RATE IS NOT NULL THEN
	          	  VAR_PREPAYRATE := V_BORROW.PREPAY_RATE;
	              IF V_BORROW.PREPAY_RATE <>0 THEN
	                VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0151' ELSE VAR_ERROR_CODE ||','||'VLD0151' END);
	              END IF;
	          	END IF;
	          	ELSE
	          		IF V_BORROW.PREPAY_RATE IS NULL THEN
	          			IF  VAR_BROKER_CD IS NOT NULL AND VAR_BROKER_TYPE <> 'SB' THEN
				          	SELECT nvl(gc.PREPAY_RATE, gbi.rate) INTO VAR_PREPAYRATE
							FROM    GEC_BROKER_VW gb 
							LEFT JOIN GEC_COUNTERPARTY gc
							ON gc.COUNTERPARTY_CD = gb.BROKER_CD AND gc.TRANSACTION_CD ='G1B'
							LEFT JOIN GEC_BENCHMARK_INDEX_RATE gbi
							ON gc.benchmark_index_cd = gbi.benchmark_index_cd
							WHERE gb.broker_cd =VAR_BROKER_CD;
							IF VAR_PREPAYRATE IS NULL THEN
								VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0367' ELSE VAR_ERROR_CODE ||','||'VLD0367' END);
							END IF;
						ELSE
							VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0367' ELSE VAR_ERROR_CODE ||','||'VLD0367' END);
						END IF;
					ELSE
						VAR_PREPAYRATE := V_BORROW.PREPAY_RATE;
	          		END IF;
	          END IF;
          ELSE
          	IF VAR_PREPAYDATE IS NOT NULL AND V_BORROW.SETTLE_DATE IS NOT NULL AND VAR_PREPAYDATE = V_BORROW.SETTLE_DATE OR V_BORROW.COLLATERAL_TYPE IS NOT NULL AND (V_BORROW.COLLATERAL_TYPE<>'CASH' AND V_BORROW.COLLATERAL_TYPE<>'POOL') THEN 
	          	IF V_BORROW.PREPAY_RATE IS NOT NULL THEN
	          	  VAR_PREPAYRATE := V_BORROW.PREPAY_RATE;
	              IF V_BORROW.PREPAY_RATE <>0 THEN
	                VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0151' ELSE VAR_ERROR_CODE ||','||'VLD0151' END);
	              END IF;
	          	END IF;
	          	ELSE
	          		IF V_BORROW.PREPAY_RATE IS NULL THEN
	          			IF  VAR_BROKER_CD IS NOT NULL AND VAR_BROKER_TYPE <> 'SB' THEN
				          	SELECT nvl(gc.PREPAY_RATE, gbi.rate) INTO VAR_PREPAYRATE
							FROM    GEC_BROKER_VW gb 
							LEFT JOIN GEC_COUNTERPARTY gc
							ON gc.COUNTERPARTY_CD = gb.BROKER_CD AND gc.TRANSACTION_CD ='G1B'
							LEFT JOIN GEC_BENCHMARK_INDEX_RATE gbi
							ON gc.benchmark_index_cd = gbi.benchmark_index_cd
							WHERE gb.broker_cd =VAR_BROKER_CD;
							IF VAR_PREPAYRATE IS NULL THEN
								VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0152' ELSE VAR_ERROR_CODE ||','||'VLD0152' END);
							END IF;
						ELSE
							VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0152' ELSE VAR_ERROR_CODE ||','||'VLD0152' END);
						END IF;
					ELSE
						VAR_PREPAYRATE := V_BORROW.PREPAY_RATE;
	          		END IF;
	          END IF;
          END IF;
          
          
          --gec2.0 misc change
          IF V_BORROW.MINIMUM_FEE_CD IS NULL THEN
            IF V_BORROW.COLLATERAL_CURRENCY_CD IS NOT NULL THEN
              V_BORROW.MINIMUM_FEE_CD := V_BORROW.COLLATERAL_CURRENCY_CD;
            END IF;
          END IF;
          
          IF V_BORROW.MINIMUM_FEE_CD IS NOT NULL THEN             
            SELECT COUNT(COLLATERAL_CURRENCY_CD_ID) INTO VAR_ROW_COUNT FROM GEC_COLLATERAL_CURRENCY_CODE WHERE COLLATERAL_CURRENCY_CD = V_BORROW.MINIMUM_FEE_CD;
            IF VAR_ROW_COUNT<=0 THEN
              VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0338' ELSE VAR_ERROR_CODE ||','||'VLD0338' END);
            END IF;
          END IF;
        
          IF V_BORROW.MINIMUM_FEE IS NOT NULL AND V_BORROW.MINIMUM_FEE_CD IS NULL THEN
          	VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0337' ELSE VAR_ERROR_CODE ||','||'VLD0337' END);
          END IF;
          
          IF V_BORROW.COLLATERAL_CURRENCY_CD IS NOT NULL THEN
            SELECT COUNT(COLLATERAL_CURRENCY_CD_ID) INTO VAR_COLL_CODE_COUNT FROM GEC_COLLATERAL_CURRENCY_CODE WHERE COLLATERAL_CURRENCY_CD = V_BORROW.COLLATERAL_CURRENCY_CD;
            IF VAR_COLL_CODE_COUNT < 1 THEN
              VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0307' ELSE VAR_ERROR_CODE ||','||'VLD0307' END);
            END IF;
          ELSE
          	VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0306' ELSE VAR_ERROR_CODE ||','||'VLD0306' END);
          END IF;
          
          IF V_BORROW.COLLATERAL_TYPE IS NOT NULL THEN
            SELECT COUNT(COLLATERAL_TYPE_ID) INTO VAR_COLL_TYPE_COUNT FROM GEC_COLLATERAL_TYPE WHERE COLLATERAL_TYPE = V_BORROW.COLLATERAL_TYPE;
            IF VAR_COLL_TYPE_COUNT < 1 THEN
              VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0310' ELSE VAR_ERROR_CODE ||','||'VLD0310' END);
            END IF;
          ELSE
          	VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0309' ELSE VAR_ERROR_CODE ||','||'VLD0309' END);
          END IF;
          -- END gec2.0 misc change
        
          UPDATE GEC_BORROW_TEMP GBT
          SET GBT.ASSET_ID = VAR_ASSET_ID, GBT.ERROR_CODE = VAR_ERROR_CODE ,GBT.COLLATERAL_TYPE = VAR_COLLATERAL_TYPE,GBT.COLLATERAL_PERCENTAGE = VAR_COLLATERAL_PERCENTAGE
              ,GBT.COLLATERAL_CURRENCY_CD = VAR_COLLATERAL_CURRENCY_CD, GBT.PRICE = VAR_PRICE , GBT.PRICE_ROUND_FACTOR = VAR_PRICE_ROUND_FACTOR
              ,GBT.DEFAULT_PRICE = VAR_TEMP_PRICE, GBT.IS_STALE_PRICE = VAR_IS_STALE_PRICE, GBT.IS_STALE_EXCHANGE_PRICE = VAR_IS_STALE_EXCHANGE_PRICE,
              GBT.EXCHANGE_RATE = VAR_EXCHANGE_RATE, GBT.SECURITY_EXCHANGE_RATE = VAR_SECURITY_EXCHANGE_RATE,GBT.MINIMUM_FEE_CD = V_BORROW.MINIMUM_FEE_CD,
              GBT.PREPAY_RATE = VAR_PREPAYRATE, GBT.PREPAY_DATE = VAR_PREPAYDATE,GBT.RECLAIM_RATE = VAR_RECLAIM_RATE,GBT.DOMESTIC_TAX_PERCENTAGE= VAR_DOMESTIC_TAX_PER,GBT.OVERSEAS_TAX_PERCENTAGE=VAR_OVERSEAS_TAX_PER
          WHERE GBT.BORROW_ID = V_BORROW.BORROW_ID;

          
          VAR_ERROR_CODE := NULL;
          VAR_ASSET_ID := NULL;
          VAR_ASSET_CODE := NULL;
          VAR_ASSET_CODE_TYPE := NULL;
          VAR_COLLATERAL_TYPE :=NULL;
          VAR_COLLATERAL_CURRENCY_CD :=NULL;
          VAR_STATUS :=NULL;
          VAR_PRICE := NULL;
          VAR_BROKER_CD := NULL;
          VAR_ASSET_TYPE_ID := NULL;
          VAR_ASSET_RS := NULL;
          VAR_BORROW_COUNT_OF_SAME_ASSET := NULL;
          VAR_BROKER_COUNT := NULL;
          VAR_COLLATERAL_PERCENTAGE := NULL;
          VAR_CUR_DATESTR := NULL;
          VAR_TRADE_COUNTRY_CD:= NULL;
          VAR_CLEAN_PRICE := NULL;
          VAR_DIRTY_PRICE := NULL;
          VAR_TO_TIMEZONE := NULL;
          VAR_FOUND_FLAG := NULL;
          VAR_BUSINESS_DAY := NULL;
          VAR_DATE := NULL;
          VAR_UTIL_NUMBER := NULL;
          VAR_CUTOFF_TIME := NULL; 
          VAR_PRICE_DATE := NULL;
          VAR_PRICE_CURRENCY := NULL;
          VAR_PRICE_ROUND_FACTOR := NULL;
          VAR_DPS := NULL;  
          VAR_EXCHANGE_RATE := NULL;
          VAR_EXCHANGE_DATE := NULL; 
          VAR_SECURITY_EXCHANGE_RATE := NULL;
          VAR_SECURITY_EXCHANGE_DATE := NULL;              
          VAR_TEMP_PRICE := NULL;
          VAR_VALIDATE_DATE_RESULT := NULL;
          VAR_IS_STALE_PRICE := NULL;
          VAR_STALE_EXCHANGE_PRICE := NULL;
          VAR_STALE_SECURITY_CUR := NULL;
          VAR_IS_STALE_EXCHANGE_PRICE := NULL;        
          VAR_DOMESTIC_TAX_PER  := NULL;  
          VAR_RECLAIM_RATE  := NULL;
          VAR_PREPAYRATE  := NULL;
          VAR_PREPAYDAY  := NULL;
          VAR_PREPAYDATE  := NULL;
          VAR_OVERSEAS_TAX_PER  := NULL;              
          V_BORROW.MINIMUM_FEE_CD := NULL;
          VAR_COLL_CODE_COUNT :=NULL;
          VAR_COLL_TYPE_COUNT :=NULL;
	  END LOOP;
	  
	  OPEN P_BORROWLIST_CURSOR FOR
	  SELECT GBT.ASSET_ID, GBT.ASSET_CODE, GBT.BROKER_CD, GBT.TRADE_DATE, GBT.SETTLE_DATE,
	         GBT.BORROW_QTY, GBT.PRICE, GBT.RATE, GBT.COLLATERAL_CURRENCY_CD, GBT.COLLATERAL_PERCENTAGE,
	         GBT.COLLATERAL_TYPE, GBT.POSITION_FLAG, GBT.COMMENT_TXT, GBT.ERROR_CODE, GBT.PRICE_ROUND_FACTOR,
	         GBT.DEFAULT_PRICE, GA.TRADE_COUNTRY_CD, GA.ASSET_TYPE_ID, GA.PRICE_DATE, GA.CLEAN_PRICE, GA.DIRTY_PRICE,
             GBT.IS_STALE_PRICE, GBT.IS_STALE_EXCHANGE_PRICE, GBT.PREPAY_DATE, GBT.PREPAY_RATE, tc.PREPAY_DATE_VALUE, GA.PRICE_CURRENCY_CD,
             GBT.RECLAIM_RATE*100 AS RECLAIM_RATE, GBT.OVERSEAS_TAX_PERCENTAGE*100 AS OVERSEAS_TAX_PERCENTAGE, GBT.DOMESTIC_TAX_PERCENTAGE*100 AS DOMESTIC_TAX_PERCENTAGE,
             GBT.MINIMUM_FEE,GBT.MINIMUM_FEE_CD, GBT.EXCHANGE_RATE, GBT.SECURITY_EXCHANGE_RATE,GBT.TERM_DATE,GBT.EXPECTED_RETURN_DATE
 
	  FROM GEC_BORROW_TEMP GBT
	  LEFT JOIN GEC_ASSET GA ON GBT.ASSET_ID = GA.ASSET_ID
	  LEFT JOIN GEC_TRADE_COUNTRY TC ON GA.TRADE_COUNTRY_CD = TC.TRADE_COUNTRY_CD;
	  
  END VALIDATE_LOADVALIDATED_BORROW;		
  
	PROCEDURE VALIDATE_SETTLE_DATE(p_assetId 	IN  NUMBER,
								   p_settleDate IN NUMBER,
								   p_tradeCty 	IN VARCHAR2,
								   p_errorCode	OUT		VARCHAR2)

	IS	
		var_cur_date NUMBER(8);
		var_cur_datestr VARCHAR(20);
		var_date DATE;
		v_locale GEC_TRADE_COUNTRY.LOCALE%TYPE := NULL;
		v_cuttoff_time GEC_TRADE_COUNTRY.CUTOFF_TIME%TYPE := NULL;
		VAR_FROM_TIMEZONE  GEC_TRADE_COUNTRY.LOCALE%TYPE; 
	BEGIN
		VAR_FROM_TIMEZONE := 'AMERICA/NEW_YORK';
	    BEGIN
	      SELECT c.LOCALE, c.CUTOFF_TIME
	        INTO v_locale, v_cuttoff_time
	        FROM GEC_ASSET a, GEC_TRADE_COUNTRY c 
	       WHERE a.ASSET_ID = p_assetId
	         AND a.TRADE_COUNTRY_CD = c.TRADE_COUNTRY_CD;
    	EXCEPTION WHEN NO_DATA_FOUND THEN
          -- Default to p_tradeCty
	      SELECT c.LOCALE, c.CUTOFF_TIME
	        INTO v_locale, v_cuttoff_time
	        FROM GEC_TRADE_COUNTRY c 
	       WHERE c.TRADE_COUNTRY_CD = p_tradeCty;
    	END;  
						
		var_cur_date := TO_NUMBER(TO_CHAR(GEC_UTILS_PKG.TO_TIMEZONE( SYSDATE ,VAR_FROM_TIMEZONE , v_locale),'YYYYMMDD'));

		IF p_settleDate < var_cur_date THEN
			p_errorCode := 'VLD0074';
		ELSIF p_settleDate = var_cur_date THEN
			var_cur_datestr := GEC_UTILS_PKG.NUMBER_TO_CHAR(var_cur_date) || v_cuttoff_time;
			var_date := GEC_UTILS_PKG.TO_BOS_TIME(var_cur_datestr, v_locale);
			IF var_date < sysdate THEN
				p_errorCode := 'VLD0071';
			END IF;
		END IF;
			
	END VALIDATE_SETTLE_DATE;
	
	
  FUNCTION VALIDATE_PRICE_DATE(P_PRICE_DATE IN DATE,
                               P_BUSINESS_DATE IN DATE,
                               P_TRADE_COUNTRY IN VARCHAR2,
                               P_TYPE IN VARCHAR2)  RETURN VARCHAR2
  IS
      VAR_BUS_DAY_OFFSET NUMBER(8);
      VAR_IS_WORKING_DAY VARCHAR2(10);
      VAR_PRICE_DATE DATE;
      VAR_BUSSINESS_DATE DATE;
  BEGIN
      VAR_BUS_DAY_OFFSET := 0;
      VAR_PRICE_DATE :=P_PRICE_DATE;
      VAR_BUSSINESS_DATE := P_BUSINESS_DATE;
      
      IF P_TYPE <> 'E' THEN
      	WHILE VAR_PRICE_DATE < VAR_BUSSINESS_DATE
      	LOOP
          	VAR_IS_WORKING_DAY := GEC_UTILS_PKG.IS_WORKDAY(VAR_BUSSINESS_DATE,P_TRADE_COUNTRY,P_TYPE);
          	IF VAR_IS_WORKING_DAY ='Y' THEN
              
              	IF VAR_BUS_DAY_OFFSET = 2 THEN
                  	RETURN 'N';
              	END IF;
              	VAR_BUS_DAY_OFFSET := VAR_BUS_DAY_OFFSET+1;
			
          	END IF;
          	VAR_BUSSINESS_DATE := VAR_BUSSINESS_DATE-1;
      	END LOOP;
      ELSE
      	WHILE VAR_PRICE_DATE < VAR_BUSSINESS_DATE
      	LOOP
			IF TO_CHAR(VAR_BUSSINESS_DATE, 'D') = '1' OR TO_CHAR(VAR_BUSSINESS_DATE, 'D') = '7' THEN      	
          		VAR_IS_WORKING_DAY := 'N';
          	ELSE 
          		VAR_IS_WORKING_DAY := 'Y';
          	END IF;
          	
          	IF VAR_IS_WORKING_DAY ='Y' THEN
              
              	IF VAR_BUS_DAY_OFFSET = 2 THEN
                  	RETURN 'N';
              	END IF;
              	VAR_BUS_DAY_OFFSET := VAR_BUS_DAY_OFFSET+1;
			
          	END IF;
          	
          	VAR_BUSSINESS_DATE := VAR_BUSSINESS_DATE-1;
      	END LOOP;      	      	
      END IF;
      RETURN 'Y';
  END VALIDATE_PRICE_DATE;	
  
	PROCEDURE BATCH_VALIDATE_ORDERS
	IS
	BEGIN
	  BATCH_VALIDATE_FUND;
	  BATCH_VALIDATE_STATEGY;
	  BATCH_VALIDATE_IM;
	  BATCH_VALIDATE_ASSET;
	  BATCH_VALIDATE_TRADE_DATE;
	  BATCH_VALIDATE_SETTLE_DATE;
	  BATCH_VALIDATE_SHARE_QTY;
	END BATCH_VALIDATE_ORDERS;
  
	PROCEDURE BATCH_VALIDATE_FUND
	IS
		CURSOR v_cur_invalide_fund is
			select t.row_id, t.fund_cd
			from
				(select temp.rowid row_id, gf.fund_cd fund_cd
				from gec_im_order_temp temp
				left join gec_fund gf
				on temp.fund_cd= gf.fund_cd) t
			where t.fund_cd is null;
	BEGIN
		FOR v_item IN v_cur_invalide_fund
		LOOP
			UPDATE GEC_IM_ORDER_TEMP 
			SET FUND_ERROR_CODE = GEC_ERROR_CODE_PKG.C_VLD_CD_FUND_INVALID
			WHERE rowid=v_item.row_id;
		END LOOP;
	END BATCH_VALIDATE_FUND;
	
	PROCEDURE BATCH_VALIDATE_STATEGY
	IS
		CURSOR v_cur_invalide_strategy is
			select t.row_id, t.strategy_id
			from
				(select temp.rowid row_id, gs.strategy_id strategy_id
				from gec_im_order_temp temp
				left join gec_fund gf
				on temp.fund_cd= gf.fund_cd
				left join gec_strategy gs
				on temp.strategy_id = gs.strategy_id
				and gs.status='A'
				where temp.FUND_ERROR_CODE is null
				) t
			where t.strategy_id is null;
			
		CURSOR v_cur_invalide_im is
			select t.row_id, t.client_id
			from
				(select temp.rowid row_id, gc.client_id client_id
				from gec_im_order_temp temp
				left join gec_strategy gs
				on temp.strategy_id = gs.strategy_id
				AND gs.status = 'A'
				left join gec_client gc
				on temp.INVESTMENT_MANAGER_CD = gc.client_short_name
				and gc.client_status='A'
				and gs.client_id= gc.client_id
				where temp.FUND_ERROR_CODE is null
				) t
			where t.client_id is null;
	BEGIN
		FOR v_item IN v_cur_invalide_strategy
		LOOP
			UPDATE GEC_IM_ORDER_TEMP 
			SET FUND_ERROR_CODE = GEC_ERROR_CODE_PKG.C_VLD_CD_FUND_STRATEGY_INVALID
			WHERE rowid=v_item.row_id;
		END LOOP;
		
		FOR v_item IN v_cur_invalide_im
		LOOP
			UPDATE GEC_IM_ORDER_TEMP 
			SET FUND_ERROR_CODE = GEC_ERROR_CODE_PKG.C_VLD_CD_FUND_STRATEGY_INVALID
			WHERE rowid=v_item.row_id;
		END LOOP;
	END BATCH_VALIDATE_STATEGY;
	
	PROCEDURE BATCH_VALIDATE_IM
	IS
		
		CURSOR v_cur_invalide_im is
			select t.row_id, t.client_id
			from
				(select temp.rowid row_id, gc.client_id client_id
				from gec_im_order_temp temp
				left join gec_strategy gs
				on temp.strategy_id = gs.strategy_id
				left join gec_client gc
				on temp.INVESTMENT_MANAGER_CD = gc.client_short_name
				and gc.client_status='A'
				where temp.FUND_ERROR_CODE is null
				) t
			where t.client_id is null;
	BEGIN
		FOR v_item IN v_cur_invalide_im
		LOOP
			UPDATE GEC_IM_ORDER_TEMP 
			SET FUND_ERROR_CODE = GEC_ERROR_CODE_PKG.C_VLD_CD_FUND_IM_INVALID
			WHERE rowid=v_item.row_id;
		END LOOP;
		
	END BATCH_VALIDATE_IM;
	
	PROCEDURE BATCH_VALIDATE_ASSET
	IS
		var_asset_rs GEC_ASSET_TP_ARRAY;
		var_asset GEC_ASSET_TP;
		var_found_flag NUMBER;  
		var_asset_code_type gec_asset_identifier.asset_code_type%type;
		var_status varchar2(1);
		var_default_trade_cty varchar2(2) :='US';
		CURSOR v_cur_invalide_asset is
			select rowid row_id, asset_code
			from gec_im_order_temp;
	BEGIN
		FOR v_item IN v_cur_invalide_asset
		LOOP 
			VALIDATE_ASSET_ID(NULL, 
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            v_item.ASSET_CODE,
                            NULL,
                            var_found_flag, 
                            var_asset_code_type,
                            var_status ,
                            var_asset_rs);
           	IF var_found_flag=0 THEN
           		UPDATE GEC_IM_ORDER_TEMP 
				SET ASSET_ERROR_CODE = GEC_ERROR_CODE_PKG.C_VLD_CD_ASSET_INVALID
				WHERE rowid=v_item.row_id;
			ELSIF var_found_flag=1 THEN
				var_asset := var_asset_rs(1);
				UPDATE gec_im_order_temp
				SET 
					asset_id = var_asset.asset_id,
					cusip = var_asset.cusip,
					isin = var_asset.isin,
					sedol = var_asset.sedol,
					quik = var_asset.quik,
					trade_country_cd = NVL(var_asset.trade_country_cd, var_default_trade_cty),
                    ticker = var_asset.ticker,
					description = var_asset.description,
					asset_code_type = var_asset_code_type,
					asset_type_id = var_asset.asset_type_id
				WHERE rowid = v_item.row_id;
			ELSE
				UPDATE GEC_IM_ORDER_TEMP 
				SET ASSET_ERROR_CODE = GEC_ERROR_CODE_PKG.C_VLD_CD_ASSET_MULTIPLE
				WHERE rowid=v_item.row_id;
			END IF;
		END LOOP;
	END BATCH_VALIDATE_ASSET;
	
	PROCEDURE BATCH_VALIDATE_ASSET_FLIP
	IS
		var_asset_rs GEC_ASSET_TP_ARRAY;
		var_asset GEC_ASSET_TP;
		var_found_flag NUMBER;  
		var_asset_code_type gec_asset_identifier.asset_code_type%type;
		var_status varchar2(1);
		var_default_trade_cty varchar2(2) :='US';
		CURSOR v_cur_invalide_asset IS
			SELECT rowid row_id, asset_code
			FROM GEC_FLIP_TRADE_TEMP;
	BEGIN
		FOR v_item IN v_cur_invalide_asset
		LOOP 
			VALIDATE_ASSET_ID(NULL, 
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            v_item.ASSET_CODE,
                            NULL,
                            var_found_flag, 
                            var_asset_code_type,
                            var_status ,
                            var_asset_rs);
           	IF var_found_flag=0 THEN
           		NULL;
			ELSIF var_found_flag=1 THEN
				var_asset := var_asset_rs(1);
				UPDATE GEC_FLIP_TRADE_TEMP
				SET 
					asset_id = var_asset.asset_id,
					cusip = var_asset.cusip,
					isin = var_asset.isin,
					sedol = var_asset.sedol,
					quik = var_asset.quik,
					trade_country_cd = NVL(var_asset.trade_country_cd, var_default_trade_cty),
                    ticker = var_asset.ticker,
					description = var_asset.description
				WHERE rowid = v_item.row_id;
			ELSE
				UPDATE GEC_FLIP_TRADE_TEMP 
				SET ASSET_ERROR = GEC_ERROR_CODE_PKG.C_VLD_CD_ASSET_MULTIPLE
				WHERE rowid=v_item.row_id;
			END IF;
		END LOOP;
	END BATCH_VALIDATE_ASSET_FLIP;
	
	PROCEDURE BATCH_VALIDATE_TRADE_DATE
	IS
		CURSOR v_cur_invalide_trade_date is
			select rowid row_id
			from gec_im_order_temp temp
			where GEC_UTILS_PKG.IS_WORKDAY(GEC_UTILS_PKG.NUMBER_TO_DATE(temp.BUSINESS_DATE),temp.trade_country_cd)='N';
	BEGIN
		FOR v_item IN v_cur_invalide_trade_date
		LOOP 
           		UPDATE GEC_IM_ORDER_TEMP 
				SET TRADE_DATE_ERROR_CODE = GEC_ERROR_CODE_PKG.C_VLD_CD_TRADE_DATE_INVALID
				WHERE rowid=v_item.row_id;
		END LOOP;
	END BATCH_VALIDATE_TRADE_DATE;  	
	
	PROCEDURE BATCH_VALIDATE_SETTLE_DATE
	IS
		CURSOR v_cur_invalide_settle_date is
			select rowid row_id
			from gec_im_order_temp temp
			where GEC_UTILS_PKG.IS_WORKDAY(GEC_UTILS_PKG.NUMBER_TO_DATE(temp.SETTLE_DATE),temp.trade_country_cd,'S')='N';
	BEGIN
		FOR v_item IN v_cur_invalide_settle_date
		LOOP 
           		UPDATE GEC_IM_ORDER_TEMP 
				SET SETTLE_DATE_ERROR_CODE = GEC_ERROR_CODE_PKG.C_VLD_CD_SETTLE_DATE_INVALID
				WHERE rowid=v_item.row_id;
		END LOOP;
	END BATCH_VALIDATE_SETTLE_DATE; 	
	
	PROCEDURE BATCH_VALIDATE_SHARE_QTY
	IS
		CURSOR v_cur_invalid_share_qty is
			select rowid row_id
			from gec_im_order_temp temp
			where EXISTS (SELECT 1 FROM GEC_ASSET ga where temp.ASSET_ID = ga.ASSET_ID and ga.ASSET_TYPE_ID = '2' and NOT REGEXP_LIKE(temp.SHARE_QTY,'000$'));
	BEGIN
		FOR v_item IN v_cur_invalid_share_qty
		LOOP 
           		UPDATE GEC_IM_ORDER_TEMP 
				SET SHARE_QTY_ERROR_CODE = GEC_ERROR_CODE_PKG.C_VLD_CD_SHARE_QTY_INVALID
				WHERE rowid=v_item.row_id;
		END LOOP;
	END BATCH_VALIDATE_SHARE_QTY;
	
	PROCEDURE VALIDATE_PRICE(
  VAR_INPUT_PRICE IN GEC_BULK_G1_TRADE.PRICE%TYPE,
  VAR_PRICE OUT GEC_BULK_G1_TRADE.PRICE%TYPE,
  VAR_TEMP_PRICE OUT GEC_BULK_G1_TRADE.PRICE%TYPE,
  VAR_ASSET_ID IN GEC_ASSET.ASSET_ID%TYPE,
  VAR_BROKER_CD IN GEC_BROKER.BROKER_CD%TYPE,
  VAR_TRADE_COUNTRY_CD IN GEC_TRADE_COUNTRY.CURRENCY_CD%TYPE,
  VAR_PRICE_ROUND_FACTOR IN GEC_BROKER.US_PRICE_ROUND_FACTOR%TYPE,
  VAR_DPS IN GEC_BROKER.NOU_US_DPS%TYPE,
  VAR_EXCHANGE_RATE IN GEC_EXCHANGE_RATE.EXCHANGE_RATE%TYPE,
  VAR_EXCHANGE_DATE IN GEC_EXCHANGE_RATE.EXCHANGE_DATE%TYPE,
  VAR_SECURITY_EXCHANGE_RATE IN GEC_EXCHANGE_RATE.EXCHANGE_RATE%TYPE,
  VAR_SECURITY_EXCHANGE_DATE IN GEC_EXCHANGE_RATE.EXCHANGE_DATE%TYPE,
  VAR_COLLATERAL_PERCENTAGE IN GEC_BROKER.US_COLLATERAL_PERCENTAGE%TYPE,
  VAR_ASSET_TYPE_ID IN GEC_ASSET.ASSET_TYPE_ID%TYPE,
  VAR_CLEAN_PRICE IN GEC_ASSET.CLEAN_PRICE%TYPE,
  VAR_DIRTY_PRICE IN GEC_ASSET.CLEAN_PRICE%TYPE,
  VAR_FROM_TIMEZONE IN GEC_TRADE_COUNTRY.LOCALE%TYPE,
  VAR_BUSINESS_DAY IN OUT DATE,
  VAR_STALE_EXCHANGE_PRICE IN OUT VARCHAR2,
  VAR_STALE_SECURITY_CUR IN OUT VARCHAR2,
  VAR_IS_STALE_EXCHANGE_PRICE IN OUT VARCHAR,
  VAR_VALIDATE_DATE_RESULT IN OUT VARCHAR2,
  VAR_ERROR_CODE IN OUT VARCHAR2) AS
  VAR_UTIL_NUMBER  NUMBER(10);
  BEGIN
  --CACULATE DEAULT PRICE
  IF VAR_INPUT_PRICE IS NOT NULL AND VAR_INPUT_PRICE<>GEC_CONSTANTS_PKG.C_BORROW_MIN_PRICE THEN
      VAR_PRICE := VAR_INPUT_PRICE;
      IF VAR_ASSET_ID IS NOT NULL AND VAR_BROKER_CD IS NOT NULL THEN
        -- IF THE PRICE IS INCORRECT ROUND LOGIC
        VAR_UTIL_NUMBER := 100/VAR_PRICE_ROUND_FACTOR;
        VAR_TEMP_PRICE := VAR_UTIL_NUMBER * VAR_PRICE;
        IF TRUNC(VAR_TEMP_PRICE) <> VAR_TEMP_PRICE THEN
          VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0104' ELSE VAR_ERROR_CODE ||','||'VLD0104' END);
        END IF;
        -- IF THE PRICE LIES IN BETWEEN 0.9*R AND 1.1*R
        IF (VAR_CLEAN_PRICE IS NOT NULL AND VAR_ASSET_TYPE_ID = 4) OR (VAR_CLEAN_PRICE IS NOT NULL AND VAR_DIRTY_PRICE IS NOT NULL AND VAR_ASSET_TYPE_ID <> 4)  THEN                    
          -- validate the exchange rate is not null
          IF VAR_EXCHANGE_RATE IS NULL OR VAR_SECURITY_EXCHANGE_RATE IS NULL THEN
            VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0154' ELSE VAR_ERROR_CODE ||','||'VLD0154' END);
          ELSE
          -- validate stale exchange date
          VAR_BUSINESS_DAY := GEC_UTILS_PKG.TO_TIMEZONE(sysdate, VAR_FROM_TIMEZONE, 'AMERICA/NEW_YORK');
          VAR_STALE_EXCHANGE_PRICE := VALIDATE_PRICE_DATE(TO_DATE(VAR_EXCHANGE_DATE,'YYYYMMDD'),VAR_BUSINESS_DAY,'US','E'); 
          VAR_STALE_SECURITY_CUR := VALIDATE_PRICE_DATE(TO_DATE(VAR_SECURITY_EXCHANGE_DATE,'YYYYMMDD'),VAR_BUSINESS_DAY,'US','E');
            IF VAR_STALE_EXCHANGE_PRICE = 'N' OR VAR_STALE_SECURITY_CUR = 'N' THEN--MORE THAN TWO DAY 
              VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0155' ELSE VAR_ERROR_CODE ||','||'VLD0155' END);
              VAR_IS_STALE_EXCHANGE_PRICE := 'ON';              	
            END IF;
          -- for equilty
          IF VAR_ASSET_TYPE_ID = 4 THEN
            IF VAR_EXCHANGE_RATE <> VAR_SECURITY_EXCHANGE_RATE THEN
              VAR_TEMP_PRICE := TRUNC((VAR_CLEAN_PRICE * VAR_EXCHANGE_RATE / VAR_SECURITY_EXCHANGE_RATE) * VAR_COLLATERAL_PERCENTAGE, VAR_DPS);
            ELSE
              VAR_TEMP_PRICE := TRUNC(VAR_CLEAN_PRICE * VAR_COLLATERAL_PERCENTAGE, VAR_DPS) ; 
            END IF;
          ELSE
            IF VAR_EXCHANGE_RATE <> VAR_SECURITY_EXCHANGE_RATE THEN
              VAR_TEMP_PRICE := TRUNC((VAR_CLEAN_PRICE * VAR_EXCHANGE_RATE / VAR_SECURITY_EXCHANGE_RATE) * VAR_COLLATERAL_PERCENTAGE + (VAR_DIRTY_PRICE - VAR_CLEAN_PRICE) * VAR_EXCHANGE_RATE / VAR_SECURITY_EXCHANGE_RATE , VAR_DPS);
            ELSE
              VAR_TEMP_PRICE := TRUNC(VAR_CLEAN_PRICE * VAR_COLLATERAL_PERCENTAGE + VAR_DIRTY_PRICE - VAR_CLEAN_PRICE, VAR_DPS);
            END IF;
          END IF;
          -- calculate the default price      
          VAR_TEMP_PRICE := CEIL(VAR_TEMP_PRICE*VAR_UTIL_NUMBER)/VAR_UTIL_NUMBER; 
          --validate the price limit between 0.9 * default price and 1.1 * default price
          IF (VAR_PRICE>VAR_TEMP_PRICE*1.1 OR VAR_PRICE< VAR_TEMP_PRICE*0.9)  AND VAR_VALIDATE_DATE_RESULT = 'Y' THEN
            VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0105' ELSE VAR_ERROR_CODE ||','||'VLD0105' END);
          END IF;                         	        
        END IF;
       END IF;
      END IF;
    ELSIF VAR_INPUT_PRICE IS NULL THEN
     IF VAR_ASSET_ID IS NOT NULL AND VAR_BROKER_CD IS NOT NULL THEN                 
       IF (VAR_CLEAN_PRICE IS NOT NULL AND VAR_ASSET_TYPE_ID = 4) OR (VAR_CLEAN_PRICE IS NOT NULL AND VAR_DIRTY_PRICE IS NOT NULL AND VAR_ASSET_TYPE_ID <> 4) AND VAR_TRADE_COUNTRY_CD IS NOT NULL THEN                 
           VAR_UTIL_NUMBER := 100/VAR_PRICE_ROUND_FACTOR;
           IF VAR_EXCHANGE_RATE IS NULL OR VAR_SECURITY_EXCHANGE_RATE IS NULL THEN
              VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0154' ELSE VAR_ERROR_CODE ||','||'VLD0154' END);
           ELSE
               -- validate stale exchange date
               VAR_BUSINESS_DAY := GEC_UTILS_PKG.TO_TIMEZONE(sysdate, VAR_FROM_TIMEZONE, 'AMERICA/NEW_YORK');                      
               VAR_STALE_EXCHANGE_PRICE := VALIDATE_PRICE_DATE(TO_DATE(VAR_EXCHANGE_DATE,'YYYYMMDD'),VAR_BUSINESS_DAY,'US','E'); 
               VAR_STALE_SECURITY_CUR := VALIDATE_PRICE_DATE(TO_DATE(VAR_SECURITY_EXCHANGE_DATE,'YYYYMMDD'),VAR_BUSINESS_DAY,'US','E');
           IF VAR_STALE_EXCHANGE_PRICE = 'N' OR VAR_STALE_SECURITY_CUR = 'N' THEN--MORE THAN TWO DAY 
               VAR_ERROR_CODE :=  (CASE  WHEN  VAR_ERROR_CODE IS NULL  THEN 'VLD0155' ELSE VAR_ERROR_CODE ||','||'VLD0155' END);
               VAR_IS_STALE_EXCHANGE_PRICE := 'ON';              	
           END IF;
            -- for equilty
           IF VAR_ASSET_TYPE_ID = 4 THEN
              	IF VAR_EXCHANGE_RATE <> VAR_SECURITY_EXCHANGE_RATE THEN
                   VAR_PRICE := TRUNC((VAR_CLEAN_PRICE * VAR_EXCHANGE_RATE / VAR_SECURITY_EXCHANGE_RATE) * VAR_COLLATERAL_PERCENTAGE, VAR_DPS);
                ELSE
                   VAR_PRICE := TRUNC(VAR_CLEAN_PRICE * VAR_COLLATERAL_PERCENTAGE, VAR_DPS) ; 
              	END IF;
           ELSE
                IF VAR_EXCHANGE_RATE <> VAR_SECURITY_EXCHANGE_RATE THEN
                   VAR_PRICE := TRUNC((VAR_CLEAN_PRICE * VAR_EXCHANGE_RATE / VAR_SECURITY_EXCHANGE_RATE) * VAR_COLLATERAL_PERCENTAGE + (VAR_DIRTY_PRICE - VAR_CLEAN_PRICE) * VAR_EXCHANGE_RATE / VAR_SECURITY_EXCHANGE_RATE , VAR_DPS);
                ELSE
                   VAR_PRICE := TRUNC(VAR_CLEAN_PRICE * VAR_COLLATERAL_PERCENTAGE + VAR_DIRTY_PRICE - VAR_CLEAN_PRICE, VAR_DPS);
               	END IF;
           END IF;     
                         
                VAR_PRICE := CEIL(VAR_PRICE * VAR_UTIL_NUMBER)/VAR_UTIL_NUMBER;
                -- STORAGE THE DEFAULT PRICE
                VAR_TEMP_PRICE := VAR_PRICE;                                                    
                END IF;                      
              ELSE
                 VAR_PRICE := VAR_INPUT_PRICE;
       END IF;
    ELSE 
     VAR_PRICE := VAR_INPUT_PRICE;
     END IF;
    END IF;
  END VALIDATE_PRICE; 	
END GEC_VALIDATION_PKG;
/
