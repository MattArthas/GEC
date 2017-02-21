CREATE OR REPLACE PACKAGE GEC_IM_ORDER_PKG
AS

	PROCEDURE UPDATE_ORDER_STATUS(p_status IN VARCHAR2,p_imOrderId IN NUMBER,p_updatedBy IN VARCHAR2,p_retOrders OUT SYS_REFCURSOR);
	
	PROCEDURE OPEN_MODIFIED_SHORT(p_imOrderId IN NUMBER,p_retOrders OUT SYS_REFCURSOR);
	PROCEDURE OPEN_MODIFIED_COVER(p_imOrderId IN NUMBER,p_retOrders OUT SYS_REFCURSOR);
	PROCEDURE OPEN_SHORT_AND_CANCEL(p_imOrderId IN NUMBER,p_retOrders OUT SYS_REFCURSOR);
	
	PROCEDURE OPEN_NULL_CURSOR(p_retOrders OUT SYS_REFCURSOR);
	
	PROCEDURE UPDATE_ORDERS_FOR_NORESPONSE(p_borrowRequestId IN NUMBER,p_retOrders OUT SYS_REFCURSOR,p_borrowRequest OUT SYS_REFCURSOR);
	
	PROCEDURE OPEN_PRE_BOOK_SHORT(p_im_order_ids IN GEC_NUMBER_ARRAY,
	                              p_error_code OUT VARCHAR2,
                                  p_pre_book_orders OUT SYS_REFCURSOR);
                                  
    PROCEDURE UPLOAD_ORDERS(p_uploadedBy IN VARCHAR2, p_retOrderList OUT SYS_REFCURSOR, p_retLocatedIds  OUT SYS_REFCURSOR);
	PROCEDURE UPLOAD_ORDERS_INPUT(p_uploadedBy IN VARCHAR2, p_retLocatedIds  OUT SYS_REFCURSOR);
	
END GEC_IM_ORDER_PKG;
/


