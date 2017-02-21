-------------------------------------------------------------------------
-- Copyright (c) 2009 State Street Bank and Trust Corp.
-- 225 Franklin Street, Boston, MA 02110, U.S.A.
-- All rights reserved.
--
-- "GEC_BORROWREQUEST_PKG.sql is the copyrighted,
-- proprietary property of State Street Bank and Trust Company and its
-- subsidiaries and affiliates which retain all right, title and interest
-- therein."
--
-- Revision History
--
-- Date            Programmer                Notes
-- ------------    --------------------      ----------------------------
-- NOV 05, 2010    Yiyang, Shen		         created
-- AUG 22, 2011		Chen, Hui				 updated
-------------------------------------------------------------------------
create or replace PACKAGE GEC_BORROWREQUEST_PKG 
AS
                       
PROCEDURE EXPORT_EQUILEND_BORROW_REQUEST(p_type IN VARCHAR2,
                                           p_request_file_type	IN VARCHAR2,
                                           p_fund IN VARCHAR2,
                                           p_broker_code			IN VARCHAR2,
                                           p_branch_cd			IN VARCHAR2,
                                           p_settle_market		IN VARCHAR2,
                                           p_trade_countries		IN VARCHAR2,
                                           p_coll_type			IN VARCHAR2,
                                           p_coll_code			IN VARCHAR2,
                                           p_include_gc_sp		IN VARCHAR2,
                                           p_settle_dates			IN VARCHAR2,
                                           p_equilend_chain_id     IN NUMBER,
                                           p_equilend_schedule_id  IN NUMBER,
                                           p_auto_release_rule_id  IN NUMBER,
                                           p_request_by			IN VARCHAR2,
                                           p_borrow_request_id 	OUT NUMBER,
                                           p_errorCode         	OUT VARCHAR2,
                                           p_short_ids IN GEC_NUMBER_ARRAY,
                                           p_full_fill IN VARCHAR2,
                                           p_past_date_counts_ps OUT NUMBER);
PROCEDURE FILL_DEMANDS_WITH_SHORTS( p_borrow_request_id 		IN NUMBER,
                                    p_request_file_type IN VARCHAR2,
                                    p_type			IN VARCHAR2,
                                    p_settle_market		IN VARCHAR2);
PROCEDURE GET_SB_TRADES(p_request_file_type IN VARCHAR2,
                    p_fund IN VARCHAR2,
				    p_broker_code  		IN VARCHAR2,
                    p_branch_cd   IN VARCHAR2,
                    p_trade_countries 	IN VARCHAR2,
				    p_coll_type  		IN VARCHAR2,
                    p_coll_code			IN VARCHAR2,
				    p_include_gc_sp		IN VARCHAR2,
                    p_settle_dates 		IN VARCHAR2,
                    p_order_flag IN VARCHAR2);
PROCEDURE GET_NSB_TRADES(p_request_file_type IN VARCHAR2,
                    p_fund IN VARCHAR2,
				    p_broker_code  		IN VARCHAR2,
                    p_branch_cd   IN VARCHAR2,
                    p_trade_countries 	IN VARCHAR2,
				    p_coll_type  		IN VARCHAR2,
                    p_coll_code			IN VARCHAR2,
				    p_include_gc_sp		IN VARCHAR2,
                    p_settle_dates 		IN VARCHAR2,
                    p_order_flag IN VARCHAR2);
PROCEDURE GET_EXT_TRADES(p_fund IN VARCHAR2,
                    p_branch_cd   IN VARCHAR2,
                    p_trade_countries 	IN VARCHAR2,
				    p_coll_type  		IN VARCHAR2,
                    p_coll_code			IN VARCHAR2,
				    p_include_gc_sp		IN VARCHAR2,
                    p_settle_dates 		IN VARCHAR2,
                    p_order_flag IN VARCHAR2);
PROCEDURE SAVE_BORROW_REQUEST_MESSAGES(p_cur_messages OUT SYS_REFCURSOR);
PROCEDURE REMOVE_EXCEPTION_ORDERS(p_auto_release_rule_id  IN NUMBER);
FUNCTION GET_TRADE_COUNTRIES(p_trade_country	IN VARCHAR2)RETURN VARCHAR2;
FUNCTION GET_SETTLE_DATES(p_trade_settle_period		IN VARCHAR2)RETURN VARCHAR2;		      
FUNCTION GET_LOG_NUMBER(p_row_type		IN VARCHAR2,
						p_sys_date_str 	IN VARCHAR2)RETURN VARCHAR2;
FUNCTION GET_EXPIRATION_TIME(p_request_time		IN date,
            p_order_exp_period 	IN VARCHAR2) RETURN date;
PROCEDURE REMOVE_NOT_SELECTED_ORDERS(p_short_ids IN GEC_NUMBER_ARRAY);
PROCEDURE CHECK_PAST_DATE_P_SHARES;
END GEC_BORROWREQUEST_PKG;
/

