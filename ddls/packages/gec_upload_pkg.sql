-------------------------------------------------------------------------
-- Copyright (c) 2009 State Street Bank and Trust Corp.
-- 225 Franklin Street, Boston, MA 02110, U.S.A.
-- All rights reserved.
--
-- "GEC_UPLOAD_PKG.sql is the copyrighted,
-- proprietary property of State Street Bank and Trust Company and its
-- subsidiaries and affiliates which retain all right, title and interest
-- therein."
--
-- Revision History
--
-- Date            Programmer                Notes
-- ------------    --------------------      ----------------------------
-- Apr  4, 2009    Zhao Hong                 initial
-- Apr 19, 2009    Zhao Hong                 Comment the 4 lines due to item 49 in URL: 
--											    http://collaborate/sites/GMT/gmsftprojects/omd/Lists/Requirements%20Questions/AllItems.aspx
-- Apr 28, 2009    jingzheng shang			 http://ajra03.statestr.com:8080/browse/OMD-284
-- Apr 30, 2009    Zhao Hong                 Fix GEC-28
-------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE GEC_UPLOAD_PKG
AS
	--Function: upload im request from excel file; or user inquiry a locate/preborrow from an availability.
	--p_checkTrailer 'Y':check 'N':no check
	--************************************************************************************                     
	-- Import Locate and preborrow
	-- Main Entry for locate and preborrow 
	-- calculate reserve quantities.
	--************************************************************************************	
	PROCEDURE UPLOAD_IM_REQUEST( p_uploadData        		IN GEC_IM_REQUEST_TP_ARRAY,
		                         p_uploadedBy        		IN VARCHAR2,
		                         p_checkTrailer 	 		IN VARCHAR2,
		                         p_transactionCd   			IN VARCHAR2,
		                         p_oper						IN VARCHAR2,
		                         p_errorCode         		OUT VARCHAR2,
		                         p_errorCount        		OUT NUMBER,
		                         p_requestId        		OUT NUMBER,
                                 p_locate_on_preborrow_cntry    OUT VARCHAR2);
	--************************************************************************************                     
	-- Core Calculation: 
	-- calculate reserve quantities.
	--************************************************************************************				                         
	PROCEDURE PROCESS_LOCATE(	p_uploadedBy        		IN VARCHAR2,
								p_transactionCd   			IN VARCHAR2,
								p_sourceCd					IN VARCHAR2,
								p_curr_date 				IN  DATE,
								p_oper						IN VARCHAR2,
								p_requestId					OUT NUMBER								
							);
	
	--************************************************************************************                     
	-- IDENTIFY SOURCE CD, TRANSACTION CD: 
	-- 
	--************************************************************************************		
	PROCEDURE IDENTIFY_LOCATE(	p_uploadData IN GEC_IM_REQUEST_TP_ARRAY,
								p_transactionCd OUT VARCHAR2,
								p_sourceCd  OUT VARCHAR2,
								p_errorCode	OUT VARCHAR2);
								
	--************************************************************************************                     
	-- Append comment Call Desk when approved quantity is zero.
	-- GEC-1437
	--************************************************************************************		
	PROCEDURE COMMENT_CALL_DESK;	
	
	PROCEDURE COMMENT_LIQUID;							
		
	--Function: upload im orders from excel file.
	PROCEDURE UPLOAD_IM_ORDER( p_uploadedBy        IN VARCHAR2,
		                         p_allowReUploadFlag IN VARCHAR2,
		                         p_errorCode         OUT VARCHAR2,
		                         p_errorCount        OUT NUMBER,
		                         p_trailerCount      OUT NUMBER,
		                         p_recordCount       OUT NUMBER,
		                         p_retOrders         OUT SYS_REFCURSOR,
		                         p_retSsgmLoanOrders OUT SYS_REFCURSOR,
		                         p_retLocatedIds	 OUT SYS_REFCURSOR,
		                         p_retNoMatchCancel	 OUT SYS_REFCURSOR,
		                         p_retMatchCoverSentG1 OUT SYS_REFCURSOR,
		                         p_retComment OUT SYS_REFCURSOR);
	PROCEDURE GET_SSGM_LOAN_FOR_ORDER( p_retSsgmLoanOrders OUT SYS_REFCURSOR );
	PROCEDURE OPEN_SSGM_LOAN_FOR_ORDER( p_retSsgmLoanOrders OUT SYS_REFCURSOR );
	PROCEDURE OPEN_NOMATCHCANCEL (p_retNoMatchCancel	 OUT SYS_REFCURSOR);
	PROCEDURE OPEN_MATCHCOVERSENTG1 (p_retMatchCoverSentG1	 OUT SYS_REFCURSOR);
	PROCEDURE GET_NOMATCHCANCEL (p_retNoMatchCancel	 OUT SYS_REFCURSOR);
	PROCEDURE GET_MATCHCOVERSENTG1 (p_retMatchCoverSentG1	 OUT SYS_REFCURSOR);
	PROCEDURE HANDLE_ORDER_CANCEL;
	PROCEDURE HANDLE_NO_DEMAND_BORROW;
	PROCEDURE FILL_ORDER_WITH_GC_RATE;
	PROCEDURE FILL_ORDERSB_WITH_GC_RATE;
	--Function: upload im availability from a FTP file. 
	--The asset will be set with source_flag 'F'tp-availability. And this procedure will insert asset_identifier table.
	PROCEDURE UPLOAD_IM_AVAILABILITY( p_uploadData IN GEC_IM_AVAILABILITY_TP_ARRAY,
									  p_uploadedBy IN VARCHAR2,
									  p_lastModifiedDate IN DATE,
									  p_availability_cnt OUT NUMBER);
	
	--Function: import external locate response from a file.
	PROCEDURE UPLOAD_EXT_LOCATE_RESPONSE( p_uploadData IN GEC_EXT_LOCATE_RESP_TP_ARRAY,
									  p_ext_type IN VARCHAR2,
									  p_uploadedBy IN VARCHAR2,
									  p_error_code OUT VARCHAR2,
									  p_returnedAvail_cursor OUT SYS_REFCURSOR);
	
	--Function: check if the request has been prior uploaded.
	--If it was uploaded, return 'Y'; else return 'N'
	FUNCTION IS_PRIOR_UPLOADED RETURN VARCHAR2;

	--Calculate reserved quantities in gec_locate_preborrow_temp
    PROCEDURE CALCULATE_QUANTITIES(p_oper IN VARCHAR2);
    
    --Return: the count of rows with status 'X'
    FUNCTION GET_ERROR_COUNT RETURN NUMBER;

	--validate the length of asset code.
	FUNCTION IS_VALID_ASSET_CODE(P_ASSET_CODE IN VARCHAR2,
	                             P_ASSET_CODE_TYPE IN VARCHAR2) RETURN VARCHAR2;

	--Update asset_id in gec_locate_preborrow_temp if the asset is found. Else, insert a new asset with source_flag 'R'equest-of-IM.
	--This procedure will not insert asset_identifier table.
	PROCEDURE FILL_ASSETS_FOR_NEW_ORDERS;

	PROCEDURE UPDATE_TEMP_REQUEST_BY_AVAIL;
	
	--FOR ORDER UPLOAD, INIT IN 1.4
	PROCEDURE UPDATE_TEMP_ORDER_BY_AVAIL;
	
	--Do some updates when no availablity but has asset		                               	
	PROCEDURE UPDATE_WHEN_NO_AVAILABILITY;
	--PROCEDURE UPDATE_TEMP_ORDER_NO_AVAIL;
			
	PROCEDURE UPDATE_INTERNAL_COMMENT;
	
	PROCEDURE UPDATE_REQUEST_AFTER_CUTOFF(p_curr_date IN DATE);
										
		
	PROCEDURE FILL_LOCATE_PREBORROW_TEMP ( 	p_uploadData		IN GEC_IM_REQUEST_TP_ARRAY,
											p_uploadedBy        IN VARCHAR2,
											p_sourceCd			IN VARCHAR2);	
	
	--PROCEDURE FILL_ORDER_PREBORROW_TEMP ;	
				
	--FILL SOME FIELDS FOR INLINE EDIT.	
	PROCEDURE FILL_INLINE_EDIT(p_uploadData        IN GEC_IM_REQUEST_TP_ARRAY);		
	
	--If request is from inlinedit, it return 'Y', else 'N'
	FUNCTION IS_INLINE_EDIT(p_uploadData        IN GEC_IM_REQUEST_TP_ARRAY) RETURN VARCHAR2;	
	
	--allocate AVAILABILITY for locate.
	PROCEDURE RESERVE_AVAILABILITY( p_avail_sb_qty 		IN OUT NUMBER ,
	  								p_avail_sb_qty_ral 	IN OUT NUMBER ,
	  								p_avail_nsb_qty 	IN OUT NUMBER ,
	                               	p_avail_nfs_qty 	IN OUT NUMBER ,
	                               	p_avail_ext2_qty 	IN OUT NUMBER ,
	                               	p_locate_sb_qty 	OUT NUMBER ,
	                               	p_locate_sb_qty_ral OUT NUMBER ,
	                               	p_locate_nsb_qty 	OUT NUMBER ,
	                               	p_locate_nfs_qty 	OUT NUMBER ,
	                               	p_locate_ext2_qty 	OUT NUMBER ,
	                               	p_share_qty 		IN  NUMBER );   
	                               										
	--TRADER LOCATE ENTRY 	                               					
	PROCEDURE UPLOAD_TRADER_LOCATE_ENTRY;	
	--ENTRY OF PROCESS LOCATES FROM API
	PROCEDURE UPLOAD_API_LOCATE( p_uploadData        IN GEC_IM_REQUEST_TP_ARRAY,
		                         p_uploadedBy        IN VARCHAR2,
		                         p_checkTrailer 	 IN VARCHAR2,
								 p_transactionCd 	 IN VARCHAR2,
		                         p_errorCode         OUT VARCHAR2,
		                         p_errorCount        OUT NUMBER);     
	--DELETE OLD API INITIAL LOCATES	                         
	PROCEDURE DELETE_API_LOCATE( p_uploadData        IN GEC_IM_REQUEST_TP_ARRAY,
		                         p_uploadedBy        IN VARCHAR2);       
	-- DELETE OLD INITIAL LOCATES	                         
	PROCEDURE DELETE_REQUEST( 	p_uploadData        IN GEC_IM_REQUEST_TP_ARRAY,
		                        p_uploadedBy        IN VARCHAR2,
		                        p_transactionCd     IN  VARCHAR2,
		                        p_sourceCd			IN  VARCHAR2);     

	--************************************************************************************                     
	-- VALIDATE LOCATE FROM FILE AUTOMATION
	--************************************************************************************		                        
	PROCEDURE VALIDATE_FA_LOCATE(p_uploadData        IN GEC_IM_REQUEST_TP_ARRAY,
								 p_uploadedBy        IN VARCHAR2,
								 p_checkTrailer 	 IN VARCHAR2,
		                         p_errorCode         OUT VARCHAR2,
								 p_scheduledTime_cur OUT    SYS_REFCURSOR 
								 );  
								 
	--************************************************************************************                     
	-- VALIDATE PREBORROW FROM FILE AUTOMATION
	--************************************************************************************		                        
	PROCEDURE VALIDATE_FA_PREBORROW(p_uploadData        IN GEC_IM_REQUEST_TP_ARRAY,
									p_uploadedBy        IN VARCHAR2,
									p_checkTrailer 	    IN VARCHAR2,
			                        p_errorCode         OUT VARCHAR2,
									p_scheduledTime_cur OUT    SYS_REFCURSOR 
									);    

	--************************************************************************************                     
	--	VALIDATE ORDER FROM FILE AUTOMATION
	--************************************************************************************
--	PROCEDURE VALIDATE_FA_ORDER(p_uploadData        IN GEC_IM_ORDER_TP_ARRAY,
--								 p_uploadedBy        IN VARCHAR2,
--								 p_checkTrailer 	 IN VARCHAR2,
--		                         p_errorCode         OUT VARCHAR2 );   
		                         
	PROCEDURE OPEN_NULL_SCHEDULE_CURSOR( p_retAvails OUT SYS_REFCURSOR );
	
	--GEC2.2 change
	PROCEDURE FILL_ORDER_WITH_P_SHARES_SD;	
											                         		                         	            		
END GEC_UPLOAD_PKG;
/