CREATE OR REPLACE PACKAGE BODY GEC_IM_ORDER_PKG
AS
	PROCEDURE UPDATE_ORDER_STATUS(p_status IN VARCHAR2,p_imOrderId IN NUMBER,p_updatedBy IN VARCHAR2,p_retOrders OUT SYS_REFCURSOR)
	IS
		v_export_status VARCHAR2(1);
		v_status  VARCHAR2(1);
		v_transType VARCHAR2(20);
		v_filled_qty GEC_IM_ORDER.FILLED_QTY%TYPE;
		v_handled_flag VARCHAR2(1) := 'N';
		v_cancel_order_id NUMBER(38,0) :=0;
		v_sum_allocation_qty GEC_IM_ORDER.FILLED_QTY%TYPE;
		CURSOR v_cur_order IS
			SELECT EXPORT_STATUS,
					STATUS,
					TRANSACTION_CD,
					FILLED_QTY
			FROM GEC_IM_ORDER 
			WHERE IM_ORDER_ID = p_imOrderId FOR UPDATE;
	BEGIN
		OPEN_NULL_CURSOR(p_retOrders);
	
		FOR v_item IN v_cur_order
		LOOP
			v_export_status := v_item.EXPORT_STATUS;
			v_status := v_item.STATUS;
			v_transType := v_item.TRANSACTION_CD;
			v_filled_qty := v_item.FILLED_QTY;
		END LOOP;
		
		IF v_export_status = 'I' THEN
			RETURN;
		END IF;
		
		IF v_transType = GEC_CONSTANTS_PKG.C_SHORT AND p_status = 'C' AND ( v_status = 'P' OR v_status = 'E' ) AND v_filled_qty>0 THEN
			
			BEGIN
				SELECT 'Y' INTO v_handled_flag
				FROM GEC_IM_ORDER 
				WHERE MATCHED_ID = p_imOrderId;
				EXCEPTION WHEN NO_DATA_FOUND THEN
					v_handled_flag :='N';
			END;
			IF v_handled_flag='N' THEN 
				SELECT GEC_IM_ORDER_ID_SEQ.nextval INTO v_cancel_order_id FROM DUAL;
				
				INSERT INTO GEC_IM_ORDER ( 
				im_order_id, 
				BUSINESS_DATE, INVESTMENT_MANAGER_CD, 
				TRANSACTION_CD, FUND_CD, Share_Qty, 
	            ASSET_ID, ASSET_CODE, ASSET_CODE_TYPE, 
				Reserved_SB_Qty, RESERVED_SB_QTY_RAL , Reserved_NSB_Qty, 
				SOURCE_CD, UPDATED_BY, STATUS, 
				SETTLE_DATE, Position_Flag, 
	            SB_Broker_Cd, UPDATED_AT, RESTRICTION_CD, 
	            Reserved_NFS_Qty, Reserved_EXT2_Qty, Trade_Date, 
	            CREATED_BY, CREATED_AT,
				CUSIP, ISIN, SEDOL, QUIK, TRADE_COUNTRY_CD,
				TICKER, DESCRIPTION, FILE_VERSION ,
	            at_point_avail_qty, asset_type_id,matched_id)
		            SELECT  v_cancel_order_id as IM_ORDER_ID, 
					BUSINESS_DATE, INVESTMENT_MANAGER_CD, 
					GEC_CONSTANTS_PKG.C_SHORT_CANCEL as TRANSACTION_CD, FUND_CD, Share_Qty, 
					ASSET_ID, ASSET_CODE, ASSET_CODE_TYPE, 
					Reserved_SB_Qty, RESERVED_SB_QTY_RAL , Reserved_NSB_Qty, 
					'Manual - UI' as SOURCE_CD, p_updatedBy as UPDATED_BY, CASE EXPORT_STATUS WHEN 'I' THEN 'P' ELSE 'M' END AS STATUS, 
					SETTLE_DATE,Position_Flag, 
		            SB_Broker_Cd, SYSDATE as UPDATED_AT, RESTRICTION_CD, 
		            Reserved_NFS_Qty,Reserved_EXT2_Qty, Trade_Date, 
		            p_updatedBy as CREATED_BY, SYSDATE as CREATED_AT,
					CUSIP, ISIN, SEDOL, QUIK, TRADE_COUNTRY_CD,
					TICKER, DESCRIPTION, FILE_VERSION ,
					at_point_avail_qty,  asset_type_id, p_imOrderId as matched_id
						FROM GEC_IM_ORDER WHERE IM_ORDER_ID= p_imOrderId;
						
				UPDATE GEC_IM_ORDER SET FILLED_QTY=SHARE_QTY, MATCHED_ID=v_cancel_order_id, UPDATED_AT=SYSDATE WHERE IM_ORDER_ID= p_imOrderId;
				
				UPDATE GEC_IM_ORDER
				SET STATUS=p_status,
					UPDATED_BY = p_updatedBy,
					UPDATED_AT = SYSDATE
				WHERE IM_ORDER_ID=p_imOrderId;
					
				OPEN_SHORT_AND_CANCEL(p_imOrderId,p_retOrders);
			ELSE
				RETURN;
			END IF;
			
		ELSE
		
			IF v_transType = GEC_CONSTANTS_PKG.C_SHORT AND p_status = 'P' AND v_status = 'C' THEN
				SELECT SUM(ALLOCATION_QTY) FILLED_QTY INTO v_sum_allocation_qty FROM gec_allocation WHERE im_order_id=p_imOrderId;
				UPDATE GEC_IM_ORDER
				SET STATUS=p_status,
					FILLED_QTY= decode(v_sum_allocation_qty,null,0,v_sum_allocation_qty),
					MATCHED_ID = NULL,
					UPDATED_BY = p_updatedBy,
					UPDATED_AT = SYSDATE
				WHERE IM_ORDER_ID=p_imOrderId;
				UPDATE GEC_IM_ORDER
				SET MATCHED_ID = NULL,
					UPDATED_BY = p_updatedBy,
					UPDATED_AT = SYSDATE
				WHERE MATCHED_ID = p_imOrderId;
			ELSE
				UPDATE GEC_IM_ORDER
				SET STATUS=p_status,
					UPDATED_BY = p_updatedBy,
					UPDATED_AT = SYSDATE
				WHERE IM_ORDER_ID=p_imOrderId;
			END IF;
			
			IF v_transType = GEC_CONSTANTS_PKG.C_SHORT THEN
				OPEN_MODIFIED_SHORT(p_imOrderId,p_retOrders);
			ELSE
				OPEN_MODIFIED_COVER(p_imOrderId,p_retOrders);
			END IF;
		END IF;
	
	END UPDATE_ORDER_STATUS;
	
	PROCEDURE OPEN_MODIFIED_SHORT(p_imOrderId IN NUMBER,p_retOrders OUT SYS_REFCURSOR)
	IS
		CURSOR v_cur_order IS
			SELECT FUND_CD,ASSET_ID
			FROM GEC_IM_ORDER 
			WHERE IM_ORDER_ID = p_imOrderId;
		
		v_fundCd GEC_IM_ORDER.FUND_CD%type;
		v_assetId GEC_IM_ORDER.ASSET_ID%type;
	BEGIN
		FOR item IN  v_cur_order
		LOOP
			v_fundCd := item.FUND_CD;
			v_assetId := item.ASSET_ID;
		END LOOP;
		OPEN p_retOrders FOR
					SELECT 	gio.IM_ORDER_ID,
						DECODE(gio.TRANSACTION_CD,'COVER',null,gio.HOLDBACK_FLAG) HOLDBACK_FLAG,
						gtc.TRADING_DESK_CD,
						gio.TRADE_COUNTRY_CD,
						gio.INVESTMENT_MANAGER_CD,
						gs.STRATEGY_NAME STRATEGY,
						gio.FUND_CD,
						gio.TRANSACTION_CD,
						gio.SB_BROKER_CD,
						gio.STATUS,
						DECODE(gio.TRANSACTION_CD,'COVER',null,gio.EXPORT_STATUS) EXPORT_STATUS,
						gio.CUSIP,
						gio.ASSET_ID,
						gio.DESCRIPTION,
						null BROKER_CD,
						gio.SHARE_QTY,
		       			gio.FILLED_QTY,
						(gio.SHARE_QTY-NVL(gio.FILLED_QTY,0)) UNFILLED_QTY,
						gio.TRADE_DATE,
						gio.P_SHARES_SETTLE_DATE,
						gio.SETTLE_DATE,
						gio.G1_EXTRACTED_AT,
						gio.G1_EXTRACTED_FLAG,
						gio.TICKER,
						gio.SEDOL,
						gio.ISIN,
						gio.QUIK,
						UPPER(gat.ASSET_TYPE_DESC) SECURITY_TYPE,
						r.RESTRICTION_ABBRV,
						gio.POSITION_FLAG,
						gio.UPDATED_AT,
						gio.CREATED_AT,
						gio.COMMENT_TXT,
						gu.NSB_COLLATERAL_TYPE,
						gu.BRANCH_CD,
						gio.RATE,
						gio.SETTLEMENT_LOCATION_CD,
						gio.LEGAL_ENTITY_CD,
						gu.G1_INSTANCE_CD,
						CASE WHEN gio.transaction_cd = 'SHORT' AND EXISTS (
					      	select 1 from gec_im_order c
					        		where c.status not in ('X','C')
						       			and c.transaction_cd='COVER'
										and gio.asset_id = c.asset_id 
										and gio.settle_date!=c.settle_date
										and c.settle_date>=GEC_UTILS_PKG.DATE_TO_NUMBER(SYSDATE)) AND gio.status not in ('X','C') 
						THEN 'Y'
					     WHEN gio.transaction_cd = 'COVER'
					     		THEN NULL
					     ELSE 'N'
						END AS SHORT_IS_COVERED,
						CASE WHEN gio.transaction_cd = 'COVER' AND gio.status not in ('X','C')  AND  EXISTS (
							select 1 from gec_im_order s
									where s.G1_EXTRACTED_AT IS NULL
				              			and s.transaction_cd='SHORT'
				               			and s.status not in ('X','C')
				               			and gio.fund_cd = s.fund_cd 
								      	and gio.asset_id = s.asset_id
								      	and s.settle_date>GEC_UTILS_PKG.DATE_TO_NUMBER(SYSDATE)
								      	and gio.settle_date>GEC_UTILS_PKG.DATE_TO_NUMBER(SYSDATE)) 
									THEN 'Y'
						     WHEN gio.transaction_cd = 'SHORT'
						     		THEN NULL
						     ELSE 'N'
						END AS COVER_IS_MATCHED,
						ga.CLEAN_PRICE,
						ga.DIRTY_PRICE,
						ga.PRICE_CURRENCY_CD,
						CASE WHEN EXISTS(
		          				select 1 from gec_allocation where STATUS!='T' AND im_order_id= gio.im_order_id
		        			) THEN 'Y'
		        			ELSE 'N'
		        		END AS HAS_ALLOCATIONS
				FROM gec_im_order gio
				LEFT JOIN GEC_TRADE_COUNTRY gtc
					ON gio.TRADE_COUNTRY_CD = gtc.TRADE_COUNTRY_CD
				LEFT JOIN GEC_ASSET_TYPE gat
				ON gio.ASSET_TYPE_ID = gat.ASSET_TYPE_ID
				LEFT JOIN gec_strategy gs
				ON gio.strategy_id = gs.strategy_id
		    	LEFT JOIN GEC_ASSET ga
		    	on gio.ASSET_ID = ga.ASSET_ID
		    	LEFT JOIN GEC_FUND gu
    			on gio.FUND_CD = gu.FUND_CD
    			LEFT JOIN GEC_RESTRICTION r
          		on gio.RESTRICTION_CD = r.RESTRICTION_CD
				WHERE gio.IM_ORDER_ID = p_imOrderId
				
				UNION
				SELECT 	gio.IM_ORDER_ID,
						NULL HOLDBACK_FLAG,
						NULL TRADING_DESK_CD,
						NULL TRADE_COUNTRY_CD,
						NULL INVESTMENT_MANAGER_CD,
						NULL STRATEGY,
						NULL FUND_CD,
						gio.TRANSACTION_CD,
						NULL SB_BROKER_CD,
						gio.STATUS,
						NULL EXPORT_STATUS,
						NULL CUSIP,
						NULL ASSET_ID,
						NULL DESCRIPTION,
						NULL BROKER_CD,
						NULL SHARE_QTY,
		       			NULL FILLED_QTY,
						NULL UNFILLED_QTY,
						NULL TRADE_DATE,
						NULL P_SHARES_SETTLE_DATE,
						NULL SETTLE_DATE,
						NULL G1_EXTRACTED_AT,
						NULL G1_EXTRACTED_FLAG,
						NULL TICKER,
						NULL SEDOL,
						NULL ISIN,
						NULL QUIK,
						NULL SECURITY_TYPE,
						NULL RESTRICTION_ABBRV,
						NULL POSITION_FLAG,
						NULL UPDATED_AT,
						NULL CREATED_AT,
						NULL COMMENT_TXT,
						NULL NSB_COLLATERAL_TYPE,
						NULL BRANCH_CD,
						NULL SHORT_IS_COVERED,
						NULL RATE,
						NULL SETTLEMENT_LOCATION_CD,
						NULL LEGAL_ENTITY_CD,
						NULL G1_INSTANCE_CD,
						CASE WHEN gio.transaction_cd = 'COVER' AND gio.status not in ('X','C')  AND  EXISTS (
							select 1 from gec_im_order s
									where s.G1_EXTRACTED_AT IS NULL
				              			and s.transaction_cd='SHORT'
				               			and s.status not in ('X','C')
				               			and gio.fund_cd = s.fund_cd 
								      	and gio.asset_id = s.asset_id
								      	and s.settle_date>GEC_UTILS_PKG.DATE_TO_NUMBER(SYSDATE)
								      	and gio.settle_date>GEC_UTILS_PKG.DATE_TO_NUMBER(SYSDATE)) 
									THEN 'Y'
						     WHEN gio.transaction_cd = 'SHORT'
						     		THEN NULL
						     ELSE 'N'
						END AS COVER_IS_MATCHED,
						null CLEAN_PRICE,
						null DIRTY_PRICE,
						null PRICE_CURRENCY_CD,
						'N'  HAS_ALLOCATIONS
				FROM gec_im_order gio
				LEFT JOIN GEC_RESTRICTION r
          		on gio.RESTRICTION_CD = r.RESTRICTION_CD
				WHERE gio.transaction_cd = 'COVER' AND gio.status not in ('X','C')
					and gio.fund_cd = v_fundCd
					and gio.asset_id = v_assetId;
	END OPEN_MODIFIED_SHORT;
	
	PROCEDURE OPEN_MODIFIED_COVER(p_imOrderId IN NUMBER,p_retOrders OUT SYS_REFCURSOR)
	IS
		CURSOR v_cur_order IS
			SELECT SETTLE_DATE,ASSET_ID
			FROM GEC_IM_ORDER 
			WHERE IM_ORDER_ID = p_imOrderId;
		
		v_settledate GEC_IM_ORDER.SETTLE_DATE%type;
		v_assetId GEC_IM_ORDER.ASSET_ID%type;
	BEGIN
		FOR item IN  v_cur_order
		LOOP
			v_settledate := item.SETTLE_DATE;
			v_assetId := item.ASSET_ID;
		END LOOP;
		OPEN p_retOrders FOR
					SELECT 	gio.IM_ORDER_ID,
						DECODE(gio.TRANSACTION_CD,'COVER',null,gio.HOLDBACK_FLAG) HOLDBACK_FLAG,
						gtc.TRADING_DESK_CD,
						gio.TRADE_COUNTRY_CD,
						gio.INVESTMENT_MANAGER_CD,
						gs.STRATEGY_NAME STRATEGY,
						gio.FUND_CD,
						gio.TRANSACTION_CD,
						gio.SB_BROKER_CD,
						gio.STATUS,
						DECODE(gio.TRANSACTION_CD,'COVER',null,gio.EXPORT_STATUS) EXPORT_STATUS,
						gio.CUSIP,
						gio.ASSET_ID,
						gio.DESCRIPTION,
						null BROKER_CD,
						gio.SHARE_QTY,
		       			gio.FILLED_QTY,
						(gio.SHARE_QTY-NVL(gio.FILLED_QTY,0)) UNFILLED_QTY,
						gio.TRADE_DATE,
						gio.P_SHARES_SETTLE_DATE,
						gio.SETTLE_DATE,
						gio.G1_EXTRACTED_AT,
						gio.G1_EXTRACTED_FLAG,
						gio.TICKER,
						gio.SEDOL,
						gio.ISIN,
						gio.QUIK,
						UPPER(gat.ASSET_TYPE_DESC) SECURITY_TYPE,
						r.RESTRICTION_ABBRV,
						gio.POSITION_FLAG,
						gio.UPDATED_AT,
						gio.CREATED_AT,
						gio.COMMENT_TXT,
						gu.NSB_COLLATERAL_TYPE,
						gu.BRANCH_CD,
						gio.RATE,
						gio.SETTLEMENT_LOCATION_CD,
						gio.LEGAL_ENTITY_CD,
						gu.G1_INSTANCE_CD,
						CASE WHEN gio.transaction_cd = 'SHORT' AND EXISTS (
					      	select 1 from gec_im_order c
					        		where c.status not in ('X','C')
						       			and c.transaction_cd='COVER'
										and gio.asset_id = c.asset_id 
										and gio.settle_date!=c.settle_date
										and c.settle_date>=GEC_UTILS_PKG.DATE_TO_NUMBER(SYSDATE)) AND gio.status not in ('X','C') 
						THEN 'Y'
					     WHEN gio.transaction_cd = 'COVER'
					     		THEN NULL
					     ELSE 'N'
						END AS SHORT_IS_COVERED,
						CASE WHEN gio.transaction_cd = 'COVER' AND gio.status not in ('X','C')  AND  EXISTS (
							select 1 from gec_im_order s
									where s.G1_EXTRACTED_AT IS NULL
				              			and s.transaction_cd='SHORT'
				               			and s.status not in ('X','C')
				               			and gio.fund_cd = s.fund_cd 
								      	and gio.asset_id = s.asset_id
								      	and s.settle_date>GEC_UTILS_PKG.DATE_TO_NUMBER(SYSDATE)
								      	and gio.settle_date>GEC_UTILS_PKG.DATE_TO_NUMBER(SYSDATE)) 
									THEN 'Y'
						     WHEN gio.transaction_cd = 'SHORT'
						     		THEN NULL
						     ELSE 'N'
						END AS COVER_IS_MATCHED,
						ga.CLEAN_PRICE,
						ga.DIRTY_PRICE,
						ga.PRICE_CURRENCY_CD,
						CASE WHEN EXISTS(
		          				select 1 from gec_allocation where STATUS!='T' AND im_order_id= gio.im_order_id
		        			) THEN 'Y'
		        			ELSE 'N'
		        		END AS HAS_ALLOCATIONS
				FROM gec_im_order gio
				LEFT JOIN GEC_TRADE_COUNTRY gtc
					ON gio.TRADE_COUNTRY_CD = gtc.TRADE_COUNTRY_CD
				LEFT JOIN GEC_ASSET_TYPE gat
				ON gio.ASSET_TYPE_ID = gat.ASSET_TYPE_ID
				LEFT JOIN gec_strategy gs
				ON gio.strategy_id = gs.strategy_id
		    	LEFT JOIN GEC_ASSET ga
		    	on gio.ASSET_ID = ga.ASSET_ID
		    	LEFT JOIN GEC_FUND gu
    			on gio.FUND_CD = gu.FUND_CD
    			LEFT JOIN GEC_RESTRICTION r
          		on gio.RESTRICTION_CD = r.RESTRICTION_CD
				WHERE gio.IM_ORDER_ID = p_imOrderId
				
				UNION
				SELECT 	gio.IM_ORDER_ID,
						NULL HOLDBACK_FLAG,
						NULL TRADING_DESK_CD,
						NULL TRADE_COUNTRY_CD,
						NULL INVESTMENT_MANAGER_CD,
						NULL STRATEGY,
						NULL FUND_CD,
						gio.TRANSACTION_CD,
						NULL SB_BROKER_CD,
						gio.STATUS,
						NULL EXPORT_STATUS,
						NULL CUSIP,
						NULL ASSET_ID,
						NULL DESCRIPTION,
						NULL BROKER_CD,
						NULL SHARE_QTY,
		       			NULL FILLED_QTY,
						NULL UNFILLED_QTY,
						NULL TRADE_DATE,
						NULL P_SHARES_SETTLE_DATE,
						NULL SETTLE_DATE,
						NULL G1_EXTRACTED_AT,
						NULL G1_EXTRACTED_FLAG,
						NULL TICKER,
						NULL SEDOL,
						NULL ISIN,
						NULL QUIK,
						NULL SECURITY_TYPE,
						NULL RESTRICTION_ABBRV,
						NULL POSITION_FLAG,
						NULL UPDATED_AT,
						NULL CREATED_AT,
						NULL COMMENT_TXT,
						null NSB_COLLATERAL_TYPE,
						null BRANCH_CD,
						NULL RATE,
						NULL SETTLEMENT_LOCATION_CD,
						NULL LEGAL_ENTITY_CD,
						NULL G1_INSTANCE_CD,
						CASE WHEN gio.transaction_cd = 'SHORT' AND EXISTS (
					      	select 1 from gec_im_order c
					        		where c.status not in ('X','C')
						       			and c.transaction_cd='COVER'
										and gio.asset_id = c.asset_id 
										and gio.settle_date!=c.settle_date
										and c.settle_date>=GEC_UTILS_PKG.DATE_TO_NUMBER(SYSDATE)) AND gio.status not in ('X','C') 
						THEN 'Y'
					     WHEN gio.transaction_cd = 'COVER'
					     		THEN NULL
					     ELSE 'N'
						END AS SHORT_IS_COVERED,
						NULL AS COVER_IS_MATCHED,
						null CLEAN_PRICE,
						null DIRTY_PRICE,
						null PRICE_CURRENCY_CD,
						'N'  HAS_ALLOCATIONS
				FROM gec_im_order gio
				LEFT JOIN GEC_RESTRICTION r
          		on gio.RESTRICTION_CD = r.RESTRICTION_CD
				WHERE gio.transaction_cd = 'SHORT' AND gio.status not in ('X','C')
					and gio.settle_date != v_settledate
					and gio.asset_id = v_assetId;
	END OPEN_MODIFIED_COVER;
	
	PROCEDURE OPEN_SHORT_AND_CANCEL(p_imOrderId IN NUMBER,p_retOrders OUT SYS_REFCURSOR)
	IS
		CURSOR v_cur_order IS
			SELECT FUND_CD,ASSET_ID
			FROM GEC_IM_ORDER 
			WHERE IM_ORDER_ID = p_imOrderId;
		
		v_fundCd GEC_IM_ORDER.FUND_CD%type;
		v_assetId GEC_IM_ORDER.ASSET_ID%type;
	BEGIN
		FOR item IN  v_cur_order
		LOOP
			v_fundCd := item.FUND_CD;
			v_assetId := item.ASSET_ID;
		END LOOP;
		OPEN p_retOrders FOR
					SELECT 	gio.IM_ORDER_ID,
						DECODE(gio.TRANSACTION_CD,'COVER',null,gio.HOLDBACK_FLAG) HOLDBACK_FLAG,
						gtc.TRADING_DESK_CD,
						gio.TRADE_COUNTRY_CD,
						gio.INVESTMENT_MANAGER_CD,
						gs.STRATEGY_NAME STRATEGY,
						gio.FUND_CD,
						gio.TRANSACTION_CD,
						gio.SB_BROKER_CD,
						gio.STATUS,
						DECODE(gio.TRANSACTION_CD,'COVER',null,gio.EXPORT_STATUS) EXPORT_STATUS,
						gio.CUSIP,
						gio.ASSET_ID,
						gio.DESCRIPTION,
						null BROKER_CD,
						gio.SHARE_QTY,
		       			gio.FILLED_QTY,
						(gio.SHARE_QTY-NVL(gio.FILLED_QTY,0)) UNFILLED_QTY,
						gio.TRADE_DATE,
						gio.SETTLE_DATE,
						gio.P_SHARES_SETTLE_DATE,
						gio.G1_EXTRACTED_AT,
						gio.G1_EXTRACTED_FLAG,
						gio.TICKER,
						gio.SEDOL,
						gio.ISIN,
						gio.QUIK,
						UPPER(gat.ASSET_TYPE_DESC) SECURITY_TYPE,
						r.RESTRICTION_ABBRV,
						gio.POSITION_FLAG,
						gio.UPDATED_AT,
						gio.CREATED_AT,
						gio.COMMENT_TXT,
						gu.NSB_COLLATERAL_TYPE,
						gu.BRANCH_CD,
						gio.RATE,
						gio.SETTLEMENT_LOCATION_CD,
						gio.LEGAL_ENTITY_CD,
						gu.G1_INSTANCE_CD,
						CASE WHEN gio.transaction_cd = 'SHORT' AND EXISTS (
					      	select 1 from gec_im_order c
					        		where c.status not in ('X','C')
						       			and c.transaction_cd='COVER'
										and gio.asset_id = c.asset_id 
										and gio.settle_date!=c.settle_date
										and c.settle_date>=GEC_UTILS_PKG.DATE_TO_NUMBER(SYSDATE)) AND gio.status not in ('X','C') 
						THEN 'Y'
					     WHEN gio.transaction_cd = 'COVER'
					     		THEN NULL
					     ELSE 'N'
						END AS SHORT_IS_COVERED,
						NULL COVER_IS_MATCHED,
						ga.CLEAN_PRICE,
						ga.DIRTY_PRICE,
						ga.PRICE_CURRENCY_CD,
						CASE WHEN EXISTS(
		          				select 1 from gec_allocation where STATUS!='T' AND im_order_id= gio.im_order_id
		        			) THEN 'Y'
		        			ELSE 'N'
		        		END AS HAS_ALLOCATIONS
				FROM gec_im_order gio
				LEFT JOIN GEC_TRADE_COUNTRY gtc
					ON gio.TRADE_COUNTRY_CD = gtc.TRADE_COUNTRY_CD
				LEFT JOIN GEC_ASSET_TYPE gat
				ON gio.ASSET_TYPE_ID = gat.ASSET_TYPE_ID
				LEFT JOIN gec_strategy gs
				ON gio.strategy_id = gs.strategy_id
		    	LEFT JOIN GEC_ASSET ga
		    	on gio.ASSET_ID = ga.ASSET_ID
		    	LEFT JOIN GEC_FUND gu
    			on gio.FUND_CD = gu.FUND_CD
    			LEFT JOIN GEC_RESTRICTION r
          		on gio.RESTRICTION_CD = r.RESTRICTION_CD
				WHERE gio.IM_ORDER_ID = p_imOrderId OR gio.MATCHED_ID = p_imOrderId
				
				
				UNION
				SELECT 	gio.IM_ORDER_ID,
						NULL HOLDBACK_FLAG,
						NULL TRADING_DESK_CD,
						NULL TRADE_COUNTRY_CD,
						NULL INVESTMENT_MANAGER_CD,
						NULL STRATEGY,
						NULL FUND_CD,
						gio.TRANSACTION_CD,
						NULL SB_BROKER_CD,
						gio.STATUS,
						NULL EXPORT_STATUS,
						NULL CUSIP,
						NULL ASSET_ID,
						NULL DESCRIPTION,
						NULL BROKER_CD,
						NULL SHARE_QTY,
		       			NULL FILLED_QTY,
						NULL UNFILLED_QTY,
						NULL TRADE_DATE,
						NULL SETTLE_DATE,
						NULL P_SHARES_SETTLE_DATE,
						NULL G1_EXTRACTED_AT,
						NULL G1_EXTRACTED_FLAG,
						NULL TICKER,
						NULL SEDOL,
						NULL ISIN,
						NULL QUIK,
						NULL SECURITY_TYPE,
						NULL RESTRICTION_ABBRV,
						NULL POSITION_FLAG,
						NULL UPDATED_AT,
						NULL CREATED_AT,
						NULL COMMENT_TXT,
						null NSB_COLLATERAL_TYPE,
						null BRANCH_CD,
						NULL RATE,
						NULL SETTLEMENT_LOCATION_CD,
						NULL LEGAL_ENTITY_CD,
						NULL G1_INSTANCE_CD,
						NULL SHORT_IS_COVERED,
						CASE WHEN gio.transaction_cd = 'COVER' AND gio.status not in ('X','C')  AND  EXISTS (
							select 1 from gec_im_order s
									where s.G1_EXTRACTED_AT IS NULL
				              			and s.transaction_cd='SHORT'
				               			and s.status not in ('X','C')
				               			and gio.fund_cd = s.fund_cd 
								      	and gio.asset_id = s.asset_id
								      	and s.settle_date>GEC_UTILS_PKG.DATE_TO_NUMBER(SYSDATE)
								      	and gio.settle_date>GEC_UTILS_PKG.DATE_TO_NUMBER(SYSDATE)) 
									THEN 'Y'
						     WHEN gio.transaction_cd = 'SHORT'
						     		THEN NULL
						     ELSE 'N'
						END AS COVER_IS_MATCHED,
						null CLEAN_PRICE,
						null DIRTY_PRICE,
						null PRICE_CURRENCY_CD,
						'N'  HAS_ALLOCATIONS
				FROM gec_im_order gio
				LEFT JOIN GEC_RESTRICTION r
          		on gio.RESTRICTION_CD = r.RESTRICTION_CD
				WHERE gio.transaction_cd = 'COVER' AND gio.status not in ('X','C')
					and gio.fund_cd = v_fundCd
					and gio.asset_id = v_assetId;
				
	END OPEN_SHORT_AND_CANCEL;
	
	PROCEDURE OPEN_NULL_CURSOR(p_retOrders OUT SYS_REFCURSOR)
	IS
	BEGIN
		OPEN p_retOrders FOR
			SELECT 	NULL IM_ORDER_ID,
					NULL HOLDBACK_FLAG,
					NULL TRADING_DESK_CD,
					NULL TRADE_COUNTRY_CD,
					NULL INVESTMENT_MANAGER_CD,
					NULL STRATEGY,
					NULL FUND_CD,
					NULL TRANSACTION_CD,
					NULL SB_BROKER_CD,
					NULL STATUS,
					NULL EXPORT_STATUS,
					NULL CUSIP,
					NULL ASSET_ID,
					NULL DESCRIPTION,
					NULL BROKER_CD,
					NULL SHARE_QTY,
	       			NULL FILLED_QTY,
					NULL UNFILLED_QTY,
					NULL TRADE_DATE,
					NULL SETTLE_DATE,
					NULL G1_EXTRACTED_AT,
					NULL G1_EXTRACTED_FLAG,
					NULL TICKER,
					NULL SEDOL,
					NULL ISIN,
					NULL QUIK,
					NULL SECURITY_TYPE,
					NULL RESTRICTION_ABBRV,
					NULL POSITION_FLAG,
					NULL UPDATED_AT,
					NULL CREATED_AT,
					NULL COMMENT_TXT,
					null NSB_COLLATERAL_TYPE,
					null BRANCH_CD,
					NULL RATE,
					NULL SETTLEMENT_LOCATION_CD,
					NULL LEGAL_ENTITY_CD,
					NULL SHORT_IS_COVERED,
					NULL COVER_IS_MATCHED,
					NULL CLEAN_PRICE,
					NULL DIRTY_PRICE,
					NULL HAS_ALLOCATIONS,
					NULL PRICE_CURRENCY_CD,
					NULL P_SHARES_SETTLE_DATE,
					NULL G1_INSTANCE_CD
				FROM DUAL WHERE 1=0;
	END OPEN_NULL_CURSOR;
	
	PROCEDURE UPDATE_ORDERS_FOR_NORESPONSE(p_borrowRequestId IN NUMBER,p_retOrders OUT SYS_REFCURSOR,p_borrowRequest OUT SYS_REFCURSOR)
	IS
  	CURSOR v_im_orders IS
		SELECT gio.im_order_id,gio.matched_id,gio.TRANSACTION_CD from GEC_IM_ORDER gio
		JOIN GEC_BORROW_ORDER_DETAIL gbod
     	on gio.im_order_id = gbod.im_order_id
      	JOIN GEC_BORROW_ORDER gbo
      	on gbo.borrow_order_id = gbod.borrow_order_id
	  	WHERE gbo.borrow_request_id = p_borrowRequestId
	  	FOR UPDATE
      	order by gio.im_order_id; --for dead lock
	BEGIN
      FOR v_i_o IN v_im_orders
				LOOP
					IF v_i_o.TRANSACTION_CD = GEC_CONSTANTS_PKG.C_SB_SHORT THEN 
						UPDATE GEC_IM_ORDER o SET o.EXPORT_STATUS = 'C', o.HOLDBACK_FLAG = 'N',UPDATED_AT = SYSDATE WHERE o.im_order_id = v_i_o.im_order_id;
					ELSE 
						UPDATE GEC_IM_ORDER o SET o.EXPORT_STATUS = 'R', o.HOLDBACK_FLAG = 'N',UPDATED_AT = SYSDATE WHERE o.im_order_id = v_i_o.im_order_id;
					END IF;
					IF v_i_o.matched_id IS NOT NULL THEN
							UPDATE GEC_IM_ORDER o SET o.status = 'C',UPDATED_AT = SYSDATE WHERE o.im_order_id = v_i_o.im_order_id;
                            UPDATE GEC_IM_ORDER o SET o.status = 'M',UPDATED_AT = SYSDATE WHERE o.im_order_id = v_i_o.matched_id;
                    END IF;
				END LOOP;
				
		OPEN p_borrowRequest FOR
        select br.BORROW_REQUEST_ID, 
        f.FILE_NAME,
        rf.FILE_NAME as RESPONSE_FILE_NAME,
        br.REQUEST_AT,
        br.REQUEST_BY,
        br.RESPONSE_AT,
        br.RESPONSE_BY,
        br.STATUS,
        br.STATUS_MSG,
        br.BORROW_REQUEST_TYPE,
        br.BORROW_REQUEST_FILE_TYPE,
        br.BRANCH_CD,
		br.BROKER_CD,
		br.SETTLEMENT_MARKET,
		br.COLLATERAL_TYPE,
		br.COLLATERAL_CURRENCY_CD,
		br.AUTOBORROW_BATCH_ID,
		br.AGGREGATE_ID,
		br.EQUILEND_CHAIN_ID,
		br.EQUILEND_SCHEDULE_ID,
		br.REQUEST_COUNT,
		br.SHTT_ABNO_COUNT,
		br.ORAC_ABRE_COUNT,
		br.EXPIRATION_TIME,
		br.TYPE,
		br.ALLOCATE_STATUS,
		NVL(GS.BROKER_CD,gcs.CHAIN_LENDER) as LENDER
        from GEC_BORROW_REQUEST br
        LEFT JOIN GEC_FILE f
        ON br.BORROW_REQUEST_ID = f.REQUEST_ID and f.FILE_TYPE = 'REQ'
        LEFT JOIN GEC_FILE rf
        ON f.REQUEST_ID = rf.REQUEST_ID and rf.FILE_TYPE = 'RES'
        LEFT JOIN GEC_SCHEDULE gs
	    ON br.EQUILEND_SCHEDULE_ID = gs.EQUILEND_SCHEDULE_ID
	    LEFT JOIN (select gc.equilend_chain_ID, REPLACE(GEC_NO_DUP_STRACAT_FNC(Broker_Cd),';',',') as CHAIN_LENDER from gec_chain_schedule gcs
	    LEFT JOIN gec_chain gc
	    ON gc.CHAIN_ID = gcs.CHAIN_ID
	    group by gc.equilend_chain_ID) gcs
	    ON br.EQUILEND_CHAIN_ID = gcs.equilend_chain_ID
        where br.BORROW_REQUEST_ID = p_borrowRequestId;
				
      OPEN p_retOrders FOR
         SELECT gio.IM_ORDER_ID,
				gio.ASSET_ID,
				gio.CUSIP,
				gio.SEDOL,
				gio.ISIN,
				gio.QUIK,
        		gio.TICKER,
        		gio.DESCRIPTION,
        		gio.POSITION_FLAG,
        		gio.TRADE_COUNTRY_CD,
				gio.FUND_CD,
				gio.TRANSACTION_CD,
				gio.SB_BROKER_CD,
				gio.P_SHARES_SETTLE_DATE,
				gio.SETTLE_DATE,
				gio.STATUS,
				NVL(gio.filled_qty,0) FILLED_QTY,
        		gio.SHARE_QTY,
        		(NVL(gio.SHARE_QTY,0)-NVL(gio.filled_qty,0)) UNFILLED_QTY,
        		gio.RATE,
        		gio.BRANCH_CD,
        		gio.collateral_currency_cd,
       		 	gio.nsb_collateral_type,
       		 	gio.trading_desk_cd,
       		 	gio.PREPAY_DATE_VALUE,
       		 	UPPER(gio.ASSET_TYPE_DESC) SECURITY_TYPE,
				DECODE(NVL(ta.M_COUNT,0),0,0,1) REQUIREMANUAL,
       		 	gio.SOURCE_CD AS SOURCE_CD
		FROM GEC_AGGREGATE_DEMAND_VW gio
    	LEFT JOIN (select ga.IM_ORDER_ID,count(gb.STATUS) as M_COUNT 
    				from GEC_ALLOCATION ga
    				LEFT JOIN GEC_BORROW gb
    				ON ga.BORROW_ID = gb.BORROW_ID
    				WHERE gb.STATUS = 'M'
    				GROUP BY ga.IM_ORDER_ID) ta
    	ON gio.IM_ORDER_ID = ta.IM_ORDER_ID
        WHERE gio.im_order_id in(
                        SELECT gio.im_order_id from GEC_BORROW_ORDER gbo
                        JOIN GEC_BORROW_ORDER_DETAIL gbod
                        on gbo.borrow_order_id = gbod.borrow_order_id
                        JOIN GEC_IM_ORDER gio
                        on gio.im_order_id = gbod.im_order_id
                        WHERE gbo.borrow_request_id = p_borrowRequestId);
                        
	END UPDATE_ORDERS_FOR_NORESPONSE;
	
	PROCEDURE OPEN_PRE_BOOK_SHORT(p_im_order_ids IN GEC_NUMBER_ARRAY,
	                              p_error_code OUT VARCHAR2,
                                p_pre_book_orders OUT SYS_REFCURSOR)
  IS
     VAR_RATE GEC_LOAN.RATE%TYPE;
     VAR_ERROR_CODE VARCHAR2(10);
     CURSOR V_CUR_PRE_BOOK_ORDER IS
         SELECT 
             GIO.IM_ORDER_ID
             ,GIO.ASSET_ID
             ,GIO.FUND_CD
             ,TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDD')) AS TRADE_DATE
             ,GIO.SHARE_QTY
             ,(GEC_ALLOCATION_PKG.CALCULATE_PRICE_BY_IM_ORDER_ID(GIO.IM_ORDER_ID)) AS PRE_BOOKLOAN_PRICE
             ,GIO.FILLED_QTY
             ,(GIO.SHARE_QTY - GIO.FILLED_QTY) AS UNFILLED_QTY
             ,GIO.SETTLE_DATE
             ,GIO.STATUS
             ,GIO.EXPORT_STATUS
             ,GIO.G1_EXTRACTED_AT
             ,(GEC_ALLOCATION_PKG.GENERATE_BORROW_LINK_REF())AS PRE_BOOK_LOAN_LINKREFERENCE
             ,NVL(TRIM(GGC.COLLATERAL_CURRENCY_CD),TRIM(GGB.COLLATERAL_CURRENCY_CD)) AS COLLATERAL_CD
             ,NVL(TRIM(GGC.COLL_TYPE),TRIM(GGB.COLL_TYPE)) AS COLLATERAL_TYPE
             ,TRIM(GGB.COUNTERPARTY_CD) AS COUNTERPARTY_CD
         FROM GEC_IM_ORDER GIO
         INNER JOIN GEC_ASSET GA
	       ON GIO.ASSET_ID = GA.ASSET_ID
         INNER JOIN TABLE ( cast ( p_im_order_ids as GEC_NUMBER_ARRAY) ) orders
           ON ORDERS.COLUMN_VALUE = GIO.IM_ORDER_ID
         LEFT JOIN GEC_G1_BOOKING GGB
           ON GGB.FUND_CD=GIO.FUND_CD AND GGB.TRANSACTION_CD=GEC_CONSTANTS_PKG.C_G1L AND GGB.POS_TYPE=GEC_CONSTANTS_PKG.C_NSB
         LEFT JOIN  GEC_G1_COLLATERAL GGC 
           ON GGC.G1_BOOKING_ID = GGB.G1_BOOKING_ID AND GGC.TRADE_COUNTRY_CD ='US'
         WHERE (GIO.STATUS = 'P' OR GIO.STATUS = 'E') AND (GIO.SHARE_QTY - GIO.FILLED_QTY) >0 AND GIO.TRADE_COUNTRY_CD = 'US'
         AND UPPER(GIO.TRANSACTION_CD) = 'SHORT' AND 
         instr(GEC_CONSTANTS_PKG.GET_DUMMY_FUNDS(),GIO.FUND_CD||',')=0
