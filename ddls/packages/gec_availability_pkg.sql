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
-- Date            Programmer                Notes
-- ------------    --------------------      ----------------------------
-- May  6, 2009    Zhao Hong                 initial
-- 
-------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE GEC_AVAILABILITY_PKG
AS

	--The result is sorted by im_availability_id asc.
	PROCEDURE GET_AVAILABILITY_BY_REQUESTS( p_requests IN GEC_NUMBER_ARRAY,
											p_ret_cur OUT SYS_REFCURSOR );

	--This procedure is get all availabilities by the business_date/asset_id/investment_manager_cd/client_cd in gec_locate_preborrow_temp table.
	--Usually, the procedure is called by another stored procedure, such as GEC_UPLOAD_PKG.UPLOAD_IM_ORDER.
	--The result is sorted by im_availability_id asc.
	PROCEDURE GET_AVAIL_BY_TEMP_ACTIVITY( p_retAvails OUT SYS_REFCURSOR );

	--This procedure will return a availability row of null values.
	PROCEDURE OPEN_NULL_AVAIL_CURSOR( p_retAvails OUT SYS_REFCURSOR );
	
	-- get available quantity for specific im_user_id and im  		
  	-- An it return refcursor	
	PROCEDURE GET_AVAILABILITY( p_locate_list 		IN GEC_IM_REQUEST_TP_ARRAY,
	  								p_im_user_id		IN VARCHAR2,
	  								p_im				IN VARCHAR2,
	                                p_locate_list_cur 	OUT SYS_REFCURSOR );   

	--Process/Load DML availabilities
	PROCEDURE PREPARE_AVAILABILITY_TEMP( p_retAvails  OUT SYS_REFCURSOR);
	PROCEDURE UPDATE_IR_AVAILABILITY( p_avail_region IN VARCHAR2, p_fail_number OUT NUMBER );	
	PROCEDURE APPLY_UNEXPIRED_LOCATE( p_avail_region IN VARCHAR2 );
	PROCEDURE APPLY_UNACCEPT_LOCATE( p_avail_region IN VARCHAR2 );
	
	PROCEDURE GET_INDICATIVE_RATE (
							p_source_cd 			IN 	VARCHAR2,
							p_position_flag 		IN 	VARCHAR2,
							p_st_gc_rate_type 		IN 	VARCHAR2,
							p_gc_rate_type			IN 	VARCHAR2,
							p_sm_indicative_rate 	IN 	NUMBER,
							p_avail_nsb_rate        IN  NUMBER,
							p_min_sp_rate 			IN 	NUMBER,
							p_gc_rate 				IN 	NUMBER,
							p_indicative_rate		OUT VARCHAR2
							);	

	FUNCTION GET_G1_BOOKING_RATE(P_FUND_CODE IN VARCHAR2)RETURN NUMBER; 
	FUNCTION GET_NSB_RATE_FOR_AVAIL(p_position_flag IN VARCHAR2, p_min_sp_rate IN NUMBER, p_gc_rate IN NUMBER, p_nsb_rate IN NUMBER)RETURN NUMBER; 
	FUNCTION GET_INDICATE_RATE_FOR_AVAIL(p_position_flag IN VARCHAR2, p_gc_rate_type IN VARCHAR2, p_avail_nsb_rate IN NUMBER, p_gc_rate IN NUMBER)RETURN VARCHAR2;     
	
	PROCEDURE UPDATE_AVAILS_FOR_ASSET(p_assetId  IN  NUMBER);       
	          
	PROCEDURE LOAD_AVAILS_INTO_DASHBOARD(p_avail_region IN VARCHAR2);
	
	PROCEDURE UPDATE_AVAIL_FOR_BORROW(p_borrow_ids IN GEC_NUMBER_ARRAY,p_error_code	OUT VARCHAR2);
      	
    PROCEDURE PROCESS_AVPO_AVAIL_TEMP(p_legalEntityId IN GEC_NUMBER_ARRAY);                                         
                                            
END GEC_AVAILABILITY_PKG;
/

CREATE OR REPLACE PACKAGE BODY GEC_AVAILABILITY_PKG

