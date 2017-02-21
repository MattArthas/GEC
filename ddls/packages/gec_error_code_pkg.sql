-------------------------------------------------------------------------
-- Copyright (c) 2009 State Street Bank and Trust Corp.
-- 225 Franklin Street, Boston, MA 02110, U.S.A.
-- All rights reserved.
--
-- "GEC_ERROR_CODE_PKG.sql is the copyrighted,
-- proprietary property of State Street Bank and Trust Company and its
-- subsidiaries and affiliates which retain all right, title and interest
-- therein."
--
-- Revision History
--
-- Date            Programmer                Notes
-- ------------    --------------------      ----------------------------
-- Apr  4, 2009    Zhao Hong                 initial
--
--
-------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE GEC_ERROR_CODE_PKG
AS

	--VBAccess: MsgBox "IM Request file trailer record is missing.", vbOKOnly + vbExclamation, "Please investigate"
	C_REQUEST_TRAILER_RECORD_MISS CONSTANT VARCHAR2(50) := 'PKG7000';

	--VBAccess: MsgBox "IM Request file discrepancy:" "&" vbCrLf "&" "Trailer count: " "&" intTrailer "&" _
	--        vbCrLf "&" "Record count: " "&" intCount, vbOKOnly + vbExclamation, "Please investigate"
	C_REQUEST_FILE_DISCREPANCY CONSTANT VARCHAR2(50) := 'PKG7001';
	
	--VBAccess: MsgBox("Prior Request loaded for IM. Continue?", vbYesNo + vbExclamation, "Prior file imported")
	--C_PRIOR_REQUEST_LOADED CONSTANT VARCHAR2(50) := 'PKG7002';
	
    --VBAccess: MsgBox "IM Request file was not import. Please check IM Request file.", vbOKOnly + vbExclamation, "File Error"
	C_REQUEST_FILE_ERROR_NO_DATA CONSTANT VARCHAR2(50) := 'PKG7003';


	--VBAccess: MsgBox "IM Order file trailer record is missing.", vbOKOnly + vbExclamation, "Please investigate"
	C_ORDER_TRAILER_RECORD_MISS CONSTANT VARCHAR2(50) := 'PKG7004';

	--VBAccess: MsgBox "IM Order file discrepancy:" "&" vbCrLf "&" "Trailer count: " "&" intTrailer "&" _
    --        vbCrLf "&" "Record count: " "&" intCount, vbOKOnly + vbExclamation, "Please investigate"
	C_ORDER_FILE_DISCREPANCY CONSTANT VARCHAR2(50) := 'PKG7005';
	
	--VBAccess: MsgBox("Prior Order loaded for IM. Continue?", vbYesNo + vbExclamation, "Prior file imported")
	C_PRIOR_ORDER_LOADED CONSTANT VARCHAR2(50) := 'PKG7006';
	
    --VBAccess: MsgBox "IM Orders file was not import. Please check IM Orders file.", vbOKOnly + vbExclamation, "File Error"
	C_ORDER_FILE_ERROR_NO_DATA CONSTANT VARCHAR2(50) := 'PKG7007';
	
	C_ORDER_IM_FUND_NOT_MATCHED CONSTANT VARCHAR2(50) := 'PKG7008';

	--**************************************************************************
	-- Error Codes which indicate the procedure of upload_im_request is failed 
	--**************************************************************************
	
	--File with Valid and Invalid IM (IM not exist in GEC)
	C_IM_NOT_EXIST CONSTANT VARCHAR2(50) := 'PKG7009';
	
	--Import valid file to Active/Inactive IM , who has no fund or Default-Fund 
	C_IM_WITHOUT_FUND CONSTANT VARCHAR2(50) := 'PKG7010';
	
	--Import valid file to Active/Inactive IM, who has fund and Default-Fund but without Strategy
	C_IM_WITHOUT_STRATEGY CONSTANT VARCHAR2(50) := 'PKG7011';  
	 
	--Import file to Active/Inactive IM (use FUND in file), who has fund and Default-Fund, has Strategy but fund not attached to Strategy
	C_IM_FUND_STRATEGY_NOT_MATCHED VARCHAR2(50) := 'PKG7012'; 
	
	--**************************************************************************
	--Error Code for PARIMIS API
	--**************************************************************************		
	--Duplicated (im_locate_id,im_request_id) in One Request
	C_API_DUPLICATED_LOCATE_ID VARCHAR2(50) := 'PKG7013'; 
	
	--Invalid request type for export trade blotter
	C_BORROW_REQUEST_INVALID_TYPE VARCHAR2(50) := 'PKG7014'; 
			
	--**************************************************************************
	--Error Code for File Automation
	--**************************************************************************				

	--Error Code 001: the fund in the locate request file requires a trailer record and the file does not have the trailer record.
	C_VLD_NO_TRAILER CONSTANT VARCHAR2(50) := 'VLD0001';
	
	--Error Code 002: the fund in the locate request file requires a trailer record and the record count in trailer is not correct.
	C_VLD_TRAILER_NOT_MATCHED CONSTANT VARCHAR2(50) := 'VLD0002'; 
	
	--Error Code 004: the Investment Manager and strategy contained in this f-ile do not match..
 	C_VLD_IM_STRATEGY_NOT_MATCHED CONSTANT VARCHAR2(50) := 'VLD0004';
 	
	--Error Code 005: the Investment Manager and fund contained in this file do not match.
	C_VLD_IM_FUND_NOT_MATCHED CONSTANT VARCHAR2(50) := 'VLD0005';

	--Error Code 006: the file contains an unrecognized Investment Manager.
	C_VLD_UNRECOGNIZED_IM CONSTANT VARCHAR2(50) := 'VLD0006';
		
	--Error Code 007: no fund has been setup for this Investment Manager.
	C_VLD_FUND_NOT_SETUP  CONSTANT VARCHAR2(50) := 'VLD0007';

	--Error Code 008: no strategy has been setup for this Investment Manager.
	C_VLD_STRATEGY_NOT_SETUP  CONSTANT VARCHAR2(50) := 'VLD0008';
	
	--Error Code 009: the strategy associated with this Investment Manager has not been assigned to a fund(s).
	C_VLD_STRATEGY_HAS_NO_FUND  CONSTANT VARCHAR2(50) := 'VLD0009';
	
	--Error Code 010: the transaction type in this file is invalid.
	C_VLD_INVALID_TRANSACTION_TYPE  CONSTANT VARCHAR2(50) := 'VLD0010';
	
	--Error Code 012: this file has a business date that is a non-working day (e.g., a holiday or a weekend).
	C_VLD_NON_WORKING_DAY  CONSTANT VARCHAR2(50) := 'VLD0012'; 

	--Error Code 032: The fund associated with this Investment Manager has not been assigned to a strategy.
	C_VLD_FUND_HAS_NO_STRATEGY  CONSTANT VARCHAR2(50) := 'VLD0032'; 
	
	--VLD0040: the Investment manager is inactive.
	C_VLD_INACTIVE_IM  CONSTANT VARCHAR2(50) := 'VLD0040'; 
	
	--VLD0040: the Investment manager is inactive.
	C_VLD_NO_STRATEGY_PROFILE  CONSTANT VARCHAR2(50) := 'VLD0044'; 
	
	--VLD0046:Strategy associated with the IM/Fund is inactive 
	C_VLD_INACTIVE_STRATEGY  CONSTANT VARCHAR2(50) := 'VLD0046';  
	
	------------------------Error Msg
	C_VLD_CD_PAST_DATE CONSTANT VARCHAR2(50) := 'VLD0047';
	C_VLD_MSG_PAST_DATE CONSTANT VARCHAR2(200) := 'VLD0047:Locate/Pre-borrow cannot be processed because Request date has gone past.';
	
	C_VLD_CD_NONWORKING_DAY CONSTANT VARCHAR2(50)  :='VLD0048';
	C_VLD_MSG_NONWORKING_DAY CONSTANT VARCHAR2(200)  :='VLD0048:Locate/Pre-borrow cannot be processed because Locate/Pre-borrow Request date is a non-trading day.';
	
	C_VLD_CD_AFTER_CUTOFF CONSTANT VARCHAR2(50)  :='VLD0049';
	C_VLD_MSG_AFTER_CUTOFF CONSTANT VARCHAR2(200)  :='VLD0049:Locate/Pre-borrow cannot be processed because Locate/Pre-borrow Request is received after the locate cut-off time for the trade country.';
	
	C_VLD_CD_EARLY_LOCATE CONSTANT VARCHAR2(50)  :='VLD0050';
	C_VLD_MSG_EARLY_LOCATE CONSTANT VARCHAR2(200)  :='VLD0050:Locate/Pre-borrow cannot be processed because Request Date is more than one day in future.';
	
	C_VLD_CD_NO_STRATEGY_PROFILE VARCHAR2(50) :='VLD0051';
	C_VLD_MSG_NO_STRATEGY_PROFILE VARCHAR2(200) := 'VLD0051:Trade Country does not exist or is inactive under Strategy Profile.';

	C_VLD_CD_NO_PREBORROW_COUNTRY VARCHAR2(50) :='VLD0052';
	C_VLD_MSG_NO_PREBORROW_COUNTRY VARCHAR2(200) := 'VLD0052:Non Pre-borrow market security.';
		
	C_VLD_CD_ASSET_INVALID VARCHAR2(50) :='VLD0053';
	C_VLD_MSG_ASSET_INVALID CONSTANT VARCHAR2(200) := 'VLD0053:Security not found.';

	C_VLD_CD_ASSET_MULTIPLE VARCHAR2(50) :='VLD0055';
	C_VLD_MSG_ASSET_MULTIPLE CONSTANT VARCHAR2(200) := 'VLD0055:Multiple securities are found.';
	
	C_VLD_CD_AFTER_MARKET_HOUR VARCHAR2(50) :='VLD0054';
	C_VLD_MSG_AFTER_MARKET_HOUR CONSTANT VARCHAR2(200) :='VLD0054:Located after market hours.';
	
	C_VLD_CD_DATE_NOT_WORKING_DAY CONSTANT VARCHAR2(50) :='VLD0084';
	
	--Undefined fund, please set up the fund and re-enter.
	C_VLD_CD_FUND_INVALID  CONSTANT VARCHAR2(50) :='VLD0111';
	--Fund is not assigned to a strategy or not to an inactive strategy.
	C_VLD_CD_FUND_STRATEGY_INVALID  CONSTANT VARCHAR2(50) :='VLD0112';
	--The strategy which Fund mapped to is not assigned to an IM.
	C_VLD_CD_FUND_IM_INVALID  CONSTANT VARCHAR2(50) :='VLD0113';
	--The input trade date is not a business date.
	C_VLD_CD_TRADE_DATE_INVALID  CONSTANT VARCHAR2(50) :='VLD0073';
	--The input settlement date is not a business date.
	C_VLD_CD_SETTLE_DATE_INVALID  CONSTANT VARCHAR2(50) :='VLD0072';
	--Corp Bond with quantity which is not multiples of 1000.
	C_VLD_CD_SHARE_QTY_INVALID  CONSTANT VARCHAR2(50) :='VLD0115';
	C_VLD_MSG_SHARE_QTY_INVALID CONSTANT VARCHAR2(200) := 'Corp Bond with quantity which is not multiples of 1000.';
	C_VLD_SETTLE_LOCATION_INVALID CONSTANT VARCHAR2(50) :='VLD0211';
	--BULK RETURN LENGTH GREATER THAN 6
	C_VLD_CPATY_LENGTH_INVALID CONSTANT VARCHAR2(50) :='VLD0221';
	--BULK RETURN IS BLANK AND TRANSACTION_TYPE IS NOT 'B'
	C_VLD_CPATY_BLANK_INVALID CONSTANT VARCHAR2(50) :='VLD0222';
	C_VLD_POSTING_TYPE_INVALID CONSTANT VARCHAR2(50) :='VLD0223';
END GEC_ERROR_CODE_PKG;
/