--         AND GIO.IM_ORDER_ID IN (
--             select distinct orders.COLUMN_VALUE ORDER_ID from TABLE ( cast ( p_im_order_ids as GEC_NUMBER_ARRAY) ) orders
--             )
         ORDER BY GIO.IM_ORDER_ID
         FOR UPDATE OF GIO.STATUS;
  BEGIN
      p_error_code := NULL;
      FOR V_ORDER IN V_CUR_PRE_BOOK_ORDER LOOP
          VAR_RATE := GEC_ALLOCATION_PKG.GET_LOAN_RATE('NSB',V_ORDER.FUND_CD,'US',NULL,VAR_ERROR_CODE);
--         GET_LOAN_RATE(p_borrow_request_type IN VARCHAR2, p_fund_cd IN VARCHAR2, p_date IN NUMBER, p_error_code OUT VARCHAR2)
          IF VAR_ERROR_CODE IS NOT NULL THEN
					    p_error_code := VAR_ERROR_CODE;
               OPEN p_pre_book_orders FOR 
               SELECT GIOT.IM_ORDER_ID, GIOT.ASSET_ID, GIOT.FUND_CD, GIOT.TRADE_DATE, GIOT.UNFILLED_QTY, GIOT.SHARE_QTY, GIOT.PRE_BOOKLOAN_PRICE,
               (GIOT.SHARE_QTY - GIOT.UNFILLED_QTY) AS FILLED_QTY, 
               GIOT.SETTLE_DATE, GIOT.STATUS, GIOT.EXPORT_STATUS, GIOT.G1_EXTRACTED_AT,
               GIOT.PREBOOKFUNDRATE, GIOT.PRE_BOOK_LOAN_LINKREFERENCE, GIOT.COLLATERAL_CURRENCY_CD,
               GIOT.COUNTERPARTY_CD, GIOT.FUND_G1_COLL_TYPE
               FROM GEC_IM_ORDER_TEMP GIOT;
					    RETURN;
				  END IF;
          INSERT INTO GEC_IM_ORDER_TEMP(IM_ORDER_ID, ASSET_ID, FUND_CD, TRADE_DATE, SHARE_QTY, PRE_BOOKLOAN_PRICE,
                                        UNFILLED_QTY, SETTLE_DATE, STATUS, EXPORT_STATUS, G1_EXTRACTED_AT, PRE_BOOK_LOAN_LINKREFERENCE, 
                                        PREBOOKFUNDRATE,COLLATERAL_CURRENCY_CD,COUNTERPARTY_CD,FUND_G1_COLL_TYPE)
          VALUES(V_ORDER.IM_ORDER_ID, V_ORDER.ASSET_ID, V_ORDER.FUND_CD, V_ORDER.TRADE_DATE, V_ORDER.SHARE_QTY, 
                 V_ORDER.PRE_BOOKLOAN_PRICE, V_ORDER.UNFILLED_QTY, V_ORDER.SETTLE_DATE, V_ORDER.STATUS, V_ORDER.EXPORT_STATUS,
                 V_ORDER.G1_EXTRACTED_AT, V_ORDER.PRE_BOOK_LOAN_LINKREFERENCE,VAR_RATE,V_ORDER.COLLATERAL_CD,V_ORDER.COUNTERPARTY_CD,
                 V_ORDER.COLLATERAL_TYPE);
      END LOOP;
      
      OPEN p_pre_book_orders FOR 
      SELECT GIOT.IM_ORDER_ID, GIOT.ASSET_ID, GIOT.FUND_CD, GIOT.TRADE_DATE, GIOT.UNFILLED_QTY, GIOT.SHARE_QTY, GIOT.PRE_BOOKLOAN_PRICE,
             (GIOT.SHARE_QTY - GIOT.UNFILLED_QTY) AS FILLED_QTY, 
             GIOT.SETTLE_DATE, GIOT.STATUS, GIOT.EXPORT_STATUS, GIOT.G1_EXTRACTED_AT,
             GIOT.PREBOOKFUNDRATE, GIOT.PRE_BOOK_LOAN_LINKREFERENCE,GIOT.COLLATERAL_CURRENCY_CD,
             GIOT.COUNTERPARTY_CD, GIOT.FUND_G1_COLL_TYPE
      FROM GEC_IM_ORDER_TEMP GIOT
      ORDER BY GIOT.IM_ORDER_ID ASC;