create or replace PACKAGE BODY GEC_BORROWREQUEST_PKG
AS

	PROCEDURE EXPORT_EQUILEND_BORROW_REQUEST(p_type IN VARCHAR2,
                                           p_request_file_type	IN VARCHAR2,
                                           p_fund IN VARCHAR2,
                                           p_broker_code			IN VARCHAR2,
                                           p_branch_cd			IN VARCHAR2,
                                           p_settle_market		IN VARCHAR2,
                                           p_trade_countries		IN VARCHAR2,
                                           p_coll_type			IN VARCHAR2,
                                           p_coll_code			IN VARCHAR2,
                                           p_include_gc_sp		IN VARCHAR2,
                                           p_settle_dates			IN VARCHAR2,
                                           p_equilend_chain_id     IN NUMBER,
                                           p_equilend_schedule_id  IN NUMBER,
                                           p_auto_release_rule_id  IN NUMBER,
                                           p_request_by			IN VARCHAR2,
                                           p_borrow_request_id 	OUT NUMBER,
                                           p_errorCode         	OUT VARCHAR2,
                                           p_short_ids IN GEC_NUMBER_ARRAY,
                                           p_full_fill IN VARCHAR2,
                                           p_past_date_counts_ps OUT NUMBER)
	IS
	V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_BORROWREQUEST_PKG.EXPORT_EQUILEND_BORROW_REQUEST';
    v_trade_countries VARCHAR2(500) := p_trade_countries;
    v_settle_dates VARCHAR2(200) := p_settle_dates;
    v_count_shorts NUMBER := 0;
    v_request_time date := sysdate;
    v_order_exp_period GEC_CONFIG.ATTR_VALUE1%TYPE := null;
    v_expiration_time date := null;
	v_request_type GEC_BRW_REQUEST_FILE_TYPE.BORROW_REQUEST_TYPE%TYPE;
    v_auto_borrow_batch_id GEC_BORROW_REQUEST.AUTOBORROW_BATCH_ID%TYPE;
    v_count_flag NUMBER :=0;
    p_order_flag VARCHAR2(1) := 'N';
    p_request_file_type_tmp GEC_BRW_REQUEST_FILE_TYPE.BORROW_REQUEST_FILE_TYPE%TYPE;
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
    -- INSERT INTO T_CONTENT(p_type,p_request_file_type,p_fund,p_broker_code,p_branch_cd,p_settle_market,p_trade_countries,p_coll_type,
    -- p_coll_code,p_include_gc_sp,p_settle_dates,p_equilend_chain_id,p_equilend_schedule_id,p_auto_release_rule_id,p_request_by)
    -- VALUES(p_type,p_request_file_type,p_fund,p_broker_code,p_branch_cd,p_settle_market,p_trade_countries,p_coll_type,
    -- p_coll_code,p_include_gc_sp,p_settle_dates,p_equilend_chain_id,p_equilend_schedule_id,p_auto_release_rule_id,p_request_by);

    --handle the parameters for auto release
    IF p_type = GEC_CONSTANTS_PKG.C_AUTO_RELEASE_REQUEST THEN
      v_trade_countries := GET_TRADE_COUNTRIES(p_trade_countries);
      v_settle_dates := GET_SETTLE_DATES(p_settle_dates);
    END IF;

	--gec2.1 change, remove not selected orders
	IF p_short_ids IS NOT NULL and p_short_ids.COUNT>0 THEN
    	p_order_flag := 'Y';
    ELSE
    	p_order_flag := 'N';
	END IF;

    --insert trades to temp table
    IF p_request_file_type = GEC_CONSTANTS_PKG.C_SB_REQUEST OR p_request_file_type = GEC_CONSTANTS_PKG.C_SBO_REQUEST THEN
      GET_SB_TRADES(p_request_file_type,p_fund,p_broker_code,p_branch_cd,v_trade_countries,p_coll_type,p_coll_code,p_include_gc_sp,v_settle_dates,p_order_flag);
    ELSE IF p_request_file_type = GEC_CONSTANTS_PKG.C_NSB_REQUEST OR p_request_file_type = GEC_CONSTANTS_PKG.C_NC_REQUEST THEN
      GET_NSB_TRADES(p_request_file_type,p_fund,p_broker_code,p_branch_cd,v_trade_countries,p_coll_type,p_coll_code,p_include_gc_sp,v_settle_dates,p_order_flag);
    ELSE IF p_request_file_type = GEC_CONSTANTS_PKG.C_EXTERNAL_REQUEST THEN
      GET_EXT_TRADES(p_fund,p_branch_cd,v_trade_countries,p_coll_type,p_coll_code,p_include_gc_sp,v_settle_dates,p_order_flag);
    ELSE 
        p_errorCode := GEC_ERROR_CODE_PKG.C_BORROW_REQUEST_INVALID_TYPE;
        RETURN;
    END IF;
    END IF;
    END IF;
    
    --remove the exceptions for auto release
    IF p_type = GEC_CONSTANTS_PKG.C_AUTO_RELEASE_REQUEST THEN 
      REMOVE_EXCEPTION_ORDERS(p_auto_release_rule_id);
    END IF;

	--gec2.1 change, remove not selected orders
	IF p_order_flag = 'Y' THEN
	  	REMOVE_NOT_SELECTED_ORDERS(p_short_ids);
	END IF;
	
	--No demand
    select count(*) into v_count_shorts from GEC_INFLIGHT_SHORT_TEMP;
		IF v_count_shorts = 0 THEN
			RETURN;
		END IF;
	
	CHECK_PAST_DATE_P_SHARES;
	
	--Past date counts of P Shares 
    select count(*) into p_past_date_counts_ps from GEC_INFLIGHT_SHORT_TEMP;
		IF p_past_date_counts_ps = 0 THEN
			p_past_date_counts_ps :=v_count_shorts;
			RETURN;
		END IF;
	p_past_date_counts_ps := v_count_shorts-p_past_date_counts_ps;
	
    --Get order expire time for schedule
    IF p_equilend_schedule_id is not null THEN
      select ATTR_VALUE1 into v_order_exp_period from GEC_CONFIG where attr_group='EQUILEND' AND attr_name = 'ORDER_EXP_PERIOD';
      v_expiration_time := GET_EXPIRATION_TIME(v_request_time,v_order_exp_period);
      --DBMS_OUTPUT.put_LINE('the expiration is:'||v_expiration_time);
    END IF;
    
    --Get auto borrow batch id
    SELECT TO_CHAR(sysdate, 'YYYYMMDD') || LPAD( GEC_UTILS_PKG.RIGHT_ ( GEC_AUTO_BORROW_BATCH_ID_SEQ.NEXTVAL , 16), 16, '0') 
    INTO v_auto_borrow_batch_id from dual;
    --gec2.1 change
    p_request_file_type_tmp := p_request_file_type;
    IF p_request_file_type = GEC_CONSTANTS_PKG.C_NSB_REQUEST AND P_EQUILEND_SCHEDULE_ID IS NOT NULL THEN
      SELECT COUNT(1) INTO v_count_flag
	  FROM GEC_SCHEDULE SCH 
	  LEFT JOIN GEC_BROKER_VW BRO ON SCH.BROKER_CD =  BRO.BROKER_CD
      WHERE BRO.AGENCY_FLAG = 'N'
      AND SCH.EQUILEND_SCHEDULE_ID = P_EQUILEND_SCHEDULE_ID;
      IF v_count_flag >0 THEN
      	p_request_file_type_tmp := GEC_CONSTANTS_PKG.C_EXTERNAL_REQUEST;
      END IF;
    ELSIF p_request_file_type = GEC_CONSTANTS_PKG.C_NSB_REQUEST AND P_EQUILEND_CHAIN_ID IS NOT NULL THEN
      SELECT COUNT(1) INTO v_count_flag
      FROM GEC_CHAIN GC 
      LEFT JOIN  GEC_CHAIN_SCHEDULE GCS
      ON GC.CHAIN_ID= GCS.CHAIN_ID
      LEFT JOIN GEC_BROKER_VW BRO
      ON BRO.BROKER_CD = GCS.BROKER_CD
      WHERE  BRO.AGENCY_FLAG = 'N'
      AND GC.EQUILEND_CHAIN_ID = P_EQUILEND_CHAIN_ID;
      IF v_count_flag >0 THEN
      	p_request_file_type_tmp := GEC_CONSTANTS_PKG.C_EXTERNAL_REQUEST;
      END IF;
    END IF; 
    
    --There are demands, Create Request
		SELECT BORROW_REQUEST_TYPE INTO v_request_type FROM GEC_BRW_REQUEST_FILE_TYPE WHERE BORROW_REQUEST_FILE_TYPE = p_request_file_type_tmp;
		SELECT GEC_REQUEST_ID_SEQ.NEXTVAL INTO p_borrow_request_id FROM DUAL;
    INSERT INTO GEC_BORROW_REQUEST(BORROW_REQUEST_ID, AUTOBORROW_BATCH_ID,BORROW_REQUEST_TYPE, BORROW_REQUEST_FILE_TYPE, 
    STATUS, STATUS_MSG,BROKER_CD,BRANCH_CD,SETTLEMENT_MARKET,COLLATERAL_TYPE,COLLATERAL_CURRENCY_CD,EQUILEND_CHAIN_ID,
    EQUILEND_SCHEDULE_ID,type,REQUEST_BY, REQUEST_AT,EXPIRATION_TIME,FULL_FILL)
    VALUES(p_borrow_request_id,decode(p_type,GEC_CONSTANTS_PKG.C_FILE_REQUEST,null,v_auto_borrow_batch_id), v_request_type, p_request_file_type_tmp, 
      GEC_CONSTANTS_PKG.C_INFLIGHT_STATUS, GEC_CONSTANTS_PKG.C_INFLIGHT_STATUS_MSG,p_broker_code,p_branch_cd,p_settle_market,p_coll_type,p_coll_code,
      p_equilend_chain_id,p_equilend_schedule_id, p_type,p_request_by, v_request_time,v_expiration_time,p_full_fill);
    
		--Fill borrow orders and borrow order detail, update borrow request
		FILL_DEMANDS_WITH_SHORTS(p_borrow_request_id,p_request_file_type_tmp,p_type,p_settle_market);
		
		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END EXPORT_EQUILEND_BORROW_REQUEST;

	PROCEDURE FILL_DEMANDS_WITH_SHORTS(p_borrow_request_id 		IN NUMBER,
                                     p_request_file_type IN VARCHAR2,
                                     p_type			IN VARCHAR2,
                                     p_settle_market		IN VARCHAR2)
	IS
		v_borrow_order_id GEC_BORROW_ORDER.BORROW_ORDER_ID%TYPE;
		v_sum_qty NUMBER :=0;
		v_unfilled_qty NUMBER :=0;
		v_sys_date_str VARCHAR2(8);
		v_sys_date DATE;
    v_pending_flag VARCHAR2(1) := 'N';
    v_request_count NUMBER := 0;
		CURSOR v_ranked_shorts IS
			SELECT im_order_id, asset_id, broker_cd, collateral_type,
					collateral_currency_cd, settle_date, share_qty,
					filled_qty, transaction_cd, fund_cd,
					rank() over(partition by  settle_date, asset_id, 
									collateral_type,collateral_currency_cd,broker_cd
									order by im_order_id) rank
			FROM GEC_INFLIGHT_SHORT_TEMP;
	BEGIN
		
		SELECT sysdate into v_sys_date from dual;
		v_sys_date_str := TO_CHAR(v_sys_date, 'YYMMDD');
	
		FOR v_cur_short IN v_ranked_shorts
		LOOP
			v_unfilled_qty := v_cur_short.share_qty - v_cur_short.filled_qty;
			
			--If rank value is 1, it's the start of a new group
			IF v_cur_short.rank = 1 THEN
				
				--Update qty for old demand
				IF v_borrow_order_id IS NOT NULL THEN
					IF mod(v_sum_qty,100) <> 0 AND v_pending_flag = 'N' THEN
						v_pending_flag := 'Y';
					END IF;
					
					UPDATE GEC_BORROW_ORDER SET SHARE_QTY = v_sum_qty WHERE BORROW_ORDER_ID = v_borrow_order_id;
				END IF;
				
				--Create New Borrow Order, and recount sum qty
				v_sum_qty := v_unfilled_qty;
				SELECT GEC_BORROW_ORDER_ID_SEQ.NEXTVAL INTO v_borrow_order_id FROM DUAL;
				INSERT INTO GEC_BORROW_ORDER(BORROW_ORDER_ID,BORROW_REQUEST_ID,LOG_NUMBER,ASSET_ID,BROKER_CD, 
												SETTLE_DATE, COLLATERAL_TYPE, COLLATERAL_CURRENCY_CD,STATUS,STATUS_MSG)
				VALUES(v_borrow_order_id,p_borrow_request_id, GET_LOG_NUMBER(v_cur_short.transaction_cd, v_sys_date_str),
					v_cur_short.asset_id, DECODE(p_request_file_type,GEC_CONSTANTS_PKG.C_EXTERNAL_REQUEST,GEC_CONSTANTS_PKG.C_EXTERNAL_REQUEST,v_cur_short.broker_cd),
					v_cur_short.settle_date, v_cur_short.collateral_type, v_cur_short.collateral_currency_cd,decode(p_type,GEC_CONSTANTS_PKG.C_FILE_REQUEST,null,GEC_CONSTANTS_PKG.C_BORROW_ORDER_INFLIGHT),
                  decode(p_type,GEC_CONSTANTS_PKG.C_FILE_REQUEST,null,GEC_CONSTANTS_PKG.C_BORROW_ORDER_INFLIGHT_MSG));
			ELSE
				v_sum_qty := v_sum_qty + v_unfilled_qty;
			END IF;
				
			--InFlight Order
			UPDATE GEC_IM_ORDER SET EXPORT_STATUS='I', HOLDBACK_FLAG='N', UPDATED_AT= sysdate WHERE IM_ORDER_ID = v_cur_short.im_order_id;
			--Create borrow order detail
			INSERT INTO GEC_BORROW_ORDER_DETAIL(BORROW_ORDER_ID, IM_ORDER_ID, FULL_FILLED_QTY, REQUEST_QTY)
							VALUES(v_borrow_order_id, v_cur_short.im_order_id, v_cur_short.filled_qty, v_unfilled_qty);
		END LOOP;
		
		--Update qty for rest demand
		IF v_borrow_order_id IS NOT NULL THEN
			IF mod(v_sum_qty,100) <> 0 AND v_pending_flag = 'N' THEN
				v_pending_flag := 'Y';
			END IF;
					
			UPDATE GEC_BORROW_ORDER SET SHARE_QTY = v_sum_qty WHERE BORROW_ORDER_ID = v_borrow_order_id;
		END IF;
    
    --Update request count for borrow request
    select count(*) into v_request_count from GEC_BORROW_ORDER where BORROW_REQUEST_ID = p_borrow_request_id;
		update GEC_BORROW_REQUEST set request_count = v_request_count where borrow_request_id = p_borrow_request_id;
		
    --SB/NSB needs no Odd lot, EXT needs Odd lot, except auto release
		IF v_pending_flag ='Y' AND p_request_file_type = GEC_CONSTANTS_PKG.C_EXTERNAL_REQUEST 
    AND p_borrow_request_id IS NOT NULL AND p_type <> GEC_CONSTANTS_PKG.C_AUTO_RELEASE_REQUEST 
    AND p_settle_market = GEC_CONSTANTS_PKG.C_TRADE_CNTRY_US THEN
      UPDATE GEC_BORROW_REQUEST SET STATUS=GEC_CONSTANTS_PKG.C_PENDING_STATUS,
          STATUS_MSG=GEC_CONSTANTS_PKG.C_PENDING_STATUS_MSG 
          WHERE BORROW_REQUEST_ID = p_borrow_request_id;
		END IF;
    
	END FILL_DEMANDS_WITH_SHORTS;

  	PROCEDURE GET_SB_TRADES(p_request_file_type IN VARCHAR2,
                    	p_fund IN VARCHAR2,
				        p_broker_code  		IN VARCHAR2,
                    	p_branch_cd   IN VARCHAR2,
                    	p_trade_countries 	IN VARCHAR2,
				        p_coll_type  		IN VARCHAR2,
                    	p_coll_code			IN VARCHAR2,
				        p_include_gc_sp		IN VARCHAR2,
                    	p_settle_dates 		IN VARCHAR2,
                    	p_order_flag IN VARCHAR2)
	IS
      
  CURSOR v_cur_sb_orders IS
      SELECT im_order.IM_ORDER_ID, 
           im_order.ASSET_ID, 
           im_order.DML_SB_BROKER as BROKER_CD,
           im_order.SB_COLLATERAL_TYPE as COLLATERAL_TYPE, 
           im_order.SB_COLLATERAL_CURRENCY_CD as COLLATERAL_CURRENCY_CD,
           im_order.SETTLE_DATE, 
           im_order.SHARE_QTY, 
           im_order.FILLED_QTY,
           im_order.TRANSACTION_CD, 
           im_order.FUND_CD,
           im_order.POSITION_FLAG,
           im_order.TRADE_COUNTRY_CD
      FROM GEC_PENDING_EXPORT_ORDERS_VW im_order
      JOIN GEC_IM_ORDER_VW lock_orders 
      ON im_order.IM_ORDER_ID = lock_orders.IM_ORDER_ID
      JOIN gec_broker_vw broker 
      ON broker.DML_BROKER_CD = im_order.DML_SB_BROKER
      WHERE im_order.TRANSACTION_CD = decode(p_request_file_type,GEC_CONSTANTS_PKG.C_SBO_REQUEST,GEC_CONSTANTS_PKG.C_SB_SHORT,GEC_CONSTANTS_PKG.C_SHORT)
          AND im_order.FUND_CD = nvl(p_fund,im_order.FUND_CD) --may be null for JOB_AUTO/MANUAL_AUTO/FILE
          AND im_order.BRANCH_CD = nvl(p_branch_cd,im_order.BRANCH_CD) --may be null for MANUAL_AUTO/FILE
          AND im_order.SB_COLLATERAL_TYPE = p_coll_type 
          AND im_order.SB_COLLATERAL_CURRENCY_CD = p_coll_code
          AND instr(nvl(p_trade_countries,im_order.TRADE_COUNTRY_CD), im_order.TRADE_COUNTRY_CD) > 0 --may be null for JOB_AUTO
          AND instr(nvl(p_include_gc_sp,im_order.POSITION_FLAG), im_order.POSITION_FLAG) > 0 --may be null for JOB_AUTO
          AND im_order.HOLDBACK_FLAG = 'N'
          AND broker.DML_BROKER_CD = nvl(p_broker_code,broker.DML_BROKER_CD) --may be null for JOB_AUTO/MANUAL_AUTO/FILE
		  AND broker.BORROW_REQUEST_TYPE = 'SB'
          -- AND instr(p_settle_dates, GEC_UTILS_PKG.NUMBER_TO_CHAR(im_order.SETTLE_DATE)) > 0
          AND lock_orders.EXPORT_STATUS != 'I' AND lock_orders.EXPORT_STATUS != 'C'
      ORDER BY im_order.IM_ORDER_ID ASC
      FOR UPDATE OF lock_orders.IM_ORDER_ID;
	BEGIN		
		--get shorts for SB Trade
      FOR v_item IN v_cur_sb_orders
      LOOP
      	IF p_order_flag = 'Y' AND v_item.SETTLE_DATE >=p_settle_dates THEN
      		INSERT INTO GEC_INFLIGHT_SHORT_TEMP(IM_ORDER_ID,ASSET_ID,BROKER_CD,COLLATERAL_TYPE,COLLATERAL_CURRENCY_CD,SETTLE_DATE,
        	SHARE_QTY,FILLED_QTY,TRANSACTION_CD,FUND_CD,POSITION_FLAG,TRADE_COUNTRY_CD) values(v_item.IM_ORDER_ID,v_item.ASSET_ID,v_item.BROKER_CD,v_item.COLLATERAL_TYPE,
        	v_item.COLLATERAL_CURRENCY_CD,v_item.SETTLE_DATE,v_item.SHARE_QTY,v_item.FILLED_QTY,v_item.TRANSACTION_CD,v_item.FUND_CD,v_item.POSITION_FLAG,v_item.TRADE_COUNTRY_CD);
      	ELSIF p_order_flag = 'N' AND instr(p_settle_dates, GEC_UTILS_PKG.NUMBER_TO_CHAR(v_item.SETTLE_DATE)) > 0 THEN
      		INSERT INTO GEC_INFLIGHT_SHORT_TEMP(IM_ORDER_ID,ASSET_ID,BROKER_CD,COLLATERAL_TYPE,COLLATERAL_CURRENCY_CD,SETTLE_DATE,
        	SHARE_QTY,FILLED_QTY,TRANSACTION_CD,FUND_CD,POSITION_FLAG,TRADE_COUNTRY_CD) values(v_item.IM_ORDER_ID,v_item.ASSET_ID,v_item.BROKER_CD,v_item.COLLATERAL_TYPE,
        	v_item.COLLATERAL_CURRENCY_CD,v_item.SETTLE_DATE,v_item.SHARE_QTY,v_item.FILLED_QTY,v_item.TRANSACTION_CD,v_item.FUND_CD,v_item.POSITION_FLAG,v_item.TRADE_COUNTRY_CD);
      	END IF;        
      END LOOP;
    
	END GET_SB_TRADES;
	
   PROCEDURE GET_NSB_TRADES(p_request_file_type IN VARCHAR2,
                    	p_fund IN VARCHAR2,
				        p_broker_code  		IN VARCHAR2,
                    	p_branch_cd   IN VARCHAR2,
                    	p_trade_countries 	IN VARCHAR2,
				        p_coll_type  		IN VARCHAR2,
                    	p_coll_code			IN VARCHAR2,
				        p_include_gc_sp		IN VARCHAR2,
                    	p_settle_dates 		IN VARCHAR2,
                    	p_order_flag IN VARCHAR2)
	IS
      
  CURSOR v_cur_nsb_orders IS
      SELECT im_order.IM_ORDER_ID, 
           im_order.ASSET_ID, 
           im_order.DML_NSB_BROKER as BROKER_CD,
           im_order.NSB_COLLATERAL_TYPE as COLLATERAL_TYPE, 
           im_order.NSB_COLLATERAL_CURRENCY_CD as COLLATERAL_CURRENCY_CD,
           im_order.SETTLE_DATE, 
           im_order.SHARE_QTY, 
           im_order.FILLED_QTY,
           im_order.TRANSACTION_CD, 
           im_order.FUND_CD,
           im_order.POSITION_FLAG,
           im_order.TRADE_COUNTRY_CD
      FROM GEC_PENDING_EXPORT_ORDERS_VW im_order
      JOIN GEC_IM_ORDER_VW lock_orders 
      ON im_order.IM_ORDER_ID = lock_orders.IM_ORDER_ID
      JOIN gec_broker_vw broker 
      ON broker.DML_BROKER_CD = im_order.DML_NSB_BROKER
      WHERE im_order.TRANSACTION_CD = GEC_CONSTANTS_PKG.C_SHORT
          AND im_order.FUND_CD = nvl(p_fund,im_order.FUND_CD) --may be null for JOB_AUTO/MANUAL_AUTO/FILE
          AND im_order.BRANCH_CD = nvl(p_branch_cd,im_order.BRANCH_CD) --may be null for MANUAL_AUTO/FILE
          AND im_order.NSB_COLLATERAL_TYPE = p_coll_type 
          AND im_order.NSB_COLLATERAL_CURRENCY_CD = p_coll_code
          AND instr(nvl(p_trade_countries,im_order.TRADE_COUNTRY_CD), im_order.TRADE_COUNTRY_CD) > 0 --may be null for JOB_AUTO
          AND instr(nvl(p_include_gc_sp,im_order.POSITION_FLAG), im_order.POSITION_FLAG) > 0 --may be null for JOB_AUTO
          AND im_order.HOLDBACK_FLAG = decode(p_request_file_type,GEC_CONSTANTS_PKG.C_NC_REQUEST,'C','N')
          AND broker.DML_BROKER_CD = nvl(p_broker_code,broker.DML_BROKER_CD) --may be null for JOB_AUTO/MANUAL_AUTO/FILE
		  AND broker.BORROW_REQUEST_TYPE = 'NSB'
          AND broker.NON_CASH_AGENCY_FLAG=decode(p_request_file_type,GEC_CONSTANTS_PKG.C_NC_REQUEST,'Y','N')
          --AND instr(p_settle_dates, GEC_UTILS_PKG.NUMBER_TO_CHAR(im_order.SETTLE_DATE)) > 0
          AND lock_orders.EXPORT_STATUS != 'I' AND lock_orders.EXPORT_STATUS != 'C'
      ORDER BY im_order.IM_ORDER_ID ASC
      FOR UPDATE OF lock_orders.IM_ORDER_ID;
	BEGIN		
		--get shorts for NSB Trade

      FOR v_item IN v_cur_nsb_orders
      LOOP
      	IF p_order_flag = 'Y' AND v_item.SETTLE_DATE >= p_settle_dates THEN
      		INSERT INTO GEC_INFLIGHT_SHORT_TEMP(IM_ORDER_ID,ASSET_ID,BROKER_CD,COLLATERAL_TYPE,COLLATERAL_CURRENCY_CD,SETTLE_DATE,
        	SHARE_QTY,FILLED_QTY,TRANSACTION_CD,FUND_CD,POSITION_FLAG,TRADE_COUNTRY_CD) values(v_item.IM_ORDER_ID,v_item.ASSET_ID,v_item.BROKER_CD,v_item.COLLATERAL_TYPE,
        	v_item.COLLATERAL_CURRENCY_CD,v_item.SETTLE_DATE,v_item.SHARE_QTY,v_item.FILLED_QTY,v_item.TRANSACTION_CD,v_item.FUND_CD,v_item.POSITION_FLAG,v_item.TRADE_COUNTRY_CD);
      	ELSIF p_order_flag = 'N' AND instr(p_settle_dates, GEC_UTILS_PKG.NUMBER_TO_CHAR(v_item.SETTLE_DATE)) > 0 THEN
      		INSERT INTO GEC_INFLIGHT_SHORT_TEMP(IM_ORDER_ID,ASSET_ID,BROKER_CD,COLLATERAL_TYPE,COLLATERAL_CURRENCY_CD,SETTLE_DATE,
        	SHARE_QTY,FILLED_QTY,TRANSACTION_CD,FUND_CD,POSITION_FLAG,TRADE_COUNTRY_CD) values(v_item.IM_ORDER_ID,v_item.ASSET_ID,v_item.BROKER_CD,v_item.COLLATERAL_TYPE,
        	v_item.COLLATERAL_CURRENCY_CD,v_item.SETTLE_DATE,v_item.SHARE_QTY,v_item.FILLED_QTY,v_item.TRANSACTION_CD,v_item.FUND_CD,v_item.POSITION_FLAG,v_item.TRADE_COUNTRY_CD);
      	END IF;
      END LOOP;
    
	END GET_NSB_TRADES;
  
  	PROCEDURE GET_EXT_TRADES(p_fund IN VARCHAR2,
                    	p_branch_cd   IN VARCHAR2,
                    	p_trade_countries 	IN VARCHAR2,
				        p_coll_type  		IN VARCHAR2,
                    	p_coll_code			IN VARCHAR2,
				        p_include_gc_sp		IN VARCHAR2,
                    	p_settle_dates 		IN VARCHAR2,
                    	p_order_flag IN VARCHAR2)
	IS
    CURSOR v_cur_ext_orders IS
      SELECT im_order.IM_ORDER_ID, 
           im_order.ASSET_ID, 
           'External' as BROKER_CD,
           im_order.NSB_COLLATERAL_TYPE as COLLATERAL_TYPE, 
           im_order.NSB_COLLATERAL_CURRENCY_CD as COLLATERAL_CURRENCY_CD,
           im_order.SETTLE_DATE, 
           im_order.SHARE_QTY, 
           im_order.FILLED_QTY,
           im_order.TRANSACTION_CD, 
           im_order.FUND_CD,
           im_order.POSITION_FLAG,
           im_order.TRADE_COUNTRY_CD
      FROM GEC_PENDING_EXPORT_ORDERS_VW im_order
      JOIN GEC_IM_ORDER_VW lock_orders 
      ON im_order.IM_ORDER_ID = lock_orders.IM_ORDER_ID
      WHERE im_order.TRANSACTION_CD = GEC_CONSTANTS_PKG.C_SHORT
          AND im_order.FUND_CD = nvl(p_fund,im_order.FUND_CD) --may be null for JOB_AUTO/MANUAL_AUTO/FILE
          AND im_order.BRANCH_CD = nvl(p_branch_cd,im_order.BRANCH_CD) --may be null for MANUAL_AUTO/FILE
          AND im_order.NSB_COLLATERAL_TYPE = p_coll_type 
          AND im_order.NSB_COLLATERAL_CURRENCY_CD = p_coll_code
          AND instr(nvl(p_trade_countries,im_order.TRADE_COUNTRY_CD), im_order.TRADE_COUNTRY_CD) > 0 --may be null for JOB_AUTO
          AND instr(nvl(p_include_gc_sp,im_order.POSITION_FLAG), im_order.POSITION_FLAG) > 0 --may be null for JOB_AUTO
          AND im_order.HOLDBACK_FLAG = 'N'
          --AND instr(p_settle_dates, GEC_UTILS_PKG.NUMBER_TO_CHAR(im_order.SETTLE_DATE)) > 0
          AND lock_orders.EXPORT_STATUS != 'I' AND lock_orders.EXPORT_STATUS != 'C'
      ORDER BY im_order.IM_ORDER_ID ASC
      FOR UPDATE OF lock_orders.IM_ORDER_ID;
	BEGIN		
  
		--get shorts for EXT Trade
    FOR v_item IN v_cur_ext_orders
    LOOP
    	IF p_order_flag = 'Y' AND v_item.SETTLE_DATE >= p_settle_dates THEN
      		INSERT INTO GEC_INFLIGHT_SHORT_TEMP(IM_ORDER_ID,ASSET_ID,BROKER_CD,COLLATERAL_TYPE,COLLATERAL_CURRENCY_CD,SETTLE_DATE,
      		SHARE_QTY,FILLED_QTY,TRANSACTION_CD,FUND_CD,POSITION_FLAG,TRADE_COUNTRY_CD) values(v_item.IM_ORDER_ID,v_item.ASSET_ID,v_item.BROKER_CD,v_item.COLLATERAL_TYPE,
      		v_item.COLLATERAL_CURRENCY_CD,v_item.SETTLE_DATE,v_item.SHARE_QTY,v_item.FILLED_QTY,v_item.TRANSACTION_CD,v_item.FUND_CD,v_item.POSITION_FLAG,v_item.TRADE_COUNTRY_CD);
      	ELSIF p_order_flag = 'N' AND instr(p_settle_dates, GEC_UTILS_PKG.NUMBER_TO_CHAR(v_item.SETTLE_DATE)) > 0 THEN
      		INSERT INTO GEC_INFLIGHT_SHORT_TEMP(IM_ORDER_ID,ASSET_ID,BROKER_CD,COLLATERAL_TYPE,COLLATERAL_CURRENCY_CD,SETTLE_DATE,
      		SHARE_QTY,FILLED_QTY,TRANSACTION_CD,FUND_CD,POSITION_FLAG,TRADE_COUNTRY_CD) values(v_item.IM_ORDER_ID,v_item.ASSET_ID,v_item.BROKER_CD,v_item.COLLATERAL_TYPE,
      		v_item.COLLATERAL_CURRENCY_CD,v_item.SETTLE_DATE,v_item.SHARE_QTY,v_item.FILLED_QTY,v_item.TRANSACTION_CD,v_item.FUND_CD,v_item.POSITION_FLAG,v_item.TRADE_COUNTRY_CD);
      	END IF;
    END LOOP;
    
	END GET_EXT_TRADES;

  PROCEDURE SAVE_BORROW_REQUEST_MESSAGES(p_cur_messages OUT SYS_REFCURSOR)
  IS
  v_message_id GEC_EQUILEND_MESSAGE.EQUILEND_MESSAGE_ID%TYPE;
  CURSOR v_cur_messages IS
  select * from GEC_EQUILEND_MESSAGE_TEMP;
  BEGIN
      FOR v_item IN v_cur_messages
      LOOP
        SELECT GEC_EQUILEND_MESSAGE_ID_SEQ.NEXTVAL into v_message_id from DUAL;
        INSERT INTO GEC_EQUILEND_MESSAGE(EQUILEND_MESSAGE_ID,MESSAGE_TYPE,MESSAGE_SUB_TYPE,EQL_PROGRAM_REF,STATUS,
        MESSAGE_CONTENT,IN_OUT,CREATED_AT,CREATED_BY)VALUES(v_message_id,v_item.MESSAGE_TYPE,v_item.MESSAGE_SUB_TYPE,
        v_item.EQL_PROGRAM_REF,v_item.STATUS,v_item.MESSAGE_CONTENT,v_item.IN_OUT,v_item.CREATED_AT,v_item.CREATED_BY);
        --INSERT INTO GEC_EQL_MSG_BRW_REQ(EQUILEND_MESSAGE_ID,BORROW_REQUEST_ID)VALUES(v_message_id,v_item.BORROW_REQUEST_ID);
        INSERT INTO GEC_EQL_MSG_BRW_ORDER(EQUILEND_MESSAGE_ID,BORROW_ORDER_ID)VALUES(v_message_id,v_item.BORROW_ORDER_ID);
      END LOOP;
      OPEN p_cur_messages FOR
				SELECT message.EQUILEND_MESSAGE_ID,
        message.MESSAGE_CONTENT
				FROM GEC_EQUILEND_MESSAGE message
        JOIN GEC_EQL_MSG_BRW_ORDER msg_brw_order
        ON message.EQUILEND_MESSAGE_ID = msg_brw_order.EQUILEND_MESSAGE_ID
		WHERE msg_brw_order.BORROW_ORDER_ID in (select BORROW_ORDER_ID from GEC_EQUILEND_MESSAGE_TEMP );
  END SAVE_BORROW_REQUEST_MESSAGES;
  
  PROCEDURE REMOVE_EXCEPTION_ORDERS(p_auto_release_rule_id  IN NUMBER)
  IS 
    v_trade_countries VARCHAR2(500) := '';
    v_settle_dates VARCHAR2(200) := '';
    CURSOR v_cur_exceptions IS 
    select POSITION_FLAG,
    TRADE_COUNTRY_CD,
    TRADE_SETTLE_PERIOD,
    FUND_CD
    from GEC_AUTORELEASE_EXCEPTION 
    where AUTORELEASE_RULE_ID = p_auto_release_rule_id;
  BEGIN
    --delete the orders where in exception rule tables
    FOR v_item IN v_cur_exceptions
		LOOP
      v_trade_countries := GET_TRADE_COUNTRIES(v_item.TRADE_COUNTRY_CD);
      v_settle_dates := GET_SETTLE_DATES(v_item.TRADE_SETTLE_PERIOD);
      delete from GEC_INFLIGHT_SHORT_TEMP 
      where instr(nvl(v_item.POSITION_FLAG,POSITION_FLAG), POSITION_FLAG)> 0
      AND instr(nvl(v_trade_countries,TRADE_COUNTRY_CD), TRADE_COUNTRY_CD)>0
      AND instr(nvl(v_settle_dates,SETTLE_DATE), SETTLE_DATE)>0
      AND instr(nvl(v_item.FUND_CD,FUND_CD),FUND_CD)>0;
    END LOOP;
  END REMOVE_EXCEPTION_ORDERS;
  
  PROCEDURE REMOVE_NOT_SELECTED_ORDERS(p_short_ids IN GEC_NUMBER_ARRAY)
  IS
  	CURSOR temp_cur
  	IS
  	SELECT 
  		IM_ORDER_ID,
  		ASSET_ID,
  		BROKER_CD,
  		COLLATERAL_TYPE,
  		COLLATERAL_CURRENCY_CD,
  		SETTLE_DATE,
        SHARE_QTY,
        FILLED_QTY,
        TRANSACTION_CD,
        FUND_CD,
        POSITION_FLAG,
        TRADE_COUNTRY_CD
    FROM GEC_INFLIGHT_SHORT_TEMP  GIFT
	INNER JOIN TABLE ( CAST ( p_short_ids AS GEC_NUMBER_ARRAY) ) ORDERS
	ON GIFT.IM_ORDER_ID = ORDERS.COLUMN_VALUE;
	v_item temp_cur%ROWTYPE;
  BEGIN
  	OPEN temp_cur; 
    delete from GEC_INFLIGHT_SHORT_TEMP;
    LOOP
      FETCH temp_cur INTO v_item;
      EXIT WHEN temp_cur%NOTFOUND;
      INSERT INTO GEC_INFLIGHT_SHORT_TEMP(IM_ORDER_ID,ASSET_ID,BROKER_CD,COLLATERAL_TYPE,COLLATERAL_CURRENCY_CD,SETTLE_DATE,
      	SHARE_QTY,FILLED_QTY,TRANSACTION_CD,FUND_CD,POSITION_FLAG,TRADE_COUNTRY_CD) values(v_item.IM_ORDER_ID,v_item.ASSET_ID,v_item.BROKER_CD,v_item.COLLATERAL_TYPE,
      	v_item.COLLATERAL_CURRENCY_CD,v_item.SETTLE_DATE,v_item.SHARE_QTY,v_item.FILLED_QTY,v_item.TRANSACTION_CD,v_item.FUND_CD,v_item.POSITION_FLAG,v_item.TRADE_COUNTRY_CD);		
    END LOOP;
    CLOSE temp_cur;
  END REMOVE_NOT_SELECTED_ORDERS;
  
  PROCEDURE CHECK_PAST_DATE_P_SHARES
  IS 
    p_errorCode VARCHAR2(50) := NULL;
    CURSOR v_cur_p_shares IS 
    	SELECT  
    		gist.ASSET_ID,
    		gist.IM_ORDER_ID,
    		gist.SETTLE_DATE,
    		gist.TRADE_COUNTRY_CD,
    		fund.FUND_CATEGORY_CD,
    		gccm.COUNTRY_CATEGORY_CD
    	FROM GEC_INFLIGHT_SHORT_TEMP gist
    	LEFT JOIN GEC_FUND fund ON fund.FUND_CD = gist.FUND_CD
		LEFT JOIN GEC_COUNTRY_CATEGORY_MAP gccm ON gist.TRADE_COUNTRY_CD = gccm.COUNTRY_CD;
  BEGIN
    --delete the past date orders of p shares
    FOR v_item IN v_cur_p_shares
	LOOP
      	IF (v_item.COUNTRY_CATEGORY_CD = 'PS1' OR  v_item.COUNTRY_CATEGORY_CD = 'PS2')
      		 AND v_item.FUND_CATEGORY_CD = 'OBF' THEN
      		GEC_VALIDATION_PKG.VALIDATE_SETTLE_DATE(v_item.ASSET_ID,v_item.SETTLE_DATE,v_item.TRADE_COUNTRY_CD,p_errorCode);
      		IF p_errorCode IS NOT NULL THEN
      			DELETE FROM GEC_INFLIGHT_SHORT_TEMP where IM_ORDER_ID = v_item.IM_ORDER_ID;
      		END IF;
      	END IF;
    END LOOP;
    
  END CHECK_PAST_DATE_P_SHARES;
  
  FUNCTION GET_TRADE_COUNTRIES(p_trade_country	IN VARCHAR2)RETURN VARCHAR2
  IS 
    v_trade_countries VARCHAR2(500) := '';
    v_first VARCHAR2(1) := 'Y';
    CURSOR v_cur_trade_countries IS
    select TRADE_COUNTRY_CD, PREBORROW_ELIGIBLE_FLAG
    FROM GEC_TRADE_COUNTRY
    WHERE status = 'A';
  BEGIN 
  	IF GEC_CONSTANTS_PKG.C_TRADE_CNTRY_NON_US = p_trade_country THEN
			FOR v_item IN v_cur_trade_countries
      LOOP
				IF GEC_CONSTANTS_PKG.C_TRADE_CNTRY_US <> v_item.TRADE_COUNTRY_CD AND
					GEC_CONSTANTS_PKG.C_TRADE_CNTRY_CA <> v_item.TRADE_COUNTRY_CD AND
					v_item.PREBORROW_ELIGIBLE_FLAG = 'N' THEN
          --DBMS_OUTPUT.put_LINE('the trade countries is:'||v_trade_countries);
          IF v_first = 'Y' THEN
            v_first := 'N';
            v_trade_countries := v_trade_countries || v_item.TRADE_COUNTRY_CD;
          ELSE
            v_trade_countries := v_trade_countries || ',' || v_item.TRADE_COUNTRY_CD;
          END IF;
        END IF;
			END LOOP;
		ELSE
			v_trade_countries := p_trade_country;
		END IF;
    RETURN v_trade_countries;
  END GET_TRADE_COUNTRIES;
  
	FUNCTION GET_SETTLE_DATES(p_trade_settle_period		IN VARCHAR2) RETURN VARCHAR2
	IS

		v_date_array GEC_UTILS_PKG.t_number_array;
		v_settle_dates VARCHAR2(200) := '';
		v_first VARCHAR2(1) := 'Y';
		v_curr_date NUMBER;
    abc varchar2(10):= '';
	BEGIN
		v_date_array := GEC_UTILS_PKG.SPLIT_TO_NUMBER_ARRAY(p_trade_settle_period);
		
		FOR i IN 1..v_date_array.count LOOP
			v_curr_date := GEC_UTILS_PKG.GET_TPLUSN_NUM(GEC_UTILS_PKG.DATE_TO_NUMBER(sysdate), v_date_array(i),'ALL','S');
			IF v_first = 'Y' THEN
				v_first := 'N';
				v_settle_dates := v_settle_dates || v_curr_date;
			ELSE
				v_settle_dates := v_settle_dates || ',' || v_curr_date;
			END IF;
		END LOOP;
		RETURN v_settle_dates;
	END GET_SETTLE_DATES;
	
	--Row Type is SHORT OR TRAILER, We'll substr to get the first letter
	FUNCTION GET_LOG_NUMBER(p_row_type		IN VARCHAR2,
							p_sys_date_str 	IN VARCHAR2) RETURN VARCHAR2
	IS
		v_log_number   GEC_BORROW_ORDER.LOG_NUMBER%TYPE;
		v_sys_date_str VARCHAR2(10) := p_sys_date_str;
	BEGIN
		IF v_sys_date_str IS NULL THEN
			SELECT TO_CHAR(sysdate, 'YYMMDD') into v_sys_date_str from dual;
		END IF;
		
		SELECT SUBSTR(p_row_type, 1, 1) || '-' || v_sys_date_str || '-' || LPAD( GEC_UTILS_PKG.RIGHT_ ( GEC_Log_Number_SEQ.NEXTVAL , 11), 11, '0')
			   INTO v_log_number from dual;
		
		RETURN v_log_number;
	END GET_LOG_NUMBER;

	FUNCTION GET_EXPIRATION_TIME(p_request_time		IN date,
							p_order_exp_period 	IN VARCHAR2) RETURN date
	IS
		v_expiration_time date;
    v_h number := to_number(SUBSTR(p_order_exp_period,1,2));
    v_m number := to_number(SUBSTR(p_order_exp_period,3,2));
    v_s number := to_number(SUBSTR(p_order_exp_period,5,2));
	BEGIN
		v_expiration_time := p_request_time + v_h/24 + v_m/(24*60) + v_s/(24*60*60);

		RETURN v_expiration_time;
	END GET_EXPIRATION_TIME;
	
	
END GEC_BORROWREQUEST_PKG;
/