AS

	PROCEDURE GET_AVAILABILITY_BY_REQUESTS( p_requests IN GEC_NUMBER_ARRAY,
											p_ret_cur OUT SYS_REFCURSOR )
	IS
	BEGIN
		OPEN p_ret_cur FOR
			select ia.im_availability_id, ia.asset_id, ia.business_date, ia.client_cd, ia.investment_manager_cd,
					ia.asset_code, ia.asset_code_type, ia.position_flag, ia.restriction_cd, ia.nsb_qty,
					ia.nsb_rate, ia.sb_qty, ia.sb_qty_ral, ia.sb_rate, ia.nfs_qty,
					ia.nfs_rate, ia.ext2_qty, ia.ext2_rate, ia.sb_qty_sod, ia.nsb_qty_sod,
					ia.sb_qty_ral_sod, ia.nfs_qty_sod, ia.ext2_qty_sod, ia.source_cd, ia.created_by,
					ia.created_at, ia.strategy_id, r.RESTRICTION_ABBRV,
					ASSET.CUSIP, ASSET.SEDOL, ASSET.ISIN, ASSET.TICKER, ASSET.DESCRIPTION,ia.indicative_rate, strategy.STRATEGY_NAME, gtc.TRADING_DESK_CD,
				     ia.TRADE_COUNTRY_CD,	asset.quik, ia.STRATEGY_ID, upper(gat.ASSET_TYPE_DESC) as SECURITY_TYPE,
				     DECODE(asset.LIQUIDITY_FLAG,
				     	GEC_CONSTANTS_PKG.C_LIQUID_DB,
			   		   	GEC_CONSTANTS_PKG.C_LIQUID,
			  		   	GEC_CONSTANTS_PKG.C_ILLIQUID_DB,
			  		   	GEC_CONSTANTS_PKG.C_ILLIQUID,
			  		   	null) as LIQUIDITY_FLAG
			  from gec_im_availability ia, (select distinct req.COLUMN_VALUE im_availability_id from TABLE ( cast ( p_requests as GEC_NUMBER_ARRAY) ) req ) ids,
			  		gec_asset asset, gec_restriction r,gec_strategy strategy, GEC_TRADE_COUNTRY gtc, gec_asset_type gat
			 where ia.im_availability_id = ids.im_availability_id
			   and ia.trade_country_cd = gtc.trade_country_cd	
			   and ia.strategy_id = strategy.strategy_id
			   and strategy.status = 'A'
			   and ia.asset_id = asset.asset_id
			   and ia.restriction_cd = r.restriction_cd (+)
               and asset.asset_type_id = gat.asset_type_id(+)
			 order by ia.im_availability_id asc;
	END GET_AVAILABILITY_BY_REQUESTS;

	--The query is almost the same with the query in GET_AVAILABILITY_BY_REQUESTS, except using gec_locate_preborrow_temp instead of requests
	--The qury does not use im_availability_id in locate_preborrow_temp table, because there can be multiple availabilities associated to one activity.
	PROCEDURE GET_AVAIL_BY_TEMP_ACTIVITY( p_retAvails OUT SYS_REFCURSOR )
	IS
	BEGIN
		OPEN p_retAvails FOR
			select ia.im_availability_id, ia.asset_id, ia.business_date, ia.client_cd, ia.investment_manager_cd,
					ia.asset_code, ia.asset_code_type, ia.position_flag, ia.restriction_cd, ia.nsb_qty,
					ia.nsb_rate, ia.sb_qty, ia.sb_qty_ral, ia.sb_rate, ia.nfs_qty,
					ia.nfs_rate, ia.ext2_qty, ia.ext2_rate, ia.sb_qty_sod, ia.nsb_qty_sod,
					ia.sb_qty_ral_sod, ia.nfs_qty_sod, ia.ext2_qty_sod, ia.source_cd, ia.created_by,
					ia.created_at, r.RESTRICTION_ABBRV,
					ASSET.CUSIP, ASSET.SEDOL, ASSET.ISIN, ASSET.TICKER, ASSET.DESCRIPTION,
					ia.indicative_rate, strategy.STRATEGY_NAME, gtc.TRADING_DESK_CD,
				     ia.TRADE_COUNTRY_CD,	asset.quik, ia.STRATEGY_ID, upper(gat.ASSET_TYPE_DESC) as SECURITY_TYPE
			  from gec_im_availability ia, gec_IM_ORDER_temp lpt, gec_asset_type gat,
			  		gec_asset asset, gec_restriction r, gec_strategy strategy, GEC_TRADE_COUNTRY gtc
			 where ia.im_availability_id = lpt.im_availability_id
			   and ia.trade_country_cd = gtc.trade_country_cd	
			   and ia.strategy_id = strategy.strategy_id
			   and ia.asset_id = asset.asset_id
			   and ia.restriction_cd = r.restriction_cd (+)			   
               and asset.asset_type_id = gat.asset_type_id(+)
			 order by ia.im_availability_id asc;
	END GET_AVAIL_BY_TEMP_ACTIVITY;
	
	PROCEDURE OPEN_NULL_AVAIL_CURSOR( p_retAvails OUT SYS_REFCURSOR )
	IS
	BEGIN
		OPEN p_retAvails FOR
			select null im_availability_id, null asset_id, null business_date, null client_cd, null investment_manager_cd,
					null asset_code, null asset_code_type, null position_flag, null restriction_cd, null nsb_qty,
					null nsb_rate, null sb_qty, null sb_qty_ral, null sb_rate, null nfs_qty,
					null nfs_rate, null ext2_qty, null ext2_rate, null sb_qty_sod, null nsb_qty_sod,
					null sb_qty_ral_sod, null nfs_qty_sod, null ext2_qty_sod, null source_cd, null created_by,
					null created_at, null RESTRICTION_ABBRV,
					null CUSIP, null SEDOL, null ISIN, null TICKER, null DESCRIPTION, 
					null INDICATIVE_RATE, null STRATEGY_NAME, null STRATEGY_ID, null TRADING_DESK_CD, null TRADE_COUNTRY_CD, null QUIK, null SECURITY_TYPE
			  from dual WHERE 1=0;
	END OPEN_NULL_AVAIL_CURSOR;


	-- get available quantity for specific im_user_id and im  		
  	-- An it return refcursor	
	-- TO-DO add one new patrameter p_strategy_id
	PROCEDURE GET_AVAILABILITY( p_locate_list 		IN GEC_IM_REQUEST_TP_ARRAY,
	  							p_im_user_id		IN VARCHAR2,
	  							p_im				IN VARCHAR2,
	                            p_locate_list_cur 	OUT SYS_REFCURSOR )	                       
	IS 
  		--p_locate_list_temp GEC_IM_REQUEST_TP_ARRAY;
  		v_im_default_client_cd gec_fund.client_cd%type;
  		v_im_default_fund_cd gec_fund.fund_cd%type;
  		v_strategy_name GEC_STRATEGY.STRATEGY_NAME%type; --TO-DO
  		v_today NUMBER(8);
      	v_strategy_id NUMBER;      
      	v_preborrow_tbl GEC_IM_REQUEST_TP_ARRAY;
      	v_transactionCd gec_locate_preborrow_temp.transaction_cd%type;
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_AVAILABILITY_PKG.GET_AVAILABILITY';
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
		v_today := GEC_UTILS_PKG.DATE_TO_NUMBER(SYSDATE);
		BEGIN
			SELECT STRATEGY_NAME, TRANSACTION_CD
			  INTO v_strategy_name, v_transactionCd
			  FROM TABLE ( CAST ( p_locate_list AS GEC_IM_REQUEST_TP_ARRAY) ) IRT
			 WHERE ROWNUM =1;
			  
			v_transactionCd :=NVL(v_transactionCd,GEC_CONSTANTS_PKG.C_LOCATE);
			  		
			select strategy.strategy_id  
			  into v_strategy_id
			  from gec_client cl, gec_strategy strategy
			 where cl.client_short_name = p_im
			   and cl.client_id = strategy.client_id 
			   and strategy.strategy_name = v_strategy_name
			   and strategy.status = 'A'; 
		EXCEPTION WHEN NO_DATA_FOUND THEN
		    v_strategy_id := -1;
    	END;
		
		DELETE gec_locate_preborrow_temp;
		INSERT INTO gec_locate_preborrow_temp( Locate_Preborrow_id,
						 CUSIP, ISIN, SEDOL,
						 ASSET_CODE, ASSET_CODE_TYPE, 
						 QUIK, TICKER, TRADE_COUNTRY_CD,
						 STRATEGY_ID
						 )
			SELECT gec_Locate_Preborrow_id_seq.nextval,
			            irt.CUSIP AS CUSIP,
			            irt.ISIN AS ISIN,
			           	irt.SEDOL AS SEDOL,
					    irt.asset_code AS ASSET_CODE,
				        irt.ASSET_CODE_TYPE AS ASSET_CODE_TYPE,
				        irt.quik,
				        irt.ticker,
				        irt.trade_country_cd trade_country_cd,
				        GEC_STRATEGY.STRATEGY_ID
			  FROM TABLE ( cast ( p_locate_list as GEC_IM_REQUEST_TP_ARRAY) ) irt 
                 left join      GEC_STRATEGY
            on GEC_STRATEGY.strategy_id =  v_strategy_id
            AND   GEC_STRATEGY.status = 'A';
         
        GEC_VALIDATION_PKG.FILL_REQUEST_TEMP_WITH_ASSET(v_transactionCd);

        update gec_locate_preborrow_temp
        set status = 'D'
        where comment_txt like '%' || GEC_ERROR_CODE_PKG.C_VLD_MSG_ASSET_MULTIPLE || '%';

		OPEN p_locate_list_cur FOR		
			SELECT v_today AS BUSINESS_DATE, P_IM AS INVESTMENT_MANAGER_CD, 
				v_im_default_client_cd AS CLIENT_CD, NULL TRANSACTION_CD,
				v_im_default_fund_cd AS FUND_CD, lpt.asset_id AS ASSET_ID,
				lpt.cusip AS CUSIP, lpt.isin AS ISIN,
				lpt.sedol AS SEDOL,	lpt.ticker AS TICKER, 
				(NVL(AVAIL.SB_QTY,0) + NVL(AVAIL.SB_QTY_RAL,0) + NVL(AVAIL.NSB_QTY,0) + NVL(AVAIL.EXT2_QTY,0) + NVL(AVAIL.NFS_QTY,0) ) AS SHARE_QTY, 
				lpt.DESCRIPTION AS DESCRIPTION,
				NULL AS CREATED_AT, NULL AS SOURCE_CD, NULL AS SETTLE_DATE,
				NULL AS COMMENT_TXT, lpt.quik AS QUIK, NULL AS TRADE_COUNTRY_CD, NULL AS FILE_VERSION,
				p_im_user_id AS IM_USER_ID, NULL AS LOCATE_PREBORROW_ID, lpt.ASSET_ID AS ASSET_ID, 
        avail.INDICATIVE_RATE as INDICATIVE_RATE, lpt.ASSET_CODE as ASSET_CODE, lpt.ASSET_CODE_TYPE as ASSET_TYPE,
        lpt.status  as status
		  	FROM gec_locate_preborrow_temp  lpt
		 	LEFT OUTER JOIN gec_im_availability avail
		  	ON avail.asset_id = lpt.asset_id
		  	AND avail.STRATEGY_ID = lpt.STRATEGY_ID
		  	AND avail.status ='A'
		  	AND avail.TRADE_COUNTRY_CD = lpt.TRADE_COUNTRY_CD
		 	ORDER BY  lpt.Locate_Preborrow_id;

		GEC_LOG_PKG.LOG_PERFORMANCE_END('GEC_AVAILABILITY_PKG.GET_AVAILABILITY');
	END GET_AVAILABILITY;
	
	
	
	-- Filter availabilities based on strategy;
	-- Populate values to availabilities;
	-- Insert all temp table data to persistent table
	PROCEDURE UPDATE_IR_AVAILABILITY( p_avail_region IN VARCHAR2, p_fail_number OUT NUMBER) 
	IS		
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_AVAILABILITY_PKG.UPDATE_IR_AVAILABILITY';
		v_avail_nsb_rate GEC_IM_AVAILABILITY_TEMP.NSB_RATE%TYPE := NULL;
        v_avail_indicate_rate GEC_IM_AVAILABILITY.INDICATIVE_RATE%TYPE := 'GC';
    	v_avail_restriction_cd GEC_IM_AVAILABILITY_TEMP.RESTRICTION_CD%TYPE;
    	v_avail_position_flag GEC_IM_AVAILABILITY.POSITION_FLAG%TYPE;
    	
    	v_sm_rate GEC_ASSET_RATE.INDICATIVE_RATE%TYPE;
		v_sm_position_flag GEC_ASSET_RATE.POSITION_FLAG%TYPE;
        v_sm_type GEC_ASSET_RATE.TYPE%TYPE;
        v_sm_restriction_cd GEC_ASSET_RATE.RESTRICTION_CD%TYPE;

        v_qty_zero_flag VARCHAR2(1);
        v_valid_flag VARCHAR2(1);
		
		v_liquid_percentage  GEC_STRATEGY_PROFILE.LIQUID_PERCENTAGE%TYPE;
		
		-- Search all availibilities based on strategy;
		CURSOR v_cur_avail IS
		    SELECT * FROM
				 	(SELECT ir.rowid as TEMP_ROW_ID, ir.ASSET_ID, ir.POSITION_FLAG, ir.INVESTMENT_MANAGER_CD, ir.CLIENT_CD, ir.FUND_CD, ir.TRADE_COUNTRY_CD, 
					       ir.NSB_RATE, gs.STRATEGY_ID, ir.RESTRICTION_CD,
		                   gs.GC_RATE_TYPE,
					       sp.ext2_percentage, sp.sb_percentage, sp.sfa_percentage AS nsb_percentage, 
		                   sp.surrogate_percentage AS nfs_percentage, sp.sb_ral_percentage, sp.min_sp_rate AS min_sp_rate, sp.gc_rate as gc_rate,
		                   ga.CUSIP, ga.ISIN, ga.SEDOL, ga.QUIK, ga.TICKER, ga.DESCRIPTION,
		                   ga.ASSET_TYPE_ID as ASSET_TYPE_ID,
		                   sp.ASSET_TYPES_STR as CONFIGED_ASSET_TYPES_STR,
		                  (Row_number() over(partition by ir.FUND_CD, ir.TRADE_COUNTRY_CD, ir.ASSET_ID order by ir.FUND_CD, ir.TRADE_COUNTRY_CD, ir.ASSET_ID asc) ) as row_number   
					  FROM GEC_IM_AVAILABILITY_TEMP ir, GEC_STRATEGY gs, GEC_STRATEGY_PROFILE sp, GEC_FUND gf, GEC_ASSET ga
					 WHERE gs.STRATEGY_ID = sp.STRATEGY_ID
					   AND sp.STATUS = 'A'
					   AND gs.STATUS = 'A'
					   AND ir.FUND_CD = gs.IM_DEFAULT_FUND_CD
					   AND UPPER(ir.TRADE_COUNTRY_CD) = UPPER(sp.TRADE_COUNTRY_CD)
--			           AND UPPER(ir.COLLATERAL_CURRENCY_CD) = UPPER(sp.COLLATERAL_CURRENCY_CD)
--			           AND UPPER(ir.COLLATERAL_TYPE) = UPPER(sp.COLLATERAL_TYPE)
			           AND sp.AVAILABILITY_REGIONS_STR like '%'||p_avail_region||'%'
			           AND gf.FUND_CD = ir.FUND_CD
			           AND gf.INVESTMENT_MANAGER_CD = ir.INVESTMENT_MANAGER_CD
			           AND gf.CLIENT_CD = ir.CLIENT_CD
			           AND ir.ASSET_ID = ga.ASSET_ID) qry
			           WHERE qry.row_number = 1;						  	
	    CURSOR v_cur_expire_avail IS
	        SELECT ar.row_id as row_id, ar.asset_id,ar.strategy_id
	           FROM (select gia.rowid as row_id, gia.asset_id, gia.im_availability_id,gs.strategy_id
	                   from GEC_IM_AVAILABILITY gia, GEC_STRATEGY gs, GEC_STRATEGY_PROFILE sp
	                  WHERE gia.STATUS = 'A'
	                    AND gs.STRATEGY_ID = sp.STRATEGY_ID
	               -- Expire active and inactive stragegy profile availabilities.
	                 --AND sp.STATUS = 'A'
	                 --AND gs.STATUS = 'A'
	                 AND gia.strategy_id = gs.strategy_id
	                 AND UPPER(gia.TRADE_COUNTRY_CD) = UPPER(sp.TRADE_COUNTRY_CD)
	  --                       AND UPPER(gia.COLLATERAL_CURRENCY_CD) = UPPER(sp.COLLATERAL_CURRENCY_CD)
	  --                       AND UPPER(gia.COLLATERAL_TYPE) = UPPER(sp.COLLATERAL_TYPE)
	                 AND sp.AVAILABILITY_REGIONS_STR like '%'||p_avail_region||'%'
	                 ) ar
	            WHERE 
	                 not exists (
	                 SELECT * FROM GEC_IM_AVAILABILITY_TEMP giat
	                 WHERE giat.im_availability_id=ar.im_availability_id
	                 )
	          UNION
	          -- All availabilities which not related strategy profile has been deleted.
	               SELECT gia.rowid as row_id, gia.asset_id,gia.strategy_id
	                 FROM GEC_IM_AVAILABILITY gia
	            LEFT JOIN GEC_STRATEGY_PROFILE sp
	                   ON gia.STRATEGY_ID = sp.STRATEGY_ID
	                  AND gia.trade_country_cd = sp.trade_country_cd
	                WHERE gia.status = 'A'
	                  AND sp.strategy_id IS NULL
	         --order by asset_id to avoid dead lock with other scenarios that updating availability records.
             ORDER BY asset_id,strategy_id;
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
	
		-- Delete gec asset rate which permanent is T or Null
		Delete GEC_ASSET_RATE WHERE TYPE = 'T' OR TYPE IS NULL;
   
    -- Populate values to availabilities;
    -- Rates, positon flag (GE/SP), Quantity(SB_Qty,SB_Qty_RAL,NSB_Qty,NFS_Qty,EXT2_Qty)    
    FOR v_avail IN v_cur_avail
		LOOP
      	v_qty_zero_flag := 'N';
        v_valid_flag := 'Y';
        v_avail_nsb_rate := NULL;
        v_avail_position_flag := NULL;
        v_avail_indicate_rate := NULL;
        v_avail_restriction_cd := NULL;
        v_sm_position_flag := NULL;
        v_sm_type := NULL;
        v_sm_rate := NULL;
        v_sm_restriction_cd := NULL;
        v_liquid_percentage := 1;
      BEGIN
        SELECT gar.indicative_rate, gar.position_flag, gar.type, gar.restriction_cd 
          INTO v_sm_rate, v_sm_position_flag, v_sm_type, v_sm_restriction_cd
          FROM GEC_ASSET ga, GEC_ASSET_RATE gar
          WHERE ga.asset_id = gar.asset_id
            AND ga.asset_id = v_avail.ASSET_ID
            AND gar.STATUS = 'A';
		  EXCEPTION WHEN NO_DATA_FOUND THEN
          v_sm_type := 'T';
      END;
      
      -- Examine Trade Country and Security Restriction 
