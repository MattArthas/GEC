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
CREATE OR REPLACE PACKAGE GEC_FUTURE_LOCATE_PKG
AS
	PROCEDURE PROCESS_FUTURE_LOCATE( 	p_curr_date		    IN	DATE,
										p_transaction_cd  	IN  VARCHAR2,
										p_scheduleFile_cur 	OUT SYS_REFCURSOR );

END GEC_FUTURE_LOCATE_PKG;
/

CREATE OR REPLACE PACKAGE BODY GEC_FUTURE_LOCATE_PKG
AS
	
	PROCEDURE PROCESS_FUTURE_LOCATE( 	p_curr_date			IN	DATE,
										p_transaction_cd  	IN  VARCHAR2,
										p_scheduleFile_cur 	OUT SYS_REFCURSOR )
	IS
		v_curr_date gec_locate_preborrow.scheduled_at%type;
		v_request_id gec_locate_preborrow.request_id%type;
		V_PROCEDURE_NAME VARCHAR2(100) := 'GEC_FUTURE_LOCATE_PKG.PROCESS_FUTURE_LOCATE';
		V_SOURCE_CD gec_locate_preborrow.source_cd%type;
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
		
		v_curr_date := NVL(p_curr_date,sysdate);
		V_SOURCE_CD := gec_constants_pkg.C_ALL_FUTURE_LOCATE;
		--clear temp table 
		DELETE gec_locate_preborrow_temp;
		--Fill temp table
		INSERT INTO gec_locate_preborrow_temp(
		Locate_Preborrow_id, 	BUSINESS_DATE, 		INVESTMENT_MANAGER_CD, 	TRANSACTION_CD, 
		FUND_CD, 				Share_Qty, 			CUSIP, 					ISIN, 
		SEDOL, 					Ticker,				Description, 			SOURCE_CD, 
		Locate_id, 			Position_Flag, 			CLIENT_CD, 
		SB_BROKER, 				ASSET_CODE, 		ASSET_CODE_TYPE, 		STATUS,
	    comment_txt, 			quik, 				trade_country_cd, 		file_version, 
	    im_user_id ,			IM_DEFAULT_FUND_CD,	FUND_SOURCE,			IM_DEFAULT_CLIENT_CD,
	    STRATEGY_ID,			request_id,			im_request_id,			im_locate_id,
	    im_availability_id,		asset_id,			created_by,				created_at,
	    updated_by,				updated_at,			indicative_rate,		trader_approved_qty,
	    trader_request_qty,		row_number,			ASSET_TYPE_ID
		)
		SELECT 
		Locate_Preborrow_id, 	BUSINESS_DATE, 		INVESTMENT_MANAGER_CD, 	TRANSACTION_CD, 
		FUND_CD, 				(case when trader_approved_qty is not null then trader_approved_qty  else share_qty end) as Share_Qty,
		CUSIP, 					ISIN, 
		SEDOL, 					Ticker,				Description, 			SOURCE_CD, 
		Locate_id, 			Position_Flag, 			CLIENT_CD, 
		SB_BROKER, 				ASSET_CODE, 		ASSET_CODE_TYPE, 		'P' status,
	    null, 					quik, 				trade_country_cd, 		file_version, 
	    im_user_id ,			IM_DEFAULT_FUND_CD,	FUND_SOURCE,			IM_DEFAULT_CLIENT_CD,
	    STRATEGY_ID,			request_id,			im_request_id,			im_locate_id,
	    im_availability_id,		asset_id,			created_by,				created_at,
	    'SS Desk' updated_by,	SYSDATE updated_at,	indicative_rate,		trader_approved_qty,
	    share_qty as trader_request_qty, row_number,ASSET_TYPE_ID
 		FROM gec_locate_preborrow loc 
 		WHERE 
 			status = 'H'
 		AND scheduled_at <= v_curr_date
 		AND initial_flag = 'N'
 		AND TRANSACTION_CD = p_transaction_cd;
		
		delete gec_locate_preborrow loc
		where exists (
					select 1 
					from gec_locate_preborrow_temp temp
					where loc.Locate_Preborrow_id = temp.Locate_Preborrow_id
					);
		
		--Process LOCATES, return v_request_id
		gec_upload_pkg.process_locate(null, null, V_SOURCE_CD,v_curr_date,GEC_CONSTANTS_PKG.C_LOCATE_FUTURE_JOB,v_request_id);
		
		--ACCEPT LOCATES
		GEC_TRANSACTION_PKG.PROCESS_ACCEPT_LOCATES;
				
		--return scheduled st requests that will be processed in java
		OPEN p_scheduleFile_cur FOR 
		SELECT f.file_id, f.file_name, f.request_id,f.file_type, re.investment_manager_cd, f.file_source,f.scheduled_at
	   	FROM gec_file f, GEC_REQUEST re
	   	WHERE f.REQUEST_ID = re.REQUEST_ID
	   		AND f.FILE_TYPE = p_transaction_cd
	   		AND f.scheduled_at <= v_curr_date
		    AND f.status = 'P'
	   	ORDER BY f.file_name, f.file_id;
	
	GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	
	END PROCESS_FUTURE_LOCATE;
	 	
END GEC_FUTURE_LOCATE_PKG;
/