CREATE OR REPLACE PACKAGE BODY GEC_UPLOAD_PKG
AS
	FUNCTION IS_PRIOR_UPLOADED RETURN VARCHAR2
	IS
		v_ret VARCHAR2(1) := 'N';
	BEGIN
		BEGIN
			SELECT 'Y' INTO v_ret FROM DUAL
			WHERE EXISTS (
					SELECT 1
					  FROM GEC_LOCATE_PREBORROW lp, GEC_LOCATE_PREBORROW_TEMP lpt
					 WHERE lp.BUSINESS_DATE = lpt.BUSINESS_DATE 
					   AND lp.INVESTMENT_MANAGER_CD = lpt.INVESTMENT_MANAGER_CD
					   AND lp.TRANSACTION_CD = lpt.TRANSACTION_CD
					   AND lp.INITIAL_FLAG != 'Y');
		EXCEPTION WHEN NO_DATA_FOUND THEN
			v_ret := 'N';
		END;
		RETURN v_ret;
	END IS_PRIOR_UPLOADED;

	PROCEDURE UPLOAD_IM_REQUEST( p_uploadData        		IN GEC_IM_REQUEST_TP_ARRAY,
		                         p_uploadedBy        		IN VARCHAR2,
		                         p_checkTrailer 	 		IN VARCHAR2,
		                         p_transactionCd   			IN  VARCHAR2,
		                         p_oper						IN VARCHAR2,
		                         p_errorCode         		OUT VARCHAR2,
		                         p_errorCount        		OUT NUMBER,
		                         p_requestId        		OUT NUMBER,
                                 p_locate_on_preborrow_cntry    OUT VARCHAR2)
	IS
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_UPLOAD_PKG.UPLOAD_IM_REQUEST';
		v_uploadedAt gec_locate_preborrow.created_at%type;
		v_trailer_flag gec_fund.request_trailer%type;
		v_trailer_count NUMBER(10);
		v_row_count NUMBER(10);
		v_index NUMBER(10);
		v_curr_date DATE;
		v_transactionCd gec_locate_preborrow_temp.transaction_cd%type;
		v_sourceCd gec_locate_preborrow_temp.source_cd%type;			
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
		p_errorCount := 0;
		p_errorCode := null;
		v_index := 0;
		v_transactionCd :=NVL(p_transactionCd,GEC_CONSTANTS_PKG.C_LOCATE);
		
		select sysdate into v_curr_date from dual;
		
		--identify source and transaction
		IDENTIFY_LOCATE(p_uploadData,v_transactionCd,v_sourceCd,p_errorCode);
		if p_errorCode IS NOT NULL THEN
			RETURN;
		END IF;
		
		--clear legacy data which is upload (but not accepted) by the same user					
		DELETE_REQUEST( p_uploadData, p_uploadedBy, v_transactionCd,v_sourceCd);
		
		--insert data into GEC_LOCATE_PREBORROW_temp
		--qry_apnd_Locate_Preborrow_temp; qry_updt_request_error; qry_update_Locate_Preborrow_temp_CLIENT_CD; qry_updt_sb_broker_cd
		FILL_LOCATE_PREBORROW_TEMP ( p_uploadData, p_uploadedBy,v_sourceCd);
				
		gec_validation_pkg.VALIDATE_IM_REQUEST(	p_uploadData ,
												p_uploadedBy,
												p_checkTrailer,
												v_transactionCd,
						 						v_curr_date,	 
												p_errorCode); 
										 		
		IF ( p_errorCode IS NOT NULL ) THEN
			RETURN;
		ELSE
			IF (p_transactionCd = gec_constants_pkg.C_LOCATE) THEN
            	gec_validation_pkg.VALIDATE_COUNTRY_FOR_LOCATE(p_locate_on_preborrow_cntry);
            END IF;
		END IF;
		
		--PROCESS LOCATE, RESERVER AVAILS
		PROCESS_LOCATE(p_uploadedBy,v_transactionCd,v_sourceCd,v_curr_date,p_oper,p_requestId);
		
		--qry_select_Locate_Preborrow_errors
		p_errorCount := GET_ERROR_COUNT;
		
		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END UPLOAD_IM_REQUEST;
	

	PROCEDURE PROCESS_LOCATE(	p_uploadedBy        	IN 	VARCHAR2,
								p_transactionCd   		IN 	VARCHAR2,
								p_sourceCd				IN 	VARCHAR2,
								p_curr_date 			IN  DATE,
								p_oper					IN  VARCHAR2,
								p_requestId				OUT NUMBER		
								)
	IS 
		v_record_count NUMBER(38);
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_UPLOAD_PKG.PROCESS_LOCATE';
	BEGIN	
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
		--It will match request with availablity to update temp table set im_availablity_id...
		UPDATE_TEMP_REQUEST_BY_AVAIL;
		--Asset exists in security, but has no availablity
		UPDATE_WHEN_NO_AVAILABILITY;
		--UPDATE INTERNAL_COOMENT WHEN NO AVAILABLITY
		UPDATE_INTERNAL_COMMENT;
		-- Locate : date = next day, time = 3:00 
		-- schedule to process at 4:00, date -> today, approve = 0 , rate = 999 	
		UPDATE_REQUEST_AFTER_CUTOFF( p_curr_date );
	
		--It will calculate the reserved quantity for request
		CALCULATE_QUANTITIES(p_oper);
		
		--qry_updt_Locate_Preborrow_temp_shs_greater_error
		UPDATE GEC_LOCATE_PREBORROW_temp 
		SET GEC_LOCATE_PREBORROW_temp.STATUS = 
		        CASE WHEN Share_Qty > Reserved_SB_Qty+SB_Qty_RAL+Reserved_NSB_Qty+Reserved_NFS_Qty+Reserved_EXT2_Qty THEN 'E'
		             ELSE 'P'
		        END
		WHERE GEC_LOCATE_PREBORROW_temp.STATUS ='P';
		
		IF ( gec_constants_pkg.C_TRADER_ENTRY = p_sourceCD or gec_constants_pkg.C_ALL_FUTURE_LOCATE = p_sourceCD) THEN
			UPLOAD_TRADER_LOCATE_ENTRY;
		END IF;
		
		--Update Liquid Flag
		UPDATE GEC_locate_preborrow_temp glp 
			   SET glp.LIQUIDITY_FLAG = (SELECT ga.LIQUIDITY_FLAG FROM GEC_ASSET ga
	                                              WHERE glp.asset_id = ga.asset_id)
	    WHERE glp.asset_id IS NOT NULL AND exists (select 1 from GEC_ASSET ga WHERE glp.asset_id = ga.asset_id);	
		--ADD COMMENT CALL DESK
		COMMENT_CALL_DESK;
		COMMENT_LIQUID;

		--Generate request ID. BUT,GSAMC,SMAC,API,INLINE-EDIT ALREADY HAVE THESE REQUEST IDS.
		--AND the new request id need be returned to java
		IF p_sourceCd not in (GEC_CONSTANTS_PKG.C_FA_REQUEST,GEC_CONSTANTS_PKG.C_FA_SMAC_REQUEST,GEC_CONSTANTS_PKG.C_FA_GSMAC_REQUEST,
								GEC_CONSTANTS_PKG.C_ALL_INLINE_EDIT,GEC_CONSTANTS_PKG.C_API_LOCATE, gec_constants_pkg.C_ALL_FUTURE_LOCATE) THEN --TO-DO Check SOURCE CODE
			SELECT GEC_REQUEST_ID_SEQ.NEXTVAL INTO p_requestId FROM DUAL;
			
			SELECT COUNT(1) INTO v_record_count FROM GEC_LOCATE_PREBORROW_TEMP;
			
			INSERT INTO GEC_REQUEST(REQUEST_ID,LOCATE_COUNT,CREATED_AT,CREATED_BY)
			VALUES(p_requestId,v_record_count, SYSDATE, p_uploadedBy);
			
			UPDATE GEC_LOCATE_PREBORROW_TEMP
			SET REQUEST_ID = p_requestId
			WHERE REQUEST_ID IS NULL;					
		ELSE
			BEGIN
				SELECT REQUEST_ID INTO p_requestId 
				 FROM GEC_LOCATE_PREBORROW_TEMP
				WHERE ROWNUM = 1;
			 EXCEPTION WHEN NO_DATA_FOUND THEN
			 	--If no data found, return back without setting p_requestId.
				RETURN;
		 	 END;
		 
		END IF;
		
		--GEC MIS CHANGE
		--qry_updt_Locate_Preborrow_temp_comment
		UPDATE GEC_locate_preborrow_temp
		SET COMMENT_TXT = 'You located a security that requires a Preborrow. This Locate response is informational only. Please submit a Preborrow if you wish to borrow this security'||';'||COMMENT_TXT
		WHERE TRADE_COUNTRY_CD IN 
		(SELECT TRADE_COUNTRY_CD FROM GEC_TRADE_COUNTRY WHERE PREBORROW_ELIGIBLE_FLAG = 'Y')
		AND TRANSACTION_CD = 'LOCATE'
		AND RESERVED_SB_QTY + SB_QTY_RAL + RESERVED_NSB_QTY + RESERVED_NFS_QTY + RESERVED_EXT2_QTY >0;
		
		--insert data from GEC_LOCATE_PREBORROW_temp to GEC_LOCATE_PREBORROW with createdBy = p_uploadedBy and INITIAL_FLAG = 'Y'
		INSERT INTO GEC_LOCATE_PREBORROW ( Locate_Preborrow_Id, IM_AVAILABILITY_ID,
					BUSINESS_DATE, INVESTMENT_MANAGER_CD, TRANSACTION_CD, FUND_CD, 
					CLIENT_CD, Share_Qty, ASSET_ID, ASSET_CODE, ASSET_CODE_TYPE, 
					Reserved_SB_Qty, SB_Qty_RAL, Reserved_NSB_Qty, 
					SOURCE_CD, UPDATED_BY, STATUS, COMMENT_TXT, 
					SB_Rate, 
					NSB_Loan_No, NSB_Rate, Remaining_SFP, 
					Position_Flag, SB_Broker, UPDATED_AT, 
					RESTRICTION_CD, Reserved_NFS_Qty, NFS_Borrow_ID, 
					NFS_Rate, Reserved_EXT2_Qty, EXT2_Borrow_ID, 
					EXT2_Rate, 
					INITIAL_FLAG, CREATED_BY, CREATED_AT,
					CUSIP, ISIN, SEDOL, QUIK, TRADE_COUNTRY_CD,
                    TRADE_COUNTRY_ALIAS_CD,
					TICKER, DESCRIPTION, FILE_VERSION,im_user_id ,IM_DEFAULT_FUND_CD,FUND_SOURCE,
	    			IM_DEFAULT_CLIENT_CD,STRATEGY_ID,REQUEST_ID,IM_REQUEST_ID,IM_LOCATE_ID,SCHEDULED_AT,
	    			INDICATIVE_RATE,INTERNAL_COMMENT_TXT,AT_POINT_AVAIL_QTY,
	    			AGENCY_BORROW_RATE, RECLAIM_RATE, ROW_NUMBER, 
	    			trader_approved_qty,ASSET_TYPE_ID,LIQUIDITY_FLAG
	    			 )
			SELECT  locate_preborrow_id, IM_AVAILABILITY_ID, 
					BUSINESS_DATE, INVESTMENT_MANAGER_CD, TRANSACTION_CD, FUND_CD, 
					CLIENT_CD, Share_Qty, ASSET_ID, ASSET_CODE, ASSET_CODE_TYPE, 
					Reserved_SB_Qty, SB_Qty_RAL, Reserved_NSB_Qty, SOURCE_CD, 
					UPDATED_BY, STATUS, COMMENT_TXT,  
					SB_Rate, NSB_Loan_No, 
					NSB_Rate, Remaining_SFP, Position_Flag, 
					(CASE FUND_SOURCE WHEN 'S' THEN s_f.BROKERS ELSE SB_Broker END ) SB_Broker, updated_at, RESTRICTION_CD, 
					Reserved_NFS_Qty, NFS_Borrow_ID, NFS_Rate, 
					Reserved_EXT2_Qty, EXT2_Borrow_ID, EXT2_Rate, 
					'Y', CREATED_BY, CREATED_AT,
					CUSIP, ISIN, SEDOL, QUIK, TRADE_COUNTRY_CD,
                      (case when 
          length(glpt.TRADE_COUNTRY_ALIAS_CD)>3 then glpt.TRADE_COUNTRY_CD
                    when glpt.TRADE_COUNTRY_ALIAS_CD is null then glpt.TRADE_COUNTRY_CD
                     ELSE glpt.TRADE_COUNTRY_ALIAS_CD end) as TRADE_COUNTRY_ALIAS_CD,
					TICKER, DESCRIPTION, FILE_VERSION,im_user_id,IM_DEFAULT_FUND_CD,FUND_SOURCE,
					IM_DEFAULT_CLIENT_CD,glpt.STRATEGY_ID,REQUEST_ID,IM_REQUEST_ID,IM_LOCATE_ID,SCHEDULED_AT,
					INDICATIVE_RATE,INTERNAL_COMMENT_TXT,AT_POINT_AVAIL_QTY,
					AGENCY_BORROW_RATE, RECLAIM_RATE, NVL(ROW_NUMBER, rownum) as ROW_NUMBER, 
					trader_approved_qty,ASSET_TYPE_ID,LIQUIDITY_FLAG
			FROM GEC_LOCATE_PREBORROW_temp glpt
				 LEFT OUTER JOIN (SELECT temp.STRATEGY_ID,
				GEC_STRCAT_FNC(temp.DML_SB_BROKER) BROKERS FROM (select distinct s.STRATEGY_ID, f.DML_SB_BROKER from GEC_STRATEGY s,
				GEC_FUND f WHERE f.STRATEGY_ID = s.STRATEGY_ID) temp GROUP BY temp.STRATEGY_ID) s_f
				ON glpt.STRATEGY_ID = s_f.STRATEGY_ID;	
		
		
		
		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END PROCESS_LOCATE;

	PROCEDURE IDENTIFY_LOCATE(	p_uploadData IN GEC_IM_REQUEST_TP_ARRAY,
								p_transactionCd OUT VARCHAR2,
								p_sourceCd  OUT VARCHAR2,
								p_errorCode	OUT VARCHAR2)
	IS
	BEGIN
	
		BEGIN
			SELECT TRANSACTION_CD ,SOURCE_CD INTO p_transactionCd,p_sourceCd
			FROM TABLE ( CAST ( p_uploadData AS GEC_IM_REQUEST_TP_ARRAY) ) irt	    
		   WHERE 
		   		(irt.Transaction_cd IS NULL OR UPPER(irt.Transaction_cd) != GEC_CONSTANTS_PKG.C_TRAILER)
		   		AND ROWNUM=1;	 
		 EXCEPTION WHEN NO_DATA_FOUND THEN
				--It will not happen,since the java validation will popup error fist.
				RETURN;
		 END;
		 
		 IF ( IS_INLINE_EDIT(p_uploadData) = 'Y' ) THEN 		 	
		 	p_sourceCd := GEC_CONSTANTS_PKG.C_ALL_INLINE_EDIT;
		 	RETURN;
		 END IF;
		 
		 IF p_transactionCd IS NULL THEN
		 	p_errorCode := gec_error_code_pkg.C_VLD_INVALID_TRANSACTION_TYPE;
		 	RETURN;
		 END IF;
								
	END IDENTIFY_LOCATE;
	
	PROCEDURE COMMENT_CALL_DESK
	IS
	BEGIN
		--qry_updt_Locate_Preborrow_temp_comments
		UPDATE GEC_locate_preborrow_temp a 
		   SET COMMENT_TXT = GEC_UTILS_PKG.SUB_COMMENT( 				
				CASE  WHEN  NVL(Reserved_SB_Qty,0) + NVL(SB_Qty_RAL,0) + NVL(Reserved_NSB_Qty,0) + NVL(Reserved_NFS_Qty,0) + NVL(Reserved_EXT2_Qty,0) = 0
				      	THEN  trim('Call Desk;'||' '||COMMENT_TXT)
				      --WHEN	im_availability_id IS NULL AND ASSET_ID IS NOT NULL 
				      --	THEN  trim(COMMENT_TXT ||' '|| 'Call Desk') 
				      ELSE 	trim(COMMENT_TXT)
				 END				
					) 
		 where a.status <> 'H' 
		 	AND NVL(Reserved_SB_Qty,0) + NVL(SB_Qty_RAL,0) + NVL(Reserved_NSB_Qty,0) + NVL(Reserved_NFS_Qty,0) + NVL(Reserved_EXT2_Qty,0) = 0;	
	
	END COMMENT_CALL_DESK;
	
	PROCEDURE COMMENT_LIQUID
	IS
    V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_UPLOAD_PKG.COMMENT_LIQUID';
    v_temp_comment VARCHAR2(300) := '';
    CURSOR v_cur_updateLocates IS
      SELECT glpt.locate_preborrow_id,glpt.LIQUIDITY_FLAG,gf.INCLUDE_LIQUIDITY_STATEMENT,gf.LEGAL_ENTITY_CD
      FROM GEC_locate_preborrow_temp glpt
      JOIN gec_fund gf ON glpt.fund_cd = gf.fund_cd
      ORDER BY glpt.locate_preborrow_id;
	BEGIN 
	    GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
	    FOR v_item in v_cur_updateLocates
			LOOP
			  v_temp_comment := '';
			  IF v_item.LIQUIDITY_FLAG = 'YES' THEN
			  	v_temp_comment := GEC_CONSTANTS_PKG.C_LIQUIDITY_COMMENTS;
			  ELSIF v_item.LIQUIDITY_FLAG = 'NO' THEN
			  	v_temp_comment := GEC_CONSTANTS_PKG.C_ILLIQUIDITY_COMMENTS;
			  END IF;
			  IF v_item.LIQUIDITY_FLAG = 'YES' or v_item.LIQUIDITY_FLAG = 'NO' THEN
          IF v_item.LEGAL_ENTITY_CD = GEC_CONSTANTS_PKG.C_LEGAL_ENTITY_GMBH THEN
            v_temp_comment := v_temp_comment||GEC_CONSTANTS_PKG.C_GMBH_COMMENTS;
          ELSE
            v_temp_comment := v_temp_comment||GEC_CONSTANTS_PKG.C_SSBT_COMMENTS;
          END IF;
        END IF;
            
		      IF v_item.INCLUDE_LIQUIDITY_STATEMENT = 'Y' THEN
		           UPDATE GEC_locate_preborrow_temp 
		           SET COMMENT_TXT = GEC_UTILS_PKG.SUB_COMMENT( 				
		            CASE  WHEN  NVL(Reserved_SB_Qty,0) + NVL(SB_Qty_RAL,0) + NVL(Reserved_NSB_Qty,0) + NVL(Reserved_NFS_Qty,0) + NVL(Reserved_EXT2_Qty,0)>0
		                    THEN  trim(COMMENT_TXT||' '||v_temp_comment)
		                  ELSE 	trim(COMMENT_TXT)
		             END)
		             WHERE locate_preborrow_id = v_item.locate_preborrow_id;
		      END IF;
			END LOOP;
	    GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME, 'S', 'SUCCESS');
	END COMMENT_LIQUID;
	
	--Java code has set up values for columns asset_code and asset_code_type in GEC_IM_ORDER_TP_ARRAY.
	PROCEDURE UPLOAD_IM_AVAILABILITY( p_uploadData IN GEC_IM_AVAILABILITY_TP_ARRAY,
									  p_uploadedBy IN VARCHAR2,
									  p_lastModifiedDate IN DATE,
									  p_availability_cnt OUT NUMBER)
	IS
		V_ASSET_ROWID ROWID;
		V_ASSET GEC_ASSET%ROWTYPE;
		V_ASSET_ID GEC_ASSET.ASSET_ID%TYPE;
		V_FOUND_FLAG VARCHAR2(1) := 'N';
		V_lastModifiedDate DATE := NVL(p_lastModifiedDate,sysdate);

		CURSOR V_CUR_AVAIL IS 
			SELECT DISTINCT iat.CUSIP,iat.ISIN,iat.SEDOL,iat.TICKER,iat.DESCRIPTION
			  FROM TABLE ( cast ( p_uploadData as GEC_IM_AVAILABILITY_TP_ARRAY) ) iat;
		
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START('GEC_UPLOAD_PKG.UPLOAD_IM_AVAILABILITY');
		FOR V_AVAIL IN V_CUR_AVAIL
		LOOP
			IF V_AVAIL.CUSIP IS NOT NULL THEN
				BEGIN
					SELECT A.ROWID, A.ASSET_ID,A.CUSIP,A.ISIN,A.SEDOL,A.TICKER,A.DESCRIPTION
					  INTO V_ASSET_ROWID, V_ASSET.ASSET_ID,V_ASSET.CUSIP,V_ASSET.ISIN,V_ASSET.SEDOL,V_ASSET.TICKER,V_ASSET.DESCRIPTION
					  FROM GEC_ASSET_IDENTIFIER AI, GEC_ASSET A
					 WHERE AI.ASSET_CODE = V_AVAIL.CUSIP
					   AND AI.ASSET_ID = A.ASSET_ID;
					V_FOUND_FLAG := 'Y';
				EXCEPTION WHEN NO_DATA_FOUND THEN
					V_FOUND_FLAG := 'N';
				END;
			END IF;
			IF V_FOUND_FLAG = 'N' AND V_AVAIL.ISIN IS NOT NULL THEN
				BEGIN
					SELECT A.ROWID, A.ASSET_ID,A.CUSIP,A.ISIN,A.SEDOL,A.TICKER,A.DESCRIPTION
					  INTO V_ASSET_ROWID, V_ASSET.ASSET_ID,V_ASSET.CUSIP,V_ASSET.ISIN,V_ASSET.SEDOL,V_ASSET.TICKER,V_ASSET.DESCRIPTION
					  FROM GEC_ASSET_IDENTIFIER AI, GEC_ASSET A
					 WHERE AI.ASSET_CODE = V_AVAIL.ISIN
					   AND AI.ASSET_ID = A.ASSET_ID;
					V_FOUND_FLAG := 'Y';
				EXCEPTION WHEN NO_DATA_FOUND THEN
					V_FOUND_FLAG := 'N';
				END;
			END IF;
			IF V_FOUND_FLAG = 'N' AND V_AVAIL.SEDOL IS NOT NULL THEN
				BEGIN
					SELECT A.ROWID, A.ASSET_ID,A.CUSIP,A.ISIN,A.SEDOL,A.TICKER,A.DESCRIPTION
					  INTO V_ASSET_ROWID, V_ASSET.ASSET_ID,V_ASSET.CUSIP,V_ASSET.ISIN,V_ASSET.SEDOL,V_ASSET.TICKER,V_ASSET.DESCRIPTION
					  FROM GEC_ASSET_IDENTIFIER AI, GEC_ASSET A
					 WHERE AI.ASSET_CODE = V_AVAIL.SEDOL
					   AND AI.ASSET_ID = A.ASSET_ID;
					V_FOUND_FLAG := 'Y';
				EXCEPTION WHEN NO_DATA_FOUND THEN
					V_FOUND_FLAG := 'N';
				END;
			END IF;
			
			--Fill null columns in table GEC_ASSET if the asset already exist.
			IF V_FOUND_FLAG = 'Y' THEN
				UPDATE GEC_ASSET
				   SET CUSIP = NVL(DECODE(IS_VALID_ASSET_CODE(V_AVAIL.CUSIP, GEC_CONSTANTS_PKG.C_CSP), 'Y', V_AVAIL.CUSIP, null) , CUSIP),
				       ISIN = NVL(DECODE(IS_VALID_ASSET_CODE(V_AVAIL.ISIN, GEC_CONSTANTS_PKG.C_ISN), 'Y', V_AVAIL.ISIN, null) ,ISIN),
				       SEDOL = NVL(DECODE(IS_VALID_ASSET_CODE(V_AVAIL.SEDOL, GEC_CONSTANTS_PKG.C_SED), 'Y', V_AVAIL.SEDOL, null),SEDOL),
				       TICKER = NVL(V_AVAIL.TICKER,TICKER),
				       DESCRIPTION = NVL(V_AVAIL.DESCRIPTION, DESCRIPTION),
				       SOURCE_FLAG = GEC_CONSTANTS_PKG.C_SOURCE_FLAG_FTP_AVAIL
				 WHERE ROWID = V_ASSET_ROWID
				   AND (  ( IS_VALID_ASSET_CODE(V_AVAIL.CUSIP, GEC_CONSTANTS_PKG.C_CSP) = 'Y' AND (CUSIP IS NULL OR CUSIP != V_AVAIL.CUSIP) )
				       OR ( IS_VALID_ASSET_CODE(V_AVAIL.ISIN, GEC_CONSTANTS_PKG.C_ISN) = 'Y' AND (ISIN IS NULL OR ISIN != V_AVAIL.ISIN) ) 
				       OR ( IS_VALID_ASSET_CODE(V_AVAIL.SEDOL, GEC_CONSTANTS_PKG.C_SED) = 'Y' AND (SEDOL IS NULL OR SEDOL != V_AVAIL.SEDOL) ) 
				       OR ( V_AVAIL.TICKER IS NOT NULL AND (TICKER IS NULL OR TICKER != V_AVAIL.TICKER) ) 
				       OR ( V_AVAIL.DESCRIPTION IS NOT NULL AND (DESCRIPTION IS NULL OR DESCRIPTION != V_AVAIL.DESCRIPTION) ) 
				       );
								
				--Add loopup data into gec_asset_identifier table
				IF V_ASSET.CUSIP IS NULL AND IS_VALID_ASSET_CODE(V_AVAIL.CUSIP, GEC_CONSTANTS_PKG.C_CSP) = 'Y' THEN
					INSERT INTO GEC_ASSET_IDENTIFIER(ASSET_CODE, ASSET_CODE_TYPE, ASSET_ID)
						VALUES(V_AVAIL.CUSIP, GEC_CONSTANTS_PKG.C_CSP, V_ASSET.ASSET_ID);
				END IF;
				IF V_ASSET.ISIN IS NULL AND IS_VALID_ASSET_CODE(V_AVAIL.ISIN, GEC_CONSTANTS_PKG.C_ISN) = 'Y' THEN
					INSERT INTO GEC_ASSET_IDENTIFIER(ASSET_CODE, ASSET_CODE_TYPE, ASSET_ID)
						VALUES(V_AVAIL.ISIN, GEC_CONSTANTS_PKG.C_ISN, V_ASSET.ASSET_ID);
				END IF;
				IF V_ASSET.SEDOL IS NULL AND IS_VALID_ASSET_CODE(V_AVAIL.SEDOL, GEC_CONSTANTS_PKG.C_SED) = 'Y' THEN
					INSERT INTO GEC_ASSET_IDENTIFIER(ASSET_CODE, ASSET_CODE_TYPE, ASSET_ID)
						VALUES(V_AVAIL.SEDOL, GEC_CONSTANTS_PKG.C_SED, V_ASSET.ASSET_ID);
				END IF;

			ELSE
				--Insert asset info when the asset is not found in table gec_asset
				SELECT GEC_ASSET_ID_SEQ.NEXTVAL INTO V_ASSET_ID FROM DUAL;
				INSERT INTO GEC_ASSET(ASSET_ID,CUSIP,ISIN,SEDOL,TICKER,DESCRIPTION,SOURCE_FLAG)
					VALUES(V_ASSET_ID,V_AVAIL.CUSIP,V_AVAIL.ISIN,V_AVAIL.SEDOL,V_AVAIL.TICKER,V_AVAIL.DESCRIPTION, GEC_CONSTANTS_PKG.C_SOURCE_FLAG_FTP_AVAIL);
				IF V_AVAIL.CUSIP IS NOT NULL AND IS_VALID_ASSET_CODE(V_AVAIL.CUSIP, GEC_CONSTANTS_PKG.C_CSP) = 'Y' THEN
					INSERT INTO GEC_ASSET_IDENTIFIER(ASSET_CODE, ASSET_CODE_TYPE, ASSET_ID)
						VALUES(V_AVAIL.CUSIP, GEC_CONSTANTS_PKG.C_CSP, V_ASSET_ID);
				END IF;
				IF V_AVAIL.ISIN IS NOT NULL AND IS_VALID_ASSET_CODE(V_AVAIL.ISIN, GEC_CONSTANTS_PKG.C_ISN) = 'Y' THEN
					INSERT INTO GEC_ASSET_IDENTIFIER(ASSET_CODE, ASSET_CODE_TYPE, ASSET_ID)
						VALUES(V_AVAIL.ISIN, GEC_CONSTANTS_PKG.C_ISN, V_ASSET_ID);
				END IF;
				IF V_AVAIL.SEDOL IS NOT NULL AND IS_VALID_ASSET_CODE(V_AVAIL.SEDOL, GEC_CONSTANTS_PKG.C_SED) = 'Y' THEN
					INSERT INTO GEC_ASSET_IDENTIFIER(ASSET_CODE, ASSET_CODE_TYPE, ASSET_ID)
						VALUES(V_AVAIL.SEDOL, GEC_CONSTANTS_PKG.C_SED, V_ASSET_ID);
				END IF;			
			END IF;

		END LOOP;
		
		INSERT INTO GEC_IM_AVAILABILITY(
						IM_AVAILABILITY_ID,
						ASSET_ID,
						BUSINESS_DATE,
						CLIENT_CD,
						INVESTMENT_MANAGER_CD,
						ASSET_CODE,
						ASSET_CODE_TYPE,
						POSITION_FLAG,
						RESTRICTION_CD,
						NSB_QTY,
						NSB_RATE,
						SB_QTY,
						SB_QTY_RAL,
						SB_RATE,
						NFS_QTY,
						NFS_RATE,
						EXT2_QTY,
						EXT2_RATE,
						SB_QTY_SOD,
						NSB_QTY_SOD,
						SB_QTY_RAL_SOD,
						NFS_QTY_SOD,
						EXT2_QTY_SOD,
						SOURCE_CD,
						CREATED_BY,
						CREATED_AT)
			SELECT GEC_IM_AVAILABILITY_ID_SEQ.nextval, ai.asset_id, iat.BUSINESS_DATE,iat.CLIENT_CD,iat.INVESTMENT_MANAGER_CD,
					iat.ASSET_CODE,iat.ASSET_CODE_TYPE,iat.POSITION_FLAG,iat.RESTRICTION_CD,NVL(iat.NSB_QTY,0),
					NVL(iat.NSB_RATE,0),NVL(iat.SB_QTY,0),NVL(iat.SB_QTY_RAL,0),NVL(iat.SB_RATE,0),NVL(iat.NFS_QTY,0),
					NVL(iat.NFS_RATE,0),NVL(iat.EXT2_QTY,0),NVL(iat.EXT2_RATE,0),NVL(iat.SB_QTY_SOD,0),NVL(iat.NSB_QTY_SOD,0),
					NVL(iat.SB_QTY_RAL_SOD,0),NVL(iat.NFS_QTY_SOD,0),NVL(iat.EXT2_QTY_SOD,0),iat.SOURCE_CD,p_uploadedBy,
					V_lastModifiedDate
			FROM TABLE ( cast ( p_uploadData as GEC_IM_AVAILABILITY_TP_ARRAY) ) iat
			  	INNER JOIN GEC_ASSET_IDENTIFIER ai
		 	 		ON ai.asset_code = iat.asset_code		  
		 	 	INNER JOIN GEC_FUND 
		  			ON iat.CLIENT_CD = GEC_FUND.CLIENT_CD 
		  		INNER JOIN GEC_CLIENT gc
		  			ON gc.client_status = 'A' AND gc.CLIENT_SHORT_NAME = iat.INVESTMENT_MANAGER_CD	
				INNER JOIN GEC_STRATEGY strategy
					ON strategy.IM_DEFAULT_FUND_CD = GEC_FUND.FUND_CD AND strategy.client_id = gc.client_id AND strategy.status='A'
				INNER JOIN GEC_RESTRICTION r
				        ON iat.RESTRICTION_CD = r.RESTRICTION_CD;
			
			SELECT count(1) INTO p_availability_cnt
			  FROM GEC_IM_AVAILABILITY avail, GEC_RESTRICTION res,
		        	TABLE ( cast ( p_uploadData as GEC_IM_AVAILABILITY_TP_ARRAY) ) iat
		        WHERE avail.BUSINESS_DATE = iat.BUSINESS_DATE 
		        	AND iat.ASSET_CODE = avail.ASSET_CODE
		        	AND iat.CLIENT_CD = avail.CLIENT_CD
		        	AND iat.INVESTMENT_MANAGER_CD = avail.INVESTMENT_MANAGER_CD
		        	AND avail.RESTRICTION_CD = res.RESTRICTION_CD;
	                		        		 
		GEC_LOG_PKG.LOG_PERFORMANCE_END('GEC_UPLOAD_PKG.UPLOAD_IM_AVAILABILITY');
	END UPLOAD_IM_AVAILABILITY;

	---------upload response in Availability---------
	PROCEDURE UPLOAD_EXT_LOCATE_RESPONSE( p_uploadData IN GEC_EXT_LOCATE_RESP_TP_ARRAY,
									  p_ext_type IN VARCHAR2,
									  p_uploadedBy IN VARCHAR2,
									  p_error_code OUT VARCHAR2,
									  p_returnedAvail_cursor OUT SYS_REFCURSOR)
	IS
		V_FOUND_FLAG VARCHAR2(1) := 'N';
		V_INSERT_AVAILABILITY_ARRAY GEC_IM_AVAILABILITY_TP_ARRAY := GEC_IM_AVAILABILITY_TP_ARRAY();
		V_NEW_AVAILABILITY GEC_IM_AVAILABILITY_TP;
		V_ASSET_CODE GEC_ASSET_IDENTIFIER.ASSET_CODE%TYPE;
		V_ASSET_CODE_TYPE GEC_ASSET_IDENTIFIER.ASSET_CODE_TYPE%TYPE;
		V_INDEX_INSERT INT := 1;
		V_INDEX_UPLOADDATA INT := 0;
		V_AVAIL_ROWID ROWID;
		V_RESPONSE GEC_EXT_LOCATE_RESP_TP;
		V_NFS_QTY GEC_IM_AVAILABILITY.NFS_QTY%TYPE;
		V_NFS_RATE GEC_IM_AVAILABILITY.NFS_RATE%TYPE;
		V_EXT2_QTY GEC_IM_AVAILABILITY.EXT2_QTY%TYPE;
		V_EXT2_RATE GEC_IM_AVAILABILITY.EXT2_RATE%TYPE;
		V_INVESTMANAGER GEC_FUND.INVESTMENT_MANAGER_CD%TYPE;
		V_CLIENT GEC_FUND.CLIENT_CD%TYPE;
		V_IS_CONTINUE VARCHAR2(1) := 'Y';
		V_AVAILABILITY_CNT NUMBER(20);
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_UPLOAD_PKG.UPLOAD_EXT_LOCATE_RESPONSE';
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
		FOR V_INDEX_UPLOADDATA IN 1 .. p_uploadData.count
		LOOP
        	V_RESPONSE := p_uploadData(V_INDEX_UPLOADDATA);
            
            BEGIN
                SELECT 
              	  GEC_FUND.CLIENT_CD, GEC_FUND.INVESTMENT_MANAGER_CD
            	INTO V_CLIENT,  V_INVESTMANAGER
           		FROM GEC_FUND
            	WHERE GEC_FUND.FUND_CD = (SUBSTR(V_RESPONSE.REFID,6,2)|| SUBSTR(V_RESPONSE.REFID,10,2));
                
                V_IS_CONTINUE := 'Y';
            EXCEPTION WHEN NO_DATA_FOUND THEN
                V_IS_CONTINUE := 'N';    
                p_error_code := 'some fund is not found.';
            END;     
              
            IF V_IS_CONTINUE = 'Y' THEN            
            	IF p_ext_type = 'NFS'  THEN  
	                V_NFS_QTY := V_RESPONSE.APPROVED_QTY;
	                V_NFS_RATE := V_RESPONSE.FEE;
	                V_EXT2_QTY := 0;
	                V_EXT2_RATE := 0;
                ELSE
	                V_NFS_QTY := 0;
	                V_NFS_RATE := 0;
	                V_EXT2_QTY := V_RESPONSE.APPROVED_QTY;
	                V_EXT2_RATE := V_RESPONSE.FEE;
                END IF;
                
                IF V_RESPONSE.CUSIP IS NOT NULL THEN
                    BEGIN
                        SELECT AVAIL.ROWID INTO V_AVAIL_ROWID
                      	FROM GEC_IM_AVAILABILITY AVAIL, GEC_ASSET_IDENTIFIER A
                      	WHERE A.ASSET_CODE = V_RESPONSE.CUSIP
                        	 AND AVAIL.ASSET_ID = A.ASSET_ID 
                        	 AND V_RESPONSE.BUSINESS_DATE = AVAIL.BUSINESS_DATE
                        	 AND V_CLIENT = AVAIL.CLIENT_CD
                        	 AND V_INVESTMANAGER = AVAIL.INVESTMENT_MANAGER_CD;
                        	 
                     	 V_FOUND_FLAG := 'Y';                       	 
                    EXCEPTION WHEN NO_DATA_FOUND THEN
                      	 V_FOUND_FLAG := 'N';
                    END;       
                END IF;
                IF V_FOUND_FLAG = 'N' AND V_RESPONSE.ISIN IS NOT NULL THEN
                     BEGIN
                        SELECT AVAIL.ROWID INTO V_AVAIL_ROWID
                        FROM GEC_IM_AVAILABILITY AVAIL, GEC_ASSET_IDENTIFIER A
                        WHERE A.ASSET_CODE = V_RESPONSE.ISIN
                            AND AVAIL.ASSET_ID = A.ASSET_ID 
                            AND V_RESPONSE.BUSINESS_DATE = AVAIL.BUSINESS_DATE
                            AND V_CLIENT = AVAIL.CLIENT_CD
                        	AND V_INVESTMANAGER = AVAIL.INVESTMENT_MANAGER_CD;
                        V_FOUND_FLAG := 'Y';     
                     EXCEPTION WHEN NO_DATA_FOUND THEN
                         V_FOUND_FLAG := 'N';
                     END;  
                END IF;
                IF V_FOUND_FLAG = 'N' AND V_RESPONSE.SEDOL IS NOT NULL THEN
					BEGIN
                     	 SELECT AVAIL.ROWID INTO V_AVAIL_ROWID
                    	  FROM GEC_IM_AVAILABILITY AVAIL, GEC_ASSET_IDENTIFIER A
                    	  WHERE A.ASSET_CODE = V_RESPONSE.SEDOL
                     	    	AND AVAIL.ASSET_ID = A.ASSET_ID 
                      	    	AND V_RESPONSE.BUSINESS_DATE = AVAIL.BUSINESS_DATE
                      	   		AND V_CLIENT = AVAIL.CLIENT_CD
                        	 	AND V_INVESTMANAGER = AVAIL.INVESTMENT_MANAGER_CD;
                    	  V_FOUND_FLAG := 'Y';     
					EXCEPTION WHEN NO_DATA_FOUND THEN
                          V_FOUND_FLAG := 'N';
                    END;  
                END IF;
            
                --Fill null columns in table GEC_ASSET if the asset already exist.
                IF V_FOUND_FLAG = 'Y' THEN  
                    IF p_ext_type = 'NFS'  THEN
                        UPDATE GEC_IM_AVAILABILITY 
                        	SET NFS_QTY = V_NFS_QTY, 
                        		NFS_RATE = V_NFS_RATE
                     	WHERE ROWID = V_AVAIL_ROWID;
                   ELSE
                     	UPDATE GEC_IM_AVAILABILITY 
                    	 SET EXT2_QTY = V_EXT2_QTY,
                         	EXT2_RATE = V_EXT2_RATE
                    	 WHERE ROWID = V_AVAIL_ROWID;
                   END IF;
                ELSE
                	--availability is not found, then prepare to insert a new availability
                	IF V_RESPONSE.CUSIP IS NOT NULL THEN
	                    V_ASSET_CODE := V_RESPONSE.CUSIP;
	                    V_ASSET_CODE_TYPE := GEC_CONSTANTS_PKG.C_CSP;    
                	ELSIF V_RESPONSE.ISIN IS NOT NULL THEN
	                    V_ASSET_CODE := V_RESPONSE.ISIN;
	                    V_ASSET_CODE_TYPE := GEC_CONSTANTS_PKG.C_ISN;    
                	ELSE 
	                    V_ASSET_CODE := V_RESPONSE.SEDOL;
	                    V_ASSET_CODE_TYPE := GEC_CONSTANTS_PKG.C_SED;    
                	END IF;
                    V_NEW_AVAILABILITY := GEC_IM_AVAILABILITY_TP( 
	                       V_RESPONSE.BUSINESS_DATE,
	                       V_CLIENT,
	                       V_INVESTMANAGER,
	                       V_ASSET_CODE,
	                       V_ASSET_CODE_TYPE,
	                       GEC_CONSTANTS_PKG.C_GC,
	                       '0',
	                       0,
	                       0,
	                       0,
	                       0,
	                       0,
	                       V_NFS_QTY,
	                       V_NFS_RATE,
	                       V_EXT2_QTY,
	                       V_EXT2_RATE,
	                       0,
	                       0,
	                       0,
	                       0,
	                       0,
	                       GEC_CONSTANTS_PKG.C_SYSTEM,
	                       V_RESPONSE.CUSIP,
	                       V_RESPONSE.ISIN,
	                       V_RESPONSE.SEDOL,
	                       V_RESPONSE.TICKER,
	                       '');
                    V_INSERT_AVAILABILITY_ARRAY.extend;                        
                    V_INSERT_AVAILABILITY_ARRAY(V_INDEX_INSERT) := V_NEW_AVAILABILITY;
                	V_INDEX_INSERT := V_INDEX_INSERT + 1;
                END IF;
        	END IF;  
		END LOOP;	
                
        IF V_INSERT_AVAILABILITY_ARRAY.count <> 0 THEN
        	UPLOAD_IM_AVAILABILITY(V_INSERT_AVAILABILITY_ARRAY, p_uploadedBy, null, V_AVAILABILITY_CNT);
        END IF;
        
        OPEN p_returnedAvail_cursor FOR
				SELECT avail.BUSINESS_DATE,avail.INVESTMENT_MANAGER_CD,avail.CLIENT_CD,iat.CUSIP,asset.SEDOL,
						asset.ISIN,asset.TICKER,asset.DESCRIPTION,avail.POSITION_FLAG,avail.RESTRICTION_CD,
						avail.NSB_QTY,avail.NSB_RATE,avail.SB_QTY,avail.SB_QTY_RAL,avail.SB_RATE,
						avail.NFS_QTY,avail.NFS_RATE,avail.EXT2_QTY,avail.EXT2_RATE,avail.SB_QTY_SOD,
						avail.NSB_QTY_SOD,avail.SB_QTY_RAL_SOD,avail.NFS_QTY_SOD,avail.EXT2_QTY_SOD,avail.CREATED_AT,
						avail.SOURCE_CD,avail.IM_AVAILABILITY_ID,avail.asset_id,
				      	res.RESTRICTION_ABBRV,avail.INDICATIVE_RATE, '' strategyName, '' tradingDesk,
				      	'' quik,DECODE(asset.LIQUIDITY_FLAG,
							      		GEC_CONSTANTS_PKG.C_LIQUID_DB,
						   		   		GEC_CONSTANTS_PKG.C_LIQUID,
						  		   		GEC_CONSTANTS_PKG.C_ILLIQUID_DB,
						  		   		GEC_CONSTANTS_PKG.C_ILLIQUID,
						  		   		null) as LIQUIDITY_FLAG
				FROM
		        	GEC_IM_AVAILABILITY avail, GEC_RESTRICTION res,
		        	GEC_FUND fund, GEC_ASSET asset, 
		        	TABLE ( cast ( p_uploadData as GEC_EXT_LOCATE_RESP_TP_ARRAY) ) iat
		        WHERE fund.FUND_CD = (SUBSTR(iat.REFID,6,2)|| SUBSTR(iat.REFID,10,2))
		        	AND avail.BUSINESS_DATE = iat.BUSINESS_DATE 
		        	AND fund.CLIENT_CD = avail.CLIENT_CD
		        	AND fund.INVESTMENT_MANAGER_CD = avail.INVESTMENT_MANAGER_CD
		        	AND ((iat.CUSIP IS NOT NULL AND asset.CUSIP = iat.CUSIP) 
		        			OR (iat.ISIN IS NOT NULL AND asset.ISIN = iat.ISIN)
		        			OR (iat.SEDOL IS NOT NULL AND asset.SEDOL = iat.SEDOL))
		        	AND avail.ASSET_ID = asset.ASSET_ID
		        	AND avail.RESTRICTION_CD = res.RESTRICTION_CD
	            ORDER BY 
	                avail.INVESTMENT_MANAGER_CD, 
	                avail.CLIENT_CD, 
	                asset.CUSIP;
        
		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END UPLOAD_EXT_LOCATE_RESPONSE;	
	
	PROCEDURE CALCULATE_QUANTITIES(p_oper IN VARCHAR2)
	IS
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_UPLOAD_PKG.CALCULATE_QUANTITIES';
		--Reason for the order by statement: item 9 in http://collaborate/sites/GMT/gmsftprojects/gec/Lists/Requirements%20Questions/AllItems.aspx
		--Content:
		--   Locate and Pre-borrow are both IM (investment manger) locate inquiries.  
		--   However the Pre-borrow is a firmer inquiry, which is followed by an order trade later. 
		--   When GEC processes locate file, it sources or reserves IM availability for Per-borrow first followed by Locate. 

		CURSOR v_cur_lpt is
			select lpt.rowid lpt_rowid, lpt.Share_Qty, 
				avail.IM_AVAILABILITY_ID, avail.POSITION_FLAG as POSITION_FLAG, avail.RESTRICTION_CD,
				avail.NSB_QTY, avail.NSB_RATE, avail.SB_QTY, avail.SB_QTY_RAL, avail.SB_RATE,
				avail.NFS_QTY, avail.NFS_RATE, avail.EXT2_QTY, avail.EXT2_RATE, lpt.position_flag as LPT_POSITION_FLAG, lpt.trader_approved_qty
				--,
				--CASE WHEN lpt.source_cd in (gec_constants_pkg.C_API_LOCATE,gec_constants_pkg.C_FA_SMAC_REQUEST,gec_constants_pkg.C_FA_GSMAC_REQUEST,gec_constants_pkg.C_FA_REQUEST) AND strategy.ST_GC_RATE_TYPE='T' THEN 'GC'
				--	 WHEN lpt.source_cd in (gec_constants_pkg.C_API_LOCATE,gec_constants_pkg.C_FA_SMAC_REQUEST,gec_constants_pkg.C_FA_GSMAC_REQUEST,gec_constants_pkg.C_FA_REQUEST) AND strategy.ST_GC_RATE_TYPE='N' THEN gec_utils_pkg.number_to_char(avail.NSB_RATE)
				--	 ELSE lpt.indicative_rate
				-- END AS indicative_rate
			 from gec_locate_preborrow_temp lpt, gec_im_availability avail,gec_strategy strategy
			 where lpt.im_availability_id = avail.im_availability_id
			   and lpt.strategy_id = strategy.strategy_id
			   and strategy.status = 'A'
			   and lpt.status = 'P' 	
			   and avail.status = 'A'
		       and (lpt.TRANSACTION_CD=GEC_CONSTANTS_PKG.C_LOCATE OR lpt.TRANSACTION_CD=GEC_CONSTANTS_PKG.C_SHORT OR lpt.TRANSACTION_CD=GEC_CONSTANTS_PKG.C_PREBORROW) --Remove preborrow: delete OR lpt.TRANSACTION_CD=GEC_CONSTANTS_PKG.C_PREBORROW 
			--   and (lpt.position_flag = GEC_CONSTANTS_PKG.C_GC OR lpt.trader_approved_qty IS NOT NULL)
		     order by avail.IM_AVAILABILITY_ID, lpt.locate_preborrow_id;

			v_avail_id				gec_im_availability.IM_AVAILABILITY_ID%type;
			v_avail_nsb_qty 		gec_im_availability.NSB_QTY%type;
			v_avail_sb_qty 			gec_im_availability.SB_QTY%type;
			v_avail_sb_qty_ral 		gec_im_availability.SB_QTY_RAL%type;
			v_avail_nfs_qty 		gec_im_availability.NFS_QTY%type;
			v_avail_ext2_qty 		gec_im_availability.EXT2_QTY%type;
						
			v_locate_nsb_qty 		gec_locate_preborrow_temp.RESERVED_NSB_QTY%type;
			v_locate_sb_qty 		gec_locate_preborrow_temp.RESERVED_SB_QTY%type;
			v_locate_sb_qty_ral 	gec_locate_preborrow_temp.SB_QTY_RAL%type;
			v_locate_nfs_qty 		gec_locate_preborrow_temp.RESERVED_NFS_QTY%type;
			v_locate_ext2_qty 		gec_locate_preborrow_temp.RESERVED_EXT2_QTY%type;
					
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
		
		FOR v_lpt in v_cur_lpt
		LOOP
			IF p_oper=GEC_CONSTANTS_PKG.C_LOCATE_TRADER_ENTER OR v_lpt.LPT_POSITION_FLAG=GEC_CONSTANTS_PKG.C_GC OR v_lpt.trader_approved_qty IS NOT NULL THEN
				--clean up
				v_locate_nsb_qty := 0;
				v_locate_sb_qty := 0;
				v_locate_sb_qty_ral := 0;
				v_locate_nfs_qty := 0;
				v_locate_ext2_qty := 0;
					
				if(v_lpt.IM_AVAILABILITY_ID = v_avail_id) then
					null; -- do nothing
				else
					v_avail_nsb_qty := NVL(v_lpt.nsb_qty,0);
					v_avail_sb_qty := NVL(v_lpt.sb_qty,0);
					v_avail_sb_qty_ral := NVL(v_lpt.sb_qty_ral,0);
					v_avail_nfs_qty := NVL(v_lpt.nfs_qty,0);
					v_avail_ext2_qty := NVL(v_lpt.ext2_qty,0);								
				end if;
				
				--invoke function to calculate quantity
				RESERVE_AVAILABILITY( 	v_avail_sb_qty 		,
		  								v_avail_sb_qty_ral 	,
		  								v_avail_nsb_qty 	,
		                               	v_avail_nfs_qty 	,
		                               	v_avail_ext2_qty 	,
		                               	v_locate_sb_qty 	,
		                               	v_locate_sb_qty_ral ,
		                               	v_locate_nsb_qty 	,
		                               	v_locate_nfs_qty 	,
		                               	v_locate_ext2_qty 	,
		                               	v_lpt.share_qty 	); 
	
				-- update 
	   			UPDATE gec_locate_preborrow_temp
				       SET Reserved_SB_Qty 		=   v_locate_sb_qty,
			                SB_Qty_RAL 			= 	v_locate_sb_qty_ral,
			                Reserved_NSB_Qty	= 	v_locate_nsb_qty,
			                Reserved_NFS_Qty 	= 	v_locate_nfs_qty,
			                Reserved_EXT2_Qty 	= 	v_locate_ext2_qty,
			                SB_Rate 			= v_lpt.SB_Rate,
			                NSB_Rate 			= v_lpt.NSB_Rate,
			                NFS_Rate 			= v_lpt.NFS_Rate,
			                EXT2_Rate 			= v_lpt.EXT2_Rate,
			                Position_Flag 		= v_lpt.Position_Flag,
			                RESTRICTION_CD 		= v_lpt.RESTRICTION_CD,
			                Remaining_SFP 		= 0,
			                IM_AVAILABILITY_ID 	= v_lpt.IM_AVAILABILITY_ID--,
			                --INDICATIVE_RATE 	= v_lpt.indicative_rate
	   			WHERE rowid = v_lpt.lpt_rowid;
				
				v_avail_id 	:= 	v_lpt.IM_AVAILABILITY_ID;	
			END IF;	
		END LOOP;		
		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END CALCULATE_QUANTITIES;
	
		
    FUNCTION GET_ERROR_COUNT RETURN NUMBER
    IS
    	v_errorCount NUMBER(10) := NULL;
    BEGIN
		--qry_select_Locate_Preborrow_errors
		SELECT count(STATUS) INTO v_errorCount
		FROM GEC_LOCATE_PREBORROW_temp
		WHERE STATUS='X';
		RETURN v_errorCount;
    END GET_ERROR_COUNT;

	FUNCTION IS_VALID_ASSET_CODE(P_ASSET_CODE IN VARCHAR2,
	                             P_ASSET_CODE_TYPE IN VARCHAR2) RETURN VARCHAR2
	IS
		V_RET VARCHAR2(1) := 'N';
	BEGIN
		IF P_ASSET_CODE_TYPE = GEC_CONSTANTS_PKG.C_CSP AND LENGTH(P_ASSET_CODE) = 9 THEN
			V_RET := 'Y';
		ELSIF P_ASSET_CODE_TYPE = GEC_CONSTANTS_PKG.C_ISN AND LENGTH(P_ASSET_CODE) = 12 THEN
			V_RET := 'Y';
		ELSIF P_ASSET_CODE_TYPE = GEC_CONSTANTS_PKG.C_SED AND LENGTH(P_ASSET_CODE) = 7 THEN
			V_RET := 'Y';
		ELSE
			V_RET := 'N';
		END IF;
		RETURN V_RET;
	END IS_VALID_ASSET_CODE;
	
	PROCEDURE FILL_ASSETS_FOR_NEW_ORDERS
	IS
		--In current release, we match only field asset_code instead of all cusip/isin/sedol
		CURSOR v_cur_exist_assets is
			select GEC_LOCATE_PREBORROW_temp.rowid as row_id, ai.asset_id
			from GEC_LOCATE_PREBORROW_temp
			join gec_asset_identifier ai
			on GEC_LOCATE_PREBORROW_temp.asset_code = ai.asset_code;
		
		--If the asset_code is the same in several requests/orders, we will use the one with max information fields.
		CURSOR v_cur_new_assets is
			select lpt.cusip, lpt.isin, lpt.sedol,lpt.quik, lpt.ticker, lpt.description, lpt.asset_code, lpt.asset_code_type
			  from (
					select lpt.cusip, lpt.isin, lpt.sedol, lpt.quik quik, lpt.ticker, lpt.description, lpt.asset_code, lpt.asset_code_type,
							( rank() over(partition by lpt.asset_code 
									order by (case when lpt.asset_code_type = GEC_CONSTANTS_PKG.C_CSP AND lpt.isin IS NOT NULL AND lpt.sedol IS NOT NULL
												  then 1
												  when lpt.asset_code_type = GEC_CONSTANTS_PKG.C_CSP AND lpt.isin IS NOT NULL AND lpt.sedol IS NULL
												  then 2
												  when lpt.asset_code_type = GEC_CONSTANTS_PKG.C_CSP AND lpt.isin IS NULL AND lpt.sedol IS NOT NULL
												  then 3
												  when lpt.asset_code_type = GEC_CONSTANTS_PKG.C_ISN AND lpt.sedol IS NOT NULL
												  then 1
												  else 9
											  end), rownum
								) ) rank
					from GEC_LOCATE_PREBORROW_temp lpt
					left outer join gec_asset_identifier ai
					on lpt.asset_code = ai.asset_code
					where 
						(	lpt.cusip is not null 
						 	or lpt.isin is not null 
	           				or lpt.sedol is not null 
	           				or lpt.quik is not null 
	           				)          				
						and ai.asset_id is null 
						and lpt.status != 'X'   -- add 'X'  do not deal preborrow with X status					 		
					) lpt
			 where rank = 1;
		v_asset_id GEC_ASSET.ASSET_ID%TYPE;
			
	BEGIN
		--if asset_id not found, insert a new asset with source_flag 'R'
		FOR v_rec in v_cur_new_assets
		LOOP
			SELECT GEC_ASSET_ID_SEQ.NEXTVAL INTO V_ASSET_ID FROM DUAL;
			INSERT INTO GEC_ASSET(ASSET_ID, CUSIP, ISIN, SEDOL, TICKER, DESCRIPTION, SOURCE_FLAG,QUIK)
				VALUES (V_ASSET_ID, v_rec.CUSIP, v_rec.ISIN, v_rec.SEDOL, null, v_rec.DESCRIPTION, GEC_CONSTANTS_PKG.C_SOURCE_FLAG_IM_REQUEST,v_rec.quik); --v_rec.TICKER
			IF v_rec.ASSET_CODE IS NOT NULL THEN
				INSERT INTO GEC_ASSET_IDENTIFIER(ASSET_CODE, ASSET_CODE_TYPE, ASSET_ID)
				    VALUES (v_rec.ASSET_CODE, v_rec.ASSET_CODE_TYPE, V_ASSET_ID);
			END IF;
		END LOOP;

		--update asset_id in gec_locate_preborrow_temp if the asset is found.
		FOR v_rec in v_cur_exist_assets
		LOOP
			UPDATE GEC_LOCATE_PREBORROW_temp
			   SET asset_id = v_rec.asset_id
			 WHERE rowid = v_rec.row_id;
		END LOOP;
	END FILL_ASSETS_FOR_NEW_ORDERS;
	
	PROCEDURE UPDATE_TEMP_REQUEST_BY_AVAIL
	IS
	
	CURSOR CUR_UPDATE_REQUEST_BY_AVAIL IS
		select 						
					(rank() over(partition by loc.locate_preborrow_id order by avail.im_availability_id asc) ) as rank,					
					avail.im_availability_id, 
					nvl(gar.restriction_cd, avail.restriction_cd) as restriction_cd, 
					nvl(gar.Position_flag, avail.Position_flag) as Position_flag, 
					loc.Locate_Preborrow_id,
					avail.SB_RATE, 
					avail.NSB_RATE, 
					avail.NFS_RATE, 
					avail.EXT2_RATE,
					nvl(gar.INTERNAL_COMMENT_TXT, avail.INTERNAL_COMMENT_TXT) as INTERNAL_COMMENT_TXT,
					loc.rowid as row_id,
					avail.INDICATIVE_RATE,
					strategy_profile.min_sp_rate,
					strategy_profile.gc_rate,
					loc.source_cd,
					strategy.ST_GC_RATE_TYPE,
					strategy.gc_rate_type,
					strategy_profile.strategy_id AS profile_strategy_id, 	
          			gar.INDICATIVE_RATE AS SM_INDICATIVE_RATE
			FROM gec_im_availability  avail , GEC_LOCATE_PREBORROW_temp loc,
			gec_strategy_profile strategy_profile, gec_strategy strategy, GEC_ASSET_RATE gar
			where loc.asset_id = avail.asset_id
			  and avail.status = 'A'
			  and avail.strategy_id = loc.strategy_id
			  and avail.trade_country_cd = loc.trade_country_cd
			  and loc.strategy_id = strategy.strategy_id
			  and strategy.status = 'A'
			  and strategy_profile.status = 'A'
			  and loc.strategy_id = strategy_profile.strategy_id
			  and loc.trade_country_cd = strategy_profile.trade_country_cd
			  and avail.asset_id = gar.asset_id(+) ;
					  
		v_nsb_rate GEC_LOCATE_PREBORROW_temp.nsb_rate%TYPE;
		v_indicative_rate GEC_LOCATE_PREBORROW_temp.indicative_rate%TYPE;	
	BEGIN
				
		FOR v_rec in CUR_UPDATE_REQUEST_BY_AVAIL LOOP
									
				gec_availability_pkg.GET_INDICATIVE_RATE (
									v_rec.source_cd, 
									v_rec.Position_flag, 	
									v_rec.st_gc_rate_type, 		
									v_rec.gc_rate_type,
									v_rec.SM_INDICATIVE_RATE,			
									v_rec.nsb_rate, 
									v_rec.min_sp_rate ,			
									v_rec.gc_rate,		
									v_indicative_rate	
									);
			
				UPDATE GEC_LOCATE_PREBORROW_temp temp
				SET temp.restriction_cd = v_rec.restriction_cd,
					temp.position_flag  = v_rec.Position_flag,
					temp.SB_RATE = v_rec.SB_RATE,
					temp.NSB_RATE = v_rec.NSB_RATE,
					temp.NFS_RATE = v_rec.NFS_RATE,
					temp.EXT2_RATE = v_rec.EXT2_RATE,
					temp.im_availability_id = v_rec.im_availability_id,
					temp.INDICATIVE_RATE = DECODE(TRANSACTION_CD,GEC_CONSTANTS_PKG.C_COVER,NULL,GEC_CONSTANTS_PKG.C_SHORT,NULL, NVL(INDICATIVE_RATE, v_indicative_rate) ),
					temp.internal_comment_txt = gec_utils_pkg.sub_comment(trim(temp.internal_comment_txt|| v_rec.internal_comment_txt))
				WHERE temp.rowid = v_rec.row_id;					
				
		END LOOP;									
							
	END UPDATE_TEMP_REQUEST_BY_AVAIL;
		
	PROCEDURE UPDATE_TEMP_ORDER_BY_AVAIL
	IS
	
	CURSOR CUR_UPDATE_REQUEST_BY_AVAIL IS
				SELECT					
					avail.im_availability_id, 
					nvl((nvl(gar.restriction_cd, avail.restriction_cd)),'0') as restriction_cd, 
					nvl(gar.Position_flag, case when avail.im_availability_id is null then 'GC' else avail.Position_flag end) as Position_flag, 
					loc.rowid as row_id
				FROM GEC_IM_ORDER_TEMP loc 
      			left join gec_fund gf 
     			on loc.fund_cd=gf.fund_cd
      			left join gec_im_availability  avail 
      			on avail.status = 'A'  
        			and loc.asset_id = avail.asset_id
        			and avail.strategy_id = gf.strategy_id
      			left join GEC_ASSET_RATE gar
      			on loc.asset_id = gar.asset_id;
					  
	BEGIN
				
		FOR v_rec in CUR_UPDATE_REQUEST_BY_AVAIL LOOP
				UPDATE GEC_IM_ORDER_temp temp
				SET temp.restriction_cd = v_rec.restriction_cd,
					temp.position_flag  = v_rec.Position_flag,
					temp.im_availability_id = v_rec.im_availability_id
				WHERE temp.rowid = v_rec.row_id;					
				
		END LOOP;									
							
	END UPDATE_TEMP_ORDER_BY_AVAIL;
	PROCEDURE UPDATE_WHEN_NO_AVAILABILITY
	IS
		CURSOR cur_set_indicative_rate IS
		SELECT 
			temp.rowid as row_id,
			rate.internal_comment_txt,
			nvl(rate.POSITION_FLAG,'GC') as POSITION_FLAG,
			rate.INDICATIVE_RATE as SM_INDICATIVE_RATE,
			rate.RESTRICTION_CD,
			rate.type,
			strategy_profile.min_sp_rate,
			strategy_profile.gc_rate,
			temp.im_availability_id,
			temp.source_cd,
			strategy.ST_GC_RATE_TYPE,
			strategy.gc_rate_type,
			strategy_profile.strategy_id AS profile_strategy_id,
			temp.indicative_rate as loc_indicative_rate 	
		FROM GEC_LOCATE_PREBORROW_TEMP temp
		INNER JOIN gec_strategy strategy
			ON temp.strategy_id = strategy.strategy_id
				AND strategy.status = 'A'
		LEFT JOIN gec_strategy_profile strategy_profile
			ON strategy.strategy_id = strategy_profile.strategy_id
				AND temp.trade_country_cd = strategy_profile.trade_country_cd
				AND strategy_profile.status ='A'
		LEFT JOIN GEC_ASSET_RATE rate
			ON 	rate.status = 'A'
				AND temp.asset_id = rate.asset_id
		WHERE temp.asset_id IS NOT NULL
			AND temp.im_availability_id IS NULL;
							
	v_nsb_rate GEC_LOCATE_PREBORROW_temp.nsb_rate%TYPE;
	v_indicative_rate GEC_LOCATE_PREBORROW_temp.indicative_rate%TYPE;
			
	BEGIN
	--When asset exists in securityMaster(gec_asset) and has no availability
	--http://ajra03.statestr.com:8080/browse/GEC-1520
	FOR v_rec in cur_set_indicative_rate LOOP
			
			--IF ( v_rec.profile_strategy_id IS NULL) THEN
			--NO THIS STRATEGY-COUNTRY PROFILE SETUP FOR THIS STRATEGY
			--THE RATE SHOULD BE 999
			--	v_indicative_rate := GEC_CONSTANTS_PKG.C_DEFAULT_INDICATIVE_RATE;
			--	v_nsb_rate := GEC_CONSTANTS_PKG.C_DEFAULT_NSB_RATE;
			--ELSE
			--HAS STRATEGY-COUNTRY PROFILE SETUP FOR THE STRATEGY
			gec_availability_pkg.GET_INDICATIVE_RATE (
								v_rec.source_cd, 
								v_rec.position_flag, 	
								v_rec.st_gc_rate_type, 		
								v_rec.gc_rate_type,			
								v_rec.sm_indicative_rate, 
								NULL,	
								v_rec.min_sp_rate ,			
								v_rec.gc_rate,		
								v_indicative_rate	
								);
			
			UPDATE GEC_LOCATE_PREBORROW_temp
			   SET 	INDICATIVE_RATE = DECODE(TRANSACTION_CD,GEC_CONSTANTS_PKG.C_COVER,NULL,GEC_CONSTANTS_PKG.C_SHORT,NULL, NVL(v_rec.loc_indicative_rate, v_indicative_rate) ),
			   		nsb_rate		= gec_constants_pkg.C_DEFAULT_NSB_RATE,
			   		POSITION_FLAG 	= nvl(v_rec.POSITION_FLAG, POSITION_FLAG),
			   		RESTRICTION_CD 	= nvl(v_rec.RESTRICTION_CD, RESTRICTION_CD)
			 WHERE rowid = v_rec.row_id;						
			
	END LOOP;		
	
	--AVAILABILITY does not exists and asset does not exists.
	UPDATE 	GEC_LOCATE_PREBORROW_temp 
		SET 
			NSB_RATE =  DECODE(TRANSACTION_CD,GEC_CONSTANTS_PKG.C_COVER, NSB_RATE, GEC_CONSTANTS_PKG.C_SHORT, NSB_RATE,GEC_CONSTANTS_PKG.C_DEFAULT_NSB_RATE ),
			INDICATIVE_RATE = DECODE(TRANSACTION_CD,GEC_CONSTANTS_PKG.C_COVER,NULL,GEC_CONSTANTS_PKG.C_SHORT,NULL,NVL(INDICATIVE_RATE, GEC_CONSTANTS_PKG.C_DEFAULT_INDICATIVE_RATE)	)	
	WHERE ASSET_ID IS NULL 
		AND IM_AVAILABILITY_ID IS NULL;
				
	END UPDATE_WHEN_NO_AVAILABILITY;	
						
	PROCEDURE UPDATE_INTERNAL_COMMENT
	IS
		CURSOR cur_set_internal_comment IS
		SELECT 
			temp.rowid as row_id,
			rate.internal_comment_txt			
		FROM GEC_LOCATE_PREBORROW_TEMP temp, gec_asset_rate rate
		where temp.im_availability_id IS NULL 
			AND temp.asset_id is not null
			AND temp.asset_id = rate.asset_id
			AND temp.status <> 'X';				
	BEGIN
		FOR v_rec in cur_set_internal_comment LOOP
				UPDATE GEC_LOCATE_PREBORROW_temp
			   	SET 
			   		internal_comment_txt = gec_utils_pkg.sub_comment(trim(internal_comment_txt|| ' ' ||v_rec.internal_comment_txt))
			 	WHERE rowid = v_rec.row_id;	
			null;
		END LOOP;		
	END UPDATE_INTERNAL_COMMENT;
	
	PROCEDURE UPDATE_REQUEST_AFTER_CUTOFF( p_curr_date IN DATE)
	IS
		CURSOR cur_request_after_cutoff IS
		SELECT temp.rowid AS ROW_ID
		FROM GEC_LOCATE_PREBORROW_temp temp, GEC_STRATEGY strategy,GEC_STRATEGY_PROFILE profile, GEC_TRADE_COUNTRY country
		WHERE temp.strategy_id = strategy.strategy_id
			   and temp.trade_country_cd = country.trade_country_cd
			   and strategy.strategy_id = profile.strategy_id
			   and temp.trade_country_cd = profile.trade_country_cd
			   and temp.business_date > gec_utils_pkg.DATE_TO_NUMBER(gec_utils_pkg.TO_TIMEZONE(p_curr_date,gec_constants_pkg.C_BOS_TIMEZONE,country.locale))
			   and gec_utils_pkg.TO_CUTOFF_TIME(p_curr_date,gec_constants_pkg.C_BOS_TIMEZONE,country.locale) >= gec_utils_pkg.FORMAT_CUTOFF_TO_HH24(country.cutoff_time)
			   and temp.status IN ( 'P', 'E')
			   and profile.HOLDBACK_FLAG = 'Y'
			   and country.STATUS NOT IN ('D');
	BEGIN
		-- Locate : date = next day, time = 3:00PM,cut off time:2:00PM, schedule flag is 'YES'. 
		-- schedule to process at 4:00PM, date -> today, approve = 0 , rate = 999.
		-- http://ajra03.statestr.com:8080/browse/GEC-1499 	
		-- trader_approved_qty = 0, this trader_approved_qty is useless, since the syste will not allocate any
		-- qunaity for this case even though trader_approved_qty  > 0. trader_approved_qty = 0 is an important indicator
		-- shows that not allocate quantity in UPLOAD_TRADER_LOCATE_ENTRY.	
		FOR v_rec in cur_request_after_cutoff
		LOOP
			UPDATE GEC_LOCATE_PREBORROW_temp
			   SET 	Reserved_SB_Qty 	=   0,
		            SB_Qty_RAL 			= 	0,
		            Reserved_NSB_Qty	= 	0,
		            Reserved_NFS_Qty 	= 	0,
		            Reserved_EXT2_Qty 	= 	0,
			   		indicative_rate = 999,
			   		status = 'E',
			   		trader_approved_qty = 0, 
			   		comment_txt = gec_utils_pkg.SUB_COMMENT(comment_txt||' '||GEC_ERROR_CODE_PKG.C_VLD_MSG_AFTER_MARKET_HOUR)
			 WHERE rowid = v_rec.row_id;
		END LOOP;
		
	END UPDATE_REQUEST_AFTER_CUTOFF;
	

	PROCEDURE FILL_INLINE_EDIT( p_uploadData        IN GEC_IM_REQUEST_TP_ARRAY )
	IS
	BEGIN
		-- update temp with modification.		
		MERGE INTO GEC_LOCATE_PREBORROW_temp temp
		USING  ( 		
			SELECT 
				pre.locate_preborrow_id , pre.business_date,
        		--pre.SETTLE_DATE, 
        		--pre.created_by, pre.im_user_id ,
				pre.created_at,
				pre.file_version,
				pre.request_id,
				pre.row_number,
				pre.im_request_id,
				pre.im_locate_id
			FROM 
					 TABLE ( cast ( p_uploadData as GEC_IM_REQUEST_TP_ARRAY) ) locRequest,
					GEC_LOCATE_PREBORROW pre
			where 
					 pre.locate_preborrow_id = locRequest.locate_preborrow_id
					AND locRequest.locate_preborrow_id is not null			
		) qry
		ON (temp.Locate_Preborrow_id = qry.Locate_Preborrow_id )
		WHEN MATCHED THEN
			UPDATE SET --temp.SETTLE_DATE = qry.SETTLE_DATE,
						-- created by, created at, and im user id will be new value based on resubmit request via inline edit
						--temp.created_by  = qry.created_by,
						temp.created_at = qry.created_at,
						--temp.im_user_id = qry.im_user_id,
						temp.file_version = file_version,
						temp.request_id = qry.request_id,
						temp.row_number = qry.row_number,
						temp.im_request_id = qry.im_request_id,
						temp.im_locate_id= qry.im_locate_id;
						
		-- after set fields to inline edit records,delete these recrods from gec_locate_preborrow
		delete from GEC_LOCATE_PREBORROW preborrow
	    where exists(  
	          select 1 from  TABLE ( cast ( p_uploadData as GEC_IM_REQUEST_TP_ARRAY) ) irt
	          where irt.locate_preborrow_id = preborrow.locate_preborrow_id
	          		AND  irt.locate_preborrow_id IS NOT NULL
	        );   
		   

	END FILL_INLINE_EDIT;
	

	FUNCTION IS_INLINE_EDIT(p_uploadData        IN GEC_IM_REQUEST_TP_ARRAY) RETURN VARCHAR2
	IS
		v_locate_preborrow_id NUMBER(38);
	BEGIN
			-- if it is not inlineedit, it will do nohing
			-- else it will update new locate in gec_locate_preborrow_temp according to old record in gec_locate_preborrow
			begin
				select locate_preborrow_id into v_locate_preborrow_id 
				from  TABLE ( cast ( p_uploadData as GEC_IM_REQUEST_TP_ARRAY) ) locRequest 
				where rownum = 1 ;			
			EXCEPTION WHEN NO_DATA_FOUND THEN
				return 'N';
	        END;  
			
			if (v_locate_preborrow_id is not null ) and ( v_locate_preborrow_id >0)  then		
				return 'Y';
			else
				return 'N';
			end if;	
					
			return 'N';
	END IS_INLINE_EDIT;

	--allocate AVAILABILITY for locate.
	PROCEDURE RESERVE_AVAILABILITY( p_avail_sb_qty 		IN OUT NUMBER ,
	  								p_avail_sb_qty_ral 	IN OUT NUMBER ,
	  								p_avail_nsb_qty 	IN OUT NUMBER ,
	                               	p_avail_nfs_qty 	IN OUT NUMBER ,
	                               	p_avail_ext2_qty 	IN OUT NUMBER ,
	                               	p_locate_sb_qty 	OUT NUMBER ,
	                               	p_locate_sb_qty_ral OUT NUMBER ,
	                               	p_locate_nsb_qty 	OUT NUMBER ,
	                               	p_locate_nfs_qty 	OUT NUMBER ,
	                               	p_locate_ext2_qty 	OUT NUMBER ,
	                               	p_share_qty 		IN  NUMBER )
	IS	
			v_avail_sb_qty 		NUMBER(38);
	  		v_avail_sb_qty_ral 	NUMBER(38);
	  		v_avail_nsb_qty 	NUMBER(38);
	        v_avail_nfs_qty 	NUMBER(38);
	        v_avail_ext2_qty 	NUMBER(38);
	BEGIN	
			p_locate_sb_qty 	:= 0; 
	        p_locate_sb_qty_ral := 0; 
	        p_locate_nsb_qty 	:= 0; 
	        p_locate_nfs_qty 	:= 0; 
	        p_locate_ext2_qty 	:= 0; 
	        --Record available quantities to temp varible
	       	v_avail_sb_qty 		:= p_avail_sb_qty;
	  		v_avail_sb_qty_ral 	:= p_avail_sb_qty_ral;
	  		v_avail_nsb_qty 	:= p_avail_nsb_qty;
	       	v_avail_nfs_qty 	:= p_avail_nfs_qty;
	        v_avail_ext2_qty 	:= p_avail_ext2_qty;
	        --If available quantities are negative,set them to be 0, So the calculation process 
			--will be unified as normal scenarioes.
			p_avail_sb_qty 		:= case when p_avail_sb_qty <0 then 0 else p_avail_sb_qty end;
	  		p_avail_sb_qty_ral 	:= case when p_avail_sb_qty_ral<0 then 0 else p_avail_sb_qty_ral end;
	  		p_avail_nsb_qty 	:= case when p_avail_nsb_qty<0 then 0 else p_avail_nsb_qty end;
	        p_avail_nfs_qty 	:= case when p_avail_nfs_qty<0 then 0 else p_avail_nfs_qty end;
	        p_avail_ext2_qty 	:= case when p_avail_ext2_qty<0 then 0 else p_avail_ext2_qty end;
	
			if ( p_share_qty < p_avail_sb_qty) then			
				p_locate_sb_qty 	:= 	p_share_qty;						
			elsif   p_share_qty  <=   p_avail_sb_qty + p_avail_sb_qty_ral then 			
				p_locate_sb_qty 	:= 	p_avail_sb_qty;
				p_locate_sb_qty_ral := 	p_share_qty-p_avail_sb_qty;				
			elsif p_share_qty <= p_avail_sb_qty + p_avail_sb_qty_ral + p_avail_nsb_qty then				
				p_locate_sb_qty 	:= 	p_avail_sb_qty;
				p_locate_sb_qty_ral := 	p_avail_sb_qty_ral;
				p_locate_nsb_qty 	:= 	p_share_qty - p_avail_sb_qty - p_avail_sb_qty_ral;			
			elsif p_share_qty <= p_avail_sb_qty + p_avail_sb_qty_ral + p_avail_nsb_qty + p_avail_nfs_qty  then 						
				p_locate_sb_qty 	:= 	p_avail_sb_qty;
				p_locate_sb_qty_ral := 	p_avail_sb_qty_ral;
				p_locate_nsb_qty 	:= 	p_avail_nsb_qty;
				p_locate_nfs_qty 	:= 	p_share_qty - p_avail_sb_qty - p_avail_sb_qty_ral - p_avail_nsb_qty ;				
			elsif p_share_qty <= p_avail_sb_qty + p_avail_sb_qty_ral + p_avail_nsb_qty + p_avail_nfs_qty + p_avail_ext2_qty then 				
				p_locate_sb_qty 	:= 	p_avail_sb_qty;
				p_locate_sb_qty_ral := 	p_avail_sb_qty_ral;
				p_locate_nsb_qty 	:= 	p_avail_nsb_qty;
				p_locate_nfs_qty 	:= 	p_avail_nfs_qty;
				p_locate_ext2_qty 	:= 	p_share_qty - p_avail_sb_qty - p_avail_sb_qty_ral - p_avail_nsb_qty - p_avail_nfs_qty;				
			elsif (p_share_qty > p_avail_sb_qty + p_avail_sb_qty_ral + p_avail_nsb_qty + p_avail_nfs_qty + p_avail_ext2_qty)
						and  (p_avail_sb_qty + p_avail_sb_qty_ral + p_avail_nsb_qty + p_avail_nfs_qty + p_avail_ext2_qty >0) then 						
				p_locate_sb_qty 	:= 	p_avail_sb_qty;
				p_locate_sb_qty_ral := 	p_avail_sb_qty_ral;
				p_locate_nsb_qty 	:= 	p_avail_nsb_qty;
				p_locate_nfs_qty 	:= 	p_avail_nfs_qty;
				p_locate_ext2_qty 	:= 	p_avail_ext2_qty;			
			end if;
			--Use temp varibles to calculate available quantities.
			--These substrated avail qtys can be used in next locate with same im_availabilty_id.
			p_avail_nsb_qty 	:= 	v_avail_nsb_qty 	- 	p_locate_nsb_qty;
			p_avail_sb_qty 		:= 	v_avail_sb_qty 		- 	p_locate_sb_qty;
			p_avail_sb_qty_ral 	:= 	v_avail_sb_qty_ral 	- 	p_locate_sb_qty_ral;
			p_avail_nfs_qty 	:= 	v_avail_nfs_qty 	- 	p_locate_nfs_qty;
			p_avail_ext2_qty 	:= 	v_avail_ext2_qty 	- 	p_locate_ext2_qty;				
	END RESERVE_AVAILABILITY;
	
	--TRADER LOCATE ENTRY                               					
	PROCEDURE UPLOAD_TRADER_LOCATE_ENTRY
	IS
	BEGIN	
	  -- SET SFA_QTY , SHARE_QTY
      --set share qty back,Since when fill_locate_temp, it maybe set as trader_approved_qty           	
      update gec_locate_preborrow_temp
      		set 
      		 	share_qty = trader_request_qty,
      			status = ( case when status = 'P' and trader_request_qty > trader_approved_qty then 'E' 
				 			when status = 'E' and trader_request_qty = trader_approved_qty then 'P' 
				 			else status end ),         	  
				reserved_nsb_qty = (case when status = 'E' and trader_approved_qty >0 then (Reserved_nsb_qty + trader_approved_qty - (Reserved_sb_qty + sb_qty_ral + Reserved_nsb_qty + Reserved_nfs_qty + Reserved_ext2_qty)) else  Reserved_nsb_qty end)				 			
		where trader_approved_qty is not null;
			
	END UPLOAD_TRADER_LOCATE_ENTRY;

	PROCEDURE UPLOAD_API_LOCATE(p_uploadData        IN 	GEC_IM_REQUEST_TP_ARRAY,
								p_uploadedBy        IN 	VARCHAR2,
								p_checkTrailer 	 	IN 	VARCHAR2,
								p_transactionCd 	IN 	VARCHAR2,
								p_errorCode         OUT VARCHAR2,
								p_errorCount        OUT NUMBER)
	IS
		v_request_id GEC_LOCATE_PREBORROW.request_id%type;
        v_locate_on_preborrow_cntry VARCHAR2(1) := 'N';
	BEGIN
		p_errorCount := 0;
		p_errorCode := NULL;
		BEGIN
			INSERT INTO GEC_LOCATE_PREBORROW
			(
				Locate_Preborrow_id,	INITIAL_FLAG,		CREATED_BY, 	CREATED_AT,
			 	REQUEST_ID,				IM_REQUEST_ID,		IM_LOCATE_ID,	TRANSACTION_CD	
			 )
			SELECT  gec_Locate_Preborrow_id_seq.nextval, 	'Y',				p_uploadedBy,	SYSDATE,				
					REQUEST_ID,								IM_REQUEST_ID,		IM_LOCATE_ID,	TRANSACTION_CD
			 FROM TABLE ( CAST ( p_uploadData AS GEC_IM_REQUEST_TP_ARRAY) ) irt;
			 
			 COMMIT;
		EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
			p_errorCode := GEC_ERROR_CODE_PKG.C_API_DUPLICATED_LOCATE_ID;
			return;			
		END;
	 
		--Upload IM Locates
	 	UPLOAD_IM_REQUEST( p_uploadData,
		                p_uploadedBy,
		                'N',
		                p_transactionCd,
		                GEC_CONSTANTS_PKG.C_LOCATE_CLIENT_ENTER,
		                p_errorCode,
		                p_errorCount,
		                v_request_id,
		                v_locate_on_preborrow_cntry);
	
	END UPLOAD_API_LOCATE;

		                         
	PROCEDURE DELETE_API_LOCATE(p_uploadData        IN GEC_IM_REQUEST_TP_ARRAY,
								p_uploadedBy        IN VARCHAR2)
	IS	
	BEGIN	
		DELETE FROM GEC_LOCATE_PREBORROW pre
		WHERE EXISTS ( SELECT 1 FROM TABLE ( cast ( p_uploadData as GEC_IM_REQUEST_TP_ARRAY) ) irt
						WHERE  	pre.request_id = irt.request_id 
							AND pre.im_locate_id = irt.im_locate_id
							AND pre.im_request_id = irt.im_request_id
					)
			AND CREATED_BY = p_uploadedBy
			AND INITIAL_FLAG = 'Y';
		
		COMMIT;		
	END DELETE_API_LOCATE;	 	
	
		                         
	PROCEDURE DELETE_REQUEST(p_uploadData        IN GEC_IM_REQUEST_TP_ARRAY,
							p_uploadedBy        IN VARCHAR2,
							p_transactionCd     IN  VARCHAR2,
		                    p_sourceCd			IN  VARCHAR2)
	IS
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_UPLOAD_PKG.DELETE_REQUEST';
	BEGIN	
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
		delete GEC_LOCATE_PREBORROW_temp;
		
		IF GEC_CONSTANTS_PKG.C_LOCATE =  p_transactionCd  THEN
		
			IF  p_sourceCd IS NOT NULL AND p_sourceCd=GEC_CONSTANTS_PKG.C_API_LOCATE THEN
					DELETE FROM GEC_LOCATE_PREBORROW pre
					WHERE EXISTS ( 
								SELECT 1 FROM TABLE ( cast ( p_uploadData as GEC_IM_REQUEST_TP_ARRAY) ) irt
								WHERE  	pre.request_id = irt.request_id 
									AND pre.im_locate_id = irt.im_locate_id
									AND pre.im_request_id = irt.im_request_id
							)
					AND CREATED_BY = p_uploadedBy
					AND (im_locate_id IS NOT NULL OR im_request_id IS NOT NULL)
					AND INITIAL_FLAG = 'Y'
					AND TRANSACTION_CD = p_transactionCd;		
			ELSIF  p_sourceCd IS NOT NULL AND p_sourceCd IN (GEC_CONSTANTS_PKG.C_FA_GSMAC_REQUEST, GEC_CONSTANTS_PKG.C_FA_SMAC_REQUEST, GEC_CONSTANTS_PKG.C_FA_REQUEST) THEN
					DELETE GEC_LOCATE_PREBORROW pre
			 		WHERE EXISTS(		   		
			   				SELECT 1 FROM TABLE ( cast ( p_uploadData as GEC_IM_REQUEST_TP_ARRAY) ) irt
							WHERE  	pre.request_id = irt.request_id 
			   			)
			   		AND request_id IS NOT NULL
			   		AND CREATED_BY = p_uploadedBy
			   		AND INITIAL_FLAG = 'Y'
			   		AND TRANSACTION_CD = p_transactionCd;
			-- Upload request via im file, should remove all request for the user
      		ELSIF p_sourceCd IS NOT NULL AND p_sourceCd=GEC_CONSTANTS_PKG.C_IM_FILE THEN
		            DELETE GEC_LOCATE_PREBORROW
					WHERE CREATED_BY = p_uploadedBy
					AND INITIAL_FLAG = 'Y';				   		
			ELSE
				   	DELETE GEC_LOCATE_PREBORROW
				 	WHERE CREATED_BY = p_uploadedBy
				   	AND INITIAL_FLAG = 'Y'
				   	AND TRANSACTION_CD = p_transactionCd;				
			END IF;		
		ELSE 
			-- Upload request via im file, should remove all request for the user
			IF   GEC_CONSTANTS_PKG.C_PREBORROW = p_transactionCd AND p_sourceCd IS NOT NULL AND p_sourceCd=GEC_CONSTANTS_PKG.C_IM_FILE THEN
					DELETE GEC_LOCATE_PREBORROW
					WHERE CREATED_BY = p_uploadedBy
					AND INITIAL_FLAG = 'Y';
			END IF;
		
		END IF;
		
		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END DELETE_REQUEST;     	

	--VALIDATE LOCATE FROM FILE AUTOMATION
	PROCEDURE VALIDATE_FA_LOCATE(p_uploadData        IN 	GEC_IM_REQUEST_TP_ARRAY,
								 p_uploadedBy        IN 	VARCHAR2,
								 p_checkTrailer 	 IN 	VARCHAR2,
								 p_errorCode         OUT	VARCHAR2,
								 p_scheduledTime_cur OUT    SYS_REFCURSOR 
								 )      
	IS
		v_trailer_count NUMBER(10);
		v_row_count NUMBER(10);
		v_index NUMBER(10);	
		v_error_flag VARCHAR2(1);
		v_check_strategy_flag VARCHAR2(1);
    	v_trailer_flag VARCHAR2(1);
    	v_curr_date DATE;
    	v_null_cur SYS_REFCURSOR;
    	V_MAX_SCHEDULEDAT DATE;
    	V_schedule_flag VARCHAR2(1);
    	v_fail_flag VARCHAR(1);
    	v_transactionCd gec_locate_preborrow_temp.transaction_cd%type;
    	v_sourceCd gec_locate_preborrow_temp.source_cd%type;
	BEGIN
		
		GEC_LOG_PKG.LOG_PERFORMANCE_START('GEC_UPLOAD_PKG.VALIDATE_FA_LOCATE');
		v_error_flag := 'N';
		v_check_strategy_flag := 'Y';
		v_fail_flag :='N';
		v_transactionCd := gec_constants_pkg.C_LOCATE;
				
		select sysdate into v_curr_date from dual;
		
		DELETE GEC_LOCATE_PREBORROW_temp;
		
		--identify source and transaction
		IDENTIFY_LOCATE(p_uploadData,v_transactionCd,v_sourceCd,p_errorCode);
		IF p_errorCode IS NOT NULL THEN
			RETURN;
		END IF;
		
		--insert data into GEC_LOCATE_PREBORROW_temp
		--qry_apnd_Locate_Preborrow_temp; qry_updt_request_error; qry_update_Locate_Preborrow_temp_CLIENT_CD; qry_updt_sb_broker_cd
		FILL_LOCATE_PREBORROW_TEMP(p_uploadData, p_uploadedBy,v_sourceCd);   		
		
		gec_validation_pkg.VALIDATE_IM_REQUEST(	p_uploadData ,
												p_uploadedBy,
												p_checkTrailer,
												v_transactionCd,
								 				v_curr_date,	 
												p_errorCode);  		
		IF ( p_errorCode IS NOT NULL ) THEN
			OPEN_NULL_SCHEDULE_CURSOR(p_scheduledTime_cur);
			RETURN;
		END IF;
		
		--Check Locate cannot be processed because Locate Request Date is more than one day in future.
		--C_VLD_MSG_EARLY_LOCATE
		BEGIN		
			select 'Y' INTO v_fail_flag  
			from gec_locate_preborrow_temp loc, gec_trade_country country				 	   
			where loc.trade_country_cd = country.trade_country_cd
			and loc.business_date > gec_utils_pkg.date_to_number( gec_utils_pkg.get_tplusn(gec_utils_pkg.TO_TIMEZONE(v_curr_date, gec_constants_pkg.C_BOS_TIMEZONE, country.LOCALE), 1, loc.trade_country_cd) )
			AND rownum = 1;
								
		EXCEPTION WHEN NO_DATA_FOUND THEN
					v_fail_flag :='N';
		END;	
		
		IF 	v_fail_flag = 'Y' THEN
			OPEN_NULL_SCHEDULE_CURSOR(p_scheduledTime_cur);
			p_errorCode := gec_error_code_pkg.C_VLD_CD_EARLY_LOCATE; --C_VLD_MSG_EARLY_LOCATE
			GEC_LOG_PKG.LOG_PERFORMANCE_END('GEC_UPLOAD_PKG.VALIDATE_FA_LOCATE');	
			RETURN;
		END IF;
		
		v_fail_flag :='N';
		BEGIN			
			SELECT 'Y' INTO v_fail_flag 
			FROM gec_locate_preborrow_temp loc ,gec_strategy strategy
			where loc.strategy_id = strategy.strategy_id
			AND strategy.STATUS = 'A'
			AND strategy.ST_STATUS = 'M'
			AND ROWNUM=1;
		EXCEPTION WHEN NO_DATA_FOUND THEN
			v_fail_flag :='N';
		END;	
		--If one locate in the file is ST manual, the whole request(st file) should be manual processed.
		--OPEN NULL SCHEDULE CURSOR SO THAT NO JOB WILL BE SCHEDULED.
		IF v_fail_flag='Y' THEN
			OPEN_NULL_SCHEDULE_CURSOR(p_scheduledTime_cur);
			GEC_LOG_PKG.LOG_PERFORMANCE_END('GEC_UPLOAD_PKG.VALIDATE_FA_LOCATE');	
			RETURN;
		END IF;
		
		BEGIN
								
			SELECT max(loc.scheduled_at) into V_MAX_SCHEDULEDAT 
			FROM gec_locate_preborrow_temp loc ,gec_strategy strategy
			where loc.strategy_id = strategy.strategy_id
			AND loc.status = 'H'
			AND strategy.STATUS = 'A'
			AND strategy.ST_STATUS = 'O'
			AND loc.scheduled_at IS NOT NULL;
			
			IF 	(V_MAX_SCHEDULEDAT IS NULL) THEN			
				OPEN_NULL_SCHEDULE_CURSOR(p_scheduledTime_cur); 
			ELSE
			
				V_schedule_flag :='Y';
				BEGIN
					SELECT 	'N' INTO V_schedule_flag FROM DUAL
					WHERE EXISTS (
						SELECT 1 FROM (
							select scheduled_at from gec_locate_preborrow 
							where status = 'H' AND INITIAL_FLAG ='N' AND scheduled_at IS NOT NULL 
							UNION ALL
							select scheduled_at from gec_file 
							where status = 'P' AND scheduled_at IS NOT NULL 
						) qry WHERE scheduled_at=V_MAX_SCHEDULEDAT
					 );
					 
				EXCEPTION WHEN NO_DATA_FOUND THEN
					V_schedule_flag :='Y';
				END;		
					
					OPEN p_scheduledTime_cur FOR
					SELECT 	
						V_MAX_SCHEDULEDAT AS scheduled_at,
						to_number(to_char(V_MAX_SCHEDULEDAT,'yyyymmddhh24Miss')) AS job_id, 
						'STFILE' AS job_type ,
						 V_schedule_flag AS schedule_flag
					FROM DUAL;		
									 	
			END IF;
			
		EXCEPTION WHEN NO_DATA_FOUND THEN
			OPEN_NULL_SCHEDULE_CURSOR(p_scheduledTime_cur);
		END;
		
		GEC_LOG_PKG.LOG_PERFORMANCE_END('GEC_UPLOAD_PKG.VALIDATE_FA_LOCATE');		
	END VALIDATE_FA_LOCATE;
	
	--VALIDATE LOCATE FROM FILE AUTOMATION
	PROCEDURE VALIDATE_FA_PREBORROW(p_uploadData        IN 	GEC_IM_REQUEST_TP_ARRAY,
									p_uploadedBy        IN 	VARCHAR2,
									p_checkTrailer 	    IN 	VARCHAR2,
									p_errorCode         OUT	VARCHAR2,
									p_scheduledTime_cur OUT    SYS_REFCURSOR 
									)      
	IS
		v_trailer_count NUMBER(10);
		v_row_count NUMBER(10);
		v_index NUMBER(10);	
		v_error_flag VARCHAR2(1);
		v_check_strategy_flag VARCHAR2(1);
    	v_trailer_flag VARCHAR2(1);
    	v_curr_date DATE;
    	v_null_cur SYS_REFCURSOR;
    	V_MAX_SCHEDULEDAT DATE;
    	V_schedule_flag VARCHAR2(1);
    	v_fail_flag VARCHAR(1);
    	v_transactionCd gec_locate_preborrow_temp.transaction_cd%type;
    	v_sourceCd  gec_locate_preborrow_temp.source_cd%type;
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START('GEC_UPLOAD_PKG.VALIDATE_FA_PREBORROW');
		v_error_flag := 'N';
		v_check_strategy_flag := 'Y';
		v_fail_flag :='N';
		v_transactionCd := gec_constants_pkg.C_PREBORROW;
				
		select sysdate into v_curr_date from dual;
		
		DELETE GEC_LOCATE_PREBORROW_temp;
		
		--identify source and transaction
		IDENTIFY_LOCATE(p_uploadData,v_transactionCd,v_sourceCd,p_errorCode);
		IF p_errorCode IS NOT NULL THEN
			RETURN;
		END IF;
		
		--insert data into GEC_LOCATE_PREBORROW_temp
		--qry_apnd_Locate_Preborrow_temp; qry_updt_request_error; qry_update_Locate_Preborrow_temp_CLIENT_CD; qry_updt_sb_broker_cd
		FILL_LOCATE_PREBORROW_TEMP(p_uploadData, p_uploadedBy,v_sourceCd);   		
					
		
		gec_validation_pkg.VALIDATE_IM_REQUEST(	p_uploadData ,
												p_uploadedBy,
												p_checkTrailer,
												v_transactionCd,
								 				v_curr_date,	 
												p_errorCode);  		
		IF ( p_errorCode IS NOT NULL ) THEN
			OPEN_NULL_SCHEDULE_CURSOR(p_scheduledTime_cur);
			GEC_LOG_PKG.LOG_PERFORMANCE_END('GEC_UPLOAD_PKG.VALIDATE_FA_PREBORROW');		
			RETURN;
		END IF;
		
		BEGIN
		
			select 'Y' INTO v_fail_flag  
			from gec_locate_preborrow_temp loc, gec_trade_country country				 	   
			where loc.trade_country_cd = country.trade_country_cd
			and loc.business_date > gec_utils_pkg.date_to_number( gec_utils_pkg.get_tplusn(gec_utils_pkg.TO_TIMEZONE(v_curr_date, gec_constants_pkg.C_BOS_TIMEZONE, country.LOCALE), 1, loc.trade_country_cd) )
			AND rownum = 1;
								
		EXCEPTION WHEN NO_DATA_FOUND THEN
					v_fail_flag :='N';
		END;	
		
		IF 	v_fail_flag = 'Y' THEN
			OPEN_NULL_SCHEDULE_CURSOR(p_scheduledTime_cur);
			p_errorCode := gec_error_code_pkg.C_VLD_CD_EARLY_LOCATE;
			GEC_LOG_PKG.LOG_PERFORMANCE_END('GEC_UPLOAD_PKG.VALIDATE_FA_PREBORROW');		
			RETURN;
		END IF;	
		--return 1 record with null values.		
		OPEN_NULL_SCHEDULE_CURSOR(p_scheduledTime_cur);
		
		GEC_LOG_PKG.LOG_PERFORMANCE_END('GEC_UPLOAD_PKG.VALIDATE_FA_PREBORROW');		
	END VALIDATE_FA_PREBORROW;


	PROCEDURE OPEN_NULL_SCHEDULE_CURSOR( p_retAvails OUT SYS_REFCURSOR )
	IS
	BEGIN
		OPEN p_retAvails FOR
			select 	null scheduled_at,
				   	0 job_id, 
				  	null job_type ,
					null schedule_flag
			  from dual;
	END OPEN_NULL_SCHEDULE_CURSOR;
		
	--Fill GEC_LOCATE_PREBORROW_temp from locate array
	PROCEDURE FILL_LOCATE_PREBORROW_TEMP ( 	p_uploadData		IN GEC_IM_REQUEST_TP_ARRAY,
											p_uploadedBy        IN VARCHAR2,
											p_sourceCd			IN VARCHAR2)
	IS
		v_uploadedAt gec_locate_preborrow.created_at%type;
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_UPLOAD_PKG.FILL_LOCATE_PREBORROW_TEMP';
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
	
		select sysdate into v_uploadedAt from dual;
		--qry_apnd_Locate_Preborrow_temp; qry_updt_request_error; qry_update_Locate_Preborrow_temp_CLIENT_CD; qry_updt_sb_broker_cd
		INSERT INTO GEC_LOCATE_PREBORROW_temp
		  ( Locate_Preborrow_id, BUSINESS_DATE, INVESTMENT_MANAGER_CD, TRANSACTION_CD, FUND_CD, Share_Qty, CUSIP, ISIN, SEDOL, Ticker, 
		    Description, SOURCE_CD, Position_Flag, CLIENT_CD, SB_BROKER, ASSET_CODE, ASSET_CODE_TYPE, STATUS,
		    comment_txt, quik, trade_country_cd,
            TRADE_COUNTRY_ALIAS_CD,
             file_version, im_user_id ,IM_DEFAULT_FUND_CD,FUND_SOURCE,
		    IM_DEFAULT_CLIENT_CD,STRATEGY_ID,trader_request_qty,trader_approved_qty,request_id,im_request_id,im_locate_id,
		    NSB_RATE, UPDATED_BY,UPDATED_AT,CREATED_BY,CREATED_AT,ASSET_ID,indicative_rate, 
		    NSB_LOAN_NO, AGENCY_BORROW_RATE, RECLAIM_RATE, INTERNAL_COMMENT_TXT, asset_type_id)
		    SELECT (CASE WHEN irt.locate_preborrow_id IS NOT NULL AND irt.locate_preborrow_id >0 THEN irt.locate_preborrow_id ELSE gec_Locate_Preborrow_id_seq.nextval END), --to support inline edit
		           decode(irt.BUSINESS_DATE,0,null,irt.BUSINESS_DATE) BUSINESS_DATE,
		           irt.Investment_Manager_cd,
		           UPPER(irt.Transaction_cd),
		           irt.FUND_CD,
		           --If trader entry approved qty for the locate, set share qty = trader approved quantity in order to calculate the quantities conveniently.
				   --Share quantity will be recoveried at the end of the upload process.
		           (CASE WHEN irt.trader_approved_qty!=GEC_CONSTANTS_PKG.C_NULL THEN irt.trader_approved_qty ELSE irt.share_qty END) AS share_qty,
		           irt.CUSIP AS CUSIP,	
		           irt.ISIN AS ISIN,	
		           irt.SEDOL AS SEDOL,	
		           UPPER(trim(irt.Ticker)),
		           irt.Description,
		           NVL(irt.SOURCE_CD, GEC_CONSTANTS_PKG.C_IM_FILE) SOURCE_CD,
		           GEC_CONSTANTS_PKG.C_GC Position_Flag,
		           f.CLIENT_CD,  
		           f.DML_SB_Broker,
				   irt.ASSET_CODE AS ASSET_CODE, 
				   irt.ASSET_CODE_TYPE AS ASSET_CODE_TYPE,
		           (CASE 
			           	WHEN irt.status = 'X' THEN 'X'			           
						ELSE 'P' 
					END) STATUS,
					irt.comment_txt,
					irt.quik,
					decode(irt.trade_country_cd,gtca.TRADE_COUNTRY_ALIAS_CD,gtca.TRADE_COUNTRY_CD,gtca.TRADE_COUNTRY_CD,gtca.TRADE_COUNTRY_CD,irt.trade_country_cd) as trade_country_cd,
					decode(irt.trade_country_cd,gtca.TRADE_COUNTRY_CD,gtca.TRADE_COUNTRY_CD,gtc.CURRENCY_CD,gtc.TRADE_COUNTRY_CD,irt.trade_country_cd) AS GEC_TRADE_COUNTRY_ALIAS,
					irt.file_version,
					irt.im_user_id,
					irt.IM_DEFAULT_FUND_CD,
					(CASE WHEN irt.strategy_name IS NOT NULL THEN 'S' ELSE '' END) FUND_SOURCE,
					irt.IM_DEFAULT_CLIENT_CD,
					strategy.strategy_id,
					irt.share_qty AS trader_request_qty,
					(CASE WHEN irt.trader_approved_qty=GEC_CONSTANTS_PKG.C_NULL THEN NULL ELSE irt.trader_approved_qty END) AS trader_approved_qty,
					( CASE WHEN REQUEST_ID = -1 THEN NULL ELSE REQUEST_ID END ) AS REQUEST_ID,
					im_request_id,
					im_locate_id,
					999 as nsb_rate,
					p_uploadedBy AS UPDATED_BY,
					v_uploadedAt AS UPDATED_AT,
					p_uploadedBy AS CREATED_BY,
					v_uploadedAt AS CREATED_AT,
					decode(irt.asset_id,0,null,irt.asset_id) AS asset_id,
					irt.indicative_rate,
					irt.NSB_LOAN_NO,
					irt.AGENCY_BORROW_RATE,
					irt.RECLAIM_RATE,
					irt.INTERNAL_COMMENT_TXT,
					'4' as asset_type_id
		    FROM TABLE ( CAST ( p_uploadData AS GEC_IM_REQUEST_TP_ARRAY) ) irt
		    LEFT OUTER JOIN GEC_FUND f
		      ON irt.FUND_CD = f.FUND_CD
		    LEFT OUTER JOIN 
		    	( 	
		    	SELECT strategy.strategy_id, strategy.strategy_name, client.client_short_name INVESTMENT_MANAGER_CD 
		    	FROM GEC_STRATEGY strategy, GEC_CLIENT client 
		    	WHERE strategy.client_id = client.client_id
		    	  AND strategy.status = 'A' 
		    	) strategy
		      ON irt.strategy_name = strategy.strategy_name
		      	AND irt.INVESTMENT_MANAGER_CD = strategy.INVESTMENT_MANAGER_CD
            left join  
            gec_trade_country gtc
            on irt.TRADE_COUNTRY_CD=gtc.currency_cd
            left  join GEC_TRADE_COUNTRY_ALIAS gtca
            on (irt.TRADE_COUNTRY_CD=gtca.TRADE_COUNTRY_CD or irt.TRADE_COUNTRY_CD=gtca.TRADE_COUNTRY_ALIAS_CD)
		   WHERE 
		   		irt.Transaction_cd IS NULL OR UPPER(irt.Transaction_cd) != GEC_CONSTANTS_PKG.C_TRAILER;	   	
		   		

		IF ( p_sourceCd IS NOT NULL AND p_sourceCd=GEC_CONSTANTS_PKG.C_ALL_INLINE_EDIT ) THEN
				FILL_INLINE_EDIT(p_uploadData);	
		END IF;
								
		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END FILL_LOCATE_PREBORROW_TEMP;	
		
	PROCEDURE UPLOAD_IM_ORDER( p_uploadedBy        IN VARCHAR2,
		                         p_allowReUploadFlag IN VARCHAR2,
		                         p_errorCode         OUT VARCHAR2,
		                         p_errorCount        OUT NUMBER,
		                         p_trailerCount      OUT NUMBER,
		                         p_recordCount       OUT NUMBER,
		                         p_retOrders         OUT SYS_REFCURSOR,
		                         p_retSsgmLoanOrders OUT SYS_REFCURSOR,
		                         p_retLocatedIds	 OUT SYS_REFCURSOR,
		                         p_retNoMatchCancel	 OUT SYS_REFCURSOR,
		                         p_retMatchCoverSentG1 OUT SYS_REFCURSOR,
		                         p_retComment OUT SYS_REFCURSOR)
	IS
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_UPLOAD_PKG.UPLOAD_IM_ORDER';
		v_uploadedAt gec_locate_preborrow.created_at%type;
		--v_source_cd gec_locate_preborrow.source_cd%type;
		v_trailer_flag gec_fund.order_trailer%type;
		v_trailer_count NUMBER(10);
		v_row_count NUMBER(10);
		v_sb_qty gec_locate_preborrow.RESERVED_SB_QTY%TYPE;
		v_sb_ral_qty gec_locate_preborrow.SB_QTY_RAL%TYPE;
		v_nsb_qty gec_locate_preborrow.RESERVED_NSB_QTY%TYPE;
		v_nfs_qty gec_locate_preborrow.RESERVED_NFS_QTY%TYPE;
		v_ext2_qty gec_locate_preborrow.RESERVED_EXT2_QTY%TYPE;
		
		CURSOR v_cur_matched_shorts (i_business_date in number, 
									 i_investment_manager_cd in varchar2, 
									 i_client_cd in varchar2, 
									 i_fund_cd in varchar2,
									 i_asset_id in number)
		    IS
			SELECT ROWID, LOCATE_PREBORROW_ID, SHARE_QTY
			  FROM GEC_IM_ORDER_TEMP
			 WHERE BUSINESS_DATE = i_business_date
			   AND INVESTMENT_MANAGER_CD = i_investment_manager_cd
			   AND CLIENT_CD = i_client_cd
			   AND FUND_CD = i_fund_cd
			   AND ASSET_ID = i_asset_id
			   AND TRANSACTION_CD = GEC_CONSTANTS_PKG.C_SHORT;
		
		--Find all P/E locates that matches the aggregated shorts. For each P/E locate, there is no more than one row in cursor result.
		--To match short to first locate, order by locate.locate_preborrow_id (alternatively using created_at)
		--This cursor must have the same order as cursor "v_cur_unexpired_locate" in GEC_AVAILABILITY_PKG.APPLY_UNEXPIRED_LOCATE to avoid dead lock.
		CURSOR v_cur_updt_availability_orders IS 
			SELECT DISTINCT GEC_IM_AVAILABILITY.IM_Availability_ID, gec_select_short_filled_vw.Locate_Preborrow_ID,
						gec_select_short_filled_vw.restriction_cd, gec_select_short_filled_vw.position_flag, gec_select_short_filled_vw.SB_RATE, 
						gec_select_short_filled_vw.NSB_RATE, gec_select_short_filled_vw.NFS_RATE, gec_select_short_filled_vw.EXT2_RATE,
						(gec_select_short_filled_vw.Reserved_NSB_Qty) NSB_Qty,
						(gec_select_short_filled_vw.Reserved_SB_Qty) SB_Qty,
						(gec_select_short_filled_vw.SB_Qty_RAL) SB_Qty_RAL,
						(gec_select_short_filled_vw.Reserved_NFS_Qty) NFS_Qty,
						(gec_select_short_filled_vw.Reserved_EXT2_Qty) EXT2_Qty,
						(gec_select_short_filled_vw.indicative_rate) indicative_rate,
						gec_select_short_filled_vw.asset_id, gec_select_short_filled_vw.business_date, gec_select_short_filled_vw.fund_cd,
						gec_select_short_filled_vw.investment_manager_cd, gec_select_short_filled_vw.client_cd,
						DECODE( sign(GEC_SUM_OF_ORDERS_TEMP.SumOfShare_Qty - 
								     (gec_select_short_filled_vw.Reserved_SB_Qty + gec_select_short_filled_vw.SB_Qty_RAL + gec_select_short_filled_vw.Reserved_NSB_Qty
									  + gec_select_short_filled_vw.Reserved_NFS_Qty + gec_select_short_filled_vw.Reserved_EXT2_Qty
									  + GEC_IM_AVAILABILITY.SB_QTY + GEC_IM_AVAILABILITY.SB_QTY_RAL + GEC_IM_AVAILABILITY.NSB_QTY +GEC_IM_AVAILABILITY.NFS_QTY +GEC_IM_AVAILABILITY.EXT2_QTY) )
								, 1, 0, GEC_IM_AVAILABILITY.NSB_QTY) Remaining_SFP	
		         FROM  GEC_IM_AVAILABILITY,GEC_SUM_OF_ORDERS_TEMP, gec_select_short_filled_vw,GEC_TRADE_COUNTRY country
		        WHERE gec_select_short_filled_vw.BUSINESS_DATE = GEC_SUM_OF_ORDERS_TEMP.BUSINESS_DATE
				   AND gec_select_short_filled_vw.INVESTMENT_MANAGER_CD = GEC_SUM_OF_ORDERS_TEMP.INVESTMENT_MANAGER_CD
				   AND gec_select_short_filled_vw.CLIENT_CD = GEC_SUM_OF_ORDERS_TEMP.CLIENT_CD
				   AND gec_select_short_filled_vw.ASSET_ID = GEC_SUM_OF_ORDERS_TEMP.ASSET_ID
				   AND gec_select_short_filled_vw.FUND_CD = GEC_SUM_OF_ORDERS_TEMP.FUND_CD
				   AND gec_select_short_filled_vw.IM_AVAILABILITY_ID = GEC_IM_AVAILABILITY.IM_AVAILABILITY_ID
				   AND (gec_select_short_filled_vw.STATUS = 'P' OR gec_select_short_filled_vw.STATUS = 'E')
				   AND GEC_SUM_OF_ORDERS_TEMP.STATUS = 'E'
				   AND GEC_SUM_OF_ORDERS_TEMP.TRANSACTION_CD = GEC_CONSTANTS_PKG.C_SHORT
				   AND GEC_SUM_OF_ORDERS_TEMP.SumOfShare_Qty <= gec_select_short_filled_vw.Approved_Qty				   
				   AND gec_select_short_filled_vw.trade_country_cd = country.trade_country_cd
				   AND GEC_IM_AVAILABILITY.STATUS = 'A'
				   AND ( (gec_select_short_filled_vw.transaction_cd = gec_constants_pkg.C_PREBORROW AND country.PREBORROW_ELIGIBLE_FLAG='Y' )
				   		OR (gec_select_short_filled_vw.transaction_cd = gec_constants_pkg.C_LOCATE AND country.PREBORROW_ELIGIBLE_FLAG='N') ) 
				ORDER BY asset_id, business_date, fund_cd, investment_manager_cd, client_cd, gec_select_short_filled_vw.Locate_Preborrow_ID;

		CURSOR v_cur_update_order IS
			SELECT (nvl(avail.SB_QTY,0)+nvl(avail.SB_QTY_RAL,0)+nvl(avail.NSB_QTY,0)+nvl(avail.NFS_QTY,0)+nvl(avail.EXT2_QTY,0) ) as at_point_avail,
					temp.IM_ORDER_id
			  FROM GEC_IM_AVAILABILITY avail, GEC_IM_ORDER_temp temp
			 WHERE 
				avail.im_availability_id = temp.im_availability_id
				and avail.status = 'A'; 
		
		v_first char(1) := 'Y';
		v_execution_flag char(1) := 'N';
		v_last_item v_cur_updt_availability_orders%rowtype;
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
		p_errorCount := 0;
		p_errorCode := null;
		
		--open default value for OUT cursors.
		OPEN_SSGM_LOAN_FOR_ORDER(p_retSsgmLoanOrders);
		OPEN p_retLocatedIds FOR
			SELECT NULL Locate_Preborrow_ID FROM DUAL  WHERE 1=0;
		
		OPEN p_retOrders FOR
			SELECT 	NULL IM_ORDER_ID,			NULL HOLDBACK_FLAG,		NULL TRADING_DESK_CD,	NULL TRADE_COUNTRY_CD,
					NULL INVESTMENT_MANAGER_CD,	NULL STRATEGY,			NULL FUND_CD,			NULL TRANSACTION_CD,	
					NULL SB_BROKER_CD,			NULL STATUS,			NULL EXPORT_STATUS,		NULL CUSIP, 	NULL ASSET_ID,
					NULL DESCRIPTION,			NULL BROKER_CD,			NULL SHARE_QTY,			NULL FILLED_QTY,
					NULL UNFILLED_QTY,			NULL TRADE_DATE,		NULL SETTLE_DATE,		NULL G1_EXTRACTED_AT,
					NULL G1_EXTRACTED_FLAG,		NULL TICKER,			NULL SEDOL,				NULL ISIN,
					NULL QUIK,					NULL SECURITY_TYPE,		NULL RESTRICTION_ABBRV,	NULL POSITION_FLAG,
					NULL UPDATED_AT,			NULL CREATED_AT,		NULL COMMENT_TXT,		null NSB_COLLATERAL_TYPE,
					null BRANCH_CD,				NULL SHORT_IS_COVERED,  NULL RATE,				NULL SETTLEMENT_LOCATION_CD,
					NULL LEGAL_ENTITY_CD,		NULL P_SHARES_SETTLE_DATE,
					NULL COVER_IS_MATCHED,		NULL CLEAN_PRICE,		NULL DIRTY_PRICE,		NULL HAS_ALLOCATIONS
			FROM DUAL WHERE 1=0;
		OPEN_NOMATCHCANCEL (p_retNoMatchCancel);
		OPEN_MATCHCOVERSENTG1 (p_retMatchCoverSentG1);
		--clear legacy data which is upload (but not accepted) by the same user
		--delete GEC_LOCATE_PREBORROW_temp;
		
		--Remove this section for it is possible to remove the locates that are generated by "import locate".
		--There is no record with initial flag of 'Y' when upload order.

		--populate data in GEC_LOCATE_PREBORROW_temp and GEC_IM_AVAILABILITY. VB: qry_apnd_Locate_Preborrow_temp_Orders	
		--FILL_ORDER_PREBORROW_TEMP;
						
		GEC_VALIDATION_PKG.VALIDATE_IM_ORDER('Y', p_errorCode, p_retComment);
		IF(p_errorCode IS NOT NULL) THEN
			RETURN ;
		END IF;
		
		--set Corp Bond to 'X' WHICH QTY CAN'T BE UPDATE BY 1000.
		 UPDATE (SELECT giot.status, giot.comment_txt FROM GEC_IM_ORDER_TEMP giot 
                                    JOIN GEC_ASSET ga
                                    ON giot.ASSET_ID = ga.ASSET_ID
                                    AND ga.ASSET_TYPE_ID = '2'
                                    WHERE  NOT REGEXP_LIKE(giot.SHARE_QTY,'000$')
                                    	AND giot.TRANSACTION_CD IN(GEC_CONSTANTS_PKG.C_SHORT,GEC_CONSTANTS_PKG.C_COVER,GEC_CONSTANTS_PKG.C_SB_SHORT)) 
         SET status='X', COMMENT_TXT= GEC_ERROR_CODE_PKG.C_VLD_MSG_SHARE_QTY_INVALID;
                                
		
		--Update asset_id in gec_locate_preborrow_temp if the asset is found. Else, insert a new asset with source_flag 'R'
		--FILL_ASSETS_FOR_NEW_ORDERS; --DO NOT CREATE NEW ASSET ANY MORE
		
		--update the Position flag and availability flag for orders
		--qry_updt_ticker_descr_position_flag,qry_updt_avail_flag_orders
		--UPDATE_TEMP_REQUEST_BY_AVAIL;
		UPDATE_TEMP_ORDER_BY_AVAIL;
		--update orders' rate
		FILL_ORDER_WITH_GC_RATE;
		FILL_ORDERSB_WITH_GC_RATE;
		--UPDATE POSITION FLAG.
		--UPDATE_TEMP_ORDER_NO_AVAIL;



		--HANDLE ORDER CANCEL 
		HANDLE_ORDER_CANCEL;
		GET_NOMATCHCANCEL (p_retNoMatchCancel);
		GET_MATCHCOVERSENTG1 (p_retMatchCoverSentG1);

		--get sysdate
		select sysdate into v_uploadedAt from dual;

		--qry_delete_sum_of_orders
		DELETE GEC_SUM_OF_ORDERS_TEMP;
		
		--qry_apnd_sum_of_orders
		INSERT INTO GEC_SUM_OF_ORDERS_TEMP ( BUSINESS_DATE, INVESTMENT_MANAGER_CD, FUND_CD, TRANSACTION_CD,
									 STATUS, CLIENT_CD, ASSET_ID, SumOfShare_Qty )
			SELECT BUSINESS_DATE, 
					INVESTMENT_MANAGER_CD, 
					FUND_CD , 
					TRANSACTION_CD, 
					STATUS, 
					CLIENT_CD ,
					ASSET_ID, 
					Sum(Share_Qty) AS SumOfShare_Qty
			  FROM GEC_IM_ORDER_temp
			 WHERE TRANSACTION_CD = GEC_CONSTANTS_PKG.C_SHORT
			 GROUP BY BUSINESS_DATE, 
					INVESTMENT_MANAGER_CD, 
					FUND_CD, 
					CLIENT_CD, 
					ASSET_ID,
					TRANSACTION_CD, 
					STATUS;
		
		
		--qry_updt_match_borrows_orders		
		--qry_updt_IM_Availability_locates_orders
		FOR v_cur_item in v_cur_updt_availability_orders
		LOOP
			--For requirement: trader can only locate an individual security once per day for a given fund
			--Also refer to item 56 on http://collaborate/sites/GMT/gmsftprojects/omd/Lists/Requirements%20Questions/AllItems.aspx
			IF v_first = 'Y' THEN
				v_first := 'N';
				v_execution_flag := 'Y';
				v_last_item.asset_id := v_cur_item.asset_id;
				v_last_item.business_date := v_cur_item.business_date;
				v_last_item.fund_cd := v_cur_item.fund_cd;
				v_last_item.investment_manager_cd := v_cur_item.investment_manager_cd;
				v_last_item.client_cd := v_cur_item.client_cd;
			ELSE
				IF v_last_item.asset_id != v_cur_item.asset_id OR v_last_item.business_date != v_cur_item.business_date
				   OR v_last_item.fund_cd != v_cur_item.fund_cd OR v_last_item.investment_manager_cd != v_cur_item.investment_manager_cd
				   OR v_last_item.client_cd != v_cur_item.client_cd
				THEN
					v_execution_flag := 'Y';
					v_last_item.asset_id := v_cur_item.asset_id;
					v_last_item.business_date := v_cur_item.business_date;
					v_last_item.fund_cd := v_cur_item.fund_cd;
					v_last_item.investment_manager_cd := v_cur_item.investment_manager_cd;
					v_last_item.client_cd := v_cur_item.client_cd;
				ELSE
					v_execution_flag := 'N';
				END IF;
			END IF;
			
			--When find the matched first locate for shorts: 
			--1. update locate status to 'F';
			--2. update short status to 'P'; update some fields in short, eg: rate and im_availability_id (this work has been done before, but here make them accurate for 'P' shorts)
			--3. update short qty; 
			--4. bring back the qty of matched locates to associated availabilities
			IF v_execution_flag = 'Y' THEN
				--1.update locate status to 'F';
				UPDATE GEC_LOCATE_PREBORROW
				    SET STATUS = 'F'
				  WHERE Locate_Preborrow_ID = v_cur_item.Locate_Preborrow_ID;
				  
				--2. update short status to 'P'; update some fields in short
				--qry_updt_filled_locates_orders
				UPDATE GEC_IM_ORDER_TEMP
				   SET STATUS = 'P', 
						Reserved_SB_Qty = 0, 
						Reserved_NSB_Qty = 0, 
						RESERVED_SB_QTY_RAL = 0, 
						Reserved_NFS_Qty = 0, 
						Reserved_EXT2_Qty = 0,
						restriction_cd = v_cur_item.restriction_cd,
						position_flag = v_cur_item.position_flag,
						Locate_Preborrow_ID = v_cur_item.Locate_Preborrow_ID,
						im_availability_id = v_cur_item.im_availability_id
				 WHERE asset_id = v_cur_item.asset_id
				   AND business_date = v_cur_item.business_date
				   AND fund_cd = v_cur_item.fund_cd
				   AND investment_manager_cd = v_cur_item.investment_manager_cd
				   AND client_cd = v_cur_item.client_cd
				   AND status = 'E';

				--3.update short qty; Steps:
				--S1. save locate.qty to local qty variables
				--S2. open cursor on shorts matched to the locate
				--S3. for each short, exec sub-procedure to calculate the qty: update local qty variables and shorts in temp table
				v_sb_qty := v_cur_item.SB_QTY;
				v_sb_ral_qty := v_cur_item.SB_QTY_RAL;
				v_nsb_qty := v_cur_item.NSB_QTY;
				v_nfs_qty := v_cur_item.NFS_QTY;
				v_ext2_qty := v_cur_item.EXT2_QTY;
				FOR v_short in v_cur_matched_shorts(v_cur_item.business_date, v_cur_item.investment_manager_cd, v_cur_item.client_cd, v_cur_item.fund_cd, v_cur_item.asset_id)
				LOOP
					UPDATE GEC_IM_ORDER_TEMP
					   SET Reserved_SB_Qty = CASE WHEN SHARE_QTY <= v_sb_qty THEN SHARE_QTY 
					     						  ELSE v_sb_qty 
					     					 END,
					       RESERVED_SB_QTY_RAL = CASE WHEN SHARE_QTY <= v_sb_qty THEN 0
					       					 WHEN SHARE_QTY > v_sb_qty AND SHARE_QTY <= v_sb_qty+v_sb_ral_qty 
					       					 		THEN SHARE_QTY-v_sb_qty
					       					 ELSE v_sb_ral_qty
					       					 END,
					       Reserved_NSB_Qty = CASE WHEN SHARE_QTY <= v_sb_qty+v_sb_ral_qty THEN 0
					       						   WHEN SHARE_QTY > v_sb_qty+v_sb_ral_qty AND SHARE_QTY <= v_sb_qty+v_sb_ral_qty+v_nsb_qty 
					       						   		THEN SHARE_QTY-(v_sb_qty+v_sb_ral_qty)
					       						   ELSE v_nsb_qty
					       					  END,
					       Reserved_NFS_Qty = CASE WHEN SHARE_QTY <= v_sb_qty+v_sb_ral_qty+v_nsb_qty THEN 0
					       						   WHEN SHARE_QTY > v_sb_qty+v_sb_ral_qty+v_nsb_qty AND SHARE_QTY <= v_sb_qty+v_sb_ral_qty+v_nsb_qty+v_nfs_qty
					       						   		THEN SHARE_QTY-(v_sb_qty+v_sb_ral_qty+v_nsb_qty)
					       						   ELSE v_nfs_qty
					       					  END,
					       Reserved_EXT2_Qty = CASE WHEN SHARE_QTY <= v_sb_qty+v_sb_ral_qty+v_nsb_qty+v_nfs_qty THEN 0
					       						   WHEN SHARE_QTY > v_sb_qty+v_sb_ral_qty+v_nsb_qty+v_nfs_qty AND SHARE_QTY <= v_sb_qty+v_sb_ral_qty+v_nsb_qty+v_nfs_qty+v_ext2_qty
					       						   		THEN SHARE_QTY-(v_sb_qty+v_sb_ral_qty+v_nsb_qty+v_nfs_qty)
					       						   ELSE v_ext2_qty
					       					  END
					 WHERE ROWID = v_short.ROWID;

					--Update local qty qty
					SELECT v_sb_qty - Reserved_SB_Qty, v_sb_ral_qty - Reserved_SB_Qty_RAL, v_nsb_qty - Reserved_NSB_Qty,
					       v_nfs_qty - Reserved_NFS_Qty, v_ext2_qty - Reserved_EXT2_Qty
					  INTO v_sb_qty, v_sb_ral_qty, v_nsb_qty, v_nfs_qty, v_ext2_qty
					  FROM GEC_IM_ORDER_TEMP
					 WHERE ROWID = v_short.ROWID;
				END LOOP;
				
				--4. bring back the qty of matched locates to associated availabilities
				-- Comment out according to gec-1008
				 
			END IF;
		END LOOP;
		
		
		-- return matched locate id 
		OPEN p_retLocatedIds FOR
			SELECT DISTINCT Locate_Preborrow_ID
		         FROM  GEC_IM_ORDER_TEMP
		        WHERE STATUS='P' AND TRANSACTION_CD = GEC_CONSTANTS_PKG.C_SHORT
		        		AND Locate_Preborrow_ID IS NOT NULL;
		
		
		--Comment out the code rows for qty calculation, becaus the population of short qty has been done above. --Zhao Hong 20090826
		--calculate quantities in GEC_LOCATE_PREBORROW_temp and GEC_IM_AVAILABILITY
		--CALCULATE_QUANTITIES;

		--v_cur_update_preborrow
		--update set at_point_avail_qty.
		--Refer to http://collaborate/sites/GMT/gmsftprojects/gec13/Lists/Requirements%20Questions/DispForm.aspx?ID=206 
		FOR v_cur_item IN v_cur_update_order LOOP
			update 	gec_im_order_temp 
			set 	AT_POINT_AVAIL_QTY = v_cur_item.at_point_avail
			where	im_order_id = v_cur_item.im_order_id;
		END LOOP;
		
		OPEN p_retOrders FOR
			SELECT 	giot.IM_ORDER_ID,				NULL HOLDBACK_FLAG,				gtc.TRADING_DESK_CD,		giot.TRADE_COUNTRY_CD,
					giot.INVESTMENT_MANAGER_CD,		gs.STRATEGY_NAME STRATEGY,		giot.FUND_CD,				giot.TRANSACTION_CD,
					giot.SB_BROKER_CD,				giot.STATUS,					NULL EXPORT_STATUS,			giot.CUSIP,		giot.ASSET_ID,
					giot.DESCRIPTION,				null BROKER_CD,					giot.SHARE_QTY,	       		NULL FILLED_QTY,
					NULL UNFILLED_QTY,				giot.TRADE_DATE,				giot.SETTLE_DATE,			NULL G1_EXTRACTED_AT,
					NULL G1_EXTRACTED_FLAG,			giot.TICKER,					giot.SEDOL,					giot.ISIN,
					giot.QUIK,		UPPER(gat.ASSET_TYPE_DESC) SECURITY_TYPE,		r.RESTRICTION_ABBRV,		giot.POSITION_FLAG,
					giot.UPDATED_AT,				giot.CREATED_AT,				giot.COMMENT_TXT,			null NSB_COLLATERAL_TYPE,
					null BRANCH_CD,					NULL SHORT_IS_COVERED,			giot.rate,					giot.SETTLEMENT_LOCATION_CD,
					giot.LEGAL_ENTITY_CD,
					NULL COVER_IS_MATCHED,			NULL CLEAN_PRICE,				NULL DIRTY_PRICE,			NULL HAS_ALLOCATIONS,
					NULL PRICE_CURRENCY_CD,			giot.P_SHARES_SETTLE_DATE,		gf.G1_INSTANCE_CD
			FROM gec_im_order_temp giot
			LEFT JOIN GEC_TRADE_COUNTRY gtc
				ON giot.TRADE_COUNTRY_CD = gtc.TRADE_COUNTRY_CD
				LEFT JOIN GEC_ASSET_TYPE gat
				ON giot.ASSET_TYPE_ID = gat.ASSET_TYPE_ID
			    LEFT JOIN gec_fund gf
			    ON giot.FUND_CD = gf.FUND_CD
				LEFT JOIN gec_strategy gs
				ON gf.strategy_id = gs.strategy_id
				LEFT JOIN GEC_RESTRICTION r
          		ON giot.RESTRICTION_CD = r.RESTRICTION_CD;
		
		--BR27. of Allocate Supply 
		--find on-demand borrows' order which match the import order and update the proterties.

		HANDLE_NO_DEMAND_BORROW;
		--gec2.2 change
		GEC_UPLOAD_PKG.FILL_ORDER_WITH_P_SHARES_SD;		
		--delete Trailer
		DELETE GEC_IM_ORDER_TEMP WHERE UPPER(TRANSACTION_CD) = GEC_CONSTANTS_PKG.C_TRAILER;
		--insert into GEC_LOCATE_PREBORROW from GEC_LOCATE_PREBORROW_temp
		--qry_apnd_Locate_Preborrow_orders
		INSERT INTO GEC_IM_ORDER ( im_order_id,
						BUSINESS_DATE, INVESTMENT_MANAGER_CD, TRANSACTION_CD, FUND_CD, BRANCH_CD, 
            Share_Qty, ASSET_ID, ASSET_CODE, ASSET_CODE_TYPE, 
						Reserved_SB_Qty, RESERVED_SB_QTY_RAL , Reserved_NSB_Qty, 
						SOURCE_CD, RATE,
            UPDATED_BY, STATUS, COMMENT_TXT, 
            SETTLE_DATE,Position_Flag,
            SB_Broker_Cd, UPDATED_AT, 
						RESTRICTION_CD, Reserved_NFS_Qty,
            Reserved_EXT2_Qty, 
            Trade_Date, 
            CLIENT_REF_NO,
            CREATED_BY, CREATED_AT,
						CUSIP, ISIN, SEDOL, QUIK, TRADE_COUNTRY_CD,
						TICKER, DESCRIPTION, FILE_VERSION ,REQUEST_ID,
            at_point_avail_qty, strategy_id,LOCATE_PREBORROW_ID,
            asset_type_id,matched_id,SETTLEMENT_LOCATION_CD,LEGAL_ENTITY_CD,P_SHARES_SETTLE_DATE)
				SELECT  im_order_id,
						BUSINESS_DATE, INVESTMENT_MANAGER_CD, TRANSACTION_CD, FUND_CD,BRANCH_CD, 
            Share_Qty, ASSET_ID, ASSET_CODE, ASSET_CODE_TYPE, 
						Reserved_SB_Qty, RESERVED_SB_QTY_RAL , Reserved_NSB_Qty, 
						SOURCE_CD, RATE,
            UPDATED_BY, STATUS, COMMENT_TXT, 
						
            SETTLE_DATE,Position_Flag,
            SB_Broker_Cd, UPDATED_AT, 
						RESTRICTION_CD, Reserved_NFS_Qty,
            Reserved_EXT2_Qty, 
            Trade_Date, 
            CLIENT_REF_NO,
            CREATED_BY, CREATED_AT,
						CUSIP, ISIN, SEDOL, QUIK, TRADE_COUNTRY_CD,
						TICKER, DESCRIPTION, FILE_VERSION ,REQUEST_ID,
            at_point_avail_qty, strategy_id,LOCATE_PREBORROW_ID,
            asset_type_id,matched_id,SETTLEMENT_LOCATION_CD,LEGAL_ENTITY_CD,P_SHARES_SETTLE_DATE
				FROM GEC_IM_ORDER_temp;

		--qry_select_Locate_Preborrow_errors
		p_errorCount := GET_ERROR_COUNT;
		
		GET_SSGM_LOAN_FOR_ORDER( p_retSsgmLoanOrders );
		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END UPLOAD_IM_ORDER;
	
	PROCEDURE OPEN_SSGM_LOAN_FOR_ORDER( p_retSsgmLoanOrders OUT SYS_REFCURSOR )
	IS
	BEGIN
		OPEN p_retSsgmLoanOrders FOR
			select null FUND_CD, null CUSIP, null DESCRIPTION, null SHARE_QTY, null TRADE_DATE,
					null SETTLE_DATE, null SSGM_LOAN_QTY, null SSGM_TRADE_DATE, null SSGM_SETTLE_DATE
			  from dual WHERE 1=0;
	END OPEN_SSGM_LOAN_FOR_ORDER;
	
	PROCEDURE GET_SSGM_LOAN_FOR_ORDER( p_retSsgmLoanOrders OUT SYS_REFCURSOR )
	IS
	BEGIN
		OPEN p_retSsgmLoanOrders FOR
			select giot.FUND_CD, giot.CUSIP, giot.DESCRIPTION, giot.SHARE_QTY, giot.TRADE_DATE,
					giot.SETTLE_DATE, gsl.SSGM_LOAN_QTY, gsl.TRADE_DATE SSGM_TRADE_DATE, gsl.SETTLE_DATE SSGM_SETTLE_DATE
			  from GEC_IM_ORDER_TEMP giot, GEC_SSGM_LOAN gsl
			  where giot.asset_id = gsl.asset_id AND giot.TRANSACTION_CD=GEC_CONSTANTS_PKG.C_SHORT AND gsl.STATUS='O';
	END GET_SSGM_LOAN_FOR_ORDER;
	
	PROCEDURE HANDLE_ORDER_CANCEL
	IS
	
		CURSOR CUR_UPDATE_ORDER_CANCEL IS
			SELECT 	gio.im_order_id im_order_id_o ,giot.im_order_id im_order_id_t,
						case when giot.transaction_cd=GEC_CONSTANTS_PKG.C_SHORT_CANCEL and gio.export_status='I' then gio.status
							when giot.transaction_cd=GEC_CONSTANTS_PKG.C_SHORT_CANCEL and gio.export_status!='I' then 'C'
							when giot.transaction_cd=GEC_CONSTANTS_PKG.C_COVER_CANCEL then 'C' end  order_status, 
						case when giot.transaction_cd=GEC_CONSTANTS_PKG.C_SHORT_CANCEL and gio.export_status='I' then 'P'
							when giot.transaction_cd=GEC_CONSTANTS_PKG.C_SHORT_CANCEL and gio.export_status!='I' then 'M'
							when giot.transaction_cd=GEC_CONSTANTS_PKG.C_COVER_CANCEL then 'M' end  cancel_status,
						case when gio.export_status!='I' and gio.filled_qty<gio.share_qty and gio.filled_qty>0 then gio.share_qty else gio.filled_qty end order_filledQty
				FROM (
						SELECT im_order_id,transaction_cd,export_status,status,share_qty,filled_qty,
								INVESTMENT_MANAGER_CD,fund_cd,cusip,sedol,TRADE_COUNTRY_CD,SETTLE_DATE,MATCHED_ID,
								( row_number() over(partition by INVESTMENT_MANAGER_CD,transaction_cd,fund_cd,share_qty,cusip,sedol,SETTLE_DATE,GROUP_NUM,matched_id
									order by filled_qty asc,status desc
								) ) rank
						FROM GEC_IM_ORDER 
						left join (select 'E' AS TEMP_STATUS,'1' GROUP_NUM FROM DUAL	--here I apart status into 2 groups,'X','C' AND 'E','P','B'
                                UNION select 'P' AS TEMP_STATUS,'1' GROUP_NUM FROM DUAL
                                UNION select 'B' AS TEMP_STATUS,'1' GROUP_NUM FROM DUAL
                                UNION select 'X' AS TEMP_STATUS,'2' GROUP_NUM FROM DUAL
                                UNION select 'C' AS TEMP_STATUS,'2' GROUP_NUM FROM DUAL
                                )
              				ON STATUS = TEMP_STATUS
						) gio,
						
					 (  
					 	SELECT im_order_id,transaction_cd,status,share_qty,
								INVESTMENT_MANAGER_CD,fund_cd,cusip,sedol,TRADE_COUNTRY_CD,SETTLE_DATE,MATCHED_ID,
								( row_number() over(partition by INVESTMENT_MANAGER_CD,transaction_cd,fund_cd,share_qty,cusip,sedol,SETTLE_DATE,matched_id
									order by im_order_id asc 
								) ) rank
						FROM GEC_IM_ORDER_TEMP
					 	) giot,
            		GEC_IM_ORDER lock_t
				WHERE 	gio.INVESTMENT_MANAGER_CD = giot.INVESTMENT_MANAGER_CD
					and	gio.fund_cd=giot.fund_cd
					and gio.share_qty = giot.share_qty
					and (gio.cusip=giot.cusip or gio.sedol=giot.sedol)
					and (giot.TRADE_COUNTRY_CD is null or gio.TRADE_COUNTRY_CD =giot.TRADE_COUNTRY_CD)
					and gio.SETTLE_DATE =giot.SETTLE_DATE
					and gio.STATUS NOT IN('C','X')
					and gio.MATCHED_ID IS NULL
					and ((gio.TRANSACTION_CD=GEC_CONSTANTS_PKG.C_SHORT and giot.TRANSACTION_CD = GEC_CONSTANTS_PKG.C_SHORT_CANCEL)
				or (gio.TRANSACTION_CD=GEC_CONSTANTS_PKG.C_COVER and giot.TRANSACTION_CD = GEC_CONSTANTS_PKG.C_COVER_CANCEL))
					and gio.rank = giot.rank
          		and lock_t.im_order_id=gio.im_order_id
          	ORDER BY gio.im_order_id ASC
        	FOR UPDATE OF lock_t.im_order_id;
	
	BEGIN
		FOR v_item IN CUR_UPDATE_ORDER_CANCEL
		LOOP
			UPDATE GEC_IM_ORDER SET MATCHED_ID = v_item.im_order_id_t, STATUS = v_item.order_status, FILLED_QTY = v_item.order_filledQty, UPDATED_AT=SYSDATE WHERE IM_ORDER_ID=v_item.im_order_id_o;
			UPDATE GEC_IM_ORDER_TEMP SET MATCHED_ID = v_item.im_order_id_o, STATUS = v_item.cancel_status WHERE IM_ORDER_ID=v_item.im_order_id_t;
		END LOOP;
		
	END HANDLE_ORDER_CANCEL;
	
	PROCEDURE HANDLE_NO_DEMAND_BORROW
	IS
		CURSOR v_cur_matched_no_demand_borrow IS
			SELECT BORROW_ID FROM GEC_ALLOCATION 
			WHERE IM_ORDER_ID in
			    (SELECT gio.im_order_id
				from (SELECT im_order_id,FUND_CD,ASSET_ID,SHARE_QTY,SETTLE_DATE,
						row_number() over(partition by FUND_CD,ASSET_ID,SHARE_QTY,SETTLE_DATE ORDER BY IM_ORDER_ID) rank
						FROM gec_im_order 
						WHERE SOURCE_CD=GEC_CONSTANTS_PKG.C_SOURCE_DUMMY AND TRANSACTION_CD=GEC_CONSTANTS_PKG.C_SHORT
						) gio, 
					 (SELECT FUND_CD,ASSET_ID,SHARE_QTY,SETTLE_DATE,
						row_number() over(partition by FUND_CD,ASSET_ID,SHARE_QTY,SETTLE_DATE ORDER BY IM_ORDER_ID) rank
						FROM gec_im_order_temp 
						WHERE TRANSACTION_CD=GEC_CONSTANTS_PKG.C_SHORT
						)giot
			    WHERE 	gio.FUND_CD=giot.FUND_CD 
					AND gio.ASSET_ID=giot.ASSET_ID 
					AND gio.SHARE_QTY=giot.SHARE_QTY
					AND gio.SETTLE_DATE=giot.SETTLE_DATE
					AND gio.rank = giot.rank)
			order by borrow_id asc;
		
		CURSOR v_cur_matched_no_demand_order IS
		    SELECT gio.im_order_id,   giot.im_order_id im_order_id_temp,   
				giot.BUSINESS_DATE,   giot.INVESTMENT_MANAGER_CD,   giot.TRANSACTION_CD,   giot.FUND_CD, giot.BRANCH_CD,  giot.Share_Qty,   
					giot.ASSET_ID,   giot.ASSET_CODE,   giot.ASSET_CODE_TYPE,   giot.Reserved_SB_Qty,   giot.RESERVED_SB_QTY_RAL,   
					giot.Reserved_NSB_Qty,   giot.UPDATED_BY,   giot.STATUS,   giot.COMMENT_TXT,   giot.SETTLE_DATE,   giot.Position_Flag,   
					giot.SB_Broker_Cd,   giot.UPDATED_AT,   giot.RESTRICTION_CD,   giot.Reserved_NFS_Qty,   giot.Reserved_EXT2_Qty,   
					giot.SOURCE_CD,   giot.Trade_Date,   giot.CLIENT_REF_NO,   giot.CREATED_BY,   giot.CREATED_AT,   giot.CUSIP,   
					giot.ISIN,   giot.SEDOL,   giot.QUIK,   giot.TRADE_COUNTRY_CD,   giot.TICKER,   giot.DESCRIPTION,   giot.FILE_VERSION,   
					giot.REQUEST_ID,   giot.at_point_avail_qty,   giot.asset_type_id, giot.rate,giot.strategy_id,giot.LEGAL_ENTITY_CD,giot.P_SHARES_SETTLE_DATE
		     from (SELECT im_order_id,FUND_CD,ASSET_ID,SHARE_QTY,SETTLE_DATE,
						row_number() over(partition by FUND_CD,ASSET_ID,SHARE_QTY,SETTLE_DATE ORDER BY IM_ORDER_ID) rank
						FROM gec_im_order 
						WHERE SOURCE_CD=GEC_CONSTANTS_PKG.C_SOURCE_DUMMY AND TRANSACTION_CD=GEC_CONSTANTS_PKG.C_SHORT
						) gio, 
					 (SELECT temp.*,
						row_number() over(partition by FUND_CD,ASSET_ID,SHARE_QTY,SETTLE_DATE ORDER BY IM_ORDER_ID) rank
						FROM gec_im_order_temp temp
						WHERE TRANSACTION_CD=GEC_CONSTANTS_PKG.C_SHORT
						) giot
			    WHERE 	gio.FUND_CD=giot.FUND_CD 
					AND gio.ASSET_ID=giot.ASSET_ID 
					AND gio.SHARE_QTY=giot.SHARE_QTY
					AND gio.SETTLE_DATE=giot.SETTLE_DATE
					AND gio.rank = giot.rank;
		v_nodemand_flag VARCHAR(1):='Y';		
	BEGIN
		FOR v_no_demand_borrow in v_cur_matched_no_demand_borrow LOOP
			UPDATE GEC_BORROW SET NO_DEMAND_FLAG='N' 
			WHERE BORROW_ID =v_no_demand_borrow.BORROW_ID
				AND NO_DEMAND_FLAG='Y';
		END LOOP;
		
		FOR v_no_demand_short in v_cur_matched_no_demand_order LOOP
			
			BEGIN		
				SELECT 'Y' into v_nodemand_flag FROM GEC_IM_ORDER 
				WHERE  	IM_ORDER_ID=v_no_demand_short.IM_ORDER_ID
					AND SOURCE_CD=GEC_CONSTANTS_PKG.C_SOURCE_DUMMY;	
				EXCEPTION WHEN NO_DATA_FOUND THEN
					v_nodemand_flag :='N';
			END;
			
			IF v_nodemand_flag ='Y' THEN
				UPDATE GEC_IM_ORDER SET	BUSINESS_DATE = v_no_demand_short.BUSINESS_DATE,
										INVESTMENT_MANAGER_CD = v_no_demand_short.INVESTMENT_MANAGER_CD,
										TRANSACTION_CD = v_no_demand_short.TRANSACTION_CD,
										FUND_CD = v_no_demand_short.FUND_CD,
										BRANCH_CD = v_no_demand_short.BRANCH_CD,
										Share_Qty = v_no_demand_short.Share_Qty,
										ASSET_ID = v_no_demand_short.ASSET_ID,
										ASSET_CODE = v_no_demand_short.ASSET_CODE,
										ASSET_CODE_TYPE = v_no_demand_short.ASSET_CODE_TYPE,
										Reserved_SB_Qty = v_no_demand_short.Reserved_SB_Qty,
										RESERVED_SB_QTY_RAL = v_no_demand_short.RESERVED_SB_QTY_RAL,
										Reserved_NSB_Qty = v_no_demand_short.Reserved_NSB_Qty,
										UPDATED_BY = v_no_demand_short.UPDATED_BY,
										COMMENT_TXT = v_no_demand_short.COMMENT_TXT,
										SETTLE_DATE = v_no_demand_short.SETTLE_DATE,
										Position_Flag = v_no_demand_short.Position_Flag,
										SB_Broker_Cd = v_no_demand_short.SB_Broker_Cd,
										UPDATED_AT = v_no_demand_short.UPDATED_AT,
										RESTRICTION_CD = v_no_demand_short.RESTRICTION_CD,
										Reserved_NFS_Qty = v_no_demand_short.Reserved_NFS_Qty,
										Reserved_EXT2_Qty = v_no_demand_short.Reserved_EXT2_Qty,
										SOURCE_CD = v_no_demand_short.SOURCE_CD,
										Trade_Date = v_no_demand_short.Trade_Date,
										CLIENT_REF_NO = v_no_demand_short.CLIENT_REF_NO,
										CREATED_BY = v_no_demand_short.CREATED_BY,
										CREATED_AT = v_no_demand_short.CREATED_AT,
										CUSIP = v_no_demand_short.CUSIP,
										ISIN = v_no_demand_short.ISIN,
										SEDOL = v_no_demand_short.SEDOL,
										QUIK = v_no_demand_short.QUIK,
										TRADE_COUNTRY_CD = v_no_demand_short.TRADE_COUNTRY_CD,
										TICKER = v_no_demand_short.TICKER,
										DESCRIPTION = v_no_demand_short.DESCRIPTION,
										FILE_VERSION = v_no_demand_short.FILE_VERSION,
										REQUEST_ID = v_no_demand_short.REQUEST_ID,
										at_point_avail_qty = v_no_demand_short.at_point_avail_qty,
										asset_type_id = v_no_demand_short.asset_type_id,
										rate = v_no_demand_short.rate,
										strategy_id = v_no_demand_short.strategy_id,
										LEGAL_ENTITY_CD = v_no_demand_short.LEGAL_ENTITY_CD,
										P_SHARES_SETTLE_DATE = v_no_demand_short.P_SHARES_SETTLE_DATE
						WHERE IM_ORDER_ID = v_no_demand_short.IM_ORDER_ID;
				
				DELETE GEC_IM_ORDER_TEMP WHERE IM_ORDER_ID=v_no_demand_short.IM_ORDER_ID_TEMP;
				
			END IF;
		END LOOP;
	END HANDLE_NO_DEMAND_BORROW;
	
	--GMT Programs > US Equity Auto-Borrow Capability, Same Day Settlement > Change Request > Add a new column 'Rate' in Order and View aggregated demand page 
	--1. Add a  column named ‘Rate’  in Order page and Aggregated Demand page; both are display on the Short Level.
	--2. Rules for get value of rate
	--	a. First find locate for the strategy which mapped to the fund of that short for that security for the same Locate Date (Trade Date of the Short), and if found matched locate, and then populate the Rate with the Locate indicative fee.
	--	b. If multiple locates found, using the highest indicative fee of those locates
	--	c. If no matching locate found and if short security category is GC, then get this value from column  ‘GC Rate’ from this short’s fund Strategy Profile with short Trade Country
	--	d. If no matching locate found and if short security category is SP, then leave Rate as blank 
	--3. If value of GC Rate show up as text ‘GC’ in matched Locate Indicative Fee, set rate at Order and aggregated demand page with related numeric value.
	
	PROCEDURE FILL_ORDER_WITH_GC_RATE
	IS
		CURSOR v_cur_match_rate_for_order IS
			SELECT case when glp.locate_preborrow_id is null and giot.position_flag='GC' or glp.status in('X','C') then gsp.GC_RATE
	            when glp.locate_preborrow_id is null and giot.position_flag='SP' then NULL
	            when glp.locate_preborrow_id is not null then glp.indicative_rate
	            else null end as rate,
	            giot.rowid as row_id
			FROM GEC_IM_ORDER_TEMP giot
			LEFT JOIN (select strategy_id,status,locate_preborrow_id,INVESTMENT_MANAGER_CD,asset_id,trade_country_cd,business_date,to_number(indicative_rate) as indicative_rate, row_number() over(PARTITION by strategy_id,asset_id, business_date order by to_number(indicative_rate) DESC ) rank  FROM
                (select glpt.strategy_id,glpt.status,glpt.locate_preborrow_id,glpt.INVESTMENT_MANAGER_CD,glpt.asset_id,glpt.trade_country_cd,glpt.business_date, decode(glpt.indicative_rate,'GC',decode(gspT.GC_RATE,null,'GC',gspT.GC_RATE),glpt.indicative_rate) indicative_rate
                  FROM gec_locate_preborrow glpt
                  left join gec_strategy_profile gspt
                  on glpt.strategy_id=gspt.strategy_id
                  and glpt.trade_country_cd=gspt.trade_country_cd
                  and gspt.status='A'
                  and glpt.status not in('X','C')) tt 
                  where tt.indicative_rate != 'GC')glp
			ON giot.ASSET_ID = glp.ASSET_ID
			AND giot.TRADE_DATE = glp.BUSINESS_DATE
			AND giot.strategy_id = glp.strategy_id
			AND giot.trade_country_cd = glp.trade_country_cd
			AND giot.INVESTMENT_MANAGER_CD = glp.INVESTMENT_MANAGER_CD
	   		AND glp.rank=1
	   		LEFT JOIN GEC_FUND gf
	   		ON giot.FUND_CD=gf.FUND_CD
			LEFT JOIN GEC_STRATEGY_PROFILE gsp
			ON gf.STRATEGY_ID = gsp.STRATEGY_ID
			and giot.trade_country_cd=gsp.trade_country_cd
			AND gsp.status='A'
			WHERE giot.TRANSACTION_CD=GEC_CONSTANTS_PKG.C_SHORT
				  AND giot.status!='X';
	BEGIN
		FOR v_item IN v_cur_match_rate_for_order
		LOOP
			update GEC_IM_ORDER_TEMP set rate= v_item.rate where rowid=v_item.row_id;
		END LOOP;
	END FILL_ORDER_WITH_GC_RATE;
	
	PROCEDURE FILL_ORDERSB_WITH_GC_RATE
	IS
		CURSOR v_cur_match_rate_for_ordersb IS
			SELECT nvl(gar.indicative_rate,decode(giot.position_flag,'GC',gsp.GC_RATE,null)) rate,
	            giot.rowid as row_id
			FROM GEC_IM_ORDER_TEMP giot
			LEFT JOIN gec_asset_rate gar
			on giot.ASSET_ID=gar.ASSET_ID
	   		LEFT JOIN GEC_FUND gf
	   		ON giot.FUND_CD=gf.FUND_CD
			LEFT JOIN GEC_STRATEGY_PROFILE gsp
			ON gf.STRATEGY_ID = gsp.STRATEGY_ID
			and giot.trade_country_cd=gsp.trade_country_cd
			AND gsp.status='A'
			WHERE giot.TRANSACTION_CD=GEC_CONSTANTS_PKG.C_SB_SHORT
				  AND giot.status!='X';
	BEGIN
		FOR v_item IN v_cur_match_rate_for_ordersb
		LOOP
			update GEC_IM_ORDER_TEMP set rate= v_item.rate where rowid=v_item.row_id;
		END LOOP;
	END FILL_ORDERSB_WITH_GC_RATE;
	
	
	PROCEDURE OPEN_NOMATCHCANCEL (p_retNoMatchCancel	 OUT SYS_REFCURSOR)
	IS
	BEGIN
		OPEN p_retNoMatchCancel FOR
			SELECT null TRANSACTION_CD,null FUND_CD, null CUSIP, null DESCRIPTION,
					null SHARE_QTY,null TRADE_DATE, null SETTLE_DATE
			FROM DUAL WHERE 1=0;
	END OPEN_NOMATCHCANCEL;
	
	PROCEDURE OPEN_MATCHCOVERSENTG1 (p_retMatchCoverSentG1	 OUT SYS_REFCURSOR)
	IS
	BEGIN
		OPEN p_retMatchCoverSentG1 FOR
			SELECT null TRANSACTION_CD,null FUND_CD, null CUSIP, null DESCRIPTION,
					null SHARE_QTY,null TRADE_DATE, null SETTLE_DATE
			FROM DUAL WHERE 1=0;
	END OPEN_MATCHCOVERSENTG1;
	
	PROCEDURE GET_NOMATCHCANCEL (p_retNoMatchCancel	 OUT SYS_REFCURSOR)
	IS
	BEGIN
		OPEN p_retNoMatchCancel FOR
			SELECT TRANSACTION_CD, FUND_CD, CUSIP,DESCRIPTION,
					SHARE_QTY, TRADE_DATE, SETTLE_DATE
			FROM GEC_IM_ORDER_TEMP 
			WHERE MATCHED_ID IS NULL
				AND (TRANSACTION_CD=GEC_CONSTANTS_PKG.C_SHORT_CANCEL OR TRANSACTION_CD=GEC_CONSTANTS_PKG.C_COVER_CANCEL);
	END GET_NOMATCHCANCEL;
	
	PROCEDURE GET_MATCHCOVERSENTG1 (p_retMatchCoverSentG1	 OUT SYS_REFCURSOR)
	IS
	BEGIN
		OPEN p_retMatchCoverSentG1 FOR
			SELECT giot.TRANSACTION_CD,giot.FUND_CD, giot.CUSIP,giot.DESCRIPTION,
					giot.SHARE_QTY,giot.TRADE_DATE, giot.SETTLE_DATE
			FROM GEC_IM_ORDER_TEMP giot
			JOIN GEC_IM_ORDER gio
			ON giot.matched_id=gio.im_order_id
			WHERE giot.TRANSACTION_CD=GEC_CONSTANTS_PKG.C_COVER_CANCEL AND gio.TRANSACTION_CD=GEC_CONSTANTS_PKG.C_COVER
				AND gio.G1_EXTRACTED_FLAG='Y'
				AND giot.matched_id is not null;
	END GET_MATCHCOVERSENTG1;
	
	PROCEDURE FILL_ORDER_WITH_P_SHARES_SD
	IS
		CURSOR v_cur_p_shares_sd IS
    SELECT
          giot.IM_ORDER_ID,
          giot.TRADE_COUNTRY_CD,
          giot.SETTLE_DATE,
          gf.FUND_CATEGORY_CD,
          gccm.COUNTRY_CATEGORY_CD
    FROM GEC_IM_ORDER_TEMP giot
    LEFT JOIN GEC_FUND gf ON giot.FUND_CD=gf.FUND_CD
    LEFT JOIN GEC_COUNTRY_CATEGORY_MAP gccm ON giot.TRADE_COUNTRY_CD = gccm.COUNTRY_CD
    WHERE giot.ASSET_ID IS NOT NULL
          AND giot.TRANSACTION_CD not in ('COVER', 'COVER CANCEL', 'SHORT CANCEL') 
          AND giot.STATUS!='X';
    BEGIN
		FOR v_item IN v_cur_p_shares_sd
		LOOP
			IF (v_item.COUNTRY_CATEGORY_CD = 'PS1' OR  v_item.COUNTRY_CATEGORY_CD = 'PS2')
        AND v_item.FUND_CATEGORY_CD = 'OBF' THEN
        UPDATE GEC_IM_ORDER_TEMP SET P_SHARES_SETTLE_DATE= GEC_UTILS_PKG.GET_TMINUSN_NUM(v_item.SETTLE_DATE,1,v_item.TRADE_COUNTRY_CD,'S') WHERE IM_ORDER_ID=v_item.IM_ORDER_ID;
      END IF;
		END LOOP;
  	END FILL_ORDER_WITH_P_SHARES_SD;

END GEC_UPLOAD_PKG;
/