--      IF v_avail.TRADE_COUNTRY_CD = 'US' THEN
--          IF v_avail.RESTRICTION_CD = '6' THEN
--              v_valid_flag := 'N';
--          END IF;
--      ELSE
--          IF v_avail.RESTRICTION_CD = '7' THEN
--              v_valid_flag := 'N';
--          END IF;
--      END IF;
	  
	  -- Examine whether the security type(asset_type) is configured in strategy profile
	  IF v_avail.ASSET_TYPE_ID IS NOT NULL AND v_avail.CONFIGED_ASSET_TYPES_STR IS NOT NULL THEN
	  	  IF (','||v_avail.CONFIGED_ASSET_TYPES_STR||',') LIKE '%'||(','||v_avail.ASSET_TYPE_ID||',')||'%' THEN
	  	  		v_valid_flag := 'Y';
	  	  ELSE
	  	  		v_valid_flag := 'N';
	  	  END IF;
	  ELSE
	  		v_valid_flag := 'N';
	  END IF;
	  
      
      IF v_valid_flag = 'Y' THEN
      
          IF v_sm_type = 'P' THEN
              -- Assign position flag for avail with sm position flag
              IF v_sm_position_flag IS NOT NULL THEN
                  v_avail_position_flag := v_sm_position_flag;
              ELSE 
                  v_avail_position_flag := v_avail.POSITION_FLAG;
              END IF;
              -- Start to assign indicate rate value
              IF v_sm_rate IS NOT NULL THEN
                  v_avail_nsb_rate := v_sm_rate;
              ELSE 
                  IF v_avail.NSB_RATE IS NOT NULL AND v_avail.NSB_RATE != 0 THEN                
                      v_avail_nsb_rate := v_avail.NSB_RATE;
                  END IF;
              END IF; 
              -- Start to assign restriction code
              IF v_sm_restriction_cd IS NOT NULL THEN
                  v_avail_restriction_cd := v_sm_restriction_cd;  
              ELSE 
                  v_avail_restriction_cd := v_avail.RESTRICTION_CD; 
              END IF; 
      
          ELSE
              -- GEC does not look at non-perm-overwrite rates in SM. 
              v_avail_position_flag := v_avail.POSITION_FLAG;
              IF v_avail.NSB_RATE IS NOT NULL AND v_avail.NSB_RATE != 0 THEN                
                  v_avail_nsb_rate := v_avail.NSB_RATE;
              END IF;
              v_avail_restriction_cd := v_avail.RESTRICTION_CD;     
          END IF; --END v_sm_type = 'P'

          IF v_avail_position_flag = 'SP' THEN
              v_qty_zero_flag := 'Y';
          END IF;
          
          -- get NSB rate based on position flag.   
          v_avail_nsb_rate := GET_NSB_RATE_FOR_AVAIL(
              v_avail_position_flag, v_avail.min_sp_rate, v_avail.gc_rate, v_avail_nsb_rate);
          
          -- get indicative rate
          v_avail_indicate_rate := GET_INDICATE_RATE_FOR_AVAIL(
              v_avail_position_flag, v_avail.GC_RATE_TYPE, v_avail_nsb_rate, v_avail.gc_rate);
          
          IF v_avail_position_flag = 'GC' THEN
              BEGIN
	              SELECT gsp.LIQUID_PERCENTAGE
	                  INTO v_liquid_percentage
	                  FROM GEC_STRATEGY_PROFILE gsp
	                  LEFT JOIN GEC_ASSET ga
	                  ON ga.trade_country_cd = gsp.trade_country_cd                                
	                  WHERE gsp.trade_country_cd = v_avail.trade_country_cd
	                	 AND gsp.STRATEGY_ID = v_avail.STRATEGY_ID
	                 	 AND ga.LIQUIDITY_FLAG = GEC_CONSTANTS_PKG.C_ILLIQUID_DB
	                	 AND ga.asset_id = v_avail.ASSET_ID;
	              EXCEPTION WHEN NO_DATA_FOUND THEN
	              	  v_liquid_percentage := 1;
          	  END;  
          END IF;
          
          UPDATE GEC_IM_AVAILABILITY_TEMP
           SET 
               --record the NSB_Rate for GEC1.8 GmbH change
           	   INDICATIVE_RATE_NUMBER = v_avail_nsb_rate, 
               POSITION_FLAG = v_avail_position_flag,
               INDICATIVE_RATE = v_avail_indicate_rate,
               RESTRICTION_CD = v_avail_restriction_cd,
           -- updated for GEC-1810, avail will be loaded even it is 'SP'
           --    SB_Qty = (CASE WHEN v_qty_zero_flag = 'Y' THEN 0 ELSE SB_Qty END) * v_avail.sb_percentage, 
           --    SB_Qty_RAL = (CASE WHEN v_qty_zero_flag = 'Y' THEN 0 ELSE SB_Qty_RAL END) * v_avail.sb_ral_percentage,
           --    NSB_Qty = (CASE WHEN v_qty_zero_flag = 'Y' THEN 0 ELSE NSB_Qty END) * v_avail.nsb_percentage, 
           --    NFS_Qty = (CASE WHEN v_qty_zero_flag = 'Y' THEN 0 ELSE NFS_Qty END) * v_avail.nfs_percentage,
           --    EXT2_Qty = (CASE WHEN v_qty_zero_flag = 'Y' THEN 0 ELSE EXT2_Qty END) * v_avail.ext2_percentage,
               SB_Qty =  SB_Qty * v_avail.sb_percentage * v_liquid_percentage, 
               SB_Qty_RAL = SB_Qty_RAL * v_avail.sb_ral_percentage * v_liquid_percentage,
               NSB_Qty = NSB_Qty * v_avail.nsb_percentage * v_liquid_percentage, 
               NFS_Qty = NFS_Qty * v_avail.nfs_percentage * v_liquid_percentage,
               EXT2_Qty = EXT2_Qty * v_avail.ext2_percentage * v_liquid_percentage,
               STRATEGY_ID = v_avail.STRATEGY_ID,
               STATUS = 'A',
               CUSIP = v_avail.CUSIP,
               SEDOL = v_avail.SEDOL,
               ISIN = v_avail.ISIN,
               QUIK = v_avail.QUIK,
               TICKER = v_avail.TICKER,
               DESCRIPTION = v_avail.DESCRIPTION
		WHERE rowid = v_avail.TEMP_ROW_ID;
           
      END IF; --END v_valid_flag = 'Y'
      
		END LOOP;
									        
		commit;
         
	    -- Insert non-matched records to GEC_AVAILABILITY_ERROR table;
		 INSERT INTO GEC_AVAILABILITY_ERROR(
			AVAILABILITY_ERROR_ID,
	        CREATED_AT,
	        BUSINESS_DATE,
	        INVESTMENT_MANAGER_CD,
	        CLIENT_CD,
	        FUND_CD,
	        CUSIP,
	        SEDOL,
	        ISIN,
	        QUIK,
	        TICKER,
	        DESCRIPTION,
	        POSITION_FLAG,
	        RESTRICTION_CD,
	        TRADE_COUNTRY_CD,
	        COLLATERAL_CURRENCY_CD,
	        COLLATERAL_TYPE,
	        SB_QTY,
	        SB_QTY_RAL,
	        NSB_QTY,
	        NFS_QTY,
	        EXT2_QTY,
	        NSB_RATE,
	        CREATED_DATETIME,
	        AVAILABILITY_REGION,
         	INDICATIVE_RATE_NUMBER
		)		  
		SELECT 
			gec_availability_error_id_seq.nextval,
			sysdate,
			BUSINESS_DATE,
			INVESTMENT_MANAGER_CD,
	        CLIENT_CD,
	        FUND_CD,
	        CUSIP,
	        SEDOL,
	        ISIN,
	        QUIK,
	        TICKER,
	        DESCRIPTION,
	        POSITION_FLAG,
	        RESTRICTION_CD,
	        TRADE_COUNTRY_CD,
	        COLLATERAL_CURRENCY_CD,
	        COLLATERAL_TYPE,
	        SB_QTY,
	        SB_QTY_RAL,
	        NSB_QTY,
	        NFS_QTY,
	        EXT2_QTY,
	        NSB_RATE,
	        CREATED_DATETIME,
	        AVAILABILITY_REGION,
        	INDICATIVE_RATE_NUMBER
		FROM GEC_IM_AVAILABILITY_TEMP WHERE STATUS = 'I';	
		
		SELECT COUNT(*) INTO p_fail_number FROM GEC_IM_AVAILABILITY_TEMP WHERE STATUS = 'I';
	    
	    -- Filter availibilities in temp table based on strategy
	    DELETE FROM GEC_IM_AVAILABILITY_TEMP WHERE STATUS = 'I';
        
        commit; 
            
		 -- Insert all temp table data to persistent table
		 INSERT INTO gec_im_availability(
		 	  IM_AVAILABILITY_ID,
			  ASSET_ID,
			  BUSINESS_DATE,
			  CLIENT_CD,
			  INVESTMENT_MANAGER_CD,
			  ASSET_CODE,
			  ASSET_CODE_TYPE,
			  POSITION_FLAG,
			  RESTRICTION_CD,
      		  INDICATIVE_RATE,
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
			  STRATEGY_ID,
			  TRADE_COUNTRY_CD,
			  STATUS,
			  COLLATERAL_CURRENCY_CD,
			  COLLATERAL_TYPE,
			  CREATED_BY,
			  CREATED_AT,
			  AVAILABILITY_REGION,
       		  INDICATIVE_RATE_NUMBER
		)		  
		SELECT 
			  IM_AVAILABILITY_ID,
			  ASSET_ID,
			  BUSINESS_DATE,
			  CLIENT_CD,
			  INVESTMENT_MANAGER_CD,
			  ASSET_CODE,
			  ASSET_CODE_TYPE,
			  POSITION_FLAG,
			  RESTRICTION_CD,
              INDICATIVE_RATE,
			  NSB_QTY,
			  NSB_RATE,
			  SB_QTY,
			  SB_QTY_RAL,
			  SB_RATE,
			  NFS_QTY,
			  0,
			  EXT2_QTY,
			  EXT2_RATE,
              -- Assign sod qty value
			  SB_QTY,
			  NSB_QTY,
			  SB_QTY_RAL,
			  NFS_QTY,
			  EXT2_QTY,
			  'System', --Source code
			  STRATEGY_ID,
			  TRADE_COUNTRY_CD,
			  'A', --Status
			  COLLATERAL_CURRENCY_CD,
			  COLLATERAL_TYPE,
			  CREATED_BY,
			  CREATED_DATETIME,
			  AVAILABILITY_REGION,
       		  INDICATIVE_RATE_NUMBER
		FROM GEC_IM_AVAILABILITY_TEMP WHERE STATUS = 'A';
		
	    -- Expire Stale Availability. Update the previous batch availabilities to set the flag to 'E'; 
	    FOR v_avail_id IN v_cur_expire_avail
	    LOOP
	         UPDATE GEC_IM_AVAILABILITY
	            SET STATUS = 'E'
	          WHERE ROWID = v_avail_id.ROW_ID;
	    END LOOP;
     
		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END UPDATE_IR_AVAILABILITY;  

	FUNCTION GET_NSB_RATE_FOR_AVAIL(p_position_flag IN VARCHAR2, p_min_sp_rate IN NUMBER, p_gc_rate IN NUMBER, p_nsb_rate IN NUMBER)RETURN NUMBER
	    IS
	      v_avail_nsb_rate GEC_IM_AVAILABILITY_TEMP.NSB_RATE%TYPE := NULL;
	    BEGIN
           -- Start to assign indicative rate based on position flag.
          IF p_position_flag = 'SP' THEN
              IF p_min_sp_rate IS NULL AND p_nsb_rate IS NULL THEN
                  v_avail_nsb_rate := 999;
              ELSE 
                  v_avail_nsb_rate := GEC_UTILS_PKG.MAX_NUMBER(p_nsb_rate, p_min_sp_rate);
              END IF;
          END IF; --END p_position_flag = 'SP'
          IF p_position_flag = 'GC' THEN
              IF p_gc_rate IS NULL AND p_nsb_rate IS NULL THEN
                  v_avail_nsb_rate := 999;
              ELSE 
                  v_avail_nsb_rate := GEC_UTILS_PKG.MAX_NUMBER(p_nsb_rate, p_gc_rate);
              END IF;              
          END IF; --END p_position_flag = 'GC'   
		  RETURN v_avail_nsb_rate;
	END GET_NSB_RATE_FOR_AVAIL;
	
	FUNCTION GET_INDICATE_RATE_FOR_AVAIL(p_position_flag IN VARCHAR2, p_gc_rate_type IN VARCHAR2, p_avail_nsb_rate IN NUMBER, p_gc_rate IN NUMBER)RETURN VARCHAR2
	    IS
	      v_avail_indicate_rate GEC_IM_AVAILABILITY.INDICATIVE_RATE%TYPE := 'GC';
	    BEGIN
          IF p_gc_rate_type = 'N' THEN
              v_avail_indicate_rate := GEC_UTILS_PKG.NUMBER_TO_CHAR(p_avail_nsb_rate);
          END IF;
          IF p_gc_rate_type = 'T' THEN
              IF p_position_flag = 'GC' AND p_avail_nsb_rate = p_gc_rate THEN
                  v_avail_indicate_rate := 'GC';
              ELSE
                  v_avail_indicate_rate := GEC_UTILS_PKG.NUMBER_TO_CHAR(p_avail_nsb_rate);
              END IF;
          END IF;   
		  RETURN v_avail_indicate_rate;
	END GET_INDICATE_RATE_FOR_AVAIL;		
	  
	FUNCTION GET_G1_BOOKING_RATE(P_FUND_CODE IN VARCHAR2)RETURN NUMBER
	    IS
	    	v_rate GEC_G1_BOOKING.RATE%TYPE := 0;
	    BEGIN
	      BEGIN
	        SELECT NVL(gb_nsb.rate, 0) gl_nsb_rate INTO v_rate
	          FROM GEC_G1_BOOKING gb_nsb
	         WHERE gb_nsb.Pos_Type = 'NSB' and gb_nsb.TRANSACTION_CD = 'G1L'
	           AND gb_nsb.fund_cd = P_FUND_CODE;
	      EXCEPTION WHEN NO_DATA_FOUND THEN
	        v_rate := 0;
	      END;
			RETURN v_rate;
	END GET_G1_BOOKING_RATE;
  
  
	PROCEDURE APPLY_UNEXPIRED_LOCATE( p_avail_region IN VARCHAR2 )
    IS		
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_AVAILABILITY_PKG.APPLY_UNEXPIRED_LOCATE';
	    v_avail_id GEC_IM_AVAILABILITY.IM_AVAILABILITY_ID%TYPE;
	    v_new_avail_id GEC_IM_AVAILABILITY.IM_AVAILABILITY_ID%TYPE;
    
    	--The "order by" has the same order as cursor "v_cur_updt_availability_orders" in procedure gec_upload_pkg.UPLOAD_IM_ORDER.
		--The purpose is to avoid dead lock: system is processing unexpired locates, while trader is uploading shorts(change locate status to 'F').
	    CURSOR v_cur_unexpired_locate IS           
	        SELECT lp.LOCATE_PREBORROW_ID, lp.ASSET_ID, lp.RESERVED_SB_QTY, lp.SB_QTY_RAL, lp.RESERVED_NSB_QTY, 
	               lp.RESERVED_NFS_QTY, lp.RESERVED_EXT2_QTY, lp.STRATEGY_ID, gia.im_availability_id, lp.TRADE_COUNTRY_CD
	          FROM GEC_LOCATE_PREBORROW lp, GEC_STRATEGY_PROFILE sp, GEC_TRADE_COUNTRY tc, GEC_IM_AVAILABILITY gia
	         WHERE lp.STRATEGY_ID = sp.strategy_id
	           AND lp.TRADE_COUNTRY_CD = sp.trade_country_cd
	           AND tc.trade_country_cd = sp.trade_country_cd
	           AND sp.availability_regions_str like '%'||p_avail_region||'%'
	           AND lp.INITIAL_FLAG = 'N'
	           AND gia.im_availability_id = lp.im_availability_id
	           AND gia.status = 'E'
	           AND lp.business_date IS NOT NULL
	           AND sysdate < GEC_UTILS_PKG.TO_BOS_TIME(to_char(lp.business_date)||tc.cutoff_time, tc.locale)
	         ORDER BY lp.asset_id, lp.business_date, lp.fund_cd, lp.investment_manager_cd, lp.client_cd, lp.Locate_Preborrow_ID;
	BEGIN	
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);

        FOR v_unexpired_locate IN v_cur_unexpired_locate
		LOOP
	       	v_avail_id := NULL;
	       	v_new_avail_id := NULL;
	        -- search the latest availibility for the locate 
	        BEGIN
			    SELECT IM_AVAILABILITY_ID INTO v_avail_id
				  FROM GEC_IM_AVAILABILITY 
			     WHERE ASSET_ID = v_unexpired_locate.ASSET_ID
				   AND STRATEGY_ID = v_unexpired_locate.STRATEGY_ID
				   AND TRADE_COUNTRY_CD = v_unexpired_locate.TRADE_COUNTRY_CD
		           AND STATUS = 'A'
		           AND ROWNUM = 1
		           -- add RX lock.
		           FOR UPDATE OF GEC_IM_AVAILABILITY.IM_AVAILABILITY_ID;
	        EXCEPTION WHEN NO_DATA_FOUND THEN
	            -- Insert non-existing avail
				select GEC_IM_Availability_id_seq.nextval into v_new_avail_id from dual;
	            INSERT INTO  GEC_IM_AVAILABILITY  
	                        (IM_Availability_id,   Business_Date,    INVESTMENT_MANAGER_CD,  CLIENT_CD,
	                          ASSET_CODE,           ASSET_CODE_TYPE,  ASSET_ID,               Position_flag, 
	                          NSB_Rate,             NFS_qty,          NFS_rate,				 source_cd,
	                          strategy_id,		  trade_country_cd, 	  STATUS,  			INDICATIVE_RATE,    
	                          CREATED_AT )              -- COLLATERAL_CURRENCY_CD, COLLATERAL_TYPE,   INDICATIVE_RATE,     CREATED_AT)
	            SELECT v_new_avail_id,   qry.Business_Date,	qry.INVESTMENT_MANAGER_CD,  qry.CLIENT_CD,
	                    qry.ASSET_CODE,           qry.ASSET_CODE_TYPE,  			qry.ASSET_ID,               qry.Position_flag, 
	                    qry.NSB_Rate,             qry.NFS_qty,          			qry.NFS_rate,				        'LOCATE',
	                    qry.strategy_id,		  qry.trade_country_cd,           'A',	                     qry.INDICATIVE_RATE,               
	                    SYSDATE    ---qry.COLLATERAL_CURRENCY_CD,qry.COLLATERAL_TYPE
	             FROM( SELECT lp.Business_Date, f.INVESTMENT_MANAGER_CD, f.CLIENT_CD, lp.ASSET_CODE, lp.ASSET_CODE_TYPE, 
	                             lp.ASSET_ID, 'GC' AS Position_Flag, 999 AS NSB_Rate, 0 AS NFS_Qty, 0.35 AS NFS_Rate,
	                             lp.strategy_id, lp.trade_country_cd, --gsp.collateral_currency_cd, gsp.collateral_type, 
	                             '999' AS INDICATIVE_RATE	
	                     FROM GEC_locate_preborrow lp, gec_fund f, GEC_STRATEGY_PROFILE gsp
	                    WHERE lp.LOCATE_PREBORROW_ID = v_unexpired_locate.LOCATE_PREBORROW_ID
	                      AND lp.fund_cd = f.fund_cd
	                      AND lp.strategy_id = gsp.strategy_id
	                      AND lp.trade_country_cd = gsp.trade_country_cd
	                ) qry;
			    v_avail_id := v_new_avail_id;
			END; 
	         
		   -- update avail qty
		   UPDATE GEC_IM_AVAILABILITY
		   SET 				   
	             SB_Qty = SB_Qty - v_unexpired_locate.RESERVED_SB_QTY, 
	             SB_Qty_RAL = SB_Qty_RAL - v_unexpired_locate.SB_QTY_RAL, 
	             NSB_Qty = NSB_Qty - v_unexpired_locate.RESERVED_NSB_QTY, 
	             NFS_Qty = NFS_Qty - v_unexpired_locate.RESERVED_NFS_QTY, 
	             EXT2_Qty = EXT2_Qty - v_unexpired_locate.RESERVED_EXT2_QTY
		   WHERE im_availability_id = v_avail_id;
		   
		   -- change locate foreign key for availibility
		   UPDATE GEC_LOCATE_PREBORROW
		      SET IM_AVAILABILITY_ID = v_avail_id
		    WHERE LOCATE_PREBORROW_ID = v_unexpired_locate.LOCATE_PREBORROW_ID;
		END LOOP;
			
		-- Apply un-accept locates, change locate foreign key for current availibility
	    APPLY_UNACCEPT_LOCATE(p_avail_region);
	     
		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END APPLY_UNEXPIRED_LOCATE;  
	
	-- Populate asset id, trade country code to availability temp table
	PROCEDURE PREPARE_AVAILABILITY_TEMP (p_retAvails  OUT SYS_REFCURSOR)
    IS
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_AVAILABILITY_PKG.PREPARE_AVAILABILITY_TEMP';
		v_tc gec_im_availability_temp.trade_country_cd%TYPE := NULL;
		v_asset_id gec_im_availability_temp.asset_id%TYPE;
           
        -- Search all availibilities;
		CURSOR v_cur_avail IS
			SELECT ir.rowid as TEMP_ROW_ID, ir.cusip, ir.sedol, ir.isin, ir.quik, ir.ticker, ir.trade_country_cd
			  FROM GEC_IM_AVAILABILITY_TEMP ir;
      
    BEGIN
    	commit;
    	
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);

      FOR v_avail IN v_cur_avail
      LOOP
      	v_tc := trim(v_avail.trade_country_cd);
      	v_asset_id := NULL;

        BEGIN
          SELECT GTC.TRADE_COUNTRY_CD INTO v_tc
            FROM GEC_TRADE_COUNTRY gtc
           WHERE gtc.CURRENCY_CD = v_avail.trade_country_cd;
        EXCEPTION WHEN NO_DATA_FOUND THEN
          v_tc := NULL;
        END;
        
        BEGIN
            SELECT asset_id INTO v_asset_id FROM GEC_ASSET WHERE CUSIP=v_avail.cusip;
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN
                v_asset_id := NULL;
            WHEN OTHERS THEN
                v_asset_id := NULL;
        END;
        
        UPDATE GEC_IM_AVAILABILITY_TEMP
           SET TRADE_COUNTRY_CD = v_tc,
               ASSET_ID = v_asset_id
         WHERE ROWID = v_avail.TEMP_ROW_ID; 

        END LOOP;
        	
       	commit;
       	
        OPEN p_retAvails FOR
			SELECT DISTINCT
	             temp.business_date,
	             temp.cusip,
	             temp.isin,
	             temp.sedol,
	             temp.ticker,
	             temp.quik,
	             temp.description,
	             temp.trade_country_cd,
	             temp.position_flag,
		   		 UPPER(gat.asset_type_desc) as SECURITY_TYPE
		  FROM   GEC_IM_AVAILABILITY_TEMP  temp
		  LEFT JOIN GEC_ASSET_TYPE gat
		  ON gat.asset_type_id = temp.asset_type_id
       	  WHERE  temp.asset_id IS NULL
		ORDER BY temp.business_date, temp.cusip;
		 
		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END PREPARE_AVAILABILITY_TEMP; 
	
	PROCEDURE APPLY_UNACCEPT_LOCATE( p_avail_region IN VARCHAR2 )
    IS		
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_AVAILABILITY_PKG.APPLY_UNACCEPT_LOCATE';
	    v_avail_id GEC_IM_AVAILABILITY.IM_AVAILABILITY_ID%TYPE;
           
	    CURSOR v_cur_unaccept_locate IS
	        SELECT lp.ROWID AS LOCATE_ROW_ID, lp.ASSET_ID, lp.RESERVED_SB_QTY, lp.SB_QTY_RAL, lp.RESERVED_NSB_QTY, 
	               lp.RESERVED_NFS_QTY, lp.RESERVED_EXT2_QTY, lp.STRATEGY_ID, gia.im_availability_id, lp.TRADE_COUNTRY_CD
	          FROM GEC_LOCATE_PREBORROW lp, GEC_STRATEGY_PROFILE sp, GEC_TRADE_COUNTRY tc, GEC_IM_AVAILABILITY gia
	         WHERE lp.STRATEGY_ID = sp.strategy_id
	           AND lp.TRADE_COUNTRY_CD = sp.trade_country_cd
	           AND tc.trade_country_cd = sp.trade_country_cd
	           AND sp.availability_regions_str like '%'||p_avail_region||'%'
	           AND lp.INITIAL_FLAG = 'Y'
	           AND gia.im_availability_id = lp.im_availability_id
	           AND gia.status = 'E'
	         ORDER BY lp.locate_preborrow_id;
               
	BEGIN	
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);

        FOR v_unaccept_locate IN v_cur_unaccept_locate
	    LOOP
	       	v_avail_id := NULL;
	        -- search the latest availibility for the locate 
	        BEGIN
			    SELECT IM_AVAILABILITY_ID INTO v_avail_id
				  FROM GEC_IM_AVAILABILITY 
				 WHERE ASSET_ID = v_unaccept_locate.ASSET_ID
				   AND STRATEGY_ID = v_unaccept_locate.STRATEGY_ID
				   AND TRADE_COUNTRY_CD = v_unaccept_locate.TRADE_COUNTRY_CD
	               AND STATUS = 'A'
	               AND ROWNUM = 1;
	        EXCEPTION WHEN NO_DATA_FOUND THEN
			    v_avail_id := NULL;
			END; 
				   
	        -- change locate foreign key for availibility
			UPDATE GEC_LOCATE_PREBORROW
			   SET IM_AVAILABILITY_ID = v_avail_id
			 WHERE ROWID = v_unaccept_locate.LOCATE_ROW_ID;
	    END LOOP;
      
		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END APPLY_UNACCEPT_LOCATE;  

	PROCEDURE GET_INDICATIVE_RATE (
								p_source_cd 			IN 	VARCHAR2,
								p_position_flag 		IN 	VARCHAR2,
								p_st_gc_rate_type 		IN 	VARCHAR2,
								p_gc_rate_type			IN 	VARCHAR2,
								p_sm_indicative_rate 	IN 	NUMBER,
								p_avail_nsb_rate        IN  NUMBER,
								p_min_sp_rate 			IN 	NUMBER,
								p_gc_rate 				IN 	NUMBER,
								p_indicative_rate		OUT VARCHAR2
								)
	IS
		v_position_flag GEC_ASSET_RATE.POSITION_FLAG%TYPE := NULL;
		v_idicative_rate_num GEC_IM_AVAILABILITY.NSB_RATE%TYPE := NULL;
	BEGIN
		
		v_position_flag := nvl(p_position_flag, 'GC');
		
		IF p_sm_INDICATIVE_RATE IS NULL AND p_avail_nsb_rate IS NULL THEN
			p_indicative_rate := GEC_CONSTANTS_PKG.C_DEFAULT_INDICATIVE_RATE;
		ELSE
			-- To fix GEC-1854 (when nsb rate is zero should be treated as null)
			IF p_sm_INDICATIVE_RATE IS NULL AND p_avail_nsb_rate = 0 THEN
				v_idicative_rate_num := GET_NSB_RATE_FOR_AVAIL(v_position_flag,p_min_sp_rate,p_gc_rate,NULL);
			ELSE
				v_idicative_rate_num := GET_NSB_RATE_FOR_AVAIL(v_position_flag,p_min_sp_rate,p_gc_rate,nvl(p_sm_INDICATIVE_RATE,p_avail_nsb_rate));
			END IF;
			
			IF p_source_cd in (gec_constants_pkg.C_API_LOCATE,gec_constants_pkg.C_FA_SMAC_REQUEST,gec_constants_pkg.C_FA_GSMAC_REQUEST,gec_constants_pkg.C_FA_REQUEST,gec_constants_pkg.C_IM_FILE) THEN
				p_indicative_rate := GET_INDICATE_RATE_FOR_AVAIL(v_position_flag, p_st_gc_rate_type, v_idicative_rate_num,p_gc_rate);
			ELSE
				p_indicative_rate := GET_INDICATE_RATE_FOR_AVAIL(v_position_flag, p_gc_rate_type, v_idicative_rate_num,p_gc_rate);
			END IF;
		END IF;			
	END GET_INDICATIVE_RATE;					

	PROCEDURE UPDATE_AVAILS_FOR_ASSET( p_assetId IN  NUMBER)
	IS
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_AVAILABILITY_PKG.UPDATE_AVAILS_FOR_ASSET';
		v_gc_rate_type GEC_STRATEGY.gc_rate_type%TYPE := NULL;
		v_gc_rate GEC_STRATEGY_PROFILE.gc_rate%TYPE := NULL;
		v_min_sp_rate GEC_STRATEGY_PROFILE.min_sp_rate%TYPE := NULL;

		v_avail_nsb_rate GEC_IM_AVAILABILITY.nsb_rate%TYPE;
		v_avail_indicative_rate GEC_IM_AVAILABILITY.indicative_rate%TYPE;
		v_avail_position_flag GEC_IM_AVAILABILITY.position_flag%TYPE := NULL;
		
		v_sm_indicative_rate GEC_ASSET_RATE.indicative_rate%TYPE := NULL;
		v_sm_position_flag GEC_ASSET_RATE.position_flag%TYPE := NULL;
		v_sm_restriction_cd GEC_ASSET_RATE.restriction_cd%TYPE := NULL;
		v_sm_internal_comment_txt GEC_ASSET_RATE.internal_comment_txt%TYPE := '';
		v_sm_cty_cd GEC_ASSET.trade_country_cd%TYPE := NULL;
				
		CURSOR v_cur_avail IS
		    SELECT gia.ROWID as AVAIL_ROW_ID, gia.strategy_id, gia.TRADE_COUNTRY_CD, gia.NSB_RATE, gia.POSITION_FLAG
			  FROM GEC_IM_AVAILABILITY gia
			 WHERE gia.asset_id = p_assetId
			   AND gia.status = 'A'
			   order by gia.strategy_id asc;
	BEGIN
		
		SELECT gar.indicative_rate, gar.position_flag, gar.restriction_cd, gar.internal_comment_txt, ga.trade_country_cd
			   into
			   v_sm_indicative_rate, v_sm_position_flag, v_sm_restriction_cd, v_sm_internal_comment_txt, v_sm_cty_cd
	      FROM GEC_ASSET ga
	 LEFT JOIN GEC_ASSET_RATE gar
	        ON ga.asset_id = gar.asset_id	
	     WHERE ga.asset_id= p_assetId;  
    
		FOR v_avail in v_cur_avail LOOP
			v_avail_nsb_rate := NULL;
			v_avail_indicative_rate := NULL;
			v_gc_rate_type := NULL;
			v_gc_rate := NULL;
			v_min_sp_rate := NULL;
			v_avail_position_flag := NULL;
      
			v_avail_position_flag := nvl(v_sm_position_flag, v_avail.POSITION_FLAG);
			IF v_avail_position_flag IS NULL THEN
				v_avail_position_flag := 'GC';
			END IF;
			
			BEGIN						    
			    SELECT gs.gc_rate_type, gsp.gc_rate, gsp.min_sp_rate 
			    	   into
			    	   v_gc_rate_type, v_gc_rate, v_min_sp_rate
			      FROM GEC_STRATEGY gs
	         LEFT JOIN GEC_STRATEGY_PROFILE gsp
	                on gs.STRATEGY_ID = gsp.STRATEGY_ID
	               and gsp.TRADE_COUNTRY_CD = v_avail.TRADE_COUNTRY_CD
	               AND gsp.status ='A'
			     WHERE gs.strategy_id = v_avail.strategy_id
	               AND gs.status = 'A';  			   
			EXCEPTION WHEN NO_DATA_FOUND THEN
	        	v_gc_rate_type := NULL;
	        END;  
        	
        	IF  v_gc_rate_type IS NOT NULL THEN      			
				--IF v_sm_indicative_rate IS NULL AND v_avail.NSB_RATE IS NULL THEN
				--	v_avail_nsb_rate := GEC_CONSTANTS_PKG.C_DEFAULT_NSB_RATE;
				--	v_avail_indicative_rate := GEC_CONSTANTS_PKG.C_DEFAULT_INDICATIVE_RATE;
				--ELSE
					-- refer to GEC-1639 (If sm indicative fee is blank, use strategy profile rate)
					v_avail_nsb_rate := gec_availability_pkg.GET_NSB_RATE_FOR_AVAIL(
											v_avail_position_flag, 
											v_min_sp_rate, 
											v_gc_rate, 
											v_sm_indicative_rate);
					v_avail_indicative_rate := gec_availability_pkg.GET_INDICATE_RATE_FOR_AVAIL(
											v_avail_position_flag, 
											v_gc_rate_type, 
											v_avail_nsb_rate, 
											v_gc_rate);
				--END IF;
				
				UPDATE GEC_IM_AVAILABILITY
				  SET
				    -- No need to upate availability nsb rate when update SM. (refer to GEC-1681) 
				  	--NSB_RATE = v_avail_nsb_rate,
					INDICATIVE_RATE = v_avail_indicative_rate,
					POSITION_FLAG = v_avail_position_flag,
					RESTRICTION_CD = nvl(v_sm_restriction_cd, RESTRICTION_CD),
					INTERNAL_COMMENT_TXT = nvl(v_sm_internal_comment_txt, INTERNAL_COMMENT_TXT)
				WHERE rowid = v_avail.AVAIL_ROW_ID;				
			END IF;	
		END LOOP;	
          
		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END UPDATE_AVAILS_FOR_ASSET;	
	
	PROCEDURE LOAD_AVAILS_INTO_DASHBOARD(p_avail_region IN VARCHAR2)
  	IS	
    
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_AVAILABILITY_PKG.LOAD_AVAILS_INTO_AVAIL_BY_CUSIP';    
    
  	BEGIN	
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
   
	    UPDATE GEC_LENDER_AVAILABILITY
	    SET STATUS = 'I'
	    WHERE SOURCE_CD = 'SFA'
	    AND (FUND_CD NOT IN (SELECT FUND_CD FROM GEC_SFA_AVAIL_FILTER) AND FUND_CD IS NOT NULL) OR (FUND_CD IN (SELECT FUND_CD FROM GEC_SFA_AVAIL_FILTER WHERE AVAILABILITY_REGION = p_avail_region));
	       
	      
	    INSERT INTO GEC_LENDER_AVAILABILITY(
			 	  LENDER_AVAILABILITY_ID,
				  ASSET_ID,
				  BROKER_CD,
				  LEGAL_ENTITY_ID,
				  AVAIL_QTY,
				  INDICATIVE_RATE,
				  FUND_CD,
				  RECLAIM_RATE,
				  CREATED_DATETIME,
	        	  STATUS,
				  CREATED_AT,
				  CREATED_BY,
				  SOURCE_CD,			  
				  POSITION_FLAG,
				  RESTRICTION_CD,
	        	  ORDER_EXP_DATE,
          		  LEGAL_ENTITY_CD,
          		  INDICATIVE_RATE_NUMBER
			)		  
			SELECT 
	         GEC_LENDER_AVAILABILITY_ID_SEQ.nextval as LENDER_AVAILABILITY_ID,
	         GEC_ASSET.asset_id as ASSET_ID, 
	         null as BROKER_CD,
	         null as LEGAL_ENTITY_ID,
	         ia.NSB_QTY + ia.NFS_QTY as AVAIL_QTY,
	         ia.INDICATIVE_RATE as INDICATIVE_RATE, 
	         gs.IM_DEFAULT_FUND_CD as FUND_CD,
	         null as RECLAIM_RATE,
	         ia.CREATED_AT as CREATED_DATETIME,
	         'A' as STATUS,
	         ia.CREATED_AT as CREATED_AT,
	         ia.SOURCE_CD as CREATED_BY,
	         'SFA' as SOURCE_CD,           
	         ia.POSITION_FLAG as POSITION_FLAG,
	         ia.RESTRICTION_CD as RESTRICTION_CD,
	         null as ORDER_EXP_DATE,
	         gf.LEGAL_ENTITY_CD,
	         ia.INDICATIVE_RATE_NUMBER as INDICATIVE_RATE_NUMBER
	      FROM GEC_IM_AVAILABILITY ia, GEC_ASSET , GEC_CLIENT gc, GEC_STRATEGY gs, GEC_STRATEGY_PROFILE gsp,
			       GEC_FUND gf, GEC_TRADE_COUNTRY gtc, GEC_RESTRICTION r, GEC_ASSET_TYPE gat, GEC_SFA_AVAIL_FILTER gsaf
	       WHERE gc.client_status = 'A'
			   AND gc.CLIENT_TYPE = 'EXT'
			   AND gs.client_id = gc.client_id 
			   AND gs.status = 'A'
			   AND gs.IM_DEFAULT_FUND_CD = gf.FUND_CD 
			   AND gc.CLIENT_SHORT_NAME = gf.INVESTMENT_MANAGER_CD
			   AND gsp.strategy_id = gs.strategy_id
			   AND gsp.status = 'A'
			   AND gtc.trade_country_cd = gsp.trade_country_cd
			   AND gtc.status = 'A'
			   AND gsp.strategy_id = ia.strategy_id
			   AND gc.CLIENT_SHORT_NAME = ia.INVESTMENT_MANAGER_CD
			   AND ia.status = 'A'
			   AND gsp.trade_country_cd = ia.trade_country_cd
			   AND ia.CLIENT_CD = gf.CLIENT_CD
			   AND ia.asset_id = GEC_ASSET.asset_id
			   AND ia.RESTRICTION_CD = r.RESTRICTION_CD (+)
			   AND GEC_ASSET.ASSET_TYPE_ID = gat.ASSET_TYPE_ID 
	       	   AND ia.AVAILABILITY_REGION = p_avail_region
	       	   AND ia.AVAILABILITY_REGION = gsaf.AVAILABILITY_REGION
	       	   AND gsaf.FUND_CD = gs.IM_DEFAULT_FUND_CD
	       	   AND ((instr(','||gsaf.TRADE_COUNTRY_CDS||',',','||ia.trade_country_cd||',')>0 and 
	                gsaf.STATUS = 'W') 
	                OR
	                (instr(','||gsaf.TRADE_COUNTRY_CDS||',',','||ia.trade_country_cd||',')=0 and 
	                gsaf.STATUS = 'B'));
      
    	GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END LOAD_AVAILS_INTO_DASHBOARD;	
  
    PROCEDURE UPDATE_AVAIL_FOR_BORROW(p_borrow_ids IN GEC_NUMBER_ARRAY
                                    ,p_error_code	OUT VARCHAR2)
  	IS
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_AVAILABILITY_PKG.UPDATE_AVAIL_FOR_BORROW';  
		v_broker_cd VARCHAR2(6);
		v_borrow_qty NUMBER;
		v_asset_id NUMBER;
		v_broker_request_type VARCHAR2(10);
		v_lender_availability_id NUMBER;
		v_avail_qty NUMBER;
		v_not_exist VARCHAR(1);
		v_brw_map_exist VARCHAR(1);
    	v_souce_cd VARCHAR2(10);
    	c_source_cd_null VARCHAR2(20);
  		CURSOR BORROW_IDS IS
            SELECT borrows.COLUMN_VALUE
            FROM TABLE ( cast ( p_borrow_ids as GEC_NUMBER_ARRAY) ) borrows; 
  	BEGIN
	    GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
	    FOR V_BORROW_ID IN BORROW_IDS
	    LOOP
	      	v_broker_cd := null;
		    v_borrow_qty := null;
		    v_asset_id := null;
		    v_broker_request_type := null;
		    v_avail_qty := null;
		    v_not_exist := 'N';
		    v_brw_map_exist := 'N';
        	v_souce_cd := null;
        	c_source_cd_null := 'C_SOURCE_CD_NULL_STR';
	     	BEGIN
		      SELECT GBO.ASSET_ID,GBO.BROKER_CD,GBO.BORROW_QTY,GB.BORROW_REQUEST_TYPE INTO v_asset_id,v_broker_cd,v_borrow_qty, v_broker_request_type
		        FROM GEC_BORROW GBO
		        LEFT JOIN GEC_BROKER GB
		        ON GBO.BROKER_CD = GB.BROKER_CD
		        WHERE GBO.BORROW_ID = V_BORROW_ID.COLUMN_VALUE
		        		AND GBO.STATUS in ('P','B');
		    EXCEPTION WHEN NO_DATA_FOUND THEN
		  				v_not_exist := 'Y';
	     	END;
	          
		    BEGIN
				IF  v_broker_request_type <> 'SB' AND v_not_exist = 'N' THEN
	        IF v_broker_request_type = 'NSB' THEN
	            v_souce_cd := 'SFA';
	            v_broker_cd := null;        
	        END IF;
      
	      declare CURSOR AVAIL_CUR IS
	            SELECT LENDER_AVAILABILITY_ID, AVAIL_QTY
	              FROM GEC_LENDER_AVAILABILITY
	                    WHERE NVL(SOURCE_CD, c_source_cd_null) = NVL(v_souce_cd, c_source_cd_null)
	                    AND NVL(BROKER_CD, c_source_cd_null) = NVL(v_broker_cd, c_source_cd_null)
	                    AND ASSET_ID = v_asset_id
	                    AND STATUS = 'A'; 
			    BEGIN 
		            FOR CURR_AVAIL_CUR IN AVAIL_CUR
		              LOOP 
		             
		                  BEGIN      
		                  SELECT 'Y' INTO v_brw_map_exist FROM DUAL
		                  WHERE EXISTS(select 1 from GEC_LENDER_AVAIL_BRW_MAP 
		                    WHERE LENDER_AVAILABILITY_ID = CURR_AVAIL_CUR.LENDER_AVAILABILITY_ID
		                    AND BORROW_ID = V_BORROW_ID.COLUMN_VALUE);
		                  EXCEPTION WHEN NO_DATA_FOUND THEN
		                        v_brw_map_exist := 'N';
		                  END;
		                
		                IF v_brw_map_exist = 'N' THEN 
		                  INSERT INTO GEC_LENDER_AVAIL_BRW_MAP(
		                      LENDER_AVAILABILITY_ID,
		                      BORROW_ID
		                  )VALUES
		                  (
		                      CURR_AVAIL_CUR.LENDER_AVAILABILITY_ID,
		                      V_BORROW_ID.COLUMN_VALUE
		                  );
		                  
		                  IF CURR_AVAIL_CUR.AVAIL_QTY - v_borrow_qty <= 0 THEN
		                    v_avail_qty := 0;
		                  ELSE
		                    v_avail_qty := CURR_AVAIL_CUR.AVAIL_QTY - v_borrow_qty;
		                  END IF;
		                  
		                 UPDATE GEC_LENDER_AVAILABILITY SET AVAIL_QTY = v_avail_qty,
		                      CREATED_DATETIME = sysdate 
		                      WHERE LENDER_AVAILABILITY_ID = CURR_AVAIL_CUR.LENDER_AVAILABILITY_ID;
		               END IF;
	               
	               END LOOP;
	            END;
		    END IF;  
        
		    EXCEPTION WHEN NO_DATA_FOUND THEN
		  		p_error_code := null;
		    END;   	
	    END LOOP;
  		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END UPDATE_AVAIL_FOR_BORROW;
  
	PROCEDURE PROCESS_AVPO_AVAIL_TEMP(p_legalEntityId IN GEC_NUMBER_ARRAY)
	IS
	    V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_AVAILABILITY_PKG.PROCESS_AVPO_AVAIL_TEMP';  
	    P_LEGAL_ENTITY_ID NUMBER;
	    P_ORDER_EXP_DATE NUMBER;
    CURSOR V_LEGAL_ENDITY_CDS IS
            SELECT DISTINCT(GEC_LEGAL_ENTITY.LEGAL_ENTITY_CD) FROM 
            GEC_LEGAL_ENTITY
            INNER JOIN (
              TABLE ( cast ( p_legalEntityId as GEC_NUMBER_ARRAY) ) LEGALENDITY_Ids) 
            ON GEC_LEGAL_ENTITY.LEGAL_ENTITY_ID = LEGALENDITY_Ids.COLUMN_VALUE; 
	 	CURSOR V_CUR(p_led VARCHAR2) IS
			SELECT GLAT.LENDER_AVAILABILITY_ID AS GIA_LENDER_AVAILABILITY_ID, 
				GIA.ASSET_ID AS GIA_ASSET_ID, 
				GLAT.BROKER_CD, 
				GLAT.LEGAL_ENTITY_ID,
				GLAT.AVAIL_QTY, 
				GLAT.RATE,
				GLAT.RECLAIM_RATE, 
				GLAT.CREATED_DATETIME, 
				GLAT.ORDER_EXP_DATE, 
				GLA.LENDER_AVAILABILITY_ID AS GLA_LENDER_AVAILABILITY_ID,
				GLA.ORDER_EXP_DATE as GLA_ORDER_EXP_DATE,
        GLA.LEGAL_ENTITY_CD as LEGAL_ENTITY_CD 
			FROM GEC_LENDER_AVAILABILITY_TEMP GLAT
			LEFT OUTER JOIN GEC_ASSET_IDENTIFIER GIA
			ON GIA.ASSET_CODE_TYPE=DECODE(GLAT.ASSET_CODE_TYPE,'C',GEC_CONSTANTS_PKG.C_CSP,'S',GEC_CONSTANTS_PKG.C_SED,'I',GEC_CONSTANTS_PKG.C_ISN,'Q',GEC_CONSTANTS_PKG.C_QUK,GEC_CONSTANTS_PKG.C_TIK) 
			AND GIA.ASSET_CODE=GLAT.ASSET_CODE 
			LEFT OUTER JOIN GEC_LENDER_AVAILABILITY GLA 
			ON GLA.ASSET_ID = GIA.ASSET_ID
			AND GLA.LEGAL_ENTITY_ID = GLAT.LEGAL_ENTITY_ID
			AND GLA.STATUS = 'A'
			AND GLA.ORDER_EXP_DATE >= GLAT.ORDER_EXP_DATE
      AND GLA.LEGAL_ENTITY_CD = p_led
			ORDER BY GIA_ASSET_ID,GIA_LENDER_AVAILABILITY_ID;
	   
	   v_avail_pre V_CUR%ROWTYPE;
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
	 
   FOR V_CUR_CD IN V_LEGAL_ENDITY_CDS
     LOOP
   
	    FOR V_REC IN V_CUR(V_CUR_CD.LEGAL_ENTITY_CD)
	    LOOP
       IF V_REC.GIA_LENDER_AVAILABILITY_ID IS NOT NULL AND (v_avail_pre.GIA_LENDER_AVAILABILITY_ID IS NULL OR V_REC.GIA_LENDER_AVAILABILITY_ID <> v_avail_pre.GIA_LENDER_AVAILABILITY_ID) THEN
	      	
			   	IF ((V_REC.GLA_LENDER_AVAILABILITY_ID IS NULL OR V_REC.GLA_ORDER_EXP_DATE < V_REC.ORDER_EXP_DATE) AND V_REC.GIA_ASSET_ID IS NOT NULL) THEN
			    	IF P_ORDER_EXP_DATE IS NULL THEN
			        	P_ORDER_EXP_DATE := V_REC.ORDER_EXP_DATE;   
			        END IF;  
			    	IF P_LEGAL_ENTITY_ID IS NULL THEN
			        	P_LEGAL_ENTITY_ID := V_REC.LEGAL_ENTITY_ID;   
			      	END IF;  
				   	IF (v_avail_pre.GIA_ASSET_ID IS NULL OR v_avail_pre.GIA_ASSET_ID <> V_REC.GIA_ASSET_ID) THEN 
				        INSERT INTO GEC_LENDER_AVAILABILITY  
							(
							LENDER_AVAILABILITY_ID,   
							ASSET_ID,    
							BROKER_CD,  
							LEGAL_ENTITY_ID,
							AVAIL_QTY,
							INDICATIVE_RATE,
							FUND_CD,
							RECLAIM_RATE, 
							CREATED_DATETIME,
							STATUS,          
							CREATED_AT,				
							CREATED_BY,
							SOURCE_CD,		
							POSITION_FLAG,
							RESTRICTION_CD,
							ORDER_EXP_DATE,
              LEGAL_ENTITY_CD
							)
						VALUES(
						    GEC_LENDER_AVAILABILITY_ID_SEQ.nextval,
						    V_REC.GIA_ASSET_ID,
						    V_REC.BROKER_CD,
						    V_REC.LEGAL_ENTITY_ID,
						    V_REC.AVAIL_QTY,
						    V_REC.RATE,
						    NULL,
						    V_REC.RECLAIM_RATE,
						    V_REC.CREATED_DATETIME,
						    'A',
						    SYSDATE,
						    GEC_CONSTANTS_PKG.C_SYSTEM,
						    NULL,      
						    NULL,
						    NULL,
						    V_REC.ORDER_EXP_DATE,
                V_CUR_CD.LEGAL_ENTITY_CD
							); 
				      ELSIF (v_avail_pre.GIA_ASSET_ID = V_REC.GIA_ASSET_ID) THEN 
				         --duplicate asset in AVPO
						 V_REC.RATE := NVL(GREATEST(V_REC.RATE,v_avail_pre.RATE),NVL(V_REC.RATE,v_avail_pre.RATE));
           				 V_REC.RECLAIM_RATE := NVL(LEAST(V_REC.RECLAIM_RATE,v_avail_pre.RECLAIM_RATE),NVL(V_REC.RECLAIM_RATE,v_avail_pre.RECLAIM_RATE));       
				         UPDATE GEC_LENDER_AVAILABILITY GLA SET GLA.AVAIL_QTY = GLA.AVAIL_QTY + V_REC.AVAIL_QTY,
					         GLA.INDICATIVE_RATE = V_REC.RATE,
					         GLA.RECLAIM_RATE = V_REC.RECLAIM_RATE,
					         GLA.CREATED_DATETIME = V_REC.CREATED_DATETIME      
					         WHERE GLA.STATUS = 'A'
					         AND GLA.LEGAL_ENTITY_ID = V_REC.LEGAL_ENTITY_ID
					         AND GLA.ASSET_ID = V_REC.GIA_ASSET_ID
					         AND GLA.ORDER_EXP_DATE = V_REC.ORDER_EXP_DATE
                   AND GLA.LEGAL_ENTITY_CD = V_CUR_CD.LEGAL_ENTITY_CD;
				      END IF;
			     
			     
			    ELSIF ( V_REC.GLA_LENDER_AVAILABILITY_ID IS NOT NULL AND V_REC.GIA_ASSET_ID IS NOT NULL ) THEN
				    IF (v_avail_pre.GIA_ASSET_ID is null or v_avail_pre.GIA_ASSET_ID <> V_REC.GIA_ASSET_ID) THEN 
				    	UPDATE GEC_LENDER_AVAILABILITY GLA SET GLA.AVAIL_QTY = GLA.AVAIL_QTY + V_REC.AVAIL_QTY,
					        GLA.INDICATIVE_RATE = V_REC.RATE,
					        GLA.RECLAIM_RATE = V_REC.RECLAIM_RATE,
					        GLA.CREATED_DATETIME = V_REC.CREATED_DATETIME      
					        WHERE GLA.STATUS = 'A' 
                  AND GLA.LENDER_AVAILABILITY_ID = V_REC.GLA_LENDER_AVAILABILITY_ID
                  AND GLA.LEGAL_ENTITY_CD = V_CUR_CD.LEGAL_ENTITY_CD;
				   	ELSIF (v_avail_pre.GIA_ASSET_ID = V_REC.GIA_ASSET_ID) THEN 
				    --duplicate asset
						V_REC.RATE := NVL(GREATEST(V_REC.RATE,v_avail_pre.RATE),NVL(V_REC.RATE,v_avail_pre.RATE));
           				V_REC.RECLAIM_RATE := NVL(LEAST(V_REC.RECLAIM_RATE,v_avail_pre.RECLAIM_RATE),NVL(V_REC.RECLAIM_RATE,v_avail_pre.RECLAIM_RATE)); 
				    	UPDATE GEC_LENDER_AVAILABILITY GLA SET GLA.AVAIL_QTY = GLA.AVAIL_QTY + V_REC.AVAIL_QTY,
					        GLA.INDICATIVE_RATE = V_REC.RATE,
					        GLA.RECLAIM_RATE = V_REC.RECLAIM_RATE,
					        GLA.CREATED_DATETIME = V_REC.CREATED_DATETIME      
					        WHERE GLA.STATUS = 'A' 
                  AND GLA.LENDER_AVAILABILITY_ID = V_REC.GLA_LENDER_AVAILABILITY_ID
                  AND GLA.LEGAL_ENTITY_CD = V_CUR_CD.LEGAL_ENTITY_CD;
				   	END IF;
			  	END IF;
			    v_avail_pre := V_REC;
			    
		    END IF;
	  	END LOOP;
      v_avail_pre := null;
      
        IF P_ORDER_EXP_DATE IS NOT NULL AND P_LEGAL_ENTITY_ID IS NOT NULL THEN
	    	UPDATE GEC_LENDER_AVAILABILITY GLA SET GLA.STATUS = 'I' 
		        WHERE GLA.STATUS = 'A' AND GLA.LEGAL_ENTITY_ID = P_LEGAL_ENTITY_ID
		        AND GLA.ORDER_EXP_DATE < P_ORDER_EXP_DATE
            	AND GLA.LEGAL_ENTITY_CD = V_CUR_CD.LEGAL_ENTITY_CD;
	    END IF;
      
	  	END LOOP;
	    
	   DELETE FROM GEC_LENDER_AVAILABILITY_TEMP;
	    
	    GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	 END PROCESS_AVPO_AVAIL_TEMP;
 	
END GEC_AVAILABILITY_PKG;
/