--  EXCEPTION WHEN OTHERS THEN
--      RETURN;
  END OPEN_PRE_BOOK_SHORT;
  
  
    PROCEDURE UPLOAD_ORDERS(p_uploadedBy IN VARCHAR2, 
    						p_retOrderList OUT SYS_REFCURSOR,
    						p_retLocatedIds OUT SYS_REFCURSOR)
    IS
    	V_PROCEDURE_NAME CONSTANT VARCHAR(200) := 'GEC_IM_ORDER_PKG.UPLOAD_ORDERS';
    	v_valid VARCHAR2(1) :='Y';
    	
    BEGIN
    	GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
    	
    	OPEN p_retOrderList FOR
    			select TRANSACTION_CD, FUND_CD, ASSET_CODE, TRADE_DATE, SETTLE_DATE,SETTLEMENT_LOCATION_CD,TRADE_COUNTRY_CD,
    					SHARE_QTY,FUND_ERROR_CODE, ASSET_ERROR_CODE, TRADE_DATE_ERROR_CODE, SETTLE_DATE_ERROR_CODE, SHARE_QTY_ERROR_CODE
    			from gec_im_order_temp 
    			WHERE 1=0;
    	OPEN p_retLocatedIds FOR
			SELECT NULL Locate_Preborrow_ID FROM DUAL  WHERE 1=0;
			
    	GEC_VALIDATION_PKG.BATCH_VALIDATE_ORDERS;
    	
    	BEGIN 
    		SELECT 'N' INTO v_valid FROM DUAL
    		WHERE EXISTS(SELECT 1 FROM GEC_IM_ORDER_TEMP t
    						WHERE t.FUND_ERROR_CODE is not null or
  									t.ASSET_ERROR_CODE is not null or
  									t.TRADE_DATE_ERROR_CODE is not null or
  									t.SETTLE_DATE_ERROR_CODE is not null or
  									t.SHARE_QTY_ERROR_CODE is not null);
  			EXCEPTION WHEN NO_DATA_FOUND THEN
  				v_valid := 'Y';
  		END;
  		
  		IF v_valid = 'N' THEN
  			OPEN p_retOrderList FOR
    			select TRANSACTION_CD, FUND_CD, ASSET_CODE, TRADE_DATE, SETTLE_DATE,SETTLEMENT_LOCATION_CD,TRADE_COUNTRY_CD,
    					SHARE_QTY,FUND_ERROR_CODE, ASSET_ERROR_CODE, TRADE_DATE_ERROR_CODE, SETTLE_DATE_ERROR_CODE, SHARE_QTY_ERROR_CODE
    			from gec_im_order_temp;
	    		RETURN;
	   ELSE
	   		UPDATE GEC_IM_ORDER_TEMP SET IM_ORDER_ID = GEC_IM_ORDER_ID_SEQ.nextval;
	    	UPLOAD_ORDERS_INPUT(p_uploadedBy,
    							 p_retLocatedIds);
	    	
	   END IF; 
    	
    	
    	
    	
    	GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
    END UPLOAD_ORDERS;
    
    PROCEDURE UPLOAD_ORDERS_INPUT(p_uploadedBy IN VARCHAR2,
    							 p_retLocatedIds  OUT SYS_REFCURSOR)
    IS
    	v_uploadedAt gec_im_order.created_at%type;
    	v_first char(1) := 'Y';
		v_execution_flag char(1) := 'N';
		v_sb_qty gec_locate_preborrow.RESERVED_SB_QTY%TYPE;
		v_sb_ral_qty gec_locate_preborrow.SB_QTY_RAL%TYPE;
		v_nsb_qty gec_locate_preborrow.RESERVED_NSB_QTY%TYPE;
		v_nfs_qty gec_locate_preborrow.RESERVED_NFS_QTY%TYPE;
		v_ext2_qty gec_locate_preborrow.RESERVED_EXT2_QTY%TYPE;
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
    	
		v_last_item v_cur_updt_availability_orders%rowtype;
		
		CURSOR v_cur_update_order IS
			SELECT (nvl(avail.SB_QTY,0)+nvl(avail.SB_QTY_RAL,0)+nvl(avail.NSB_QTY,0)+nvl(avail.NFS_QTY,0)+nvl(avail.EXT2_QTY,0) ) as at_point_avail,
					temp.IM_ORDER_id
			  FROM GEC_IM_AVAILABILITY avail, GEC_IM_ORDER_temp temp
			 WHERE 
				avail.im_availability_id = temp.im_availability_id
				and avail.status = 'A'; 
				
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
    BEGIN
    
    	
    	GEC_UPLOAD_PKG.UPDATE_TEMP_ORDER_BY_AVAIL;
    	
    	GEC_UPLOAD_PKG.FILL_ORDER_WITH_GC_RATE;
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
		
		--gec2.2 change
		GEC_UPLOAD_PKG.FILL_ORDER_WITH_P_SHARES_SD;
		
		GEC_UPLOAD_PKG.HANDLE_NO_DEMAND_BORROW;
		
		INSERT INTO GEC_IM_ORDER ( im_order_id, 
						BUSINESS_DATE, INVESTMENT_MANAGER_CD, TRANSACTION_CD, FUND_CD, BRANCH_CD, 
          				Share_Qty, ASSET_ID, ASSET_CODE, ASSET_CODE_TYPE, 
						Reserved_SB_Qty, RESERVED_SB_QTY_RAL , Reserved_NSB_Qty, 
						SOURCE_CD, UPDATED_BY, STATUS, COMMENT_TXT, 
           				SETTLE_DATE,Position_Flag,  SB_Broker_Cd, UPDATED_AT, 
						RESTRICTION_CD, Reserved_NFS_Qty,  Reserved_EXT2_Qty, 
           				Trade_Date,CLIENT_REF_NO, CREATED_BY, CREATED_AT,
						CUSIP, ISIN, SEDOL, QUIK, TRADE_COUNTRY_CD,
						TICKER, DESCRIPTION, FILE_VERSION ,REQUEST_ID,
						at_point_avail_qty, strategy_id,LOCATE_PREBORROW_ID,
						asset_type_id,matched_id,rate,SETTLEMENT_LOCATION_CD,LEGAL_ENTITY_CD,P_SHARES_SETTLE_DATE)
				SELECT  IM_ORDER_ID, 
						BUSINESS_DATE, INVESTMENT_MANAGER_CD, TRANSACTION_CD, FUND_CD, BRANCH_CD, 
			            Share_Qty, ASSET_ID, ASSET_CODE, ASSET_CODE_TYPE, 
						Reserved_SB_Qty, RESERVED_SB_QTY_RAL , Reserved_NSB_Qty, 
						SOURCE_CD, UPDATED_BY, STATUS, COMMENT_TXT, 
			            SETTLE_DATE,Position_Flag,  SB_Broker_Cd, UPDATED_AT, 
						RESTRICTION_CD, Reserved_NFS_Qty, Reserved_EXT2_Qty, 
			            Trade_Date, CLIENT_REF_NO,CREATED_BY, CREATED_AT,
						CUSIP, ISIN, SEDOL, QUIK, TRADE_COUNTRY_CD,
						TICKER, DESCRIPTION, FILE_VERSION ,REQUEST_ID,
						at_point_avail_qty, strategy_id,LOCATE_PREBORROW_ID,
            			asset_type_id,matched_id,rate,SETTLEMENT_LOCATION_CD,LEGAL_ENTITY_CD,P_SHARES_SETTLE_DATE
				FROM GEC_IM_ORDER_temp;
		
    END UPLOAD_ORDERS_INPUT;
END GEC_IM_ORDER_PKG;
/
