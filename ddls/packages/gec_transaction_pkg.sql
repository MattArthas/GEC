-------------------------------------------------------------------------
-- Copyright (c) 2010 State Street Bank and Trust Corp.
-- 225 Franklin Street, Boston, MA 02110, U.S.A.
-- All rights reserved.
--
-- GEC_transaction_PKG.sql is the copyrighted,
-- proprietary property of State Street Bank and Trust Company and its
-- subsidiaries and affiliates which retain all right, title and interest
-- therein.
--
-- Revision History
--
-- Date            Programmer                Notes
-- ------------    --------------------      ----------------------------
-- Feb 23, 2010    Zhao Hong                 initial
-- 
-------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE GEC_TRANSACTION_PKG
AS
	-------------------------------------THE FOLLOWING PROCEDURES ARE CALLED OUTSIDE BY JAVA-----------------------------------
	--Accept locate requests
	--Called by JAVA saveAndAcceptLocateRequest()
	--The logic is based on the code of Feb 23, 2010 : private List GecIMRequest saveAndAcceptLocateRequest(String userID, Long requestId) 
	PROCEDURE ACCEPT_LOCATES( p_userId     			IN  VARCHAR2,
							  p_requestIds  		IN  GEC_NUMBER_ARRAY,
							  p_transaction_cd		IN 	VARCHAR2,
							  p_locatePreborrowIds  IN  GEC_NUMBER_ARRAY,
							  p_acceptFlag			IN 	VARCHAR2,				
							  p_retLocates 			OUT SYS_REFCURSOR,
							  p_scheduledTime_cur 	OUT SYS_REFCURSOR);
							  
	PROCEDURE PROCESS_ACCEPT_LOCATES;
	
	-------------------------------------THE FOLLOWING PROCEDURES ARE CALLED ONLY BY STORED PROCEDURES FUNCTIONS-----------------------------------
	--calculate fee in im locate response
	FUNCTION CALCULATE_FEE( p_nsbRate     IN  NUMBER,
							p_rateFactor  IN  NUMBER)
		RETURN NUMBER;

	--format fee in im locate response
	FUNCTION FORMAT_FEE( p_nsbRate     IN  NUMBER,
						 p_rateFactor  IN  NUMBER,
						 p_rateDisplay IN  VARCHAR2,
						 p_rateText    IN  VARCHAR2)
		RETURN VARCHAR2;
		
	PROCEDURE BUILD_LOCATE_INFO_WITH_ASSET( p_locatePreborrowId     IN  NUMBER,
											p_assetId  				IN  NUMBER,
											p_needInsert			IN  VARCHAR2,
											p_rtnLocates  			OUT SYS_REFCURSOR);
							  
END GEC_TRANSACTION_PKG;
/

