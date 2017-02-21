-------------------------------------------------------------------------
-- Copyright (c) 2009 State Street Bank and Trust Corp.
-- 225 Franklin Street, Boston, MA 02110, U.S.A.
-- All rights reserved.
--
-- "GEC_AVAILABILITY_PKG.sql is the copyrighted,
-- proprietary property of State Street Bank and Trust Company and its
-- subsidiaries and affiliates which retain all right, title and interest
-- therein."
--
-- Revision History
--
-- Date            Programmer                Note
-- ------------    --------------------      ----------------------------
-- Nov 3, 2010     Huang, Gubo               initial
-- Jan 18, 2011    Huang, Gubo               Performance Tunning
-- Apr 8, 2011     Huang, Gubo               Non Cash function
-- Nov 11, 2011    Hu, Gaoxiang              GEC 1.5 enhancement
-------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE GEC_ALLOCATION_PKG
AS
	TYPE FUND_RATE IS RECORD(	LOAN_INDEX VARCHAR2(8),
								NSB_RATE GEC_G1_BOOKING.RATE%type,
								SB_RATE GEC_G1_BOOKING.RATE%type
								);
								
	TYPE NONUS_FUND_EX_LOAN_INFO IS RECORD(	LOAN_INDEX VARCHAR2(30),
									RECLAIM_RATE GEC_G1_BOOKING.RECLAIM_RATE%type,
									OVERSEAS_TAX_PERCENTAGE GEC_G1_BOOKING.OVERSEAS_TAX_PERCENTAGE%type,
									DOMESTIC_TAX_PERCENTAGE GEC_G1_BOOKING.DOMESTIC_TAX_PERCENTAGE%type,
									COLLATERAL_CURRENCY_CD GEC_G1_BOOKING.COLLATERAL_CURRENCY_CD%type,
									COLL_TYPE GEC_G1_BOOKING.COLL_TYPE%type,
									PREPAY_RATE GEC_COUNTERPARTY.PREPAY_RATE%type
									);	
	
	TYPE FUND_RATE_MAP IS TABLE OF FUND_RATE INDEX BY VARCHAR2(8);
	TYPE NONUS_EX_LOAN_INFO_MAP IS TABLE OF NONUS_FUND_EX_LOAN_INFO INDEX BY VARCHAR2(30);
								
	PROCEDURE PREPARE_TEMP_BORROWS( p_input_type IN VARCHAR2, p_borrow_file_type IN VARCHAR2, p_trans_type IN VARCHAR2, p_valid_status OUT VARCHAR2);
	PROCEDURE PREPARE_TEMP_ORDERS(p_user_id IN VARCHAR2, p_type IN VARCHAR2, p_valid_status OUT VARCHAR2);
	PROCEDURE MERGE_BORROWS(p_user_id IN VARCHAR2, p_input_type IN VARCHAR2,p_trans_type IN VARCHAR2, p_valid_status OUT VARCHAR2);
	
	PROCEDURE PROCESS_AUTO_ALLOCATION(
										p_user_id IN VARCHAR2,
										p_demand_request_id NUMBER,
										p_input_type IN VARCHAR2,
										p_settle_date IN NUMBER,
										p_asset_id IN NUMBER,
										p_nsb_coll_type IN VARCHAR2,
										p_nsb_coll_code IN VARCHAR2,
										p_branch_code IN VARCHAR2,
										p_borrow_file_type IN VARCHAR2,
										p_trans_type IN VARCHAR2,
										p_need_allocation IN VARCHAR2,
										p_status OUT VARCHAR2,
										p_shorts_cursor OUT SYS_REFCURSOR,
										p_borrows_cursor OUT SYS_REFCURSOR,
										p_error_code OUT VARCHAR2,
										p_error_hint OUT VARCHAR2
										);
		
	
	
	PROCEDURE DELETE_MANU_INTERV_BORROWS(
											p_borrow_id IN NUMBER,
											p_asset_id IN NUMBER,
											p_nsb_coll_type IN VARCHAR2,
											p_nsb_coll_code IN VARCHAR2,
											p_branch_code IN VARCHAR2,
											p_settle_date IN NUMBER,
											p_trans_type IN VARCHAR2,
											p_status OUT VARCHAR2,
											p_shorts_cursor OUT SYS_REFCURSOR
										);
	
	PROCEDURE LOCK_SHORTS(p_demand_request_id NUMBER, p_input_type IN VARCHAR2, p_settle_date IN NUMBER, p_end_settle_date IN NUMBER);
	
	PROCEDURE CALC_RUN_COUNT(p_allo_key IN VARCHAR2, p_count OUT NUMBER);
	PROCEDURE FILL_ERROR_RST(p_shorts_cursor OUT SYS_REFCURSOR, p_borrows_cursor OUT SYS_REFCURSOR);
	
	PROCEDURE FILL_ALLO_ERROR_RST(p_allo_cursor OUT SYS_REFCURSOR);
	
	PROCEDURE CHECK_MULTI_SETTLEDATES(p_error OUT VARCHAR2);
	
	PROCEDURE CHECK_MULTI_PREPAYDATES(p_error OUT VARCHAR2);
										
	PROCEDURE SAVE_NO_DEMANDS(p_user_id IN VARCHAR2, p_status OUT VARCHAR2, p_borrows_cursor OUT SYS_REFCURSOR, p_shorts_cursor OUT SYS_REFCURSOR, p_allo_cursor OUT SYS_REFCURSOR, p_error_code OUT VARCHAR2);
	
	PROCEDURE SAVE_MANU_INTERV(p_user_id IN VARCHAR2, p_asset_id IN NUMBER, p_status OUT VARCHAR2, p_borrows_cursor OUT SYS_REFCURSOR, p_shorts_cursor OUT SYS_REFCURSOR, p_allo_cursor OUT SYS_REFCURSOR, p_error_code OUT VARCHAR2, p_borrow_request_id OUT NUMBER);
	
	PROCEDURE CHECK_MUANUAL_BORROW_STATUS(var_valid OUT VARCHAR2);
										
	PROCEDURE GENERATE_LOCATE_FEE(p_user_id IN VARCHAR2);
	
	PROCEDURE GET_FEE_QTY_CHANGE(fund_cd IN VARCHAR ,trade_country_cd IN VARCHAR,borrow_request_type IN VARCHAR,position_flag IN VARCHAR,order_id IN NUMBER,fee OUT NUMBER);
	PROCEDURE SET_SHORT_QTY_FOR_M;									
										
	FUNCTION SINGLE_ALLOCATION(p_user_id IN VARCHAR2, p_asset_id IN NUMBER, p_borrow_settle_date IN NUMBER, p_borrow_request_type IN VARCHAR2, p_input_type IN VARCHAR2, p_agency_flag IN VARCHAR2, p_across_flag IN VARCHAR2, p_error_code OUT VARCHAR2, p_error_hint OUT VARCHAR2, p_rate_map IN OUT NOCOPY FUND_RATE_MAP, p_ex_loan_info_map IN OUT NOCOPY NONUS_EX_LOAN_INFO_MAP) RETURN VARCHAR2;
	
	FUNCTION REVERSE_SINGLE_ALLO_SB(p_user_id IN VARCHAR2, p_asset_id IN NUMBER, p_r_alloc_key IN VARCHAR2,p_across IN VARCHAR2, p_error_code OUT VARCHAR2) RETURN VARCHAR2;
	FUNCTION REVERSE_SINGLE_ALLO_NSB(p_user_id IN VARCHAR2, p_asset_id IN NUMBER, p_r_alloc_key IN VARCHAR2,p_across IN VARCHAR2, p_error_code OUT VARCHAR2) RETURN VARCHAR2;
	FUNCTION REVERSE_SINGLE_ALLO_AGE(p_user_id IN VARCHAR2, p_asset_id IN NUMBER, p_r_alloc_key IN VARCHAR2,p_across IN VARCHAR2, p_error_code OUT VARCHAR2) RETURN VARCHAR2;
	
	
	PROCEDURE PREPARE_SHORTS_FOR_FILE(p_borrow_file_type IN VARCHAR, p_asset_id IN NUMBER, p_borrow_settle_date IN NUMBER, p_borrow_order_id IN NUMBER, p_agency_code IN VARCHAR, p_branch_cd IN VARCHAR, p_trade_country IN VARCHAR, p_borrow_request_type IN VARCHAR);   
	PROCEDURE PREPARE_SHORTS_FOR_BATCH(p_asset_id IN NUMBER, p_settle_date IN NUMBER, p_end_settle_date IN NUMBER, p_agency_code IN VARCHAR, p_request_type IN VARCHAR, p_branch_cd IN VARCHAR, p_trade_country IN VARCHAR);
	PROCEDURE PREPARE_SHORTS_FOR_SINGLE(p_asset_id IN NUMBER, p_settle_date IN NUMBER, p_end_settle_date IN NUMBER, p_nsb_coll_type IN VARCHAR2, p_nsb_coll_code IN VARCHAR, p_trans_type IN VARCHAR, p_agency_code IN VARCHAR, p_request_type IN VARCHAR, p_branch_cd IN VARCHAR, p_borrow_branch_cd IN VARCHAR, p_trade_country IN VARCHAR);
	
	PROCEDURE BOOK_ONE_ALLOCATION(p_user_id IN VARCHAR2,
								  p_asset_id IN NUMBER, 
								  p_short_fund_cd IN VARCHAR2, 
								  p_short_settle_date IN NUMBER, 
								  p_borrow_id IN NUMBER, 
								  p_order_id IN NUMBER, 
								  p_b_qty IN NUMBER, 
								  p_o_qty IN NUMBER, 
								  p_fee IN NUMBER, 
								  p_l_settle_date IN NUMBER,
								  p_l_prepay_date IN NUMBER,
     							  p_prepay_rate IN NUMBER,
								  p_reclaim_rate IN NUMBER,
								  p_oversea_tax IN NUMBER,
								  p_domestic_tax IN NUMBER,
								  p_coll_type IN VARCHAR2,
								  p_coll_code IN VARCHAR2,
								  p_min_fee IN NUMBER,		
								  p_min_fee_cd IN VARCHAR2,									  
								  p_borrow_request_type IN VARCHAR2,
								  p_broker_cd IN VARCHAR2);
	
	-- added for increasing performacne of response uploading							  
	PROCEDURE BOOK_ONE_ALLOCATION2(p_user_id IN VARCHAR2,
								  p_asset_id IN NUMBER, 
								  p_short_fund_cd IN VARCHAR2, 
								  p_short_settle_date IN NUMBER, 
								  p_borrow_id IN NUMBER, 
								  p_order_id IN NUMBER, 
								  p_b_qty IN NUMBER, 
								  p_o_qty IN NUMBER, 
								  p_fee IN NUMBER, 
								  p_l_settle_date IN NUMBER,
								  p_l_prepay_date IN NUMBER,
								  p_prepay_rate IN NUMBER,
								  p_reclaim_rate IN NUMBER,
								  p_oversea_tax IN NUMBER,
								  p_domestic_tax IN NUMBER,
								  p_coll_type IN VARCHAR2,
								  p_coll_code IN VARCHAR2,
								  p_min_fee IN NUMBER,								  
								  p_borrow_request_type IN VARCHAR2,
								  p_broker_cd IN VARCHAR2,
								  p_update_flag IN VARCHAR2);
	
	
	PROCEDURE GET_COLL_CODE_TYPE_INFO(p_trade_country IN VARCHAR2,
									  p_fund_cd IN VARCHAR2,
									  p_sb_coll_type OUT VARCHAR2,
									  p_nsb_coll_type OUT VARCHAR2,
									  p_sb_coll_code OUT VARCHAR2,
									  p_nsb_coll_code OUT VARCHAR2);
									  
	PROCEDURE GET_LOAN_INFO(p_trade_country_cd IN VARCHAR2,
								  p_fund_cd IN VARCHAR2,
								  p_borrow_request_type IN VARCHAR2,								  
								  p_coll_type OUT VARCHAR2,
								  p_domestic_tax OUT NUMBER, 
								  p_overseas_tax OUT NUMBER, 
								  p_error_code OUT VARCHAR2);									  
									  
	PROCEDURE CHECK_FUND_CONFIG_ORDER_LOAN(p_im_order_ids IN GEC_NUMBER_ARRAY,
	                                       p_error_code OUT VARCHAR2,
	                                       p_fund OUT VARCHAR2,
	                                       p_trade_country OUT VARCHAR2);
	                                       
	PROCEDURE GET_LOAN_DEF_SET_PRE_DATE(p_borrow_request_type IN VARCHAR2,
											  p_short_fund_cd IN VARCHAR2,
											  p_trade_country IN VARCHAR2,
											  p_short_settle_date IN NUMBER,
											  p_prepay_date OUT NUMBER,
											  p_settle_date OUT NUMBER);
	
	FUNCTION GET_EQUILEND_PREPAY_RATE(p_transaction_cd IN VARCHAR2, p_broker_cd IN VARCHAR2) RETURN NUMBER;
		
	FUNCTION GET_FUND_RATE_FROM_MAP(p_borrow_request_type IN VARCHAR2, p_fund_cd IN VARCHAR2, p_trade_country_cd IN VARCHAR2, p_loan_index IN VARCHAR2, p_error_code OUT NOCOPY VARCHAR2, p_rate_map IN OUT NOCOPY FUND_RATE_MAP) RETURN NUMBER;	
			  
	FUNCTION GET_LOAN_RATE(p_borrow_request_type IN VARCHAR2, p_fund_cd IN VARCHAR2, p_trade_country_cd IN VARCHAR2, p_date IN NUMBER, p_error_code OUT VARCHAR2) RETURN NUMBER;
	
	FUNCTION GET_NONUS_EX_LOAN_INFO_MAP(p_borrow_request_type IN VARCHAR2, p_fund_cd IN VARCHAR2,  p_trade_country_cd IN VARCHAR2, p_loan_index IN VARCHAR2, p_borrow_settle_date IN NUMBER, p_prepay_date IN NUMBER, p_error_code OUT NOCOPY VARCHAR2, p_nonus_loan_info_map IN OUT NOCOPY NONUS_EX_LOAN_INFO_MAP) RETURN NONUS_FUND_EX_LOAN_INFO;
	FUNCTION GET_NONUS_EX_LOAN_INFO(p_borrow_request_type IN VARCHAR2, p_fund_cd IN VARCHAR2, p_trade_country_cd IN VARCHAR2, p_borrow_settle_date IN NUMBER, p_prepay_date IN NUMBER, p_error_code OUT VARCHAR2) RETURN NONUS_FUND_EX_LOAN_INFO;
		
	FUNCTION GET_INDEX_RATE(p_index_cd IN VARCHAR2, p_date IN NUMBER) RETURN NUMBER;
	FUNCTION GET_MAX_RATE_FOR_SAME_SHORT(p_imorder_id IN GEC_ALLOCATION.IM_ORDER_ID%TYPE
                                         ,P_IF_FORCE IN VARCHAR2
                                         ,P_FUND_CD IN GEC_FUND.FUND_CD%TYPE
                                         ,P_SETTLE_DATE IN GEC_ALLOCATION.SETTLE_DATE%TYPE
                                         ,P_REQUEST_TYPE IN GEC_BROKER.BORROW_REQUEST_TYPE%TYPE
                                         ,P_PREPAY_DATE IN GEC_ALLOCATION.PREPAY_DATE%TYPE) RETURN GEC_ALLOCATION.RATE%TYPE;
	FUNCTION CALCULATE_PRICE_BY_IM_ORDER_ID(P_GEC_IM_ORDER IN GEC_IM_ORDER.IM_ORDER_ID%TYPE) RETURN GEC_ASSET.CLEAN_PRICE%TYPE;
	
	FUNCTION GENERATE_LINK_REFERENCE( P_ALLOCATION_ID IN GEC_ALLOCATION.ALLOCATION_ID%TYPE) RETURN GEC_LOAN.LINK_REFERENCE%TYPE;
	
	FUNCTION GENERATE_BORROW_LINK(p_borrow_request_type IN VARCHAR2, p_loan_number IN VARCHAR2, p_broker_code IN VARCHAR2, p_type IN VARCHAR2) RETURN GEC_LOAN.LINK_REFERENCE%TYPE;
	FUNCTION GENERATE_BORROW_LINK_REF RETURN GEC_LOAN.LINK_REFERENCE%TYPE;
END GEC_ALLOCATION_PKG;
/

CREATE OR REPLACE PACKAGE BODY GEC_ALLOCATION_PKG
AS
	-- p_valid_status 'Y' 
	--                'N' validate failed
	--p_input_type  F is from File or Message; S is from single; B is from batch Null is from ui
	--p_borrow_file_type not use now
	--p_tran_type FT for flip trades SHORTSB for shortSB
	PROCEDURE PREPARE_TEMP_BORROWS( p_input_type IN VARCHAR2, p_borrow_file_type IN VARCHAR2, p_trans_type IN VARCHAR2, p_valid_status OUT VARCHAR2)
	IS
		var_asset_rs GEC_ASSET_TP_ARRAY;
		var_status varchar2(1); 
		var_asset_code_type GEC_ASSET_IDENTIFIER.ASSET_CODE_TYPE%type;   
		var_found_flag NUMBER(1); 
		var_asset_id GEC_ASSET.ASSET_ID%type;
		var_demand_id GEC_BORROW.BORROW_ORDER_ID%type;
		var_borrow_req_type GEC_BORROW_REQUEST.BORROW_REQUEST_TYPE%type;
		var_agency_flag GEC_BROKER.AGENCY_FLAG%type;
		var_allo_priority GEC_BORROW_REQUEST_TYPE.ALLOCATION_ORDER%type;
		var_prepay_rate GEC_COUNTERPARTY.PREPAY_RATE%type;		
		var_broker_cd GEC_BROKER.BROKER_CD%type;
		var_rec_legal_entity_cd GEC_BROKER.LEGAL_ENTITY_CD%type;
		var_prepay_day NUMBER(3);
		var_cur_date NUMBER(8);
		var_cur_datestr VARCHAR(20);
		var_date DATE;
		var_coll_type GEC_BORROW.COLLATERAL_TYPE%type;
		var_coll_trade_country GEC_TRADE_COUNTRY.TRADE_COUNTRY_CD%type;
		var_coll_code_trade_country GEC_TRADE_COUNTRY.TRADE_COUNTRY_CD%type;
	    v_prepay_date GEC_BORROW.PREPAY_DATE%type;
		 
		CURSOR v_temp_borrows IS
			SELECT BORROW_ID, ASSET_ID, BROKER_CD, CUSIP, SEDOL, ISIN, QUIK, TICKER, ASSET_CODE, COLLATERAL_TYPE, COLLATERAL_DESC, REC_SUB_ACCOUNT_ID, FROM_SUB_ACCOUNT_ID, 
				   SETTLE_DATE, PREPAY_DATE, PREPAY_RATE, BORROW_REQUEST_TYPE, RESPONSE_LOG_NUM, REC_LEGAL_ENTITY_ID, FROM_LEGAL_ENTITY_ID, BORROW_ORDER_ID,TRADE_COUNTRY_CD,FROM_CORP_ID,REC_CORP_ID,COLLATERAL_CURRENCY_CD
			FROM GEC_BORROW_TEMP;
		
		CURSOR error_borrows IS
			SELECT BORROW_ID, ASSET_ID, BROKER_CD, BORROW_REQUEST_TYPE, ALLOCATION_ORDER, AGENCY_FLAG, SETTLE_DATE, TRADE_DATE, COLLATERAL_TYPE, COLLATERAL_CURRENCY_CD, 
				   BORROW_QTY, POSITION_FLAG,BRANCH_CD, PRICE, RATE, RECLAIM_RATE, OVERSEAS_TAX_PERCENTAGE, DOMESTIC_TAX_PERCENTAGE, TRADE_COUNTRY_CD, PREPAY_RATE, PREPAY_DATE, BOOK_G1_BORROW_FLAG
			FROM GEC_BORROW_TEMP
			WHERE ASSET_ID IS NULL OR 
					BROKER_CD IS NULL OR BORROW_REQUEST_TYPE IS NULL OR ALLOCATION_ORDER IS NULL OR AGENCY_FLAG IS NULL OR BOOK_G1_BORROW_FLAG IS NULL OR
					COLLATERAL_TYPE IS NULL OR
					COLLATERAL_CURRENCY_CD IS NULL OR
					BORROW_QTY IS NULL OR
					POSITION_FLAG IS NULL OR
					BRANCH_CD IS NULL OR
					TRADE_COUNTRY_CD IS NULL OR
					PRICE IS NULL OR
					RATE IS NULL OR
					RECLAIM_RATE IS NULL OR
					OVERSEAS_TAX_PERCENTAGE IS NULL OR
					DOMESTIC_TAX_PERCENTAGE IS NULL OR
					(PREPAY_RATE IS NULL AND (COLLATERAL_TYPE = 'CASH' OR COLLATERAL_TYPE='POOL') AND BORROW_REQUEST_TYPE <> 'SB' AND TRADE_COUNTRY_CD<>'US' AND TRADE_COUNTRY_CD<>'CA') OR
					(PREPAY_RATE IS NULL AND PREPAY_DATE < SETTLE_DATE AND (COLLATERAL_TYPE = 'CASH' OR COLLATERAL_TYPE='POOL') AND BORROW_REQUEST_TYPE <> 'SB' AND (TRADE_COUNTRY_CD='US' OR TRADE_COUNTRY_CD='CA')) OR
					(PREPAY_RATE IS NOT NULL AND PREPAY_RATE<>0 AND COLLATERAL_TYPE <> 'CASH' AND COLLATERAL_TYPE <>'POOL') OR
					(PREPAY_RATE IS NOT NULL AND PREPAY_RATE<>0 AND SETTLE_DATE = PREPAY_DATE AND (BORROW_REQUEST_TYPE='SB' OR (BORROW_REQUEST_TYPE<>'SB' AND (TRADE_COUNTRY_CD='US' OR TRADE_COUNTRY_CD='CA')))) OR
					(p_input_type = GEC_CONSTANTS_PKG.C_BORROW_SINGLE AND p_trans_type = GEC_CONSTANTS_PKG.C_SB_SHORT AND BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB);
					
		CURSOR asset_borrows IS
				SELECT t.BORROW_ID, t.BORROW_QTY, t.SETTLE_DATE, t.TRADE_DATE, c.LOCALE, c.TRADE_COUNTRY_CD, t.PREPAY_DATE, t.PREPAY_RATE,t.TERM_DATE,t.EXPECTED_RETURN_DATE, c.CUTOFF_TIME, a.ASSET_TYPE_ID,t.rowid as ROW_ID, t.COLLATERAL_CURRENCY_CD
				FROM GEC_BORROW_TEMP t, GEC_ASSET a, GEC_TRADE_COUNTRY c 
				WHERE a.ASSET_ID = t.ASSET_ID AND
					  a.TRADE_COUNTRY_CD = c.TRADE_COUNTRY_CD;
						
	BEGIN	
		-- set asset id first for classfy the GC/SP for file	
		IF p_input_type IS NOT NULL THEN	
			-- Set ASSET_ID from CUSIP/SEDOL/ISIN/QUIK/TICKER/ASSET_CODE
			FOR v_borrow IN v_temp_borrows
			LOOP
				IF v_borrow.ASSET_ID IS NULL THEN
					GEC_VALIDATION_PKG.VALIDATE_ASSET_ID(
	                      						v_borrow.CUSIP,
	                      						v_borrow.ISIN,
	                      						v_borrow.SEDOL,
	                      						v_borrow.QUIK,
	                      						v_borrow.TICKER,
	                      						NULL,
	                      						NULL,
	                      						v_borrow.ASSET_CODE,
	                      						NULL,
	                      						var_found_flag, 
	                      						var_asset_code_type,
	                      						var_status,
	                      						var_asset_rs
	                      					);
	                IF var_found_flag = 1 AND var_asset_rs.COUNT = 1 THEN
						var_asset_id := var_asset_rs(var_asset_rs.first).ASSET_ID;
						
						UPDATE GEC_BORROW_TEMP 
						SET ASSET_ID = var_asset_id,
							TRADE_COUNTRY_CD = (SELECT ga.TRADE_COUNTRY_CD FROM GEC_ASSET ga WHERE ga.ASSET_ID = var_asset_id)					
						WHERE BORROW_ID = v_borrow.BORROW_ID;
						
					END IF;
				ELSE
					UPDATE GEC_BORROW_TEMP 
					SET 
						TRADE_COUNTRY_CD = (SELECT ga.TRADE_COUNTRY_CD FROM GEC_ASSET ga WHERE ga.ASSET_ID = v_borrow.ASSET_ID)
					WHERE BORROW_ID = v_borrow.BORROW_ID;						
				END IF;		
			END LOOP;
		ELSE
			FOR v_borrow IN v_temp_borrows
			LOOP
				UPDATE GEC_BORROW_TEMP 
				SET 
					TRADE_COUNTRY_CD = (SELECT ga.TRADE_COUNTRY_CD FROM GEC_ASSET ga WHERE ga.ASSET_ID = v_borrow.ASSET_ID)
				WHERE BORROW_ID = v_borrow.BORROW_ID;				
			END LOOP;					
		END IF;	
		
		IF p_input_type IS NOT NULL AND p_input_type = GEC_CONSTANTS_PKG.C_BORROW_FILE THEN					
			-- Set BORROW_ORDER_ID from RESPONSE_LOG_NUM for file response
			UPDATE GEC_BORROW_TEMP temp SET
				(temp.BORROW_ORDER_ID, temp.SETTLE_DATE) = (
										SELECT bo.BORROW_ORDER_ID,  NVL(temp.SETTLE_DATE, bo.SETTLE_DATE)
										FROM GEC_BORROW_ORDER bo
										WHERE bo.LOG_NUMBER = temp.RESPONSE_LOG_NUM AND
									     	  rownum = 1
										);
										
			-- convert LEGAL_ENTITY_ID to BROKER_CD, SB from receive legal entity, other from from legal entity
			IF p_trans_type <> GEC_CONSTANTS_PKG.C_FLIP_TRADE THEN
				UPDATE GEC_BORROW_TEMP temp 
				SET	  temp.POSITION_FLAG =  NVL((SELECT o.POSITION_FLAG FROM GEC_IM_ORDER o,GEC_BORROW_ORDER bo, GEC_BORROW_ORDER_DETAIL detail, GEC_BORROW_TEMP t WHERE t.BORROW_ORDER_ID = bo.BORROW_ORDER_ID AND bo.BORROW_ORDER_ID = detail.BORROW_ORDER_ID AND detail.IM_ORDER_ID = o.IM_ORDER_ID AND o.POSITION_FLAG = 'SP' AND t.BORROW_ID = temp.BORROW_ID AND rownum = 1) 
												,'GC');
			ELSE 
				UPDATE GEC_BORROW_TEMP temp 
				SET	  temp.POSITION_FLAG = 'GC';
			END IF;
			
			-- convert coll type from external to GEC
			-- the rate is from fee amount of equilend if coll type <> cash
			-- collCashAmount is only for external response
			-- miniFee is only for external response
			FOR v_borrow IN v_temp_borrows
			LOOP
				IF v_borrow.FROM_LEGAL_ENTITY_ID = 8 and v_borrow.FROM_CORP_ID =2 THEN
					-- BR2.4.	If the fromLegalEntity is 8,  then it will Agency  SB or NSB borrow
					BEGIN
						SELECT DISTINCT b.BROKER_CD, type.BORROW_REQUEST_TYPE, b.AGENCY_FLAG INTO var_broker_cd, var_borrow_req_type, var_agency_flag FROM GEC_BROKER b, GEC_BORROW_REQUEST_TYPE type
						WHERE 
							  b.LEGAL_ENTITY_ID = v_borrow.REC_LEGAL_ENTITY_ID AND
							  b.CORP_ID = v_borrow.REC_CORP_ID and 
							  b.BORROW_REQUEST_TYPE = type.BORROW_REQUEST_TYPE AND
							  (b.BORROW_REQUEST_TYPE = 'SB' OR
							  b.BORROW_REQUEST_TYPE = 'NSB') AND
							  b.AGENCY_FLAG = 'Y';
						EXCEPTION WHEN NO_DATA_FOUND THEN
							var_broker_cd := NULL;
							var_borrow_req_type := NULL;
							var_agency_flag := NULL;					  
					END;	

				ELSE
					-- BR2.5.	If the fromLegalEntty is not 8, then this borrow will be the external borrow				
					BEGIN
						SELECT DISTINCT b.BROKER_CD, type.BORROW_REQUEST_TYPE, b.AGENCY_FLAG INTO var_broker_cd, var_borrow_req_type, var_agency_flag FROM GEC_BROKER b, GEC_BORROW_REQUEST_TYPE type
						WHERE 
							  b.LEGAL_ENTITY_ID = v_borrow.FROM_LEGAL_ENTITY_ID AND
							  b.CORP_ID = v_borrow.FROM_CORP_ID AND 
							  b.BORROW_REQUEST_TYPE = type.BORROW_REQUEST_TYPE AND
							  (b.BORROW_REQUEST_TYPE <> 'SB' AND
							  b.AGENCY_FLAG = 'N');
						EXCEPTION 
						WHEN NO_DATA_FOUND THEN
							var_broker_cd := NULL;
							var_borrow_req_type := NULL;
							var_agency_flag := NULL;	
						WHEN TOO_MANY_ROWS THEN
							BEGIN
								SELECT b.LEGAL_ENTITY_CD into var_rec_legal_entity_cd FROM GEC_BROKER b
								WHERE
									  b.LEGAL_ENTITY_ID = v_borrow.REC_LEGAL_ENTITY_ID AND
									  b.CORP_ID = v_borrow.REC_CORP_ID;
								SELECT DISTINCT b.BROKER_CD, type.BORROW_REQUEST_TYPE, b.AGENCY_FLAG INTO var_broker_cd, var_borrow_req_type, var_agency_flag FROM GEC_BROKER b, GEC_BORROW_REQUEST_TYPE type
								WHERE 
									  b.LEGAL_ENTITY_ID = v_borrow.FROM_LEGAL_ENTITY_ID AND
									  b.CORP_ID = v_borrow.FROM_CORP_ID AND 
									  b.LEGAL_ENTITY_CD = var_rec_legal_entity_cd AND 
									  b.BORROW_REQUEST_TYPE = type.BORROW_REQUEST_TYPE AND
									  (b.BORROW_REQUEST_TYPE <> 'SB' AND
									  b.AGENCY_FLAG = 'N');
								EXCEPTION 
								WHEN NO_DATA_FOUND THEN
									var_broker_cd := NULL;
									var_borrow_req_type := NULL;
									var_agency_flag := NULL;	
							END;									  
					END;
				END IF;	
				
				-- set broker code
				UPDATE GEC_BORROW_TEMP temp SET temp.BROKER_CD = var_broker_cd, temp.BORROW_REQUEST_TYPE = var_borrow_req_type WHERE BORROW_ID = v_borrow.BORROW_ID;
				
				-- convert the coll type
				UPDATE GEC_BORROW_TEMP 			
				SET COLLATERAL_TYPE = CASE WHEN v_borrow.COLLATERAL_TYPE = 'CA' OR v_borrow.COLLATERAL_TYPE = 'CP'
										   THEN (SELECT m.GEC_COLLATERAL_TYPE FROM GEC_COLLATERAL_TYPE_MAP m WHERE m.EXTERNAL_COLLATERAL_TYPE = v_borrow.COLLATERAL_TYPE)
										   WHEN (NVL(v_borrow.FROM_SUB_ACCOUNT_ID, v_borrow.REC_SUB_ACCOUNT_ID)) || v_borrow.COLLATERAL_DESC IS NOT NULL AND v_borrow.COLLATERAL_TYPE <> 'CA'
										   THEN (SELECT m.GEC_COLLATERAL_TYPE FROM GEC_COLLATERAL_TYPE_MAP m WHERE m.EXTERNAL_COLLATERAL_TYPE = v_borrow.COLLATERAL_TYPE AND m.SUBTYPE = (NVL(v_borrow.FROM_SUB_ACCOUNT_ID, v_borrow.REC_SUB_ACCOUNT_ID)) || v_borrow.COLLATERAL_DESC)
										   ELSE (SELECT m.GEC_COLLATERAL_TYPE FROM GEC_COLLATERAL_TYPE_MAP m WHERE m.EXTERNAL_COLLATERAL_TYPE = v_borrow.COLLATERAL_TYPE AND m.SUBTYPE IS NULL)
										   END
				WHERE BORROW_ID = v_borrow.BORROW_ID;

				UPDATE GEC_BORROW_TEMP
				SET RATE = CASE WHEN COLLATERAL_TYPE <> 'CASH' THEN FEE ELSE RATE END,
					OVERSEAS_TAX_PERCENTAGE = 0,
					DOMESTIC_TAX_PERCENTAGE = 0,
					AMOUNT = CASE WHEN BORROW_REQUEST_TYPE <> 'SB' AND var_agency_flag <> 'Y' THEN AMOUNT ELSE NULL END,
					POSITION_FLAG = CASE WHEN BORROW_REQUEST_TYPE <> 'SB' AND var_agency_flag <> 'Y' THEN 'GC' ELSE POSITION_FLAG END				
				WHERE BORROW_ID = v_borrow.BORROW_ID;
				-- PSHARE
				IF v_borrow.PREPAY_DATE IS NULL THEN
					IF var_borrow_req_type= GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB THEN
						var_prepay_day:=0;
					ELSE
						BEGIN
							SELECT gcbp.PREPAY_DATE_VALUE INTO var_prepay_day
							FROM GEC_COUNTRY_BROKER_PROFILE gcbp
							WHERE gcbp.TRADE_COUNTRY_CD = v_borrow.TRADE_COUNTRY_CD
							AND gcbp.BROKER_CD = var_broker_cd;
						EXCEPTION WHEN NO_DATA_FOUND THEN
							SELECT gtc.PREPAY_DATE_VALUE INTO var_prepay_day
							FROM GEC_TRADE_COUNTRY gtc
							WHERE gtc.TRADE_COUNTRY_CD=v_borrow.TRADE_COUNTRY_CD;
						END;
					END IF;
					
					SELECT TRADE_COUNTRY_CD INTO var_coll_code_trade_country FROM GEC_TRADE_COUNTRY
					WHERE CURRENCY_CD=v_borrow.COLLATERAL_CURRENCY_CD;
					v_prepay_date:=GEC_UTILS_PKG.GET_TMINUSN_NUM(v_borrow.SETTLE_DATE,var_prepay_day,var_coll_code_trade_country,'S');
					
					IF GEC_UTILS_PKG.IS_WORKDAY(GEC_UTILS_PKG.NUMBER_TO_DATE(v_prepay_date),var_coll_code_trade_country,'S') ='N' THEN
							v_prepay_date:=GEC_UTILS_PKG.GET_TMINUSN_NUM(v_prepay_date,1,var_coll_code_trade_country,'S');
					END IF;
					
					UPDATE GEC_BORROW_TEMP SET PREPAY_DATE = v_prepay_date WHERE BORROW_ID = v_borrow.BORROW_ID;
				END IF;
				
				IF var_borrow_req_type IS NOT NULL AND var_borrow_req_type <>'SB' AND v_borrow.TRADE_COUNTRY_CD IS NOT NULL AND (v_borrow.TRADE_COUNTRY_CD<>'US' AND v_borrow.TRADE_COUNTRY_CD<>'CA') THEN
					SELECT COLLATERAL_TYPE INTO var_coll_type FROM GEC_BORROW_TEMP WHERE BORROW_ID = v_borrow.BORROW_ID;
					IF var_coll_type <> 'CASH' AND var_coll_type<>'POOL' THEN				
						UPDATE GEC_BORROW_TEMP SET PREPAY_RATE = NULL WHERE BORROW_ID = v_borrow.BORROW_ID;
					ELSE
						IF v_borrow.PREPAY_RATE IS NULL AND var_borrow_req_type <> 'SB' THEN
							var_prepay_rate := GET_EQUILEND_PREPAY_RATE('G1B', var_broker_cd);
							UPDATE GEC_BORROW_TEMP SET PREPAY_RATE = var_prepay_rate WHERE var_prepay_rate IS NOT NULL AND BORROW_ID = v_borrow.BORROW_ID;								
						END IF;
					END IF;
				ELSE
					IF v_borrow.PREPAY_DATE < v_borrow.SETTLE_DATE THEN
					SELECT COLLATERAL_TYPE INTO var_coll_type FROM GEC_BORROW_TEMP WHERE BORROW_ID = v_borrow.BORROW_ID;
						IF var_coll_type <> 'CASH' AND var_coll_type<>'POOL' THEN				
							UPDATE GEC_BORROW_TEMP SET PREPAY_RATE = NULL WHERE BORROW_ID = v_borrow.BORROW_ID;
						ELSE
							IF v_borrow.PREPAY_RATE IS NULL AND var_borrow_req_type <> 'SB' THEN
								var_prepay_rate := GET_EQUILEND_PREPAY_RATE('G1B', var_broker_cd);
	
								UPDATE GEC_BORROW_TEMP SET PREPAY_RATE = var_prepay_rate WHERE var_prepay_rate IS NOT NULL AND BORROW_ID = v_borrow.BORROW_ID;								
							END IF;
						END IF;			
					ELSE
						UPDATE GEC_BORROW_TEMP SET PREPAY_RATE = NULL WHERE BORROW_ID = v_borrow.BORROW_ID;				
					END IF;
				END IF;
				-- get default prepay rate

			END LOOP;
			--set net dividend rate
			UPDATE GEC_BORROW_TEMP temp SET temp.RECLAIM_RATE = 1 where temp.RECLAIM_RATE is null or temp.RECLAIM_RATE=0;
		END IF;		
		-- set legal entity cd
		UPDATE GEC_BORROW_TEMP temp SET temp.LEGAL_ENTITY_CD = (select LEGAL_ENTITY_CD from gec_broker gb where gb.BROKER_CD = temp.BROKER_CD );
		
		
		-- update type for temp borrow, and make broker code/coll type/coll code to all upper case(For GEC-2102), set default NON_CASH_FLAG to N
		-- for NC(Non Cash) file input,	set the NON_CASH_FLAG to 'Y'
		UPDATE GEC_BORROW_TEMP temp
		SET TYPE = CASE WHEN p_input_type IS NULL THEN NVL(TYPE, GEC_CONSTANTS_PKG.C_BORROW_MANUAL_INPUT) 
						WHEN p_input_type = GEC_CONSTANTS_PKG.C_BORROW_FILE THEN NVL(TYPE, GEC_CONSTANTS_PKG.C_BORROW_AUTO_INPUT) 
						ELSE NVL(TYPE, GEC_CONSTANTS_PKG.C_BORROW_MANUAL_INPUT) END,
--			NON_CASH_FLAG = CASE WHEN p_input_type = GEC_CONSTANTS_PKG.C_BORROW_FILE AND p_borrow_file_type IS NOT NULL AND p_borrow_file_type = 'NC' THEN 'Y' ELSE 'N' END,
			BROKER_CD = UPPER(BROKER_CD),
			COLLATERAL_TYPE = UPPER(COLLATERAL_TYPE),
			COLLATERAL_CURRENCY_CD = UPPER(COLLATERAL_CURRENCY_CD);
		
		-- set BOOK_G1_BORROW_FLAG
		UPDATE GEC_BORROW_TEMP temp
		SET BOOK_G1_BORROW_FLAG = (SELECT BOOK_G1_BORROW_FLAG FROM GEC_BROKER br WHERE temp.BROKER_CD = br.BROKER_CD);
		
		-- convert BROKER_CD to DML_BROKER_CD, for 002625, P02625
		-- change for CMO function, M0997 to 002625, NON_CASH_FLAG to Y
		-- 0997 to 002625 and T0997 to P02625
		UPDATE GEC_BORROW_TEMP temp 
		SET (temp.BROKER_CD, temp.NON_CASH_FLAG) = (SELECT v.DML_BROKER_CD, v.NON_CASH_AGENCY_FLAG FROM GEC_BROKER_VW v WHERE temp.BROKER_CD = v.BROKER_CD)
		WHERE EXISTS(SELECT 1 FROM GEC_BROKER_VW v WHERE temp.BROKER_CD = v.BROKER_CD);
		

	--	UPDATE GEC_BORROW_TEMP temp 
	--	SET temp.BROKER_CD = NVL((SELECT m.DML_BROKER_CD FROM GEC_G1_DML_BROKER_MAP m WHERE m.G1_COUNTERPARTY_CD = temp.BROKER_CD AND m.NON_CASH_FLAG = 'Y'), temp.BROKER_CD),
	--		temp.NON_CASH_FLAG = 'Y'
	--	WHERE EXISTS(SELECT 1 FROM GEC_G1_DML_BROKER_MAP m_o WHERE m_o.G1_COUNTERPARTY_CD = temp.BROKER_CD AND m_o.NON_CASH_FLAG = 'Y');
		
	--	UPDATE GEC_BORROW_TEMP temp 
	--	SET temp.BROKER_CD = NVL((SELECT m.DML_BROKER_CD FROM GEC_G1_DML_BROKER_MAP m WHERE m.G1_COUNTERPARTY_CD = temp.BROKER_CD AND m.NON_CASH_FLAG = 'N'), temp.BROKER_CD)
	--	WHERE EXISTS(SELECT 1 FROM GEC_G1_DML_BROKER_MAP m_o WHERE m_o.G1_COUNTERPARTY_CD = temp.BROKER_CD AND m_o.NON_CASH_FLAG = 'N');

		
		-- Set the borrow request type / broker allocation priority by BROKER_CD
		-- Change for GEC-2101, populate branch_cd from gec_broker
		UPDATE GEC_BORROW_TEMP temp SET
			(temp.BORROW_REQUEST_TYPE, temp.ALLOCATION_ORDER, temp.AGENCY_FLAG, temp.BRANCH_CD) = (
																SELECT  broker.BORROW_REQUEST_TYPE , type.ALLOCATION_ORDER, broker.AGENCY_FLAG, broker.BRANCH_CD
																FROM GEC_BROKER_VW broker, GEC_BORROW_REQUEST_TYPE type
																WHERE broker.BORROW_REQUEST_TYPE = type.BORROW_REQUEST_TYPE
																	and broker.DML_BROKER_CD = temp.BROKER_CD
																	and broker.NON_CASH_AGENCY_FLAG = temp.NON_CASH_FLAG
																	and rownum = 1
															);
														
		
		-- validation for ASSET_ID, BORROW_ORDER_ID, BORROW_REQUEST_TYPE, ALLOCATION_ORDER
		p_valid_status := 'Y';
		FOR error IN error_borrows 
		LOOP 
			IF error.ASSET_ID IS NULL THEN
				UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0060',',VLD0060') WHERE BORROW_ID = error.BORROW_ID;
				p_valid_status := 'N';
			ELSIF error.BROKER_CD IS NULL OR error.BORROW_REQUEST_TYPE IS NULL OR error.ALLOCATION_ORDER IS NULL OR error.AGENCY_FLAG IS NULL OR error.BOOK_G1_BORROW_FLAG IS NULL THEN
				UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0061',',VLD0061') WHERE BORROW_ID = error.BORROW_ID;
				p_valid_status := 'N';
			ELSIF error.COLLATERAL_TYPE IS NULL OR error.COLLATERAL_CURRENCY_CD IS NULL THEN
				UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0063',',VLD0063') WHERE BORROW_ID = error.BORROW_ID;
				p_valid_status := 'N';
			ELSIF error.BORROW_QTY IS NULL THEN
				UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0065',',VLD0065') WHERE BORROW_ID = error.BORROW_ID;
				p_valid_status := 'N';
			ELSIF error.POSITION_FLAG IS NULL THEN
				UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0064',',VLD0064') WHERE BORROW_ID = error.BORROW_ID;
				p_valid_status := 'N';
			ELSIF error.BRANCH_CD IS NULL THEN
				UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0114',',VLD0114') WHERE BORROW_ID = error.BORROW_ID;
				p_valid_status := 'N';
			ELSIF error.TRADE_COUNTRY_CD IS NULL THEN
				UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0146',',VLD0146') WHERE BORROW_ID = error.BORROW_ID;
				p_valid_status := 'N';	
			ELSIF (error.PREPAY_RATE IS NOT NULL AND error.PREPAY_RATE<>0 AND error.COLLATERAL_TYPE <> 'CASH' AND error.COLLATERAL_TYPE <> 'POOL') OR (error.PREPAY_RATE IS NOT NULL AND error.PREPAY_RATE<>0 AND error.SETTLE_DATE = error.PREPAY_DATE AND (error.BORROW_REQUEST_TYPE='SB' OR (error.BORROW_REQUEST_TYPE<>'SB' AND (error.TRADE_COUNTRY_CD='US' OR error.TRADE_COUNTRY_CD='CA'))))	THEN
				UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0149',',VLD0149') WHERE BORROW_ID = error.BORROW_ID;
				p_valid_status := 'N';		
			ELSIF error.PRICE IS NULL THEN
				UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0150',',VLD0150') WHERE BORROW_ID = error.BORROW_ID;
				p_valid_status := 'N';														
			ELSIF error.RATE IS NULL THEN
				UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0151',',VLD0151') WHERE BORROW_ID = error.BORROW_ID;
				p_valid_status := 'N';		
			ELSIF error.RECLAIM_RATE IS NULL OR error.OVERSEAS_TAX_PERCENTAGE IS NULL OR error.DOMESTIC_TAX_PERCENTAGE IS NULL THEN
				UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0152',',VLD0152') WHERE BORROW_ID = error.BORROW_ID;
				p_valid_status := 'N';	
			ELSIF error.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND p_input_type = GEC_CONSTANTS_PKG.C_BORROW_SINGLE AND p_trans_type = GEC_CONSTANTS_PKG.C_SB_SHORT THEN
				UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0192',',VLD0192') WHERE BORROW_ID = error.BORROW_ID;
				p_valid_status := 'N';																														
			END IF;			
		END LOOP;
		
		var_cur_date := GEC_UTILS_PKG.DATE_TO_NUMBER(sysdate);
		
		-- validation for settle date, trade date, coporate bond qty
		FOR a_b IN asset_borrows
		LOOP
			IF a_b.SETTLE_DATE < var_cur_date THEN
				UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0074',',VLD0074') WHERE rowid = a_b.ROW_ID;
				p_valid_status := 'N';
			ELSIF a_b.SETTLE_DATE = var_cur_date THEN
				var_cur_datestr := GEC_UTILS_PKG.NUMBER_TO_CHAR(var_cur_date) || a_b.CUTOFF_TIME;
				var_date := GEC_UTILS_PKG.TO_BOS_TIME(var_cur_datestr, a_b.LOCALE);
				IF var_date < sysdate THEN
					UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0071',',VLD0071') WHERE rowid = a_b.ROW_ID;
					p_valid_status := 'N';
				END IF;
			END IF;
			
			IF GEC_UTILS_PKG.IS_WORKDAY(GEC_UTILS_PKG.NUMBER_TO_DATE(a_b.SETTLE_DATE),a_b.TRADE_COUNTRY_CD,'S') <> 'Y' THEN
				UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0072',',VLD0072') WHERE rowid = a_b.ROW_ID;
				p_valid_status := 'N';
			END IF;
			
			IF a_b.COLLATERAL_CURRENCY_CD IS NOT NULL THEN
				BEGIN
					SELECT TRADE_COUNTRY_CD INTO var_coll_trade_country FROM GEC_TRADE_COUNTRY WHERE CURRENCY_CD = a_b.COLLATERAL_CURRENCY_CD;
				EXCEPTION WHEN NO_DATA_FOUND THEN
					var_coll_trade_country := NULL;	
				END;
				
				IF var_coll_trade_country IS NULL THEN
					UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0158',',VLD0158') WHERE rowid = a_b.ROW_ID;
					p_valid_status := 'N';	
				ELSE
					IF GEC_UTILS_PKG.IS_WORKDAY(GEC_UTILS_PKG.NUMBER_TO_DATE(a_b.PREPAY_DATE),var_coll_trade_country,'S') <> 'Y' THEN
						UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0153',',VLD0153') WHERE rowid = a_b.ROW_ID;
						p_valid_status := 'N';
					END IF;							
				END IF;			
			END IF;
	
			
			IF a_b.SETTLE_DATE < a_b.TRADE_DATE THEN
				UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0082',',VLD0082') WHERE rowid = a_b.ROW_ID;
				p_valid_status := 'N';
			END IF;
	
			IF a_b.PREPAY_DATE > a_b.SETTLE_DATE OR a_b.PREPAY_DATE < a_b.TRADE_DATE THEN		
				UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0148',',VLD0148') WHERE rowid = a_b.ROW_ID;
				p_valid_status := 'N';			
			END IF;

			IF a_b.PREPAY_DATE < var_cur_date THEN
				UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0160',',VLD0160') WHERE rowid = a_b.ROW_ID;
				p_valid_status := 'N';	
			END IF;
			IF a_b.TERM_DATE IS NOT NULL AND a_b.TERM_DATE <a_b.SETTLE_DATE THEN
				UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0217',',VLD0217') WHERE rowid = a_b.ROW_ID;
				p_valid_status := 'N';	
			END IF;
			IF a_b.EXPECTED_RETURN_DATE IS NOT NULL THEN
				IF a_b.EXPECTED_RETURN_DATE <= a_b.SETTLE_DATE THEN
					UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0218',',VLD0218') WHERE rowid = a_b.ROW_ID;
					p_valid_status := 'N';	
				ELSE
					IF GEC_UTILS_PKG.IS_WORKDAY(GEC_UTILS_PKG.NUMBER_TO_DATE(a_b.EXPECTED_RETURN_DATE),'ALL','S') <> 'Y' THEN
						UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0220',',VLD0220') WHERE rowid = a_b.ROW_ID;
						p_valid_status := 'N';	
					END IF;
				END IF;
				
			END IF;
			-- for coporate bond borrows, qty need to multiply 1000
			IF p_input_type IS NOT NULL AND a_b.ASSET_TYPE_ID = 2 AND MOD(a_b.BORROW_QTY, 1000) <> 0 THEN 
				UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR, ERROR_CODE = ERROR_CODE || DECODE(ERROR_CODE,NULL,'VLD0156',',VLD0156') WHERE rowid = a_b.ROW_ID;
				p_valid_status := 'N';					
			END IF;
			
		END LOOP;
		
		-- set the unfilled qty
		UPDATE GEC_BORROW_TEMP SET UNFILLED_QTY = BORROW_QTY;

	END PREPARE_TEMP_BORROWS;

	
	-- p_valid_status 'Y'
	--                'N'
	--                'E'
	PROCEDURE PREPARE_TEMP_ORDERS(p_user_id IN VARCHAR2, p_type IN VARCHAR2, p_valid_status OUT VARCHAR2)
	IS
	
	var_sb_coll_code  GEC_FUND.COLLATERAL_CURRENCY_CD%type;
	var_nsb_coll_code GEC_FUND.COLLATERAL_CURRENCY_CD%type;	
	var_sb_coll_type  GEC_FUND.SB_COLLATERAL_TYPE%type;
	var_nsb_coll_type GEC_FUND.NSB_COLLATERAL_TYPE%type;
	
	var_branch_cd GEC_BROKER.BRANCH_CD%type;
	
	CURSOR fund_validate IS 
		SELECT f.FUND_CD, t.IM_ORDER_ID
		FROM GEC_IM_ORDER_TEMP t, GEC_FUND f
		WHERE t.FUND_CD = f.FUND_CD(+);
		
	-- for the existed shorts, need to lock for updating in following steps
	CURSOR existed_orders IS
		SELECT o.SHARE_QTY, o.FILLED_QTY, NVL(t.NSB_ALLOC_QTY, 0) as NSB_ALLOC_QTY, NVL(SB_ALLOC_QTY, 0) as SB_ALLOC_QTY
		FROM GEC_IM_ORDER_TEMP t, GEC_IM_ORDER o
		WHERE t.IM_ORDER_ID = o.IM_ORDER_ID AND
			t.IM_ORDER_ID IS NOT NULL
		ORDER BY o.IM_ORDER_ID ASC
		FOR UPDATE OF o.FILLED_QTY;
		
	CURSOR orders_prepared IS
		SELECT t.IM_ORDER_ID, t.TRADE_COUNTRY_CD, t.FUND_CD
		FROM GEC_IM_ORDER_TEMP t;
				
	BEGIN
		p_valid_status := 'Y';
		
		IF p_type = 'M' THEN
			FOR e_o IN existed_orders
			LOOP
				IF (e_o.SHARE_QTY - e_o.FILLED_QTY) < e_o.NSB_ALLOC_QTY + e_o.SB_ALLOC_QTY THEN
					p_valid_status := 'E';
				END IF;
				EXIT WHEN p_valid_status = 'E';
			END LOOP;
		END IF;
		
		IF p_valid_status = 'E' THEN
			RETURN;
		END IF;
		
		
		-- set holdback flag,export_status for the existed orders
		UPDATE GEC_IM_ORDER_TEMP t SET (t.HOLDBACK_FLAG, t.EXPORT_STATUS) = (SELECT o.HOLDBACK_FLAG, o.EXPORT_STATUS FROM GEC_IM_ORDER o WHERE t.IM_ORDER_ID = o.IM_ORDER_ID AND rownum =1)
		WHERE EXISTS(SELECT 1 FROM GEC_IM_ORDER in_o WHERE t.IM_ORDER_ID = in_o.IM_ORDER_ID);

		-- set short id for the new orders, such as new shorts for manual intervention or for no demand borrows
		UPDATE GEC_IM_ORDER_TEMP SET IM_ORDER_ID = GEC_IM_ORDER_ID_SEQ.nextval, STATUS = 'N'  -- new
		WHERE IM_ORDER_ID IS NULL;
		
		-- validate the input fund
		FOR f_v IN fund_validate
		LOOP
			IF f_v.FUND_CD IS NULL THEN
				UPDATE GEC_IM_ORDER_TEMP SET ERROR_CODE = ERROR_CODE || ',VLD0076' WHERE IM_ORDER_ID = f_v.IM_ORDER_ID;
				p_valid_status := 'N';
			END IF;
		END LOOP;
		
		IF p_valid_status = 'N' THEN
			RETURN;
		END IF;
		
		-- prepare gec_im_order_temp
		UPDATE GEC_IM_ORDER_TEMP t SET (t.SB_BROKER_CD, t.NSB_BROKER_CD, t.BRANCH_CD, t.TRADE_COUNTRY_CD)=(
											SELECT f.DML_SB_BROKER, f.DML_NSB_BROKER, f.BRANCH_CD, a.TRADE_COUNTRY_CD
											FROM GEC_FUND f, GEC_ASSET a
											WHERE t.FUND_CD = f.FUND_CD AND
												  t.ASSET_ID = a.ASSET_ID AND
													rownum = 1
											);
		BEGIN
			SELECT t.BRANCH_CD INTO var_branch_cd FROM GEC_IM_ORDER_TEMP t WHERE STATUS <> 'N' AND rownum = 1 AND p_type = 'M';	
		EXCEPTION WHEN NO_DATA_FOUND THEN
			var_branch_cd := NULL;
		END;	
		
		-- prepare coll info 
		FOR o_p IN orders_prepared
		LOOP 	
			GET_COLL_CODE_TYPE_INFO(o_p.TRADE_COUNTRY_CD, o_p.FUND_CD, var_sb_coll_type, var_nsb_coll_type, var_sb_coll_code, var_nsb_coll_code);
			UPDATE GEC_IM_ORDER_TEMP t SET t.SB_COLLATERAL_CURRENCY_CD = var_sb_coll_code, NSB_COLLATERAL_CURRENCY_CD = var_nsb_coll_code,
										   t.SB_COLLATERAL_TYPE = var_sb_coll_type, t.NSB_COLLATERAL_TYPE = var_nsb_coll_type
									   WHERE t.IM_ORDER_ID = o_p.IM_ORDER_ID;		
		END LOOP;
		
		UPDATE GEC_IM_ORDER_TEMP t SET t.PREPAY_DATE = NULL WHERE t.PREPAY_DATE = 0;
				
		-- insert dummy short to gec_im_order table 
		INSERT INTO GEC_IM_ORDER(
			IM_ORDER_ID,
  			FUND_CD,
  			ASSET_ID,
  			SHARE_QTY,
  			FILLED_QTY,
  			SETTLE_DATE,
  			TRADE_DATE,
  			STATUS,
  			TRANSACTION_CD,
  			SOURCE_CD,
  			TRADE_COUNTRY_CD,
  			ASSET_TYPE_ID,
  			BRANCH_CD,
	  		CREATED_BY,
	  		CREATED_AT,
	  		UPDATED_BY,
	  		UPDATED_AT 			
		)SELECT 
			t.IM_ORDER_ID,
  			t.FUND_CD,
  			t.ASSET_ID,
  			t.SHARE_QTY,
  			0 AS FILLED_QTY,
  			t.SETTLE_DATE,
  			t.TRADE_DATE,
  			'P' AS STATUS,
  			'SHORT' AS TRANSACTION_CD, 
  			CASE WHEN p_type = 'N' THEN GEC_CONSTANTS_PKG.C_SOURCE_CD_NO_DEMAND ELSE GEC_CONSTANTS_PKG.C_SOURCE_CD_MORE_DEMAND END AS SOURCE_CD,
  			a.TRADE_COUNTRY_CD,	-- for allocation, only support 'US'	
			a.ASSET_TYPE_ID,
			CASE WHEN p_type = 'M' THEN var_branch_cd ELSE t.BRANCH_CD END,
	  		p_user_id,
	  		sysdate,
	  		p_user_id,
	  		sysdate	 			
		FROM GEC_IM_ORDER_TEMP t, GEC_ASSET a
		WHERE a.ASSET_ID = t.ASSET_ID AND
				t.STATUS = 'N';
										
	END PREPARE_TEMP_ORDERS;
	-- p_valid_status 'Y'
	--	              'N'
	--                'E'
	PROCEDURE MERGE_BORROWS(p_user_id IN VARCHAR2, p_input_type IN VARCHAR2,p_trans_type IN VARCHAR2, p_valid_status OUT VARCHAR2)
	IS
		-- for the existed borrows, lock the borrows for updating in following steps
		CURSOR update_borrows IS
			SELECT t.BORROW_ID,
  				   t.BORROW_ORDER_ID,
  				   t.ASSET_ID,
  				   t.BROKER_CD,
  				   t.TRADE_DATE,
  				   t.SETTLE_DATE,
  				   t.COLLATERAL_TYPE,
  				   t.COLLATERAL_CURRENCY_CD,
  				   t.COLLATERAL_LEVEL,
  				   t.BORROW_QTY,
  				   t.RATE,
  				   t.PRICE,
  				   t.POSITION_FLAG,
  				   t.COMMENT_TXT,
  				   t.PREPAY_DATE,
  				   t.PREPAY_RATE,
  				   t.RECLAIM_RATE,
  				   t.OVERSEAS_TAX_PERCENTAGE,
  				   t.DOMESTIC_TAX_PERCENTAGE,
  				   t.MINIMUM_FEE,
  				   t.MINIMUM_FEE_CD,
  				   t.BOOK_G1_BORROW_FLAG,
  				   t.G1_EXTRACTED_AT,
  				   t.NO_DEMAND_FLAG,
  				   t.TYPE,
  				   t.INTERVENTION_REASON,
  				   t.STATUS,
  				   b.STATUS AS EXIST_STATUS,
  				   b.TYPE AS EXIST_TYPE,
  				   t.OPERATION,
  				   b.LOAN_NO,
  				   t.BORROW_REQUEST_TYPE,
  				   t.NON_CASH_FLAG,
  				   t.TERM_DATE,
  				   t.EXPECTED_RETURN_DATE,
  				   t.TERM_TYPE
			FROM GEC_BORROW_TEMP t, GEC_BORROW b 
			WHERE t.BORROW_ID = b.BORROW_ID AND 
					t.OPERATION IN (GEC_CONSTANTS_PKG.C_BORROW_UPDATE, GEC_CONSTANTS_PKG.C_BORROW_DELETE)
			ORDER BY b.BORROW_ID ASC
			FOR UPDATE OF b.STATUS;
			
		CURSOR not_exist_deletes IS
			SELECT t.BORROW_ID FROM GEC_BORROW_TEMP t
			WHERE t.OPERATION = GEC_CONSTANTS_PKG.C_BORROW_DELETE;
	BEGIN
		p_valid_status := 'Y';
		
		IF p_input_type <> GEC_CONSTANTS_PKG.C_BORROW_FILE THEN
			-- update/delete the existed borrows
			FOR u_b IN update_borrows
			LOOP
				IF p_input_type <> GEC_CONSTANTS_PKG.C_BORROW_SINGLE OR (u_b.EXIST_STATUS IS NOT NULL AND u_b.EXIST_STATUS <> GEC_CONSTANTS_PKG.C_BORROW_MANUAL) THEN  --OR u_b.EXIST_STATUS IS NULL OR u_b.EXIST_STATUS <> 'M' 
					UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR WHERE BORROW_ID = u_b.BORROW_ID;
					p_valid_status := 'N';
				ELSIF u_b.EXIST_STATUS <> GEC_CONSTANTS_PKG.C_BORROW_MANUAL THEN
					-- try to update/delete the borrow which are not in 'M' status, go to error
					UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR WHERE BORROW_ID = u_b.BORROW_ID;
					p_valid_status := 'E';
				ELSE
					IF p_trans_type=GEC_CONSTANTS_PKG.C_FLIP_TRADE THEN
						DELETE FROM GEC_FLIP_BORROW WHERE BORROW_ID = u_b.BORROW_ID;
					ELSE
						DELETE FROM GEC_ALLOCATION WHERE BORROW_ID = u_b.BORROW_ID;
					END IF;
					
					IF u_b.OPERATION = GEC_CONSTANTS_PKG.C_BORROW_UPDATE THEN
						UPDATE GEC_BORROW SET
							BORROW_ORDER_ID = u_b.BORROW_ORDER_ID,
	  						ASSET_ID = u_b.ASSET_ID,
	  						BROKER_CD = NVL((SELECT m.BROKER_CD FROM GEC_BROKER_VW m WHERE m.DML_BROKER_CD= u_b.BROKER_CD AND m.NON_CASH_AGENCY_FLAG = u_b.NON_CASH_FLAG AND rownum=1),u_b.BROKER_CD),
	  						TRADE_DATE = u_b.TRADE_DATE,
	  						SETTLE_DATE = u_b.SETTLE_DATE,
	  						COLLATERAL_TYPE = u_b.COLLATERAL_TYPE,
	  						COLLATERAL_CURRENCY_CD = u_b.COLLATERAL_CURRENCY_CD,
	  						COLLATERAL_LEVEL = u_b.COLLATERAL_LEVEL,
	  						BORROW_QTY = u_b.BORROW_QTY,
	  						RATE = u_b.RATE,
	  						PRICE = u_b.PRICE,
	  						POSITION_FLAG = u_b.POSITION_FLAG,
	  						COMMENT_TXT = u_b.COMMENT_TXT,
	  						PREPAY_DATE = u_b.PREPAY_DATE,
	  						PREPAY_RATE = u_b.PREPAY_RATE,
	  						RECLAIM_RATE = u_b.RECLAIM_RATE,
	  						OVERSEAS_TAX_PERCENTAGE = u_b.OVERSEAS_TAX_PERCENTAGE,
	  						DOMESTIC_TAX_PERCENTAGE = u_b.DOMESTIC_TAX_PERCENTAGE,
	  						MINIMUM_FEE = u_b.MINIMUM_FEE,
	  						MINIMUM_FEE_CD = u_b.MINIMUM_FEE_CD,
	  						BOOK_G1_BORROW_FLAG = u_b.BOOK_G1_BORROW_FLAG,
	  						G1_EXTRACTED_AT = u_b.G1_EXTRACTED_AT,
	  						NO_DEMAND_FLAG = 'N',
	  						LOAN_NO = u_b.LOAN_NO,
	  						TYPE = u_b.TYPE,
	  						INTERVENTION_REASON = u_b.INTERVENTION_REASON,
	  						STATUS = GEC_CONSTANTS_PKG.C_BORROW_PROCESSED,
	  						UPDATED_BY = p_user_id,
	  						UPDATED_AT = sysdate,
	  						TERM_DATE = u_b.TERM_DATE,
	  						EXPECTED_RETURN_DATE = u_b.EXPECTED_RETURN_DATE,
	  						TERM_TYPE = u_b.TERM_TYPE,
	  						LINK_REFERENCE = GEC_ALLOCATION_PKG.GENERATE_BORROW_LINK_REF()
	  					WHERE BORROW_ID = u_b.BORROW_ID;
	  				ELSE -- for delete
	  					DELETE FROM GEC_BORROW_TEMP WHERE BORROW_ID = u_b.BORROW_ID;
	  					DELETE FROM GEC_BORROW WHERE BORROW_ID = u_b.BORROW_ID;
	  				END IF;
	  				
				END IF;
			END LOOP;
			
			-- try to delete the not existed borrows(have been deleted by other user), go to error
			FOR n_d IN not_exist_deletes
			LOOP
				UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR WHERE BORROW_ID = n_d.BORROW_ID;
				p_valid_status := 'E';
			END LOOP;
			
			IF p_valid_status <> 'Y' THEN
				RETURN;
			END IF;
			
			-- insert new borrows to GEC_BORROW
			INSERT INTO GEC_BORROW(  BORROW_ID,
	  								 BORROW_ORDER_ID,
	  								 ASSET_ID,
	  								 BROKER_CD,
	  								 TRADE_DATE,
	  								 SETTLE_DATE,
	  								 COLLATERAL_TYPE,
	  								 COLLATERAL_CURRENCY_CD,
	  								 COLLATERAL_LEVEL,
	  								 BORROW_QTY,
	  								 RATE,
	  								 PRICE,
	  								 AMOUNT,
	  								 POSITION_FLAG,
	  								 COMMENT_TXT,
				   				     PREPAY_DATE,
  								     PREPAY_RATE,
  								     RECLAIM_RATE,
  				   					 OVERSEAS_TAX_PERCENTAGE,
  				   					 DOMESTIC_TAX_PERCENTAGE,
  				   					 MINIMUM_FEE,
  				   					 MINIMUM_FEE_CD,
  				   					 BOOK_G1_BORROW_FLAG,	  								 
	  								 G1_EXTRACTED_AT,
	  								 NO_DEMAND_FLAG,
	  								 LOAN_NO,
	  								 TYPE,
	  								 INTERVENTION_REASON,
	  								 STATUS,
	  								 CREATED_BY,
	  								 CREATED_AT,
	  								 UPDATED_BY,
	  								 UPDATED_AT,	  								 
	  								 LINK_REFERENCE,
	  								 TERM_DATE,
	  								 EXPECTED_RETURN_DATE,
	  								 TERM_TYPE)
	  		SELECT t.BORROW_ID,
	  		       t.BORROW_ORDER_ID,
	  			   t.ASSET_ID,
	  			   NVL(m.BROKER_CD, t.BROKER_CD),
	  			   t.TRADE_DATE,
	  			   t.SETTLE_DATE,
	  			   t.COLLATERAL_TYPE,
	  			   t.COLLATERAL_CURRENCY_CD,
	  			   t.COLLATERAL_LEVEL,
	  			   t.BORROW_QTY,
	  			   t.RATE,
	  			   t.PRICE,
	  			   t.AMOUNT,
	  			   t.POSITION_FLAG,
	  			   t.COMMENT_TXT,
  				   t.PREPAY_DATE,
  				   t.PREPAY_RATE,
  				   t.RECLAIM_RATE,
  				   t.OVERSEAS_TAX_PERCENTAGE,
  				   t.DOMESTIC_TAX_PERCENTAGE,
  				   t.MINIMUM_FEE,
  				   t.MINIMUM_FEE_CD,
  				   t.BOOK_G1_BORROW_FLAG,	  			   
	  			   t.G1_EXTRACTED_AT,
	  			   'N',
	  			   t.LOAN_NO,
	  			   t.TYPE,
	  			   t.INTERVENTION_REASON,
	  			   GEC_CONSTANTS_PKG.C_BORROW_PROCESSED,
	  			   p_user_id,
	  			   sysdate,
	  			   p_user_id,
	  			   sysdate,	  			   
	  			   (GEC_ALLOCATION_PKG.GENERATE_BORROW_LINK_REF()),
	  			   t.TERM_DATE,
	  			   t.EXPECTED_RETURN_DATE,
	  			   t.TERM_TYPE
	  		FROM GEC_BORROW_TEMP t, GEC_BROKER_VW m
			WHERE NOT EXISTS (SELECT 1 FROM GEC_BORROW b WHERE b.BORROW_ID = t.BORROW_ID)
					AND t.BROKER_CD = m.DML_BROKER_CD AND
					t.NON_CASH_FLAG = m.NON_CASH_AGENCY_FLAG;
		ELSE 
			-- for file input, it only include new borrows
			INSERT INTO GEC_BORROW(  BORROW_ID,
	  								 BORROW_ORDER_ID,
	  								 ASSET_ID,
	  								 BROKER_CD,
	  								 TRADE_DATE,
	  								 SETTLE_DATE,
	  								 COLLATERAL_TYPE,
	  								 COLLATERAL_CURRENCY_CD,
	  								 COLLATERAL_LEVEL,
	  								 BORROW_QTY,
	  								 RATE,
	  								 PRICE,
	  								 AMOUNT,
	  								 POSITION_FLAG,
	  								 COMMENT_TXT,
				   				     PREPAY_DATE,
  								     PREPAY_RATE,
  								     RECLAIM_RATE,
  				   					 OVERSEAS_TAX_PERCENTAGE,
  				   					 DOMESTIC_TAX_PERCENTAGE,
  				   					 MINIMUM_FEE,
  				   					 MINIMUM_FEE_CD,  				   					 
  				   					 BOOK_G1_BORROW_FLAG,	  		  								 
	  								 G1_EXTRACTED_AT,
	  								 NO_DEMAND_FLAG,
	  								 LOAN_NO,
	  								 TYPE,
	  								 INTERVENTION_REASON,
	  								 STATUS,
	  								 EQUILEND_MESSAGE_ID,
	  								 CREATED_BY,
	  								 CREATED_AT,
	  								 UPDATED_BY,
	  								 UPDATED_AT,		  								 
	  								 LINK_REFERENCE,
	  								 TERM_DATE,
	  								 EXPECTED_RETURN_DATE,
	  								 TERM_TYPE)
	  		SELECT t.BORROW_ID,
	  		       t.BORROW_ORDER_ID,
	  			   t.ASSET_ID,
	  			   NVL(m.BROKER_CD, t.BROKER_CD),
	  			   t.TRADE_DATE,
	  			   t.SETTLE_DATE,
	  			   t.COLLATERAL_TYPE,
	  			   t.COLLATERAL_CURRENCY_CD,
	  			   t.COLLATERAL_LEVEL,
	  			   t.BORROW_QTY,
	  			   t.RATE,
	  			   t.PRICE,
	  			   t.AMOUNT,
	  			   t.POSITION_FLAG,
	  			   t.COMMENT_TXT,
  				   t.PREPAY_DATE,
  				   t.PREPAY_RATE,
  				   t.RECLAIM_RATE,
  				   t.OVERSEAS_TAX_PERCENTAGE,
  				   t.DOMESTIC_TAX_PERCENTAGE,
  				   t.MINIMUM_FEE,
  				   t.MINIMUM_FEE_CD,  				   
  				   t.BOOK_G1_BORROW_FLAG,	  			   
	  			   t.G1_EXTRACTED_AT,
	  			   'N',
	  			   t.LOAN_NO,
	  			   t.TYPE,
	  			   t.INTERVENTION_REASON,
	  			   GEC_CONSTANTS_PKG.C_BORROW_PROCESSED,
	  			   t.EQUILEND_MESSAGE_ID,
	  			   p_user_id,
	  			   sysdate,
	  			   p_user_id,
	  			   sysdate,		  			   
	  			   (GEC_ALLOCATION_PKG.GENERATE_BORROW_LINK_REF()),
	  			   t.TERM_DATE,
	  			   t.EXPECTED_RETURN_DATE,
	  			   t.TERM_TYPE
	  		FROM GEC_BORROW_TEMP t, GEC_BROKER_VW m
	  		WHERE t.BROKER_CD = m.DML_BROKER_CD AND
	  			t.NON_CASH_FLAG = m.NON_CASH_AGENCY_FLAG;
		END IF;
	END MERGE_BORROWS;
	
	-- p_status 'S' - success
	--          'VE' - validation error
	--          'UE' - try to update/delete the borrow which are not fullfilled following condition - Single input / MANUAL INPUT	
	--          'SE' - BR6 error
	--          'NE' - there are no demand borrows
	--          'ME' - for SB response file, if there are Manual Intervention
	--          'OE' - try to update/delete not existed borrows or borrows not in 'Manual' status
	--          'FE' - cannot get default fee for allocation, need to check fund configuration
	PROCEDURE PROCESS_AUTO_ALLOCATION(
										p_user_id IN VARCHAR2,
										p_demand_request_id NUMBER,
										p_input_type IN VARCHAR2,
										p_settle_date IN NUMBER,
										p_asset_id IN NUMBER,
										p_nsb_coll_type IN VARCHAR2,
										p_nsb_coll_code IN VARCHAR2,
										p_branch_code IN VARCHAR2,
										p_borrow_file_type IN VARCHAR2,
										p_trans_type IN VARCHAR2,
										p_need_allocation IN VARCHAR2,
										p_status OUT VARCHAR2,
										p_shorts_cursor OUT SYS_REFCURSOR,
										p_borrows_cursor OUT SYS_REFCURSOR,
										p_error_code OUT VARCHAR2,
										p_error_hint OUT VARCHAR2
										)
	IS
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_ALLOCATION_PKG.PROCESS_AUTO_ALLOCATION';
		var_end_settle_date GEC_BORROW.SETTLE_DATE%type;
		var_run_flag VARCHAR2(1); 
		var_error VARCHAR2(1);
		var_valid VARCHAR2(1);
		var_across VARCHAR2(1);
		var_loop_count NUMBER(10);
		var_count NUMBER(10);
		var_m_b_found VARCHAR2(1);
		
		var_borrow_id GEC_BORROW.BORROW_ID%type;
		var_coll_type GEC_BORROW.COLLATERAL_TYPE%type;
		var_coll_code GEC_BORROW.COLLATERAL_CURRENCY_CD%type;
		var_trade_country GEC_TRADE_COUNTRY.TRADE_COUNTRY_CD%type;
		
		var_rate_map FUND_RATE_MAP;
		var_ex_loan_info_map NONUS_EX_LOAN_INFO_MAP;
		
		var_error_code VARCHAR2(10);
		var_error_hint VARCHAR2(30);
		var_manual VARCHAR2(3) :='NO';
		var_auto VARCHAR2(3) :='NO';
		var_branch_cd GEC_BROKER.BRANCH_CD%type;

		-- BOS branch borrow have higher priority than 'TOR' branch	borrow	
		CURSOR v_f_run_units IS
			SELECT DISTINCT ASSET_ID, SETTLE_DATE, BORROW_REQUEST_TYPE, BORROW_ORDER_ID, ALLOCATION_ORDER, AGENCY_FLAG, BRANCH_CD, PREPAY_DATE, TRADE_COUNTRY_CD, RECLAIM_RATE
			FROM GEC_BORROW_TEMP
			ORDER BY ASSET_ID asc, SETTLE_DATE asc, ALLOCATION_ORDER asc, PREPAY_DATE desc, RECLAIM_RATE asc, BORROW_ORDER_ID asc;
		-- BOS branch borrow have higher priority than 'TOR' branch	borrow		
		CURSOR v_nf_run_units IS
			SELECT DISTINCT ASSET_ID, SETTLE_DATE, BORROW_REQUEST_TYPE, ALLOCATION_ORDER, AGENCY_FLAG, BRANCH_CD, PREPAY_DATE, TRADE_COUNTRY_CD, RECLAIM_RATE
			FROM GEC_BORROW_TEMP
			ORDER BY ASSET_ID asc, SETTLE_DATE asc, ALLOCATION_ORDER asc, PREPAY_DATE desc, RECLAIM_RATE asc;
	
		
		-- per Question 41, identify whether it is no demand borrows
		CURSOR v_no_demands IS
			SELECT BORROW_ID, BORROW_REQUEST_TYPE, AGENCY_FLAG, BRANCH_CD, TRADE_COUNTRY_CD FROM GEC_BORROW_TEMP 
			WHERE BORROW_QTY = UNFILLED_QTY AND BORROW_QTY > 0;
		-- match asset id / broker code / coll type / coll code / settle date	
		--zwh CURSOR v_sb_no_demand IS
		--	SELECT out_b.BORROW_ID, curr_allo.IM_ORDER_ID
		--	FROM (SELECT lc.DML_SB_BROKER as BROKER_CD, lc.SB_COLLATERAL_TYPE as COLLATERAL_TYPE, NVL(lcc.COLLATERAL_CURRENCY_CD, lc.COLLATERAL_CURRENCY_CD) as COLLATERAL_CURRENCY_CD, in_b.ASSET_ID, o.SETTLE_DATE as S_SETTLE_DATE, a.IM_ORDER_ID, o.HOLDBACK_FLAG, lc.BRANCH_CD, in_b.BORROW_ORDER_ID
		--			FROM GEC_BORROW_TEMP in_b, 
		--				 GEC_ALLOCATION a, 
		--				 GEC_IM_ORDER o, 
        --      			(SELECT f.FUND_CD, f.DML_SB_BROKER, f.BRANCH_CD, f.SB_COLLATERAL_TYPE, g1.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1
		--                 WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'SB' AND g1.TRANSACTION_CD = 'G1L') lc LEFT JOIN 
        --      			(SELECT f.FUND_CD, gc.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1, GEC_G1_COLLATERAL gc
		--                 WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'SB' AND g1.TRANSACTION_CD = 'G1L' AND g1.G1_BOOKING_ID = gc.G1_BOOKING_ID AND gc.TRADE_COUNTRY_CD = var_trade_country) lcc ON lc.FUND_CD = lcc.FUND_CD				                 
		--			WHERE a.BORROW_ID = in_b.BORROW_ID AND
		--				a.IM_ORDER_ID = o.IM_ORDER_ID AND
		--				o.FUND_CD = lc.FUND_CD)curr_allo,
		--		GEC_BORROW_TEMP out_b
		--	WHERE out_b.BROKER_CD = curr_allo.BROKER_CD AND
		--		  out_b.COLLATERAL_CURRENCY_CD = curr_allo.COLLATERAL_CURRENCY_CD AND
		--		  out_b.ASSET_ID = curr_allo.ASSET_ID AND
		--		  out_b.SETTLE_DATE = curr_allo.S_SETTLE_DATE AND
		--		  out_b.BRANCH_CD IN ('BOS',GEC_CONSTANTS_PKG.C_BRANCH_GMBH) AND
		--		  out_b.BORROW_ID = var_borrow_id AND
		--		  curr_allo.HOLDBACK_FLAG IN ('N', 'C') AND
		--		  (p_input_type=GEC_CONSTANTS_PKG.C_BORROW_FILE AND out_b.BORROW_ORDER_ID = curr_allo.BORROW_ORDER_ID OR p_input_type <> GEC_CONSTANTS_PKG.C_BORROW_FILE) AND 
		--		  (out_b.NON_CASH_FLAG='Y' AND curr_allo.COLLATERAL_TYPE='CASH' OR out_b.NON_CASH_FLAG='N' AND curr_allo.HOLDBACK_FLAG<>'C') AND
		--		  rownum = 1;
				  
		-- match asset id / broker code / coll type / coll code / settle date	
		CURSOR v_sb_no_demand_tor IS
			SELECT out_b.BORROW_ID, curr_allo.IM_ORDER_ID
			FROM (SELECT lc.DML_SB_BROKER as BROKER_CD, lc.SB_COLLATERAL_TYPE as COLLATERAL_TYPE, NVL(lcc.COLLATERAL_CURRENCY_CD, lc.COLLATERAL_CURRENCY_CD) as COLLATERAL_CURRENCY_CD, in_b.ASSET_ID, o.SETTLE_DATE as S_SETTLE_DATE, a.IM_ORDER_ID, o.HOLDBACK_FLAG, lc.BRANCH_CD, in_b.BORROW_ORDER_ID
					FROM GEC_BORROW_TEMP in_b, 
						 GEC_ALLOCATION a, 
						 GEC_IM_ORDER o, 
              			(SELECT f.FUND_CD, f.DML_SB_BROKER, f.BRANCH_CD, f.SB_COLLATERAL_TYPE, g1.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1
		                 WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'SB' AND g1.TRANSACTION_CD = 'G1L') lc LEFT JOIN 
              			(SELECT f.FUND_CD, gc.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1, GEC_G1_COLLATERAL gc
		                 WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'SB' AND g1.TRANSACTION_CD = 'G1L' AND g1.G1_BOOKING_ID = gc.G1_BOOKING_ID AND gc.TRADE_COUNTRY_CD = var_trade_country) lcc ON lc.FUND_CD = lcc.FUND_CD		                 
					WHERE a.BORROW_ID = in_b.BORROW_ID AND
						a.IM_ORDER_ID = o.IM_ORDER_ID AND
						o.FUND_CD = lc.FUND_CD)curr_allo,
				GEC_BORROW_TEMP out_b
			WHERE out_b.BROKER_CD = curr_allo.BROKER_CD AND
				  out_b.COLLATERAL_CURRENCY_CD = curr_allo.COLLATERAL_CURRENCY_CD AND
				  out_b.ASSET_ID = curr_allo.ASSET_ID AND
				  out_b.SETTLE_DATE <= curr_allo.S_SETTLE_DATE AND
				  curr_allo.BRANCH_CD IN (SELECT ALLOCATE_DEMAND_BRANCH FROM GEC_ALLOCATION_RULE WHERE ALLOCATE_BORROW_BRANCH= var_branch_cd) AND
				  out_b.BORROW_ID = var_borrow_id AND
				  curr_allo.HOLDBACK_FLAG IN ('N', 'C') AND
				  (p_input_type=GEC_CONSTANTS_PKG.C_BORROW_FILE AND out_b.BORROW_ORDER_ID = curr_allo.BORROW_ORDER_ID OR p_input_type <> GEC_CONSTANTS_PKG.C_BORROW_FILE) AND 
				  (out_b.NON_CASH_FLAG='Y' AND curr_allo.COLLATERAL_TYPE='CASH' OR out_b.NON_CASH_FLAG='N' AND curr_allo.HOLDBACK_FLAG<>'C') AND
				  rownum = 1;				  
				  
		--CURSOR v_sb_holdback IS
		--	SELECT t.BORROW_ID, o.HOLDBACK_FLAG
		--	FROM GEC_BORROW_TEMP t, 
		--		 GEC_IM_ORDER o, 
		--		 (SELECT f.FUND_CD, f.DML_SB_BROKER, f.BRANCH_CD, g1.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1
		--		  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'SB' AND g1.TRANSACTION_CD = 'G1L') lc LEFT JOIN 
		--		 (SELECT f.FUND_CD, gc.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1, GEC_G1_COLLATERAL gc
		--		  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'SB' AND g1.TRANSACTION_CD = 'G1L' AND g1.G1_BOOKING_ID = gc.G1_BOOKING_ID AND gc.TRADE_COUNTRY_CD = var_trade_country) lcc ON lc.FUND_CD = lcc.FUND_CD		  
		--	WHERE t.ASSET_ID = o.ASSET_ID AND
		--			o.FUND_CD = lc.FUND_CD AND
		--			t.BROKER_CD = lc.DML_SB_BROKER AND
		--			t.COLLATERAL_CURRENCY_CD = NVL(lcc.COLLATERAL_CURRENCY_CD, lc.COLLATERAL_CURRENCY_CD) AND
		--			lc.BRANCH_CD IN ('BOS',GEC_CONSTANTS_PKG.C_BRANCH_GMBH) AND
		--			t.SETTLE_DATE = o.SETTLE_DATE AND
		--			o.HOLDBACK_FLAG IN ('Y', 'C') AND
		--			o.SHARE_QTY > o.FILLED_QTY AND
		--			t.BORROW_ID = var_borrow_id AND
		--			rownum = 1;
					
		CURSOR v_sb_holdback_tor IS
			SELECT t.BORROW_ID, o.HOLDBACK_FLAG
			FROM GEC_BORROW_TEMP t,
				 GEC_IM_ORDER o, 
				 (SELECT f.FUND_CD, f.DML_SB_BROKER, f.BRANCH_CD, g1.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1
				  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'SB' AND g1.TRANSACTION_CD = 'G1L') lc LEFT JOIN
				 (SELECT f.FUND_CD, gc.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1, GEC_G1_COLLATERAL gc
				  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'SB' AND g1.TRANSACTION_CD = 'G1L' and g1.G1_BOOKING_ID = gc.G1_BOOKING_ID and gc.TRADE_COUNTRY_CD = var_trade_country) lcc ON lc.FUND_CD = lcc.FUND_CD	
			WHERE t.ASSET_ID = o.ASSET_ID AND
					o.FUND_CD = lc.FUND_CD AND				
					t.BROKER_CD = lc.DML_SB_BROKER AND
					t.COLLATERAL_CURRENCY_CD = NVL(lcc.COLLATERAL_CURRENCY_CD, lc.COLLATERAL_CURRENCY_CD) AND
					lc.BRANCH_CD IN (SELECT ALLOCATE_DEMAND_BRANCH FROM GEC_ALLOCATION_RULE WHERE ALLOCATE_BORROW_BRANCH= var_branch_cd) AND
					t.SETTLE_DATE = o.SETTLE_DATE AND
					o.HOLDBACK_FLAG IN ('Y', 'C') AND
					o.SHARE_QTY > o.FILLED_QTY AND
					t.BORROW_ID = var_borrow_id AND
					rownum = 1;					
					
		-- for single input, only need to allocated to the shorts in current aggregated demand(asset id, nsb coll type, nsb coll code, branch code)
		--CURSOR v_sb_holdback_s IS
		--	SELECT t.BORROW_ID, o.HOLDBACK_FLAG
		--	FROM GEC_BORROW_TEMP t, 
		--		 GEC_IM_ORDER o, 
		--		 (SELECT f.FUND_CD, f.DML_SB_BROKER, f.BRANCH_CD, g1.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1
		--		  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'SB' AND g1.TRANSACTION_CD = 'G1L' ) lc LEFT JOIN 
		--		 (SELECT f.FUND_CD, gc.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1, GEC_G1_COLLATERAL gc
		--		  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'SB' AND g1.TRANSACTION_CD = 'G1L' and g1.G1_BOOKING_ID = gc.G1_BOOKING_ID and gc.TRADE_COUNTRY_CD = var_trade_country) lcc ON lc.FUND_CD = lcc.FUND_CD	
		--	WHERE t.ASSET_ID = o.ASSET_ID AND
		--			o.FUND_CD = lc.FUND_CD AND				
		--			t.BROKER_CD = lc.DML_SB_BROKER AND
		--			NVL(lcc.COLLATERAL_CURRENCY_CD, lc.COLLATERAL_CURRENCY_CD) = t.COLLATERAL_CURRENCY_CD AND
		--			lc.BRANCH_CD IN ('BOS',GEC_CONSTANTS_PKG.C_BRANCH_GMBH) AND
		--			t.SETTLE_DATE = o.SETTLE_DATE AND
		--			o.TRANSACTION_CD = p_trans_type AND					
		--			lc.BRANCH_CD = p_branch_code AND
		--			o.HOLDBACK_FLAG IN ('Y', 'C') AND
		--			o.SHARE_QTY > o.FILLED_QTY AND
		--			t.BORROW_ID = var_borrow_id AND
		--			rownum = 1;
					
		CURSOR v_sb_holdback_s_tor IS
			SELECT t.BORROW_ID, o.HOLDBACK_FLAG
			FROM GEC_BORROW_TEMP t, 
				 GEC_IM_ORDER o, 
				 (SELECT f.FUND_CD, f.DML_SB_BROKER, f.BRANCH_CD, g1.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1
				  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'SB' AND g1.TRANSACTION_CD = 'G1L') lc LEFT JOIN
				 (SELECT f.FUND_CD, gc.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1, GEC_G1_COLLATERAL gc
				  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'SB' AND g1.TRANSACTION_CD = 'G1L' and g1.G1_BOOKING_ID = gc.G1_BOOKING_ID and gc.TRADE_COUNTRY_CD = var_trade_country) lcc ON lc.FUND_CD = lcc.FUND_CD	
			WHERE t.ASSET_ID = o.ASSET_ID AND
					o.FUND_CD = lc.FUND_CD AND						
					t.BROKER_CD = lc.DML_SB_BROKER AND
					NVL(lcc.COLLATERAL_CURRENCY_CD, lc.COLLATERAL_CURRENCY_CD) = t.COLLATERAL_CURRENCY_CD AND
				  -- branch 'TOR' borrow can allocated to branch 'TOR' and 'BOS' shorts					
					lc.BRANCH_CD IN (SELECT ALLOCATE_DEMAND_BRANCH FROM GEC_ALLOCATION_RULE WHERE ALLOCATE_BORROW_BRANCH= var_branch_cd) AND
					t.SETTLE_DATE = o.SETTLE_DATE AND
					o.TRANSACTION_CD = p_trans_type AND		
					lc.BRANCH_CD = p_branch_code AND
					o.HOLDBACK_FLAG IN ('Y', 'C') AND
					o.SHARE_QTY > o.FILLED_QTY AND
					t.BORROW_ID = var_borrow_id AND
					rownum = 1;					
		
		-- match asset id / broker code / coll type / coll code / borrow settle date <= short settle date
		--CURSOR v_agecny_no_demand IS
		--	SELECT out_b.BORROW_ID, curr_allo.IM_ORDER_ID
		--	FROM (SELECT lc.DML_NSB_BROKER as BROKER_CD, lc.NSB_COLLATERAL_TYPE as COLLATERAL_TYPE, NVL(lcc.COLLATERAL_CURRENCY_CD, lc.COLLATERAL_CURRENCY_CD) as COLLATERAL_CURRENCY_CD, in_b.ASSET_ID, o.SETTLE_DATE as S_SETTLE_DATE, a.IM_ORDER_ID, o.HOLDBACK_FLAG, o.TRANSACTION_CD, lc.BRANCH_CD, in_b.BORROW_ORDER_ID
		--			FROM GEC_BORROW_TEMP in_b, 
		--				 GEC_ALLOCATION a, 
		--				 GEC_IM_ORDER o, 
		--		 		 (SELECT f.FUND_CD, f.DML_NSB_BROKER, f.BRANCH_CD, f.NSB_COLLATERAL_TYPE, g1.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1
		--		  		  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L') lc LEFT JOIN
		--		 		 (SELECT f.FUND_CD, gc.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1, GEC_G1_COLLATERAL gc
		--		  		  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L' and g1.G1_BOOKING_ID = gc.G1_BOOKING_ID and gc.TRADE_COUNTRY_CD = var_trade_country) lcc ON lc.FUND_CD = lcc.FUND_CD
		--			WHERE a.BORROW_ID = in_b.BORROW_ID AND
		--				a.IM_ORDER_ID = o.IM_ORDER_ID AND
		--				o.FUND_CD = lc.FUND_CD)curr_allo,
		--		GEC_BORROW_TEMP out_b
		--	WHERE out_b.BROKER_CD = curr_allo.BROKER_CD AND
		--		  out_b.COLLATERAL_CURRENCY_CD = curr_allo.COLLATERAL_CURRENCY_CD AND
		--		  out_b.ASSET_ID = curr_allo.ASSET_ID AND
		--		  out_b.SETTLE_DATE <= curr_allo.S_SETTLE_DATE AND
		--		  out_b.BRANCH_CD IN ('BOS',GEC_CONSTANTS_PKG.C_BRANCH_GMBH) AND
		--		  out_b.BORROW_ID = var_borrow_id AND
		--		  curr_allo.HOLDBACK_FLAG IN ('N', 'C') AND
				  -- NSB borrow can not be allocated to SB only short
		--		  curr_allo.TRANSACTION_CD <> GEC_CONSTANTS_PKG.C_SB_SHORT AND				  
		--		  (p_input_type=GEC_CONSTANTS_PKG.C_BORROW_FILE AND out_b.BORROW_ORDER_ID = curr_allo.BORROW_ORDER_ID OR p_input_type <> GEC_CONSTANTS_PKG.C_BORROW_FILE) AND 
		--		  (out_b.NON_CASH_FLAG='Y' AND curr_allo.COLLATERAL_TYPE='CASH' OR out_b.NON_CASH_FLAG='N' AND curr_allo.HOLDBACK_FLAG<>'C') AND
		--		  rownum = 1;
				  
		CURSOR v_agecny_no_demand_tor IS
			SELECT out_b.BORROW_ID, curr_allo.IM_ORDER_ID
			FROM (SELECT lc.DML_NSB_BROKER as BROKER_CD, lc.NSB_COLLATERAL_TYPE as COLLATERAL_TYPE, NVL(lcc.COLLATERAL_CURRENCY_CD, lc.COLLATERAL_CURRENCY_CD) as COLLATERAL_CURRENCY_CD, in_b.ASSET_ID, o.SETTLE_DATE as S_SETTLE_DATE, a.IM_ORDER_ID, o.HOLDBACK_FLAG, o.TRANSACTION_CD, lc.BRANCH_CD, in_b.BORROW_ORDER_ID
					FROM GEC_BORROW_TEMP in_b, 
						 GEC_ALLOCATION a, 
						 GEC_IM_ORDER o, 
				 		 (SELECT f.FUND_CD, f.DML_NSB_BROKER, f.BRANCH_CD, f.NSB_COLLATERAL_TYPE, g1.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1
				  		  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L') lc LEFT JOIN
				 		 (SELECT f.FUND_CD, gc.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1, GEC_G1_COLLATERAL gc
				  		  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L' and g1.G1_BOOKING_ID = gc.G1_BOOKING_ID and gc.TRADE_COUNTRY_CD = var_trade_country) lcc ON lc.FUND_CD = lcc.FUND_CD
					WHERE a.BORROW_ID = in_b.BORROW_ID AND
						a.IM_ORDER_ID = o.IM_ORDER_ID AND
						o.FUND_CD = lc.FUND_CD)curr_allo,
				GEC_BORROW_TEMP out_b
			WHERE 
				  out_b.COLLATERAL_CURRENCY_CD = curr_allo.COLLATERAL_CURRENCY_CD AND
				  out_b.ASSET_ID = curr_allo.ASSET_ID AND
				  out_b.SETTLE_DATE <= curr_allo.S_SETTLE_DATE AND
				  -- branch 'TOR' borrow can allocated to branch 'TOR' and 'BOS' shorts						  
				  curr_allo.BRANCH_CD IN (SELECT ALLOCATE_DEMAND_BRANCH FROM GEC_ALLOCATION_RULE WHERE ALLOCATE_BORROW_BRANCH= var_branch_cd) AND
				  out_b.BORROW_ID = var_borrow_id AND
				  curr_allo.HOLDBACK_FLAG IN ('N', 'C') AND
				  -- NSB borrow can not be allocated to SB only short
				  curr_allo.TRANSACTION_CD <> GEC_CONSTANTS_PKG.C_SB_SHORT AND					  
				  (p_input_type=GEC_CONSTANTS_PKG.C_BORROW_FILE AND out_b.BORROW_ORDER_ID = curr_allo.BORROW_ORDER_ID OR p_input_type <> GEC_CONSTANTS_PKG.C_BORROW_FILE) AND 
				  (out_b.NON_CASH_FLAG='Y' AND curr_allo.COLLATERAL_TYPE='CASH' OR out_b.NON_CASH_FLAG='N' AND curr_allo.HOLDBACK_FLAG<>'C') AND
				  rownum = 1;				  
		
		--CURSOR v_agecny_holdback IS
		--	SELECT t.BORROW_ID, o.HOLDBACK_FLAG
		--	FROM GEC_BORROW_TEMP t, 
		--		 GEC_IM_ORDER o, 
		--		 (SELECT f.FUND_CD, f.DML_NSB_BROKER, f.BRANCH_CD, g1.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1
		--		  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L') lc LEFT JOIN
		--		 (SELECT f.FUND_CD, gc.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1, GEC_G1_COLLATERAL gc
		--		  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L' and g1.G1_BOOKING_ID = gc.G1_BOOKING_ID and gc.TRADE_COUNTRY_CD = var_trade_country) lcc ON lc.FUND_CD = lcc.FUND_CD
		--	WHERE t.ASSET_ID = o.ASSET_ID AND
		--			o.FUND_CD = lc.FUND_CD AND
		--			t.BROKER_CD = lc.DML_NSB_BROKER AND
		--			t.COLLATERAL_CURRENCY_CD = NVL(lcc.COLLATERAL_CURRENCY_CD, lc.COLLATERAL_CURRENCY_CD) AND
		--			lc.BRANCH_CD IN ('BOS',GEC_CONSTANTS_PKG.C_BRANCH_GMBH) AND
		--			t.SETTLE_DATE <= o.SETTLE_DATE AND
		--			o.HOLDBACK_FLAG IN ('Y', 'C') AND
		--			o.SHARE_QTY > o.FILLED_QTY AND
		--			t.BORROW_ID = var_borrow_id AND
		--			rownum = 1;
					
		CURSOR v_agecny_holdback_tor IS
			SELECT t.BORROW_ID, o.HOLDBACK_FLAG
			FROM GEC_BORROW_TEMP t, 
				 GEC_IM_ORDER o, 
				 (SELECT f.FUND_CD, f.DML_NSB_BROKER, f.BRANCH_CD, g1.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1
				  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L') lc LEFT JOIN
				 (SELECT f.FUND_CD, gc.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1, GEC_G1_COLLATERAL gc
				  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L' and g1.G1_BOOKING_ID = gc.G1_BOOKING_ID and gc.TRADE_COUNTRY_CD = var_trade_country) lcc ON lc.FUND_CD = lcc.FUND_CD 
			WHERE t.ASSET_ID = o.ASSET_ID AND
					o.FUND_CD = lc.FUND_CD AND						
					t.BROKER_CD = lc.DML_NSB_BROKER AND
					t.COLLATERAL_CURRENCY_CD = NVL(lcc.COLLATERAL_CURRENCY_CD, lc.COLLATERAL_CURRENCY_CD) AND
					lc.BRANCH_CD IN (SELECT ALLOCATE_DEMAND_BRANCH FROM GEC_ALLOCATION_RULE WHERE ALLOCATE_BORROW_BRANCH= var_branch_cd) AND
					t.SETTLE_DATE <= o.SETTLE_DATE AND
					o.HOLDBACK_FLAG IN ('Y', 'C') AND
					o.SHARE_QTY > o.FILLED_QTY AND
					t.BORROW_ID = var_borrow_id AND
					rownum = 1;					
					
		-- for single input, only need to allocated to the shorts in current aggregated demand(asset id, nsb coll type, nsb coll code, branch code)
		--CURSOR v_agecny_holdback_s IS
		--	SELECT t.BORROW_ID, o.HOLDBACK_FLAG
		--	FROM GEC_BORROW_TEMP t, 
		--		 GEC_IM_ORDER o, 
		--		 (SELECT f.FUND_CD, f.DML_NSB_BROKER, f.BRANCH_CD, g1.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1
		--		  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L') lc LEFT JOIN
		--		 (SELECT f.FUND_CD, gc.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1, GEC_G1_COLLATERAL gc
		--		  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L' and g1.G1_BOOKING_ID = gc.G1_BOOKING_ID and gc.TRADE_COUNTRY_CD = var_trade_country) lcc ON lc.FUND_CD = lcc.FUND_CD
		--	WHERE t.ASSET_ID = o.ASSET_ID AND
		--			o.FUND_CD = lc.FUND_CD AND						
		--			t.BROKER_CD = lc.DML_NSB_BROKER AND
		--			NVL(lcc.COLLATERAL_CURRENCY_CD, lc.COLLATERAL_CURRENCY_CD) = p_nsb_coll_code AND
		--			lc.BRANCH_CD IN ('BOS',GEC_CONSTANTS_PKG.C_BRANCH_GMBH) AND
		--			t.SETTLE_DATE <= o.SETTLE_DATE AND
		--			o.HOLDBACK_FLAG IN ('Y','C') AND
		--			o.SHARE_QTY > o.FILLED_QTY AND
		--			o.TRANSACTION_CD = p_trans_type AND		
		--			lc.BRANCH_CD = p_branch_code AND
		--			t.BORROW_ID = var_borrow_id AND
		--			rownum = 1;
					
		CURSOR v_agecny_holdback_s_tor IS
			SELECT t.BORROW_ID, o.HOLDBACK_FLAG
			FROM GEC_BORROW_TEMP t, 
				 GEC_IM_ORDER o, 
				 (SELECT f.FUND_CD, f.DML_NSB_BROKER, f.BRANCH_CD, g1.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1
				  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L') lc LEFT JOIN
				 (SELECT f.FUND_CD, gc.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1, GEC_G1_COLLATERAL gc
				  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L' and g1.G1_BOOKING_ID = gc.G1_BOOKING_ID and gc.TRADE_COUNTRY_CD = var_trade_country) lcc ON lc.FUND_CD = lcc.FUND_CD
			WHERE t.ASSET_ID = o.ASSET_ID AND
					o.FUND_CD = lc.FUND_CD AND						
					t.BROKER_CD = lc.DML_NSB_BROKER AND
					NVL(lcc.COLLATERAL_CURRENCY_CD, lc.COLLATERAL_CURRENCY_CD) = p_nsb_coll_code AND
				  -- branch 'TOR' borrow can allocated to branch 'TOR' and 'BOS' shorts					
					lc.BRANCH_CD IN (SELECT ALLOCATE_DEMAND_BRANCH FROM GEC_ALLOCATION_RULE WHERE ALLOCATE_BORROW_BRANCH= var_branch_cd) AND
					t.SETTLE_DATE <= o.SETTLE_DATE AND
					o.HOLDBACK_FLAG IN ('Y','C') AND
					o.SHARE_QTY > o.FILLED_QTY AND
					o.TRANSACTION_CD = p_trans_type AND		
					lc.BRANCH_CD = p_branch_code AND
					t.BORROW_ID = var_borrow_id AND
					rownum = 1;					
		
		-- match asset id / coll type / coll code / borrow settle date <= short settle date
		--CURSOR v_nsb_no_demand IS
		--	SELECT out_b.BORROW_ID, curr_allo.IM_ORDER_ID
		--	FROM (SELECT lc.NSB_COLLATERAL_TYPE as COLLATERAL_TYPE, NVL(lcc.COLLATERAL_CURRENCY_CD, lc.COLLATERAL_CURRENCY_CD) as COLLATERAL_CURRENCY_CD, in_b.ASSET_ID, o.SETTLE_DATE as S_SETTLE_DATE, a.IM_ORDER_ID, lc.BRANCH_CD, o.TRANSACTION_CD, o.HOLDBACK_FLAG, in_b.BORROW_ORDER_ID
		--			FROM GEC_BORROW_TEMP in_b, 
		--				 GEC_ALLOCATION a, 
		--				 GEC_IM_ORDER o, 
		--		 		 (SELECT f.FUND_CD, f.BRANCH_CD, f.NSB_COLLATERAL_TYPE, g1.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1
		--		  		  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L') lc LEFT JOIN
		--		 		 (SELECT f.FUND_CD, gc.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1, GEC_G1_COLLATERAL gc
		--		  		  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L' and g1.G1_BOOKING_ID = gc.G1_BOOKING_ID and gc.TRADE_COUNTRY_CD = var_trade_country) lcc ON lc.FUND_CD = lcc.FUND_CD
		--			WHERE a.BORROW_ID = in_b.BORROW_ID AND
		--				a.IM_ORDER_ID = o.IM_ORDER_ID AND
		--				o.FUND_CD = lc.FUND_CD)curr_allo,
		--		GEC_BORROW_TEMP out_b
		--	WHERE out_b.COLLATERAL_CURRENCY_CD = curr_allo.COLLATERAL_CURRENCY_CD AND
		--		  out_b.ASSET_ID = curr_allo.ASSET_ID AND
		--		  out_b.SETTLE_DATE <= curr_allo.S_SETTLE_DATE AND
		--		  out_b.BRANCH_CD IN ('BOS',GEC_CONSTANTS_PKG.C_BRANCH_GMBH) AND
		--		  out_b.BORROW_ID = var_borrow_id AND
				  --in gec1.5 can't allocated to holdback short
		--		  curr_allo.HOLDBACK_FLAG IN ('N', 'C') AND		
				  -- NSB borrow can not be allocated to SB only short
	--			  curr_allo.TRANSACTION_CD <> GEC_CONSTANTS_PKG.C_SB_SHORT AND					  		  
	--			  (p_input_type=GEC_CONSTANTS_PKG.C_BORROW_FILE AND out_b.BORROW_ORDER_ID = curr_allo.BORROW_ORDER_ID OR p_input_type <> GEC_CONSTANTS_PKG.C_BORROW_FILE) AND 
	--			  (out_b.NON_CASH_FLAG='Y' AND curr_allo.COLLATERAL_TYPE='CASH' OR out_b.NON_CASH_FLAG='N' AND curr_allo.HOLDBACK_FLAG<>'C') AND
	--			  rownum = 1;
				  
		CURSOR v_nsb_no_demand_tor IS
			SELECT out_b.BORROW_ID, curr_allo.IM_ORDER_ID
			FROM (SELECT lc.NSB_COLLATERAL_TYPE as COLLATERAL_TYPE, NVL(lcc.COLLATERAL_CURRENCY_CD, lc.COLLATERAL_CURRENCY_CD) as COLLATERAL_CURRENCY_CD, in_b.ASSET_ID, o.SETTLE_DATE as S_SETTLE_DATE, a.IM_ORDER_ID, lc.BRANCH_CD, o.TRANSACTION_CD, o.HOLDBACK_FLAG, in_b.BORROW_ORDER_ID
					FROM GEC_BORROW_TEMP in_b, 
						 GEC_ALLOCATION a, 
						 GEC_IM_ORDER o, 
				 		 (SELECT f.FUND_CD, f.BRANCH_CD, f.NSB_COLLATERAL_TYPE, g1.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1
				  		  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L') lc LEFT JOIN
				 		 (SELECT f.FUND_CD, gc.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1, GEC_G1_COLLATERAL gc
				  		  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L' and g1.G1_BOOKING_ID = gc.G1_BOOKING_ID and gc.TRADE_COUNTRY_CD = var_trade_country) lcc ON lc.FUND_CD = lcc.FUND_CD
					WHERE a.BORROW_ID = in_b.BORROW_ID AND
						a.IM_ORDER_ID = o.IM_ORDER_ID AND
						o.FUND_CD = lc.FUND_CD)curr_allo,
				GEC_BORROW_TEMP out_b
			WHERE out_b.COLLATERAL_CURRENCY_CD = curr_allo.COLLATERAL_CURRENCY_CD AND
				  out_b.ASSET_ID = curr_allo.ASSET_ID AND
				  out_b.SETTLE_DATE <= curr_allo.S_SETTLE_DATE AND
				  -- branch 'TOR' borrow can allocated to branch 'TOR' and 'BOS' shorts						  
				  curr_allo.BRANCH_CD IN (SELECT ALLOCATE_DEMAND_BRANCH FROM GEC_ALLOCATION_RULE WHERE ALLOCATE_BORROW_BRANCH= var_branch_cd) AND
				  --in gec1.5 can't allocated to holdback short
				  curr_allo.HOLDBACK_FLAG IN ('N', 'C') AND		
				  -- NSB borrow can not be allocated to SB only short
				  curr_allo.TRANSACTION_CD <> GEC_CONSTANTS_PKG.C_SB_SHORT AND					  			  
				  out_b.BORROW_ID = var_borrow_id AND
				  (p_input_type=GEC_CONSTANTS_PKG.C_BORROW_FILE AND out_b.BORROW_ORDER_ID = curr_allo.BORROW_ORDER_ID OR p_input_type <> GEC_CONSTANTS_PKG.C_BORROW_FILE) AND 
				  (out_b.NON_CASH_FLAG='Y' AND curr_allo.COLLATERAL_TYPE='CASH' OR out_b.NON_CASH_FLAG='N' AND curr_allo.HOLDBACK_FLAG<>'C') AND
				  rownum = 1;				  
		
		--CURSOR v_non_agecny_holdback IS
		--	SELECT t.BORROW_ID, o.HOLDBACK_FLAG
		--	FROM GEC_BORROW_TEMP t, 
		--		 GEC_IM_ORDER o, 
		--		 (SELECT f.FUND_CD, f.DML_NSB_BROKER, f.BRANCH_CD, g1.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1
		--		  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L') lc LEFT JOIN
		--		 (SELECT f.FUND_CD, gc.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1, GEC_G1_COLLATERAL gc
		--		  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L' and g1.G1_BOOKING_ID = gc.G1_BOOKING_ID and gc.TRADE_COUNTRY_CD = var_trade_country) lcc ON lc.FUND_CD = lcc.FUND_CD
		--	WHERE t.ASSET_ID = o.ASSET_ID AND
		--			o.FUND_CD = lc.FUND_CD AND						
		--			t.COLLATERAL_CURRENCY_CD = NVL(lcc.COLLATERAL_CURRENCY_CD, lc.COLLATERAL_CURRENCY_CD) AND
		--			lc.BRANCH_CD IN ('BOS',GEC_CONSTANTS_PKG.C_BRANCH_GMBH) AND
		--			t.SETTLE_DATE <= o.SETTLE_DATE AND
					--in gec1.5 can't allocated to holdback short					
		--			o.HOLDBACK_FLAG IN ('Y','C') AND
		--			o.SHARE_QTY > o.FILLED_QTY AND
		--			t.BORROW_ID = var_borrow_id AND
		--			rownum = 1;
					
		CURSOR v_non_agecny_holdback_tor IS
			SELECT t.BORROW_ID, o.HOLDBACK_FLAG
			FROM GEC_BORROW_TEMP t, 
				 GEC_IM_ORDER o, 
				 (SELECT f.FUND_CD, f.DML_NSB_BROKER, f.BRANCH_CD, g1.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1
				  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L') lc LEFT JOIN 
				 (SELECT f.FUND_CD, gc.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1, GEC_G1_COLLATERAL gc
				  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L' and g1.G1_BOOKING_ID = gc.G1_BOOKING_ID and gc.TRADE_COUNTRY_CD = var_trade_country) lcc ON lc.FUND_CD = lcc.FUND_CD
			WHERE t.ASSET_ID = o.ASSET_ID AND
					o.FUND_CD = lc.FUND_CD AND						
					t.COLLATERAL_CURRENCY_CD = NVL(lcc.COLLATERAL_CURRENCY_CD, lc.COLLATERAL_CURRENCY_CD) AND
					lc.BRANCH_CD IN (SELECT ALLOCATE_DEMAND_BRANCH FROM GEC_ALLOCATION_RULE WHERE ALLOCATE_BORROW_BRANCH= var_branch_cd) AND
					t.SETTLE_DATE <= o.SETTLE_DATE AND
				  	--in gec1.5 can't allocated to holdback short					
					o.HOLDBACK_FLAG IN ('Y','C') AND
					o.SHARE_QTY > o.FILLED_QTY AND
					t.BORROW_ID = var_borrow_id AND
					rownum = 1;					
					
		-- for single input, only need to allocated to the shorts in current aggregated demand(asset id, nsb coll type, nsb coll code, branch code)
		--CURSOR v_non_agecny_holdback_s IS
			--SELECT t.BORROW_ID, o.HOLDBACK_FLAG
		--	FROM GEC_BORROW_TEMP t, 
		--		 GEC_IM_ORDER o, 
		--		 (SELECT f.FUND_CD, f.DML_NSB_BROKER, f.BRANCH_CD, g1.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1
		--		  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L') lc LEFT JOIN
		--		 (SELECT f.FUND_CD, gc.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1, GEC_G1_COLLATERAL gc
		--		  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L' and g1.G1_BOOKING_ID = gc.G1_BOOKING_ID and gc.TRADE_COUNTRY_CD = var_trade_country) lcc ON lc.FUND_CD = lcc.FUND_CD	
		--	WHERE t.ASSET_ID = o.ASSET_ID AND
		--			o.FUND_CD = lc.FUND_CD AND					
		--			NVL(lcc.COLLATERAL_CURRENCY_CD, lc.COLLATERAL_CURRENCY_CD) = p_nsb_coll_code AND
		--			lc.BRANCH_CD IN ('BOS',GEC_CONSTANTS_PKG.C_BRANCH_GMBH) AND
		--			t.SETTLE_DATE <= o.SETTLE_DATE AND
		--			o.HOLDBACK_FLAG IN ('Y','C') AND
		--			o.SHARE_QTY > o.FILLED_QTY AND
		--			o.TRANSACTION_CD = p_trans_type AND	
		--			lc.BRANCH_CD = p_branch_code AND
		--			t.BORROW_ID = var_borrow_id AND
		--			rownum = 1;
					
		CURSOR v_non_agecny_holdback_s_tor IS
			SELECT t.BORROW_ID, o.HOLDBACK_FLAG
			FROM GEC_BORROW_TEMP t, 
				 GEC_IM_ORDER o, 
				 (SELECT f.FUND_CD, f.DML_NSB_BROKER, f.BRANCH_CD, g1.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1
				  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L') lc LEFT JOIN
				 (SELECT f.FUND_CD, gc.COLLATERAL_CURRENCY_CD FROM GEC_FUND f, GEC_G1_BOOKING g1, GEC_G1_COLLATERAL gc
				  WHERE g1.FUND_CD = f.FUND_CD AND g1.POS_TYPE = 'NSB' AND g1.TRANSACTION_CD = 'G1L' and g1.G1_BOOKING_ID = gc.G1_BOOKING_ID and gc.TRADE_COUNTRY_CD = var_trade_country) lcc ON lc.FUND_CD = lcc.FUND_CD
			WHERE t.ASSET_ID = o.ASSET_ID AND
					o.FUND_CD = lc.FUND_CD AND				
					NVL(lcc.COLLATERAL_CURRENCY_CD, lc.COLLATERAL_CURRENCY_CD) = p_nsb_coll_code AND
					lc.BRANCH_CD IN (SELECT ALLOCATE_DEMAND_BRANCH FROM GEC_ALLOCATION_RULE WHERE ALLOCATE_BORROW_BRANCH= var_branch_cd) AND
					t.SETTLE_DATE <= o.SETTLE_DATE AND
					o.HOLDBACK_FLAG IN ('Y','C') AND
					o.SHARE_QTY > o.FILLED_QTY AND
					o.TRANSACTION_CD = p_trans_type AND	
					lc.BRANCH_CD = p_branch_code AND
					t.BORROW_ID = var_borrow_id AND
					rownum = 1;					
		
		-- manual borrows which for the securities coming from the trade countries which set auto booking flag 'N'
		CURSOR v_file_manual_submit IS
			SELECT TYPE FROM GEC_BORROW_TEMP;
		CURSOR v_not_auto_booking IS
			SELECT bt.BORROW_ID, bt.ASSET_ID FROM GEC_BORROW_TEMP bt, GEC_TRADE_COUNTRY tc WHERE bt.TRADE_COUNTRY_CD = tc.TRADE_COUNTRY_CD AND tc.G1_AUTO_BOOKING = 'N' AND p_user_id <> GEC_CONSTANTS_PKG.C_SYSTEM;
		CURSOR v_prepare_rate_null IS
			SELECT BORROW_ID, ASSET_ID FROM GEC_BORROW_TEMP WHERE PREPAY_RATE IS NULL AND ((PREPAY_DATE < SETTLE_DATE AND (COLLATERAL_TYPE = 'CASH' OR COLLATERAL_TYPE = 'POOL' )AND (BORROW_REQUEST_TYPE <> 'SB' AND (TRADE_COUNTRY_CD='US' OR TRADE_COUNTRY_CD='CA')) ) OR  ((COLLATERAL_TYPE = 'CASH' OR COLLATERAL_TYPE = 'POOL' ) AND (BORROW_REQUEST_TYPE <> 'SB' AND (TRADE_COUNTRY_CD<>'US' AND TRADE_COUNTRY_CD<>'CA'))));
		-- manual borrows which are borrow more than demand
		CURSOR v_manual_borrows IS
			SELECT BORROW_ID, ASSET_ID FROM GEC_BORROW_TEMP WHERE UNFILLED_QTY > 0;
		-- manual borrows which are sp
		CURSOR v_sp_borrows IS
			SELECT BORROW_ID, ASSET_ID FROM GEC_BORROW_TEMP WHERE POSITION_FLAG = 'SP' AND BORROW_REQUEST_TYPE<>GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB;
			
		CURSOR v_manuals IS
			SELECT BORROW_ID, INTERVENTION_REASON FROM GEC_BORROW_TEMP WHERE STATUS = GEC_CONSTANTS_PKG.C_BORROW_MANUAL;
		
		CURSOR v_contigency_manuals IS
			SELECT BORROW_ID FROM GEC_BORROW_TEMP WHERE CONTINGENTY_INTERVENTION_FLAG = 'Y';
		
		CURSOR v_pshare_manuals IS
			SELECT gbt.BORROW_ID, gbt.ASSET_ID FROM GEC_BORROW_TEMP gbt,GEC_ALLOCATION ga,GEC_IM_ORDER gio,GEC_FUND gf,GEC_COUNTRY_CATEGORY_MAP gccm
			WHERE ga.BORROW_ID=gbt.BORROW_ID 
			AND ga.IM_ORDER_ID = gio.IM_ORDER_ID
			AND gio.FUND_CD = gf.FUND_CD
			AND gbt.SETTLE_DATE = gio.SETTLE_DATE
			AND gio.TRADE_COUNTRY_CD = gccm.COUNTRY_CD
			AND (gccm.COUNTRY_CATEGORY_CD='PS1' OR gccm.COUNTRY_CATEGORY_CD='PS2')
			AND gf.FUND_CATEGORY_CD = 'OBF'
			AND gf.FUND_CATEGORY_CD IS NOT NULL;
			
		
		
		-- SB manual borrows
		CURSOR v_sb_manual_borrows IS
				SELECT f.NSB_COLLATERAL_TYPE, f.COLLATERAL_CURRENCY_CD, a.BORROW_ID, a.IM_ORDER_ID
				FROM GEC_BORROW_TEMP t, GEC_ALLOCATION a, GEC_IM_ORDER o, GEC_FUND f
				WHERE t.BORROW_ID = a.BORROW_ID AND
						a.IM_ORDER_ID = o.IM_ORDER_ID AND
						o.FUND_CD = f.FUND_CD AND
						t.STATUS = GEC_CONSTANTS_PKG.C_BORROW_MANUAL AND
						t.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB;
		
		-- if it is file response and it is sb and it need manual intervention
		CURSOR v_file_sb_manual IS
				SELECT t.BORROW_ID 
				FROM GEC_BORROW_TEMP t
				WHERE t.STATUS = GEC_CONSTANTS_PKG.C_BORROW_MANUAL AND
					  t.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND
					  t.UNFILLED_QTY > 0;
		
		-- all shorts which are current borrow_request, excluding which are mapping to manual borrows		  
		CURSOR in_flight_orders IS
			SELECT o.IM_ORDER_ID, o.MATCHED_ID FROM GEC_IM_ORDER o
			WHERE o.EXPORT_STATUS = 'I' AND 
							EXISTS (SELECT 1 FROM GEC_BORROW_ORDER bo, GEC_BORROW_ORDER_DETAIL detail
										WHERE detail.IM_ORDER_ID = o.IM_ORDER_ID  AND
												detail.BORROW_ORDER_ID = bo.BORROW_ORDER_ID AND
												bo.BORROW_REQUEST_ID = p_demand_request_id)
							AND NOT EXISTS(SELECT 1 FROM GEC_BORROW_ORDER_DETAIL detail, GEC_BORROW_TEMP temp
												WHERE detail.IM_ORDER_ID = o.IM_ORDER_ID AND
													detail.BORROW_ORDER_ID = temp.BORROW_ORDER_ID AND
													temp.STATUS = GEC_CONSTANTS_PKG.C_BORROW_MANUAL);
		
		-- all SB only orders 
		CURSOR sb_only_orders IS
			SELECT o.IM_ORDER_ID 
			FROM GEC_IM_ORDER o, GEC_BORROW_TEMP t, GEC_ALLOCATION a
			WHERE t.BORROW_ID = a.BORROW_ID AND
			      a.IM_ORDER_ID = o.IM_ORDER_ID AND
			      o.TRANSACTION_CD = GEC_CONSTANTS_PKG.C_SB_SHORT AND
			      t.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND
			      t.STATUS <> GEC_CONSTANTS_PKG.C_BORROW_MANUAL AND
			      p_input_type = GEC_CONSTANTS_PKG.C_BORROW_SINGLE
			UNION
			SELECT o.IM_ORDER_ID
			FROM GEC_IM_ORDER o, GEC_BORROW_REQUEST br, GEC_BORROW_ORDER bo, GEC_BORROW_ORDER_DETAIL del, GEC_BORROW_TEMP t
			WHERE bo.BORROW_REQUEST_ID = br.BORROW_REQUEST_ID AND	  
			  	  br.BORROW_REQUEST_ID = p_demand_request_id AND
			      bo.BORROW_ORDER_ID = del.BORROW_ORDER_ID AND
			      t.BORROW_ORDER_ID = del.BORROW_ORDER_ID AND
			      del.IM_ORDER_ID = o.IM_ORDER_ID AND
			      p_input_type = GEC_CONSTANTS_PKG.C_BORROW_FILE AND
			      o.TRANSACTION_CD = GEC_CONSTANTS_PKG.C_SB_SHORT AND
			      t.STATUS <> GEC_CONSTANTS_PKG.C_BORROW_MANUAL;
			      
													
		-- all pre-loan shorts which are allocated by current input borrows	
		CURSOR pre_booked_loans IS
			SELECT a.IM_ORDER_ID, l.LOAN_ID FROM GEC_ALLOCATION a, GEC_LOAN l 
			WHERE a.LOAN_ID = l.LOAN_ID AND
			  		l.TYPE = 'PRE-LOAN' AND
			  	EXISTS(SELECT 1 FROM GEC_ALLOCATION in_a, GEC_BORROW_TEMP t WHERE in_a.IM_ORDER_ID = a.IM_ORDER_ID AND in_a.BORROW_ID = t.BORROW_ID);
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);		
		
		-- prepare borrow temp
		PREPARE_TEMP_BORROWS(p_input_type, p_borrow_file_type, p_trans_type, var_valid);
		
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME||' prepare borrow end-');
		
		-- validation error
		IF var_valid = 'N' THEN
			p_status := 'VE';
			FILL_ERROR_RST(p_shorts_cursor, p_borrows_cursor);
			RETURN;
		END IF;
		
		IF p_input_type <> GEC_CONSTANTS_PKG.C_BORROW_FILE THEN
			var_end_settle_date := GEC_UTILS_PKG.GET_TPLUSN_NUM(p_settle_date, 5, 'US', 'S');
		END IF;
		
		-- lock gec_im_order, lock sequence 2 (lock sequence 1 is locking gec_borrow_request)
		LOCK_SHORTS(p_demand_request_id, p_input_type, p_settle_date, var_end_settle_date);
		
		-- update/delete existed borrows to GEC_BORROW, it only happens in Single Input and can only update manual intervention (manual input) borrows 
		-- add new borrows
		-- may lock gec_borrow, lock sequence 3
		MERGE_BORROWS(p_user_id, p_input_type,p_trans_type, var_valid);
		
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME||' merge borrow end-');
		
		IF var_valid = 'N' THEN
			p_status := 'UE';
			FILL_ERROR_RST(p_shorts_cursor, p_borrows_cursor);
			RETURN;
		ELSIF var_valid = 'E' THEN
			p_status := 'OE';
			FILL_ERROR_RST(p_shorts_cursor, p_borrows_cursor);
			RETURN;
		END IF;
		
--------------------------------------------------------------------------------------------------------------
------------------------------------------- BEGIN MAIN AUTO ALLOCATION LOGIC----------------------------------
--------------------------------------------------------------------------------------------------------------
		IF p_input_type = GEC_CONSTANTS_PKG.C_BORROW_FILE THEN
			FOR v_f_unit IN v_f_run_units
			LOOP
				-- Fetch the proper shorts to allocate for file, according to BORROW_ORDER_ID
				PREPARE_SHORTS_FOR_FILE(p_borrow_file_type, v_f_unit.ASSET_ID, p_settle_date, v_f_unit.BORROW_ORDER_ID, v_f_unit.AGENCY_FLAG, v_f_unit.BRANCH_CD, v_f_unit.TRADE_COUNTRY_CD, v_f_unit.BORROW_REQUEST_TYPE);
				
				INSERT INTO GEC_BORROW_UNIT_TEMP (BORROW_ID, BORROW_ORDER_ID, ASSET_ID, BROKER_CD, TRADE_DATE, SETTLE_DATE, PREPAY_DATE, TRADE_COUNTRY_CD, COLLATERAL_TYPE,
  									COLLATERAL_CURRENCY_CD, BORROW_QTY, UNFILLED_QTY,POSITION_FLAG, BORROW_REQUEST_TYPE , AGENCY_FLAG, STATUS, NON_CASH_FLAG, BRANCH_CD)
  				SELECT BORROW_ID, BORROW_ORDER_ID, ASSET_ID, BROKER_CD, TRADE_DATE, SETTLE_DATE, PREPAY_DATE, TRADE_COUNTRY_CD, COLLATERAL_TYPE,
  						COLLATERAL_CURRENCY_CD, BORROW_QTY, UNFILLED_QTY,POSITION_FLAG, BORROW_REQUEST_TYPE, AGENCY_FLAG, STATUS, NON_CASH_FLAG, BRANCH_CD
  				FROM GEC_BORROW_TEMP 
  				WHERE BORROW_ORDER_ID = v_f_unit.BORROW_ORDER_ID AND BORROW_REQUEST_TYPE = v_f_unit.BORROW_REQUEST_TYPE;
				
				var_run_flag := 'Y';
				
				WHILE var_run_flag = 'Y'
				LOOP
					var_run_flag := SINGLE_ALLOCATION(p_user_id, v_f_unit.ASSET_ID, v_f_unit.SETTLE_DATE, v_f_unit.BORROW_REQUEST_TYPE, p_input_type, v_f_unit.AGENCY_FLAG,'Y', var_error_code, var_error_hint, var_rate_map, var_ex_loan_info_map);
					EXIT WHEN var_error_code IS NOT NULL;
				END LOOP;
				
				DELETE FROM GEC_IM_ORDER_TEMP;
				DELETE FROM GEC_BORROW_UNIT_TEMP;

				EXIT WHEN var_error_code IS NOT NULL;
			END LOOP;
			
		ELSE
			var_across:='N';
			var_loop_count:=2;
			WHILE var_loop_count>0
			LOOP
				FOR v_nf_unit IN v_nf_run_units
				LOOP
					-- Fetch the proper shorts to allocate for Single / Batch
					IF p_input_type = GEC_CONSTANTS_PKG.C_BORROW_BATCH THEN
						PREPARE_SHORTS_FOR_BATCH(v_nf_unit.ASSET_ID, p_settle_date, var_end_settle_date, v_nf_unit.AGENCY_FLAG, v_nf_unit.BORROW_REQUEST_TYPE, v_nf_unit.BRANCH_CD, v_nf_unit.TRADE_COUNTRY_CD);
					ELSE
						PREPARE_SHORTS_FOR_SINGLE(p_asset_id, p_settle_date, var_end_settle_date, p_nsb_coll_type, p_nsb_coll_code, p_trans_type, v_nf_unit.AGENCY_FLAG, v_nf_unit.BORROW_REQUEST_TYPE, p_branch_code, v_nf_unit.BRANCH_CD, v_nf_unit.TRADE_COUNTRY_CD);
					END IF;
					
					INSERT INTO GEC_BORROW_UNIT_TEMP (BORROW_ID, BORROW_ORDER_ID, ASSET_ID, BROKER_CD, TRADE_DATE, SETTLE_DATE, PREPAY_DATE, TRADE_COUNTRY_CD, COLLATERAL_TYPE,
	  									COLLATERAL_CURRENCY_CD, BORROW_QTY, UNFILLED_QTY,POSITION_FLAG, BORROW_REQUEST_TYPE , AGENCY_FLAG, STATUS, NON_CASH_FLAG, BRANCH_CD,LEGAL_ENTITY_CD)
	  				SELECT BORROW_ID, BORROW_ORDER_ID, ASSET_ID, BROKER_CD, TRADE_DATE, SETTLE_DATE, PREPAY_DATE, TRADE_COUNTRY_CD, COLLATERAL_TYPE,
	  						COLLATERAL_CURRENCY_CD, BORROW_QTY, UNFILLED_QTY,POSITION_FLAG, BORROW_REQUEST_TYPE, AGENCY_FLAG, STATUS, NON_CASH_FLAG, BRANCH_CD,LEGAL_ENTITY_CD
	  				FROM GEC_BORROW_TEMP 
	  				WHERE ASSET_ID = v_nf_unit.ASSET_ID AND
	  						SETTLE_DATE = v_nf_unit.SETTLE_DATE AND
	  						BORROW_REQUEST_TYPE = v_nf_unit.BORROW_REQUEST_TYPE;
					
					var_run_flag := 'Y';
					
					WHILE var_run_flag = 'Y'
					LOOP
						var_run_flag := SINGLE_ALLOCATION(p_user_id, v_nf_unit.ASSET_ID, v_nf_unit.SETTLE_DATE, v_nf_unit.BORROW_REQUEST_TYPE, p_input_type, v_nf_unit.AGENCY_FLAG, var_across,var_error_code, var_error_hint, var_rate_map, var_ex_loan_info_map);
						EXIT WHEN var_error_code IS NOT NULL;
					END LOOP;
					
					DELETE FROM GEC_IM_ORDER_TEMP;
					DELETE FROM GEC_BORROW_UNIT_TEMP;
					
					EXIT WHEN var_error_code IS NOT NULL;
				END LOOP;
				var_across := 'Y';
				var_loop_count:=var_loop_count-1;
			END LOOP;
		END IF;
--------------------------------------------------------------------------------------------------------------
------------------------------------------- END MAIN AUTO ALLOCATION LOGIC----------------------------------
--------------------------------------------------------------------------------------------------------------
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME||' auto allocation end - ');
		
		IF var_error_code IS NOT NULL THEN
			p_status := 'FE';
			p_error_code := var_error_code;
			p_error_hint := var_error_hint;
			FILL_ERROR_RST(p_shorts_cursor, p_borrows_cursor);
			RETURN;
		END IF;
		
		-- handle different prepay dates error
		CHECK_MULTI_PREPAYDATES(var_error);
		IF var_error = 'Y' THEN
		   	-- there is BR6 error
			p_status := 'PE';
			FILL_ERROR_RST(p_shorts_cursor, p_borrows_cursor);
			RETURN;
		END IF;		
		-- handle BR6
		CHECK_MULTI_SETTLEDATES(var_error);
		IF var_error = 'Y' THEN
		   	-- there is BR6 error
			p_status := 'SE';
			FILL_ERROR_RST(p_shorts_cursor, p_borrows_cursor);
			RETURN;
		ELSE
			-- checking for no demand borrow
			var_error := 'N';
			FOR v_n_d IN v_no_demands
			LOOP
				var_borrow_id := v_n_d.BORROW_ID;
				var_trade_country := v_n_d.TRADE_COUNTRY_CD;
				IF v_n_d.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB THEN	--SB
					var_m_b_found := 'N';
					IF v_n_d.BRANCH_CD IS NOT NULL THEN
						var_branch_cd:=v_n_d.BRANCH_CD;
						FOR n_d_t IN v_sb_no_demand_tor
						LOOP
							var_m_b_found := 'Y';
							-- insert a fake allocation for the borrow which is - a. not allocated; b. but treat it as BORROW MORE THAN DEMAND
							INSERT INTO GEC_ALLOCATION( ALLOCATION_ID, BORROW_ID, LOAN_ID, IM_ORDER_ID, ALLOCATION_QTY, RATE, SETTLE_DATE,STATUS
								)VALUES(GEC_ALLOCATION_ID_SEQ.nextval, var_borrow_id, NULL,n_d_t.IM_ORDER_ID,0,NULL,NULL,GEC_CONSTANTS_PKG.C_ALLO_PROCESSED
										);
							EXIT WHEN var_m_b_found = 'Y';
						END LOOP;
					-- zwh ELSE 	
					--	IF v_n_d.BRANCH_CD IS NOT NULL	 THEN				
					--		FOR n_d IN v_sb_no_demand
					--		LOOP
					--			var_m_b_found := 'Y';
					--			-- insert a fake allocation for the borrow which is - a. not allocated; b. but treat it as BORROW MORE THAN DEMAND
					--			INSERT INTO GEC_ALLOCATION( ALLOCATION_ID, BORROW_ID, LOAN_ID, IM_ORDER_ID, ALLOCATION_QTY, RATE, SETTLE_DATE,STATUS
					--				)VALUES(GEC_ALLOCATION_ID_SEQ.nextval, var_borrow_id, NULL,n_d.IM_ORDER_ID,0,NULL,NULL,GEC_CONSTANTS_PKG.C_ALLO_PROCESSED
					--						);
					--			EXIT WHEN var_m_b_found = 'Y';
					--		END LOOP;
					--	END IF;
					END IF;
								
					IF var_m_b_found = 'N' THEN -- no demand borrow
						var_error := 'Y';
						UPDATE GEC_BORROW_TEMP SET NO_DEMAND_FLAG = 'Y', STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR WHERE BORROW_ID = var_borrow_id;
						
						-- for fix of GEC-2009
						IF p_input_type = GEC_CONSTANTS_PKG.C_BORROW_SINGLE THEN
							IF v_n_d.BRANCH_CD IS NOT NULL THEN
								var_branch_cd:=v_n_d.BRANCH_CD;
								FOR v_h IN v_sb_holdback_s_tor
								LOOP
									UPDATE GEC_BORROW_TEMP SET ERROR_CODE = CASE WHEN v_h.HOLDBACK_FLAG = 'Y' THEN 'VLD0109' ELSE 'VLD0117' END WHERE BORROW_ID = v_h.BORROW_ID;
								END LOOP;
							--ELSE
							--	IF v_n_d.BRANCH_CD IS NOT NULL  THEN
							--		FOR v_h IN v_sb_holdback_s
							--		LOOP
							--			UPDATE GEC_BORROW_TEMP SET ERROR_CODE = CASE WHEN v_h.HOLDBACK_FLAG = 'Y' THEN 'VLD0109' ELSE 'VLD0117' END WHERE BORROW_ID = v_h.BORROW_ID;
							--		END LOOP;
							--	END IF;			
							END IF;					
						ELSE
							IF v_n_d.BRANCH_CD IS NOT NULL THEN
								var_branch_cd:=v_n_d.BRANCH_CD;
								FOR v_h IN v_sb_holdback_tor
								LOOP
									UPDATE GEC_BORROW_TEMP SET ERROR_CODE = CASE WHEN v_h.HOLDBACK_FLAG = 'Y' THEN 'VLD0109' ELSE 'VLD0117' END WHERE BORROW_ID = v_h.BORROW_ID;
								END LOOP;
							--ELSE
							--	IF v_n_d.BRANCH_CD IS NOT NULL  THEN
							--		FOR v_h IN v_sb_holdback
							--		LOOP
							--			UPDATE GEC_BORROW_TEMP SET ERROR_CODE = CASE WHEN v_h.HOLDBACK_FLAG = 'Y' THEN 'VLD0109' ELSE 'VLD0117' END WHERE BORROW_ID = v_h.BORROW_ID;
							--		END LOOP;
							--	END IF;			
							END IF;								
						END IF;
					END IF;
				ELSIF v_n_d.AGENCY_FLAG = 'Y' THEN		-- NSB Agency
					var_m_b_found := 'N';
					IF v_n_d.BRANCH_CD IS NOT NULL THEN
						var_branch_cd:=v_n_d.BRANCH_CD;
						FOR n_d_t IN v_agecny_no_demand_tor
						LOOP
							var_m_b_found := 'Y';
							-- insert a fake allocation for the borrow which is - a. not allocated; b. but treat it as BORROW MORE THAN DEMAND
							INSERT INTO GEC_ALLOCATION( ALLOCATION_ID, BORROW_ID, LOAN_ID, IM_ORDER_ID, ALLOCATION_QTY, RATE, SETTLE_DATE,STATUS
								)VALUES(GEC_ALLOCATION_ID_SEQ.nextval, var_borrow_id, NULL,n_d_t.IM_ORDER_ID,0,NULL,NULL,GEC_CONSTANTS_PKG.C_ALLO_PROCESSED
										);
							EXIT WHEN var_m_b_found = 'Y';
						END LOOP;
					--ELSE 	
					--	IF v_n_d.BRANCH_CD IS NOT NULL	 THEN				
					--		FOR n_d IN v_agecny_no_demand
					--		LOOP
					--			var_m_b_found := 'Y';
					--			-- insert a fake allocation for the borrow which is - a. not allocated; b. but treat it as BORROW MORE THAN DEMAND
					--			INSERT INTO GEC_ALLOCATION( ALLOCATION_ID, BORROW_ID, LOAN_ID, IM_ORDER_ID, ALLOCATION_QTY, RATE, SETTLE_DATE,STATUS
					--				)VALUES(GEC_ALLOCATION_ID_SEQ.nextval, var_borrow_id, NULL,n_d.IM_ORDER_ID,0,NULL,NULL,GEC_CONSTANTS_PKG.C_ALLO_PROCESSED
					--						);
					--			EXIT WHEN var_m_b_found = 'Y';
					--		END LOOP;
					--	END IF;
					END IF;					

					IF var_m_b_found = 'N' THEN -- no demand borrow
						var_error := 'Y';
						UPDATE GEC_BORROW_TEMP SET NO_DEMAND_FLAG = 'Y', STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR WHERE BORROW_ID = var_borrow_id;
						
						-- for fix of GEC-2009
						IF p_input_type = GEC_CONSTANTS_PKG.C_BORROW_SINGLE THEN
							IF v_n_d.BRANCH_CD IS NOT NULL THEN
								var_branch_cd:=v_n_d.BRANCH_CD;
								FOR v_h IN v_agecny_holdback_s_tor
								LOOP
									UPDATE GEC_BORROW_TEMP SET ERROR_CODE = CASE WHEN v_h.HOLDBACK_FLAG = 'Y' THEN 'VLD0109' ELSE 'VLD0117' END WHERE BORROW_ID = v_h.BORROW_ID;
								END LOOP;
							--ELSE
							--	IF v_n_d.BRANCH_CD IS NOT NULL  THEN
							--		FOR v_h IN v_agecny_holdback_s
							--		LOOP
							--			UPDATE GEC_BORROW_TEMP SET ERROR_CODE = CASE WHEN v_h.HOLDBACK_FLAG = 'Y' THEN 'VLD0109' ELSE 'VLD0117' END WHERE BORROW_ID = v_h.BORROW_ID;
							--		END LOOP;
							--	END IF;			
							END IF;					
						ELSE
							IF v_n_d.BRANCH_CD IS NOT NULL THEN
								var_branch_cd:=v_n_d.BRANCH_CD;
								FOR v_h IN v_agecny_holdback_tor
								LOOP
									UPDATE GEC_BORROW_TEMP SET ERROR_CODE = CASE WHEN v_h.HOLDBACK_FLAG = 'Y' THEN 'VLD0109' ELSE 'VLD0117' END WHERE BORROW_ID = v_h.BORROW_ID;
								END LOOP;
							--ELSE
							--	IF v_n_d.BRANCH_CD IS NOT NULL  THEN
							--		FOR v_h IN v_agecny_holdback
							--		LOOP
							--			UPDATE GEC_BORROW_TEMP SET ERROR_CODE = CASE WHEN v_h.HOLDBACK_FLAG = 'Y' THEN 'VLD0109' ELSE 'VLD0117' END WHERE BORROW_ID = v_h.BORROW_ID;
							--		END LOOP;
							--	END IF;			
							END IF;								
						END IF;
					END IF;
				ELSE		-- NSB Non-Agency          
					var_m_b_found := 'N';
					IF v_n_d.BRANCH_CD IS NOT NULL THEN
						var_branch_cd:=v_n_d.BRANCH_CD;
						FOR n_d_t IN v_nsb_no_demand_tor
						LOOP
							var_m_b_found := 'Y';
							-- insert a fake allocation for the borrow which is - a. not allocated; b. but treat it as BORROW MORE THAN DEMAND
							INSERT INTO GEC_ALLOCATION( ALLOCATION_ID, BORROW_ID, LOAN_ID, IM_ORDER_ID, ALLOCATION_QTY, RATE, SETTLE_DATE,STATUS
								)VALUES(GEC_ALLOCATION_ID_SEQ.nextval, var_borrow_id, NULL,n_d_t.IM_ORDER_ID,0,NULL,NULL,GEC_CONSTANTS_PKG.C_ALLO_PROCESSED
										);
							EXIT WHEN var_m_b_found = 'Y';
						END LOOP;
					--ELSE 	
					--	IF v_n_d.BRANCH_CD IS NOT NULL	 THEN				
					--		FOR n_d IN v_nsb_no_demand
					--		LOOP
					--			var_m_b_found := 'Y';
								-- insert a fake allocation for the borrow which is - a. not allocated; b. but treat it as BORROW MORE THAN DEMAND
					--			INSERT INTO GEC_ALLOCATION( ALLOCATION_ID, BORROW_ID, LOAN_ID, IM_ORDER_ID, ALLOCATION_QTY, RATE, SETTLE_DATE,STATUS
					--				)VALUES(GEC_ALLOCATION_ID_SEQ.nextval, var_borrow_id, NULL,n_d.IM_ORDER_ID,0,NULL,NULL,GEC_CONSTANTS_PKG.C_ALLO_PROCESSED
					--						);
					--			EXIT WHEN var_m_b_found = 'Y';
					--		END LOOP;
					--	END IF;
					END IF;		
								
					IF var_m_b_found = 'N' THEN -- no demand borrow
						var_error := 'Y';
						UPDATE GEC_BORROW_TEMP SET NO_DEMAND_FLAG = 'Y', STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR WHERE BORROW_ID = var_borrow_id;
						
						-- for fix of GEC-2009
						IF p_input_type = GEC_CONSTANTS_PKG.C_BORROW_SINGLE THEN
							IF v_n_d.BRANCH_CD IS NOT NULL THEN
								var_branch_cd:=v_n_d.BRANCH_CD;
								FOR v_h IN v_non_agecny_holdback_s_tor
								LOOP
									UPDATE GEC_BORROW_TEMP SET ERROR_CODE = CASE WHEN v_h.HOLDBACK_FLAG = 'Y' THEN 'VLD0109' ELSE 'VLD0117' END WHERE BORROW_ID = v_h.BORROW_ID;
								END LOOP;
							--ELSE
							--	IF v_n_d.BRANCH_CD IS NOT NULL  THEN
							--		FOR v_h IN v_non_agecny_holdback_s
							--		LOOP
							--			UPDATE GEC_BORROW_TEMP SET ERROR_CODE = CASE WHEN v_h.HOLDBACK_FLAG = 'Y' THEN 'VLD0109' ELSE 'VLD0117' END WHERE BORROW_ID = v_h.BORROW_ID;
							--		END LOOP;
							--	END IF;			
							END IF;					
						ELSE
							IF v_n_d.BRANCH_CD IS NOT NULL THEN
								var_branch_cd:=v_n_d.BRANCH_CD;
								FOR v_h IN v_non_agecny_holdback_tor
								LOOP
									UPDATE GEC_BORROW_TEMP SET ERROR_CODE = CASE WHEN v_h.HOLDBACK_FLAG = 'Y' THEN 'VLD0109' ELSE 'VLD0117' END WHERE BORROW_ID = v_h.BORROW_ID;
								END LOOP;
							--ELSE
							--	IF v_n_d.BRANCH_CD IS NOT NULL  THEN
							--		FOR v_h IN v_non_agecny_holdback
							--		LOOP
							--			UPDATE GEC_BORROW_TEMP SET ERROR_CODE = CASE WHEN v_h.HOLDBACK_FLAG = 'Y' THEN 'VLD0109' ELSE 'VLD0117' END WHERE BORROW_ID = v_h.BORROW_ID;
							--		END LOOP;
							--	END IF;			
							END IF;								
						END IF;
					END IF;
				END IF;
			END LOOP;
			
			IF var_error = 'Y' THEN
				p_status := 'NE';
				FILL_ERROR_RST(p_shorts_cursor, p_borrows_cursor);
				RETURN;
			ELSE
				FOR v_f_m_s IN v_file_manual_submit
				LOOP
				
					IF v_f_m_s.TYPE =GEC_CONSTANTS_PKG.C_BORROW_AUTO_INPUT THEN 
						var_auto := 'YES';
					END IF;
					IF v_f_m_s.TYPE = GEC_CONSTANTS_PKG.C_BORROW_MANUAL_INPUT THEN
						var_manual := 'YES';
					END IF;
				END LOOP;
				IF var_auto = 'YES' AND var_manual = 'YES' THEN
					UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_MANUAL, INTERVENTION_REASON = 'manual intervention';
				END IF;
				-- checking for auto_book_flag = 'N'
				FOR v_n_b IN v_not_auto_booking
				LOOP
					UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_MANUAL, INTERVENTION_REASON = GEC_CONSTANTS_PKG.C_BORROW_AUTO_BOOKING_NO
					WHERE BORROW_ID = v_n_b.BORROW_ID;
				END LOOP;
				
				-- checking for manual intervention of borrow qty > demand 
				FOR v_m_b IN v_manual_borrows
				LOOP
					UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_MANUAL, INTERVENTION_REASON = GEC_CONSTANTS_PKG.C_BORROW_MORE_THAN_DEMAND 
					WHERE ASSET_ID = v_m_b.ASSET_ID;
				END LOOP;
				
				-- checking for manual intervention of SP
				FOR v_m_b IN v_sp_borrows
				LOOP
					IF p_user_id <> GEC_CONSTANTS_PKG.C_SYSTEM THEN
						UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_MANUAL, INTERVENTION_REASON = GEC_CONSTANTS_PKG.C_BORROW_SP WHERE ASSET_ID = v_m_b.ASSET_ID;
					ELSE 
						UPDATE GEC_BORROW_TEMP SET CONTINGENTY_INTERVENTION_FLAG = 'Y' WHERE ASSET_ID = v_m_b.ASSET_ID;
					END IF;					
				END LOOP;
				
				-- checking for manual intervention of fee is null
				GENERATE_LOCATE_FEE(p_user_id);				
				
				FOR v_p_r_n IN v_prepare_rate_null
				LOOP
					UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_MANUAL, INTERVENTION_REASON = GEC_CONSTANTS_PKG.C_BORROW_NO_PREPAY_RATE
					WHERE ASSET_ID = v_p_r_n.ASSET_ID;
				END LOOP;
				-- pshare 
				FOR v_p_m IN v_pshare_manuals
				LOOP
					UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_MANUAL, INTERVENTION_REASON = GEC_CONSTANTS_PKG.C_BORROW_P_SHARE
					WHERE ASSET_ID = v_p_m.ASSET_ID;
				END LOOP;
				-- update gec_borrow table for manual intervention borrows
				FOR v_m IN v_manuals
				LOOP
					UPDATE GEC_BORROW SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_MANUAL, INTERVENTION_REASON = v_m.INTERVENTION_REASON WHERE BORROW_ID = v_m.BORROW_ID; 
				END LOOP;
				
				
				-- for contigency mode, send mail about borrows and allocations
				FOR v_c IN v_contigency_manuals
				LOOP
					UPDATE GEC_BORROW SET CONTINGENTY_INTERVENTION_FLAG = 'Y' WHERE BORROW_ID = v_c.BORROW_ID;
				END LOOP;
				
				-- for SB file response input, if there are Manual Intervention, then reject the whole file
				IF p_input_type = GEC_CONSTANTS_PKG.C_BORROW_FILE THEN
					FOR f_s IN v_file_sb_manual
					LOOP
						var_error := 'Y';
						UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR WHERE BORROW_ID = f_s.BORROW_ID;
					END LOOP;
					IF var_error = 'Y' THEN
						p_status := 'ME';
						FILL_ERROR_RST(p_shorts_cursor, p_borrows_cursor);
						RETURN;
					END IF;
				END IF;
								
				-- set the allocation status to temp for manual intervention, the allocation is generated in above allocation step
				UPDATE GEC_ALLOCATION a SET a.STATUS = GEC_CONSTANTS_PKG.C_ALLO_TEMP WHERE EXISTS(
																	SELECT 1 FROM GEC_BORROW_TEMP t
																	WHERE t.BORROW_ID = a.BORROW_ID AND
																		  t.STATUS = GEC_CONSTANTS_PKG.C_BORROW_MANUAL
																		  );
				
				-- rollback the short filled qty for the manually allocation														  
				SET_SHORT_QTY_FOR_M;	
				
				-- per Question 43, for 'M' and 'SB', if it allocated to shorts which haves different NSB coll type/NSB coll code, 
				-- then only keep the allocation for one set of NSB coll type / NSB coll code
				-- since removing the coll type from matching rule, it is not needed now
			--	var_coll_type := NULL;
			--	var_coll_code := NULL;
			--	FOR s_m_b IN v_sb_manual_borrows
			--	LOOP
			--		IF var_coll_type IS NULL THEN
			--			var_coll_type := s_m_b.NSB_COLLATERAL_TYPE;
			--			var_coll_code := s_m_b.COLLATERAL_CURRENCY_CD;
			--		ELSE
			--			IF var_coll_type <> s_m_b.NSB_COLLATERAL_TYPE OR var_coll_code <> s_m_b.COLLATERAL_CURRENCY_CD THEN
			--				DELETE FROM GEC_ALLOCATION 
			--				WHERE BORROW_ID = s_m_b.BORROW_ID AND IM_ORDER_ID = s_m_b.IM_ORDER_ID AND STATUS = GEC_CONSTANTS_PKG.C_ALLO_TEMP;
			--			END IF;
			--		END IF;
			--	END LOOP;

				-- for sb only order, run one time only
				FOR s_o IN sb_only_orders
				LOOP
					UPDATE GEC_IM_ORDER o SET o.EXPORT_STATUS = 'C',o.UPDATED_AT= sysdate,o.UPDATED_BY = p_user_id WHERE o.IM_ORDER_ID = s_o.IM_ORDER_ID;	
				END LOOP;
				
				-- for file, set the in-flight status to 'R' for fill allocated borrows, 
				-- for 'M' borrows, will set in-flight status after user do manual intervension
				-- set pending cancel to cancel
				IF p_input_type = GEC_CONSTANTS_PKG.C_BORROW_FILE THEN		
					FOR in_o IN in_flight_orders
					LOOP
						UPDATE GEC_IM_ORDER o SET o.EXPORT_STATUS = CASE WHEN p_borrow_file_type = GEC_CONSTANTS_PKG.C_SBO_REQUEST THEN 'C' ELSE 'R' END, o.UPDATED_AT= sysdate,o.UPDATED_BY = p_user_id WHERE o.IM_ORDER_ID = in_o.IM_ORDER_ID;
						IF in_o.MATCHED_ID IS NOT NULL THEN -- set pending cancel to cancel, set the short cancel to M-atched
							UPDATE GEC_IM_ORDER o SET o.STATUS = 'C', o.UPDATED_AT= sysdate,o.UPDATED_BY = p_user_id WHERE o.IM_ORDER_ID = in_o.IM_ORDER_ID;
							UPDATE GEC_IM_ORDER o SET o.STATUS = 'M', o.UPDATED_AT= sysdate,o.UPDATED_BY = p_user_id WHERE o.IM_ORDER_ID = in_o.MATCHED_ID;
						END IF;
					END LOOP;
				END IF;
				
				---------------------------------- HOLD BACK FALG -----------------------------------
				-- equiland file/ single / batch, set the holding status to off
				-- for 'M' borrows, will set holdback status after user do manual intervention
				-- comment out according to GEC-2001, HOLDBACK_FLAG is set to 'N' when exporting equilend now
			--	IF p_input_type = GEC_CONSTANTS_PKG.C_BORROW_FILE THEN
			--		UPDATE GEC_IM_ORDER o SET o.HOLDBACK_FLAG = 'N'
			--		WHERE o.HOLDBACK_FLAG = 'Y' AND
			--				EXISTS( SELECT 1 FROM GEC_BORROW_ORDER_DETAIL detail, GEC_BORROW_ORDER demand
			--						WHERE o.IM_ORDER_ID = detail.IM_ORDER_ID AND
			--							detail.BORROW_ORDER_ID = demand.BORROW_ORDER_ID AND
			--							demand.BORROW_REQUEST_ID = p_demand_request_id
			--						)
			--				AND NOT EXISTS(SELECT 1 FROM GEC_BORROW_ORDER_DETAIL detail, GEC_BORROW_TEMP temp
			--								WHERE detail.IM_ORDER_ID = o.IM_ORDER_ID AND
			--										detail.BORROW_ORDER_ID = temp.BORROW_ORDER_ID AND
			--										temp.STATUS = GEC_CONSTANTS_PKG.C_BORROW_MANUAL
			--						);
			--	ELSE
				IF p_input_type <> GEC_CONSTANTS_PKG.C_BORROW_FILE THEN
					-- for single/batch equiland(agency flag = N and type is not SB) borrows, only set holdback status to off for the allocated shorts 
					-- according Question 72
					-- set the holdback from 'Y' to 'N' for the shorts which are allocated by non-agency borrows
					UPDATE GEC_IM_ORDER o SET o.HOLDBACK_FLAG = 'N', o.UPDATED_AT= sysdate,o.UPDATED_BY = p_user_id 
					WHERE o.HOLDBACK_FLAG = 'Y' AND
							EXISTS(
								SELECT 1 FROM GEC_ALLOCATION a, GEC_BORROW_TEMP temp
								WHERE o.IM_ORDER_ID = a.IM_ORDER_ID AND
									  a.BORROW_ID = temp.BORROW_ID AND
									  temp.AGENCY_FLAG = 'N' AND
									  temp.STATUS <> GEC_CONSTANTS_PKG.C_BORROW_MANUAL AND
									  temp.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB
							);
					
					-- set the holdback from 'C' to 'N' for the shorts which are allocated by non-cash borrows
					UPDATE GEC_IM_ORDER o SET o.HOLDBACK_FLAG = 'N', o.UPDATED_AT= sysdate,o.UPDATED_BY = p_user_id 
					WHERE o.HOLDBACK_FLAG = 'C' AND
							EXISTS(
								SELECT 1 FROM GEC_ALLOCATION a, GEC_BORROW_TEMP temp
								WHERE o.IM_ORDER_ID = a.IM_ORDER_ID AND
										a.BORROW_ID = temp.BORROW_ID AND
										temp.NON_CASH_FLAG = 'Y' AND
										temp.STATUS <> GEC_CONSTANTS_PKG.C_BORROW_MANUAL
							);
				END IF;
				
				-- for pre-booked loan, set the allocation status to 'B'
				FOR b_l IN pre_booked_loans
				LOOP
					UPDATE GEC_ALLOCATION a SET a.STATUS = 'B', a.LOAN_ID = b_l.LOAN_ID  WHERE a.IM_ORDER_ID = b_l.IM_ORDER_ID AND
															EXISTS(SELECT 1 FROM GEC_BORROW_TEMP t WHERE a.BORROW_ID = t.BORROW_ID);
				END LOOP;
				
				p_status := 'S';
				
				-- set the the allocation status of borrow request to C-omplete
				UPDATE GEC_BORROW_REQUEST SET ALLOCATE_STATUS='C' WHERE BORROW_REQUEST_ID = p_demand_request_id AND p_demand_request_id IS NOT NULL;
				
				IF p_input_type <> GEC_CONSTANTS_PKG.C_BORROW_FILE THEN -- for manual input borrows
					OPEN p_shorts_cursor FOR
							SELECT o.IM_ORDER_ID, o.ASSET_ID, o.TRADE_COUNTRY_CD,o.FUND_CD,o.SB_BROKER_CD,o.CUSIP,o.SHARE_QTY,o.FILLED_QTY,o.TRANSACTION_CD,o.REQUEST_ID,
									o.SHARE_QTY - o.FILLED_QTY as UNFILLED_QTY,o.SETTLE_DATE,o.TICKER,o.SEDOL,o.ISIN,o.QUIK,o.DESCRIPTION,o.RATE,f.NSB_COLLATERAL_TYPE, NVL(gc.COLLATERAL_CURRENCY_CD, gbk.COLLATERAL_CURRENCY_CD) as COLLATERAL_CURRENCY_CD,
									CASE WHEN t.STATUS=GEC_CONSTANTS_PKG.C_BORROW_MANUAL THEN 1 ELSE 0 END as REQUIREMANUAL,o.SOURCE_CD, tc.TRADING_DESK_CD, o.STATUS, o.POSITION_FLAG, UPPER(gat.ASSET_TYPE_DESC) as SECURITY_TYPE,
									o.G1_EXTRACTED_FLAG, o.EXPORT_STATUS, o.HOLDBACK_FLAG, CASE WHEN o.FILLED_QTY > 0 THEN 'Y' ELSE 'N' END as HAS_ALLOCATION,f.BRANCH_CD
							FROM GEC_IM_ORDER o
							JOIN GEC_FUND f ON o.FUND_CD = f.FUND_CD
							JOIN GEC_ASSET_TYPE gat ON o.ASSET_TYPE_ID = gat.ASSET_TYPE_ID
							JOIN GEC_TRADE_COUNTRY tc ON o.TRADE_COUNTRY_CD = tc.TRADE_COUNTRY_CD
							JOIN GEC_ALLOCATION a ON o.IM_ORDER_ID = a.IM_ORDER_ID
							JOIN GEC_BORROW_TEMP t ON t.BORROW_ID = a.BORROW_ID
    						LEFT JOIN GEC_G1_BOOKING gbk ON f.fund_cd = gbk.fund_cd AND gbk.TRANSACTION_CD = 'G1L' AND gbk.POS_TYPE = 'NSB'
    						LEFT JOIN GEC_G1_COLLATERAL gc ON gc.G1_BOOKING_ID = gbk.G1_BOOKING_ID AND gc.TRADE_COUNTRY_CD = tc.TRADE_COUNTRY_CD;
	
				ELSE -- for file response
					OPEN p_shorts_cursor FOR
						SELECT o.IM_ORDER_ID, o.ASSET_ID, o.TRADE_COUNTRY_CD,o.FUND_CD,o.SB_BROKER_CD,o.CUSIP,o.SHARE_QTY,o.FILLED_QTY,o.TRANSACTION_CD,o.REQUEST_ID AS REQUEST_ID,
									o.SHARE_QTY - o.FILLED_QTY as UNFILLED_QTY,o.SETTLE_DATE,o.TICKER,o.SEDOL,o.ISIN,o.QUIK,o.DESCRIPTION,o.RATE,f.NSB_COLLATERAL_TYPE, NVL(gc.COLLATERAL_CURRENCY_CD, gbk.COLLATERAL_CURRENCY_CD) as COLLATERAL_CURRENCY_CD,
									CASE WHEN t.STATUS=GEC_CONSTANTS_PKG.C_BORROW_MANUAL THEN 1 ELSE 0 END as REQUIREMANUAL,o.SOURCE_CD, tc.TRADING_DESK_CD, o.STATUS, o.POSITION_FLAG, UPPER(gat.ASSET_TYPE_DESC) as SECURITY_TYPE,
									o.G1_EXTRACTED_FLAG, o.EXPORT_STATUS, o.HOLDBACK_FLAG, CASE WHEN o.FILLED_QTY > 0 THEN 'Y' ELSE 'N' END as HAS_ALLOCATION,f.BRANCH_CD
						FROM GEC_IM_ORDER o
						JOIN GEC_FUND f ON o.FUND_CD = f.FUND_CD
						JOIN GEC_ASSET_TYPE gat ON o.ASSET_TYPE_ID = gat.ASSET_TYPE_ID
						JOIN GEC_TRADE_COUNTRY tc ON o.TRADE_COUNTRY_CD = tc.TRADE_COUNTRY_CD
						JOIN GEC_BORROW_ORDER_DETAIL detail ON detail.IM_ORDER_ID = o.IM_ORDER_ID
						JOIN GEC_BORROW_ORDER bo ON detail.BORROW_ORDER_ID = bo.BORROW_ORDER_ID 
						JOIN GEC_BORROW_TEMP t ON detail.BORROW_ORDER_ID = t.BORROW_ORDER_ID
						JOIN GEC_ALLOCATION a ON a.BORROW_ID = t.BORROW_ID AND a.IM_ORDER_ID = o.IM_ORDER_ID
    					LEFT JOIN GEC_G1_BOOKING gbk ON f.fund_cd = gbk.fund_cd AND gbk.TRANSACTION_CD = 'G1L' AND gbk.POS_TYPE = 'NSB'
    					LEFT JOIN GEC_G1_COLLATERAL gc ON gc.G1_BOOKING_ID = gbk.G1_BOOKING_ID AND gc.TRADE_COUNTRY_CD = tc.TRADE_COUNTRY_CD						
						WHERE 		
						bo.BORROW_REQUEST_ID = 	p_demand_request_id
						UNION
						SELECT o2.IM_ORDER_ID, o2.ASSET_ID, o2.TRADE_COUNTRY_CD,o2.FUND_CD,o2.SB_BROKER_CD,o2.CUSIP,o2.SHARE_QTY,o2.FILLED_QTY,o2.TRANSACTION_CD,NULL AS REQUEST_ID,
									o2.SHARE_QTY - o2.FILLED_QTY as UNFILLED_QTY,o2.SETTLE_DATE,o2.TICKER,o2.SEDOL,o2.ISIN,o2.QUIK,o2.DESCRIPTION,o2.RATE,f.NSB_COLLATERAL_TYPE, bo.COLLATERAL_CURRENCY_CD,
									0 as REQUIREMANUAL,o2.SOURCE_CD, tc.TRADING_DESK_CD, o2.STATUS, o2.POSITION_FLAG, UPPER(gat.ASSET_TYPE_DESC) as SECURITY_TYPE,
									o.G1_EXTRACTED_FLAG, o.EXPORT_STATUS, o.HOLDBACK_FLAG, CASE WHEN o.FILLED_QTY > 0 THEN 'Y' ELSE 'N' END as HAS_ALLOCATION,f.BRANCH_CD
						FROM GEC_IM_ORDER o2
						JOIN GEC_FUND f ON o2.FUND_CD = f.FUND_CD
						JOIN GEC_TRADE_COUNTRY tc ON o2.TRADE_COUNTRY_CD = tc.TRADE_COUNTRY_CD	
						JOIN GEC_IM_ORDER o ON 	o.MATCHED_ID = o2.IM_ORDER_ID 				
						JOIN GEC_ASSET_TYPE gat ON o.ASSET_TYPE_ID = gat.ASSET_TYPE_ID	
						JOIN GEC_BORROW_ORDER_DETAIL detail ON detail.IM_ORDER_ID = o.IM_ORDER_ID
						JOIN GEC_BORROW_ORDER bo ON detail.BORROW_ORDER_ID = bo.BORROW_ORDER_ID 
    					LEFT JOIN GEC_G1_BOOKING gbk ON f.fund_cd = gbk.fund_cd AND gbk.TRANSACTION_CD = 'G1L' AND gbk.POS_TYPE = 'NSB'
    					LEFT JOIN GEC_G1_COLLATERAL gc ON gc.G1_BOOKING_ID = gbk.G1_BOOKING_ID AND gc.TRADE_COUNTRY_CD = tc.TRADE_COUNTRY_CD																		
						WHERE 
						o.STATUS = 'C' AND -- CANCEL short
						bo.BORROW_REQUEST_ID = p_demand_request_id;
				END IF;                                                                                         
					  
				OPEN p_borrows_cursor FOR
				SELECT t.BORROW_ID as BORROW_ID, NULL as TRADE_DATE, NULL as BORROW_ORDER_ID, NULL as ASSET_ID,NULL as BROKER_CD, NULL as SETTLE_DATE,NULL as COLLATERAL_TYPE, NULL as COLLATERAL_CURRENCY_CD,
					NULL as COLLATERAL_LEVEL,NULL as BORROW_QTY,NULL as RATE,NULL as POSITION_FLAG,NULL as COMMENT_TXT,NULL as TYPE,NULL as STATUS,NULL as CREATED_AT,NULL as CREATED_BY, NULL as TRADE_COUNTRY_CD,
					NULL as UPDATED_AT,NULL as UPDATED_BY,NULL as PRICE, NULL as NO_DEMAND_FLAG, NULL as INTERVENTION_REASON, NULL as RESPONSE_LOG_NUM, NULL as CUSIP, NULL as SEDOL, NULL as ISIN,NULL as QUIK, NULL as TICKER, NULL as ASSET_CODE, NULL as BORROW_REQUEST_TYPE, NULL as UI_ROW_NUMBER, NULL as ERROR_CODE,
					NULL as PREPAY_DATE, NULL as PREPAY_RATE, NULL as RECLAIM_RATE, NULL as OVERSEAS_TAX_PERCENTAGE, NULL as DOMESTIC_TAX_PERCENTAGE, NULL as MINIMUM_FEE,NULL as MINIMUM_FEE_CD, NULL as EQUILEND_MESSAGE_ID,NULL as TERM_DATE,NULL as EXPECTED_RETURN_DATE
				FROM GEC_BORROW_TEMP t;
			END IF;
		END IF;
		
		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END PROCESS_AUTO_ALLOCATION;
	
	
	-- change for non-cash, coll type is not in constraint for single input tab
	PROCEDURE DELETE_MANU_INTERV_BORROWS(
											p_borrow_id IN NUMBER,
											p_asset_id IN NUMBER,
											p_nsb_coll_type IN VARCHAR2,
											p_nsb_coll_code IN VARCHAR2,
											p_branch_code IN VARCHAR2,
											p_settle_date IN NUMBER,
											p_trans_type IN VARCHAR2,
											p_status OUT VARCHAR2,
											p_shorts_cursor OUT SYS_REFCURSOR
										)
	IS
		var_end_settle_date GEC_IM_ORDER.SETTLE_DATE%type;
			
		CURSOR exist_borrow IS
			SELECT BORROW_ID, STATUS
			FROM GEC_BORROW WHERE BORROW_ID = p_borrow_id
			ORDER BY BORROW_ID ASC			
			FOR UPDATE OF STATUS;
			
	    CURSOR exist_allocation IS
			SELECT out_a.ALLOCATION_ID FROM 
			                       GEC_ALLOCATION out_a,
								   GEC_BORROW b, 
								   GEC_IM_ORDER o, 
								   GEC_TRADE_COUNTRY gc,
               					   (SELECT f.FUND_CD, f.BRANCH_CD, tc.TRADE_COUNTRY_CD, NVL(gc.COLLATERAL_CURRENCY_CD, gbk.COLLATERAL_CURRENCY_CD) as COLLATERAL_CURRENCY_CD
               					    FROM GEC_FUND f 
               					    LEFT JOIN GEC_G1_BOOKING gbk ON f.fund_cd = gbk.fund_cd AND gbk.TRANSACTION_CD = 'G1L' AND gbk.POS_TYPE = 'NSB'
               					    LEFT JOIN GEC_G1_COLLATERAL gc ON gc.G1_BOOKING_ID = gbk.G1_BOOKING_ID 
                                    LEFT JOIN GEC_TRADE_COUNTRY tc ON gc.TRADE_COUNTRY_CD = tc.TRADE_COUNTRY_CD
               						) loan_info
						WHERE   b.BORROW_ID = out_a.BORROW_ID AND
								out_a.IM_ORDER_ID = o.IM_ORDER_ID AND
								o.FUND_CD = loan_info.FUND_CD AND
								o.ASSET_ID = p_asset_id AND
								gc.TRADE_COUNTRY_CD = o.TRADE_COUNTRY_CD AND
								o.TRANSACTION_CD = p_trans_type AND
								loan_info.COLLATERAL_CURRENCY_CD = p_nsb_coll_code AND
								loan_info.BRANCH_CD = p_branch_code AND
								o.SETTLE_DATE >= p_settle_date AND
								o.SETTLE_DATE <= var_end_settle_date AND
								b.STATUS = GEC_CONSTANTS_PKG.C_BORROW_MANUAL
						ORDER BY out_a.ALLOCATION_ID ASC
						FOR UPDATE OF out_a.ALLOCATION_ID;
			
	BEGIN
		FOR e_b IN exist_borrow
		LOOP
			IF e_b.STATUS <> GEC_CONSTANTS_PKG.C_BORROW_MANUAL THEN
				p_status := 'OE';
				RETURN;
			END IF;
		END LOOP;
		
		var_end_settle_date := GEC_UTILS_PKG.GET_TPLUSN_NUM(p_settle_date, 5, 'US', 'S');
		
		-- dead lock analyse, lock the whole batch allocation under the same single input tab
		-- set the allocation qty to 0 for the manual intervention borrows in the same single input tab
		FOR e_a IN exist_allocation
		LOOP
			UPDATE GEC_ALLOCATION SET ALLOCATION_QTY = 0 WHERE ALLOCATION_ID = e_a.ALLOCATION_ID;
		END LOOP;				
					
		-- delete the pre-allocation for this manual borrow
		DELETE FROM GEC_ALLOCATION WHERE BORROW_ID = p_borrow_id;		
	
		DELETE FROM GEC_BORROW WHERE BORROW_ID = p_borrow_id;			
										
		OPEN p_shorts_cursor FOR
				SELECT o.IM_ORDER_ID, o.ASSET_ID, o.TRADE_COUNTRY_CD,o.FUND_CD,o.SB_BROKER_CD,o.CUSIP,o.SHARE_QTY,o.FILLED_QTY,o.TRANSACTION_CD,o.REQUEST_ID AS REQUEST_ID,
					o.SHARE_QTY - o.FILLED_QTY as UNFILLED_QTY,o.SETTLE_DATE,o.TICKER,o.SEDOL,o.ISIN,o.QUIK,o.DESCRIPTION,o.RATE,f.NSB_COLLATERAL_TYPE, NVL(gc.COLLATERAL_CURRENCY_CD, gbk.COLLATERAL_CURRENCY_CD) as COLLATERAL_CURRENCY_CD,
					CASE WHEN t.STATUS=GEC_CONSTANTS_PKG.C_BORROW_MANUAL THEN 1 ELSE 0 END as REQUIREMANUAL,o.SOURCE_CD, tc.TRADING_DESK_CD, o.STATUS, o.POSITION_FLAG, UPPER(gat.ASSET_TYPE_DESC) as SECURITY_TYPE,
					o.G1_EXTRACTED_FLAG, o.EXPORT_STATUS, o.HOLDBACK_FLAG, CASE WHEN o.FILLED_QTY > 0 THEN 'Y' ELSE 'N' END as HAS_ALLOCATION,f.BRANCH_CD
				FROM GEC_IM_ORDER o
				JOIN GEC_FUND f ON o.FUND_CD = f.FUND_CD
				JOIN GEC_ASSET_TYPE gat ON o.ASSET_TYPE_ID = gat.ASSET_TYPE_ID
				JOIN GEC_TRADE_COUNTRY tc ON o.TRADE_COUNTRY_CD = tc.TRADE_COUNTRY_CD
				JOIN GEC_ALLOCATION a ON o.IM_ORDER_ID = a.IM_ORDER_ID
				JOIN GEC_BORROW t ON t.BORROW_ID = a.BORROW_ID
    			LEFT JOIN GEC_G1_BOOKING gbk ON f.fund_cd = gbk.fund_cd AND gbk.TRANSACTION_CD = 'G1L' AND gbk.POS_TYPE = 'NSB'
    			LEFT JOIN GEC_G1_COLLATERAL gc ON gc.G1_BOOKING_ID = gbk.G1_BOOKING_ID AND gc.TRADE_COUNTRY_CD = tc.TRADE_COUNTRY_CD				
				WHERE 
						o.ASSET_ID = p_asset_id AND
						NVL(gc.COLLATERAL_CURRENCY_CD, gbk.COLLATERAL_CURRENCY_CD) = p_nsb_coll_code AND
						o.TRANSACTION_CD = p_trans_type AND
						f.BRANCH_CD = p_branch_code AND
						o.SETTLE_DATE >= p_settle_date AND
						o.SETTLE_DATE <= var_end_settle_date AND
						t.STATUS = GEC_CONSTANTS_PKG.C_BORROW_MANUAL;
	END DELETE_MANU_INTERV_BORROWS;
	
	PROCEDURE LOCK_SHORTS(p_demand_request_id NUMBER, p_input_type IN VARCHAR2, p_settle_date IN NUMBER, p_end_settle_date IN NUMBER)
	IS
	CURSOR file_shorts IS
		SELECT o.IM_ORDER_ID
			FROM GEC_BORROW_ORDER bo, GEC_BORROW_ORDER_DETAIL d, GEC_IM_ORDER o
			WHERE bo.BORROW_ORDER_ID = d.BORROW_ORDER_ID AND
					d.IM_ORDER_ID = o.IM_ORDER_ID AND
					bo.BORROW_REQUEST_ID = p_demand_request_id
			ORDER BY o.IM_ORDER_ID ASC
			FOR UPDATE OF o.IM_ORDER_ID;
	
	CURSOR non_file_shorts IS
		SELECT o.IM_ORDER_ID
			FROM GEC_IM_ORDER o
			WHERE o.SETTLE_DATE >= p_settle_date AND
					o.SETTLE_DATE <= p_end_settle_date AND
					o.STATUS IN ('P', 'E', 'B') AND
  		 	  		o.EXPORT_STATUS IN ('N', 'R') AND -- exclude in-flight
				EXISTS(SELECT 1 FROM GEC_BORROW_TEMP t WHERE o.ASSET_ID = t.ASSET_ID)
		ORDER BY o.IM_ORDER_ID ASC
		FOR UPDATE OF o.IM_ORDER_ID;
		
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START('LOCK_SHORTS');
		IF p_input_type = GEC_CONSTANTS_PKG.C_BORROW_FILE THEN -- for file response
			FOR s IN file_shorts
			LOOP
				NULL; -- only for lock shorts
			END LOOP;
		ELSE -- for manual input
			FOR n_s IN non_file_shorts
			LOOP
				NULL; -- only for lock shorts
			END LOOP;
		END IF;
		GEC_LOG_PKG.LOG_PERFORMANCE_END('LOCK_SHORTS');
	END LOCK_SHORTS;
	
	
	PROCEDURE CALC_RUN_COUNT(p_allo_key IN VARCHAR2, p_count OUT NUMBER)
	IS
		var_b_count NUMBER(10);
		var_s_count NUMBER(10);	
	BEGIN
		IF p_allo_key IS NULL THEN -- auto allocation
			SELECT COUNT(1) INTO var_b_count FROM GEC_BORROW_TEMP
			WHERE PROCESS_FLAG = 'Y';
			
			SELECT COUNT(1) INTO var_s_count FROM GEC_IM_ORDER_TEMP;
			p_count := var_b_count + var_s_count;
		ELSE -- reverse auto allocation
			SELECT COUNT(1) INTO var_b_count FROM GEC_BORROW_TEMP
			WHERE R_ALLOC_KEY = p_allo_key;
			
			SELECT COUNT(1) INTO var_s_count FROM GEC_IM_ORDER_TEMP WHERE R_ALLOC_KEY = p_allo_key;
			p_count := var_b_count + var_s_count * 2 + 1;
		END IF;
	END	CALC_RUN_COUNT;
	PROCEDURE FILL_ERROR_RST(p_shorts_cursor OUT SYS_REFCURSOR, p_borrows_cursor OUT SYS_REFCURSOR)
	IS
	BEGIN
		OPEN p_borrows_cursor FOR
				SELECT b.BORROW_ID, b.TRADE_DATE, b.BORROW_ORDER_ID, b.ASSET_ID,NVL(m.BROKER_CD, b.BROKER_CD) as BROKER_CD, b.SETTLE_DATE,b.COLLATERAL_TYPE, b.COLLATERAL_CURRENCY_CD,
					b.COLLATERAL_LEVEL,b.BORROW_QTY,RATE,b.POSITION_FLAG,b.COMMENT_TXT,b.TYPE,b.STATUS,b.CREATED_AT,b.CREATED_BY, b.TRADE_COUNTRY_CD,
					b.UPDATED_AT,b.UPDATED_BY,b.PRICE, b.NO_DEMAND_FLAG, b.INTERVENTION_REASON, b.RESPONSE_LOG_NUM, b.CUSIP, b.SEDOL, b.ISIN,b.QUIK, b.TICKER, b.ASSET_CODE, b.BORROW_REQUEST_TYPE, b.UI_ROW_NUMBER, b.ERROR_CODE,
					b.PREPAY_DATE, b.PREPAY_RATE, b.RECLAIM_RATE * 100 as RECLAIM_RATE, b.OVERSEAS_TAX_PERCENTAGE * 100 as OVERSEAS_TAX_PERCENTAGE, b.DOMESTIC_TAX_PERCENTAGE * 100 as DOMESTIC_TAX_PERCENTAGE, b.MINIMUM_FEE,b.MINIMUM_FEE_CD, b.EQUILEND_MESSAGE_ID,b.TERM_DATE,b.EXPECTED_RETURN_DATE					
				FROM GEC_BORROW_TEMP b, GEC_BROKER_VW m
				WHERE 	b.BROKER_CD = m.DML_BROKER_CD AND
						b.NON_CASH_FLAG = m.NON_CASH_AGENCY_FLAG AND
						b.STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR
				UNION 
				SELECT  b.BORROW_ID, b.TRADE_DATE, b.BORROW_ORDER_ID, b.ASSET_ID, b.BROKER_CD as BROKER_CD, b.SETTLE_DATE,b.COLLATERAL_TYPE, b.COLLATERAL_CURRENCY_CD,
					b.COLLATERAL_LEVEL,b.BORROW_QTY,RATE,b.POSITION_FLAG,b.COMMENT_TXT,b.TYPE,b.STATUS,b.CREATED_AT,b.CREATED_BY, b.TRADE_COUNTRY_CD,
					b.UPDATED_AT,b.UPDATED_BY,b.PRICE, b.NO_DEMAND_FLAG, b.INTERVENTION_REASON, b.RESPONSE_LOG_NUM, b.CUSIP, b.SEDOL, b.ISIN,b.QUIK, b.TICKER, b.ASSET_CODE, b.BORROW_REQUEST_TYPE, b.UI_ROW_NUMBER, b.ERROR_CODE,
					b.PREPAY_DATE, b.PREPAY_RATE, b.RECLAIM_RATE * 100 as RECLAIM_RATE, b.OVERSEAS_TAX_PERCENTAGE * 100 as OVERSEAS_TAX_PERCENTAGE, b.DOMESTIC_TAX_PERCENTAGE * 100 as DOMESTIC_TAX_PERCENTAGE, b.MINIMUM_FEE,b.MINIMUM_FEE_CD, b.EQUILEND_MESSAGE_ID,b.TERM_DATE,b.EXPECTED_RETURN_DATE					
				FROM GEC_BORROW_TEMP b
        		WHERE b.BROKER_CD IS NULL AND b.STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR;
		
		OPEN p_shorts_cursor FOR
				SELECT NULL as IM_ORDER_ID, NULL as ASSET_ID, NULL as TRADE_COUNTRY_CD,NULL as FUND_CD,NULL as SB_BROKER_CD,NULL as CUSIP,NULL as SHARE_QTY,NULL as FILLED_QTY,NULL as TRANSACTION_CD,NULL as REQUEST_ID,
					NULL as UNFILLED_QTY,NULL as SETTLE_DATE,NULL as TICKER,NULL as SEDOL,NULL as ISIN,NULL as QUIK,NULL as DESCRIPTION,NULL as RATE,NULL as NSB_COLLATERAL_TYPE, NULL as COLLATERAL_CURRENCY_CD,
					NULL as REQUIREMANUAL,NULL as SOURCE_CD, NULL as TRADING_DESK_CD, NULL as STATUS, NULL as POSITION_FLAG, NULL as SECURITY_TYPE,
					NULL as G1_EXTRACTED_FLAG, NULL as EXPORT_STATUS, NULL as HOLDBACK_FLAG, NULL as HAS_ALLOCATION, NULL as BRANCH_CD
				FROM DUAL;
	END FILL_ERROR_RST;
	
	PROCEDURE FILL_ALLO_ERROR_RST(p_allo_cursor OUT SYS_REFCURSOR)
	IS
	BEGIN
		OPEN p_allo_cursor FOR
		SELECT IM_ORDER_ID, UI_ROW_NUMBER, ERROR_CODE
		FROM GEC_IM_ORDER_TEMP WHERE ERROR_CODE IS NOT NULL;
	END FILL_ALLO_ERROR_RST;
	
	-- checking BR6, borrows with multi settle dates are allocated to same short
	PROCEDURE CHECK_MULTI_SETTLEDATES(p_error OUT VARCHAR2)
	IS
		-- refer to Question 145
		CURSOR v_multi_dates IS
			SELECT DISTINCT IM_ORDER_ID FROM 
				(SELECT o.IM_ORDER_ID, count(DISTINCT t.SETTLE_DATE) as DATE_COUNT
					FROM GEC_BORROW_TEMP t, GEC_ALLOCATION a, GEC_IM_ORDER o
					WHERE t.BORROW_ID = a.BORROW_ID AND
			  			a.IM_ORDER_ID = o.IM_ORDER_ID AND
			  			t.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB
					GROUP BY  o.IM_ORDER_ID
				 UNION
				 SELECT o.IM_ORDER_ID, count(DISTINCT t.SETTLE_DATE) as DATE_COUNT
					FROM GEC_BORROW_TEMP t, GEC_ALLOCATION a, GEC_IM_ORDER o
					WHERE t.BORROW_ID = a.BORROW_ID AND
			  			a.IM_ORDER_ID = o.IM_ORDER_ID AND
			  			t.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB
					GROUP BY  o.IM_ORDER_ID
				)RST
			WHERE RST.DATE_COUNT > 1;
	BEGIN
		p_error := 'N';
		
		FOR v_o_id IN v_multi_dates
		LOOP
			p_error := 'Y';
			UPDATE GEC_BORROW_TEMP t SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR 
			WHERE EXISTS(SELECT 1 FROM GEC_ALLOCATION a 
						WHERE a.BORROW_ID = t.BORROW_ID AND a.IM_ORDER_ID = v_o_id.IM_ORDER_ID);
		END LOOP;
	END CHECK_MULTI_SETTLEDATES;
	
	-- borrows with multi prepay dates are allocated to same short
	PROCEDURE CHECK_MULTI_PREPAYDATES(p_error OUT VARCHAR2)
	IS
		-- refer to Question 145
		CURSOR v_multi_dates IS
			SELECT DISTINCT IM_ORDER_ID FROM 
				(SELECT o.IM_ORDER_ID, count(DISTINCT t.PREPAY_DATE) as DATE_COUNT
					FROM GEC_BORROW_TEMP t, GEC_ALLOCATION a, GEC_IM_ORDER o
					WHERE t.BORROW_ID = a.BORROW_ID AND
			  			a.IM_ORDER_ID = o.IM_ORDER_ID AND
			  			t.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB
					GROUP BY  o.IM_ORDER_ID
				 UNION
				 SELECT o.IM_ORDER_ID, count(DISTINCT t.PREPAY_DATE) as DATE_COUNT
					FROM GEC_BORROW_TEMP t, GEC_ALLOCATION a, GEC_IM_ORDER o
					WHERE t.BORROW_ID = a.BORROW_ID AND
			  			a.IM_ORDER_ID = o.IM_ORDER_ID AND
			  			t.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB
					GROUP BY  o.IM_ORDER_ID
				)RST
			WHERE RST.DATE_COUNT > 1;
	BEGIN
		p_error := 'N';
		
		FOR v_o_id IN v_multi_dates
		LOOP
			p_error := 'Y';
			UPDATE GEC_BORROW_TEMP t SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR 
			WHERE EXISTS(SELECT 1 FROM GEC_ALLOCATION a 
						WHERE a.BORROW_ID = t.BORROW_ID AND a.IM_ORDER_ID = v_o_id.IM_ORDER_ID);
		END LOOP;
	END CHECK_MULTI_PREPAYDATES;	
	
	-- rollback the short fill qty for manual borrows
	PROCEDURE SET_SHORT_QTY_FOR_M
	IS
		CURSOR manual_filled IS
			SELECT a.IM_ORDER_ID, SUM(a.ALLOCATION_QTY) as M_FILLED_QTY 
			FROM GEC_ALLOCATION a, GEC_BORROW_TEMP t
			WHERE a.BORROW_ID = t.BORROW_ID AND
			  	 	t.STATUS = GEC_CONSTANTS_PKG.C_BORROW_MANUAL
			GROUP BY a.IM_ORDER_ID;
	BEGIN
		FOR m_f IN manual_filled
		LOOP
			UPDATE GEC_IM_ORDER SET FILLED_QTY = FILLED_QTY - m_f.M_FILLED_QTY , UPDATED_AT= sysdate WHERE IM_ORDER_ID = m_f.IM_ORDER_ID;
		END LOOP;
	END SET_SHORT_QTY_FOR_M;
	
	
	-- generate fee for sp borrows(from locates)
	PROCEDURE GENERATE_LOCATE_FEE(p_user_id IN VARCHAR2)
	IS
		var_loan_id GEC_LOAN.LOAN_ID%type;
		var_asset_id GEC_LOAN.ASSET_ID%type;
		var_request_type GEC_BORROW_REQUEST.BORROW_REQUEST_TYPE%type;
		var_fund GEC_IM_ORDER.FUND_CD%type;
		var_fee GEC_ALLOCATION.RATE%type;
		var_temp_fee GEC_ALLOCATION.RATE%type;
		var_order_id GEC_IM_ORDER.IM_ORDER_ID%type;
		var_trade_country GEC_TRADE_COUNTRY.TRADE_COUNTRY_CD%type;
		
		CURSOR us_sp_borrows IS
			SELECT a.ALLOCATION_ID, a.IM_ORDER_ID
			FROM GEC_BORROW_TEMP t, GEC_ALLOCATION a, GEC_IM_ORDER o
			WHERE t.BORROW_ID = a.BORROW_ID AND 
					a.IM_ORDER_ID = o.IM_ORDER_ID AND 
					(t.STATUS = GEC_CONSTANTS_PKG.C_BORROW_MANUAL OR (t.CONTINGENTY_INTERVENTION_FLAG = 'Y' AND p_user_id = GEC_CONSTANTS_PKG.C_SYSTEM)) AND
					t.POSITION_FLAG = 'SP' AND
					t.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND
					t.TRADE_COUNTRY_CD IN (GEC_CONSTANTS_PKG.C_COUNTRY_US, GEC_CONSTANTS_PKG.C_COUNTRY_CA);
	
		-- BR20. For Non US (except for CA), the allocation NSB fee should be populated from the locate response indicative fee for that security by that IM for that trade date(locate date) for both GC and SP borrows.						
		CURSOR non_us_borrows IS
			SELECT a.ALLOCATION_ID, a.IM_ORDER_ID, t.TRADE_COUNTRY_CD, t.BORROW_ID, t.ASSET_ID
			FROM GEC_BORROW_TEMP t, GEC_ALLOCATION a, GEC_IM_ORDER o
			WHERE t.BORROW_ID = a.BORROW_ID AND 
					a.IM_ORDER_ID = o.IM_ORDER_ID AND 
					t.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND
					t.TRADE_COUNTRY_CD NOT IN (GEC_CONSTANTS_PKG.C_COUNTRY_US, GEC_CONSTANTS_PKG.C_COUNTRY_CA);
					
			
		CURSOR locate_fees IS
			SELECT l.INDICATIVE_RATE, sp.GC_RATE
			FROM GEC_IM_ORDER o, GEC_LOCATE_PREBORROW l, GEC_FUND f, GEC_STRATEGY_PROFILE sp
			WHERE l.STRATEGY_ID = sp.STRATEGY_ID AND
				  l.TRADE_COUNTRY_CD = sp.TRADE_COUNTRY_CD AND
				  o.ASSET_ID = l.ASSET_ID AND
				  o.FUND_CD = f.FUND_CD AND
				  f.STRATEGY_ID = l.STRATEGY_ID AND
				  o.TRADE_DATE = l.BUSINESS_DATE AND 
				  l.STATUS IN ('P', 'F', 'E', 'H') AND -- exclude error/cancelled locates
				  l.TRANSACTION_CD = 'LOCATE' AND -- exclude pre-borrow
				  o.IM_ORDER_ID = var_order_id;
		-- BR20.1. For AU, it should map to preborrow for the indicative fee. 				  
		CURSOR preborrow_fees IS
			SELECT l.INDICATIVE_RATE, sp.GC_RATE
			FROM GEC_IM_ORDER o, GEC_LOCATE_PREBORROW l, GEC_FUND f, GEC_STRATEGY_PROFILE sp
			WHERE l.STRATEGY_ID = sp.STRATEGY_ID AND
				  l.TRADE_COUNTRY_CD = sp.TRADE_COUNTRY_CD AND
				  o.ASSET_ID = l.ASSET_ID AND
				  o.FUND_CD = f.FUND_CD AND
				  f.STRATEGY_ID = l.STRATEGY_ID AND
				  o.TRADE_DATE = l.BUSINESS_DATE AND 
				  l.STATUS IN ('P', 'F', 'E', 'H') AND -- exclude error/cancelled locates
				  l.TRANSACTION_CD = 'PREBORROW' AND -- exclude pre-borrow
				  o.IM_ORDER_ID = var_order_id;				  
		
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START('GENERATE LOCATE FEE');	
		-- update fee for SP(Non-SB) borrows
		FOR sp_b IN us_sp_borrows
		LOOP
			var_fee := NULL;
			var_temp_fee := NULL;
			var_order_id := sp_b.IM_ORDER_ID;
				
			FOR l_f IN locate_fees
			LOOP
				IF l_f.INDICATIVE_RATE = 'GC' THEN
					IF var_fee IS NULL OR (l_f.GC_RATE IS NOT NULL AND l_f.GC_RATE>var_fee) THEN
						var_fee := l_f.GC_RATE;
					END IF;
				ELSE
					BEGIN
						var_temp_fee := TO_NUMBER(l_f.INDICATIVE_RATE);
					EXCEPTION WHEN OTHERS THEN
						var_temp_fee := NULL;
					END;
					IF var_fee IS NULL OR (var_temp_fee IS NOT NULL AND var_temp_fee > var_fee) THEN
						var_fee := var_temp_fee;
					END IF;
				END IF;
			END LOOP;	
			
  			UPDATE GEC_ALLOCATION SET RATE = var_fee WHERE ALLOCATION_ID = sp_b.ALLOCATION_ID;
		END LOOP;
		-- if can't get fee for non_us nsb, then go to manual intervention
		FOR nub IN non_us_borrows
		LOOP
			var_fee := NULL;
			var_temp_fee := NULL;
			var_order_id := nub.IM_ORDER_ID;
			var_trade_country := nub.TRADE_COUNTRY_CD;	
			
			IF  var_trade_country = GEC_CONSTANTS_PKG.C_COUNTRY_AU THEN
				FOR l_f IN preborrow_fees
				LOOP
					IF l_f.INDICATIVE_RATE = 'GC' THEN
						IF var_fee IS NULL OR (l_f.GC_RATE IS NOT NULL AND l_f.GC_RATE>var_fee) THEN
							var_fee := l_f.GC_RATE;
						END IF;
					ELSE
						BEGIN
							var_temp_fee := TO_NUMBER(l_f.INDICATIVE_RATE);
						EXCEPTION WHEN OTHERS THEN
							var_temp_fee := NULL;
						END;
						IF var_fee IS NULL OR (var_temp_fee IS NOT NULL AND var_temp_fee > var_fee) THEN
							var_fee := var_temp_fee;
						END IF;
					END IF;
				END LOOP;
			ELSIF var_trade_country <> GEC_CONSTANTS_PKG.C_COUNTRY_AU THEN			
				FOR l_f IN locate_fees
				LOOP
					IF l_f.INDICATIVE_RATE = 'GC' THEN
						IF var_fee IS NULL OR (l_f.GC_RATE IS NOT NULL AND l_f.GC_RATE>var_fee) THEN
							var_fee := l_f.GC_RATE;
						END IF;
					ELSE
						BEGIN
							var_temp_fee := TO_NUMBER(l_f.INDICATIVE_RATE);
						EXCEPTION WHEN OTHERS THEN
							var_temp_fee := NULL;
						END;
						IF var_fee IS NULL OR (var_temp_fee IS NOT NULL AND var_temp_fee > var_fee) THEN
							var_fee := var_temp_fee;
						END IF;
					END IF;
				END LOOP;	
			END IF;
			
			IF var_fee IS NULL THEN
				IF p_user_id <> GEC_CONSTANTS_PKG.C_SYSTEM THEN
					UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_MANUAL, INTERVENTION_REASON = GEC_CONSTANTS_PKG.C_BORROW_NO_LOCATE_FEE WHERE ASSET_ID = nub.ASSET_ID;
				ELSE
					UPDATE GEC_BORROW_TEMP SET CONTINGENTY_INTERVENTION_FLAG = 'Y' WHERE ASSET_ID = nub.ASSET_ID;
				END IF;
			END IF;	
				
  			UPDATE GEC_ALLOCATION SET RATE = var_fee WHERE ALLOCATION_ID = nub.ALLOCATION_ID;

			GEC_LOG_PKG.LOG_PERFORMANCE_END('GENERATE LOCATE FEE');  			
		END LOOP;		
		
	END GENERATE_LOCATE_FEE;
	
	PROCEDURE GET_FEE_QTY_CHANGE(fund_cd IN VARCHAR ,trade_country_cd IN VARCHAR,borrow_request_type IN VARCHAR,position_flag IN VARCHAR,order_id IN NUMBER,fee OUT NUMBER)
  	IS
    var_fee GEC_ALLOCATION.RATE%type;
    v_error_code VARCHAR2(10);
    var_temp_fee GEC_ALLOCATION.RATE%type;
    CURSOR locate_fees IS
        SELECT l.INDICATIVE_RATE, sp.GC_RATE
        FROM GEC_IM_ORDER o, GEC_LOCATE_PREBORROW l, GEC_FUND f, GEC_STRATEGY_PROFILE sp
        WHERE l.STRATEGY_ID = sp.STRATEGY_ID AND
            l.TRADE_COUNTRY_CD = sp.TRADE_COUNTRY_CD AND
            o.ASSET_ID = l.ASSET_ID AND
            o.FUND_CD = f.FUND_CD AND
            f.STRATEGY_ID = l.STRATEGY_ID AND
            o.TRADE_DATE = l.BUSINESS_DATE AND 
            l.STATUS IN ('P', 'F', 'E', 'H') AND -- exclude error/cancelled locates
            l.TRANSACTION_CD = 'LOCATE' AND -- exclude pre-borrow
            o.IM_ORDER_ID = order_id;
      -- BR20.1. For AU, it should map to preborrow for the indicative fee. 				  
      CURSOR preborrow_fees IS
        SELECT l.INDICATIVE_RATE, sp.GC_RATE
        FROM GEC_IM_ORDER o, GEC_LOCATE_PREBORROW l, GEC_FUND f, GEC_STRATEGY_PROFILE sp
        WHERE l.STRATEGY_ID = sp.STRATEGY_ID AND
            l.TRADE_COUNTRY_CD = sp.TRADE_COUNTRY_CD AND
            o.ASSET_ID = l.ASSET_ID AND
            o.FUND_CD = f.FUND_CD AND
            f.STRATEGY_ID = l.STRATEGY_ID AND
            o.TRADE_DATE = l.BUSINESS_DATE AND 
            l.STATUS IN ('P', 'F', 'E', 'H') AND -- exclude error/cancelled locates
            l.TRANSACTION_CD = 'PREBORROW' AND -- exclude pre-borrow
            o.IM_ORDER_ID = order_id;				  
  	BEGIN
    	IF trade_country_cd IN (GEC_CONSTANTS_PKG.C_COUNTRY_US, GEC_CONSTANTS_PKG.C_COUNTRY_CA) AND borrow_request_type <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND position_flag  = 'SP'  THEN
      		var_fee := NULL;
      		var_temp_fee := NULL;
      		FOR l_f IN locate_fees
			LOOP
				IF l_f.INDICATIVE_RATE = 'GC' THEN
					IF var_fee IS NULL OR (l_f.GC_RATE IS NOT NULL AND l_f.GC_RATE>var_fee) THEN
						var_fee := l_f.GC_RATE;
					END IF;
				ELSE
					BEGIN
						var_temp_fee := TO_NUMBER(l_f.INDICATIVE_RATE);
					EXCEPTION WHEN OTHERS THEN
						var_temp_fee := NULL;
					END;
					IF var_fee IS NULL OR (var_temp_fee IS NOT NULL AND var_temp_fee > var_fee) THEN
						var_fee := var_temp_fee;
					END IF;
				END IF;
			END LOOP;	
    	END IF;
    	
   	 	IF trade_country_cd NOT IN (GEC_CONSTANTS_PKG.C_COUNTRY_US, GEC_CONSTANTS_PKG.C_COUNTRY_CA) AND borrow_request_type <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB THEN
      		var_fee := NULL;
      		var_temp_fee := NULL;
      		IF  trade_country_cd = GEC_CONSTANTS_PKG.C_COUNTRY_AU THEN
				FOR l_f IN preborrow_fees
				LOOP
					IF l_f.INDICATIVE_RATE = 'GC' THEN
						IF var_fee IS NULL OR (l_f.GC_RATE IS NOT NULL AND l_f.GC_RATE>var_fee) THEN
							var_fee := l_f.GC_RATE;
						END IF;
					ELSE
						BEGIN
							var_temp_fee := TO_NUMBER(l_f.INDICATIVE_RATE);
						EXCEPTION WHEN OTHERS THEN
							var_temp_fee := NULL;
						END;
						IF var_fee IS NULL OR (var_temp_fee IS NOT NULL AND var_temp_fee > var_fee) THEN
							var_fee := var_temp_fee;
						END IF;
					END IF;
				END LOOP;
			ELSIF trade_country_cd <> GEC_CONSTANTS_PKG.C_COUNTRY_AU THEN			
				FOR l_f IN locate_fees
				LOOP
					IF l_f.INDICATIVE_RATE = 'GC' THEN
						IF var_fee IS NULL OR (l_f.GC_RATE IS NOT NULL AND l_f.GC_RATE>var_fee) THEN
							var_fee := l_f.GC_RATE;
						END IF;
					ELSE
						BEGIN
							var_temp_fee := TO_NUMBER(l_f.INDICATIVE_RATE);
						EXCEPTION WHEN OTHERS THEN
							var_temp_fee := NULL;
						END;
						IF var_fee IS NULL OR (var_temp_fee IS NOT NULL AND var_temp_fee > var_fee) THEN
							var_fee := var_temp_fee;
						END IF;
					END IF;
				END LOOP;	
			END IF;
    	END IF;
    	
    	IF trade_country_cd IN (GEC_CONSTANTS_PKG.C_COUNTRY_US, GEC_CONSTANTS_PKG.C_COUNTRY_CA) AND borrow_request_type = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB THEN
      		var_fee := NULL;
      		var_fee := GET_LOAN_RATE(borrow_request_type, fund_cd, trade_country_cd, NULL, v_error_code);
    	END IF;
    	IF trade_country_cd IN (GEC_CONSTANTS_PKG.C_COUNTRY_US, GEC_CONSTANTS_PKG.C_COUNTRY_CA) AND borrow_request_type <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND position_flag  = 'GC'  THEN
      		var_fee := NULL;
      		var_fee := GET_LOAN_RATE(borrow_request_type, fund_cd, trade_country_cd, NULL, v_error_code);
    	END IF;
    	
    	IF trade_country_cd NOT IN (GEC_CONSTANTS_PKG.C_COUNTRY_US, GEC_CONSTANTS_PKG.C_COUNTRY_CA) AND borrow_request_type = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB THEN
      		var_fee := NULL;
      		var_fee := GET_LOAN_RATE(borrow_request_type, fund_cd, trade_country_cd, NULL, v_error_code);
    	END IF;
    	fee := var_fee;
    	
  	END GET_FEE_QTY_CHANGE;
	
	PROCEDURE PREPARE_SHORTS_FOR_FILE(p_borrow_file_type IN VARCHAR, p_asset_id IN NUMBER, p_borrow_settle_date IN NUMBER, p_borrow_order_id IN NUMBER, p_agency_code IN VARCHAR, p_branch_cd IN VARCHAR, p_trade_country IN VARCHAR, p_borrow_request_type IN VARCHAR)
	IS
	
	var_sb_coll_code  GEC_FUND.COLLATERAL_CURRENCY_CD%type;
	var_nsb_coll_code GEC_FUND.COLLATERAL_CURRENCY_CD%type;	
	var_sb_coll_type  GEC_FUND.SB_COLLATERAL_TYPE%type;
	var_nsb_coll_type GEC_FUND.NSB_COLLATERAL_TYPE%type;
	
	-- branch 'BOS' borrow can allocated to branch 'BOS' shorts 
  	--zwh CURSOR orders_bos_branch IS
  	--		SELECT o.IM_ORDER_ID, o.ASSET_ID, o.STATUS, o.SHARE_QTY - o.FILLED_QTY as UNFILLED_QTY,f.DML_SB_BROKER AS DML_SB_BROKER, f.DML_NSB_BROKER AS DML_NSB_BROKER, f.SB_COLLATERAL_TYPE AS SB_COLLATERAL_TYPE, f.NSB_COLLATERAL_TYPE AS NSB_COLLATERAL_TYPE, o.SETTLE_DATE, o.FUND_CD, f.BRANCH_CD, o.HOLDBACK_FLAG
  	--	 	FROM  GEC_BORROW_ORDER_DETAIL d, GEC_IM_ORDER o, GEC_FUND f
  	--	 	WHERE d.IM_ORDER_ID = o.IM_ORDER_ID AND
  	--	 	   o.FUND_CD = f.FUND_CD AND
  	--	 	   o.SHARE_QTY > o.FILLED_QTY AND
  	--	 	   (o.TRANSACTION_CD = GEC_CONSTANTS_PKG.C_SHORT OR (o.TRANSACTION_CD = GEC_CONSTANTS_PKG.C_SB_SHORT AND p_borrow_request_type = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND p_borrow_file_type = GEC_CONSTANTS_PKG.C_SBO_REQUEST)) AND
  	--	 	   o.EXPORT_STATUS <> 'C' AND
  	--	 	   o.ASSET_ID = p_asset_id AND
  	--	 	   f.BRANCH_CD IN (SELECT ALLOCATE_DEMAND_BRANCH FROM GEC_ALLOCATION_RULE WHERE ALLOCATE_BORROW_BRANCH= p_branch_cd) AND
  	--	 	   d.BORROW_ORDER_ID = p_borrow_order_id;
	-- branch 'TOR' borrow can allocated to branch 'TOR' and 'BOS' shorts  		 	
  	CURSOR orders_tor_branch IS
  			SELECT o.IM_ORDER_ID, o.ASSET_ID, o.STATUS, o.SHARE_QTY - o.FILLED_QTY as UNFILLED_QTY,f.DML_SB_BROKER AS DML_SB_BROKER, f.DML_NSB_BROKER AS DML_NSB_BROKER, f.SB_COLLATERAL_TYPE AS SB_COLLATERAL_TYPE, f.NSB_COLLATERAL_TYPE AS NSB_COLLATERAL_TYPE, f.COLLATERAL_CURRENCY_CD AS COLLATERAL_CURRENCY_CD, o.SETTLE_DATE, o.FUND_CD, f.BRANCH_CD, o.HOLDBACK_FLAG
  		 	FROM  GEC_BORROW_ORDER_DETAIL d, GEC_IM_ORDER o, GEC_FUND f
  		 	WHERE d.IM_ORDER_ID = o.IM_ORDER_ID AND
  		 	   o.FUND_CD = f.FUND_CD AND
  		 	   o.SHARE_QTY > o.FILLED_QTY AND
  		 	   (o.TRANSACTION_CD = GEC_CONSTANTS_PKG.C_SHORT OR (o.TRANSACTION_CD = GEC_CONSTANTS_PKG.C_SB_SHORT AND p_borrow_request_type = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND p_borrow_file_type = GEC_CONSTANTS_PKG.C_SBO_REQUEST)) AND
  		 	   o.EXPORT_STATUS <> 'C' AND
  		 	   o.ASSET_ID = p_asset_id AND
  		 	   --f.BRANCH_CD IN (SELECT ALLOCATE_DEMAND_BRANCH FROM GEC_ALLOCATION_RULE WHERE ALLOCATE_BORROW_BRANCH= p_branch_cd) AND
  		 	   d.BORROW_ORDER_ID = p_borrow_order_id;  	
	BEGIN
  			--IF p_branch_cd IS NOT NULL AND (p_branch_cd = 'TOR' OR p_branch_cd = GEC_CONSTANTS_PKG.C_BRANCH_GMBH) THEN
				FOR ord IN orders_tor_branch
				LOOP
					-- prepare coll type, coll code
					GET_COLL_CODE_TYPE_INFO(p_trade_country, ord.FUND_CD, var_sb_coll_type, var_nsb_coll_type, var_sb_coll_code, var_nsb_coll_code);
					
					-- prepare fund coll type for non cash matching
					SELECT f.SB_COLLATERAL_TYPE, f.NSB_COLLATERAL_TYPE INTO var_sb_coll_type, var_nsb_coll_type FROM GEC_FUND f WHERE f.FUND_CD = ord.FUND_CD;
					
					INSERT INTO GEC_IM_ORDER_TEMP(
						IM_ORDER_ID,
						ASSET_ID,
						STATUS,
						UNFILLED_QTY,  
						SB_BROKER_CD,
						NSB_BROKER_CD,
						SB_COLLATERAL_TYPE,
						NSB_COLLATERAL_TYPE,
						SB_COLLATERAL_CURRENCY_CD,
						NSB_COLLATERAL_CURRENCY_CD,						
						SETTLE_DATE,
						FUND_CD,
						BRANCH_CD,
						HOLDBACK_FLAG
	  				)VALUES(
  						ord.IM_ORDER_ID, 
  						ord.ASSET_ID, 
  						ord.STATUS, 
  						ord.UNFILLED_QTY,
  						ord.DML_SB_BROKER, 
  						ord.DML_NSB_BROKER, 
		 				var_sb_coll_type, 
  						var_nsb_coll_type, 
  						var_sb_coll_code, 
  						var_nsb_coll_code,
  						ord.SETTLE_DATE, 
  						ord.FUND_CD,
	  					ord.BRANCH_CD,
	  					ord.HOLDBACK_FLAG
  					);
  				END LOOP; 			
  			-- zwh ELSE	
  			--	IF p_branch_cd IS NOT NULL  THEN
			--		FOR ord IN orders_bos_branch
			--		LOOP
			--			-- prepare coll type, coll code					
			--			GET_COLL_CODE_TYPE_INFO(p_trade_country, ord.FUND_CD, var_sb_coll_type, var_nsb_coll_type, var_sb_coll_code, var_nsb_coll_code);	
			--			
			--			-- prepare fund coll type for non cash matching
			--			SELECT f.SB_COLLATERAL_TYPE, f.NSB_COLLATERAL_TYPE INTO var_sb_coll_type, var_nsb_coll_type FROM GEC_FUND f WHERE f.FUND_CD = ord.FUND_CD;							
			--								
			--			INSERT INTO GEC_IM_ORDER_TEMP(
			--				IM_ORDER_ID,
			--				ASSET_ID,
			--				STATUS,
			--				UNFILLED_QTY,  
			--				SB_BROKER_CD,
			--				NSB_BROKER_CD,
			--				SB_COLLATERAL_TYPE,
			--				NSB_COLLATERAL_TYPE,
			--				SB_COLLATERAL_CURRENCY_CD,
			--				NSB_COLLATERAL_CURRENCY_CD,	
			--				SETTLE_DATE,
			--				FUND_CD,
			--				BRANCH_CD,
			--				HOLDBACK_FLAG
	  		--			)VALUES(
  			--				ord.IM_ORDER_ID, 
  			--				ord.ASSET_ID, 
  			--				ord.STATUS, 
  			--				ord.UNFILLED_QTY,
  			--				ord.DML_SB_BROKER, 
  			--				ord.DML_NSB_BROKER, 
		 	--				var_sb_coll_type, 
  			--				var_nsb_coll_type, 
  			--				var_sb_coll_code, 
  			--				var_nsb_coll_code,
  			--				ord.SETTLE_DATE, 
  			--				ord.FUND_CD,
	  		--				ord.BRANCH_CD,
	  		--				ord.HOLDBACK_FLAG
  			--			);
  			--		END LOOP; 			
			--	END IF;  					
  			--END IF; 	
  			
			IF p_borrow_file_type IS NOT NULL AND p_borrow_file_type = 'NC' THEN
				UPDATE  GEC_IM_ORDER_TEMP SET HOLDBACK_FLAG = 'C';
			END IF;
					
	END PREPARE_SHORTS_FOR_FILE;
	
	
	PROCEDURE PREPARE_SHORTS_FOR_BATCH(p_asset_id IN NUMBER, p_settle_date IN NUMBER, p_end_settle_date IN NUMBER, p_agency_code IN VARCHAR, p_request_type IN VARCHAR, p_branch_cd IN VARCHAR, p_trade_country IN VARCHAR)
	IS
	
		var_sb_coll_code  GEC_FUND.COLLATERAL_CURRENCY_CD%type;
		var_nsb_coll_code GEC_FUND.COLLATERAL_CURRENCY_CD%type;	
		var_sb_coll_type  GEC_FUND.SB_COLLATERAL_TYPE%type;
		var_nsb_coll_type GEC_FUND.NSB_COLLATERAL_TYPE%type;
		
		-- branch 'BOS' borrow can allocated to branch 'BOS' shorts 	
		--zwh CURSOR orders_bos_branch IS
		--	SELECT o.IM_ORDER_ID, o.ASSET_ID, o.STATUS, o.SHARE_QTY-o.FILLED_QTY as UNFILLED_QTY,f.DML_SB_BROKER AS DML_SB_BROKER, f.DML_NSB_BROKER AS DML_NSB_BROKER, f.SB_COLLATERAL_TYPE AS SB_COLLATERAL_TYPE, f.NSB_COLLATERAL_TYPE AS NSB_COLLATERAL_TYPE, f.COLLATERAL_CURRENCY_CD AS COLLATERAL_CURRENCY_CD, o.SETTLE_DATE, o.FUND_CD, f.BRANCH_CD, o.HOLDBACK_FLAG
  		--	FROM GEC_IM_ORDER_VW o, GEC_FUND f
  		-- 	WHERE o.FUND_CD = f.FUND_CD AND
  		-- 	   o.ASSET_ID = p_asset_id AND
  		-- 	   o.SETTLE_DATE >= p_settle_date AND
  		-- 	   o.SETTLE_DATE <= p_end_settle_date AND
  		-- 	   o.STATUS IN ('P', 'E', 'B') AND
  		-- 	   o.EXPORT_STATUS IN ('N', 'R') AND -- in new, response, not in-flight
  		-- 	   o.SHARE_QTY > o.FILLED_QTY AND
  		-- 	   o.TRANSACTION_CD = 'SHORT' AND
  		-- 	   o.HOLDBACK_FLAG IN ('N', 'C') AND  -- not holdback or holdback for CMO
  		-- 	   f.BRANCH_CD IN ('BOS',GEC_CONSTANTS_PKG.C_BRANCH_GMBH); 
		-- branch 'TOR' borrow can allocated to branch 'TOR' and 'BOS' shorts  	  		 	   
		CURSOR orders_tor_branch IS
			SELECT o.IM_ORDER_ID, o.ASSET_ID, o.STATUS, o.SHARE_QTY-o.FILLED_QTY as UNFILLED_QTY,f.DML_SB_BROKER AS DML_SB_BROKER, f.DML_NSB_BROKER AS DML_NSB_BROKER, f.SB_COLLATERAL_TYPE AS SB_COLLATERAL_TYPE, f.NSB_COLLATERAL_TYPE AS NSB_COLLATERAL_TYPE, f.COLLATERAL_CURRENCY_CD AS COLLATERAL_CURRENCY_CD, o.SETTLE_DATE, o.FUND_CD, f.BRANCH_CD, o.HOLDBACK_FLAG
  			FROM GEC_IM_ORDER_VW o, GEC_FUND f
  		 	WHERE o.FUND_CD = f.FUND_CD AND
  		 	   o.ASSET_ID = p_asset_id AND
  		 	   o.SETTLE_DATE >= p_settle_date AND
  		 	   o.SETTLE_DATE <= p_end_settle_date AND
  		 	   o.STATUS IN ('P', 'E', 'B') AND
  		 	   o.EXPORT_STATUS IN ('N', 'R') AND -- in new, response, not in-flight
  		 	   o.SHARE_QTY > o.FILLED_QTY AND
  		 	   o.TRANSACTION_CD = 'SHORT' AND
  		 	   o.HOLDBACK_FLAG IN ('N', 'C');-- AND  -- not holdback or holdback for CMO
  		 	   --f.BRANCH_CD IN (SELECT ALLOCATE_DEMAND_BRANCH FROM GEC_ALLOCATION_RULE WHERE ALLOCATE_BORROW_BRANCH= p_branch_cd);   		 	   
  		 	   
	BEGIN

		--IF p_branch_cd IS NOT NULL AND (p_branch_cd = 'TOR' OR p_branch_cd=GEC_CONSTANTS_PKG.C_BRANCH_GMBH) THEN
			FOR ord IN orders_tor_branch
			LOOP
				-- prepare coll type, coll code					
				GET_COLL_CODE_TYPE_INFO(p_trade_country, ord.FUND_CD, var_sb_coll_type, var_nsb_coll_type, var_sb_coll_code, var_nsb_coll_code);	
				-- prepare fund coll type for non cash matching
				SELECT f.SB_COLLATERAL_TYPE, f.NSB_COLLATERAL_TYPE INTO var_sb_coll_type, var_nsb_coll_type FROM GEC_FUND f WHERE f.FUND_CD = ord.FUND_CD;
						
				INSERT INTO GEC_IM_ORDER_TEMP(
					IM_ORDER_ID,
	  				ASSET_ID,
	  				STATUS,
	  				UNFILLED_QTY,
	  				SB_BROKER_CD,
	  				NSB_BROKER_CD,
					SB_COLLATERAL_TYPE,
					NSB_COLLATERAL_TYPE,
					SB_COLLATERAL_CURRENCY_CD,
					NSB_COLLATERAL_CURRENCY_CD,	
	  				SETTLE_DATE,
	  				FUND_CD,
	  				BRANCH_CD,
	  				HOLDBACK_FLAG
	  			)VALUES(
	  				ord.IM_ORDER_ID, 
	  				ord.ASSET_ID, 
	  				ord.STATUS, 
	  				ord.UNFILLED_QTY,
	  				ord.DML_SB_BROKER, 
	  				ord.DML_NSB_BROKER, 
		 			var_sb_coll_type, 
  					var_nsb_coll_type, 
  					var_sb_coll_code, 
  					var_nsb_coll_code,
	  				ord.SETTLE_DATE, 
	  				ord.FUND_CD,
	  				ord.BRANCH_CD,
	  				ord.HOLDBACK_FLAG
	  			);
  			END LOOP;
  		 -- zwh ELSE
  		 --	IF p_branch_cd IS NOT NULL  THEN  		 
  		 --		FOR ord IN orders_bos_branch
  		 --		LOOP
					-- prepare coll type, coll code					
		 --			GET_COLL_CODE_TYPE_INFO(p_trade_country, ord.FUND_CD, var_sb_coll_type, var_nsb_coll_type, var_sb_coll_code, var_nsb_coll_code);		 	
					-- prepare fund coll type for non cash matching
		--			SELECT f.SB_COLLATERAL_TYPE, f.NSB_COLLATERAL_TYPE INTO var_sb_coll_type, var_nsb_coll_type FROM GEC_FUND f WHERE f.FUND_CD = ord.FUND_CD;					
						
		--  		 	INSERT INTO GEC_IM_ORDER_TEMP(
		--				IM_ORDER_ID,
	  	--				ASSET_ID,
	  	--				STATUS,
	  	--				UNFILLED_QTY,
	  	--				SB_BROKER_CD,
		-- 				NSB_BROKER_CD,
		--				SB_COLLATERAL_TYPE,
		--				NSB_COLLATERAL_TYPE,		  				
		--				SB_COLLATERAL_CURRENCY_CD,
		--				NSB_COLLATERAL_CURRENCY_CD,	
		-- 				SETTLE_DATE,
		-- 				FUND_CD,
	  	--				BRANCH_CD,
	  	--				HOLDBACK_FLAG
		-- 			)VALUES(
		--  				ord.IM_ORDER_ID, 
	  	--				ord.ASSET_ID, 
	  	--				ord.STATUS, 
	  	--				ord.UNFILLED_QTY,
	  	--				ord.DML_SB_BROKER, 
		-- 				ord.DML_NSB_BROKER, 
		-- 				var_sb_coll_type, 
  		--				var_nsb_coll_type, 
  		--				var_sb_coll_code, 
	  	--				var_nsb_coll_code,
	  	--				ord.SETTLE_DATE, 
		-- 				ord.FUND_CD,
		-- 				ord.BRANCH_CD,
	  	--				ord.HOLDBACK_FLAG
	  	--			);
		-- 		END LOOP;
  		-- 	END IF;
  		-- END IF;
		
	END PREPARE_SHORTS_FOR_BATCH;
	
	
	PROCEDURE PREPARE_SHORTS_FOR_SINGLE(p_asset_id IN NUMBER, p_settle_date IN NUMBER, p_end_settle_date IN NUMBER, p_nsb_coll_type IN VARCHAR2, p_nsb_coll_code IN VARCHAR, p_trans_type IN VARCHAR, p_agency_code IN VARCHAR, p_request_type IN VARCHAR, p_branch_cd IN VARCHAR, p_borrow_branch_cd IN VARCHAR, p_trade_country IN VARCHAR)
	IS	
		var_sb_coll_code  GEC_FUND.COLLATERAL_CURRENCY_CD%type;
		var_nsb_coll_code GEC_FUND.COLLATERAL_CURRENCY_CD%type;	
		var_sb_coll_type  GEC_FUND.SB_COLLATERAL_TYPE%type;
		var_nsb_coll_type GEC_FUND.NSB_COLLATERAL_TYPE%type;
		
		--zwh CURSOR orders_bos_branch IS
		--	SELECT o.IM_ORDER_ID, o.ASSET_ID, o.STATUS, o.SHARE_QTY-o.FILLED_QTY as UNFILLED_QTY,f.DML_SB_BROKER AS DML_SB_BROKER, f.DML_NSB_BROKER AS DML_NSB_BROKER, f.SB_COLLATERAL_TYPE AS SB_COLLATERAL_TYPE, f.NSB_COLLATERAL_TYPE AS NSB_COLLATERAL_TYPE, f.COLLATERAL_CURRENCY_CD AS COLLATERAL_CURRENCY_CD, o.SETTLE_DATE, o.FUND_CD, f.BRANCH_CD, o.HOLDBACK_FLAG
  		-- 	FROM GEC_IM_ORDER_VW o 
  		-- 	JOIN GEC_FUND f ON o.FUND_CD = f.FUND_CD
  		-- 	JOIN GEC_ASSET ga ON o.ASSET_ID = ga.ASSET_ID
  		-- 	LEFT JOIN GEC_TRADE_COUNTRY tc ON tc.TRADE_COUNTRY_CD = ga.TRADE_COUNTRY_CD
    	--	LEFT JOIN gec_g1_booking gbk ON f.fund_cd = gbk.fund_cd AND gbk.TRANSACTION_CD = 'G1L' AND gbk.POS_TYPE = 'NSB'
    	--	LEFT JOIN gec_g1_collateral gc ON gc.G1_BOOKING_ID = gbk.G1_BOOKING_ID AND gc.TRADE_COUNTRY_CD = tc.TRADE_COUNTRY_CD	  		 	
  		-- 	WHERE 
  		-- 	   o.ASSET_ID = p_asset_id AND
  		-- 	   o.SETTLE_DATE >= p_settle_date AND
  		-- 	   o.SETTLE_DATE <= p_end_settle_date AND
  		-- 	   NVL(gc.COLLATERAL_CURRENCY_CD, gbk.COLLATERAL_CURRENCY_CD) = p_nsb_coll_code AND  	 	   
  		-- 	   o.STATUS IN ('P','E','B') AND
  		-- 	   o.EXPORT_STATUS IN ('N','R', 'B') AND -- in new, response, not in-flight
  		-- 	   o.SHARE_QTY > o.FILLED_QTY AND
  		-- 	   o.TRANSACTION_CD = p_trans_type AND
  		-- 	   o.HOLDBACK_FLAG IN ('N', 'C') AND -- not holdback or holdback for CMO
		--	   f.BRANCH_CD = p_branch_cd AND
  		-- 	   f.BRANCH_CD IN ('BOS',GEC_CONSTANTS_PKG.C_BRANCH_GMBH);
  		 	   
	-- branch 'TOR' borrow can allocated to branch 'TOR' and 'BOS' shorts  	  		 	   
		CURSOR orders_tor_branch IS
			SELECT o.IM_ORDER_ID, o.ASSET_ID, o.STATUS, o.SHARE_QTY-o.FILLED_QTY as UNFILLED_QTY,f.DML_SB_BROKER AS DML_SB_BROKER, f.DML_NSB_BROKER AS DML_NSB_BROKER, f.SB_COLLATERAL_TYPE AS SB_COLLATERAL_TYPE, f.NSB_COLLATERAL_TYPE AS NSB_COLLATERAL_TYPE, f.COLLATERAL_CURRENCY_CD AS COLLATERAL_CURRENCY_CD, o.SETTLE_DATE, o.FUND_CD, f.BRANCH_CD, o.HOLDBACK_FLAG
  		 	FROM GEC_IM_ORDER_VW o 
  		 	JOIN GEC_FUND f ON o.FUND_CD = f.FUND_CD
  		 	JOIN GEC_ASSET ga ON o.ASSET_ID = ga.ASSET_ID
  		 	LEFT JOIN GEC_TRADE_COUNTRY tc ON tc.TRADE_COUNTRY_CD = ga.TRADE_COUNTRY_CD
    		LEFT JOIN gec_g1_booking gbk ON f.fund_cd = gbk.fund_cd AND gbk.TRANSACTION_CD = 'G1L' AND gbk.POS_TYPE = 'NSB'
    		LEFT JOIN gec_g1_collateral gc ON gc.G1_BOOKING_ID = gbk.G1_BOOKING_ID AND gc.TRADE_COUNTRY_CD = tc.TRADE_COUNTRY_CD
  		 	WHERE 
  		 	   o.ASSET_ID = p_asset_id AND
  		 	   o.SETTLE_DATE >= p_settle_date AND
  		 	   o.SETTLE_DATE <= p_end_settle_date AND
  		 	   NVL(gc.COLLATERAL_CURRENCY_CD, gbk.COLLATERAL_CURRENCY_CD) = p_nsb_coll_code AND     		 	   		 	   
  		 	   o.STATUS IN ('P','E','B') AND
  		 	   o.EXPORT_STATUS IN ('N','R', 'B') AND -- in new, response, not in-flight
  		 	   o.SHARE_QTY > o.FILLED_QTY AND
  		 	   o.TRANSACTION_CD = p_trans_type AND
  		 	   o.HOLDBACK_FLAG IN ('N', 'C') AND -- not holdback or holdback for CMO
  		 	   f.BRANCH_CD = p_branch_cd;-- AND
  		 	   --f.BRANCH_CD IN (SELECT ALLOCATE_DEMAND_BRANCH FROM GEC_ALLOCATION_RULE WHERE ALLOCATE_BORROW_BRANCH= p_borrow_branch_cd);   	 	   
  		 	
	BEGIN

		--zwh IF p_borrow_branch_cd IS NOT NULL AND (p_borrow_branch_cd = 'TOR' OR p_borrow_branch_cd=GEC_CONSTANTS_PKG.C_BRANCH_GMBH) THEN
			FOR ord IN orders_tor_branch
			LOOP
				-- prepare coll type, coll code					
				GET_COLL_CODE_TYPE_INFO(p_trade_country, ord.FUND_CD, var_sb_coll_type, var_nsb_coll_type, var_sb_coll_code, var_nsb_coll_code);
				-- prepare fund coll type for non cash matching
				SELECT f.SB_COLLATERAL_TYPE, f.NSB_COLLATERAL_TYPE INTO var_sb_coll_type, var_nsb_coll_type FROM GEC_FUND f WHERE f.FUND_CD = ord.FUND_CD;		
										
				INSERT INTO GEC_IM_ORDER_TEMP(
					IM_ORDER_ID,
	  				ASSET_ID,
	  				STATUS,
	  				UNFILLED_QTY,
	  				SB_BROKER_CD,
	  				NSB_BROKER_CD,
	  				SB_COLLATERAL_TYPE,
	  				NSB_COLLATERAL_TYPE,
					SB_COLLATERAL_CURRENCY_CD,
					NSB_COLLATERAL_CURRENCY_CD,	
	  				SETTLE_DATE,
	  				FUND_CD,
	  				BRANCH_CD,
	  				HOLDBACK_FLAG
	  			)VALUES(
	  				ord.IM_ORDER_ID, 
	  				ord.ASSET_ID, 
	  				ord.STATUS, 
	  				ord.UNFILLED_QTY,
	  				ord.DML_SB_BROKER, 
	  				ord.DML_NSB_BROKER, 
		 			var_sb_coll_type, 
  					var_nsb_coll_type, 
  					var_sb_coll_code, 
	  				var_nsb_coll_code,
	  				ord.SETTLE_DATE, 
	  				ord.FUND_CD,
	  				ord.BRANCH_CD,
	  				ord.HOLDBACK_FLAG
	  			);
	  		END LOOP;
  		--ELSE
  		--	IF p_borrow_branch_cd IS NOT NULL  THEN    		
	  	--		FOR ord IN orders_bos_branch
  		--		LOOP
					-- prepare coll type, coll code					
		--			GET_COLL_CODE_TYPE_INFO(p_trade_country, ord.FUND_CD, var_sb_coll_type, var_nsb_coll_type, var_sb_coll_code, var_nsb_coll_code);
					-- prepare fund coll type for non cash matching
		--			SELECT f.SB_COLLATERAL_TYPE, f.NSB_COLLATERAL_TYPE INTO var_sb_coll_type, var_nsb_coll_type FROM GEC_FUND f WHERE f.FUND_CD = ord.FUND_CD;						
					  				
	  	--			INSERT INTO GEC_IM_ORDER_TEMP(
		--				IM_ORDER_ID,
	  	--				ASSET_ID,
	  	--				STATUS,
		-- 				UNFILLED_QTY,
		--  				SB_BROKER_CD,
	  	--				NSB_BROKER_CD,
	  	--				SB_COLLATERAL_TYPE,
	  	--				NSB_COLLATERAL_TYPE,
		--				SB_COLLATERAL_CURRENCY_CD,
		--				NSB_COLLATERAL_CURRENCY_CD,	
	  	--				SETTLE_DATE,
	  	--				FUND_CD,
	  	--				BRANCH_CD,
	  	--				HOLDBACK_FLAG
		--  			)VALUES(
		--  				ord.IM_ORDER_ID, 
	  	--				ord.ASSET_ID, 
	  	--				ord.STATUS, 
	  	--				ord.UNFILLED_QTY,
	  	--				ord.DML_SB_BROKER, 
		-- 				ord.DML_NSB_BROKER, 
		-- 				var_sb_coll_type, 
  		--				var_nsb_coll_type, 
  		--				var_sb_coll_code, 
	  	--				var_nsb_coll_code,
	  	--				ord.SETTLE_DATE, 
		-- 				ord.FUND_CD,
		--  				ord.BRANCH_CD,
	  	--				ord.HOLDBACK_FLAG
	  	--			);
		--  		END LOOP;
		--	END IF;
		--END IF;			
	END PREPARE_SHORTS_FOR_SINGLE;
	
	
	
	-- Match rule changes per the requirement of Non Cash Colleteral
	-- remove the coll type matching
	-- For file response, , holdback for CMO, coll type = CASH for CMO has already been included in request export
	-- For single/batch input, if non_cash_flag = 'Y', apply rule of coll type = CASH, if non_cash_flag = 'N', apply rule of short's holdback for CMO = 'N'
	FUNCTION SINGLE_ALLOCATION( p_user_id IN VARCHAR2,
								p_asset_id IN NUMBER, 
								p_borrow_settle_date IN NUMBER, 
								p_borrow_request_type IN VARCHAR2, 
								p_input_type IN VARCHAR2, 
								p_agency_flag IN VARCHAR2, 
								p_across_flag IN VARCHAR2, 
								p_error_code OUT VARCHAR2,
								p_error_hint OUT VARCHAR2, 
								p_rate_map IN OUT NOCOPY FUND_RATE_MAP,
								p_ex_loan_info_map IN OUT NOCOPY NONUS_EX_LOAN_INFO_MAP) RETURN VARCHAR2
	IS
		v_max_qty_borrow_id GEC_BORROW.BORROW_ID%type;
		v_max_qty GEC_BORROW.BORROW_QTY%type;
		v_row_count NUMBER(10);
		v_p_share_flag NUMBER(10);
		v_new_p_share_flag NUMBER(10);
		v_found_borrows VARCHAR2(1);
		v_found_shorts VARCHAR2(1);
		v_update_flag VARCHAR2(1);
		
		v_nearest_number GEC_BORROW.BORROW_QTY%type;
		v_temp_order_id GEC_IM_ORDER.IM_ORDER_ID%type;
		v_fund_cd GEC_IM_ORDER.FUND_CD%type;
		v_short_settle_date GEC_IM_ORDER.SETTLE_DATE%type; 
		v_borrow_id GEC_BORROW.BORROW_ID%type; 
		v_borrow_qty GEC_BORROW.BORROW_QTY%type; 
		v_fee GEC_ALLOCATION.RATE%type; 
		v_nonus_fund_loan_info NONUS_FUND_EX_LOAN_INFO;
		v_broker_cd GEC_BORROW.BROKER_CD%type;
		v_position_flag GEC_BORROW.POSITION_FLAG%type;
		
		v_prepay_date GEC_BORROW.PREPAY_DATE%type;
		
		v_error_code VARCHAR2(10);
		
		v_loan_index VARCHAR2(8);
		v_loan_index2 VARCHAR2(30);
		v_trade_country GEC_TRADE_COUNTRY.TRADE_COUNTRY_CD%type;
		var_settle_date  GEC_ALLOCATION.SETTLE_DATE%type;
		var_prepay_date GEC_ALLOCATION.PREPAY_DATE%type;
		
		CURSOR max_qty_borrows IS
					SELECT BORROW_ID, TRADE_COUNTRY_CD FROM GEC_BORROW_UNIT_TEMP WHERE STATUS <> 'F' and UNFILLED_QTY = v_max_qty;
		
		-- per BR 1.2, for SB, borrow only can match to shorts whose settle date = borrow settle date				   		
		CURSOR sb_exact_match IS 
							SELECT b.BORROW_ID, b.UNFILLED_QTY as b_qty, o.FUND_CD, o.SETTLE_DATE as S_SETTLE_DATE, b.PREPAY_DATE, o.IM_ORDER_ID, b.BROKER_CD as B_BROKER_CD, b.TRADE_COUNTRY_CD,DECODE(gccm.COUNTRY_CATEGORY_CD,'PS1',DECODE(gf.FUND_CATEGORY_CD,'SGF','0','OBF','1','0'),'PS2',DECODE(gf.FUND_CATEGORY_CD,'SGF','0','OBF','1','0'),'0') P_SHARES_FLAG
							FROM GEC_BORROW_UNIT_TEMP b, GEC_IM_ORDER_TEMP o,GEC_ALLOCATION_RULE gar,GEC_FUND gf,GEC_COUNTRY_CATEGORY_MAP gccm
							WHERE b.BRANCH_CD = gar.ALLOCATE_BORROW_BRANCH and o.BRANCH_CD = gar.ALLOCATE_DEMAND_BRANCH and b.TRADE_COUNTRY_CD=gccm.COUNTRY_CD(+) and 
									  gf.FUND_CD = o.FUND_CD AND
								      ((p_across_flag='N' and b.LEGAL_ENTITY_CD = gf.LEGAL_ENTITY_CD ) OR p_across_flag='Y') AND
									  b.BROKER_CD = o.SB_BROKER_CD AND
									  b.COLLATERAL_CURRENCY_CD = o.SB_COLLATERAL_CURRENCY_CD AND
									  b.UNFILLED_QTY = o.UNFILLED_QTY AND
									  b.UNFILLED_QTY > 0 AND
									  b.STATUS <> 'F' AND
									  b.SETTLE_DATE <= o.SETTLE_DATE AND
									  (b.NON_CASH_FLAG='Y' AND o.SB_COLLATERAL_TYPE='CASH' OR b.NON_CASH_FLAG='N' AND o.HOLDBACK_FLAG<>'C')
							ORDER BY P_SHARES_FLAG desc,gar.BORROW_ALLOCATE_ORDER, gar.DEMAND_ALLOCATE_ORDER;

		CURSOR sb_nearest IS
							SELECT b.BORROW_ID, o.IM_ORDER_ID, b.UNFILLED_QTY AS b_qty, o.UNFILLED_QTY AS o_qty, o.FUND_CD, o.SETTLE_DATE as S_SETTLE_DATE, b.PREPAY_DATE, b.BROKER_CD as B_BROKER_CD, b.TRADE_COUNTRY_CD,DECODE(gccm.COUNTRY_CATEGORY_CD,'PS1',DECODE(gf.FUND_CATEGORY_CD,'SGF','0','OBF','1','0'),'PS2',DECODE(gf.FUND_CATEGORY_CD,'SGF','0','OBF','1','0'),'0') P_SHARES_FLAG
							FROM GEC_BORROW_UNIT_TEMP b, GEC_IM_ORDER_TEMP o,GEC_ALLOCATION_RULE gar,GEC_FUND gf,GEC_COUNTRY_CATEGORY_MAP gccm
							WHERE b.BRANCH_CD = gar.ALLOCATE_BORROW_BRANCH and o.BRANCH_CD = gar.ALLOCATE_DEMAND_BRANCH and b.TRADE_COUNTRY_CD=gccm.COUNTRY_CD(+) and 
							      gf.FUND_CD = o.FUND_CD AND
								  ((p_across_flag='N' and b.LEGAL_ENTITY_CD = gf.LEGAL_ENTITY_CD ) OR p_across_flag='Y') AND
							      b.BORROW_ID = v_max_qty_borrow_id AND
								  b.BROKER_CD = o.SB_BROKER_CD AND
								  b.COLLATERAL_CURRENCY_CD = o.SB_COLLATERAL_CURRENCY_CD AND
								  b.UNFILLED_QTY > 0 AND
								  b.STATUS <> 'F' AND
								  o.UNFILLED_QTY > 0 AND
								   b.SETTLE_DATE <= o.SETTLE_DATE AND
								  (b.NON_CASH_FLAG='Y' AND o.SB_COLLATERAL_TYPE='CASH' OR b.NON_CASH_FLAG='N' AND o.HOLDBACK_FLAG<>'C')
							ORDER BY P_SHARES_FLAG desc,o.UNFILLED_QTY ASC,gar.BORROW_ALLOCATE_ORDER, gar.DEMAND_ALLOCATE_ORDER;

		
		-- per BR 31, for NSB, borrow only can match to shorts whose settle date >= borrow settle date
		CURSOR nsb_exact_match IS
							SELECT b.BORROW_ID, b.UNFILLED_QTY as b_qty, o.FUND_CD, o.SETTLE_DATE as S_SETTLE_DATE, b.PREPAY_DATE, o.IM_ORDER_ID, b.BROKER_CD as B_BROKER_CD, b.POSITION_FLAG, b.TRADE_COUNTRY_CD,DECODE(gccm.COUNTRY_CATEGORY_CD,'PS1',DECODE(gf.FUND_CATEGORY_CD,'SGF','0','OBF','1','0'),'PS2',DECODE(gf.FUND_CATEGORY_CD,'SGF','0','OBF','1','0'),'0') P_SHARES_FLAG
								FROM GEC_BORROW_UNIT_TEMP b, GEC_IM_ORDER_TEMP o,GEC_ALLOCATION_RULE gar,GEC_FUND gf,GEC_COUNTRY_CATEGORY_MAP gccm
								WHERE b.BRANCH_CD = gar.ALLOCATE_BORROW_BRANCH and o.BRANCH_CD = gar.ALLOCATE_DEMAND_BRANCH AND b.TRADE_COUNTRY_CD=gccm.COUNTRY_CD(+) and 
									  gf.FUND_CD = o.FUND_CD AND
									  ((p_across_flag='N' and b.LEGAL_ENTITY_CD = gf.LEGAL_ENTITY_CD) OR p_across_flag='Y') AND
									  b.COLLATERAL_CURRENCY_CD = o.NSB_COLLATERAL_CURRENCY_CD AND
									  b.UNFILLED_QTY = o.UNFILLED_QTY AND
									  b.UNFILLED_QTY > 0 AND
									  b.STATUS <> 'F' AND
									  b.SETTLE_DATE <= o.SETTLE_DATE AND
									  (b.NON_CASH_FLAG='Y' AND o.NSB_COLLATERAL_TYPE='CASH' OR b.NON_CASH_FLAG='N' AND o.HOLDBACK_FLAG<>'C') AND
									  o.SETTLE_DATE = (SELECT MIN(SETTLE_DATE) FROM GEC_IM_ORDER_TEMP o_in,GEC_FUND gf2
									                   WHERE 
									                   		 gf2.FUND_CD = o_in.FUND_CD AND
									                   		 o_in.NSB_COLLATERAL_CURRENCY_CD = b.COLLATERAL_CURRENCY_CD AND
									                   		 o_in.SETTLE_DATE >= b.SETTLE_DATE AND
									                   		 o_in.UNFILLED_QTY > 0 AND
									                   		 ((p_across_flag='N' and b.LEGAL_ENTITY_CD = gf2.LEGAL_ENTITY_CD ) OR p_across_flag='Y') AND
									                   		 (b.NON_CASH_FLAG='Y' AND o_in.NSB_COLLATERAL_TYPE='CASH' OR b.NON_CASH_FLAG='N' AND o_in.HOLDBACK_FLAG<>'C')
									  					)
							ORDER BY P_SHARES_FLAG desc,gar.BORROW_ALLOCATE_ORDER, gar.DEMAND_ALLOCATE_ORDER ;
								
		CURSOR nsb_nearest IS
							SELECT b.BORROW_ID, o.IM_ORDER_ID, b.UNFILLED_QTY AS b_qty, o.UNFILLED_QTY AS o_qty, o.FUND_CD, o.SETTLE_DATE as S_SETTLE_DATE, b.PREPAY_DATE, b.BROKER_CD as B_BROKER_CD, b.POSITION_FLAG,DECODE(gccm.COUNTRY_CATEGORY_CD,'PS1',DECODE(gf.FUND_CATEGORY_CD,'SGF','0','OBF','1','0'),'PS2',DECODE(gf.FUND_CATEGORY_CD,'SGF','0','OBF','1','0'),'0') P_SHARES_FLAG
							FROM GEC_BORROW_UNIT_TEMP b, GEC_IM_ORDER_TEMP o,GEC_ALLOCATION_RULE gar,GEC_FUND gf,GEC_COUNTRY_CATEGORY_MAP gccm
							WHERE b.BRANCH_CD = gar.ALLOCATE_BORROW_BRANCH and o.BRANCH_CD = gar.ALLOCATE_DEMAND_BRANCH and b.BORROW_ID = v_max_qty_borrow_id AND b.TRADE_COUNTRY_CD=gccm.COUNTRY_CD(+) and 
								  gf.FUND_CD = o.FUND_CD AND
								 ((p_across_flag='N' and b.LEGAL_ENTITY_CD = gf.LEGAL_ENTITY_CD) OR p_across_flag='Y') AND
								  b.COLLATERAL_CURRENCY_CD = o.NSB_COLLATERAL_CURRENCY_CD AND
								  b.UNFILLED_QTY > 0 AND
								  b.STATUS <> 'F' AND
								  o.UNFILLED_QTY > 0 AND
								  b.SETTLE_DATE <= o.SETTLE_DATE AND
								  (b.NON_CASH_FLAG='Y' AND o.NSB_COLLATERAL_TYPE='CASH' OR b.NON_CASH_FLAG='N' AND o.HOLDBACK_FLAG<>'C') AND
								  o.SETTLE_DATE = (SELECT MIN(SETTLE_DATE) FROM GEC_IM_ORDER_TEMP o_in,GEC_FUND gf2
									                   WHERE 
									                   		 gf2.FUND_CD = o_in.FUND_CD AND
									                   		 o_in.NSB_COLLATERAL_CURRENCY_CD = b.COLLATERAL_CURRENCY_CD AND
									                   		 o_in.SETTLE_DATE >= b.SETTLE_DATE AND
									                   		 o_in.UNFILLED_QTY > 0 AND
									                   		 ((p_across_flag='N' and b.LEGAL_ENTITY_CD = gf2.LEGAL_ENTITY_CD ) OR p_across_flag='Y') AND
									                   		 (b.NON_CASH_FLAG='Y' AND o_in.NSB_COLLATERAL_TYPE='CASH' OR b.NON_CASH_FLAG='N' AND o_in.HOLDBACK_FLAG<>'C')
								  					)
							ORDER BY P_SHARES_FLAG desc,o.UNFILLED_QTY ASC, gar.BORROW_ALLOCATE_ORDER, gar.DEMAND_ALLOCATE_ORDER ;
		
		-- per BR 31, for NSB, borrow only can match to shorts whose settle date >= borrow settle date
		CURSOR other_exact_match IS
							SELECT b.BORROW_ID, b.UNFILLED_QTY as b_qty, o.FUND_CD, o.SETTLE_DATE as S_SETTLE_DATE, b.PREPAY_DATE, o.IM_ORDER_ID, b.BROKER_CD as B_BROKER_CD, b.POSITION_FLAG, b.TRADE_COUNTRY_CD,DECODE(gccm.COUNTRY_CATEGORY_CD,'PS1',DECODE(gf.FUND_CATEGORY_CD,'SGF','0','OBF','1','0'),'PS2',DECODE(gf.FUND_CATEGORY_CD,'SGF','0','OBF','1','0'),'0') P_SHARES_FLAG
								FROM GEC_BORROW_UNIT_TEMP b, GEC_IM_ORDER_TEMP o,GEC_ALLOCATION_RULE gar,GEC_FUND gf,GEC_COUNTRY_CATEGORY_MAP gccm
								WHERE b.BRANCH_CD = gar.ALLOCATE_BORROW_BRANCH and o.BRANCH_CD = gar.ALLOCATE_DEMAND_BRANCH and  b.TRADE_COUNTRY_CD=gccm.COUNTRY_CD(+) and 
								gf.FUND_CD = o.FUND_CD AND
								 ((p_across_flag='N' and b.LEGAL_ENTITY_CD = gf.LEGAL_ENTITY_CD ) OR p_across_flag='Y') AND
								b.COLLATERAL_CURRENCY_CD = o.NSB_COLLATERAL_CURRENCY_CD AND
									  b.UNFILLED_QTY = o.UNFILLED_QTY AND
									  b.UNFILLED_QTY > 0 AND
									  b.STATUS <> 'F' AND
									  b.SETTLE_DATE <= o.SETTLE_DATE AND
									  (b.NON_CASH_FLAG='Y' AND o.NSB_COLLATERAL_TYPE='CASH' OR b.NON_CASH_FLAG='N' AND o.HOLDBACK_FLAG<>'C') AND
									  o.SETTLE_DATE = (SELECT MIN(SETTLE_DATE) FROM GEC_IM_ORDER_TEMP o_in,GEC_FUND gf2
									                   WHERE 
									                   		 gf2.FUND_CD = o_in.FUND_CD AND
									                   		 o_in.NSB_COLLATERAL_CURRENCY_CD = b.COLLATERAL_CURRENCY_CD AND
									                   		 o_in.SETTLE_DATE >= b.SETTLE_DATE AND
									                   		 o_in.UNFILLED_QTY > 0 AND
									                   		 ((p_across_flag='N' and b.LEGAL_ENTITY_CD = gf2.LEGAL_ENTITY_CD ) OR p_across_flag='Y') AND
									                   		 (b.NON_CASH_FLAG='Y' AND o_in.NSB_COLLATERAL_TYPE='CASH' OR b.NON_CASH_FLAG='N' AND o_in.HOLDBACK_FLAG<>'C')
									  					)
								ORDER BY P_SHARES_FLAG desc,gar.BORROW_ALLOCATE_ORDER, gar.DEMAND_ALLOCATE_ORDER;
								
		CURSOR other_nearest IS
							SELECT b.BORROW_ID, o.IM_ORDER_ID, b.UNFILLED_QTY AS b_qty, o.UNFILLED_QTY AS o_qty, o.FUND_CD, o.SETTLE_DATE as S_SETTLE_DATE, b.PREPAY_DATE, b.BROKER_CD as B_BROKER_CD, b.POSITION_FLAG,DECODE(gccm.COUNTRY_CATEGORY_CD,'PS1',DECODE(gf.FUND_CATEGORY_CD,'SGF','0','OBF','1','0'),'PS2',DECODE(gf.FUND_CATEGORY_CD,'SGF','0','OBF','1','0'),'0') P_SHARES_FLAG
							FROM GEC_BORROW_UNIT_TEMP b, GEC_IM_ORDER_TEMP o,GEC_ALLOCATION_RULE gar,GEC_FUND gf,GEC_COUNTRY_CATEGORY_MAP gccm
							WHERE b.BRANCH_CD = gar.ALLOCATE_BORROW_BRANCH and o.BRANCH_CD = gar.ALLOCATE_DEMAND_BRANCH and b.BORROW_ID = v_max_qty_borrow_id AND b.TRADE_COUNTRY_CD=gccm.COUNTRY_CD(+) and 
								  gf.FUND_CD = o.FUND_CD AND
								 ((p_across_flag='N' and b.LEGAL_ENTITY_CD = gf.LEGAL_ENTITY_CD ) OR p_across_flag='Y') AND
								  b.COLLATERAL_CURRENCY_CD = o.NSB_COLLATERAL_CURRENCY_CD AND
								  b.UNFILLED_QTY > 0 AND
								  b.STATUS <> 'F' AND
								  o.UNFILLED_QTY > 0 AND
								  b.SETTLE_DATE <= o.SETTLE_DATE AND
								  (b.NON_CASH_FLAG='Y' AND o.NSB_COLLATERAL_TYPE='CASH' OR b.NON_CASH_FLAG='N' AND o.HOLDBACK_FLAG<>'C') AND
								  o.SETTLE_DATE = (SELECT MIN(SETTLE_DATE) FROM GEC_IM_ORDER_TEMP o_in,GEC_FUND gf2
									                   WHERE 
									                         gf2.FUND_CD = o_in.FUND_CD AND
									                         o_in.NSB_COLLATERAL_CURRENCY_CD = b.COLLATERAL_CURRENCY_CD AND
									                   		 o_in.SETTLE_DATE >= b.SETTLE_DATE AND
									                   		 o_in.UNFILLED_QTY > 0 AND
									                   		 ((p_across_flag='N' and b.LEGAL_ENTITY_CD = gf2.LEGAL_ENTITY_CD ) OR p_across_flag='Y') AND
									                   		 (b.NON_CASH_FLAG='Y' AND o_in.NSB_COLLATERAL_TYPE='CASH' OR b.NON_CASH_FLAG='N' AND o_in.HOLDBACK_FLAG<>'C')
								  					)
							ORDER BY P_SHARES_FLAG desc,o.UNFILLED_QTY ASC, gar.BORROW_ALLOCATE_ORDER, gar.DEMAND_ALLOCATE_ORDER;
	BEGIN
		p_error_code := NULL;
		IF p_borrow_request_type = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB THEN
			FOR v_m IN sb_exact_match
			LOOP
				UPDATE GEC_BORROW_UNIT_TEMP SET STATUS = 'F' WHERE BORROW_ID = v_m.BORROW_ID;
				v_loan_index := v_m.FUND_CD || '_' || v_m.TRADE_COUNTRY_CD;
				-- calc default fee
				v_fee := GET_FUND_RATE_FROM_MAP(p_borrow_request_type, v_m.FUND_CD, v_m.TRADE_COUNTRY_CD, v_loan_index, v_error_code, p_rate_map);
				IF v_error_code IS NOT NULL THEN
					p_error_code := v_error_code;
					p_error_hint := v_m.FUND_CD;
					RETURN 'N';
				END IF;
				-- pshare
				SELECT 
				TRADE_COUNTRY_CD
				INTO
				v_trade_country
				FROM
				GEC_ASSET
				WHERE 
				ASSET_ID=p_asset_id;
				GET_LOAN_DEF_SET_PRE_DATE(p_borrow_request_type,v_m.FUND_CD,v_trade_country,v_m.S_SETTLE_DATE,var_prepay_date,var_settle_date);
				-- pshare
				-- calc default non us loan info	
				-- to fix the defect PRTLB00868641 ,because of using a wrong key,we use a new key v_loan_index2 instead of v_loan_index
				v_loan_index2 := p_borrow_request_type||'_'||v_m.FUND_CD || '_' || v_m.TRADE_COUNTRY_CD;
				v_nonus_fund_loan_info := GET_NONUS_EX_LOAN_INFO_MAP(p_borrow_request_type, v_m.FUND_CD, v_m.TRADE_COUNTRY_CD, v_loan_index2, var_settle_date, var_prepay_date, v_error_code, p_ex_loan_info_map);
				IF v_error_code IS NOT NULL THEN
					p_error_code := v_error_code;
					p_error_hint := v_m.FUND_CD;
					RETURN 'N';
				END IF;				

								
				BOOK_ONE_ALLOCATION2(p_user_id,
									p_asset_id,
								    v_m.FUND_CD, 
								    v_m.S_SETTLE_DATE, 
								    v_m.BORROW_ID, 
								  	v_m.IM_ORDER_ID, 
								  	v_m.b_qty, 
								    v_m.b_qty, 
								  	v_fee, 
								  	var_settle_date, 
								  	var_prepay_date,
								  	v_nonus_fund_loan_info.PREPAY_RATE,
								  	v_nonus_fund_loan_info.RECLAIM_RATE,
								  	v_nonus_fund_loan_info.OVERSEAS_TAX_PERCENTAGE,
								  	v_nonus_fund_loan_info.DOMESTIC_TAX_PERCENTAGE,
								  	v_nonus_fund_loan_info.COLL_TYPE,
								  	v_nonus_fund_loan_info.COLLATERAL_CURRENCY_CD,
								  	0,  
								  	p_borrow_request_type,
								    v_m.B_BROKER_CD,
								    'Y');
				EXIT;
			END LOOP;
			
			v_found_borrows := 'N';
			v_max_qty_borrow_id := 0;
			v_nonus_fund_loan_info := NULL;
			
			SELECT MAX(UNFILLED_QTY), COUNT(BORROW_ID) INTO v_max_qty,v_row_count 
			FROM GEC_BORROW_UNIT_TEMP WHERE STATUS <> 'F' AND
							   		 		UNFILLED_QTY > 0;
			
			IF v_max_qty IS NOT NULL THEN
				FOR v_max IN max_qty_borrows
				LOOP
					v_found_borrows := 'Y';
					v_trade_country := v_max.TRADE_COUNTRY_CD;
									
					IF v_max_qty_borrow_id = 0 THEN
						v_max_qty_borrow_id := v_max.BORROW_ID;
					END IF;
					
					EXIT WHEN v_found_borrows = 'Y';
					
				END LOOP;
			END IF;
		
		
			IF v_found_borrows = 'N' THEN
				RETURN 'N';
			END IF;
			
			
			v_found_shorts := 'N';
			v_nearest_number := 0;
			v_p_share_flag:=0;
			v_new_p_share_flag:=0;
			FOR v_n IN sb_nearest
			LOOP
				v_found_shorts := 'Y';
				v_p_share_flag :=v_new_p_share_flag;
				v_new_p_share_flag := v_n.P_SHARES_FLAG;
				IF (v_p_share_flag=1 AND v_new_p_share_flag=0) THEN
					EXIT;
				END IF;
				IF v_n.o_qty > v_n.b_qty THEN
					IF v_nearest_number = 0 THEN
						v_nearest_number := v_n.o_qty;
						v_temp_order_id := v_n.IM_ORDER_ID;
						v_fund_cd := v_n.FUND_CD;
						v_short_settle_date := v_n.S_SETTLE_DATE; 
						v_borrow_id := v_n.BORROW_ID; 
						v_borrow_qty := v_n.b_qty; 
						v_broker_cd := v_n.B_BROKER_CD;
						v_prepay_date := v_n.PREPAY_DATE;
					END IF;
				ELSE
					IF v_n.o_qty>v_nearest_number THEN
						v_nearest_number := v_n.o_qty;
						v_temp_order_id := v_n.IM_ORDER_ID;
						v_fund_cd := v_n.FUND_CD;
						v_short_settle_date := v_n.S_SETTLE_DATE; 
						v_borrow_id := v_n.BORROW_ID; 
						v_borrow_qty := v_n.b_qty; 
						v_broker_cd := v_n.B_BROKER_CD;
						v_prepay_date := v_n.PREPAY_DATE;
					END IF;
				END IF;
				
				EXIT WHEN v_n.o_qty > v_n.b_qty;
			END LOOP;
			
			IF v_found_shorts = 'N' THEN
				IF v_row_count = 1 THEN
					RETURN 'N';
				ELSE
					UPDATE GEC_BORROW_UNIT_TEMP SET STATUS = 'F' WHERE BORROW_ID = v_max_qty_borrow_id;
				END IF;
			ELSE
				-- calc default fee
				v_loan_index := v_fund_cd || '_' || v_trade_country;
				v_fee := GET_FUND_RATE_FROM_MAP(p_borrow_request_type, v_fund_cd, v_trade_country, v_loan_index, v_error_code, p_rate_map);
				IF v_error_code IS NOT NULL THEN
					p_error_code := v_error_code;
					p_error_hint := v_fund_cd;
					RETURN 'N';
				END IF;
				-- pshare
				SELECT 
				TRADE_COUNTRY_CD
				INTO
				v_trade_country
				FROM
				GEC_ASSET
				WHERE 
				ASSET_ID=p_asset_id;
				GET_LOAN_DEF_SET_PRE_DATE(p_borrow_request_type,v_fund_cd,v_trade_country,v_short_settle_date,var_prepay_date,var_settle_date);
				-- pshare
				v_loan_index2 := p_borrow_request_type||'_'||v_fund_cd || '_' || v_trade_country;
				-- calc default non us loan info	
				-- to fix the defect PRTLB00868641 ,because of using a wrong key,we use a new key v_loan_index2 instead of v_loan_index	
				v_nonus_fund_loan_info := GET_NONUS_EX_LOAN_INFO_MAP(p_borrow_request_type, v_fund_cd, v_trade_country, v_loan_index2, var_settle_date, var_prepay_date, v_error_code, p_ex_loan_info_map);
				IF v_error_code IS NOT NULL THEN
					p_error_code := v_error_code;
					p_error_hint := v_fund_cd;
					RETURN 'N';
				END IF;					
						
				v_update_flag := 'Y';
				IF v_nearest_number >= v_borrow_qty AND v_row_count = 1 THEN
					v_update_flag := 'N';
				END IF;
				BOOK_ONE_ALLOCATION2(p_user_id,
									p_asset_id,
								    v_fund_cd, 
								    v_short_settle_date, 
								    v_borrow_id, 
								  	v_temp_order_id, 
								  	v_borrow_qty, 
								    v_nearest_number, 
								    v_fee,
								    var_settle_date,
								    var_prepay_date,
								    v_nonus_fund_loan_info.PREPAY_RATE,
								  	v_nonus_fund_loan_info.RECLAIM_RATE,
								  	v_nonus_fund_loan_info.OVERSEAS_TAX_PERCENTAGE,
								  	v_nonus_fund_loan_info.DOMESTIC_TAX_PERCENTAGE,
								  	v_nonus_fund_loan_info.COLL_TYPE,
								  	v_nonus_fund_loan_info.COLLATERAL_CURRENCY_CD,
								  	0,								    
								  	p_borrow_request_type,
								    v_broker_cd,
								    v_update_flag);
			END IF;
			IF v_nearest_number >= v_borrow_qty AND v_row_count = 1 THEN
				RETURN 'N';
			ELSE
				RETURN 'Y';
			END IF;
		END IF;
		
		IF p_borrow_request_type <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND p_agency_flag = 'Y' THEN
			
			FOR v_m IN nsb_exact_match
			LOOP	
				UPDATE GEC_BORROW_UNIT_TEMP SET STATUS = 'F' WHERE BORROW_ID = v_m.BORROW_ID;
				
				-- calc default fee for GC
				v_loan_index := v_m.FUND_CD || '_' || v_m.TRADE_COUNTRY_CD;		
				IF v_m.POSITION_FLAG <> 'SP' AND v_m.TRADE_COUNTRY_CD IN (GEC_CONSTANTS_PKG.C_COUNTRY_US, GEC_CONSTANTS_PKG.C_COUNTRY_CA) THEN
					-- calc default fee
					v_fee := GET_FUND_RATE_FROM_MAP(p_borrow_request_type, v_m.FUND_CD, v_m.TRADE_COUNTRY_CD, v_loan_index, v_error_code, p_rate_map);
					IF v_error_code IS NOT NULL THEN
						p_error_code := v_error_code;
						p_error_hint := v_m.FUND_CD;
						RETURN 'N';
					END IF;
				END IF;
				-- pshare
				SELECT 
				TRADE_COUNTRY_CD
				INTO
				v_trade_country
				FROM
				GEC_ASSET
				WHERE 
				ASSET_ID=p_asset_id;
				GET_LOAN_DEF_SET_PRE_DATE(p_borrow_request_type,v_m.FUND_CD,v_trade_country,v_m.S_SETTLE_DATE,var_prepay_date,var_settle_date);
				-- pshare
				v_loan_index2 := p_borrow_request_type||'_'||v_m.FUND_CD || '_' || v_m.TRADE_COUNTRY_CD;	
				-- calc default non us loan info
				-- to fix the defect PRTLB00868641 ,because of using a wrong key,we use a new key v_loan_index2 instead of v_loan_index
				v_nonus_fund_loan_info := GET_NONUS_EX_LOAN_INFO_MAP(p_borrow_request_type, v_m.FUND_CD, v_m.TRADE_COUNTRY_CD, v_loan_index2, var_settle_date, var_prepay_date, v_error_code, p_ex_loan_info_map);
				IF v_error_code IS NOT NULL THEN
					p_error_code := v_error_code;
					p_error_hint := v_m.FUND_CD;
					RETURN 'N';
				END IF;					
				
				BOOK_ONE_ALLOCATION2(p_user_id,
									p_asset_id,
								    v_m.FUND_CD, 
								    v_m.S_SETTLE_DATE, 
								    v_m.BORROW_ID, 
								  	v_m.IM_ORDER_ID, 
								  	v_m.b_qty, 
								    v_m.b_qty, 
								  	v_fee,
								  	var_settle_date, 
							  		var_prepay_date,
							  		v_nonus_fund_loan_info.PREPAY_RATE,
								  	v_nonus_fund_loan_info.RECLAIM_RATE,
								  	v_nonus_fund_loan_info.OVERSEAS_TAX_PERCENTAGE,
								  	v_nonus_fund_loan_info.DOMESTIC_TAX_PERCENTAGE,
								  	v_nonus_fund_loan_info.COLL_TYPE,
								  	v_nonus_fund_loan_info.COLLATERAL_CURRENCY_CD,
								  	0,  								  	
								  	p_borrow_request_type,
								    v_m.B_BROKER_CD,
								    'Y');
				EXIT;
			END LOOP;
			
			v_found_borrows := 'N';
			v_max_qty_borrow_id := 0;
			v_nonus_fund_loan_info := NULL;
			
			SELECT MAX(UNFILLED_QTY), COUNT(BORROW_ID) INTO v_max_qty, v_row_count 
			FROM GEC_BORROW_UNIT_TEMP WHERE STATUS <> 'F' AND
							   		 		UNFILLED_QTY > 0;
							   		 		
			FOR v_max IN max_qty_borrows
			LOOP				
				v_found_borrows := 'Y';
				v_trade_country := v_max.TRADE_COUNTRY_CD;				
			
				IF v_max_qty_borrow_id = 0 THEN
					v_max_qty_borrow_id := v_max.BORROW_ID;
				END IF;
				EXIT WHEN v_found_borrows = 'Y';
			END LOOP;
		
			IF v_found_borrows = 'N' THEN
				RETURN 'N';
			END IF;
			
			v_found_shorts := 'N';
			v_nearest_number := 0;
			v_p_share_flag:=0;
			v_new_p_share_flag:=0;
			FOR v_n IN nsb_nearest
			LOOP
				v_found_shorts := 'Y';
				v_p_share_flag :=v_new_p_share_flag;
				v_new_p_share_flag := v_n.P_SHARES_FLAG;
				IF (v_p_share_flag=1 AND v_new_p_share_flag=0) THEN
					EXIT;
				END IF;
				IF v_n.o_qty > v_n.b_qty THEN
					IF v_nearest_number = 0 THEN
						v_nearest_number := v_n.o_qty;
						v_temp_order_id := v_n.IM_ORDER_ID;
						v_fund_cd := v_n.FUND_CD;
						v_short_settle_date := v_n.S_SETTLE_DATE; 
						v_borrow_id := v_n.BORROW_ID; 
						v_borrow_qty := v_n.b_qty; 
						v_broker_cd := v_n.B_BROKER_CD;
						v_position_flag := v_n.POSITION_FLAG;
						v_prepay_date := v_n.PREPAY_DATE;						
					END IF;
				ELSE
					IF v_n.o_qty>v_nearest_number THEN
						v_nearest_number := v_n.o_qty;
						v_temp_order_id := v_n.IM_ORDER_ID;
						v_fund_cd := v_n.FUND_CD;
						v_short_settle_date := v_n.S_SETTLE_DATE; 
						v_borrow_id := v_n.BORROW_ID; 
						v_borrow_qty := v_n.b_qty; 
						v_broker_cd := v_n.B_BROKER_CD;
						v_position_flag := v_n.POSITION_FLAG;
						v_prepay_date := v_n.PREPAY_DATE;
					END IF;
				END IF;
				
				EXIT WHEN v_n.o_qty > v_n.b_qty;
			END LOOP;
			
			IF v_found_shorts = 'N' THEN
				IF v_row_count = 1 THEN
					RETURN 'N';
				ELSE
					UPDATE GEC_BORROW_UNIT_TEMP SET STATUS = 'F' WHERE BORROW_ID = v_max_qty_borrow_id;
				END IF;
			ELSE		
				-- calc default fee
				v_loan_index := v_fund_cd || '_' || v_trade_country;				
				IF v_position_flag <> 'SP' AND v_trade_country IN (GEC_CONSTANTS_PKG.C_COUNTRY_US, GEC_CONSTANTS_PKG.C_COUNTRY_CA) THEN
					v_fee := GET_FUND_RATE_FROM_MAP(p_borrow_request_type, v_fund_cd, v_trade_country, v_loan_index, v_error_code, p_rate_map);
					IF v_error_code IS NOT NULL THEN
						p_error_code := v_error_code;
						p_error_hint := v_fund_cd;
						RETURN 'N';
					END IF;
				END IF;
				-- pshare
				SELECT 
				TRADE_COUNTRY_CD
				INTO
				v_trade_country
				FROM
				GEC_ASSET
				WHERE 
				ASSET_ID=p_asset_id;
				GET_LOAN_DEF_SET_PRE_DATE(p_borrow_request_type,v_fund_cd,v_trade_country,v_short_settle_date,var_prepay_date,var_settle_date);
				-- pshare
				v_loan_index2 := p_borrow_request_type||'_'||v_fund_cd || '_' || v_trade_country;
				-- calc default non us loan info
				-- to fix the defect PRTLB00868641 ,because of using a wrong key,we use a new key v_loan_index2 instead of v_loan_index	
				v_nonus_fund_loan_info := GET_NONUS_EX_LOAN_INFO_MAP(p_borrow_request_type, v_fund_cd, v_trade_country, v_loan_index2, var_settle_date, var_prepay_date, v_error_code, p_ex_loan_info_map);
				IF v_error_code IS NOT NULL THEN
					p_error_code := v_error_code;
					p_error_hint := v_fund_cd;
					RETURN 'N';
				END IF;							
				
				v_update_flag := 'Y';
				IF v_nearest_number >= v_borrow_qty AND v_row_count = 1 THEN
					v_update_flag := 'N';
				END IF;
				
				BOOK_ONE_ALLOCATION2(p_user_id,
									p_asset_id,
								    v_fund_cd, 
								    v_short_settle_date, 
								    v_borrow_id, 
								  	v_temp_order_id, 
								  	v_borrow_qty, 
								    v_nearest_number, 
								    v_fee,
								    var_settle_date,
								    var_prepay_date,
								    v_nonus_fund_loan_info.PREPAY_RATE,
								  	v_nonus_fund_loan_info.RECLAIM_RATE,
								  	v_nonus_fund_loan_info.OVERSEAS_TAX_PERCENTAGE,
								  	v_nonus_fund_loan_info.DOMESTIC_TAX_PERCENTAGE,
								  	v_nonus_fund_loan_info.COLL_TYPE,
								  	v_nonus_fund_loan_info.COLLATERAL_CURRENCY_CD,
								  	0,									    
								  	p_borrow_request_type,
								    v_broker_cd,
								    v_update_flag);
			END IF;
			
			IF v_nearest_number >= v_borrow_qty AND v_row_count = 1 THEN
				RETURN 'N';
			ELSE
				RETURN 'Y';
			END IF;
		END IF;
		
		IF p_borrow_request_type <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND p_agency_flag = 'N' THEN
			FOR v_m IN other_exact_match
			LOOP
				UPDATE GEC_BORROW_UNIT_TEMP SET STATUS = 'F' WHERE BORROW_ID = v_m.BORROW_ID;
				
				-- calc default fee
				v_loan_index := v_m.FUND_CD || '_' || v_m.TRADE_COUNTRY_CD;					
				IF v_m.POSITION_FLAG <> 'SP' AND v_m.TRADE_COUNTRY_CD IN (GEC_CONSTANTS_PKG.C_COUNTRY_US, GEC_CONSTANTS_PKG.C_COUNTRY_CA) THEN	
					v_fee := GET_FUND_RATE_FROM_MAP(p_borrow_request_type, v_m.FUND_CD, v_m.TRADE_COUNTRY_CD, v_loan_index, v_error_code, p_rate_map);
					IF v_error_code IS NOT NULL THEN
						p_error_code := v_error_code;
						p_error_hint := v_m.FUND_CD;
						RETURN 'N';
					END IF;
				END IF;
				-- pshare
				SELECT 
				TRADE_COUNTRY_CD
				INTO
				v_trade_country
				FROM
				GEC_ASSET
				WHERE 
				ASSET_ID=p_asset_id;
				GET_LOAN_DEF_SET_PRE_DATE(p_borrow_request_type,v_m.FUND_CD,v_trade_country,v_m.S_SETTLE_DATE,var_prepay_date,var_settle_date);
				-- pshare
				v_loan_index2 := p_borrow_request_type||'_'||v_m.FUND_CD || '_' || v_m.TRADE_COUNTRY_CD;	
				-- calc default non us loan info
				-- to fix the defect PRTLB00868641 ,because of using a wrong key,we use a new key v_loan_index2 instead of v_loan_index
				v_nonus_fund_loan_info := GET_NONUS_EX_LOAN_INFO_MAP(p_borrow_request_type, v_m.FUND_CD, v_m.TRADE_COUNTRY_CD, v_loan_index2, var_settle_date, var_prepay_date, v_error_code, p_ex_loan_info_map);
				IF v_error_code IS NOT NULL THEN
					p_error_code := v_error_code;
					p_error_hint := v_m.FUND_CD;
					RETURN 'N';
				END IF;								
				
				BOOK_ONE_ALLOCATION2(p_user_id,
									p_asset_id,
								    v_m.FUND_CD, 
								    v_m.S_SETTLE_DATE, 
								    v_m.BORROW_ID, 
								  	v_m.IM_ORDER_ID, 
								  	v_m.b_qty, 
								    v_m.b_qty, 
								  	v_fee, 
								  	var_settle_date,
								  	var_prepay_date,
								  	v_nonus_fund_loan_info.PREPAY_RATE,
								  	v_nonus_fund_loan_info.RECLAIM_RATE,
								  	v_nonus_fund_loan_info.OVERSEAS_TAX_PERCENTAGE,
								  	v_nonus_fund_loan_info.DOMESTIC_TAX_PERCENTAGE,								  	
								  	v_nonus_fund_loan_info.COLL_TYPE,
								  	v_nonus_fund_loan_info.COLLATERAL_CURRENCY_CD,
								  	0,  								  	
								  	p_borrow_request_type,
								    v_m.B_BROKER_CD,
								    'Y');
				EXIT;
			END LOOP;
			
			v_found_borrows := 'N';
			v_max_qty_borrow_id := 0;
			v_nonus_fund_loan_info := NULL;
			
			SELECT MAX(UNFILLED_QTY), COUNT(BORROW_ID) INTO v_max_qty, v_row_count 
			FROM GEC_BORROW_UNIT_TEMP WHERE STATUS <> 'F' AND
							   		 		UNFILLED_QTY > 0;
							   		 		
			FOR v_max IN max_qty_borrows
			LOOP
				v_found_borrows := 'Y';
				v_trade_country := v_max.TRADE_COUNTRY_CD;					
			
				IF v_max_qty_borrow_id = 0 THEN
					v_max_qty_borrow_id := v_max.BORROW_ID;
				END IF;
				
				EXIT WHEN v_found_borrows = 'Y';
			END LOOP;
		
			IF v_found_borrows = 'N' THEN
				RETURN 'N';
			END IF;
		
			v_found_shorts := 'N';
			v_nearest_number := 0;
			v_p_share_flag:=0;
			v_new_p_share_flag:=0;
			FOR v_n IN other_nearest
			LOOP
				v_found_shorts := 'Y';
				v_p_share_flag :=v_new_p_share_flag;
				v_new_p_share_flag := v_n.P_SHARES_FLAG;
				IF (v_p_share_flag=1 AND v_new_p_share_flag=0) THEN
					EXIT;
				END IF;
				IF v_n.o_qty > v_n.b_qty THEN
					IF v_nearest_number = 0 THEN
						v_nearest_number := v_n.o_qty;
						v_temp_order_id := v_n.IM_ORDER_ID;
						v_fund_cd := v_n.FUND_CD;
						v_short_settle_date := v_n.S_SETTLE_DATE; 
						v_borrow_id := v_n.BORROW_ID; 
						v_borrow_qty := v_n.b_qty; 
						v_broker_cd := v_n.B_BROKER_CD;
						v_position_flag := v_n.POSITION_FLAG;
						v_prepay_date := v_n.PREPAY_DATE;							
					END IF;
				ELSE
					IF v_n.o_qty>v_nearest_number THEN
						v_nearest_number := v_n.o_qty;
						v_temp_order_id := v_n.IM_ORDER_ID;
						v_fund_cd := v_n.FUND_CD;
						v_short_settle_date := v_n.S_SETTLE_DATE; 
						v_borrow_id := v_n.BORROW_ID; 
						v_borrow_qty := v_n.b_qty; 
						v_broker_cd := v_n.B_BROKER_CD;
						v_position_flag := v_n.POSITION_FLAG;
						v_prepay_date := v_n.PREPAY_DATE;	
					END IF;					
				END IF;
				
				EXIT WHEN v_n.o_qty > v_n.b_qty;
			END LOOP;
			
			IF v_found_shorts = 'N' THEN
				IF v_row_count = 1 THEN
					RETURN 'N';
				ELSE
					UPDATE GEC_BORROW_UNIT_TEMP SET STATUS = 'F' WHERE BORROW_ID = v_max_qty_borrow_id;
				END IF;
			ELSE
				-- calc default fee
				v_loan_index := v_fund_cd || '_' || v_trade_country;			
				IF v_position_flag <> 'SP' AND v_trade_country IN (GEC_CONSTANTS_PKG.C_COUNTRY_US, GEC_CONSTANTS_PKG.C_COUNTRY_CA) THEN
					v_fee := GET_FUND_RATE_FROM_MAP(p_borrow_request_type, v_fund_cd, v_trade_country, v_loan_index, v_error_code, p_rate_map);
					IF v_error_code IS NOT NULL THEN
						p_error_code := v_error_code;
						p_error_hint := v_fund_cd;
						RETURN 'N';
					END IF;
				END IF;
				-- pshare
				SELECT 
				TRADE_COUNTRY_CD
				INTO
				v_trade_country
				FROM
				GEC_ASSET
				WHERE 
				ASSET_ID=p_asset_id;
				GET_LOAN_DEF_SET_PRE_DATE(p_borrow_request_type,v_fund_cd,v_trade_country,v_short_settle_date,var_prepay_date,var_settle_date);
				-- pshare
				
				v_loan_index2 := p_borrow_request_type||'_'||v_fund_cd || '_' || v_trade_country;	
				-- calc default non us loan info	
				-- to fix the defect PRTLB00868641 ,because of using a wrong key,we use a new key v_loan_index2 instead of v_loan_index	
				v_nonus_fund_loan_info := GET_NONUS_EX_LOAN_INFO_MAP(p_borrow_request_type, v_fund_cd, v_trade_country, v_loan_index2, var_settle_date, var_prepay_date, v_error_code, p_ex_loan_info_map);
				IF v_error_code IS NOT NULL THEN
					p_error_code := v_error_code;
					p_error_hint := v_fund_cd;
					RETURN 'N';
				END IF;									
				
				v_update_flag := 'Y';
				IF v_nearest_number >= v_borrow_qty AND v_row_count = 1 THEN
					v_update_flag := 'N';
				END IF;
				
				BOOK_ONE_ALLOCATION2(p_user_id,
									p_asset_id,
								    v_fund_cd, 
								    v_short_settle_date, 
								    v_borrow_id, 
								  	v_temp_order_id, 
								  	v_borrow_qty, 
								    v_nearest_number, 
								    v_fee, 
								  	var_settle_date,
								    var_prepay_date,
								    v_nonus_fund_loan_info.PREPAY_RATE,
								  	v_nonus_fund_loan_info.RECLAIM_RATE,
								  	v_nonus_fund_loan_info.OVERSEAS_TAX_PERCENTAGE,
								  	v_nonus_fund_loan_info.DOMESTIC_TAX_PERCENTAGE,								  	
								  	v_nonus_fund_loan_info.COLL_TYPE,
								  	v_nonus_fund_loan_info.COLLATERAL_CURRENCY_CD,
								  	0,									  	
								  	p_borrow_request_type,
								    v_broker_cd,
								    v_update_flag);
			END IF;
			
			IF v_nearest_number >= v_borrow_qty AND v_row_count = 1 THEN
				RETURN 'N';
			ELSE
				RETURN 'Y';
			END IF;
		END IF;
		
		RETURN 'N';
	END SINGLE_ALLOCATION;
	
	FUNCTION GET_EQUILEND_PREPAY_RATE(p_transaction_cd IN VARCHAR2, p_broker_cd IN VARCHAR2) RETURN NUMBER
	IS
		var_prepay_rate GEC_COUNTERPARTY.PREPAY_RATE%type;
		var_bench_index GEC_COUNTERPARTY.BENCHMARK_INDEX_CD%type;
	BEGIN
	
		BEGIN
			SELECT PREPAY_RATE, BENCHMARK_INDEX_CD INTO var_prepay_rate, var_bench_index FROM GEC_COUNTERPARTY 										
			WHERE COUNTERPARTY_CD = p_broker_cd AND 
			TRANSACTION_CD = p_transaction_cd;
		EXCEPTION WHEN NO_DATA_FOUND THEN
			var_prepay_rate := NULL;
          	var_bench_index := NULL;
        END;
          		
		IF var_prepay_rate IS NULL AND var_bench_index IS NOT NULL THEN
			BEGIN
				SELECT RATE INTO var_prepay_rate FROM GEC_BENCHMARK_INDEX_RATE
				WHERE BENCHMARK_INDEX_CD = var_bench_index;
          	EXCEPTION WHEN NO_DATA_FOUND THEN
            	var_prepay_rate := NULL;
          	END;					
		END IF;		
		
		RETURN var_prepay_rate;
	END GET_EQUILEND_PREPAY_RATE;
	
	FUNCTION GET_NONUS_EX_LOAN_INFO_MAP(p_borrow_request_type IN VARCHAR2, p_fund_cd IN VARCHAR2, p_trade_country_cd IN VARCHAR2, p_loan_index IN VARCHAR2, p_borrow_settle_date IN NUMBER, p_prepay_date IN NUMBER, p_error_code OUT NOCOPY VARCHAR2, p_nonus_loan_info_map IN OUT NOCOPY NONUS_EX_LOAN_INFO_MAP) RETURN NONUS_FUND_EX_LOAN_INFO
	IS
		var_nonus_fund_loan_info NONUS_FUND_EX_LOAN_INFO;
		var_fee GEC_G1_BOOKING.RATE%type;
		v_error_code VARCHAR2(10);
		v_found VARCHAR2(1);
	BEGIN
		v_found := 'Y';	
		BEGIN
			var_nonus_fund_loan_info := p_nonus_loan_info_map(p_loan_index);
		EXCEPTION WHEN NO_DATA_FOUND THEN
			var_nonus_fund_loan_info := GET_NONUS_EX_LOAN_INFO(p_borrow_request_type, p_fund_cd, p_trade_country_cd, p_borrow_settle_date, p_prepay_date, v_error_code);
					
			IF v_error_code IS NULL THEN -- add to map
				p_nonus_loan_info_map(p_loan_index) := var_nonus_fund_loan_info;
			ELSE
				p_error_code := v_error_code;
			END IF;
			v_found := 'N';			
		END;
		
		IF v_found = 'Y' THEN
			IF var_nonus_fund_loan_info.RECLAIM_RATE IS NULL OR var_nonus_fund_loan_info.OVERSEAS_TAX_PERCENTAGE IS NULL OR
			   var_nonus_fund_loan_info.DOMESTIC_TAX_PERCENTAGE IS NULL OR var_nonus_fund_loan_info.COLLATERAL_CURRENCY_CD IS NULL OR
			   var_nonus_fund_loan_info.COLL_TYPE IS NULL OR var_nonus_fund_loan_info.PREPAY_RATE IS NULL THEN
			   var_nonus_fund_loan_info := GET_NONUS_EX_LOAN_INFO(p_borrow_request_type, p_fund_cd, p_trade_country_cd, p_borrow_settle_date, p_prepay_date, v_error_code);
			   
			   IF v_error_code IS NULL THEN -- add to map
				  p_nonus_loan_info_map(p_loan_index) := var_nonus_fund_loan_info;
			   ELSE
				  p_error_code := v_error_code;
			   END IF;
			END IF;			   
		END IF;	
		IF p_borrow_request_type IS NOT NULL AND p_borrow_request_type <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND p_trade_country_cd IS NOT NULL AND p_trade_country_cd<>'US' AND p_trade_country_cd<>'CA' THEN
			--MF19.3.1. If collateral Type of this fund’s G1 loan is C (for Cash) and  NSB Prepay Date is less than Loan Setl Date, then Prepay rate is required, Prepay Rate will get from loan Counterparty static data. if not found from ‘Manage Prepay Rates’, then highlight the prepay rate field with tips
			IF var_nonus_fund_loan_info.COLL_TYPE = 'N' THEN
				var_nonus_fund_loan_info.PREPAY_RATE := NULL;
			END IF;	
		ELSE
			IF p_prepay_date = p_borrow_settle_date THEN
			var_nonus_fund_loan_info.PREPAY_RATE := NULL;
			END IF;			
			
			--MF19.3.1. If collateral Type of this fund’s G1 loan is C (for Cash) and  NSB Prepay Date is less than Loan Setl Date, then Prepay rate is required, Prepay Rate will get from loan Counterparty static data. if not found from ‘Manage Prepay Rates’, then highlight the prepay rate field with tips
			IF var_nonus_fund_loan_info.COLL_TYPE = 'N' THEN
				var_nonus_fund_loan_info.PREPAY_RATE := NULL;
			END IF;	
		END IF;
		
		RETURN var_nonus_fund_loan_info;
	END GET_NONUS_EX_LOAN_INFO_MAP;	
	
	
	FUNCTION GET_FUND_RATE_FROM_MAP(p_borrow_request_type IN VARCHAR2, p_fund_cd IN VARCHAR2, p_trade_country_cd IN VARCHAR2, p_loan_index IN VARCHAR2, p_error_code OUT NOCOPY VARCHAR2, p_rate_map IN OUT NOCOPY FUND_RATE_MAP) RETURN NUMBER
	IS
		var_fund_rate FUND_RATE;
		var_fee GEC_G1_BOOKING.RATE%type;
		v_error_code VARCHAR2(10);
		v_found VARCHAR2(1);
	BEGIN
		v_found := 'Y';
		BEGIN
			var_fund_rate := p_rate_map(p_loan_index);
		EXCEPTION WHEN NO_DATA_FOUND THEN
			IF p_borrow_request_type = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB THEN -- SB
				var_fee := GET_LOAN_RATE(p_borrow_request_type, p_fund_cd, p_trade_country_cd, NULL, v_error_code);
					
				IF v_error_code IS NULL THEN -- add to map
					SELECT p_loan_index, NULL, var_fee INTO var_fund_rate FROM DUAL;
					p_rate_map(p_loan_index) := var_fund_rate;
				ELSE
					p_error_code := v_error_code;
				END IF;
			ELSE
				var_fee := GET_LOAN_RATE(p_borrow_request_type, p_fund_cd, p_trade_country_cd, NULL, v_error_code);
					
				IF v_error_code IS NULL THEN -- add to map
					SELECT p_loan_index, var_fee, var_fund_rate.SB_RATE INTO var_fund_rate FROM DUAL;
					p_rate_map(p_loan_index) := var_fund_rate;
				ELSE
					p_error_code := v_error_code;
				END IF;
			END IF;
			v_found := 'N';
		END;
		
		IF v_found = 'Y' THEN
			IF p_borrow_request_type = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB THEN -- SB
				IF var_fund_rate.SB_RATE IS NULL THEN
					var_fee := GET_LOAN_RATE(p_borrow_request_type, p_fund_cd, p_trade_country_cd, NULL, v_error_code);
					
					IF v_error_code IS NULL THEN -- add to map
						SELECT p_loan_index, var_fund_rate.NSB_RATE, var_fee INTO var_fund_rate FROM DUAL;
						p_rate_map(p_loan_index) := var_fund_rate;
					ELSE
						p_error_code := v_error_code;
					END IF;
				ELSE
					var_fee := var_fund_rate.SB_RATE;
				END IF;
			ELSE
				IF var_fund_rate.NSB_RATE IS NULL THEN
					var_fee := GET_LOAN_RATE(p_borrow_request_type, p_fund_cd, p_trade_country_cd, NULL, v_error_code);
					
					IF v_error_code IS NULL THEN -- add to map
						SELECT p_loan_index, var_fee, var_fund_rate.SB_RATE INTO var_fund_rate FROM DUAL;
						p_rate_map(p_loan_index) := var_fund_rate;
					ELSE
						p_error_code := v_error_code;
					END IF;
				ELSE
					var_fee := var_fund_rate.NSB_RATE;
				END IF;
			END IF;
		END IF;
		
		RETURN var_fee;
	END GET_FUND_RATE_FROM_MAP;
	
	
	-- p_status  'S' - succesful
	-- 			 'VE'- validation error
	--           'SE'- BR6
	--           'QE'- allocated qty is not equal to borrow qty(may because of broker code / coll type / coll code / asset id NOT matching)
	-- 			 'FE'- can't get fee
	PROCEDURE SAVE_NO_DEMANDS(p_user_id IN VARCHAR2, p_status OUT VARCHAR2, p_borrows_cursor OUT SYS_REFCURSOR, p_shorts_cursor OUT SYS_REFCURSOR, p_allo_cursor OUT SYS_REFCURSOR, p_error_code OUT VARCHAR2)
	IS
		var_sb_continue VARCHAR2(1);
		var_age_continue VARCHAR2(1);
		var_nsb_continue VARCHAR2(1);
		
		var_error VARCHAR(1);
		var_valid VARCHAR(1);
		var_error_code VARCHAR(10);
		var_across VARCHAR(1);
		var_borrow_id GEC_BORROW.BORROW_ID%type;
		
		var_count NUMBER(10);
		var_loop_count NUMBER(10);
		CURSOR run_units IS
			SELECT DISTINCT ASSET_ID, R_ALLOC_KEY 
			FROM GEC_BORROW_TEMP;
		
		CURSOR no_filled_borrows IS
			SELECT BORROW_ID FROM GEC_BORROW_TEMP WHERE UNFILLED_QTY > 0;
			
		CURSOR no_cash_borrow_fail IS
			SELECT o.IM_ORDER_ID FROM GEC_BORROW_TEMP b, GEC_IM_ORDER_TEMP o
			WHERE b.ASSET_ID = o.ASSET_ID AND
				  (b.COLLATERAL_CURRENCY_CD = o.SB_COLLATERAL_CURRENCY_CD AND b.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB OR b.COLLATERAL_CURRENCY_CD = o.NSB_COLLATERAL_CURRENCY_CD AND b.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB) AND
				  (b.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND b.BROKER_CD = o.SB_BROKER_CD OR b.AGENCY_FLAG = 'Y' AND b.BROKER_CD = o.NSB_BROKER_CD OR b.AGENCY_FLAG = 'N') AND
				  b.NON_CASH_FLAG='Y' AND
				  (b.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND o.SB_COLLATERAL_TYPE <> 'CASH' OR b.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND o.NSB_COLLATERAL_TYPE <> 'CASH') AND 
				  b.BRANCH_CD = o.BRANCH_CD AND
				   (b.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND b.SETTLE_DATE <= o.SETTLE_DATE OR b.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND b.SETTLE_DATE <= o.SETTLE_DATE) AND
				  (b.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND o.SB_ALLOC_QTY > o.FILLED_SB_QTY OR b.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND o.NSB_ALLOC_QTY > o.FILLED_NSB_QTY) AND
				  b.BORROW_ID = var_borrow_id AND
				  rownum = 1;
			
		CURSOR no_filled_allos IS
			SELECT b.BORROW_ID, o.IM_ORDER_ID FROM GEC_BORROW_TEMP b, GEC_IM_ORDER_TEMP o 
			WHERE o.ASSET_ID = b.ASSET_ID AND
				  o.R_ALLOC_KEY = b.R_ALLOC_KEY AND
				  (o.SB_ALLOC_QTY > o.FILLED_SB_QTY OR o.NSB_ALLOC_QTY > o.FILLED_NSB_QTY);
	BEGIN
		var_error := 'N';
		p_status := 'S';
		PREPARE_TEMP_BORROWS(NULL, NULL, NULL, var_valid);
		PREPARE_TEMP_ORDERS(p_user_id, 'N', var_valid);
		
		IF var_valid = 'N' THEN
			p_status := 'VE';
			FILL_ERROR_RST(p_shorts_cursor, p_borrows_cursor);
			FILL_ALLO_ERROR_RST(p_allo_cursor);
			RETURN;
		END IF;
		
		-- insert temp borrow to gec_borrow table
		INSERT INTO GEC_BORROW(  BORROW_ID,
  								 BORROW_ORDER_ID,
  								 ASSET_ID,
  								 BROKER_CD,
  								 TRADE_DATE,
  								 SETTLE_DATE,
  								 COLLATERAL_TYPE,
  								 COLLATERAL_CURRENCY_CD,
  								 COLLATERAL_LEVEL,
  								 BORROW_QTY,
  								 RATE,
  								 PRICE,
  								 POSITION_FLAG,
  								 COMMENT_TXT,
				   				 PREPAY_DATE,
  								 PREPAY_RATE,
  								 RECLAIM_RATE,
  				   				 OVERSEAS_TAX_PERCENTAGE,
  				   				 DOMESTIC_TAX_PERCENTAGE,
  				   				 MINIMUM_FEE,
  				   				 MINIMUM_FEE_CD,
  				   				 BOOK_G1_BORROW_FLAG,	  								 
  								 G1_EXTRACTED_AT,
  								 NO_DEMAND_FLAG,
  								 LOAN_NO,
  								 TYPE,
  								 INTERVENTION_REASON,
  								 STATUS,
	  							 CREATED_BY,
	  							 CREATED_AT,
	  							 UPDATED_BY,
	  							 UPDATED_AT,								 
  								 LINK_REFERENCE,
  								 TERM_DATE,
  								 EXPECTED_RETURN_DATE)
  		SELECT t.BORROW_ID,
  		       t.BORROW_ORDER_ID,
  			   t.ASSET_ID,
  			   NVL(m.BROKER_CD, t.BROKER_CD),
  			   t.TRADE_DATE,
  			   t.SETTLE_DATE,
  			   t.COLLATERAL_TYPE,
  			   t.COLLATERAL_CURRENCY_CD,
  			   t.COLLATERAL_LEVEL,
  			   t.BORROW_QTY,
  			   t.RATE,
  			   t.PRICE,
  			   t.POSITION_FLAG,
  			   t.COMMENT_TXT,
  			   t.PREPAY_DATE,
  			   t.PREPAY_RATE,
  			   t.RECLAIM_RATE,
  			   t.OVERSEAS_TAX_PERCENTAGE,
  			   t.DOMESTIC_TAX_PERCENTAGE,
  			   t.MINIMUM_FEE,
  			   t.MINIMUM_FEE_CD,
  			   t.BOOK_G1_BORROW_FLAG,  			   
  			   t.G1_EXTRACTED_AT,
  			   'Y',
  			   t.LOAN_NO,
  			   t.TYPE,
  			   t.INTERVENTION_REASON,
  			   GEC_CONSTANTS_PKG.C_BORROW_PROCESSED,
	  		   p_user_id,
	  		   sysdate,
	  		   p_user_id,
	  		   sysdate,	  			   
  			   (GEC_ALLOCATION_PKG.GENERATE_BORROW_LINK_REF()),
  			   t.TERM_DATE,
  			   t.EXPECTED_RETURN_DATE
  		FROM GEC_BORROW_TEMP t, GEC_BROKER_VW m
	  		WHERE t.BROKER_CD = m.DML_BROKER_CD AND
	  				t.NON_CASH_FLAG = m.NON_CASH_AGENCY_FLAG;
  		

-----------------------------------------------------------------------------------------------------------
-----------------------------BEGIN MAIN REVERSE AUTO ALLOCATION--------------------------------------------
-----------------------------------------------------------------------------------------------------------  			
		var_error_code := NULL;
		var_across:='N';
		var_loop_count:=2;
		WHILE var_loop_count>0
		LOOP
			FOR r_u IN run_units
			LOOP
				CALC_RUN_COUNT(r_u.R_ALLOC_KEY, var_count);
				
				var_sb_continue := 'Y';
				var_age_continue := 'Y';
				var_nsb_continue := 'Y';
				WHILE (var_sb_continue = 'Y' OR var_age_continue = 'Y' OR var_nsb_continue='Y') AND var_count>=0
				LOOP
					IF var_sb_continue = 'Y' THEN
						var_sb_continue := REVERSE_SINGLE_ALLO_SB(p_user_id, r_u.ASSET_ID, r_u.R_ALLOC_KEY,var_across, var_error_code);
						EXIT WHEN var_error_code IS NOT NULL;
					END IF;
				
					-- first allocate for agency nsb
					IF var_age_continue = 'Y' THEN
						var_age_continue := REVERSE_SINGLE_ALLO_AGE(p_user_id, r_u.ASSET_ID, r_u.R_ALLOC_KEY,var_across, var_error_code);
						EXIT WHEN var_error_code IS NOT NULL;						
					ELSIF var_nsb_continue = 'Y' THEN
						var_nsb_continue := REVERSE_SINGLE_ALLO_NSB(p_user_id, r_u.ASSET_ID, r_u.R_ALLOC_KEY,var_across, var_error_code);
						EXIT WHEN var_error_code IS NOT NULL;						
					END IF;	
					var_count := var_count-1;
				END LOOP;
				EXIT WHEN var_error_code IS NOT NULL;
			END LOOP;
			var_across:='Y';
			var_loop_count:=var_loop_count-1;
			UPDATE GEC_IM_ORDER_TEMP SET SB_RUN_FLAG='N',NSB_RUN_FLAG='N',AGENCY_RUN_FLAG='N';
		END LOOP;
-----------------------------------------------------------------------------------------------------------
-----------------------------END MAIN REVERSE AUTO ALLOCATION--------------------------------------------
-----------------------------------------------------------------------------------------------------------  	
		-- fill the result set for p_allo_cursor
		FILL_ALLO_ERROR_RST(p_allo_cursor);
		
		IF var_error_code IS NOT NULL THEN
			p_status := 'FE';
			p_error_code := var_error_code;
			FILL_ERROR_RST(p_shorts_cursor, p_borrows_cursor);
			RETURN;
		END IF;
		
		-- checking for BR6 error
		CHECK_MULTI_SETTLEDATES(var_error);
		IF var_error = 'Y' THEN
			p_status := 'SE';
			FILL_ERROR_RST(p_shorts_cursor, p_borrows_cursor);
			RETURN;
		END IF;
		
		-- handle different prepay dates error
		CHECK_MULTI_PREPAYDATES(var_error);
		IF var_error = 'Y' THEN
		   	-- there is BR6 error
			p_status := 'PE';
			FILL_ERROR_RST(p_shorts_cursor, p_borrows_cursor);
			RETURN;
		END IF;			

		-- checking if qty matching
		FOR n_b IN no_filled_borrows
		LOOP
			var_borrow_id := n_b.BORROW_ID;
			UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR WHERE BORROW_ID = var_borrow_id;
			FOR n_c_f IN no_cash_borrow_fail
			LOOP
				UPDATE GEC_BORROW_TEMP SET ERROR_CODE = 'VLD0118' WHERE BORROW_ID = var_borrow_id;
			END LOOP;
			var_error := 'Y';
		END LOOP;
		FOR n_a IN no_filled_allos
		LOOP
			UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR WHERE BORROW_ID = n_a.BORROW_ID;
			var_error := 'Y';
		END LOOP;
		
		IF var_error = 'Y' THEN
			p_status := 'QE';
			FILL_ERROR_RST(p_shorts_cursor, p_borrows_cursor);
			RETURN;
		END IF;
		
		-- insert into GEC_SSGM_LOAN for fund of 0189
		INSERT INTO GEC_SSGM_LOAN(
			GEC_SSGM_LOAN_ID,
  			ALLOCATION_ID,
  			ASSET_ID,
  			STATUS,
  			TRADE_DATE,
  			SETTLE_DATE,
  			SSGM_LOAN_QTY,
  			RATE,
  			CREATED_AT,
  			CREATED_BY,
  			UPDATED_AT,  			
  			UPDATED_BY
		)SELECT 
			GEC_SSGM_LOAN_ID_SEQ.nextval,
			a.ALLOCATION_ID,
			t.ASSET_ID,
			'O',
			t.TRADE_DATE,
			a.SETTLE_DATE,
			a.ALLOCATION_QTY,
			a.RATE,
			sysdate,
			p_user_id,
			sysdate,			
			p_user_id
		FROM GEC_ALLOCATION a, GEC_IM_ORDER o, GEC_BORROW_TEMP t
			WHERE a.IM_ORDER_ID = o.IM_ORDER_ID AND
				a.BORROW_ID = t.BORROW_ID AND
				o.FUND_CD = '0189' AND
				o.SOURCE_CD = GEC_CONSTANTS_PKG.C_SOURCE_CD_NO_DEMAND;
		
		OPEN p_borrows_cursor FOR
				SELECT t.BORROW_ID as BORROW_ID, NULL as TRADE_DATE, NULL as BORROW_ORDER_ID, NULL as ASSET_ID,NULL as BROKER_CD, NULL as SETTLE_DATE,NULL as COLLATERAL_TYPE, NULL as COLLATERAL_CURRENCY_CD,
					NULL as COLLATERAL_LEVEL,NULL as BORROW_QTY,NULL as RATE,NULL as POSITION_FLAG,NULL as COMMENT_TXT,NULL as TYPE,NULL as STATUS,NULL as CREATED_AT,NULL as CREATED_BY,NULL as TRADE_COUNTRY_CD,
					NULL as UPDATED_AT,NULL as UPDATED_BY,NULL as PRICE, NULL as NO_DEMAND_FLAG, NULL as INTERVENTION_REASON, NULL as RESPONSE_LOG_NUM, NULL as CUSIP, NULL as SEDOL, NULL as ISIN,NULL as QUIK, NULL as TICKER, NULL as ASSET_CODE, NULL as BORROW_REQUEST_TYPE, NULL as UI_ROW_NUMBER, NULL as ERROR_CODE,
					NULL as PREPAY_DATE, NULL as PREPAY_RATE, NULL as RECLAIM_RATE, NULL as OVERSEAS_TAX_PERCENTAGE, NULL as DOMESTIC_TAX_PERCENTAGE, NULL as MINIMUM_FEE,NULL as MINIMUM_FEE_CD, NULL AS EQUILEND_MESSAGE_ID,NULL as TERM_DATE,NULL as EXPECTED_RETURN_DATE
				FROM GEC_BORROW_TEMP t;
				
		OPEN p_shorts_cursor FOR
				SELECT o.IM_ORDER_ID, o.ASSET_ID, o.TRADE_COUNTRY_CD,o.FUND_CD,o.SB_BROKER_CD,o.CUSIP,o.SHARE_QTY,o.FILLED_QTY,o.TRANSACTION_CD,o.REQUEST_ID as REQUEST_ID,
					o.SHARE_QTY - o.FILLED_QTY as UNFILLED_QTY,o.SETTLE_DATE,o.TICKER,o.SEDOL,o.ISIN,o.QUIK,o.DESCRIPTION,o.RATE,f.NSB_COLLATERAL_TYPE, f.COLLATERAL_CURRENCY_CD,
					0 as REQUIREMANUAL,o.SOURCE_CD, tc.TRADING_DESK_CD, o.STATUS, o.POSITION_FLAG, UPPER(gat.ASSET_TYPE_DESC) as SECURITY_TYPE,
					o.G1_EXTRACTED_FLAG, o.EXPORT_STATUS, o.HOLDBACK_FLAG, CASE WHEN o.FILLED_QTY > 0 THEN 'Y' ELSE 'N' END as HAS_ALLOCATION,f.BRANCH_CD
				FROM GEC_IM_ORDER o
				JOIN GEC_FUND f ON o.FUND_CD = f.FUND_CD
				JOIN GEC_ASSET_TYPE gat ON o.ASSET_TYPE_ID = gat.ASSET_TYPE_ID
				JOIN GEC_TRADE_COUNTRY tc ON o.TRADE_COUNTRY_CD = tc.TRADE_COUNTRY_CD
				JOIN GEC_IM_ORDER_TEMP t ON  o.IM_ORDER_ID = t.IM_ORDER_ID;
				
		DELETE FROM GEC_BORROW_TEMP;
		DELETE FROM GEC_IM_ORDER_TEMP;
				
	END SAVE_NO_DEMANDS;
	
	
	-- p_status  'S' - succesful
	-- 			 'VE'- validation error
	--           'SE'- BR6
	--           'QE'- allocated qty is not equal to borrow qty(may because of broker code / coll type / coll code / asset id NOT matching)
	--           'OE'- try to manual intervention for borrows not in 'Manual' status(may changed by other user)
	--           'FE'- can't get fee
	--           'IE'- for 2212, can't allocate to in-flight shorts for manual inputed borrows
	PROCEDURE SAVE_MANU_INTERV(p_user_id IN VARCHAR2, p_asset_id IN NUMBER, p_status OUT VARCHAR2, p_borrows_cursor OUT SYS_REFCURSOR, p_shorts_cursor OUT SYS_REFCURSOR, p_allo_cursor OUT SYS_REFCURSOR, p_error_code OUT VARCHAR2, p_borrow_request_id OUT NUMBER)
	IS
		var_im_order_id GEC_IM_ORDER.IM_ORDER_ID%type;
		var_sb_continue VARCHAR2(1);
		var_nsb_continue VARCHAR2(1);
		var_age_continue VARCHAR2(1);
		var_count NUMBER(10);
		var_loop_count NUMBER(10);
		var_error VARCHAR2(1);
		var_valid VARCHAR2(1);
		var_error_code VARCHAR2(10);
		var_request_flag VARCHAR2(1);
		var_across VARCHAR(1);
		var_borrow_id GEC_BORROW.BORROW_ID%type;
		var_borrow_request_id GEC_BORROW_REQUEST.BORROW_REQUEST_ID%type;
		
		CURSOR no_filled_borrows IS
			SELECT BORROW_ID, NON_CASH_FLAG, BORROW_REQUEST_TYPE FROM GEC_BORROW_TEMP WHERE UNFILLED_QTY > 0;
			
		CURSOR no_cash_borrow_fail IS
			SELECT o.IM_ORDER_ID FROM GEC_BORROW_TEMP b, GEC_IM_ORDER_TEMP o
			WHERE b.ASSET_ID = o.ASSET_ID AND
				  (b.COLLATERAL_CURRENCY_CD = o.SB_COLLATERAL_CURRENCY_CD AND b.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB OR b.COLLATERAL_CURRENCY_CD = o.NSB_COLLATERAL_CURRENCY_CD AND b.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB) AND
				  (b.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND b.BROKER_CD = o.SB_BROKER_CD OR b.AGENCY_FLAG = 'Y' AND b.BROKER_CD = o.NSB_BROKER_CD OR b.AGENCY_FLAG = 'N') AND
				  b.NON_CASH_FLAG='Y' AND
				  (b.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND o.SB_COLLATERAL_TYPE <> 'CASH' OR b.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND o.NSB_COLLATERAL_TYPE <> 'CASH') AND 
				  b.BRANCH_CD = o.BRANCH_CD AND
				  (b.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND b.SETTLE_DATE <= o.SETTLE_DATE OR b.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND b.SETTLE_DATE <= o.SETTLE_DATE) AND
				  (b.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND o.SB_ALLOC_QTY > o.FILLED_SB_QTY OR b.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND o.NSB_ALLOC_QTY > o.FILLED_NSB_QTY) AND
				  b.BORROW_ID = var_borrow_id AND
				  rownum = 1;
		
		CURSOR normal_borrow_fail IS
			SELECT o.IM_ORDER_ID FROM GEC_BORROW_TEMP b, GEC_IM_ORDER_TEMP o
			WHERE b.ASSET_ID = o.ASSET_ID AND
				 (b.COLLATERAL_CURRENCY_CD = o.SB_COLLATERAL_CURRENCY_CD AND b.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB OR b.COLLATERAL_CURRENCY_CD = o.NSB_COLLATERAL_CURRENCY_CD AND b.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB) AND
				  (b.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND b.BROKER_CD = o.SB_BROKER_CD OR b.AGENCY_FLAG = 'Y' AND b.BROKER_CD = o.NSB_BROKER_CD OR b.AGENCY_FLAG = 'N') AND
				  b.NON_CASH_FLAG='N' AND
				  o.HOLDBACK_FLAG = 'C' AND
				  b.BRANCH_CD = o.BRANCH_CD AND
				  (b.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND b.SETTLE_DATE <= o.SETTLE_DATE OR b.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND b.SETTLE_DATE <= o.SETTLE_DATE) AND
				  (b.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND o.SB_ALLOC_QTY > o.FILLED_SB_QTY OR b.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND o.NSB_ALLOC_QTY > o.FILLED_NSB_QTY) AND
				  b.BORROW_ID = var_borrow_id AND
				  rownum = 1;
			
		CURSOR no_filled_allos IS
			SELECT b.BORROW_ID FROM GEC_BORROW_TEMP b, GEC_IM_ORDER_TEMP o 
			WHERE o.ASSET_ID = b.ASSET_ID AND
				  o.R_ALLOC_KEY = b.R_ALLOC_KEY AND
				  (o.SB_ALLOC_QTY > o.FILLED_SB_QTY OR o.NSB_ALLOC_QTY > o.FILLED_NSB_QTY);
		
		-- added for 2212, can't allocate to in-flight shorts for manual inputed borrows	  
		CURSOR check_export_st IS
			SELECT 1 FROM GEC_BORROW_TEMP b, GEC_ALLOCATION a, GEC_IM_ORDER o
			WHERE b.BORROW_ID = a.BORROW_ID AND
					a.IM_ORDER_ID = o.IM_ORDER_ID AND
					o.EXPORT_STATUS IN ('I','P') AND
					b.TYPE = GEC_CONSTANTS_PKG.C_BORROW_MANUAL_INPUT;
				  
		CURSOR in_flight_orders IS
			SELECT o.IM_ORDER_ID, o.MATCHED_ID FROM GEC_IM_ORDER o, GEC_IM_ORDER_TEMP ot
			WHERE 	o.IM_ORDER_ID = ot.IM_ORDER_ID AND
					o.EXPORT_STATUS = 'I' AND
					EXISTS(
								SELECT 1 FROM GEC_BORROW_ORDER bo, 
								GEC_BORROW_ORDER_DETAIL detail, 
								(select  bo.borrow_request_id from gec_borrow_temp temp, gec_borrow_order bo, gec_borrow_order_detail detail,  gec_allocation a where  temp.borrow_order_id = bo.borrow_order_id and detail.borrow_order_id = bo.borrow_order_id and a.borrow_id = temp.borrow_id and temp.borrow_order_id is not null) request_id
								WHERE detail.BORROW_ORDER_ID = bo.BORROW_ORDER_ID AND
									  detail.IM_ORDER_ID = o.IM_ORDER_ID AND
									  bo.BORROW_REQUEST_ID = request_id.BORROW_REQUEST_ID
							);			
				
		CURSOR sb_only_orders IS
			SELECT o.IM_ORDER_ID 
			FROM GEC_IM_ORDER o, GEC_BORROW_TEMP t, GEC_ALLOCATION a, GEC_IM_ORDER_TEMP ot
			WHERE t.BORROW_ID = a.BORROW_ID AND
			      a.IM_ORDER_ID = o.IM_ORDER_ID AND
			      o.IM_ORDER_ID = ot.IM_ORDER_ID AND
			      o.TRANSACTION_CD = GEC_CONSTANTS_PKG.C_SB_SHORT AND
			      o.EXPORT_STATUS <> 'I'
			UNION	
			SELECT o.IM_ORDER_ID 		
			FROM GEC_IM_ORDER o, GEC_IM_ORDER_TEMP ot
			WHERE o.IM_ORDER_ID = ot.IM_ORDER_ID AND
				  o.TRANSACTION_CD = GEC_CONSTANTS_PKG.C_SB_SHORT AND
				  o.EXPORT_STATUS = 'I' AND
				  EXISTS(
							SELECT 1 FROM GEC_BORROW_ORDER bo, 
							GEC_BORROW_ORDER_DETAIL detail, 
							(select  bo.borrow_request_id from gec_borrow_temp temp, gec_borrow_order bo, gec_borrow_order_detail detail,  gec_allocation a where  temp.borrow_order_id = bo.borrow_order_id and detail.borrow_order_id = bo.borrow_order_id and a.borrow_id = temp.borrow_id and temp.borrow_order_id is not null) request_id
							WHERE detail.BORROW_ORDER_ID = bo.BORROW_ORDER_ID AND
								  detail.IM_ORDER_ID = o.IM_ORDER_ID AND
								  bo.BORROW_REQUEST_ID = request_id.BORROW_REQUEST_ID
						);					  
				  
		CURSOR borrows IS	
			SELECT BORROW_ORDER_ID FROM GEC_BORROW_TEMP WHERE BORROW_ORDER_ID IS NOT NULL;
			  		 		
	BEGIN
		var_error := 'N';
		p_status := 'S';
		var_request_flag := 'N';
		
		-- prepare gec_im_order_temp
		-- lock gec_im_order for the existed shorts, lock sequence 1
		PREPARE_TEMP_ORDERS(p_user_id, 'M', var_valid);
		
		-- lock gec_borrow for the existed borrows, lock sequence 2
		CHECK_MUANUAL_BORROW_STATUS(var_valid);
		IF var_valid = 'N' THEN
			p_status := 'OE';
			FILL_ERROR_RST(p_shorts_cursor, p_borrows_cursor);
			FILL_ALLO_ERROR_RST(p_allo_cursor);
			RETURN;
		END IF;
		
		-- Prepare borrow temp
		PREPARE_TEMP_BORROWS(NULL, NULL, NULL, var_valid);
		
		IF var_valid = 'N' THEN
			p_status := 'VE';
			FILL_ERROR_RST(p_shorts_cursor, p_borrows_cursor);
			FILL_ALLO_ERROR_RST(p_allo_cursor);
			RETURN;
		ELSIF var_valid = 'E' THEN
			p_status := 'OE';
			FILL_ERROR_RST(p_shorts_cursor, p_borrows_cursor);
			FILL_ALLO_ERROR_RST(p_allo_cursor);
			RETURN;
		END IF;
		
		
		-- delete privious generated 'T' allocations, lock gec_allocation, lock sequence 3
		DELETE FROM GEC_ALLOCATION a WHERE  EXISTS(
												SELECT 1 FROM GEC_BORROW_TEMP t 
												WHERE a.BORROW_ID = t.BORROW_ID	
											);
	
		
		-- set the R_ALLOC_KEY to dummy for borrow temp and im_order_temp
		UPDATE GEC_IM_ORDER_TEMP SET R_ALLOC_KEY = 'DUMMY';
		UPDATE GEC_BORROW_TEMP SET R_ALLOC_KEY = 'DUMMY';
		
-----------------------------------------------------------------------------------------------------------
-----------------------------BEGIN MAIN REVERSE AUTO ALLOCATION--------------------------------------------
-----------------------------------------------------------------------------------------------------------  			
		var_error_code := NULL;
		
		-- make sure to elimate dead lock
		
		var_across:='N';
		var_loop_count:=2;
		WHILE var_loop_count>0
		LOOP
			CALC_RUN_COUNT('DUMMY', var_count);
			var_sb_continue := 'Y';
			var_nsb_continue := 'Y';
			var_age_continue := 'Y';
			WHILE (var_sb_continue = 'Y' OR var_nsb_continue = 'Y' OR var_age_continue = 'Y') AND var_count>=0
			LOOP
				IF var_sb_continue = 'Y' THEN
					var_sb_continue := REVERSE_SINGLE_ALLO_SB(p_user_id, p_asset_id, 'DUMMY',var_across, var_error_code);
					EXIT WHEN var_error_code IS NOT NULL;
				END IF;
				
				-- first allocate for agency nsb
				IF var_age_continue = 'Y' THEN
					var_age_continue := REVERSE_SINGLE_ALLO_AGE(p_user_id, p_asset_id, 'DUMMY',var_across, var_error_code);
					EXIT WHEN var_error_code IS NOT NULL;				
				ELSIF var_nsb_continue = 'Y' THEN
					var_nsb_continue := REVERSE_SINGLE_ALLO_NSB(p_user_id, p_asset_id, 'DUMMY',var_across, var_error_code);
					EXIT WHEN var_error_code IS NOT NULL;	
				END IF;	
				
				var_count:=var_count-1;
				
				EXIT WHEN var_error_code IS NOT NULL;
			END LOOP;
			var_across:='Y';
			var_loop_count:=var_loop_count-1;
			UPDATE GEC_IM_ORDER_TEMP SET SB_RUN_FLAG='N',NSB_RUN_FLAG='N',AGENCY_RUN_FLAG='N';
		END LOOP;
-----------------------------------------------------------------------------------------------------------
-----------------------------END MAIN REVERSE AUTO ALLOCATION---------------------------------------------
-----------------------------------------------------------------------------------------------------------  
		-- fill the result set for p_allo_cursor
		FILL_ALLO_ERROR_RST(p_allo_cursor);
				
		IF var_error_code IS NOT NULL THEN
			p_status := 'FE';
			p_error_code := var_error_code;
			FILL_ERROR_RST(p_shorts_cursor, p_borrows_cursor);
			RETURN;
		END IF;
		
		-- checking for BR6 error
		CHECK_MULTI_SETTLEDATES(var_error);
		IF var_error = 'Y' THEN
			p_status := 'SE';
			FILL_ERROR_RST(p_shorts_cursor, p_borrows_cursor);
			RETURN;
		END IF;
		
		-- handle different prepay dates error
		CHECK_MULTI_PREPAYDATES(var_error);
		IF var_error = 'Y' THEN
		   	-- there is BR6 error
			p_status := 'PE';
			FILL_ERROR_RST(p_shorts_cursor, p_borrows_cursor);
			RETURN;
		END IF;			
		
		-- checking if qty matching
		FOR n_b IN no_filled_borrows
		LOOP
			var_borrow_id := n_b.BORROW_ID;
			UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR WHERE BORROW_ID = var_borrow_id;
			
			IF n_b.NON_CASH_FLAG = 'Y' THEN
				FOR n_c_f IN no_cash_borrow_fail
				LOOP
					UPDATE GEC_BORROW_TEMP SET ERROR_CODE = 'VLD0118' WHERE BORROW_ID = var_borrow_id;
				END LOOP;
			ELSE
				FOR n_b_f IN normal_borrow_fail
				LOOP
					UPDATE GEC_BORROW_TEMP SET ERROR_CODE = 'VLD0117' WHERE BORROW_ID = var_borrow_id;
				END LOOP;
			END IF;
			var_error := 'Y';
		END LOOP;
		
		FOR n_a IN no_filled_allos
		LOOP
			UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR WHERE BORROW_ID = n_a.BORROW_ID;
			var_error := 'Y';
		END LOOP;
		
		IF var_error = 'Y' THEN
			p_status := 'QE';
			FILL_ERROR_RST(p_shorts_cursor, p_borrows_cursor);
			RETURN;
		END IF;
		
		FOR e_s IN check_export_st
		LOOP
			var_error := 'Y';
			EXIT;
		END LOOP;
		
		IF var_error = 'Y' THEN
			p_status := 'IE';
			FILL_ERROR_RST(p_shorts_cursor, p_borrows_cursor);
			RETURN;
		END IF;
		
		-- set borrow status to 'P' after the manual intervention
		IF p_status = 'S' THEN
			UPDATE GEC_BORROW b SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_PROCESSED,
				  					UPDATED_BY = p_user_id,
				  					UPDATED_AT = sysdate
			WHERE STATUS = GEC_CONSTANTS_PKG.C_BORROW_MANUAL AND
				EXISTS(SELECT 1 FROM GEC_BORROW_TEMP t
							WHERE t.BORROW_ID = b.BORROW_ID);
		END IF;
		
		-- set the in-flight to R-esponsed
		-- set pending cancel to C-ancel, short cancel to M-atched
		FOR in_o IN in_flight_orders
		LOOP
			UPDATE GEC_IM_ORDER o SET o.EXPORT_STATUS = CASE WHEN o.TRANSACTION_CD = GEC_CONSTANTS_PKG.C_SB_SHORT THEN 'C' ELSE 'R' END, o.UPDATED_AT= sysdate,o.UPDATED_BY = p_user_id  WHERE o.IM_ORDER_ID = in_o.IM_ORDER_ID ;
			IF in_o.MATCHED_ID IS NOT NULL THEN
				UPDATE GEC_IM_ORDER o SET o.STATUS = 'C', 
										  o.UPDATED_BY = p_user_id,
										  o.UPDATED_AT = sysdate
				WHERE o.IM_ORDER_ID = in_o.IM_ORDER_ID;
				
				UPDATE GEC_IM_ORDER o SET o.STATUS = 'M',
										  o.UPDATED_BY = p_user_id,
										  o.UPDATED_AT = sysdate				 
				WHERE o.IM_ORDER_ID = in_o.MATCHED_ID;
			END IF;
		END LOOP;
		
		-- set the status as 'Complete' for SB only order
		FOR s_o IN sb_only_orders
		LOOP
			UPDATE GEC_IM_ORDER o SET o.EXPORT_STATUS = 'C',o.UPDATED_AT= sysdate,o.UPDATED_BY = p_user_id WHERE o.IM_ORDER_ID = s_o.IM_ORDER_ID;			
		END LOOP;
		
		-- set the holdback status to 'N' for file input borrows
		-- comment out according to GEC-2001, HOLDBACK_FLAG was set to 'N' when exporting equilend
	--	UPDATE GEC_IM_ORDER o SET o.HOLDBACK_FLAG = 'N'
	--				WHERE o.HOLDBACK_FLAG = 'Y' AND
	--					EXISTS(SELECT 1 FROM GEC_BORROW_ORDER_DETAIL detail, GEC_BORROW_TEMP temp
	--							WHERE o.IM_ORDER_ID = detail.IM_ORDER_ID AND
	--									detail.BORROW_ORDER_ID = temp.BORROW_ORDER_ID AND
	--									temp.BORROW_ORDER_ID IS NOT NULL
	--						);
							
		-- set the holdback status to 'N' for manual input borrows
		-- set the holdback from 'Y' to 'N' for the shorts which are allocated by non-agency borrows
		UPDATE GEC_IM_ORDER o SET o.HOLDBACK_FLAG = 'N',
				  					UPDATED_BY = p_user_id,
				  					UPDATED_AT = sysdate		
					WHERE o.HOLDBACK_FLAG = 'Y' AND
						EXISTS( SELECT 1 FROM GEC_ALLOCATION a, GEC_BORROW_TEMP temp
								WHERE o.IM_ORDER_ID = a.IM_ORDER_ID AND
									  a.BORROW_ID = temp.BORROW_ID AND
									  temp.AGENCY_FLAG = 'N' AND
									  temp.STATUS <> GEC_CONSTANTS_PKG.C_BORROW_MANUAL AND
									  temp.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB
							);
		
		-- set the holdback from 'C' to 'N' for the shorts which are allocated by non-cash borrows
		UPDATE GEC_IM_ORDER o SET o.HOLDBACK_FLAG = 'N',
				  					UPDATED_BY = p_user_id,
				  					UPDATED_AT = sysdate		
					WHERE o.HOLDBACK_FLAG = 'C' AND
							EXISTS(
								SELECT 1 FROM GEC_ALLOCATION a, GEC_BORROW_TEMP temp
								WHERE o.IM_ORDER_ID = a.IM_ORDER_ID AND
										a.BORROW_ID = temp.BORROW_ID AND
										temp.NON_CASH_FLAG = 'Y' AND
										temp.STATUS <> GEC_CONSTANTS_PKG.C_BORROW_MANUAL
							);
		FOR b IN borrows
		LOOP
			SELECT BORROW_REQUEST_ID INTO var_borrow_request_id FROM GEC_BORROW_ORDER WHERE BORROW_ORDER_ID = b.BORROW_ORDER_ID;
			var_request_flag := 'Y';
			EXIT;
		END LOOP;
		
		IF var_request_flag = 'Y' THEN
			p_borrow_request_id := var_borrow_request_id;
		ELSE
			p_borrow_request_id := NULL;
		END IF;
		
		-- insert into GEC_SSGM_LOAN for fund of 0189
		INSERT INTO GEC_SSGM_LOAN(
			GEC_SSGM_LOAN_ID,
  			ALLOCATION_ID,
  			ASSET_ID,
  			STATUS,
  			TRADE_DATE,
  			SETTLE_DATE,
  			SSGM_LOAN_QTY,
  			RATE,
  			CREATED_AT,
  			CREATED_BY,
  			UPDATED_AT,
  			UPDATED_BY
		)SELECT 
			GEC_SSGM_LOAN_ID_SEQ.nextval,
			a.ALLOCATION_ID,
			t.ASSET_ID,
			'O',
			t.TRADE_DATE,
			a.SETTLE_DATE,
			a.ALLOCATION_QTY,
			a.RATE,
			sysdate,
			p_user_id,
			sysdate,
			p_user_id
		FROM GEC_ALLOCATION a, GEC_IM_ORDER o, GEC_BORROW_TEMP t
			WHERE a.IM_ORDER_ID = o.IM_ORDER_ID AND
				a.BORROW_ID = t.BORROW_ID AND
				o.FUND_CD = '0189' AND
				o.SOURCE_CD = GEC_CONSTANTS_PKG.C_SOURCE_CD_MORE_DEMAND;
							
		OPEN p_borrows_cursor FOR
				SELECT t.BORROW_ID as BORROW_ID, NULL as TRADE_DATE, NULL as BORROW_ORDER_ID, NULL as ASSET_ID,NULL as BROKER_CD, NULL as SETTLE_DATE,NULL as COLLATERAL_TYPE, NULL as COLLATERAL_CURRENCY_CD,
					NULL as COLLATERAL_LEVEL,NULL as BORROW_QTY,NULL as RATE,NULL as POSITION_FLAG,NULL as COMMENT_TXT,NULL as TYPE,NULL as STATUS,NULL as CREATED_AT,NULL as CREATED_BY, NULL as TRADE_COUNTRY_CD,
					NULL as UPDATED_AT,NULL as UPDATED_BY,NULL as PRICE, NULL as NO_DEMAND_FLAG, NULL as INTERVENTION_REASON, NULL as RESPONSE_LOG_NUM, NULL as CUSIP, NULL as SEDOL, NULL as ISIN,NULL as QUIK, NULL as TICKER, NULL as ASSET_CODE, NULL as BORROW_REQUEST_TYPE, NULL as UI_ROW_NUMBER, NULL as ERROR_CODE,
					NULL as PREPAY_DATE, NULL as PREPAY_RATE, NULL as RECLAIM_RATE, NULL as OVERSEAS_TAX_PERCENTAGE, NULL as DOMESTIC_TAX_PERCENTAGE, NULL as MINIMUM_FEE, NULL as MINIMUM_FEE_CD, NULL as EQUILEND_MESSAGE_ID,NULL as TERM_DATE,NULL AS EXPECTED_RETURN_DATE				
				FROM GEC_BORROW_TEMP t;
				
		OPEN p_shorts_cursor FOR
				SELECT o.IM_ORDER_ID, o.ASSET_ID, o.TRADE_COUNTRY_CD,o.FUND_CD,o.SB_BROKER_CD,o.CUSIP,o.SHARE_QTY,o.FILLED_QTY,o.TRANSACTION_CD,o.REQUEST_ID,
					o.SHARE_QTY - o.FILLED_QTY as UNFILLED_QTY,o.SETTLE_DATE,o.TICKER,o.SEDOL,o.ISIN,o.QUIK,o.DESCRIPTION,o.RATE,f.NSB_COLLATERAL_TYPE, NVL(gc.COLLATERAL_CURRENCY_CD, gbk.COLLATERAL_CURRENCY_CD) as COLLATERAL_CURRENCY_CD,
					0 as REQUIREMANUAL,o.SOURCE_CD, tc.TRADING_DESK_CD, o.STATUS, o.POSITION_FLAG, UPPER(gat.ASSET_TYPE_DESC) as SECURITY_TYPE,
					o.G1_EXTRACTED_FLAG, o.EXPORT_STATUS, o.HOLDBACK_FLAG, CASE WHEN o.FILLED_QTY > 0 THEN 'Y' ELSE 'N' END as HAS_ALLOCATION,f.BRANCH_CD
				FROM 
					 GEC_IM_ORDER o 
					 JOIN GEC_FUND f ON o.FUND_CD = f.FUND_CD
					 JOIN GEC_ASSET_TYPE gat ON o.ASSET_TYPE_ID = gat.ASSET_TYPE_ID
					 JOIN GEC_TRADE_COUNTRY tc ON o.TRADE_COUNTRY_CD = tc.TRADE_COUNTRY_CD
					 JOIN GEC_ALLOCATION a ON o.IM_ORDER_ID = a.IM_ORDER_ID	
					 JOIN GEC_IM_ORDER_TEMP t ON o.IM_ORDER_ID = t.IM_ORDER_ID
					 JOIN GEC_BORROW_TEMP bt ON bt.BORROW_ID = a.BORROW_ID 
					 LEFT JOIN GEC_G1_BOOKING gbk ON f.fund_cd = gbk.fund_cd AND gbk.TRANSACTION_CD = 'G1L' AND gbk.POS_TYPE = 'NSB'
    				 LEFT JOIN GEC_G1_COLLATERAL gc ON gc.G1_BOOKING_ID = gbk.G1_BOOKING_ID AND gc.TRADE_COUNTRY_CD = tc.TRADE_COUNTRY_CD					 				 
		
				UNION
				SELECT o2.IM_ORDER_ID, o2.ASSET_ID, o2.TRADE_COUNTRY_CD,o2.FUND_CD,o2.SB_BROKER_CD,o2.CUSIP,o2.SHARE_QTY,o2.FILLED_QTY,o2.TRANSACTION_CD,o2.REQUEST_ID,
					o2.SHARE_QTY - o2.FILLED_QTY as UNFILLED_QTY,o2.SETTLE_DATE,o2.TICKER,o2.SEDOL,o2.ISIN,o2.QUIK,o2.DESCRIPTION,o2.RATE,f.NSB_COLLATERAL_TYPE, NVL(gc.COLLATERAL_CURRENCY_CD, gbk.COLLATERAL_CURRENCY_CD) as COLLATERAL_CURRENCY_CD,
					0 as REQUIREMANUAL,o2.SOURCE_CD, tc.TRADING_DESK_CD, o2.STATUS, o2.POSITION_FLAG, UPPER(gat.ASSET_TYPE_DESC) as SECURITY_TYPE,
					o.G1_EXTRACTED_FLAG, o.EXPORT_STATUS, o.HOLDBACK_FLAG, CASE WHEN o.FILLED_QTY > 0 THEN 'Y' ELSE 'N' END as HAS_ALLOCATION,f.BRANCH_CD
				FROM GEC_IM_ORDER o2
				JOIN GEC_FUND f ON o2.FUND_CD = f.FUND_CD
				JOIN GEC_TRADE_COUNTRY tc ON o2.TRADE_COUNTRY_CD = tc.TRADE_COUNTRY_CD	
				JOIN GEC_IM_ORDER o ON 	o.MATCHED_ID = o2.IM_ORDER_ID	
				JOIN GEC_IM_ORDER_TEMP t ON o.IM_ORDER_ID = t.IM_ORDER_ID
				JOIN GEC_ASSET_TYPE gat ON o.ASSET_TYPE_ID = gat.ASSET_TYPE_ID
				LEFT JOIN GEC_G1_BOOKING gbk ON f.fund_cd = gbk.fund_cd AND gbk.TRANSACTION_CD = 'G1L' AND gbk.POS_TYPE = 'NSB'
    			LEFT JOIN GEC_G1_COLLATERAL gc ON gc.G1_BOOKING_ID = gbk.G1_BOOKING_ID AND gc.TRADE_COUNTRY_CD = tc.TRADE_COUNTRY_CD						
				WHERE 		
				o.STATUS = 'C'; -- cancel shorts
			
		DELETE FROM GEC_BORROW_TEMP;
		DELETE FROM GEC_IM_ORDER_TEMP;
		
	END SAVE_MANU_INTERV;
	
	
	PROCEDURE CHECK_MUANUAL_BORROW_STATUS(var_valid OUT VARCHAR2)
	IS
		-- lock existed borrows
		CURSOR exist_borrows IS
			SELECT  b.BROKER_CD,
  					b.TRADE_DATE,
  					b.SETTLE_DATE,
  					b.COLLATERAL_TYPE,
  					b.COLLATERAL_CURRENCY_CD,
  					b.BORROW_QTY,
  					b.RATE,
  					b.PRICE,
  					b.PREPAY_DATE,
  					b.PREPAY_RATE,
  					b.RECLAIM_RATE,
  					b.OVERSEAS_TAX_PERCENTAGE,
  					b.DOMESTIC_TAX_PERCENTAGE,
  					b.MINIMUM_FEE,
  					b.AMOUNT,
  					b.POSITION_FLAG,
  					b.STATUS,
  					b.BORROW_ID
			FROM GEC_BORROW_TEMP t, GEC_BORROW b
			WHERE t.BORROW_ID = b.BORROW_ID
			ORDER BY b.BORROW_ID ASC
			FOR UPDATE OF b.STATUS;	
			
		CURSOR no_exist_borrows IS	
			SELECT t.BORROW_ID
			FROM GEC_BORROW_TEMP t WHERE t.OPERATION IS NULL OR t.OPERATION <> 'V';
	BEGIN
		var_valid := 'Y';
		
		FOR e_b IN exist_borrows
		LOOP
			IF e_b.STATUS = GEC_CONSTANTS_PKG.C_BORROW_MANUAL THEN
				UPDATE GEC_BORROW_TEMP t SET
					t.BROKER_CD = e_b.BROKER_CD,
  					t.TRADE_DATE = e_b.TRADE_DATE,
  					t.SETTLE_DATE = e_b.SETTLE_DATE,
  					t.COLLATERAL_TYPE = e_b.COLLATERAL_TYPE,
  					t.COLLATERAL_CURRENCY_CD = e_b.COLLATERAL_CURRENCY_CD,
  					t.BORROW_QTY = e_b.BORROW_QTY,
  					t.RATE = e_b.RATE,
  					t.PRICE = e_b.PRICE,
  					t.PREPAY_DATE = e_b.PREPAY_DATE,
  					t.PREPAY_RATE = e_b.PREPAY_RATE,
  					t.RECLAIM_RATE = e_b.RECLAIM_RATE,
  					t.OVERSEAS_TAX_PERCENTAGE = e_b.OVERSEAS_TAX_PERCENTAGE,
  					t.DOMESTIC_TAX_PERCENTAGE = e_b.DOMESTIC_TAX_PERCENTAGE,
  					t.MINIMUM_FEE = e_b.MINIMUM_FEE,
  					t.POSITION_FLAG = e_b.POSITION_FLAG,
  					t.OPERATION = 'V'
  				WHERE t.BORROW_ID = e_b.BORROW_ID;
			END IF;
		END LOOP;
		
		FOR n_b IN no_exist_borrows
		LOOP
			UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR WHERE BORROW_ID = n_b.BORROW_ID;
			var_valid := 'N';
		END LOOP;
		
	END;
	
	-- from hightest to lowest shorts, to match hightest to lowest borrows
	-- SB: need to match broker cd / sb coll type / sb coll code
	-- add match of borrow settle date and short settle date
	-- change for non-cash coll, for normal borrow, remove the matching of coll type, and can't match to NC holdback shorts
	--                           for non-cash borrow, can match to NC holdback shorts, but coll type can only match to CASH
	FUNCTION REVERSE_SINGLE_ALLO_SB(p_user_id IN VARCHAR2, p_asset_id IN NUMBER, p_r_alloc_key IN VARCHAR2,p_across IN VARCHAR2, p_error_code OUT VARCHAR2) RETURN VARCHAR2
	IS
	var_broker_cd GEC_BORROW.BROKER_CD%type;
	var_coll_type GEC_BORROW.COLLATERAL_TYPE%type;
	var_coll_code GEC_BORROW.COLLATERAL_CURRENCY_CD%type;
	var_fund_coll_type GEC_BORROW.COLLATERAL_TYPE%type;			
	var_b_found VARCHAR2(1);
	var_a_found VARCHAR2(1);
	var_l_settle_date GEC_BORROW.SETTLE_DATE%type;
	
	var_short_fund_cd GEC_IM_ORDER.FUND_CD%type;
	var_short_settle_date GEC_IM_ORDER.SETTLE_DATE%type; 
	var_borrow_id GEC_BORROW.BORROW_ID%type; 
	var_order_id GEC_IM_ORDER.IM_ORDER_ID%type;
	var_b_qty GEC_BORROW.BORROW_QTY%type; 
	var_o_qty GEC_IM_ORDER.SHARE_QTY%type;
	var_fee GEC_ALLOCATION.RATE%type; 
	var_borrow_request_type GEC_BORROW_REQUEST.BORROW_REQUEST_TYPE%type;
	var_o_holdback GEC_IM_ORDER.HOLDBACK_FLAG%type;
	var_branch_cd GEC_BROKER.BRANCH_CD%type;
	var_legal_entity_cd GEC_BROKER.LEGAL_ENTITY_CD%type;
	var_trade_country GEC_TRADE_COUNTRY.TRADE_COUNTRY_CD%type;
	var_reclaim_rate GEC_G1_BOOKING.RECLAIM_RATE%type;	
	var_overseas_tax GEC_G1_BOOKING.OVERSEAS_TAX_PERCENTAGE%type;			
	var_domestic_tax GEC_G1_BOOKING.DOMESTIC_TAX_PERCENTAGE%type;
	var_prepay_date GEC_BORROW.PREPAY_DATE%type; 
	var_prepay_rate GEC_COUNTERPARTY.PREPAY_RATE%type;	
	var_min_fee GEC_BORROW.MINIMUM_FEE%type;
	var_min_fee_cd GEC_ALLOCATION.MINIMUM_FEE_CD%type;
	var_error_code VARCHAR2(10);
	CURSOR max_shorts IS
		SELECT o.FUND_CD, o.SETTLE_DATE, o.IM_ORDER_ID, o.SB_ALLOC_QTY - o.FILLED_SB_QTY as o_qty, o.SB_FEE, o.SB_COLLATERAL_TYPE, o.SB_COLLATERAL_CURRENCY_CD, o.SB_BROKER_CD, o.BRANCH_CD, o.HOLDBACK_FLAG,
			   o.PREPAY_RATE, o.SB_NET_DIVIDEND, o.MINIMUM_FEE,o.MINIMUM_FEE_CD, f.SB_COLLATERAL_TYPE as FUND_COLLATERAL_TYPE,f.LEGAL_ENTITY_CD
		FROM   GEC_IM_ORDER_TEMP o, GEC_FUND f
		WHERE o.ASSET_ID = p_asset_id AND
			  o.FUND_CD = f.FUND_CD AND
			  o.R_ALLOC_KEY = p_r_alloc_key AND
			  o.SB_ALLOC_QTY IS NOT NULL AND
			  o.SB_ALLOC_QTY > o.FILLED_SB_QTY AND
			  o.EXPORT_STATUS <> 'C' AND
			  o.SB_RUN_FLAG = 'N'
		ORDER BY o.SB_ALLOC_QTY DESC,
				 CASE WHEN 
				 instr(GEC_CONSTANTS_PKG.GET_DUMMYWITH0189_FUNDS(),o.FUND_CD||',')=0 
			     THEN 1 ELSE 999 END;
	
	
	--CURSOR max_match_borrows IS
	--	SELECT b.BORROW_ID, b.UNFILLED_QTY, b.BORROW_REQUEST_TYPE, b.TRADE_COUNTRY_CD, b.PREPAY_DATE
	--	FROM GEC_BORROW_TEMP b
	--	WHERE b.ASSET_ID = p_asset_id AND
	--		  b.R_ALLOC_KEY = p_r_alloc_key AND
	--		  b.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND
	--		  b.BROKER_CD =var_broker_cd AND
			  --b.COLLATERAL_TYPE = var_coll_type AND
	--		  (b.NON_CASH_FLAG='Y' AND var_fund_coll_type = 'CASH' OR b.NON_CASH_FLAG='N' AND var_o_holdback<>'C') AND
	--		  b.COLLATERAL_CURRENCY_CD = var_coll_code AND
	--		  b.BRANCH_CD in ('TOR',GEC_CONSTANTS_PKG.C_BRANCH_GMBH) AND		  
	--		  b.SETTLE_DATE = var_short_settle_date AND
	--		  b.UNFILLED_QTY > 0 
	--	ORDER BY b.BORROW_QTY DESC; 
		
	CURSOR max_match_borrows_bos IS
		SELECT b.BORROW_ID, b.UNFILLED_QTY, b.BORROW_REQUEST_TYPE, b.TRADE_COUNTRY_CD, b.PREPAY_DATE
		FROM GEC_BORROW_TEMP b,GEC_ALLOCATION_RULE gar
		WHERE b.ASSET_ID = p_asset_id AND
			  b.BRANCH_CD = gar.ALLOCATE_BORROW_BRANCH and 
			  var_branch_cd = gar.ALLOCATE_DEMAND_BRANCH and 
			  b.R_ALLOC_KEY = p_r_alloc_key AND
			  b.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND
			  b.BROKER_CD = var_broker_cd AND
			  ((b.LEGAL_ENTITY_CD = var_legal_entity_cd AND p_across='N') OR p_across='Y') AND 
			  --b.COLLATERAL_TYPE = var_coll_type AND
			  (b.NON_CASH_FLAG='Y' AND var_fund_coll_type = 'CASH' OR b.NON_CASH_FLAG='N' AND var_o_holdback<>'C') AND
			  b.COLLATERAL_CURRENCY_CD = var_coll_code AND
			  b.BRANCH_CD IN (SELECT ALLOCATE_BORROW_BRANCH FROM GEC_ALLOCATION_RULE WHERE ALLOCATE_DEMAND_BRANCH= var_branch_cd) AND		
			  b.SETTLE_DATE <= var_short_settle_date AND  
			  b.UNFILLED_QTY > 0 
		ORDER BY b.BORROW_QTY DESC, gar.BORROW_ALLOCATE_ORDER, gar.DEMAND_ALLOCATE_ORDER; 	
		
	--excess borrows with any branch can allocated to 0189/DUMY
	CURSOR max_match_borrows_excess IS
		SELECT b.BORROW_ID, b.UNFILLED_QTY, b.BORROW_REQUEST_TYPE, b.TRADE_COUNTRY_CD, b.PREPAY_DATE
		FROM GEC_BORROW_TEMP b
		WHERE b.ASSET_ID = p_asset_id AND
			  b.R_ALLOC_KEY = p_r_alloc_key AND
			  b.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND
			  ((b.LEGAL_ENTITY_CD = var_legal_entity_cd AND p_across='N') OR p_across='Y') AND 
			  --b.COLLATERAL_TYPE = var_coll_type AND
			  (b.NON_CASH_FLAG='Y' AND var_fund_coll_type = 'CASH' OR b.NON_CASH_FLAG='N' AND var_o_holdback<>'C') AND
			  b.COLLATERAL_CURRENCY_CD = var_coll_code AND 
			  b.SETTLE_DATE <= var_short_settle_date AND  
			  b.UNFILLED_QTY > 0 
		ORDER BY b.BORROW_QTY DESC; 				
			  
	BEGIN
		var_a_found := 'N';
		
		FOR short IN max_shorts
		LOOP
			var_a_found := 'Y';
			var_short_fund_cd := short.FUND_CD;
			var_short_settle_date := short.SETTLE_DATE; 
			var_order_id := short.IM_ORDER_ID;
			var_o_qty := short.o_qty;
			var_broker_cd := short.SB_BROKER_CD;
			var_coll_code := short.SB_COLLATERAL_CURRENCY_CD;
			var_fee := short.SB_FEE; 			
			var_branch_cd := short.BRANCH_CD;
			var_o_holdback:= short.HOLDBACK_FLAG;
			var_prepay_rate := short.PREPAY_RATE;
			var_reclaim_rate := short.SB_NET_DIVIDEND;								
			var_min_fee := short.MINIMUM_FEE;
			var_min_fee_cd := short.MINIMUM_FEE_CD;
			var_fund_coll_type := short.FUND_COLLATERAL_TYPE;				
			var_legal_entity_cd:=short.LEGAL_ENTITY_CD;					
			EXIT WHEN var_a_found = 'Y';
		END LOOP;
		
		var_b_found := 'N';
		
		IF var_a_found = 'Y' THEN
			-- excess borrows with any branch can be allocated to 0189/DUMY
			IF p_r_alloc_key = 'DUMMY' AND var_short_fund_cd IS NOT NULL 
			AND  instr(GEC_CONSTANTS_PKG.GET_DUMMYWITH0189_FUNDS(),var_short_fund_cd||',')>0
		   THEN
				FOR m_b IN max_match_borrows_excess
				LOOP
					var_b_found := 'Y';
					var_borrow_id := m_b.BORROW_ID; 
					var_b_qty := m_b.UNFILLED_QTY; 
					var_borrow_request_type := m_b.BORROW_REQUEST_TYPE;
				    var_trade_country := m_b.TRADE_COUNTRY_CD;
				    
					EXIT WHEN var_b_found = 'Y';
				END LOOP;	
			ELSE	
				IF var_branch_cd IS NOT NULL THEN
					FOR m_b IN max_match_borrows_bos
					LOOP
						var_b_found := 'Y';
						var_borrow_id := m_b.BORROW_ID; 
						var_b_qty := m_b.UNFILLED_QTY; 
						var_borrow_request_type := m_b.BORROW_REQUEST_TYPE;
				    	var_trade_country := m_b.TRADE_COUNTRY_CD;				
				
						EXIT WHEN var_b_found = 'Y';
					END LOOP;
				--ELSE
				--	IF var_branch_cd IS NOT NULL  THEN				
				--		FOR m_b IN max_match_borrows
				--		LOOP
				--			var_b_found := 'Y';
				--			var_borrow_id := m_b.BORROW_ID; 
				--			var_b_qty := m_b.UNFILLED_QTY; 
				--			var_borrow_request_type := m_b.BORROW_REQUEST_TYPE;
				--			var_b_settle_date := var_short_settle_date;
				--    		var_trade_country := m_b.TRADE_COUNTRY_CD;
				--    		var_prepay_date := m_b.PREPAY_DATE;								
				
				--			EXIT WHEN var_b_found = 'Y';
				--		END LOOP;
				--	END IF;
				END IF;	
			END IF;
		END IF;						
	
		IF var_b_found = 'N' AND var_a_found = 'Y' THEN
			UPDATE GEC_IM_ORDER_TEMP SET SB_RUN_FLAG = 'Y' WHERE IM_ORDER_ID = var_order_id;
			RETURN 'Y';
		ELSIF var_b_found = 'Y' AND var_a_found = 'Y' THEN		
			GET_LOAN_INFO(var_trade_country, var_short_fund_cd, 'SB', var_coll_type, var_domestic_tax, var_overseas_tax, var_error_code);	
			IF var_error_code IS NOT NULL THEN
				p_error_code := var_error_code;
				RETURN 'N';
			END IF;						
			GET_LOAN_DEF_SET_PRE_DATE(var_borrow_request_type,var_short_fund_cd,var_trade_country,var_short_settle_date,var_prepay_date,var_l_settle_date);
			BOOK_ONE_ALLOCATION(p_user_id, p_asset_id, var_short_fund_cd, var_short_settle_date, var_borrow_id, var_order_id, var_b_qty, var_o_qty, var_fee, var_l_settle_date, var_prepay_date, var_prepay_rate, var_reclaim_rate, var_overseas_tax, var_domestic_tax, var_coll_type, var_coll_code, var_min_fee,var_min_fee_cd, var_borrow_request_type,var_broker_cd);
			RETURN 'Y';
		ELSE
			RETURN 'N';
		END IF;
		
	END REVERSE_SINGLE_ALLO_SB;
	
	
	-- NSB: do not need to match broker cd 
	-- need to include BR31, short settle date >= borrow settle date
	-- when NSB settle date is not null, then borrow settle date need to equal to NSB settle date, if not, set error
	-- change for non-cash coll, for normal borrow, remove the matching of coll type, and can't match to NC holdback shorts
	--                           for non-cash borrow, can match to NC holdback shorts, but coll type can only match to CASH
	FUNCTION REVERSE_SINGLE_ALLO_NSB(p_user_id IN VARCHAR2, p_asset_id IN NUMBER, p_r_alloc_key IN VARCHAR2,p_across IN VARCHAR2, p_error_code OUT VARCHAR2) RETURN VARCHAR2
	IS
		var_broker_cd GEC_BORROW.BROKER_CD%type;
		var_coll_type GEC_BORROW.COLLATERAL_TYPE%type;
		var_coll_code GEC_BORROW.COLLATERAL_CURRENCY_CD%type;
		var_fund_coll_type GEC_BORROW.COLLATERAL_TYPE%type;		
		var_b_found VARCHAR2(1);
		var_a_found VARCHAR2(1);
		
		var_b_settle_date GEC_BORROW.SETTLE_DATE%type;
		var_nsb_settle_date GEC_BORROW.SETTLE_DATE%type;
		var_legal_entity_cd GEC_BROKER.LEGAL_ENTITY_CD%type;
		var_short_fund_cd GEC_IM_ORDER.FUND_CD%type;
		var_short_settle_date GEC_BORROW.SETTLE_DATE%type;
		var_borrow_id GEC_BORROW.BORROW_ID%type; 
		var_order_id GEC_IM_ORDER.IM_ORDER_ID%type;
		var_b_qty GEC_BORROW.BORROW_QTY%type; 
		var_o_qty GEC_IM_ORDER.SHARE_QTY%type;
		var_fee GEC_ALLOCATION.RATE%type; 
		var_borrow_request_type GEC_BORROW_REQUEST.BORROW_REQUEST_TYPE%type;
		var_o_holdback GEC_IM_ORDER.HOLDBACK_FLAG%type;
		var_settle_date GEC_BORROW.SETTLE_DATE%type; 
		var_branch_cd GEC_BROKER.BRANCH_CD%type;
		
		var_reclaim_rate GEC_G1_BOOKING.RECLAIM_RATE%type;	
		var_overseas_tax GEC_G1_BOOKING.OVERSEAS_TAX_PERCENTAGE%type;			
		var_domestic_tax GEC_G1_BOOKING.DOMESTIC_TAX_PERCENTAGE%type;
		var_prepay_date GEC_BORROW.PREPAY_DATE%type; 		
		var_prepay_rate GEC_COUNTERPARTY.PREPAY_RATE%type;	
		var_min_fee GEC_BORROW.MINIMUM_FEE%type;
		var_min_fee_cd GEC_ALLOCATION.MINIMUM_FEE_CD%type;
		var_trade_country GEC_TRADE_COUNTRY.TRADE_COUNTRY_CD%type;		
		var_error_code VARCHAR2(10);	
		CURSOR max_shorts IS
			SELECT o.FUND_CD, o.SETTLE_DATE, o.IM_ORDER_ID, o.NSB_ALLOC_QTY - o.FILLED_NSB_QTY as o_qty, o.NSB_SETTLE_DATE, o.NSB_FEE, o.NSB_BROKER_CD, o.NSB_COLLATERAL_TYPE, o.NSB_COLLATERAL_CURRENCY_CD, o.BRANCH_CD, o.HOLDBACK_FLAG,
				   o.PREPAY_DATE, o.PREPAY_RATE, o.NSB_NET_DIVIDEND, o.OVERSEAS_TAX_PERCENTAGE, o.DOMESTIC_TAX_PERCENTAGE, o.MINIMUM_FEE,o.MINIMUM_FEE_CD, f.NSB_COLLATERAL_TYPE as FUND_COLLATERAL_TYPE,f.LEGAL_ENTITY_CD
			FROM GEC_IM_ORDER_TEMP o, GEC_FUND f
			WHERE o.ASSET_ID = p_asset_id AND
				  o.FUND_CD = f.FUND_CD AND
				  o.R_ALLOC_KEY = p_r_alloc_key AND
				  o.NSB_ALLOC_QTY IS NOT NULL AND
				  o.NSB_ALLOC_QTY > o.FILLED_NSB_QTY AND
				  o.NSB_RUN_FLAG = 'N'
			ORDER BY o.NSB_ALLOC_QTY DESC, 				 
					 CASE WHEN 
					 instr(GEC_CONSTANTS_PKG.GET_DUMMYWITH0189_FUNDS(),o.FUND_CD||',')=0
				   THEN 1 ELSE 999 END;
	
		-- only need to match settle date / coll code / coll type
		--CURSOR max_match_borrows IS
		--	SELECT b.BORROW_ID, b.UNFILLED_QTY, b.BORROW_REQUEST_TYPE, b.SETTLE_DATE, b.TRADE_COUNTRY_CD
		--	FROM GEC_BORROW_TEMP b
		--	WHERE b.ASSET_ID = p_asset_id AND
		--		  b.R_ALLOC_KEY = p_r_alloc_key AND
		--		  b.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND
		--		  b.AGENCY_FLAG = 'N' AND
				--  b.COLLATERAL_TYPE = var_coll_type AND
		--		  (b.NON_CASH_FLAG='Y' AND var_fund_coll_type = 'CASH' OR b.NON_CASH_FLAG='N' AND var_o_holdback<>'C') AND
		--		  b.COLLATERAL_CURRENCY_CD = var_coll_code AND
		--		  b.BRANCH_CD IN ('TOR',GEC_CONSTANTS_PKG.C_BRANCH_GMBH) AND
		--		  b.SETTLE_DATE <= var_short_settle_date AND
		--		  b.UNFILLED_QTY > 0 
		--	ORDER BY b.BORROW_QTY DESC; 
			
		CURSOR max_match_borrows_bos IS
			SELECT b.BORROW_ID, b.UNFILLED_QTY, b.BORROW_REQUEST_TYPE, b.SETTLE_DATE, b.TRADE_COUNTRY_CD
			FROM GEC_BORROW_TEMP b,GEC_ALLOCATION_RULE gar
			WHERE b.ASSET_ID = p_asset_id AND
				  b.BRANCH_CD = gar.ALLOCATE_BORROW_BRANCH and 
			  	  var_branch_cd = gar.ALLOCATE_DEMAND_BRANCH and 
				  b.R_ALLOC_KEY = p_r_alloc_key AND
				  b.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND
				  b.AGENCY_FLAG = 'N' AND
				  ((b.LEGAL_ENTITY_CD = var_legal_entity_cd AND p_across='N') OR p_across='Y') AND 
				--  b.COLLATERAL_TYPE = var_coll_type AND
				  (b.NON_CASH_FLAG='Y' AND var_fund_coll_type = 'CASH' OR b.NON_CASH_FLAG='N' AND var_o_holdback<>'C') AND
				  b.COLLATERAL_CURRENCY_CD = var_coll_code AND
			  	  b.BRANCH_CD IN (SELECT ALLOCATE_BORROW_BRANCH FROM GEC_ALLOCATION_RULE WHERE ALLOCATE_DEMAND_BRANCH= var_branch_cd) AND	
				  b.SETTLE_DATE <= var_short_settle_date AND
				  b.UNFILLED_QTY > 0 
			ORDER BY b.BORROW_QTY DESC,gar.BORROW_ALLOCATE_ORDER, gar.DEMAND_ALLOCATE_ORDER; 	
			
		CURSOR max_match_borrows_excess IS
			SELECT b.BORROW_ID, b.UNFILLED_QTY, b.BORROW_REQUEST_TYPE, b.SETTLE_DATE, b.TRADE_COUNTRY_CD
			FROM GEC_BORROW_TEMP b
			WHERE b.ASSET_ID = p_asset_id AND
				  b.R_ALLOC_KEY = p_r_alloc_key AND
				  b.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND
				  b.AGENCY_FLAG = 'N' AND
				  ((b.LEGAL_ENTITY_CD = var_legal_entity_cd AND p_across='N') OR p_across='Y') AND 
				--  b.COLLATERAL_TYPE = var_coll_type AND
				  (b.NON_CASH_FLAG='Y' AND var_fund_coll_type = 'CASH' OR b.NON_CASH_FLAG='N' AND var_o_holdback<>'C') AND
				  b.COLLATERAL_CURRENCY_CD = var_coll_code AND
				  b.SETTLE_DATE <= var_short_settle_date AND
				  b.UNFILLED_QTY > 0 
			ORDER BY b.BORROW_QTY DESC, b.BRANCH_CD; 						
		
	BEGIN
		var_a_found := 'N';
		
		FOR short IN max_shorts
		LOOP
			var_a_found := 'Y';
			var_short_fund_cd := short.FUND_CD;
			var_short_settle_date := short.SETTLE_DATE; 
			var_order_id := short.IM_ORDER_ID;
			var_o_qty := short.o_qty;
			var_fee := short.NSB_FEE; 
			var_nsb_settle_date := short.NSB_SETTLE_DATE;
			var_broker_cd := short.NSB_BROKER_CD;
			var_coll_type := short.NSB_COLLATERAL_TYPE;
			var_coll_code := short.NSB_COLLATERAL_CURRENCY_CD;
			var_prepay_date := short.PREPAY_DATE;
			var_prepay_rate := short.PREPAY_RATE;		
			var_reclaim_rate := short.NSB_NET_DIVIDEND;	
			var_overseas_tax := short.OVERSEAS_TAX_PERCENTAGE;			
			var_domestic_tax := short.DOMESTIC_TAX_PERCENTAGE;
			var_min_fee := short.MINIMUM_FEE;
			var_min_fee_cd := short.MINIMUM_FEE_CD;
			var_fund_coll_type := short.FUND_COLLATERAL_TYPE;			
			var_legal_entity_cd:=short.LEGAL_ENTITY_CD;				
			var_o_holdback:= short.HOLDBACK_FLAG;
			var_branch_cd := short.BRANCH_CD;
			
			EXIT WHEN var_a_found = 'Y';
		END LOOP;
		
		var_b_found := 'N';
		
		IF var_a_found = 'Y' THEN
		
			-- excess borrows with any branch can be allocated to 0189/DUMY
			IF p_r_alloc_key = 'DUMMY' AND var_short_fund_cd IS NOT NULL AND instr(GEC_CONSTANTS_PKG.GET_DUMMYWITH0189_FUNDS(),var_short_fund_cd||',')>0
		    THEN
				FOR m_b IN max_match_borrows_excess
				LOOP
					var_b_settle_date := m_b.SETTLE_DATE;				
						var_b_found := 'Y';
						var_borrow_id := m_b.BORROW_ID; 
						var_b_qty := m_b.UNFILLED_QTY; 
						var_borrow_request_type := m_b.BORROW_REQUEST_TYPE;
				    	var_trade_country := m_b.TRADE_COUNTRY_CD;						
					
									
					EXIT WHEN var_b_found = 'Y';
				END LOOP;
			ELSE			
				IF var_branch_cd IS NOT NULL THEN
					FOR m_b IN max_match_borrows_bos
					LOOP
						var_b_settle_date := m_b.SETTLE_DATE;
							var_b_found := 'Y';
							var_borrow_id := m_b.BORROW_ID; 
							var_b_qty := m_b.UNFILLED_QTY; 
							var_borrow_request_type := m_b.BORROW_REQUEST_TYPE;
				    		var_trade_country := m_b.TRADE_COUNTRY_CD;								
				
						EXIT WHEN var_b_found = 'Y';
					END LOOP;
				--ELSE
				--	IF var_branch_cd IS NOT NULL  THEN				
				--		FOR m_b IN max_match_borrows
				--		LOOP
				--			var_b_settle_date := m_b.SETTLE_DATE;
				--			IF var_nsb_settle_date IS NULL OR (var_nsb_settle_date IS NOT NULL AND var_nsb_settle_date = var_b_settle_date) THEN
				--				var_b_found := 'Y';
				--				var_borrow_id := m_b.BORROW_ID; 
				--				var_b_qty := m_b.UNFILLED_QTY; 
				--				var_borrow_request_type := m_b.BORROW_REQUEST_TYPE;
				--		  		var_trade_country := m_b.TRADE_COUNTRY_CD;									
				--			ELSE
				--				UPDATE GEC_IM_ORDER_TEMP SET ERROR_CODE = NVL(ERROR_CODE, 'VLD0075') WHERE IM_ORDER_ID = var_order_id;
				--			END IF;
				
				--			EXIT WHEN var_b_found = 'Y';
				--		END LOOP;
				--	END IF;
				END IF;		
			END IF;
		END IF;
	
		IF var_b_found = 'N' AND var_a_found = 'Y' THEN
			UPDATE GEC_IM_ORDER_TEMP SET NSB_RUN_FLAG = 'Y' WHERE IM_ORDER_ID = var_order_id;
			RETURN 'Y';
		ELSIF var_b_found = 'Y' AND var_a_found = 'Y' THEN
			IF var_coll_type IS NULL THEN
				GET_LOAN_INFO(var_trade_country, var_short_fund_cd, 'NSB', var_coll_type, var_domestic_tax, var_overseas_tax, var_error_code);	
				IF var_error_code IS NOT NULL THEN
					p_error_code := var_error_code;
					RETURN 'N';
				END IF;
			END IF;	
			BOOK_ONE_ALLOCATION(p_user_id, p_asset_id, var_short_fund_cd, var_short_settle_date, var_borrow_id, var_order_id, var_b_qty, var_o_qty, var_fee, var_nsb_settle_date,  var_prepay_date, var_prepay_rate, var_reclaim_rate, var_overseas_tax, var_domestic_tax, var_coll_type, var_coll_code, var_min_fee, var_min_fee_cd,var_borrow_request_type,var_broker_cd);
			RETURN 'Y';
		ELSE
			RETURN 'N';
		END IF;
		
	END REVERSE_SINGLE_ALLO_NSB;
	
	
	-- AGENCY NSB: need to match broker cd / nsb coll type / nsb coll code
	-- need to match settle date - borrow settle date <= short settle date
	-- change for non-cash coll, for normal borrow, remove the matching of coll type, and can't match to NC holdback shorts
	--                           for non-cash borrow, can match to NC holdback shorts, but coll type can only match to CASH
	FUNCTION REVERSE_SINGLE_ALLO_AGE(p_user_id IN VARCHAR2, p_asset_id IN NUMBER, p_r_alloc_key IN VARCHAR2,p_across IN VARCHAR2, p_error_code OUT VARCHAR2) RETURN VARCHAR2
	IS
		var_broker_cd GEC_BORROW.BROKER_CD%type;
		var_coll_type GEC_BORROW.COLLATERAL_TYPE%type;
		var_coll_code GEC_BORROW.COLLATERAL_CURRENCY_CD%type;
		var_fund_coll_type GEC_BORROW.COLLATERAL_TYPE%type;
		var_b_found VARCHAR2(1);
		var_a_found VARCHAR2(1);
		
		var_nsb_settle_date GEC_BORROW.SETTLE_DATE%type;
		var_legal_entity_cd GEC_BROKER.LEGAL_ENTITY_CD%type;
		var_short_fund_cd GEC_IM_ORDER.FUND_CD%type;
		var_short_settle_date GEC_BORROW.SETTLE_DATE%type;
		var_borrow_id GEC_BORROW.BORROW_ID%type; 
		var_order_id GEC_IM_ORDER.IM_ORDER_ID%type;
		var_b_qty GEC_BORROW.BORROW_QTY%type; 
		var_o_qty GEC_IM_ORDER.SHARE_QTY%type;
		var_fee GEC_ALLOCATION.RATE%type; 
		var_b_settle_date GEC_BORROW.SETTLE_DATE%type;
		var_borrow_request_type GEC_BORROW_REQUEST.BORROW_REQUEST_TYPE%type;
		var_o_holdback GEC_IM_ORDER.HOLDBACK_FLAG%type;
		
		var_branch_cd GEC_BROKER.BRANCH_CD%type;
		
		var_reclaim_rate GEC_G1_BOOKING.RECLAIM_RATE%type;	
		var_overseas_tax GEC_G1_BOOKING.OVERSEAS_TAX_PERCENTAGE%type;			
		var_domestic_tax GEC_G1_BOOKING.DOMESTIC_TAX_PERCENTAGE%type;
		var_prepay_date GEC_BORROW.PREPAY_DATE%type; 
		var_settle_date GEC_BORROW.SETTLE_DATE%type; 
		var_prepay_rate GEC_COUNTERPARTY.PREPAY_RATE%type;	
		var_min_fee GEC_BORROW.MINIMUM_FEE%type;	
		var_min_fee_cd GEC_ALLOCATION.MINIMUM_FEE_CD%type;
		var_trade_country GEC_TRADE_COUNTRY.TRADE_COUNTRY_CD%type;		
		var_error_code VARCHAR2(10);				
		CURSOR max_shorts IS
			SELECT o.FUND_CD, o.SETTLE_DATE, o.IM_ORDER_ID, o.NSB_ALLOC_QTY - o.FILLED_NSB_QTY as o_qty, o.NSB_SETTLE_DATE, o.NSB_FEE, o.NSB_BROKER_CD, 
				   o.NSB_COLLATERAL_TYPE, o.NSB_COLLATERAL_CURRENCY_CD, o.BRANCH_CD, o.HOLDBACK_FLAG, o.PREPAY_DATE, o.PREPAY_RATE, o.NSB_NET_DIVIDEND, 
				   o.OVERSEAS_TAX_PERCENTAGE, o.DOMESTIC_TAX_PERCENTAGE, o.MINIMUM_FEE,o.MINIMUM_FEE_CD, f.NSB_COLLATERAL_TYPE as FUND_COLLATERAL_TYPE,f.LEGAL_ENTITY_CD
			FROM GEC_IM_ORDER_TEMP o, GEC_FUND f
			WHERE o.ASSET_ID = p_asset_id AND
				  o.FUND_CD = f.FUND_CD AND
				  o.R_ALLOC_KEY = p_r_alloc_key AND
				  o.NSB_ALLOC_QTY IS NOT NULL AND
				  o.NSB_ALLOC_QTY > o.FILLED_NSB_QTY AND
				  o.AGENCY_RUN_FLAG = 'N'
			ORDER BY o.NSB_ALLOC_QTY DESC,
					 CASE WHEN 
					 instr(GEC_CONSTANTS_PKG.GET_DUMMYWITH0189_FUNDS(),o.FUND_CD||',')=0
				    THEN 1 ELSE 999 END;
	
		-- need to match settle date and broker cd / coll type / coll code
		--CURSOR max_match_borrows IS
		--	SELECT b.BORROW_ID, b.UNFILLED_QTY, b.BORROW_REQUEST_TYPE, b.SETTLE_DATE, b.TRADE_COUNTRY_CD
		--	FROM GEC_BORROW_TEMP b
		--	WHERE b.ASSET_ID = p_asset_id AND
		--		  b.R_ALLOC_KEY = p_r_alloc_key AND
		--		  b.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND
		--		  b.AGENCY_FLAG = 'Y' AND
				--  b.COLLATERAL_TYPE = var_coll_type AND
		--		  (b.NON_CASH_FLAG='Y' AND var_fund_coll_type = 'CASH' OR b.NON_CASH_FLAG='N' AND var_o_holdback<>'C') AND
		--		  b.COLLATERAL_CURRENCY_CD = var_coll_code AND
		--		  b.BRANCH_CD IN ('TOR',GEC_CONSTANTS_PKG.C_BRANCH_GMBH) AND
		--		  b.SETTLE_DATE <= var_short_settle_date AND
		--		  b.BROKER_CD = var_broker_cd AND
		--		  b.UNFILLED_QTY > 0 
		--	ORDER BY b.BORROW_QTY DESC; 
			
		CURSOR max_match_borrows_bos IS
			SELECT b.BORROW_ID, b.UNFILLED_QTY, b.BORROW_REQUEST_TYPE, b.SETTLE_DATE, b.TRADE_COUNTRY_CD
			FROM GEC_BORROW_TEMP b,GEC_ALLOCATION_RULE gar
			WHERE b.ASSET_ID = p_asset_id AND
				  b.BRANCH_CD = gar.ALLOCATE_BORROW_BRANCH and 
			  	  var_branch_cd = gar.ALLOCATE_DEMAND_BRANCH and 
				  b.R_ALLOC_KEY = p_r_alloc_key AND
				  b.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND
				  b.AGENCY_FLAG = 'Y' AND
				  ((b.LEGAL_ENTITY_CD = var_legal_entity_cd AND p_across='N') OR p_across='Y') AND 
				--  b.COLLATERAL_TYPE = var_coll_type AND
				  (b.NON_CASH_FLAG='Y' AND var_fund_coll_type = 'CASH' OR b.NON_CASH_FLAG='N' AND var_o_holdback<>'C') AND
				  b.COLLATERAL_CURRENCY_CD = var_coll_code AND
				  b.BRANCH_CD IN (SELECT ALLOCATE_BORROW_BRANCH FROM GEC_ALLOCATION_RULE WHERE ALLOCATE_DEMAND_BRANCH= var_branch_cd) AND
				  b.SETTLE_DATE <= var_short_settle_date AND
				  b.UNFILLED_QTY > 0 
			ORDER BY b.BORROW_QTY DESC, gar.BORROW_ALLOCATE_ORDER, gar.DEMAND_ALLOCATE_ORDER; 	
			
		CURSOR max_match_borrows_excess IS
			SELECT b.BORROW_ID, b.UNFILLED_QTY, b.BORROW_REQUEST_TYPE, b.SETTLE_DATE, b.TRADE_COUNTRY_CD
			FROM GEC_BORROW_TEMP b
			WHERE b.ASSET_ID = p_asset_id AND
				  b.R_ALLOC_KEY = p_r_alloc_key AND
				  b.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND
				  b.AGENCY_FLAG = 'Y' AND
				  ((b.LEGAL_ENTITY_CD = var_legal_entity_cd AND p_across='N') OR p_across='Y') AND 
				--  b.COLLATERAL_TYPE = var_coll_type AND
				  (b.NON_CASH_FLAG='Y' AND var_fund_coll_type = 'CASH' OR b.NON_CASH_FLAG='N' AND var_o_holdback<>'C') AND
				  b.COLLATERAL_CURRENCY_CD = var_coll_code AND
				  b.SETTLE_DATE <= var_short_settle_date AND
				  b.UNFILLED_QTY > 0 
			ORDER BY b.BORROW_QTY DESC; 						
	BEGIN
		var_a_found := 'N';
		
		FOR short IN max_shorts
		LOOP
			var_a_found := 'Y';
			var_short_fund_cd := short.FUND_CD;
			var_short_settle_date := short.SETTLE_DATE; 
			var_order_id := short.IM_ORDER_ID;
			var_o_qty := short.o_qty;
			var_fee := short.NSB_FEE; 
			var_nsb_settle_date := short.NSB_SETTLE_DATE;
			var_broker_cd := short.NSB_BROKER_CD;
			var_coll_type := short.NSB_COLLATERAL_TYPE;
			var_coll_code := short.NSB_COLLATERAL_CURRENCY_CD;
			var_prepay_date := short.PREPAY_DATE;
			var_prepay_rate := short.PREPAY_RATE;		
			var_reclaim_rate := short.NSB_NET_DIVIDEND;	
			var_overseas_tax := short.OVERSEAS_TAX_PERCENTAGE;			
			var_domestic_tax := short.DOMESTIC_TAX_PERCENTAGE;
			var_min_fee := short.MINIMUM_FEE;
			var_min_fee_cd := short.MINIMUM_FEE_CD;
			var_fund_coll_type := short.FUND_COLLATERAL_TYPE;
			var_legal_entity_cd:=short.LEGAL_ENTITY_CD;	
			var_branch_cd := short.BRANCH_CD;		
			var_o_holdback:= short.HOLDBACK_FLAG;
			
			EXIT WHEN var_a_found = 'Y';
		END LOOP;
		
		var_b_found := 'N';
		
		IF var_a_found = 'Y' THEN
			-- excess borrows with any branch can be allocated to 0189/DUMY
			IF p_r_alloc_key = 'DUMMY' AND var_short_fund_cd IS NOT NULL AND instr(GEC_CONSTANTS_PKG.GET_DUMMYWITH0189_FUNDS(),var_short_fund_cd||',')>0
		     THEN
				FOR m_b IN max_match_borrows_excess
				LOOP
					var_b_settle_date := m_b.SETTLE_DATE;
					
						var_b_found := 'Y';
						var_borrow_id := m_b.BORROW_ID; 
						var_b_qty := m_b.UNFILLED_QTY; 
						var_borrow_request_type := m_b.BORROW_REQUEST_TYPE;
				    	var_trade_country := m_b.TRADE_COUNTRY_CD;						
					
				
					EXIT WHEN var_b_found = 'Y';
				END LOOP;
			ELSE					
				IF var_branch_cd IS NOT NULL THEN
					FOR m_b IN max_match_borrows_bos
					LOOP
						var_b_settle_date := m_b.SETTLE_DATE;
						
							var_b_found := 'Y';
							var_borrow_id := m_b.BORROW_ID; 
							var_b_qty := m_b.UNFILLED_QTY; 
							var_borrow_request_type := m_b.BORROW_REQUEST_TYPE;
				    		var_trade_country := m_b.TRADE_COUNTRY_CD;							
						
				
						EXIT WHEN var_b_found = 'Y';
					END LOOP;
				--ELSE
				--	IF var_branch_cd IS NOT NULL  THEN				
				--		FOR m_b IN max_match_borrows
				--		LOOP
				--			var_b_settle_date := m_b.SETTLE_DATE;
				--			IF var_nsb_settle_date IS NULL OR (var_nsb_settle_date IS NOT NULL AND var_nsb_settle_date = var_b_settle_date) THEN
				--				var_b_found := 'Y';
				--				var_borrow_id := m_b.BORROW_ID; 
				--				var_b_qty := m_b.UNFILLED_QTY; 
				--				var_borrow_request_type := m_b.BORROW_REQUEST_TYPE;
				--   			var_trade_country := m_b.TRADE_COUNTRY_CD;								
				--			ELSE
				--				UPDATE GEC_IM_ORDER_TEMP SET ERROR_CODE = NVL(ERROR_CODE, 'VLD0075') WHERE IM_ORDER_ID = var_order_id;
				--			END IF;
				
				--			EXIT WHEN var_b_found = 'Y';
				--		END LOOP;
				--	END IF;
				END IF;			
			END IF;
		END IF;
	
		IF var_b_found = 'N' AND var_a_found = 'Y' THEN
			UPDATE GEC_IM_ORDER_TEMP SET AGENCY_RUN_FLAG = 'Y' WHERE IM_ORDER_ID = var_order_id;
			RETURN 'Y';
		ELSIF var_b_found = 'Y' AND var_a_found = 'Y' THEN
			IF var_coll_type IS NULL THEN
				GET_LOAN_INFO(var_trade_country, var_short_fund_cd, 'NSB', var_coll_type, var_domestic_tax, var_overseas_tax, var_error_code);	
				IF var_error_code IS NOT NULL THEN
					p_error_code := var_error_code;
					RETURN 'N';
				END IF;
			END IF;			
			BOOK_ONE_ALLOCATION(p_user_id, p_asset_id, var_short_fund_cd, var_short_settle_date, var_borrow_id, var_order_id, var_b_qty, var_o_qty, var_fee, var_nsb_settle_date,  var_prepay_date, var_prepay_rate, var_reclaim_rate, var_overseas_tax, var_domestic_tax, var_coll_type, var_coll_code, var_min_fee,var_min_fee_cd, var_borrow_request_type,var_broker_cd);
			RETURN 'Y';
		ELSE
			RETURN 'N';
		END IF;
	END REVERSE_SINGLE_ALLO_AGE;
	
	
	-- added for increasing performacne of response uploading, only used for auto-allocation
	PROCEDURE BOOK_ONE_ALLOCATION2(p_user_id IN VARCHAR2,
								  p_asset_id IN NUMBER, 
								  p_short_fund_cd IN VARCHAR2, 
								  p_short_settle_date IN NUMBER, 
								  p_borrow_id IN NUMBER, 
								  p_order_id IN NUMBER, 
								  p_b_qty IN NUMBER, 
								  p_o_qty IN NUMBER, 
								  p_fee IN NUMBER, 
								  p_l_settle_date IN NUMBER,
								  p_l_prepay_date IN NUMBER,
								  p_prepay_rate IN NUMBER,								  
								  p_reclaim_rate IN NUMBER,
								  p_oversea_tax IN NUMBER,
								  p_domestic_tax IN NUMBER,
								  p_coll_type IN VARCHAR2,
								  p_coll_code IN VARCHAR2,
								  p_min_fee IN NUMBER,
								  p_borrow_request_type IN VARCHAR2,
								  p_broker_cd IN VARCHAR2,
								  p_update_flag IN VARCHAR2)
	IS
	var_fill_qty GEC_BORROW.BORROW_QTY%type;
	var_found VARCHAR2(1);
	
	var_loan_id GEC_LOAN.LOAN_ID%type;
	var_allo_bookloan GEC_LOAN.LOAN_QTY%type;
	var_rem_fill_qty GEC_BORROW.BORROW_QTY%type;
	var_sum_loan_allo GEC_LOAN.LOAN_QTY%type;
	
	var_temp_qty GEC_BORROW.BORROW_QTY%type;
	
	var_allocated GEC_BORROW.BORROW_QTY%type;
	
	var_fee GEC_ALLOCATION.RATE%type;
	
	var_trade_date GEC_ALLOCATION.TRADE_DATE%type;
	var_trade_country GEC_ASSET.TRADE_COUNTRY_CD%type;
	
	
	BEGIN
		SELECT 
		TRADE_COUNTRY_CD
		INTO
		var_trade_country
		FROM
		GEC_ASSET
		WHERE 
		ASSET_ID=p_asset_id;
		IF var_trade_country = 'US' OR var_trade_country = 'CA' THEN
			var_trade_date:=TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDD'));
		ELSE
			var_trade_date:=TO_NUMBER(TO_CHAR(gec_utils_pkg.TO_TIMEZONE(sysdate,'America/New_York','Europe/London'),'YYYYMMDD'));
		END IF;
		IF p_b_qty > p_o_qty THEN
			var_fill_qty := p_o_qty;
		ELSE
			var_fill_qty := p_b_qty;
		END IF;
		
		
		
		var_fee := p_fee;
		
		UPDATE GEC_IM_ORDER SET FILLED_QTY = FILLED_QTY + var_fill_qty, 
								UPDATED_BY = p_user_id,
								UPDATED_AT = sysdate
		WHERE IM_ORDER_ID = p_order_id;
		
		UPDATE GEC_BORROW_TEMP SET UNFILLED_QTY = UNFILLED_QTY - var_fill_qty WHERE BORROW_ID = p_borrow_id;
		
		IF p_update_flag = 'Y' THEN
			UPDATE GEC_IM_ORDER_TEMP SET UNFILLED_QTY = UNFILLED_QTY - var_fill_qty WHERE IM_ORDER_ID = p_order_id;
			UPDATE GEC_BORROW_UNIT_TEMP SET UNFILLED_QTY = UNFILLED_QTY - var_fill_qty WHERE BORROW_ID = p_borrow_id;
		END IF;
		
		
		-- for deshaw, pre-booked loan
		var_rem_fill_qty := var_fill_qty;
		
		-- generate normal allocation
		IF var_rem_fill_qty > 0 THEN 
			INSERT INTO GEC_ALLOCATION(
								ALLOCATION_ID,
  							    BORROW_ID,
  								LOAN_ID,
  								IM_ORDER_ID,
  								ALLOCATION_QTY,
  								RATE,
  								SETTLE_DATE,
  								PREPAY_DATE,
  								PREPAY_RATE,
  								RECLAIM_RATE,
  								OVERSEAS_TAX_PERCENTAGE,
  								DOMESTIC_TAX_PERCENTAGE,
  								MINIMUM_FEE,
  								MINIMUM_FEE_CD,
  								COLLATERAL_TYPE,
  								COLLATERAL_CURRENCY_CD,
  								STATUS,
  								TRADE_DATE
							)VALUES(
								GEC_ALLOCATION_ID_SEQ.nextval,
								p_borrow_id,
								NULL,
								p_order_id,
								var_fill_qty,
								var_fee,
								p_l_settle_date,
								p_l_prepay_date,
								p_prepay_rate,
								p_reclaim_rate,
								p_oversea_tax,
								p_domestic_tax,
								p_min_fee,
								p_coll_code,
								p_coll_type,
								p_coll_code,
								GEC_CONSTANTS_PKG.C_ALLO_PROCESSED,
								var_trade_date
							);
		END IF;
	END BOOK_ONE_ALLOCATION2;
	-- p share 
	PROCEDURE GET_LOAN_DEF_SET_PRE_DATE(p_borrow_request_type IN VARCHAR2,
											  p_short_fund_cd IN VARCHAR2,
											  p_trade_country IN VARCHAR2,
											  p_short_settle_date IN NUMBER,
											  p_prepay_date OUT NUMBER,
											  p_settle_date OUT NUMBER)
		IS
		var_settle_date_value NUMBER(3);
		var_prepay_date_value NUMBER(3);
		var_coll_code_trade_country GEC_ASSET.TRADE_COUNTRY_CD%type;
		var_prepay_day NUMBER(3);
		var_request_type GEC_BORROW_REQUEST.BORROW_REQUEST_TYPE%type;
		var_g1_booking_id GEC_G1_BOOKING.G1_BOOKING_ID%type;
		var_counter_party_cd GEC_G1_BOOKING.COUNTERPARTY_CD%type;
		var_coll_cd GEC_G1_BOOKING.COLLATERAL_CURRENCY_CD%type;
		var_found_loan_data VARCHAR2(1);
		v_error_code VARCHAR2(1);
		var_prepay_date_flag GEC_LOAN_DEF_VALUE_RULE.COUNTRY_PREPAY_DATE_VALUE_FLAG%type;
		CURSOR loan_info IS
			SELECT gb.G1_BOOKING_ID, gb.COUNTERPARTY_CD, gb.COLLATERAL_CURRENCY_CD                
			FROM GEC_G1_BOOKING gb
			WHERE gb.FUND_CD = p_short_fund_cd AND
			  	gb.TRANSACTION_CD = 'G1L' AND
			  	gb.POS_TYPE = var_request_type;
		CURSOR loan_collateral IS
	    	SELECT gc.COLLATERAL_CURRENCY_CD, gc.COLL_TYPE
	    	FROM GEC_G1_COLLATERAL gc
	    	WHERE gc.G1_BOOKING_ID = var_g1_booking_id AND
	    		  gc.TRADE_COUNTRY_CD = p_trade_country;	
		BEGIN
		IF p_borrow_request_type = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB THEN
			var_request_type := p_borrow_request_type;
		ELSE
			var_request_type := GEC_CONSTANTS_PKG.C_BORROW_REQUEST_NSB;
		END IF;
		FOR l_i IN loan_info
		LOOP	
			v_error_code := NULL;	
			var_g1_booking_id := l_i.G1_BOOKING_ID;
			var_counter_party_cd := l_i.COUNTERPARTY_CD;
			var_coll_cd := l_i.COLLATERAL_CURRENCY_CD;
			var_found_loan_data := 'N';				
			FOR l_c IN loan_collateral
			LOOP
				var_found_loan_data := 'Y';
				var_coll_cd := l_c.COLLATERAL_CURRENCY_CD; 
				EXIT WHEN var_found_loan_data = 'Y';	
			END LOOP;
			EXIT WHEN v_error_code is null;	
		END LOOP;
		BEGIN
			SELECT gldvr.SETTLE_DATE_VALUE,gldvr.PREPAY_DATE_VALUE,gldvr.COUNTRY_PREPAY_DATE_VALUE_FLAG
			INTO var_settle_date_value,var_prepay_date_value,var_prepay_date_flag
			FROM GEC_LOAN_DEF_VALUE_RULE gldvr,GEC_COUNTRY_CATEGORY_MAP gccm,GEC_FUND gf
			WHERE
			gldvr.BORROW_REQUEST_TYPE=var_request_type
			AND gldvr.COUNTRY_CATEGORY_CD=gccm.COUNTRY_CATEGORY_CD
			AND (gldvr.FUND_CATEGORY_CD=gf.FUND_CATEGORY_CD OR (gf.FUND_CATEGORY_CD IS NULL AND gldvr.FUND_CATEGORY_CD='SGF'))
			AND gccm.COUNTRY_CD=p_trade_country
			AND gf.FUND_CD = p_short_fund_cd;
		EXCEPTION WHEN NO_DATA_FOUND THEN
			SELECT gldvr.SETTLE_DATE_VALUE,gldvr.PREPAY_DATE_VALUE,gldvr.COUNTRY_PREPAY_DATE_VALUE_FLAG
			INTO var_settle_date_value,var_prepay_date_value,var_prepay_date_flag
			FROM GEC_LOAN_DEF_VALUE_RULE gldvr
			WHERE
			gldvr.BORROW_REQUEST_TYPE=var_request_type
			AND gldvr.COUNTRY_CATEGORY_CD='ALL'
			AND gldvr.FUND_CATEGORY_CD='ALL';
		END;
		IF var_prepay_date_flag ='N' THEN
			var_prepay_day:=0;
		ELSE
			BEGIN
				SELECT gcbp.PREPAY_DATE_VALUE INTO var_prepay_day
				FROM GEC_COUNTRY_BROKER_PROFILE gcbp
				WHERE gcbp.TRADE_COUNTRY_CD = p_trade_country
				AND gcbp.BROKER_CD = var_counter_party_cd;
			EXCEPTION WHEN NO_DATA_FOUND THEN
				SELECT gtc.PREPAY_DATE_VALUE INTO var_prepay_day
				FROM GEC_TRADE_COUNTRY gtc
				WHERE gtc.TRADE_COUNTRY_CD=p_trade_country;
			END;
		END IF;
		SELECT TRADE_COUNTRY_CD INTO var_coll_code_trade_country FROM GEC_TRADE_COUNTRY
		WHERE CURRENCY_CD=var_coll_cd;
		p_prepay_date:=GEC_UTILS_PKG.GET_TMINUSN_NUM(p_short_settle_date,var_prepay_day+var_prepay_date_value,var_coll_code_trade_country,'S');
		p_settle_date:=GEC_UTILS_PKG.GET_TMINUSN_NUM(p_short_settle_date,var_settle_date_value,p_trade_country,'S');
		
		IF GEC_UTILS_PKG.IS_WORKDAY(GEC_UTILS_PKG.NUMBER_TO_DATE(p_prepay_date),var_coll_code_trade_country,'S') ='N' THEN
				p_prepay_date:=GEC_UTILS_PKG.GET_TMINUSN_NUM(p_prepay_date,1,var_coll_code_trade_country,'S');
		END IF;
		IF GEC_UTILS_PKG.IS_WORKDAY(GEC_UTILS_PKG.NUMBER_TO_DATE(p_settle_date),p_trade_country,'S') ='N' THEN
				p_settle_date:=GEC_UTILS_PKG.GET_TMINUSN_NUM(p_settle_date,1,p_trade_country,'S');
		END IF;
		
		IF p_prepay_date>p_settle_date THEN
			p_prepay_date:=p_settle_date;
			IF GEC_UTILS_PKG.IS_WORKDAY(GEC_UTILS_PKG.NUMBER_TO_DATE(p_prepay_date),var_coll_code_trade_country,'S') ='N' THEN
				p_prepay_date:=GEC_UTILS_PKG.GET_TMINUSN_NUM(p_settle_date,1,var_coll_code_trade_country,'S');
			END IF;
		END IF;
	END GET_LOAN_DEF_SET_PRE_DATE;
	-- end p share
	-- only used for reverse-allocation
	PROCEDURE BOOK_ONE_ALLOCATION(p_user_id IN VARCHAR2,
								  p_asset_id IN NUMBER, 
								  p_short_fund_cd IN VARCHAR2, 
								  p_short_settle_date IN NUMBER, 
								  p_borrow_id IN NUMBER, 
								  p_order_id IN NUMBER, 
								  p_b_qty IN NUMBER, 
								  p_o_qty IN NUMBER, 
								  p_fee IN NUMBER, 
								  p_l_settle_date IN NUMBER,
								  p_l_prepay_date IN NUMBER,
								  p_prepay_rate IN NUMBER,
								  p_reclaim_rate IN NUMBER,
								  p_oversea_tax IN NUMBER,
								  p_domestic_tax IN NUMBER,
								  p_coll_type IN VARCHAR2,
								  p_coll_code IN VARCHAR2,
								  p_min_fee IN NUMBER,	
								  p_min_fee_cd IN VARCHAR2,							  
								  p_borrow_request_type IN VARCHAR2,
								  p_broker_cd IN VARCHAR2)
	IS
	var_fill_qty GEC_BORROW.BORROW_QTY%type;
	var_found VARCHAR2(1);
	var_comment_txt VARCHAR2(4000);
	var_loan_id GEC_LOAN.LOAN_ID%type;
	var_allo_bookloan GEC_LOAN.LOAN_QTY%type;
	var_rem_fill_qty GEC_BORROW.BORROW_QTY%type;
	var_sum_loan_allo GEC_LOAN.LOAN_QTY%type;
	
	var_temp_qty GEC_BORROW.BORROW_QTY%type;
	
	var_allocated GEC_BORROW.BORROW_QTY%type;
	
	var_fee GEC_ALLOCATION.RATE%type;
	var_term_date GEC_ALLOCATION.term_date%type;
	var_expected_return_date GEC_ALLOCATION.EXPECTED_RETURN_DATE%type;
	var_trade_date GEC_ALLOCATION.trade_date%type;
	
	CURSOR v_prebooked_loans IS
		SELECT a.ALLOCATION_ID, a.BORROW_ID, a.IM_ORDER_ID, a.LOAN_ID, l.LOAN_QTY, a.ALLOCATION_QTY
		FROM GEC_LOAN l, GEC_ALLOCATION a
		WHERE a.IM_ORDER_ID = p_order_id AND
			  a.LOAN_ID = l.LOAN_ID AND
			  l.TYPE = 'PRE-LOAN';

	BEGIN	
		SELECT 
				LOAN_DATE,TERM_DATE,EXPECTED_RETURN_DATE,COMMENT_TXT
		INTO
				var_trade_date,var_term_date,var_expected_return_date,var_comment_txt
		FROM
			GEC_IM_ORDER_TEMP 
		WHERE 
			IM_ORDER_ID = p_order_id;
		IF p_b_qty > p_o_qty THEN
			var_fill_qty := p_o_qty;
		ELSE
			var_fill_qty := p_b_qty;
		END IF;
		
		var_fee := p_fee;
		
		-- update the orders
		UPDATE GEC_IM_ORDER SET FILLED_QTY = FILLED_QTY + var_fill_qty,
								UPDATED_BY = p_user_id,
								UPDATED_AT = sysdate
		WHERE IM_ORDER_ID = p_order_id;
		
		UPDATE GEC_IM_ORDER_TEMP SET UNFILLED_QTY = UNFILLED_QTY - var_fill_qty WHERE IM_ORDER_ID = p_order_id;
		
		IF p_borrow_request_type = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB THEN
			UPDATE GEC_IM_ORDER_TEMP SET FILLED_SB_QTY = FILLED_SB_QTY + var_fill_qty WHERE IM_ORDER_ID = p_order_id;
		ELSE
			UPDATE GEC_IM_ORDER_TEMP SET FILLED_NSB_QTY = FILLED_NSB_QTY + var_fill_qty WHERE IM_ORDER_ID = p_order_id;
		END IF;
		
		-- update temp borrow
		UPDATE GEC_BORROW_TEMP SET UNFILLED_QTY = UNFILLED_QTY - var_fill_qty WHERE BORROW_ID = p_borrow_id;
		
		-- for deshaw, pre-booked loan
		var_rem_fill_qty := var_fill_qty;
		FOR b_l IN v_prebooked_loans
		LOOP
			SELECT SUM(ALLOCATION_QTY) INTO var_sum_loan_allo FROM GEC_ALLOCATION WHERE LOAN_ID = b_l.LOAN_ID AND ALLOCATION_QTY IS NOT NULL;
			var_allo_bookloan := b_l.LOAN_QTY - var_sum_loan_allo;
			
			IF var_allo_bookloan > var_rem_fill_qty THEN
                var_allocated := var_rem_fill_qty;
            ELSE
                var_allocated := var_allo_bookloan;
            END IF;
            
			
			IF var_allocated > 0 THEN
				INSERT INTO GEC_ALLOCATION(
									ALLOCATION_ID,
	  							    BORROW_ID,
	  								LOAN_ID,
	  								IM_ORDER_ID,
	  								ALLOCATION_QTY,
	  								RATE,
	  								SETTLE_DATE,
  									PREPAY_DATE,
  									PREPAY_RATE,
  									RECLAIM_RATE,
  									OVERSEAS_TAX_PERCENTAGE,
  									DOMESTIC_TAX_PERCENTAGE,
  									MINIMUM_FEE,
  									MINIMUM_FEE_CD,
  									COLLATERAL_TYPE,
  									COLLATERAL_CURRENCY_CD,	  								
	  								STATUS,
	  								TERM_DATE,
	  								EXPECTED_RETURN_DATE,
	  								TRADE_DATE,
	  								COMMENT_TXT
								)VALUES(
									GEC_ALLOCATION_ID_SEQ.nextval,
									p_borrow_id,
									b_l.LOAN_ID,
									p_order_id,
									var_allocated,
									var_fee,
									p_l_settle_date,
									p_l_prepay_date,
									p_prepay_rate,
									p_reclaim_rate,
									p_oversea_tax,
									p_domestic_tax,
									p_min_fee,
									p_min_fee_cd,
									p_coll_type,
									p_coll_code,									
									GEC_CONSTANTS_PKG.C_ALLO_BOOKED,
									var_term_date,
									var_expected_return_date,
									var_trade_date,
									var_comment_txt
								);
				var_rem_fill_qty := var_rem_fill_qty - var_allocated;
			END IF;
		END LOOP;
		
		-- generate normal allocation
		IF var_rem_fill_qty > 0 THEN 
			INSERT INTO GEC_ALLOCATION(
								ALLOCATION_ID,
  							    BORROW_ID,
  								LOAN_ID,
  								IM_ORDER_ID,
  								ALLOCATION_QTY,
  								RATE,
  								SETTLE_DATE,
  								PREPAY_DATE,
  								PREPAY_RATE,
  								RECLAIM_RATE,
  								OVERSEAS_TAX_PERCENTAGE,
  								DOMESTIC_TAX_PERCENTAGE,
  								MINIMUM_FEE,
  								MINIMUM_FEE_CD,
  								COLLATERAL_TYPE,
  								COLLATERAL_CURRENCY_CD,	  	  								
  								STATUS,
  								TERM_DATE,
  								EXPECTED_RETURN_DATE,
	  							TRADE_DATE,
	  							COMMENT_TXT
							)VALUES(
								GEC_ALLOCATION_ID_SEQ.nextval,
								p_borrow_id,
								NULL,
								p_order_id,
								var_fill_qty,
								var_fee,
								p_l_settle_date,
								p_l_prepay_date,
								p_prepay_rate,
								p_reclaim_rate,
								p_oversea_tax,
								p_domestic_tax,
								p_min_fee,
								p_min_fee_cd,
								p_coll_type,
								p_coll_code,									
								GEC_CONSTANTS_PKG.C_ALLO_PROCESSED,
								var_term_date,
								var_expected_return_date,
								var_trade_date,
								var_comment_txt
							);
		END IF;
	END BOOK_ONE_ALLOCATION;
	
	PROCEDURE GET_LOAN_INFO(p_trade_country_cd IN VARCHAR2,
								  p_fund_cd IN VARCHAR2,
								  p_borrow_request_type IN VARCHAR2,
								  p_coll_type OUT VARCHAR2,
								  p_domestic_tax OUT NUMBER, 
								  p_overseas_tax OUT NUMBER, 
								  p_error_code OUT VARCHAR2)
	IS
	var_g1_booking_id GEC_G1_BOOKING.G1_BOOKING_ID%type;
	var_coll_type GEC_G1_BOOKING.COLL_TYPE%type;
	var_overseas_tax GEC_G1_BOOKING.OVERSEAS_TAX_PERCENTAGE%type;			
	var_domestic_tax GEC_G1_BOOKING.DOMESTIC_TAX_PERCENTAGE%type;
	var_found_loan_data VARCHAR2(1);
	var_request_type GEC_BORROW_REQUEST.BORROW_REQUEST_TYPE%type;	
	
	CURSOR loan_info IS
		SELECT gb.G1_BOOKING_ID, gb.OVERSEAS_TAX_PERCENTAGE, gb.DOMESTIC_TAX_PERCENTAGE, gb.COLL_TYPE                 
		FROM GEC_G1_BOOKING gb
		WHERE gb.FUND_CD = p_fund_cd AND
			  gb.TRANSACTION_CD = 'G1L' AND
			  gb.POS_TYPE = var_request_type;	

	CURSOR loan_reclaim_rate IS
	    SELECT rr.RECLAIM_RATE, rr.OVERSEAS_TAX_PERCENTAGE, rr.DOMESTIC_TAX_PERCENTAGE
	    FROM GEC_G1_RECLAIM_RATE rr
	    WHERE rr.G1_BOOKING_ID = var_g1_booking_id AND
	    	  rr.TRADE_COUNTRY_CD = p_trade_country_cd;	
	    	  
	CURSOR loan_collateral IS
	    SELECT  gc.COLL_TYPE
	    FROM GEC_G1_COLLATERAL gc
	    WHERE gc.G1_BOOKING_ID = var_g1_booking_id AND
	    		  gc.TRADE_COUNTRY_CD = p_trade_country_cd;	
	
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START('GET_LOAN_INFO');
		IF p_borrow_request_type = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB THEN
			var_request_type := p_borrow_request_type;
		ELSE
			var_request_type := GEC_CONSTANTS_PKG.C_BORROW_REQUEST_NSB;
		END IF;		
		
		p_error_code := 'VLD0131';
		 
		FOR l_i IN loan_info
		LOOP
			p_error_code := NULL;		
			var_g1_booking_id := l_i.G1_BOOKING_ID;
			var_overseas_tax := l_i.OVERSEAS_TAX_PERCENTAGE;
			var_domestic_tax := l_i.DOMESTIC_TAX_PERCENTAGE;
			var_coll_type := l_i.COLL_TYPE;
								
			-- get net dividend for allocation
			var_found_loan_data := 'N';			
			FOR l_r_r IN loan_reclaim_rate
			LOOP
				var_found_loan_data := 'Y';
								
				var_overseas_tax := l_r_r.OVERSEAS_TAX_PERCENTAGE;
				var_domestic_tax := l_r_r.DOMESTIC_TAX_PERCENTAGE;
					
				EXIT WHEN var_found_loan_data = 'Y';	
			END LOOP;	

			-- get collateral for allocation
			var_found_loan_data := 'N';				
			FOR l_c IN loan_collateral
			LOOP
				var_found_loan_data := 'Y';
				var_coll_type := l_c.COLL_TYPE;
					
				EXIT WHEN var_found_loan_data = 'Y';	
			END LOOP;		
			EXIT WHEN p_error_code IS NULL;
		END LOOP;	
		
		IF var_coll_type IS NULL THEN
			p_error_code := 'VLD0135';
		END IF;		
					
		IF var_overseas_tax IS NULL THEN
			p_error_code := 'VLD0137';			
		END IF;	
		
		IF var_domestic_tax IS NULL THEN
			p_error_code := 'VLD0138';		
		END IF;			
		
		IF p_coll_type IS NULL THEN
			p_coll_type := var_coll_type;
		END IF;
		
		IF p_domestic_tax IS NULL OR p_overseas_tax IS NULL THEN
			p_domestic_tax := var_domestic_tax;
			p_overseas_tax := var_overseas_tax;
		END IF;
		
	END GET_LOAN_INFO;
	
	PROCEDURE GET_COLL_CODE_TYPE_INFO(p_trade_country IN VARCHAR2,
									  p_fund_cd IN VARCHAR2,
									  p_sb_coll_type OUT VARCHAR2,
									  p_nsb_coll_type OUT VARCHAR2,
									  p_sb_coll_code OUT VARCHAR2,
									  p_nsb_coll_code OUT VARCHAR2)
	IS
	var_g1_booking_id GEC_G1_BOOKING.G1_BOOKING_ID%type;	
	var_sb_coll_cd GEC_G1_BOOKING.COLLATERAL_CURRENCY_CD%type;
	var_nsb_coll_cd GEC_G1_BOOKING.COLLATERAL_CURRENCY_CD%type;	
	var_sb_coll_type GEC_G1_BOOKING.COLL_TYPE%type;
	var_nsb_coll_type GEC_G1_BOOKING.COLL_TYPE%type;	
	
	var_found_flag VARCHAR2(1);
	var_found_loan VARCHAR2(1);
		
	CURSOR loan_info_sb IS
		SELECT gb.G1_BOOKING_ID, gb.COLLATERAL_CURRENCY_CD, gb.COLL_TYPE 
		FROM GEC_G1_BOOKING gb
		WHERE gb.FUND_CD = p_fund_cd AND
		  	gb.TRANSACTION_CD = 'G1L' AND
		  	gb.POS_TYPE = 'SB';
		  	
	CURSOR loan_info_nsb IS
		SELECT gb.G1_BOOKING_ID, gb.COLLATERAL_CURRENCY_CD, gb.COLL_TYPE 
		FROM GEC_G1_BOOKING gb
		WHERE gb.FUND_CD = p_fund_cd AND
		  	gb.TRANSACTION_CD = 'G1L' AND
		  	gb.POS_TYPE = 'NSB';		  	
		  	
    CURSOR loan_collateral_info IS
	    SELECT gc.COLLATERAL_CURRENCY_CD, gc.COLL_TYPE
	    FROM GEC_G1_COLLATERAL gc
	    WHERE gc.G1_BOOKING_ID = var_g1_booking_id AND
	    	  gc.TRADE_COUNTRY_CD = p_trade_country;	 
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START('GET_COLL_CODE_TYPE_INFO');
		
		var_found_loan := 'N';
		FOR l_i_s IN loan_info_sb
		LOOP
			var_found_loan := 'Y';
			var_g1_booking_id := l_i_s.G1_BOOKING_ID;
			var_sb_coll_cd := l_i_s.COLLATERAL_CURRENCY_CD;
			var_sb_coll_type := l_i_s.COLL_TYPE;
			
			var_found_flag := 'N';
			FOR l_c_i IN loan_collateral_info	
			LOOP
				var_found_flag := 'Y';
				var_sb_coll_cd := l_c_i.COLLATERAL_CURRENCY_CD;
				var_sb_coll_type := l_c_i.COLL_TYPE;
				EXIT WHEN var_found_flag = 'Y';
			END LOOP;
			
		    EXIT WHEN var_found_loan = 'Y';	
		END LOOP;
		
		var_found_loan := 'N';
		FOR l_i_n IN loan_info_nsb
		LOOP
			var_found_loan := 'Y';
			var_g1_booking_id := l_i_n.G1_BOOKING_ID;
			var_nsb_coll_cd := l_i_n.COLLATERAL_CURRENCY_CD;
			var_nsb_coll_type := l_i_n.COLL_TYPE;
			
			var_found_flag := 'N';
			FOR l_c_i IN loan_collateral_info	
			LOOP
				var_found_flag := 'Y';
				var_nsb_coll_cd := l_c_i.COLLATERAL_CURRENCY_CD;
				var_nsb_coll_type := l_c_i.COLL_TYPE;
				EXIT WHEN var_found_flag = 'Y';
			END LOOP;
			
		    EXIT WHEN var_found_loan = 'Y';	
		 END LOOP;	
		 
		 p_sb_coll_type := var_sb_coll_type;
		 p_nsb_coll_type := var_nsb_coll_type;
		 p_sb_coll_code := var_sb_coll_cd;
		 p_nsb_coll_code := var_nsb_coll_cd;
	
	END GET_COLL_CODE_TYPE_INFO;
	
	PROCEDURE CHECK_FUND_CONFIG_ORDER_LOAN(p_im_order_ids IN GEC_NUMBER_ARRAY,
	                                       p_error_code OUT VARCHAR2,
	                                       p_fund OUT VARCHAR2,
	                                       p_trade_country OUT VARCHAR2)
	IS
	                 
        VAR_NOCPTY_COUNT  NUMBER(10);
        VAR_WITH_TYPE_CODE_ECP_COUNT NUMBER(10);
        VAR_ALL_EXCEPTION_COUNT NUMBER(10);
        VAR_NO_TYPE_CODE_ECP_COUNT NUMBER(10);
        VAR_NO_TYPE_CODE_COUNT NUMBER(10);
        VAR_FUND_COUNT NUMBER(10);
        VAR_WITH_TYPE_CODE_COUNT NUMBER(10);
        VAR_WITHOUT_TYPE_CODE_COUNT NUMBER(10);
        CURSOR FUND_CDS IS
            SELECT DISTINCT GIO.FUND_CD
            FROM TABLE ( cast ( P_IM_ORDER_IDS as GEC_NUMBER_ARRAY) ) orders,  GEC_IM_ORDER GIO
            WHERE orders.COLUMN_VALUE =GIO.IM_ORDER_ID;
        CURSOR TRADE_COUNTRYIES(P_FUND_CD IN VARCHAR2) IS
            SELECT DISTINCT GIO.TRADE_COUNTRY_CD
            FROM TABLE ( cast ( P_IM_ORDER_IDS as GEC_NUMBER_ARRAY) ) orders,  GEC_IM_ORDER GIO
            WHERE orders.COLUMN_VALUE =GIO.IM_ORDER_ID AND GIO.FUND_CD = P_FUND_CD;
        V_TRADE_COUNTRY GEC_IM_ORDER.TRADE_COUNTRY_CD%TYPE;
        V_G1_BOOKING_ID GEC_G1_BOOKING.G1_BOOKING_ID%TYPE;                    
	BEGIN
	    
	    FOR V_FUND_CD IN FUND_CDS
	    LOOP
	        SELECT COUNT(*) INTO VAR_NOCPTY_COUNT
            FROM GEC_G1_BOOKING GGB
            WHERE GGB.FUND_CD = V_FUND_CD.FUND_CD AND GGB.TRANSACTION_CD='G1L' AND GGB.POS_TYPE ='NSB'
                 AND TRIM(GGB.COUNTERPARTY_CD) IS NOT  NULL;
	        IF VAR_NOCPTY_COUNT =0 THEN
	            P_ERROR_CODE := 'VLD0139';
	            P_FUND := V_FUND_CD.FUND_CD;
	            p_trade_country := NULL;
	            RETURN;
	        END IF;
	        
	        SELECT G1_BOOKING_ID INTO V_G1_BOOKING_ID
	        FROM GEC_G1_BOOKING GGB
	        WHERE GGB.FUND_CD = V_FUND_CD.FUND_CD AND GGB.TRANSACTION_CD='G1L' AND GGB.POS_TYPE ='NSB';
	        
	        OPEN TRADE_COUNTRYIES(V_FUND_CD.FUND_CD);
	        FETCH TRADE_COUNTRYIES INTO V_TRADE_COUNTRY;
        
            WHILE TRADE_COUNTRYIES%FOUND
            LOOP
               SELECT COUNT(*) INTO VAR_ALL_EXCEPTION_COUNT
	           FROM GEC_G1_BOOKING GGB
	           INNER JOIN GEC_G1_COLLATERAL GGC
	           ON GGB.G1_BOOKING_ID = GGC.G1_BOOKING_ID AND GGC.TRADE_COUNTRY_CD= V_TRADE_COUNTRY
	           WHERE GGB.G1_BOOKING_ID = V_G1_BOOKING_ID;
	            
	           IF VAR_ALL_EXCEPTION_COUNT >0 THEN --TOO CHECK IF THE COLL TYPE AND CODE IS BLANK FOR THE TRADE COUNTRY
		            SELECT COUNT(*) INTO VAR_WITH_TYPE_CODE_ECP_COUNT
		            FROM GEC_G1_COLLATERAL GGC
		            WHERE GGC.TRADE_COUNTRY_CD= V_TRADE_COUNTRY AND TRIM(GGC.COLL_TYPE) IS NOT NULL 
                        AND TRIM(GGC.COLLATERAL_CURRENCY_CD) IS NOT NULL AND GGC.G1_BOOKING_ID=V_G1_BOOKING_ID;
                    IF VAR_WITH_TYPE_CODE_ECP_COUNT <> VAR_ALL_EXCEPTION_COUNT THEN
                        P_ERROR_CODE := 'VLD0159';
	                    P_FUND := V_FUND_CD.FUND_CD;
	                    p_trade_country := V_TRADE_COUNTRY;
	                    RETURN;
                    END IF;
               ELSE
                    SELECT COUNT(*) INTO VAR_WITH_TYPE_CODE_COUNT
	                FROM GEC_G1_BOOKING GGB
	                WHERE GGB.G1_BOOKING_ID=V_G1_BOOKING_ID
                        AND (TRIM(GGB.COUNTERPARTY_CD) IS  NULL OR TRIM(GGB.COLL_TYPE) IS  NULL 
                        OR TRIM(GGB.COLLATERAL_CURRENCY_CD) IS  NULL);
                    IF VAR_WITH_TYPE_CODE_COUNT>0 THEN
                        P_ERROR_CODE := 'VLD0145';
	                    P_FUND := V_FUND_CD.FUND_CD;
	                    p_trade_country := NULL;
	                    RETURN;
                    END IF;    
               END IF;
               VAR_ALL_EXCEPTION_COUNT := NULL;
               VAR_WITH_TYPE_CODE_ECP_COUNT := NULL;
               VAR_WITH_TYPE_CODE_COUNT := NULL;
               FETCH TRADE_COUNTRYIES INTO V_TRADE_COUNTRY; 
            END LOOP;
            CLOSE TRADE_COUNTRYIES;
	        
	        V_G1_BOOKING_ID := NULL;
	        VAR_NOCPTY_COUNT := NULL;
	        VAR_WITHOUT_TYPE_CODE_COUNT := NULL;
	    END LOOP;
	    P_ERROR_CODE := NULL;
	    P_FUND := NULL;
	    P_TRADE_COUNTRY := NULL;
	    
	             
	    
	END CHECK_FUND_CONFIG_ORDER_LOAN;  
	
	FUNCTION GET_NONUS_EX_LOAN_INFO(p_borrow_request_type IN VARCHAR2, p_fund_cd IN VARCHAR2, p_trade_country_cd IN VARCHAR2, p_borrow_settle_date IN NUMBER, p_prepay_date IN NUMBER, p_error_code OUT VARCHAR2) RETURN NONUS_FUND_EX_LOAN_INFO
	IS
		var_request_type GEC_BORROW_REQUEST.BORROW_REQUEST_TYPE%type;
		var_nonus_fund_loan_info NONUS_FUND_EX_LOAN_INFO;
		var_g1_booking_id GEC_G1_BOOKING.G1_BOOKING_ID%type;
		var_counter_party_cd GEC_G1_BOOKING.COUNTERPARTY_CD%type;
		var_reclaim_rate GEC_G1_BOOKING.RECLAIM_RATE%type;	
		var_overseas_tax GEC_G1_BOOKING.OVERSEAS_TAX_PERCENTAGE%type;			
		var_domestic_tax GEC_G1_BOOKING.DOMESTIC_TAX_PERCENTAGE%type;
		var_coll_cd GEC_G1_BOOKING.COLLATERAL_CURRENCY_CD%type;
		var_coll_type GEC_G1_BOOKING.COLL_TYPE%type;
		var_prepay_rate GEC_COUNTERPARTY.PREPAY_RATE%type;
		var_bench_index GEC_COUNTERPARTY.BENCHMARK_INDEX_CD%type;
		
		var_found_loan_data VARCHAR2(1);
	
		CURSOR loan_info IS
			SELECT gb.G1_BOOKING_ID, gb.COUNTERPARTY_CD, gb.COLLATERAL_CURRENCY_CD, gb.COLL_TYPE, gb.RECLAIM_RATE, gb.OVERSEAS_TAX_PERCENTAGE, gb.DOMESTIC_TAX_PERCENTAGE                  
			FROM GEC_G1_BOOKING gb
			WHERE gb.FUND_CD = p_fund_cd AND
			  	gb.TRANSACTION_CD = 'G1L' AND
			  	gb.POS_TYPE = var_request_type;
	    
	    CURSOR loan_reclaim_rate IS
	    	SELECT rr.RECLAIM_RATE, rr.OVERSEAS_TAX_PERCENTAGE, rr.DOMESTIC_TAX_PERCENTAGE
	    	FROM GEC_G1_RECLAIM_RATE rr
	    	WHERE rr.G1_BOOKING_ID = var_g1_booking_id AND
	    		  rr.TRADE_COUNTRY_CD = p_trade_country_cd;
	    		  
	    CURSOR loan_collateral IS
	    	SELECT gc.COLLATERAL_CURRENCY_CD, gc.COLL_TYPE
	    	FROM GEC_G1_COLLATERAL gc
	    	WHERE gc.G1_BOOKING_ID = var_g1_booking_id AND
	    		  gc.TRADE_COUNTRY_CD = p_trade_country_cd;	    		    	
	    	
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START('GET_NONUS_EX_LOAN_INFO');
		IF p_borrow_request_type = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB THEN
			var_request_type := p_borrow_request_type;
		ELSE
			var_request_type := GEC_CONSTANTS_PKG.C_BORROW_REQUEST_NSB;
		END IF;
		
		p_error_code := 'VLD0131';
		
		FOR l_i IN loan_info
		LOOP
			p_error_code := NULL;		
			var_g1_booking_id := l_i.G1_BOOKING_ID;
			var_counter_party_cd := l_i.COUNTERPARTY_CD;
			var_reclaim_rate := l_i.RECLAIM_RATE;
			var_overseas_tax := l_i.OVERSEAS_TAX_PERCENTAGE;
			var_domestic_tax := l_i.DOMESTIC_TAX_PERCENTAGE;
			var_coll_cd := l_i.COLLATERAL_CURRENCY_CD;
			var_coll_type := l_i.COLL_TYPE;	
					
			-- get net dividend for allocation
			var_found_loan_data := 'N';			
			FOR l_r_r IN loan_reclaim_rate
			LOOP
				var_found_loan_data := 'Y';
								
				var_reclaim_rate := l_r_r.RECLAIM_RATE; 
				var_overseas_tax := l_r_r.OVERSEAS_TAX_PERCENTAGE;
				var_domestic_tax := l_r_r.DOMESTIC_TAX_PERCENTAGE;
					
				EXIT WHEN var_found_loan_data = 'Y';	
			END LOOP;
			
			-- get collateral for allocation
			var_found_loan_data := 'N';				
			FOR l_c IN loan_collateral
			LOOP
				var_found_loan_data := 'Y';
				var_coll_cd := l_c.COLLATERAL_CURRENCY_CD; 
				var_coll_type := l_c.COLL_TYPE;
					
				EXIT WHEN var_found_loan_data = 'Y';	
			END LOOP;
			
			-- get prepay rate for allocation
			BEGIN
				SELECT PREPAY_RATE, BENCHMARK_INDEX_CD INTO var_prepay_rate, var_bench_index FROM GEC_COUNTERPARTY 
				WHERE COUNTERPARTY_CD = var_counter_party_cd AND 
				TRANSACTION_CD = 'G1L';
			EXCEPTION WHEN NO_DATA_FOUND THEN
			    var_prepay_rate := NULL;
          		var_bench_index := NULL;
          	END;
          		
			IF var_prepay_rate IS NULL AND var_bench_index IS NOT NULL THEN
				BEGIN
					SELECT RATE INTO var_prepay_rate FROM GEC_BENCHMARK_INDEX_RATE
					WHERE BENCHMARK_INDEX_CD = var_bench_index;
          		EXCEPTION WHEN NO_DATA_FOUND THEN
            		var_prepay_rate := NULL;
          		END;					
			END IF;	
										
			EXIT WHEN p_error_code IS NULL;
		END LOOP;
						
		IF var_reclaim_rate IS NULL THEN
			p_error_code := 'VLD0132';
			RETURN var_nonus_fund_loan_info;
		END IF;
		
		IF var_overseas_tax IS NULL THEN
			p_error_code := 'VLD0137';
			RETURN var_nonus_fund_loan_info;			
		END IF;	
		
		IF var_domestic_tax IS NULL THEN
			p_error_code := 'VLD0138';
			RETURN var_nonus_fund_loan_info;			
		END IF;
		
		IF var_coll_cd IS NULL THEN
			p_error_code := 'VLD0136';
			RETURN var_nonus_fund_loan_info;			
		END IF;
		
		IF var_coll_type IS NULL THEN
			p_error_code := 'VLD0135';
			RETURN var_nonus_fund_loan_info;			
		END IF;	
		IF var_prepay_rate IS NULL AND (var_coll_type = 'C' OR var_coll_type = 'P') AND (p_prepay_date < p_borrow_settle_date) THEN
			IF p_borrow_request_type=GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB OR(p_borrow_request_type<>GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND (p_trade_country_cd='US' OR p_trade_country_cd='CA')) THEN
				p_error_code := 'VLD0134';
				RETURN var_nonus_fund_loan_info;	
			END IF;
					
		END IF;	
		
		-- to fix the defect PRTLB00868641 ,we do next code in the GET_NONUS_EX_LOAN_INFO_MAP
		--IF var_coll_type = 'C' AND p_prepay_date = p_borrow_settle_date THEN
		--	var_prepay_rate := NULL;
		--END IF;			
		
		-- MF19.3.1. If collateral Type of this fund’s G1 loan is C (for Cash) and  NSB Prepay Date is less than Loan Setl Date, then Prepay rate is required, Prepay Rate will get from loan Counterparty static data. if not found from ‘Manage Prepay Rates’, then highlight the prepay rate field with tips
		--IF var_coll_type = 'N' OR var_coll_type = 'P' THEN
		--	var_prepay_rate := NULL;
		--END IF;		
		
		var_nonus_fund_loan_info.RECLAIM_RATE := var_reclaim_rate;
		var_nonus_fund_loan_info.OVERSEAS_TAX_PERCENTAGE := var_overseas_tax;
		var_nonus_fund_loan_info.DOMESTIC_TAX_PERCENTAGE := var_domestic_tax;	
		var_nonus_fund_loan_info.COLLATERAL_CURRENCY_CD := var_coll_cd;
		var_nonus_fund_loan_info.COLL_TYPE := var_coll_type;			
		var_nonus_fund_loan_info.PREPAY_RATE := var_prepay_rate;
					
		RETURN var_nonus_fund_loan_info;
		
	END GET_NONUS_EX_LOAN_INFO;	
	
	FUNCTION GET_LOAN_RATE(p_borrow_request_type IN VARCHAR2, p_fund_cd IN VARCHAR2, p_trade_country_cd IN VARCHAR2, p_date IN NUMBER, p_error_code OUT VARCHAR2) RETURN NUMBER
	IS
		var_request_type GEC_BORROW_REQUEST.BORROW_REQUEST_TYPE%type;
		var_g1_booking_id GEC_G1_BOOKING.G1_BOOKING_ID%type;		
		var_rate_type GEC_G1_BOOKING.RATE_TYPE%type;
		var_rate GEC_G1_BOOKING.RATE%type;
		var_index_rate GEC_INDEX_RATE.INDEX_RATE%type;
		var_index_cd GEC_G1_BOOKING.INDEX_CD%type;
		
		CURSOR loan_rates IS
			SELECT gb.G1_BOOKING_ID, gb.RATE_TYPE, gb.RATE, gb.INDEX_CD                 
			FROM GEC_G1_BOOKING gb
			WHERE gb.FUND_CD = p_fund_cd AND
			  	gb.TRANSACTION_CD = 'G1L' AND
			  	gb.POS_TYPE = var_request_type;
			  	
		CURSOR loan_rates_nonus IS
				SELECT ga.RATE, ga.RATE_TYPE, ga.INDEX_CD
				FROM GEC_G1_RATE ga
				WHERE ga.G1_BOOKING_ID = var_g1_booking_id AND
					  ga.TRADE_COUNTRY_CD = p_trade_country_cd;
			
	BEGIN
		var_rate := NULL;
	--	GEC_LOG_PKG.LOG_PERFORMANCE_START('GET_LOAN_RATE');
		IF p_borrow_request_type = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB THEN
			var_request_type := p_borrow_request_type;
		ELSE
			var_request_type := GEC_CONSTANTS_PKG.C_BORROW_REQUEST_NSB;
		END IF;
		
		p_error_code := 'VLD0087';
		FOR l_r IN loan_rates
		LOOP
			var_g1_booking_id := l_r.G1_BOOKING_ID;
			var_rate := l_r.RATE;
			var_rate_type := l_r.RATE_TYPE;
			var_index_cd := l_r.INDEX_CD;
			
			FOR l_r_n IN loan_rates_nonus
			LOOP
				var_rate := l_r_n.RATE;
				var_rate_type := l_r_n.RATE_TYPE;
				var_index_cd := l_r_n.INDEX_CD;
				EXIT WHEN var_rate IS NOT NULL;				
			END LOOP;
			
			IF var_rate IS NOT NULL THEN
				p_error_code := NULL;
			END IF;
			
			IF var_rate_type = 'R' THEN
				var_index_rate := GET_INDEX_RATE(var_index_cd, GEC_UTILS_PKG.DATE_TO_NUMBER(SYSDATE));
				IF var_index_rate IS NULL THEN
					var_rate := NULL;
					p_error_code := 'VLD0097';
				ELSE
					var_rate := var_rate + var_index_rate;
				END IF;
			END IF;
			
			EXIT WHEN var_rate IS NOT NULL;
		END LOOP;
		
		RETURN var_rate;
		
	END GET_LOAN_RATE;
	
	FUNCTION GET_INDEX_RATE(p_index_cd IN VARCHAR2, p_date IN NUMBER) RETURN NUMBER
	IS
		var_index_rate GEC_INDEX_RATE.INDEX_RATE%type;
		CURSOR index_rates IS
			SELECT INDEX_RATE
			FROM GEC_INDEX_RATE
			WHERE INDEX_CD = p_index_cd AND INDEX_DATE = p_date;
	BEGIN
		var_index_rate := NULL;
		FOR i_r IN index_rates
		LOOP
			var_index_rate := i_r.INDEX_RATE;
			EXIT WHEN var_index_rate IS NOT NULL;
		END LOOP;
		
		RETURN var_index_rate;
	END GET_INDEX_RATE;
	
    FUNCTION GET_MAX_RATE_FOR_SAME_SHORT(p_imorder_id IN GEC_ALLOCATION.IM_ORDER_ID%TYPE
                                         ,P_IF_FORCE IN VARCHAR2
                                         ,P_FUND_CD IN GEC_FUND.FUND_CD%TYPE
                                         ,P_SETTLE_DATE IN GEC_ALLOCATION.SETTLE_DATE%TYPE
                                         ,P_REQUEST_TYPE IN GEC_BROKER.BORROW_REQUEST_TYPE%TYPE
                                         ,P_PREPAY_DATE IN GEC_ALLOCATION.PREPAY_DATE%TYPE) RETURN GEC_ALLOCATION.RATE%TYPE
    IS
        var_rate GEC_ALLOCATION.RATE%TYPE;
        var_unfilled_qty GEC_IM_ORDER.FILLED_QTY%TYPE;
    BEGIN
        SELECT (GIO.SHARE_QTY - GIO.FILLED_QTY) INTO var_unfilled_qty
        FROM GEC_IM_ORDER GIO
        WHERE GIO.IM_ORDER_ID = p_imorder_id;
        
        
        IF var_unfilled_qty = 0 THEN
            IF P_REQUEST_TYPE =GEC_CONSTANTS_PKG.C_SB THEN
                SELECT MAX (GA.RATE) INTO var_rate
	            FROM GEC_ALLOCATION GA
	            INNER JOIN GEC_BORROW GB
	                ON GB.BORROW_ID = GA.BORROW_ID
	            INNER JOIN GEC_BROKER BROKER
	                ON BROKER.BROKER_CD = GB.BROKER_CD AND BROKER.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_SB     
	            WHERE GA.IM_ORDER_ID = p_imorder_id 
	                  AND GA.STATUS='P'
	                  AND GA.SETTLE_DATE = P_SETTLE_DATE
	                  AND GA.PREPAY_DATE= P_PREPAY_DATE;
            ELSE
                SELECT MAX (GA.RATE) INTO var_rate
	            FROM GEC_ALLOCATION GA
	            INNER JOIN GEC_BORROW GB
	                ON GB.BORROW_ID = GA.BORROW_ID
	            INNER JOIN GEC_BROKER BROKER
	                ON BROKER.BROKER_CD = GB.BROKER_CD AND BROKER.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_SB     
	            WHERE GA.IM_ORDER_ID = p_imorder_id 
	                  AND GA.STATUS='P'
	                  AND GA.SETTLE_DATE = P_SETTLE_DATE
	                  AND GA.PREPAY_DATE= P_PREPAY_DATE;
            END IF;
       
        ELSE 
            IF P_REQUEST_TYPE =GEC_CONSTANTS_PKG.C_SB THEN
                SELECT MAX (GA.RATE) INTO var_rate
	            FROM GEC_ALLOCATION GA
	            INNER JOIN GEC_BORROW GB
	                ON GB.BORROW_ID = GA.BORROW_ID
	            INNER JOIN GEC_BROKER BROKER
	                ON BROKER.BROKER_CD = GB.BROKER_CD AND BROKER.BORROW_REQUEST_TYPE = GEC_CONSTANTS_PKG.C_SB     
	            WHERE GA.IM_ORDER_ID = p_imorder_id 
	                  AND GA.STATUS='P'
	                  AND GA.SETTLE_DATE = P_SETTLE_DATE
	                  AND GA.PREPAY_DATE= P_PREPAY_DATE;
            ELSE
                SELECT MAX (GA.RATE) INTO var_rate
	            FROM GEC_ALLOCATION GA
	            INNER JOIN GEC_BORROW GB
	                ON GB.BORROW_ID = GA.BORROW_ID
	            INNER JOIN GEC_BROKER BROKER
	                ON BROKER.BROKER_CD = GB.BROKER_CD AND BROKER.BORROW_REQUEST_TYPE <> GEC_CONSTANTS_PKG.C_SB     
	            WHERE GA.IM_ORDER_ID = p_imorder_id 
	                  AND GA.STATUS='P'
	                  AND GA.SETTLE_DATE = P_SETTLE_DATE
	                  AND GA.PREPAY_DATE= P_PREPAY_DATE;
            END IF;
           
        END IF;
        
        RETURN var_rate;
    EXCEPTION
         WHEN NO_DATA_FOUND THEN
             var_rate := 0;
             RETURN var_rate;
         WHEN OTHERS THEN
             var_rate := 0;
             RETURN var_rate;
    END GET_MAX_RATE_FOR_SAME_SHORT;
    
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
	          
--	          SELECT GB.US_COLLATERAL_PERCENTAGE INTO V_COLLATERAL_PERCENTAGE
--	          FROM GEC_FUND GF
--	          INNER JOIN GEC_IM_ORDER GIO
--	          ON GF.FUND_CD = GIO.FUND_CD  
--	          INNER JOIN GEC_BROKER GB
--	          ON GB.BROKER_CD = GF.DML_NSB_BROKER
--	          WHERE GIO.IM_ORDER_ID = P_GEC_IM_ORDER;
            
              SELECT GBV.US_COLLATERAL_PERCENTAGE  INTO V_COLLATERAL_PERCENTAGE
	          FROM GEC_FUND GF
	          INNER JOIN GEC_IM_ORDER GIO
	          ON GF.FUND_CD = GIO.FUND_CD  
	          INNER JOIN GEC_BROKER_VW GBV
	          ON GBV.DML_BROKER_CD = GF.DML_NSB_BROKER AND GBV.NON_CASH_AGENCY_FLAG='N'
	          WHERE GIO.IM_ORDER_ID = P_GEC_IM_ORDER;
	          -- TO DO CHANGE THE PRICE CALCULATION
	         IF V_ASSET_TYPE_ID = 4 THEN
	             V_PRICE := V_CLEAN_PRICE*V_COLLATERAL_PERCENTAGE;
	         ELSE
	             V_PRICE := (V_CLEAN_PRICE*V_COLLATERAL_PERCENTAGE) +(V_DIRTY_PRICE-V_CLEAN_PRICE);
	         END IF;
	         V_PRICE :=CEIL(V_PRICE/0.25)*0.25;
	         RETURN V_PRICE;
	      ELSE 
              RETURN 0;
	      END IF;
	  EXCEPTION 
	      WHEN NO_DATA_FOUND THEN
	          RETURN 0;
	  END CALCULATE_PRICE_BY_IM_ORDER_ID;
	  

	  
	  FUNCTION GENERATE_BORROW_LINK(p_borrow_request_type IN VARCHAR2, p_loan_number IN VARCHAR2, p_broker_code IN VARCHAR2, p_type IN VARCHAR2) RETURN GEC_LOAN.LINK_REFERENCE%TYPE
	  IS
	  BEGIN
	  		 RETURN CASE WHEN (p_borrow_request_type = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB OR p_borrow_request_type = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_NSB) AND  p_type = GEC_CONSTANTS_PKG.C_BORROW_AUTO_INPUT THEN p_loan_number
	  					ELSE p_broker_code||GEC_UTILS_PKG.GET_LOAN_NO_SEQ END;
	  END GENERATE_BORROW_LINK;
	  FUNCTION GENERATE_BORROW_LINK_REF RETURN GEC_LOAN.LINK_REFERENCE%TYPE
	  IS
	  		V_LINK_REFERENCE      GEC_LOAN.LINK_REFERENCE%TYPE;
	  BEGIN
	  		
	  		V_LINK_REFERENCE := to_char(sysdate,'yy')||GEC_UTILS_PKG.GET_LOAN_NO_SEQ;
	  		RETURN V_LINK_REFERENCE;
	  END GENERATE_BORROW_LINK_REF;
	  
	  FUNCTION GENERATE_LINK_REFERENCE( P_ALLOCATION_ID IN GEC_ALLOCATION.ALLOCATION_ID%TYPE) RETURN GEC_LOAN.LINK_REFERENCE%TYPE
	  IS
	      V_BROKER_CD           GEC_BORROW.BROKER_CD%TYPE;
	      V_LINK_REFERENCE      GEC_LOAN.LINK_REFERENCE%TYPE;
	  BEGIN
	      SELECT GB.BROKER_CD  INTO V_BROKER_CD
	      FROM GEC_ALLOCATION GA
	      INNER JOIN GEC_BORROW GB
	      ON GA.BORROW_ID = GB.BORROW_ID
	      WHERE GA.ALLOCATION_ID = P_ALLOCATION_ID;
	      
	      V_LINK_REFERENCE := V_BROKER_CD||GEC_UTILS_PKG.GET_LOAN_NO_SEQ;
	      RETURN V_LINK_REFERENCE;
	  EXCEPTION
	      WHEN NO_DATA_FOUND THEN
	          RETURN 'LINK_REF';
	  END GENERATE_LINK_REFERENCE;
	  
END GEC_ALLOCATION_PKG;
/
