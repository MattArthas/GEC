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
-- Dec 10, 2009    Yang, Zhao                initial
-------------------------------------------------------------------------
create or replace PACKAGE GEC_QUERY_PKG AS

	PROCEDURE QUERY_LOCATE_RESPONSE(requestsList 		IN 	GEC_IM_REQUEST_TP_ARRAY,
									imLocateRequestId  	IN 	VARCHAR2,
									p_errorCode       	OUT VARCHAR2,
									p_returned_cursor 	OUT SYS_REFCURSOR); 

	PROCEDURE GET_NEW_REQUESTS( requestsList 		IN 	GEC_IM_REQUEST_TP_ARRAY,
								imLocateRequestId  	IN 	VARCHAR2,
								imUserId 			IN 	VARCHAR2,
								p_returned_cursor 	OUT SYS_REFCURSOR); 
								
	PROCEDURE GET_ASSET_ID(
                     	 p_cusip IN VARCHAR2,
                     	 p_isin IN VARCHAR2,
                    	 p_sedol IN VARCHAR2,
                  		 p_quik IN VARCHAR2,
                   		 p_ticker IN VARCHAR2,
                   		 p_trade_country_cd IN VARCHAR2,
                    	 p_asset_code IN VARCHAR2,
                     	 p_asset_code_type IN VARCHAR2,
                    	 var_found_flag OUT NUMBER, 
                      	 var_asset_id OUT NUMBER);
	PROCEDURE GET_ASSET_LIST(
                     	 p_cusip IN VARCHAR2,
                     	 p_isin IN VARCHAR2,
                    	 p_sedol IN VARCHAR2,
                  		 p_quik IN VARCHAR2,
                   		 p_ticker IN VARCHAR2,
                   		 p_trade_country_cd IN VARCHAR2,
                    	 p_asset_code IN VARCHAR2,
                     	 p_asset_code_type IN VARCHAR2,
                    	 p_found_flag OUT NUMBER, 
                      	 p_asset_rs OUT SYS_REFCURSOR);
END GEC_QUERY_PKG;
/