CREATE OR REPLACE PACKAGE BODY GEC_TRANSACTION_PKG
AS

	--Accept locate requests
	PROCEDURE ACCEPT_LOCATES( p_userId     			IN  VARCHAR2,
							  p_requestIds  		IN  GEC_NUMBER_ARRAY,
							  p_transaction_cd		IN 	VARCHAR2,
							  p_locatePreborrowIds  IN  GEC_NUMBER_ARRAY,
							  p_acceptFlag			IN 	VARCHAR2,				  
							  p_retLocates 			OUT SYS_REFCURSOR,
							  p_scheduledTime_cur	OUT SYS_REFCURSOR)
	IS
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_TRANSACTION_PKG.ACCEPT_LOCATES';
		v_updated_at GEC_locate_preborrow.updated_at%type;	
		V_ID_LIST GEC_NUMBER_ARRAY; 
		v_request_id gec_request.request_id%type;
	    Cursor p_request_id_cur is 
	        Select REQUEST_ID 
	        from (select distinct req.COLUMN_VALUE REQUEST_ID from TABLE ( cast ( p_requestIds as GEC_NUMBER_ARRAY) ) req ) ids
	        order by REQUEST_ID asc; 
	                  
	    v_lp_id GEC_locate_preborrow.LOCATE_PREBORROW_ID%type;
	    v_avail_id GEC_locate_preborrow.im_availability_id%type;
	    Cursor p_lp_id_cur is 
	        Select LOCATE_PREBORROW_ID 
	        from (select distinct glp.COLUMN_VALUE LOCATE_PREBORROW_ID from TABLE ( cast ( p_locatePreborrowIds as GEC_NUMBER_ARRAY) ) glp ) ids
	        order by LOCATE_PREBORROW_ID asc; 
	        
	    CURSOR C_LOCK_AVAIL IS
			SELECT avail.im_availability_id
			  FROM gec_locate_preborrow_temp lpt, GEC_IM_AVAILABILITY avail
			 WHERE lpt.status in ('P','E') 
			   AND lpt.im_availability_id = avail.im_availability_id
			   AND avail.status='A'
			 ORDER BY lpt.asset_id,lpt.strategy_id
			   FOR UPDATE OF avail.im_availability_id;    
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
			  
		--clean temp table at first.
		DELETE FROM GEC_locate_preborrow_temp;
		
		select sysdate into v_updated_at from dual;
		
		-- add RX lock. 
	    IF p_acceptFlag = GEC_CONSTANTS_PKG.C_ACCEPT_BY_LOCPRB_ID THEN
			--This section C_LOCK_AVAIL added intends to lock matched availability And keep lock order gec_im_availablity first,gec_locate_preborrow second.
			--The where condition is same as cursor v_cur_updateAvail.Please Note: If where condition of v_cur_updateAvail changes,Please
			--change the where condition of C_LOCK_AVAIL.
	        For v_avail in C_LOCK_AVAIL
	        Loop
	            select avail.im_availability_id into v_avail_id 
	              from GEC_IM_AVAILABILITY avail 
	             where avail.im_availability_id = v_avail.im_availability_id
	               for update;
	        End loop;		    
	    		    
	        For v_lp in p_lp_id_cur
	        Loop
	            select glp.locate_preborrow_id into v_lp_id 
	              from GEC_locate_preborrow glp 
	             where glp.locate_preborrow_id = v_lp.locate_preborrow_id
	               for update;
	        End loop;	
		ELSE 
		    For v_request in p_request_id_cur
		    Loop
		        select gr.request_id into v_request_id 
		          from gec_request gr 
		         where gr.request_id = v_request.request_id 
		           for update;
		    End loop;	
	    END IF;	 
	       
	    IF p_acceptFlag = GEC_CONSTANTS_PKG.C_ACCEPT_BY_LOCPRB_ID THEN
	    	-- Accept request by locate preborrow id
			INSERT INTO GEC_locate_preborrow_temp
				(BUSINESS_DATE,INVESTMENT_MANAGER_CD,IM_USER_ID,TRANSACTION_CD,FUND_CD,
				CLIENT_CD,SHARE_QTY,ASSET_CODE,ASSET_ID,ASSET_CODE_TYPE,
				IM_AVAILABILITY_ID,CREATED_AT,RESERVED_SB_QTY,SB_QTY_RAL,RESERVED_NSB_QTY,
				SOURCE_CD,UPDATED_BY,STATUS,COMMENT_TXT,
				SB_RATE,NSB_LOAN_NO,NSB_RATE,
				REMAINING_SFP,POSITION_FLAG,SB_BROKER,
				UPDATED_AT,TRADE_COUNTRY_CD,
                TRADE_COUNTRY_ALIAS_CD,   
				RESTRICTION_CD,RESERVED_NFS_QTY,NFS_BORROW_ID,NFS_RATE,
				RESERVED_EXT2_QTY,EXT2_BORROW_ID,EXT2_RATE,
				LOCATE_PREBORROW_ID,CUSIP,ISIN,SEDOL,TICKER,
				DESCRIPTION,QUIK,FILE_VERSION,IM_DEFAULT_FUND_CD,IM_DEFAULT_CLIENT_CD,
				STRATEGY_ID,FUND_SOURCE,CREATED_BY,scheduled_at,
				indicative_rate,IM_REQUEST_ID,IM_LOCATE_ID,
	  			AT_POINT_AVAIL_QTY,AGENCY_BORROW_RATE,RECLAIM_RATE,
	  			REQUEST_ID,ASSET_TYPE_ID,LIQUIDITY_FLAG    
				)
				SELECT BUSINESS_DATE,INVESTMENT_MANAGER_CD,IM_USER_ID,TRANSACTION_CD,FUND_CD,
					CLIENT_CD,SHARE_QTY,ASSET_CODE,ASSET_ID,ASSET_CODE_TYPE,
					IM_AVAILABILITY_ID, CREATED_AT,RESERVED_SB_QTY,SB_QTY_RAL,RESERVED_NSB_QTY,
					SOURCE_CD,UPDATED_BY,STATUS,COMMENT_TXT,
					SB_RATE,NSB_LOAN_NO,NSB_RATE,
					REMAINING_SFP,POSITION_FLAG,SB_BROKER,
					V_UPDATED_AT,TRADE_COUNTRY_CD,
                    TRADE_COUNTRY_ALIAS_CD,
					RESTRICTION_CD,RESERVED_NFS_QTY,NFS_BORROW_ID,NFS_RATE,
					RESERVED_EXT2_QTY,EXT2_BORROW_ID,EXT2_RATE,
					LOCATE_PREBORROW_ID,CUSIP,ISIN,SEDOL,TICKER,
					DESCRIPTION,QUIK,FILE_VERSION,		IM_DEFAULT_FUND_CD,IM_DEFAULT_CLIENT_CD,
					STRATEGY_ID,FUND_SOURCE,CREATED_BY,scheduled_at,	
					indicative_rate,IM_REQUEST_ID,IM_LOCATE_ID,
	  				AT_POINT_AVAIL_QTY,AGENCY_BORROW_RATE,RECLAIM_RATE,
	  				GEC_locate_preborrow.REQUEST_ID,ASSET_TYPE_ID,LIQUIDITY_FLAG	      
					FROM GEC_locate_preborrow, (select distinct req.COLUMN_VALUE LP_ID from TABLE ( cast ( p_locatePreborrowIds as GEC_NUMBER_ARRAY) ) req ) ids
					WHERE GEC_locate_preborrow.locate_preborrow_id = ids.LP_ID
					AND GEC_locate_preborrow.INITIAL_FLAG  = 'Y';   	
	    ELSE
	    	-- Accept request by request id
			INSERT INTO GEC_locate_preborrow_temp
				(BUSINESS_DATE,INVESTMENT_MANAGER_CD,IM_USER_ID,TRANSACTION_CD,FUND_CD,
				CLIENT_CD,SHARE_QTY,ASSET_CODE,ASSET_ID,ASSET_CODE_TYPE,
				IM_AVAILABILITY_ID,CREATED_AT,RESERVED_SB_QTY,SB_QTY_RAL,RESERVED_NSB_QTY,
				SOURCE_CD,UPDATED_BY,STATUS,COMMENT_TXT,
				SB_RATE,NSB_LOAN_NO,NSB_RATE,
				REMAINING_SFP,POSITION_FLAG,SB_BROKER,
				UPDATED_AT,TRADE_COUNTRY_CD,TRADE_COUNTRY_ALIAS_CD,
				RESTRICTION_CD,RESERVED_NFS_QTY,NFS_BORROW_ID,NFS_RATE,
				RESERVED_EXT2_QTY,EXT2_BORROW_ID,EXT2_RATE,
				LOCATE_PREBORROW_ID,CUSIP,ISIN,SEDOL,TICKER,
				DESCRIPTION,QUIK,FILE_VERSION,IM_DEFAULT_FUND_CD,IM_DEFAULT_CLIENT_CD,
				STRATEGY_ID,FUND_SOURCE,CREATED_BY,scheduled_at,
				indicative_rate,IM_REQUEST_ID,IM_LOCATE_ID,
	  			AT_POINT_AVAIL_QTY,AGENCY_BORROW_RATE,RECLAIM_RATE,
	  			REQUEST_ID,ASSET_TYPE_ID,LIQUIDITY_FLAG	      
				)
				SELECT BUSINESS_DATE,INVESTMENT_MANAGER_CD,IM_USER_ID,TRANSACTION_CD,FUND_CD,
					CLIENT_CD,SHARE_QTY,ASSET_CODE,ASSET_ID,ASSET_CODE_TYPE,
					IM_AVAILABILITY_ID, CREATED_AT,RESERVED_SB_QTY,SB_QTY_RAL,RESERVED_NSB_QTY,
					SOURCE_CD,UPDATED_BY,STATUS,COMMENT_TXT,
					SB_RATE,NSB_LOAN_NO,NSB_RATE,
					REMAINING_SFP,POSITION_FLAG,SB_BROKER,
					V_UPDATED_AT,TRADE_COUNTRY_CD,TRADE_COUNTRY_ALIAS_CD,
					RESTRICTION_CD,RESERVED_NFS_QTY,NFS_BORROW_ID,NFS_RATE,
					RESERVED_EXT2_QTY,EXT2_BORROW_ID,EXT2_RATE,
					LOCATE_PREBORROW_ID,CUSIP,ISIN,SEDOL,TICKER,
					DESCRIPTION,QUIK,FILE_VERSION,		IM_DEFAULT_FUND_CD,IM_DEFAULT_CLIENT_CD,
					STRATEGY_ID,FUND_SOURCE,CREATED_BY,scheduled_at,	
					indicative_rate,IM_REQUEST_ID,IM_LOCATE_ID,
	  				AT_POINT_AVAIL_QTY,AGENCY_BORROW_RATE,RECLAIM_RATE,
	  				GEC_locate_preborrow.REQUEST_ID,ASSET_TYPE_ID,LIQUIDITY_FLAG	      
					FROM GEC_locate_preborrow, (select distinct req.COLUMN_VALUE REQUEST_ID from TABLE ( cast ( p_requestIds as GEC_NUMBER_ARRAY) ) req ) ids
					WHERE GEC_locate_preborrow.request_id = ids.REQUEST_ID
					AND GEC_locate_preborrow.INITIAL_FLAG  = 'Y';	 
		END IF; 
		
		PROCESS_ACCEPT_LOCATES;
				
		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);

		--GetLocateResponse is changed to convert fee to normal string  
    	--	Because to_char(fee) in oracle can not convert the number to same characters as itself.
    	--	For example to_char(0.345) it will show  .345
    	--				to_char(-0.345) it will show -.345
    	--	Here it uses  decode(sign(abs(N) - 1),-1,
    	--							decode(sign(N), -1, '-0' || substr(to_char(N), 2),'0' || to_char(N)),  
        --      						to_char(N)) 
        --      		to format fee to correct format.
    	--It looks odd but so far it's one way to properly deal this conversion from number to string. 				
		--getLocateResponse
		OPEN p_retLocates FOR
			SELECT temp.source_cd, 
                 temp.status, 
                 temp.locate_preborrow_id, 
                 temp.business_date, 
                 temp.investment_manager_cd, 
                 temp.transaction_cd, 
                 decode(temp.fund_source,
                 		'F',               
		                temp.fund_cd, 
		                'S',
		                strategy.strategy_name) fund_cd,
                 temp.asset_code, 
                 gec_asset.asset_id,
                 temp.cusip,
                 temp.isin,
                 temp.sedol,
                 temp.ticker,
                 temp.description,
                 temp.quik,
                 temp.TRADE_COUNTRY_ALIAS_CD as trade_country_cd,
                 temp.file_version,
                 temp.share_qty,
                 temp.IM_AVAILABILITY_ID,
                 temp.im_user_id,
                 Decode(include_locate_flag,'Y', Decode(temp.reserved_sb_qty + temp.sb_qty_ral + temp.reserved_nsb_qty 
                     + temp.reserved_nfs_qty + temp.reserved_ext2_qty,0,' ', Decode(temp.locate_id,NULL,' ',temp.locate_id)), 
                     NULL) AS locate_id,
                 temp.reserved_sb_qty, 
                 temp.sb_qty_ral, 
                 temp.reserved_nsb_qty, 
                 temp.reserved_nfs_qty, 
                 temp.reserved_ext2_qty, 
                 gec_fund.client_cd, 
                 temp.nsb_rate, 
                 strategy_name strategy,
                 temp.CREATED_BY,
                 temp.reserved_sb_qty + temp.sb_qty_ral + temp.reserved_nsb_qty + temp.reserved_nfs_qty + temp.reserved_ext2_qty  AS approved_qty, 
                 temp.comment_txt, 
                 decode(upper(temp.indicative_rate),'GC','GC',FORMAT_FEE(to_number(temp.indicative_rate), gec_fund.rate_factor, gec_fund.rate_display, gec_fund.rate_text) ) AS fee,
		  		 temp.LIQUIDITY_FLAG,
		         gec_fund.INCLUDE_LIQUIDITY_FLAG
		  FROM   gec_locate_preborrow_temp  temp
          INNER JOIN gec_fund 
            	ON (temp.client_cd = gec_fund.client_cd) 
           			AND (temp.fund_cd = gec_fund.fund_cd) 
           			AND (temp.investment_manager_cd = gec_fund.investment_manager_cd) 
		  LEFT JOIN gec_strategy strategy
		    ON temp.strategy_id = strategy.strategy_id
		    	AND strategy.status = 'A'
          LEFT JOIN gec_asset 
            ON gec_asset.asset_id = temp.asset_id
		 ORDER BY asset_code;
		 
		
		OPEN p_scheduledTime_cur FOR
		select 	DISTINCT
				temp.scheduled_at as scheduled_at,
				to_number(to_char(temp.scheduled_at,'yyyymmddhh24Miss')) as job_id, 
				temp.TRANSACTION_CD as job_type,
				CASE WHEN qry.scheduled_at IS NULL THEN 'Y'
				ELSE 'N'
				END AS schedule_flag
		from 	gec_locate_preborrow_temp temp
		join gec_strategy strategy
		on temp.strategy_id = strategy.strategy_id 
		and strategy.status = 'A' 
		--and ( temp.source_cd <> gec_constants_pkg.C_FA_REQUEST  OR (temp.source_cd = gec_constants_pkg.C_FA_REQUEST and strategy.st_status <> 'M' ) )
		left join (
					select pre.scheduled_at 
					from gec_locate_preborrow pre 
					LEFT JOIN gec_locate_preborrow_temp  ids 
					ON pre.locate_preborrow_id = ids.locate_preborrow_id
					where 
						 	pre.status = 'H' 
						 	and pre.INITIAL_FLAG ='N' 
						 	and pre.scheduled_at is not null
						 	and ids.locate_preborrow_id is null
						 	and pre.transaction_cd = p_transaction_cd
					union all
					select scheduled_at from gec_file 
					where 
						status = 'P' 
						and scheduled_at is not null 
						and gec_constants_pkg.C_LOCATE = p_transaction_cd
					) qry
		on temp.scheduled_at = qry.scheduled_at
		where 
		     temp.status = 'H'
		     AND temp.transaction_cd = p_transaction_cd
		     AND temp.INITIAL_FLAG ='N' 
		     AND qry.scheduled_at is null;
		      		     
		EXCEPTION 
		WHEN OTHERS THEN
			GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME, 'E', 'EXCEPTION');
			RAISE;
	END ACCEPT_LOCATES;
	
	PROCEDURE PROCESS_ACCEPT_LOCATES
	IS
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_TRANSACTION_PKG.PROCESS_ACCEPT_LOCATES';
		v_sysdate DATE;					
		CURSOR v_cur_avail_id IS	  
			 select im_availability_id,restriction_cd,Position_flag,Locate_Preborrow_id,
				SB_RATE,NSB_RATE,NFS_RATE,EXT2_RATE,asset_id
			from (
			select avail.im_availability_id, avail.restriction_cd, avail.Position_flag, Locate_Preborrow_id,
								avail.SB_RATE, avail.NSB_RATE, avail.NFS_RATE, avail.EXT2_RATE,loc.asset_id,
							(rank() over(partition by loc.locate_preborrow_id order by avail.im_availability_id asc) ) as rank
			from gec_im_availability  avail , GEC_LOCATE_PREBORROW_temp loc
			where loc.asset_id = avail.asset_id
			and loc.strategy_id = avail.strategy_id
			and loc.trade_country_cd = avail.trade_country_cd
			and avail.status ='A'
		    and loc.im_availability_id is null          
	      	) loc where rank = 1;   	  

		CURSOR v_cur_at_point_avail IS
			SELECT loc.locate_preborrow_id,
					(CASE WHEN avail.im_availability_id IS NULL THEN 0
				  		ELSE (nvl(avail.SB_QTY,0)+nvl(avail.SB_QTY_RAL,0)+nvl(avail.NSB_QTY,0)+nvl(avail.NFS_QTY,0)+nvl(avail.EXT2_QTY,0))
			 		END ) at_point_avail_qty
			  FROM GEC_locate_preborrow_temp loc 
			  LEFT JOIN GEC_IM_AVAILABILITY avail
			    ON loc.im_availability_id = avail.im_availability_id
			   AND avail.status='A'
			 WHERE loc.status = 'X';						  
	
		--Uploading availability file will update availability qty when processing unexpired locates, there is NO order of locking availability records.
		--So, system has to lock all matched availability records here in order to avoid dead lock among different availability records.
		CURSOR v_cur_updateAvail IS
			SELECT avail.im_availability_id, lpt.RESERVED_SB_QTY, lpt.SB_QTY_RAL, lpt.RESERVED_NSB_QTY, lpt.RESERVED_NFS_QTY, lpt.RESERVED_EXT2_QTY,
					lpt.locate_preborrow_id, avail.rowid as avail_rowid, lpt.rowid as locate_rowid,
					(CASE WHEN avail.im_availability_id IS NULL THEN 0
				  		ELSE (nvl(avail.SB_QTY,0)+nvl(avail.SB_QTY_RAL,0)+nvl(avail.NSB_QTY,0)+nvl(avail.NFS_QTY,0)+nvl(avail.EXT2_QTY,0))
			 		END ) at_point_avail_qty
			  FROM gec_locate_preborrow_temp lpt, GEC_IM_AVAILABILITY avail
			 WHERE lpt.status in ('P','E') 
			   AND lpt.im_availability_id = avail.im_availability_id
			   AND avail.status='A'
			 ORDER BY lpt.asset_id,lpt.strategy_id
			   FOR UPDATE OF avail.im_availability_id;
		
		--update GEC_locate_preborrow by the order of locate_preborrow_id to avoid dead lock
		CURSOR v_cur_updateLocates IS
			SELECT loc.COMMENT_TXT, loc.NSB_Rate, loc.LOCATE_ID, loc.im_availability_id, loc.locate_preborrow_id,
			 		loc.UPDATED_AT, loc.at_point_avail_qty, lp.rowid as row_id
			  FROM GEC_locate_preborrow_temp loc, gec_locate_preborrow lp
			 WHERE loc.locate_preborrow_id = lp.locate_preborrow_id
  			 ORDER BY loc.locate_preborrow_id;
	BEGIN		
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);

		SELECT SYSDATE INTO v_sysdate FROM DUAL;
		
		--create new availability for locates that do not have matched availability. --Not required from R1.3
		INSERT INTO  GEC_IM_AVAILABILITY  
		 	(IM_Availability_id,   Business_Date,    	INVESTMENT_MANAGER_CD,  CLIENT_CD,
		   	ASSET_ID,               Position_flag, 		NSB_Rate,             NFS_qty,          
		   	NFS_rate,				source_cd,			strategy_id,		  trade_country_cd, 
		   	indicative_rate,		STATUS,				created_at
		    )
		    SELECT GEC_IM_Availability_id_seq.nextval,   qry.Business_Date,		qry.INVESTMENT_MANAGER_CD,  qry.CLIENT_CD,
		        qry.ASSET_ID,               qry.Position_flag, 					qry.NSB_Rate,             	qry.NFS_qty,          			
		        qry.NFS_rate,				qry.TRANSACTION_CD AS source_cd,	qry.strategy_id,		  	qry.trade_country_cd,				
		        qry.indicative_rate,		'A' AS STATUS,						sysdate as created_at
		    FROM( SELECT DISTINCT lpt.Business_Date, lpt.INVESTMENT_MANAGER_CD, lpt.CLIENT_CD, lpt.ASSET_ID, NVL(lpt.Position_Flag,'GC') AS Position_Flag,
		    		 999 AS NSB_Rate, 0 AS NFS_Qty, 0.35 AS NFS_Rate, lpt.TRANSACTION_CD,
		                lpt.strategy_id, lpt.trade_country_cd,lpt.NSB_Rate AS indicative_rate
		            FROM GEC_locate_preborrow_temp lpt
		           WHERE lpt.im_availability_id is null
		             AND lpt.STATUS in ('E','P')
		             and lpt.asset_id is not null
		        ) qry
		    LEFT OUTER JOIN GEC_IM_AVAILABILITY avail
		      ON avail.status = 'A'
			 and avail.STRATEGY_ID = qry.STRATEGY_ID
			 and avail.ASSET_ID = qry.ASSET_ID
		   WHERE avail.ASSET_ID IS NULL;
		   		   		   		   

		FOR v_cur_item IN v_cur_avail_id LOOP
			UPDATE GEC_LOCATE_PREBORROW_temp temp
			SET 	temp.restriction_cd = v_cur_item.restriction_cd,
					temp.position_flag  = v_cur_item.position_flag,
					temp.SB_RATE = v_cur_item.SB_RATE,
					temp.NFS_RATE = v_cur_item.NFS_RATE,
					temp.EXT2_RATE = v_cur_item.EXT2_RATE,
					temp.im_availability_id = v_cur_item.im_availability_id
			WHERE temp.Locate_Preborrow_id = v_cur_item.Locate_Preborrow_id;	
			
			gec_availability_pkg.UPDATE_AVAILS_FOR_ASSET(v_cur_item.asset_id);		
		END LOOP;

		----set at-point-available-qty when Locate status is in ('X')
		--Refert to http://collaborate/sites/GMT/gmsftprojects/gec13/Lists/Requirements%20Questions/DispForm.aspx?ID=206 
		FOR v_cur_item IN v_cur_at_point_avail LOOP
			UPDATE GEC_LOCATE_PREBORROW_temp temp
			SET 	temp.at_point_avail_qty = v_cur_item.at_point_avail_qty
			WHERE temp.Locate_Preborrow_id = v_cur_item.Locate_Preborrow_id;	
		END LOOP;	
		
		--qry_updt_Locate_Preborrow_temp_LocateID
		UPDATE GEC_locate_preborrow_temp
		   SET locate_id = to_char(v_sysdate,'J')||to_char(mod(GEC_LOCATE_ID_SEQ.nextval,1000000),'FM000000')
		 WHERE ( status != 'X' );
		
		
		
		UPDATE GEC_locate_preborrow_temp
		SET locate_id = ''
		WHERE (TRADE_COUNTRY_CD IN 
		(SELECT TRADE_COUNTRY_CD FROM GEC_TRADE_COUNTRY WHERE PREBORROW_ELIGIBLE_FLAG = 'Y'))
		AND TRANSACTION_CD = 'LOCATE';
		 --END
		--updateAvailability
		FOR v_rec in v_cur_updateAvail
		LOOP		
			--set at-point-available-qty when Locate status is in ('P','E')
			--Refert to http://collaborate/sites/GMT/gmsftprojects/gec13/Lists/Requirements%20Questions/DispForm.aspx?ID=206 
			update gec_locate_preborrow_temp temp
			set 	at_point_avail_qty = 
						 (select (CASE WHEN avail.im_availability_id IS NULL THEN 0
							  		   ELSE (nvl(avail.SB_QTY,0)+nvl(avail.SB_QTY_RAL,0)+nvl(avail.NSB_QTY,0)+nvl(avail.NFS_QTY,0)+nvl(avail.EXT2_QTY,0))
						 		  END ) at_point_avail_qty 
						 	from GEC_IM_AVAILABILITY avail 
						   where avail.rowid = v_rec.avail_rowid
						 	 and avail.status ='A'
						 	 and rownum = 1
						 )
			where rowid = v_rec.locate_rowid;
		
			UPDATE GEC_IM_AVAILABILITY
			   SET SB_Qty = SB_Qty - v_rec.RESERVED_SB_QTY,
					SB_Qty_RAL = SB_Qty_RAL - v_rec.SB_QTY_RAL,
					NSB_Qty = NSB_Qty - v_rec.RESERVED_NSB_QTY,
					NFS_Qty = NFS_Qty - v_rec.RESERVED_NFS_QTY,
					EXT2_Qty = EXT2_Qty - v_rec.RESERVED_EXT2_QTY
			 WHERE rowid = v_rec.avail_rowid;
		END LOOP;

		--updateAvailabilityForSELF --We do not need it since R1.1
 
		--updateCommetFeeFromTemp
		--at_point_avail_qty:the avail qty before subtractint reserved qty
		FOR v_rec in v_cur_updateLocates
		LOOP
			UPDATE GEC_locate_preborrow
			   SET COMMENT_TXT = v_rec.COMMENT_TXT,
					NSB_Rate  = v_rec.NSB_Rate,
					INITIAL_FLAG = 'N',
					LOCATE_ID = v_rec.LOCATE_ID,
					updated_at = v_rec.updated_at, 
					im_availability_id = NVL(im_availability_id, v_rec.im_availability_id),
					at_point_avail_qty = v_rec.at_point_avail_qty			 
			 WHERE rowid = v_rec.row_id;
		END LOOP;
		
		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END PROCESS_ACCEPT_LOCATES;
	
	FUNCTION CALCULATE_FEE( p_nsbRate     IN  NUMBER,
							p_rateFactor  IN  NUMBER)
		RETURN NUMBER
	IS
		v_retFee NUMBER(32,6);
	BEGIN
		IF p_nsbRate >= 998 THEN
			v_retFee := p_nsbRate;
		ELSE
			v_retFee := p_nsbRate * p_rateFactor;
		END IF;
		RETURN v_retFee;
	END CALCULATE_FEE;
	
	FUNCTION FORMAT_FEE( p_nsbRate     IN  NUMBER,
						 p_rateFactor  IN  NUMBER,
						 p_rateDisplay IN  VARCHAR2,
						 p_rateText    IN  VARCHAR2)
		RETURN VARCHAR2
	IS
		v_feeNum NUMBER(32,6);
		v_feePrefix GEC_FUND.RATE_TEXT%TYPE;
		v_foramtFee VARCHAR2(100);
	BEGIN
		v_feeNum := CALCULATE_FEE(p_nsbRate, p_rateFactor);
		IF p_nsbRate < 998 AND p_rateDisplay = 'O' THEN
			v_feePrefix := p_rateText;
		ELSE
			v_feePrefix := '';
		END IF;
		
		IF Sign(Abs(v_feeNum) - 1) = -1 THEN
			IF Sign(v_feeNum) = -1 THEN
				v_foramtFee := '-0' ||Substr(To_char(v_feeNum),2);
			ELSIF v_feeNum = 0 THEN
				v_foramtFee := To_char(v_feeNum);
			ELSE
				v_foramtFee := '0' ||To_char(v_feeNum);
			END IF;
		ELSE
			v_foramtFee := To_char(v_feeNum);
		END IF;
		
		RETURN v_feePrefix || v_foramtFee;
	END FORMAT_FEE;
	
	--This procedure will be called in trader Locate Tab and trader Edit Locate Response popup when user save create asset popup.
	PROCEDURE BUILD_LOCATE_INFO_WITH_ASSET( p_locatePreborrowId     IN  NUMBER,
											p_assetId  				IN  NUMBER,
											p_needInsert			IN  VARCHAR2,
											p_rtnLocates  			OUT SYS_REFCURSOR)
	IS
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_TRANSACTION_PKG.BUILD_LOCATE_INFO_WITH_ASSET';
		v_source_cd GEC_LOCATE_PREBORROW.source_cd%TYPE := NULL;
		v_st_gc_rate_type GEC_STRATEGY.st_gc_rate_type%TYPE := NULL;
		v_gc_rate_type GEC_STRATEGY.gc_rate_type%TYPE := NULL;
		v_gc_rate GEC_STRATEGY_PROFILE.gc_rate%TYPE := NULL;
		v_min_sp_rate GEC_STRATEGY_PROFILE.min_sp_rate%TYPE := NULL;

		v_loc_nsb_rate GEC_LOCATE_PREBORROW.nsb_rate%TYPE;
		v_loc_indicative_rate GEC_LOCATE_PREBORROW.indicative_rate%TYPE;

		v_avail_nsb_rate GEC_IM_AVAILABILITY.nsb_rate%TYPE;
		v_avail_indicative_rate GEC_IM_AVAILABILITY.indicative_rate%TYPE;
			
		v_new_avail_id GEC_IM_AVAILABILITY.IM_AVAILABILITY_ID%TYPE;
				
		CURSOR v_cur_asset IS
			SELECT ga.cusip, ga.isin, ga.sedol, ga.ticker, ga.quik, ga.description, ga.trade_country_cd, ga.asset_type_id, 
             	   gar.internal_comment_txt, gar.restriction_cd, gar.position_flag, gar.indicative_rate
			  FROM GEC_ASSET ga
		 LEFT JOIN GEC_ASSET_RATE gar
			    ON ga.asset_id = gar.asset_id			 
			 WHERE ga.asset_id = p_assetId;
	BEGIN
		BEGIN
			SELECT 
				  glp.source_cd, gs.st_gc_rate_type, gs.gc_rate_type, gsp.gc_rate, gsp.min_sp_rate 
		          into 
		          v_source_cd, v_st_gc_rate_type, v_gc_rate_type, v_gc_rate, v_min_sp_rate
			 FROM GEC_LOCATE_PREBORROW glp
	   INNER JOIN gec_strategy gs
			   ON glp.strategy_id = gs.strategy_id
			  AND gs.status = 'A'
	    LEFT JOIN GEC_STRATEGY_PROFILE gsp
	           on glp.STRATEGY_ID = gsp.STRATEGY_ID
	          and gsp.TRADE_COUNTRY_CD = glp.TRADE_COUNTRY_CD
	          AND gsp.status ='A'
			WHERE glp.LOCATE_PREBORROW_ID = p_locatePreborrowId;
		EXCEPTION WHEN NO_DATA_FOUND THEN
        	v_st_gc_rate_type := NULL; 
        	v_gc_rate_type := NULL;
        END;       
        
		FOR v_asset in v_cur_asset LOOP
			v_loc_nsb_rate := NULL;
			v_loc_indicative_rate := NULL;			
			
			IF v_gc_rate_type IS NULL AND v_st_gc_rate_type IS NULL THEN
				v_new_avail_id := NULL;
				v_loc_indicative_rate := NULL;
				v_loc_nsb_rate := NULL;
			ELSE
				gec_availability_pkg.GET_INDICATIVE_RATE (
									v_source_cd, 
									v_asset.position_flag, 	
									v_st_gc_rate_type, 		
									v_gc_rate_type,			
									v_asset.indicative_rate,
									NULL, 	
									v_min_sp_rate,			
									v_gc_rate,	
									v_loc_indicative_rate	
									);
				-- INSERT NEW AVAILABILITY									
				IF p_needInsert = 'Y' THEN
					v_avail_nsb_rate := NULL;
					v_avail_indicative_rate := NULL;			
					v_new_avail_id := NULL;	
					
					IF v_asset.indicative_rate IS NULL THEN
						v_avail_nsb_rate := GEC_CONSTANTS_PKG.C_DEFAULT_NSB_RATE;
						v_avail_indicative_rate := GEC_CONSTANTS_PKG.C_DEFAULT_INDICATIVE_RATE;
					ELSE
						v_avail_nsb_rate := gec_availability_pkg.GET_NSB_RATE_FOR_AVAIL(
												nvl(v_asset.position_flag, 'GC'), 
												v_min_sp_rate, 
												v_gc_rate, 
												v_asset.indicative_rate);
						v_avail_indicative_rate := gec_availability_pkg.GET_INDICATE_RATE_FOR_AVAIL(
												nvl(v_asset.position_flag, 'GC'), 
												v_gc_rate_type, 
												v_avail_nsb_rate, 
												v_gc_rate);
					END IF;
					--create new availability for locates that do not have matched availability. --Not required from R1.3
			        -- Insert non-existing avail
					select GEC_IM_Availability_id_seq.nextval into v_new_avail_id from dual;
			        INSERT INTO  GEC_IM_AVAILABILITY  
			                    (IM_Availability_id,   Business_Date,    INVESTMENT_MANAGER_CD,  CLIENT_CD,
			                      ASSET_CODE,           ASSET_CODE_TYPE,  ASSET_ID,               Position_flag, 
			                      NSB_Rate,             NFS_qty,          NFS_rate,				        source_cd,
			                      strategy_id,		  trade_country_cd, 	  STATUS,              
			                      INDICATIVE_RATE,     CREATED_AT,              RESTRICTION_CD,
			                      INTERNAL_COMMENT_TXT)
			        SELECT v_new_avail_id,   qry.Business_Date,	qry.INVESTMENT_MANAGER_CD,  qry.CLIENT_CD,
			                qry.ASSET_CODE,           qry.ASSET_CODE_TYPE,  			qry.ASSET_ID,               qry.Position_flag, 
			                qry.NSB_Rate,             qry.NFS_qty,          			qry.NFS_rate,				        qry.TRANSACTION_CD,
			                qry.strategy_id,		  qry.trade_country_cd,           'A',	                   
			                qry.INDICATIVE_RATE,               SYSDATE,                 qry.RESTRICTION_CD,
			                qry.INTERNAL_COMMENT_TXT
			         FROM( SELECT lp.Business_Date, f.INVESTMENT_MANAGER_CD, f.CLIENT_CD, lp.ASSET_CODE, lp.ASSET_CODE_TYPE, 
			                         p_assetId as ASSET_ID, nvl(v_asset.position_flag, 'GC') AS Position_Flag, 999 AS NSB_Rate, 0 AS NFS_Qty, 0.35 AS NFS_Rate, lp.TRANSACTION_CD,
			                         lp.strategy_id, lp.trade_country_cd, 
			                         v_avail_indicative_rate AS INDICATIVE_RATE, v_asset.RESTRICTION_CD as RESTRICTION_CD,
			                         v_asset.internal_comment_txt as INTERNAL_COMMENT_TXT
			                 FROM GEC_locate_preborrow lp, gec_fund f, GEC_STRATEGY_PROFILE gsp
			                WHERE lp.LOCATE_PREBORROW_ID = p_locatePreborrowId
			                  AND lp.fund_cd = f.fund_cd
			                  AND lp.strategy_id = gsp.strategy_id
			                  AND gsp.trade_country_cd = lp.trade_country_cd
			                  AND lp.STATUS in ('E','P')
			            ) qry;			
				END IF;	-- END p_needInsert = 'Y'
			END IF; -- END v_gc_rate_type = NULL AND v_st_gc_rate_type = NULL
						
			UPDATE GEC_LOCATE_PREBORROW
				   SET 	ASSET_ID = p_assetId,
				   		IM_AVAILABILITY_ID = nvl(v_new_avail_id, IM_AVAILABILITY_ID),
						INDICATIVE_RATE = CASE WHEN TRANSACTION_CD != GEC_CONSTANTS_PKG.C_PREBORROW AND 
													(INDICATIVE_RATE = GEC_CONSTANTS_PKG.C_DEFAULT_INDICATIVE_RATE OR INDICATIVE_RATE IS NULL)
				   		                       THEN v_loc_indicative_rate
				   		                       ELSE INDICATIVE_RATE
				   		                  END,
						--No need to update locate sfa (nsb)rate when update SM. (refer RQ 269)
				   		POSITION_FLAG 	= nvl(v_asset.position_flag, POSITION_FLAG),
				   		RESTRICTION_CD 	= nvl(v_asset.RESTRICTION_CD, RESTRICTION_CD),
				   		internal_comment_txt = gec_utils_pkg.sub_comment(trim(internal_comment_txt|| v_asset.internal_comment_txt)),
				   		CUSIP = v_asset.CUSIP,
				   		ISIN = v_asset.ISIN,
				   		SEDOL = v_asset.SEDOL,
				   		QUIK = v_asset.QUIK,
				   		TICKER = v_asset.TICKER,
				   		ASSET_TYPE_ID = v_asset.ASSET_TYPE_ID,
				   		DESCRIPTION = v_asset.DESCRIPTION				   		
				 WHERE LOCATE_PREBORROW_ID = p_locatePreborrowId;					
				
		END LOOP;	
		
		OPEN p_rtnLocates FOR
			SELECT DISTINCT
	           glp.cusip,
               glp.sedol,
               glp.isin,
               glp.ticker,
               glp.description,
               glp.position_flag,
               glp.trade_country_cd,
               glp.quik,
               glp.internal_comment_txt,
               glp.indicative_rate,
               gr.restriction_abbrv as RESTRICTION_ABBRV,
               glp.nsb_rate,
               glp.asset_type_id,
               glp.im_availability_id,
               glp.LIQUIDITY_FLAG
		  FROM GEC_LOCATE_PREBORROW  glp
     LEFT JOIN GEC_RESTRICTION gr
			ON glp.RESTRICTION_CD = gr.RESTRICTION_CD
      	 WHERE glp.LOCATE_PREBORROW_ID = p_locatePreborrowId;
          
	GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END BUILD_LOCATE_INFO_WITH_ASSET;	
											
END GEC_TRANSACTION_PKG;
/