create or replace PACKAGE BODY GEC_QUERY_PKG AS
	PROCEDURE QUERY_LOCATE_RESPONSE(requestsList 		IN 	GEC_IM_REQUEST_TP_ARRAY,
                            		imLocateRequestId  	IN 	VARCHAR2,
                            		p_errorCode       	OUT VARCHAR2,
                             		p_returned_cursor 	OUT SYS_REFCURSOR
                             		)
	IS 
         v_Request_ID NUMBER;
         dup_Count NUMBER;
	BEGIN 
          
		BEGIN 
			SELECT COUNT(IM_LOCATE_ID)
       		  INTO dup_Count
         	  FROM (SELECT IM_LOCATE_ID      
            	      FROM TABLE ( cast ( requestsList as GEC_IM_REQUEST_TP_ARRAY) ) IRT  
            	     GROUP BY IRT.IM_LOCATE_ID
            	    HAVING COUNT(*)>1
            );          
       EXCEPTION WHEN NO_DATA_FOUND THEN
          p_errorCode := NULL;     
       END;   
              
       IF dup_Count > 0 THEN
           p_errorCode := GEC_ERROR_CODE_PKG.C_API_DUPLICATED_LOCATE_ID;
       END IF;
       
        BEGIN
			SELECT Request_ID
              INTO v_Request_ID
			  FROM GEC_REQUEST
			 WHERE IM_REQUEST_ID = imLocateRequestId;
       
		EXCEPTION WHEN NO_DATA_FOUND THEN
			v_Request_ID := 0;
		END;   
		
		-- Judge by ImLocateId only for EZE castle request
		IF imLocateRequestId LIKE 'EZECASTLE-%' THEN
	        v_Request_ID := -1;
	    END IF;
              
		OPEN  p_returned_cursor FOR 
			 SELECT  
			 		IRT.IM_LOCATE_ID, 
					LP.LOCATE_ID AS SS_LOCATE_ID,
					LP.CUSIP,
					LP.TICKER,
					LP.DESCRIPTION AS SEC_DEC,
					LP.SHARE_QTY AS REQ_QTY, 
					LP.reserved_sb_qty + LP.sb_qty_ral + LP.reserved_nsb_qty + LP.reserved_nfs_qty + LP.reserved_ext2_qty  AS APPROVED_QTY,
					to_number(decode(lp.indicative_rate,'GC',999,lp.indicative_rate)) AS RATE,
					to_char(LP.BUSINESS_DATE) as BUSINESS_DATE,
				CASE 
					WHEN (LP.INITIAL_FLAG = 'Y' or LP.IM_LOCATE_ID is null) THEN 'Pending' 
					WHEN LP.reserved_sb_qty + LP.sb_qty_ral + LP.reserved_nsb_qty + LP.reserved_nfs_qty + LP.reserved_ext2_qty = LP.SHARE_QTY
			         	AND LP.SHARE_QTY > 0  THEN  'Approved' 
					WHEN LP.reserved_sb_qty + LP.sb_qty_ral + LP.reserved_nsb_qty + LP.reserved_nfs_qty + LP.reserved_ext2_qty < LP.SHARE_QTY 
			     		AND LP.reserved_sb_qty + LP.sb_qty_ral + LP.reserved_nsb_qty + LP.reserved_nfs_qty + LP.reserved_ext2_qty > 0 THEN 'Partial' 
					WHEN LP.STATUS = 'C' THEN  'Denied' 
					WHEN LP.STATUS = 'X' THEN  'Error'
					WHEN LP.STATUS = 'H' THEN  'Hold'
					ELSE 'CallDesk' 
				END AS STATUS,
				LP.COMMENT_TXT AS "COMMENT",
					'N'as NEW_FLAG,
					LP.TRADE_COUNTRY_ALIAS_CD AS TRADE_COUNTRY_CD,
					LP.ISIN,
					LP.SEDOL, 
					LP.QUIK
			  FROM  TABLE ( cast ( requestsList as GEC_IM_REQUEST_TP_ARRAY) ) IRT, GEC_LOCATE_PREBORROW LP
			 WHERE LP.IM_LOCATE_ID = IRT.IM_LOCATE_ID
			   AND LP.INITIAL_FLAG = 'N'
			   AND (LP.Request_ID = v_Request_ID OR v_Request_ID = -1)
			UNION
			SELECT  IRT.IM_LOCATE_ID, 
					'' as SS_LOCATE_ID,
					IRT.CUSIP,
					IRT.TICKER as TICKER,
					IRT.DESCRIPTION AS SEC_DEC,
					IRT.SHARE_QTY AS REQ_QTY, 
					0 as APPROVED_QTY,
					0 AS RATE,
					to_char(IRT.BUSINESS_DATE) as BUSINESS_DATE,
					CASE WHEN IRT.BUSINESS_DATE = GEC_UTILS_PKG.DATE_TO_NUMBER(SYSDATE) THEN 'Pending' ELSE 'Error' end as  STATUS, 
					IRT.COMMENT_TXT AS "COMMENT",
					'Y',
					IRT.TRADE_COUNTRY_CD,
					IRT.ISIN,
					IRT.SEDOL,
					IRT.QUIK
			  FROM  TABLE ( cast ( requestsList as GEC_IM_REQUEST_TP_ARRAY) ) IRT, GEC_LOCATE_PREBORROW LP
			 WHERE LP.IM_LOCATE_ID(+) = IRT.IM_LOCATE_ID
			   AND (LP.IM_LOCATE_ID is null or LP.INITIAL_FLAG = 'Y')
			   AND (LP.Request_ID = v_Request_ID OR v_Request_ID = -1);
      END QUERY_LOCATE_RESPONSE;
      
	PROCEDURE GET_NEW_REQUESTS(requestsList 	    IN 	GEC_IM_REQUEST_TP_ARRAY,
                               imLocateRequestId  	IN 	VARCHAR2,
                               imUserId 			IN 	VARCHAR2,
                               p_returned_cursor 	OUT SYS_REFCURSOR)
	IS 
        v_Request_ID NUMBER;
        v_IM_CD VARCHAR2(50); 
	BEGIN
		BEGIN 
			SELECT Request_ID
			  INTO v_Request_ID
			  FROM GEC_REQUEST
			 WHERE IM_REQUEST_ID = imLocateRequestId;    
		EXCEPTION WHEN NO_DATA_FOUND THEN
			v_Request_ID := 0;
		END;
		
		-- Judge by ImLocateId only for EZE castle request
        IF imLocateRequestId LIKE 'EZECASTLE-%' THEN
	        v_Request_ID := -1;
	    END IF;
	    
		BEGIN 
			SELECT CLIENT_SHORT_NAME
			  INTO v_IM_CD
			  FROM gec_user U, gec_client CT
			 WHERE u.client_id  = ct.client_id
			   AND u.user_id = imUserId;    
        EXCEPTION WHEN NO_DATA_FOUND THEN
			v_IM_CD := '';
		END;
        
		OPEN  p_returned_cursor FOR 
			SELECT  
				IRT.IM_LOCATE_ID, 
				IRT.CUSIP,
				IRT.SHARE_QTY AS REQ_QTY,
				IRT.BUSINESS_DATE,
				IRT.COMMENT_TXT AS "COMMENT",
				v_Request_ID as  Request_ID, 
				IRT.IM_REQUEST_ID as IM_REQUEST_ID,
				IRT.STRATEGY_NAME,
				gec_constants_pkg.C_LOCATE as transaction_Type,
				v_IM_CD as INVESTMENT_MANAGER_CD,
				IRT.STATUS,
				gec_constants_pkg.C_API_LOCATE as SOURCE_CD,
				IRT.TRADE_COUNTRY_CD,
				IRT.ISIN,
				IRT.SEDOL,
				IRT.QUIK,
				IRT.TICKER as TICKER,
				imUserId as IM_USER_ID  
			  FROM TABLE ( cast ( requestsList as GEC_IM_REQUEST_TP_ARRAY) ) IRT,    
                   (SELECT * 
                 	  FROM GEC_LOCATE_PREBORROW 
                 	 WHERE (Request_ID = v_Request_ID OR v_Request_ID = -1)
                 	) LP          
			 WHERE LP.IM_LOCATE_ID(+) = IRT.IM_LOCATE_ID
			   and LP.IM_LOCATE_ID is null;
			--   and IRT.BUSINESS_DATE = GEC_UTILS_PKG.DATE_TO_NUMBER(SYSDATE);
         
      END GET_NEW_REQUESTS;
      
	PROCEDURE GET_ASSET_ID(
                      p_cusip IN VARCHAR2,
                      p_isin IN VARCHAR2,
                     p_sedol IN VARCHAR2,
                    p_quik IN VARCHAR2,
                     p_ticker IN VARCHAR2,
                      p_trade_country_cd IN VARCHAR2,
                    p_asset_code IN VARCHAR2,
                     p_asset_code_type IN VARCHAR2,
                    var_found_flag OUT NUMBER, 
                      var_asset_id OUT NUMBER)
    IS
    	var_asset_rs GEC_ASSET_TP_ARRAY;
		var_status varchar2(1);   
    	var_asset_code_type varchar2(3);   
    	p_description VARCHAR2(50);
	BEGIN 
		GEC_VALIDATION_PKG.VALIDATE_ASSET_ID( p_cusip, 
                      p_isin  ,
                      p_sedol ,
                      p_quik ,
                     p_ticker ,
                      p_description ,
                      p_trade_country_cd ,
                      p_asset_code ,
                     p_asset_code_type,
                      var_found_flag, 
                      var_asset_code_type,
                      var_status ,
                      var_asset_rs);
		IF var_found_flag = 1 AND var_asset_rs.COUNT = 1 THEN
			var_asset_id := var_asset_rs(var_asset_rs.first).ASSET_ID;
		END IF;
	END GET_ASSET_ID;
	
	PROCEDURE GET_ASSET_LIST(
                     	 p_cusip IN VARCHAR2,
                     	 p_isin IN VARCHAR2,
                    	 p_sedol IN VARCHAR2,
                  		 p_quik IN VARCHAR2,
                   		 p_ticker IN VARCHAR2,
                   		 p_trade_country_cd IN VARCHAR2,
                    	 p_asset_code IN VARCHAR2,
                     	 p_asset_code_type IN VARCHAR2,
                    	 p_found_flag OUT NUMBER, 
                      	 p_asset_rs OUT SYS_REFCURSOR)
    IS
    	v_asset_rs GEC_ASSET_TP_ARRAY;
		v_status GEC_LOCATE_PREBORROW.STATUS%TYPE;
    	v_asset_code_type GEC_ASSET_IDENTIFIER.ASSET_CODE_TYPE%TYPE;   
    	v_description GEC_ASSET.DESCRIPTION%TYPE;
    BEGIN
		GEC_VALIDATION_PKG.VALIDATE_ASSET_ID( p_cusip, 
                      p_isin  ,
                      p_sedol ,
                      p_quik ,
                      p_ticker ,
                      v_description ,
                      p_trade_country_cd ,
                      p_asset_code ,
                      p_asset_code_type,
                      p_found_flag, 
                      v_asset_code_type,
                      v_status ,
                      v_asset_rs);
		IF p_found_flag > 0 AND v_asset_rs.COUNT > 0 THEN
			OPEN p_asset_rs FOR
				SELECT ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, SOURCE_FLAG, TRADE_COUNTRY_CD, ASSET_CODE, ASSET_CODE_TYPE
				  FROM TABLE ( CAST ( v_asset_rs AS GEC_ASSET_TP_ARRAY) ) tb
				 WHERE ASSET_ID IS NOT NULL;
		ELSE
			OPEN p_asset_rs FOR
				SELECT NULL AS ASSET_ID, 
					NULL AS CUSIP, 
					NULL AS ISIN, 
					NULL AS SEDOL, 
					NULL AS QUIK, 
					NULL AS TICKER, 
					NULL AS DESCRIPTION, 
					NULL AS SOURCE_FLAG, 
					NULL AS TRADE_COUNTRY_CD, 
					NULL AS ASSET_CODE, 
					NULL AS ASSET_CODE_TYPE
				  FROM DUAL;
		END IF;
    END GET_ASSET_LIST;
	
END GEC_QUERY_PKG;
        

/
