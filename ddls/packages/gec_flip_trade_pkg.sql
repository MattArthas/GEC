-------------------------------------------------------------------------
-- Copyright (c) 2009 State Street Bank and Trust Corp.
-- 225 Franklin Street, Boston, MA 02110, U.S.A.
-- All rights reserved.
--
-- "GEC_FLIP_TRADE_PKG.sql is the copyrighted,
-- proprietary property of State Street Bank and Trust Company and its
-- subsidiaries and affiliates which retain all right, title and interest
-- therein."
--
-- Revision History
--
-- Date            Programmer                Notes
-- ------------    --------------------      ----------------------------
-- Sep 22, 2012		Chen, Hui				 created
-------------------------------------------------------------------------
create or replace PACKAGE GEC_FLIP_TRADE_PKG 
AS                                                 
    PROCEDURE UPLOAD_FLIP_TRADES_FILE(p_record_num OUT VARCHAR2,p_error_msg   OUT VARCHAR2);
    PROCEDURE UPLOAD_FLIP_TRADES_INPUT(p_retFlipTradeList OUT SYS_REFCURSOR);
    PROCEDURE VALIDATE_FLIP_TRADES(p_type IN VARCHAR2,p_record_num OUT VARCHAR2,p_error_msg OUT VARCHAR2,p_valid OUT VARCHAR2);
    FUNCTION VALIDATE_BRW_RTN_CPTY(p_brw_rtn_cpty IN VARCHAR2)RETURN VARCHAR2;
    PROCEDURE INSERT_FROM_TEMP;
    PROCEDURE SAVE_FLIP_TRADES(p_errorCode   OUT VARCHAR2,p_flip_trades OUT SYS_REFCURSOR);
    PROCEDURE CANCEL_FLIP_TRADES(p_flip_trade_ids IN VARCHAR2,p_flip_trades OUT SYS_REFCURSOR,p_errorCode  OUT VARCHAR2);
    PROCEDURE EXPORT_FLIP_TRADE_REQUEST(p_type IN VARCHAR2,
                                      p_request_file_type	IN VARCHAR2,
                                      p_flip_trade_ids IN VARCHAR2,
                                      p_current_date IN NUMBER,
                                      p_settle_market		IN VARCHAR2,
                                      p_trade_countries		IN VARCHAR2,
                                      p_settle_dates  IN VARCHAR2,
                                      p_equilend_chain_id     IN NUMBER,
                                      p_equilend_schedule_id  IN NUMBER,
                                      p_auto_release_rule_id  IN NUMBER,
                                      p_request_by			IN VARCHAR2,
                                      p_full_fill 			IN VARCHAR2,
                                      p_recall_flag 		IN VARCHAR2,
                                      p_borrow_request_id 	OUT NUMBER,
                                      p_errorCode         	OUT VARCHAR2);
    FUNCTION GET_FLIP_TRADES_BY_IDS(p_flip_trade_ids	IN VARCHAR2,p_current_date IN NUMBER) RETURN VARCHAR2;
    PROCEDURE GET_FT_TRADES(p_trade_countries 	IN VARCHAR2,
                            p_settle_dates  IN VARCHAR2,
                            p_recall_flag IN VARCHAR2);
    PROCEDURE REMOVE_EXCEPTION_TRADES(p_auto_release_rule_id  IN NUMBER);
    PROCEDURE FILL_DEMANDS_WITH_FLIP_TRADES(p_borrow_request_id 		IN NUMBER,
                                     p_type			IN VARCHAR2);  
    PROCEDURE NORESPONSE_FLIP_TRADE(p_borrowRequestId IN NUMBER,p_flip_trades OUT SYS_REFCURSOR,p_borrowRequest OUT SYS_REFCURSOR);
	PROCEDURE GENERATE_RETURN(
							  p_fund_cd IN VARCHAR2,
							  p_asset_id IN NUMBER,
							  p_flip_trade_id IN NUMBER,
							  p_flip_borrow_id IN NUMBER,
							  p_transaction_type IN VARCHAR2,
							  p_trade_date IN NUMBER,
							  p_settle_Date IN NUMBER,
							  p_return_cpty IN VARCHAR2,
							  p_bargain_ref IN VARCHAR2,
							  p_qty IN NUMBER,
							  p_status OUT VARCHAR2,
							  p_error_msg OUT VARCHAR2
							  );
	PROCEDURE GENERATE_LOAN(p_asset_id IN NUMBER,
							p_fund_cd IN VARCHAR2,
							p_trade_date IN NUMBER,
							p_settle_Date IN NUMBER,
							p_loan_qty IN NUMBER,
			   				p_rate IN NUMBER,
			   				p_price IN NUMBER,
			   				p_broker_cd IN VARCHAR2,
			   				p_user_id IN VARCHAR2,
			   				p_prepay_date IN NUMBER,
			   				p_pos_type IN VARCHAR2,
			   				p_trade_country_cd IN VARCHAR2,
			   				p_flip_trade_id IN VARCHAR2,
			   				p_flip_borrow_id IN NUMBER);
	--p_cpty_type BB BookBorrow BL BookLoan RB ReturnBorrow RL ReturnLoan
	--p_status S success E error
	PROCEDURE GET_CPTY(p_return_cpty IN VARCHAR2,
					  p_new_borrow_cpty IN VARCHAR2,
					  p_cpty_type IN VARCHAR2,
					  p_cpty OUT VARCHAR2,
					  p_fund OUT VARCHAR2,
					  p_status OUT VARCHAR2,
					  p_error_msg OUT VARCHAR2);
	--flip trade and flip borrow can't be sb at same time
	--new borrow is SB Return cpty is NSB or NULL 0189 can't have value
	PROCEDURE GENERATE_BOOK_DATA(p_flip_borrow_id IN NUMBER,
								p_flip_trade_id IN NUMBER,
								p_user_id IN VARCHAR2,
								p_status OUT VARCHAR2,
								p_error_msg OUT VARCHAR2,
								p_error_hint OUT VARCHAR2);
	PROCEDURE LOCK_FLIP_TRADES(p_demand_request_id NUMBER,p_input_type IN VARCHAR2,p_flip_trade_id NUMBER);
	PROCEDURE FILL_FLIP_ERROR_RST(p_flip_cursor OUT SYS_REFCURSOR, p_borrows_cursor OUT SYS_REFCURSOR);
	PROCEDURE SINGLE_FLIP_ALLOCATION(p_flip_trade_id IN NUMBER,
									p_user_id IN VARCHAR2,
									p_status OUT VARCHAR2,
									p_error_msg OUT VARCHAR2,
									p_error_hint OUT VARCHAR2);
	PROCEDURE CANCEL_FLIP_BORROW(p_borrow_id IN NUMBER,
								 p_status OUT VARCHAR2,
								 p_flip_trade_cursor OUT SYS_REFCURSOR
								 );
	--p_user_id the user who allocate the flip trade
	--p_demand_request_id the request id for file or message
	--p_input_type 
	--
	PROCEDURE PROCESS_FLIP_ALLOCATION(p_user_id IN VARCHAR2,
									  p_demand_request_id IN NUMBER,
                            		  p_input_type IN VARCHAR2,
                            		  p_borrow_file_type IN VARCHAR2,
                            		  p_trans_type IN VARCHAR2,
                            		  p_flip_trade_id IN NUMBER,
                            		  p_is_dirty IN VARCHAR2,
                            		  p_status OUT VARCHAR2,
                            		  p_error_msg OUT VARCHAR2,
                            		  p_error_hint OUT VARCHAR2,
                            		  p_flip_cursor OUT SYS_REFCURSOR,
									  p_borrows_cursor OUT SYS_REFCURSOR);	
									  								  	
	PROCEDURE DELETE_MANU_INTERV_FLIP_BORROW(
											p_flip_trade_id IN NUMBER,
											p_borrow_id IN NUMBER,
											p_status OUT VARCHAR2,
											p_flip_trade_cursor OUT SYS_REFCURSOR
										);
	PROCEDURE VALIDATE_MANUAL_INTERVATION(p_flip_trade_id IN NUMBER,p_is_dirty IN VARCHAR2,p_manual_flag OUT VARCHAR2);	
	PROCEDURE UPDATE_FLIP_TRADE_BORROW_TO_M(p_flip_trade_id IN NUMBER,p_intervation_reason IN VARCHAR2);	
	PROCEDURE VALIDATE_BORROWS(p_flip_trade_id IN NUMBER,var_valid OUT VARCHAR2);
	PROCEDURE FILL_FLIP_TRADE_ERROR_RST(p_flip_cursor OUT SYS_REFCURSOR);	  
	PROCEDURE BATCH_VLD_FLIP_TRADE_DATE(p_desktop_date IN DATE,p_faild_counts OUT NUMBER);
END GEC_FLIP_TRADE_PKG;
/

create or replace PACKAGE BODY GEC_FLIP_TRADE_PKG
AS

	PROCEDURE UPLOAD_FLIP_TRADES_FILE( p_record_num OUT VARCHAR2, p_error_msg   OUT VARCHAR2)
	IS
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_FLIP_TRADE_PKG.UPLOAD_FLIP_TRADES';
    var_valid VARCHAR2(1) := 'Y';
    CURSOR v_cur_set_trade_country IS
		SELECT 	temp.rowid row_id, country.trade_country_cd
		FROM 	gec_flip_trade_temp  temp , GEC_TRADE_COUNTRY country
		WHERE 	LENGTH(temp.trade_country_cd) = 3 
		and 	country.currency_cd = temp.trade_country_cd;
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
    --CORRECT ALL TRADE COUNTRIES TO SHORT NAME LIKE USD->US
		FOR VAR_REC IN  v_cur_set_trade_country LOOP
			UPDATE gec_flip_trade_temp temp
			 SET	trade_country_cd = 	VAR_REC.trade_country_cd
			where temp.rowid = VAR_REC.row_id;
		end LOOP;
    --validate flip trade
    VALIDATE_FLIP_TRADES('FILE',p_record_num,p_error_msg,var_valid);
    
    IF var_valid = 'N' THEN
        RETURN;
    ELSE 
        p_error_msg := NULL;
    END IF;
    --insert 
	    INSERT_FROM_TEMP;
		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END UPLOAD_FLIP_TRADES_FILE;	

    PROCEDURE UPLOAD_FLIP_TRADES_INPUT(p_retFlipTradeList OUT SYS_REFCURSOR)
    IS
    	V_PROCEDURE_NAME CONSTANT VARCHAR(200) := 'GEC_FLIP_TRADE_PKG.UPLOAD_FLIP_TRADES_INPUT';
      var_error_msg VARCHAR2(200);
      var_record_num NUMBER;
    	var_valid VARCHAR2(1) := 'Y';
    BEGIN
    	GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
    	
    	OPEN p_retFlipTradeList FOR
    			select  ASSET_CODE, TRADE_DATE, SETTLE_DATE,SHARE_QTY,MIN_QTY,INC_QTY,RETURN_BRANCH_CD, BORROW_RETURN_CPTY,RECALL_FLAG,RETURN_BARGAIN_REF,TRADE_COUNTRY_CD,
    					RECALL_DUE_DATE,RECALL_COMMENT_TXT, ASSET_ERROR, TRADE_DATE_ERROR, SETTLE_DATE_ERROR, SHARE_QTY_ERROR
    			from GEC_FLIP_TRADE_TEMP 
    			WHERE 1=0;
          
			--validate flip trade
    	VALIDATE_FLIP_TRADES('INPUT',var_record_num,var_error_msg,var_valid);
  		
  		IF var_valid = 'N' THEN
  			OPEN p_retFlipTradeList FOR
    			select ASSET_CODE, TRADE_DATE, SETTLE_DATE,SHARE_QTY,MIN_QTY,INC_QTY,RETURN_BRANCH_CD, BORROW_RETURN_CPTY,RECALL_FLAG,RETURN_BARGAIN_REF,TRADE_COUNTRY_CD,
    				 RECALL_DUE_DATE,RECALL_COMMENT_TXT, ASSET_ERROR, TRADE_DATE_ERROR, SETTLE_DATE_ERROR, SHARE_QTY_ERROR
    			from GEC_FLIP_TRADE_TEMP;
	    		RETURN;
	   ELSE
	   		--insert table
	    	INSERT_FROM_TEMP;
	   END IF; 

    	GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
    END UPLOAD_FLIP_TRADES_INPUT;
  
  	PROCEDURE VALIDATE_FLIP_TRADES(p_type IN VARCHAR2,p_record_num out VARCHAR2, p_error_msg OUT VARCHAR2,p_valid OUT VARCHAR2)	
	IS
    var_asset_rs GEC_ASSET_TP_ARRAY;
		var_asset GEC_ASSET_TP;
		var_found_flag NUMBER;  
		var_asset_code_type gec_asset_identifier.asset_code_type%TYPE;
		var_status VARCHAR2(1);
    var_default_trade_cty gec_flip_trade_temp.trade_country_cd%TYPE:='US';
    var_trade_cty gec_flip_trade_temp.trade_country_cd%TYPE;
    var_unfilled_qty NUMBER;
    var_found_cpty VARCHAR2(1) := 'N';
    var_cpty_temp VARCHAR2(6);
    v_rtn_bargain_refs VARCHAR2(201);
    v_new_rtn_bargain_refs VARCHAR2(200);
    v_rtn_bargain_ref VARCHAR2(16);
    v_G1_instance VARCHAR2(4);
    var_i Number := 0;
    var_max Number;
    v_count Number;
    v_length Number;
    v_sep varchar2(1) :=';';
		CURSOR var_flip_trades_cur IS
			SELECT ROWID row_id, asset_code,flip_trade_id, cusip, isin, sedol,
					quik, ticker, description, transaction_cd,
					trade_country_cd, TRADE_DATE, SETTLE_DATE, 
			        min_qty, inc_qty, SHARE_QTY,filled_qty,
			        ssgm_loan_qty,ssgm_loan_return_qty ,recall_due_date,RETURN_BRANCH_CD,
			        RETURN_BARGAIN_REF,recall_flag,borrow_return_cpty
			 FROM gec_flip_trade_temp;
	BEGIN	
      IF p_type = 'FILE' THEN
        FOR item IN  var_flip_trades_cur LOOP
          p_record_num := to_char(item.flip_trade_id);
          -- validate security
          GEC_VALIDATION_PKG.VALIDATE_ASSET_ID(item.cusip,item.isin,item.sedol,item.quik ,
                            item.ticker,item.description,item.trade_country_cd,NULL,NULL,
                            var_found_flag,var_asset_code_type,var_status,var_asset_rs);
          IF var_found_flag = 0 THEN
            p_valid := 'N';
            p_error_msg := 'Security not found.';
            RETURN;
          ELSIF var_found_flag = 1 THEN 
            var_asset := var_asset_rs(1);
            var_trade_cty :=NVL(var_asset.trade_country_cd, var_default_trade_cty);
            UPDATE gec_flip_trade_temp
            SET 
              asset_id = var_asset.asset_id,
              trade_country_cd = var_trade_cty
            WHERE flip_trade_id = item.flip_trade_id;
            IF item.min_qty IS NULL AND item.inc_qty IS NULL THEN
            	IF var_trade_cty ='US' OR var_trade_cty ='CA'THEN
            		UPDATE gec_flip_trade_temp
		            SET 
		              min_qty =100,
		              inc_qty = 100
		            WHERE flip_trade_id = item.flip_trade_id;
            	ELSE
            		UPDATE gec_flip_trade_temp
		            SET 
		              min_qty = 1,
		              inc_qty = 1
		            WHERE flip_trade_id = item.flip_trade_id;
            	END IF;
            	
            END IF;
            
            --trade date should be business day
            IF GEC_UTILS_PKG.IS_WORKDAY(GEC_UTILS_PKG.NUMBER_TO_DATE(item.TRADE_DATE),NVL(var_asset.trade_country_cd, var_default_trade_cty)) = 'N' THEN
              p_valid := 'N';
              p_error_msg := 'The Trade Date you entered is a non-trading Date.';
              return;
            END IF;
            --settle date should be business day
            IF GEC_UTILS_PKG.IS_WORKDAY(GEC_UTILS_PKG.NUMBER_TO_DATE(item.SETTLE_DATE),NVL(var_asset.trade_country_cd, var_default_trade_cty),'S') = 'N' THEN
              p_valid := 'N';
              p_error_msg := 'The Settle Date you entered is a non-trading Date.';
              RETURN;
            END IF;
            --settle date should not less than trade date
            IF item.SETTLE_DATE < item.TRADE_DATE THEN
              p_valid := 'N';
              p_error_msg := 'The Settle Date should not be less than Trade Date.';
              RETURN;
            END IF;
            
           --Corp Bond with quantity which is not multiples of 1000.
            IF 	NOT REGEXP_LIKE(item.SHARE_QTY,'000$') AND var_asset.ASSET_TYPE_ID = '2' THEN
                p_valid := 'N';
                p_error_msg := 'Request Qty for Corp Bond should be divisible for 1000.';
                return;
            END IF;
          ELSE
            p_valid := 'N';
            p_error_msg := 'Multiple securities have been found for this Asset ID.';
            return;
          END IF;
          
          --0189 LN and 0189 LN Rtn can’t be filled together
          IF item.ssgm_loan_qty != 0 AND item.ssgm_loan_qty IS NOT NULL 
            AND item.ssgm_loan_return_qty != 0 AND item.ssgm_loan_return_qty IS NOT NULL THEN 
            p_valid := 'N';
            p_error_msg := '0189LN and 0189LN Rtn cannot be entered at a time.';
            RETURN;
          END IF;
          
          --Record can’t comply with the formula of Unfilled Qty, Min Qty, Inc Qty.
          var_unfilled_qty := item.share_qty-item.filled_qty+item.SSGM_LOAN_QTY-item.SSGM_LOAN_RETURN_QTY;
          IF var_unfilled_qty <0 THEN
            var_unfilled_qty := 0;
          END IF;
          IF mod(var_unfilled_qty,item.inc_qty)!=0 THEN
            p_valid := 'N';
            p_error_msg := 'Unfilled Qty should be divisible by Inc Qty. Please Verify.';
            return;
          END IF;
          IF mod(item.min_qty,item.inc_qty)!=0 THEN 
            p_valid := 'N';
            p_error_msg := 'Min Qty should be divisible by Inc Qty. Please Verify.';
            return;
          END IF;
          --if unfilled Qty greater than Min Qty, Inc Qty should not greater than the difference between Brw Qty and Min Qty
          IF var_unfilled_qty != item.min_Qty AND item.inc_qty > var_unfilled_qty-item.min_qty THEN
            p_valid := 'N';
            p_error_msg := 'Inc Qty cannot be greater than the difference between Unfilled Qty and Min Qty.';
            return;
          END IF;
          --if unfilled Qty = Min Qty, Inc Qty = Min Qty. 
          IF var_unfilled_qty = item.min_qty AND item.min_qty != item.inc_qty THEN
            p_valid := 'N';
            p_error_msg := 'Inc Qty should be equal to Min Qty if Unfilled Qty and Min Qty is same.';
            return;
          END IF;

           --Borrow Return Counterparty and Return Bargain Ref can’t be filled together
          IF (item.RETURN_BARGAIN_REF IS NOT NULL AND (item.borrow_return_cpty IS NOT NULL OR item.RETURN_BRANCH_CD IS NOT NULL)) OR (item.borrow_return_cpty IS NOT NULL AND (item.RETURN_BARGAIN_REF IS NOT NULL OR item.RETURN_BRANCH_CD IS NOT NULL)) THEN 
            p_valid := 'N';
            p_error_msg := 'Return Branch and Borr Rtn Cpty and Rtn Bargain Ref cannot be entered at a time.';
            RETURN;
          END IF;
          
          -- Recall is Y, Borr Return Cpty is blank
          IF item.recall_flag = 'Y' AND item.borrow_return_cpty IS NULL AND item.RETURN_BARGAIN_REF IS NULL THEN
            p_valid := 'N';
            p_error_msg := 'Either Borr Rtn Cpty or Rtn Bargain Ref is required for Recall Trades.';
            RETURN;
          END IF;
          
          IF item.recall_flag = 'Y' AND item.RETURN_BRANCH_CD IS NOT NULL THEN
            p_valid := 'N';
            p_error_msg := 'Return Branch is not required for Recall Trades.';
            RETURN;
          END IF;
          
          
          -- Recall is Y, Borr Return Cpty is blank
          IF item.recall_flag = 'Y' AND item.recall_due_date IS NULL THEN
            p_valid := 'N';
            p_error_msg := 'Recall Due Dt is required for Recall Trades.';
            RETURN;
          END IF;
          --2.3 ZWH
          IF item.RETURN_BRANCH_CD IS NOT NULL THEN
          		SELECT count(BRANCH_CD) INTO v_count FROM GEC_BRANCH WHERE BRANCH_CD=item.RETURN_BRANCH_CD;
          		IF v_count =0 THEN
          			 p_valid := 'N';
		             p_error_msg := 'Invalid Return Branch - Please Verify.';
		             RETURN;
          		END IF;
          END IF;
          
          --Return_Bargain_Refs
          IF item.RETURN_BARGAIN_REF IS NOT NULL THEN
          		v_length := LENGTH(item.RETURN_BARGAIN_REF);
          		IF v_length > 20 THEN
          			 p_valid := 'N';
		             p_error_msg := 'The length of Rtn Bargain Ref cannot be greater than 20.';
		             RETURN;
          		END IF;
          		
          		IF NOT REGEXP_LIKE(item.RETURN_BARGAIN_REF,'[a-zA-Z0-9]+') THEN
          		 	p_valid := 'N';
           			p_error_msg := 'Invalid character in RETURN_BARGAIN_REF.';
           			RETURN;
          		END IF;
          		
          		v_rtn_bargain_refs := item.RETURN_BARGAIN_REF||v_sep;
          		while v_rtn_bargain_refs is not null loop
               		v_rtn_bargain_ref := rtrim(substr(
                       v_rtn_bargain_refs,1,instr(v_rtn_bargain_refs,v_sep)),v_sep);
                       v_length := LENGTH(v_rtn_bargain_ref);
                       IF v_length > 16 THEN
          			 		p_valid := 'N';
		            		p_error_msg := 'The length of one Rtn Bargain Ref cannot be greater than 12.';
		             		RETURN;
          			   END IF;
          			   SELECT G1_INSTANCE_CD INTO v_G1_instance FROM GEC_G1_INSTANCE WHERE upper(G1_INSTANCE_CD)=upper(substr(v_rtn_bargain_ref,0,4));
          			   	IF v_G1_instance IS NULL THEN
          			 		p_valid := 'N';
		             		p_error_msg := 'Invalid G1Instance in Rtn Bargain Ref - Please Verify.';
		             		RETURN;
          				END IF;
          				IF v_new_rtn_bargain_refs is null then
          				v_new_rtn_bargain_refs := v_new_rtn_bargain_refs||v_G1_instance||substr(v_rtn_bargain_ref,5);
          				ELSE
          				v_new_rtn_bargain_refs := v_new_rtn_bargain_refs||v_sep||v_G1_instance||substr(v_rtn_bargain_ref,5);
          				END IF;
               		v_rtn_bargain_refs := substr(v_rtn_bargain_refs,instr(v_rtn_bargain_refs,v_sep)+1);
              end loop;
              
              update GEC_FLIP_TRADE_TEMP gftt set gftt.RETURN_BARGAIN_REF = v_new_rtn_bargain_refs where gftt.FLIP_TRADE_ID = item.FLIP_TRADE_ID;
          		
          END IF;
          
          --Borr Return Cpty can’t found in broker list.
          IF item.borrow_return_cpty IS NOT NULL THEN
            var_max := 6-LENGTH(item.borrow_return_cpty);
            var_cpty_temp := item.borrow_return_cpty;
            loop
              var_found_cpty := VALIDATE_BRW_RTN_CPTY(var_cpty_temp);
              if var_i>=var_max OR var_found_cpty='Y' then
                exit;
              END IF;
              var_i := var_i + 1;
              SELECT LPAD(borrow_return_cpty, LENGTH(borrow_return_cpty)+1, '0') INTO var_cpty_temp 
              FROM GEC_FLIP_TRADE_TEMP WHERE flip_trade_id = item.flip_trade_id;
              UPDATE GEC_FLIP_TRADE_TEMP SET borrow_return_cpty = var_cpty_temp  WHERE flip_trade_id=item.flip_trade_id;
            end loop;
            IF var_found_cpty = 'N' THEN
              p_valid := 'N';
              p_error_msg := 'Invalid Borr Rtn Cpty - Please Verify.';
              RETURN;
            END IF;
          END IF;
      END LOOP;  
    ELSE 
  		FOR v_item IN var_flip_trades_cur LOOP 
    		--begin validate asset code
        GEC_VALIDATION_PKG.VALIDATE_ASSET_ID(NULL, NULL,NULL,NULL,NULL,NULL,NULL,v_item.ASSET_CODE,
                              NULL,var_found_flag,var_asset_code_type,var_status ,var_asset_rs);
	      IF var_found_flag=0 THEN
          p_valid := 'N';
	        UPDATE GEC_FLIP_TRADE_TEMP 
					SET ASSET_ERROR = 'Security not found.'
					WHERE rowid=v_item.row_id;
        ELSIF var_found_flag=1 THEN
					var_asset := var_asset_rs(1);
					UPDATE GEC_FLIP_TRADE_TEMP
					SET 
						asset_id = var_asset.asset_id,
	          trade_country_cd = NVL(var_asset.trade_country_cd, var_default_trade_cty)
					WHERE ROWID = v_item.row_id;
          --begin validate trade date
           IF GEC_UTILS_PKG.IS_WORKDAY(GEC_UTILS_PKG.NUMBER_TO_DATE(v_item.trade_date),NVL(var_asset.trade_country_cd, var_default_trade_cty))='N' THEN
             p_valid := 'N';
             Update GEC_FLIP_TRADE_TEMP 
             Set Trade_Date_Error = 'The Trade Date you entered is a non-trading Date.'
             WHERE Rowid=v_item.row_id;
           END IF;
           --begin validate settle date
           IF gec_utils_pkg.is_workday(gec_utils_pkg.number_to_date(v_item.settle_date),NVL(var_asset.trade_country_cd, var_default_trade_cty),'S')='N' THEN
             p_valid := 'N';
             UPDATE gec_flip_trade_temp 
             SET settle_date_error = 'The Settle Date you entered is a non-trading Date.'
             WHERE ROWID=v_item.row_id;
           END IF;
           --begin validate share qty
          IF var_asset.ASSET_TYPE_ID = '2' AND NOT REGEXP_LIKE(v_item.SHARE_QTY,'000$') THEN
              p_valid := 'N';
              UPDATE gec_flip_trade_temp 
              SET SHARE_QTY_ERROR = 'Request Qty for Corp Bond should be divisible for 1000.'
              WHERE ROWID=v_item.row_id;
          END IF;
        ELSE
          p_valid := 'N';
          UPDATE GEC_FLIP_TRADE_TEMP 
          SET ASSET_ERROR = 'Multiple securities have been found for this Asset ID.'
          WHERE rowid=v_item.row_id;
        END IF;
      END Loop;
    END IF;
	END VALIDATE_FLIP_TRADES;
  
    FUNCTION VALIDATE_BRW_RTN_CPTY(p_brw_rtn_cpty IN VARCHAR2)RETURN VARCHAR2
  IS
    v_found VARCHAR2(1) := 'N';
	BEGIN
      BEGIN
      SELECT 'Y' INTO v_found FROM DUAL
              WHERE EXISTS(SELECT 1 FROM gec_broker_vw broker 
                            WHERE broker.book_g1_borrow_flag != 'N' AND broker.LEGAL_ENTITY_CD = 'SSBT'
			and broker.BORROW_REQUEST_TYPE != 'Intercompany Counterparty' AND broker.broker_cd = p_brw_rtn_cpty);
              EXCEPTION WHEN NO_DATA_FOUND THEN
      v_found := 'N';
      END;
      return v_found;
    
	END VALIDATE_BRW_RTN_CPTY;
  
	  PROCEDURE INSERT_FROM_TEMP
	  IS
	  BEGIN
	    INSERT INTO GEC_FLIP_TRADE ( FLIP_TRADE_ID,ASSET_ID,TRANSACTION_CD,TRADE_COUNTRY_CD,
		    				TRADE_DATE,SETTLE_DATE,MIN_QTY,INC_QTY,SHARE_QTY,EXPORT_STATUS,RECALL_FLAG,
		    				FILLED_QTY,STATUS,RECALL_DUE_DATE,RETURN_BRANCH_CD,BORROW_RETURN_CPTY,RETURN_BARGAIN_REF,
	              SSGM_LOAN_QTY,SSGM_LOAN_RETURN_QTY,NSB_LOAN_RATE,RECALL_COMMENT_TXT)
					SELECT  GEC_FLIP_TRADE_ID_SEQ.nextval,ASSET_ID,TRANSACTION_CD,TRADE_COUNTRY_CD,
		    				TRADE_DATE,SETTLE_DATE,MIN_QTY,INC_QTY,SHARE_QTY,EXPORT_STATUS,RECALL_FLAG,
		    				FILLED_QTY,STATUS,RECALL_DUE_DATE,RETURN_BRANCH_CD,BORROW_RETURN_CPTY,RETURN_BARGAIN_REF,
	              SSGM_LOAN_QTY,SSGM_LOAN_RETURN_QTY,NSB_LOAN_RATE,RECALL_COMMENT_TXT
			FROM GEC_FLIP_TRADE_TEMP;
	  END INSERT_FROM_TEMP;
	  
	  PROCEDURE SAVE_FLIP_TRADES(p_errorCode   OUT VARCHAR2,p_flip_trades OUT SYS_REFCURSOR)
	  IS
      v_valid VARCHAR(1) := 'Y';
      CURSOR v_cur_flip_trades IS
	        SELECT gft.flip_trade_id,
	        gft.status,
	        gft.export_status,
          gft.trade_country_cd,
	        gftt.status status_temp,
	        gftt.export_status export_status_temp,
	        gftt.trade_date trade_date_temp,
	        gftt.settle_date settle_date_temp,
	        gftt.min_qty min_qty_temp,
	        gftt.inc_qty inc_qty_temp,
	        gftt.RETURN_BRANCH_CD,
	        gftt.borrow_return_cpty borrow_return_cpty_temp,
	        gftt.RETURN_BARGAIN_REF return_bargain_ref_temp,
	        gftt.RECALL_FLAG recall_flag_temp,
	        gftt.SHARE_QTY,
	        gftt.RECALL_DUE_DATE recall_due_date_temp,
	        gftt.SSGM_LOAN_QTY ssgm_loan_qty_temp,
	        gftt.SSGM_LOAN_RETURN_QTY ssgm_loan_return_qty_temp,
	        gftt.NSB_LOAN_RATE nsb_loan_rate_temp,
	        gftt.RECALL_COMMENT_TXT RECALL_COMMENT_TXT_TEMP
	        FROM GEC_FLIP_TRADE_TEMP gftt 
	        JOIN gec_flip_trade gft
	        ON gftt.flip_trade_id=gft.flip_trade_id
	        ORDER BY gft.flip_trade_id
	        for update of gft.flip_trade_id;
	  BEGIN
        OPEN p_flip_trades FOR
    			select FLIP_TRADE_ID, TRADE_DATE_ERROR, SETTLE_DATE_ERROR
    			FROM GEC_FLIP_TRADE_TEMP 
    			WHERE 1=0;
          
        FOR v_item_valid IN v_cur_flip_trades
	      LOOP
          IF v_item_valid.status != v_item_valid.status_temp THEN
	          p_errorCode := 'VLD0202';
	          return;
	        END IF;
	        IF v_item_valid.export_status != v_item_valid.export_status_temp THEN
	          p_errorCode := 'VLD0202';
	          RETURN;
			    END IF;
          --begin validate trade date
           IF GEC_UTILS_PKG.IS_WORKDAY(GEC_UTILS_PKG.NUMBER_TO_DATE(v_item_valid.trade_date_temp),v_item_valid.trade_country_cd)='N' THEN
             v_valid := 'N';
             Update GEC_FLIP_TRADE_TEMP 
             Set Trade_Date_Error = 'The Trade Date you entered is a non-trading Date.'
             WHERE flip_trade_id=v_item_valid.flip_trade_id;
           END IF;
           --begin validate settle date
           IF gec_utils_pkg.is_workday(gec_utils_pkg.number_to_date(v_item_valid.settle_date_temp),v_item_valid.trade_country_cd,'S')='N' THEN
             v_valid := 'N';
             UPDATE gec_flip_trade_temp 
             SET settle_date_error = 'The Settle Date you entered is a non-trading Date.'
             WHERE flip_trade_id=v_item_valid.flip_trade_id;
           END IF;
        END LOOP;
  		
  		IF v_valid = 'N' THEN
  			OPEN p_flip_trades FOR
    			SELECT FLIP_TRADE_ID, TRADE_DATE_ERROR, SETTLE_DATE_ERROR
    			FROM GEC_FLIP_TRADE_TEMP 
          WHERE TRADE_DATE_ERROR IS NOT NULL 
          or settle_date_error is not null;
	    		RETURN;
	   ELSE
        --update table
	      FOR v_item IN v_cur_flip_trades
	      LOOP
	        UPDATE gec_flip_trade
	        SET trade_date=v_item.trade_date_temp,
	        SHARE_QTY=v_item.SHARE_QTY,
	        settle_date=v_item.settle_date_temp,
	        min_qty=v_item.min_qty_temp,
	        inc_qty=v_item.inc_qty_temp,
	        SSGM_LOAN_QTY=v_item.SSGM_LOAN_QTY_TEMP,
	        SSGM_LOAN_RETURN_QTY=v_item.SSGM_LOAN_RETURN_QTY_TEMP,
	        NSB_LOAN_RATE=v_item.NSB_LOAN_RATE_TEMP,
	        RETURN_BRANCH_CD=v_item.RETURN_BRANCH_CD,
	        BORROW_RETURN_CPTY=v_item.BORROW_RETURN_CPTY_TEMP,
	        RECALL_FLAG = v_item.recall_flag_temp,
	        RETURN_BARGAIN_REF=v_item.return_bargain_ref_temp,
	        RECALL_DUE_DATE = v_item.recall_due_date_temp,
	        RECALL_COMMENT_TXT=v_item.RECALL_COMMENT_TXT_TEMP
	        where flip_trade_id=v_item.flip_trade_id;
	      END LOOP;
      END IF; 
	  END SAVE_FLIP_TRADES;
  
  PROCEDURE CANCEL_FLIP_TRADES(p_flip_trade_ids IN VARCHAR2,p_flip_trades OUT SYS_REFCURSOR,p_errorCode  OUT VARCHAR2)
  IS
    v_id_array GEC_UTILS_PKG.t_number_array;
    v_id NUMBER;
    temp_cur SYS_REFCURSOR;
    CURSOR row_cursor
    IS 
    SELECT ft.FLIP_TRADE_ID,
      ft.FILLED_QTY,
      ft.status,
      ft.SHARE_QTY,
      ft.SSGM_LOAN_QTY,
      ft.SSGM_LOAN_RETURN_QTY,
      ft.export_status
      FROM GEC_FLIP_TRADE ft
      where 1=0;
    v_item row_cursor%ROWTYPE;
    v_error_code VARCHAR2(200) := null;
	  BEGIN
        
        v_id_array := GEC_UTILS_PKG.SPLIT_TO_NUMBER_ARRAY(p_flip_trade_ids);
        FOR i IN 1..v_id_array.count LOOP
          v_id := v_id_array(i);
          INSERT INTO GEC_FLIP_TRADE_TEMP(FLIP_TRADE_ID)values(v_id);
        END LOOP;
        OPEN temp_cur FOR
          SELECT ft.FLIP_TRADE_ID,
          ft.FILLED_QTY,
          ft.status,
          ft.SHARE_QTY,
	      ft.SSGM_LOAN_QTY,
	      ft.SSGM_LOAN_RETURN_QTY,
          ft.export_status
          FROM GEC_FLIP_TRADE_TEMP gftt
          JOIN GEC_FLIP_TRADE ft
          ON gftt.FLIP_TRADE_ID = ft.FLIP_TRADE_ID
          order by ft.FLIP_TRADE_ID
          FOR UPDATE OF ft.FLIP_TRADE_ID;
        LOOP
          FETCH temp_cur INTO v_item;
          EXIT WHEN temp_cur%NOTFOUND;
          --validation
	
          IF v_item.status != 'P' OR v_item.export_status = 'I' OR (v_item.SHARE_QTY-v_item.FILLED_QTY-v_item.SSGM_LOAN_RETURN_QTY) <= 0 THEN
            p_errorCode := 'VLD0215';
          END IF;
        END LOOP;
        CLOSE temp_cur;
      
        IF p_errorCode IS NULL THEN
          UPDATE GEC_FLIP_TRADE SET status = 'C' WHERE FLIP_TRADE_ID IN (SELECT FLIP_TRADE_ID FROM GEC_FLIP_TRADE_TEMP);
        END IF;
        
        OPEN p_flip_trades FOR
        SELECT 
				gft.flip_trade_id,
				gft.ASSET_ID,
				ga.cusip,
				ga.isin,
				ga.sedol,
				ga.ticker,
				ga.quik,
				ga.description,
				gft.trade_country_cd,
				gft.transaction_cd,
				gft.trade_date,
				gft.settle_date,
				gft.recall_due_date,
				gft.share_qty,
				gft.filled_qty,
				gft.min_qty,
				gft.inc_qty,
				gft.status,
				gft.export_status,
				gft.RETURN_BRANCH_CD,
				gft.borrow_return_cpty,
				gft.RETURN_BARGAIN_REF,
				gft.ssgm_loan_qty,
				gft.ssgm_loan_return_qty,
				gft.nsb_loan_rate,
				gft.recall_comment_txt,
				gft.recall_flag,
				gtc.PREBORROW_ELIGIBLE_FLAG,
				gtc.PREPAY_DATE_VALUE,
				gft.share_qty-gft.filled_qty-gft.ssgm_loan_return_qty as export_enable_qty
			FROM gec_flip_trade gft
			JOIN gec_asset ga
			on gft.asset_id = ga.asset_id
			JOIN GEC_TRADE_COUNTRY gtc 
			ON gft.TRADE_COUNTRY_CD = gtc.TRADE_COUNTRY_CD
			WHERE gft.flip_trade_id in(SELECT FLIP_TRADE_ID FROM GEC_FLIP_TRADE_TEMP);
  END CANCEL_FLIP_TRADES;  
  
	PROCEDURE EXPORT_FLIP_TRADE_REQUEST(p_type IN VARCHAR2,
                                      p_request_file_type	IN VARCHAR2,
                                      p_flip_trade_ids IN VARCHAR2,
                                      p_current_date IN NUMBER,
                                      p_settle_market		IN VARCHAR2,
                                      p_trade_countries		IN VARCHAR2,
                                      p_settle_dates  IN VARCHAR2,
                                      p_equilend_chain_id     IN NUMBER,
                                      p_equilend_schedule_id  IN NUMBER,
                                      p_auto_release_rule_id  IN NUMBER,
                                      p_request_by			IN VARCHAR2,
                                      p_full_fill 			IN VARCHAR2,
                                      p_recall_flag 		IN VARCHAR2,
                                      p_borrow_request_id 	OUT NUMBER,
                                      p_errorCode         	OUT VARCHAR2)
	IS
    V_PROCEDURE_NAME CONSTANT VARCHAR(200) := 'GEC_FLIP_TRADE_PKG.MANUAL_EXPORT_FLIP_TRADE';
    v_trade_countries VARCHAR2(500) := p_trade_countries;
    v_settle_dates VARCHAR2(200) := p_settle_dates;
    v_count_trades NUMBER := 0;
    v_request_time date := sysdate;
    v_order_exp_period GEC_CONFIG.ATTR_VALUE1%TYPE := null;
    v_expiration_time date := null;
    v_request_type GEC_BRW_REQUEST_FILE_TYPE.BORROW_REQUEST_TYPE%TYPE;
    v_auto_borrow_batch_id GEC_BORROW_REQUEST.AUTOBORROW_BATCH_ID%TYPE := NULL;
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);


    IF p_type = GEC_CONSTANTS_PKG.C_AUTO_RELEASE_REQUEST THEN
      v_trade_countries := GEC_BORROWREQUEST_PKG.GET_TRADE_COUNTRIES(p_trade_countries);
      v_settle_dates := GEC_BORROWREQUEST_PKG.GET_SETTLE_DATES(p_settle_dates);
      --insert trades to temp table
      GET_FT_TRADES(v_trade_countries,v_settle_dates,p_recall_flag);
      --remove the exceptions for auto release
      REMOVE_EXCEPTION_TRADES(p_auto_release_rule_id);
    ELSE
      --validate flip trade and insert temp table before exporting
      p_errorCode := GET_FLIP_TRADES_BY_IDS(p_flip_trade_ids,p_current_date);
      IF p_errorCode IS NOT NULL THEN
        return;
      END IF;
    END IF;
    
    --No demand
    select count(*) into v_count_trades from GEC_INFLIGHT_FT_TEMP;
    IF v_count_trades = 0 THEN
      RETURN;
    END IF;

    --Get order expire time for schedule
    IF p_equilend_schedule_id is not null THEN
      SELECT ATTR_VALUE1 INTO v_order_exp_period FROM GEC_CONFIG WHERE attr_group='EQUILEND' AND attr_name = 'ORDER_EXP_PERIOD';
      v_expiration_time := GEC_BORROWREQUEST_PKG.GET_EXPIRATION_TIME(v_request_time,v_order_exp_period);
    END IF;
    
    --Get auto borrow batch id
    IF p_type != GEC_CONSTANTS_PKG.C_FILE_REQUEST THEN
      SELECT TO_CHAR(sysdate, 'YYYYMMDD') || LPAD( GEC_UTILS_PKG.RIGHT_ ( GEC_AUTO_BORROW_BATCH_ID_SEQ.NEXTVAL , 16), 16, '0') 
      INTO v_auto_borrow_batch_id FROM dual;
    END IF;
         
    --There are demands, Create Request
		SELECT BORROW_REQUEST_TYPE INTO v_request_type FROM GEC_BRW_REQUEST_FILE_TYPE WHERE BORROW_REQUEST_FILE_TYPE = p_request_file_type;
		SELECT GEC_REQUEST_ID_SEQ.NEXTVAL INTO p_borrow_request_id FROM DUAL;
    INSERT INTO GEC_BORROW_REQUEST(BORROW_REQUEST_ID, AUTOBORROW_BATCH_ID,BORROW_REQUEST_TYPE, BORROW_REQUEST_FILE_TYPE, 
    STATUS, STATUS_MSG,SETTLEMENT_MARKET,EQUILEND_CHAIN_ID,EQUILEND_SCHEDULE_ID,TYPE,REQUEST_BY, REQUEST_AT,EXPIRATION_TIME,FULL_FILL)
    VALUES(p_borrow_request_id,v_auto_borrow_batch_id, v_request_type, p_request_file_type,GEC_CONSTANTS_PKG.C_INFLIGHT_STATUS,GEC_CONSTANTS_PKG.C_INFLIGHT_STATUS_MSG,
    p_settle_market,p_equilend_chain_id,p_equilend_schedule_id, p_type,p_request_by, v_request_time,v_expiration_time,p_full_fill);
    
		FILL_DEMANDS_WITH_FLIP_TRADES(p_borrow_request_id,p_type);
    
		GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME);
	END EXPORT_FLIP_TRADE_REQUEST;  
  
  	FUNCTION GET_FLIP_TRADES_BY_IDS(p_flip_trade_ids	IN VARCHAR2,p_current_date IN NUMBER ) RETURN VARCHAR2
	IS
    v_id_array GEC_UTILS_PKG.t_number_array;
    v_id NUMBER;
    temp_cur SYS_REFCURSOR;
    CURSOR row_cursor
    IS 
    SELECT ft.FLIP_TRADE_ID,
      ft.ASSET_ID,
      ft.SHARE_QTY,
      ft.FILLED_QTY,
      ft.settle_date,
      ft.MIN_QTY,
      ft.inc_qty,
      ft.TRANSACTION_CD,
      ft.status,
      ft.export_status,
      ft.SSGM_LOAN_QTY,
      ft.SSGM_LOAN_RETURN_QTY,
      gtc.PREBORROW_ELIGIBLE_FLAG
      FROM GEC_FLIP_TRADE ft
      JOIN GEC_TRADE_COUNTRY gtc ON ft.TRADE_COUNTRY_CD = gtc.TRADE_COUNTRY_CD
      where 1=0;
    v_item row_cursor%ROWTYPE;
    v_unfilled_qty Number;
    v_error_code VARCHAR2(200) := null;
	BEGIN
    v_id_array := GEC_UTILS_PKG.SPLIT_TO_NUMBER_ARRAY(p_flip_trade_ids);
		FOR i IN 1..v_id_array.count LOOP
       v_id := v_id_array(i);
       INSERT INTO GEC_INFLIGHT_FT_TEMP(FLIP_TRADE_ID)values(v_id);
		END LOOP;
    OPEN temp_cur FOR
      SELECT ft.FLIP_TRADE_ID,
      ft.ASSET_ID,
      ft.SHARE_QTY,
      ft.FILLED_QTY,
      ft.settle_date,
      ft.MIN_QTY,
      ft.inc_qty,
      ft.TRANSACTION_CD,
      ft.status,
      ft.export_status,
      ft.SSGM_LOAN_QTY,
      ft.SSGM_LOAN_RETURN_QTY,
      gtc.PREBORROW_ELIGIBLE_FLAG
      FROM GEC_INFLIGHT_FT_TEMP ftt
      JOIN GEC_FLIP_TRADE ft
      ON ftt.FLIP_TRADE_ID = ft.FLIP_TRADE_ID
      JOIN GEC_TRADE_COUNTRY gtc on ft.TRADE_COUNTRY_CD = gtc.TRADE_COUNTRY_CD
      order by ft.FLIP_TRADE_ID
      FOR UPDATE OF ft.FLIP_TRADE_ID;
      LOOP
        FETCH temp_cur INTO v_item;
        EXIT WHEN temp_cur%NOTFOUND;
        --manual intervention
        IF v_item.status = 'M' or v_item.status = 'C' THEN
          v_error_code := 'VLD0201';
        END IF;
        --export status
        IF v_item.export_status = 'I' THEN
          v_error_code := 'VLD0201';
        END IF;
        --settle date
        IF v_item.settle_date < p_current_date THEN
          v_error_code := 'VLD0201';
        END IF;
        --preborrow
        ---IF v_item.PREBORROW_ELIGIBLE_FLAG='Y' THEN
        ---  v_error_code := 'VLD0201';
        ---END IF;
        --qty validation
        IF v_item.share_qty-v_item.filled_qty-v_item.SSGM_LOAN_RETURN_QTY <= 0 THEN
          v_error_code := 'VLD0201';
        END IF;
        --min qty/inc qty/unfilled qty
        v_unfilled_qty := v_item.share_qty-v_item.filled_qty+v_item.SSGM_LOAN_QTY-v_item.SSGM_LOAN_RETURN_QTY;
        IF v_unfilled_qty <0 THEN
          v_unfilled_qty := 0;
        END IF;
        IF mod(v_unfilled_qty,v_item.inc_qty)!=0 or mod(v_item.min_qty,v_item.inc_qty)!=0 THEN
          v_error_code := 'VLD0201';
        END IF;
        --if unfilled Qty = Min Qty, Inc Qty = Min Qty. 
        IF v_unfilled_qty = v_item.min_qty AND v_item.min_qty != v_item.inc_qty THEN
          v_error_code := 'VLD0201';
        END IF;
        --if unfilled Qty greater than Min Qty, Inc Qty should not greater than the difference between Brw Qty and Min Qty
        IF v_unfilled_qty != v_item.min_qty AND v_item.inc_qty > v_unfilled_qty-v_item.min_qty THEN
          v_error_code := 'VLD0201';
        END IF;

        UPDATE GEC_INFLIGHT_FT_TEMP 
        SET ASSET_ID = v_item.ASSET_ID,
        SHARE_QTY = v_item.SHARE_QTY,
        settle_date = v_item.settle_date,
        FILLED_QTY = v_item.FILLED_QTY,
       	ssgm_loan_qty = v_item.ssgm_loan_qty,
      	SSGM_LOAN_RETURN_QTY = v_item.SSGM_LOAN_RETURN_QTY,
        TRANSACTION_CD = v_item.TRANSACTION_CD
        where FLIP_TRADE_ID = v_item.FLIP_TRADE_ID;

      END LOOP;
      CLOSE temp_cur;
      IF v_error_code is not null THEN
        RETURN v_error_code;
      END IF;
    RETURN v_error_code;
	END GET_FLIP_TRADES_BY_IDS;
  
  	PROCEDURE GET_FT_TRADES(p_trade_countries 	IN VARCHAR2,p_settle_dates  IN VARCHAR2,p_recall_flag IN VARCHAR2)
	IS
    CURSOR v_cur_ft_trades IS
      SELECT flip_trade.FLIP_TRADE_ID, 
           flip_trade.ASSET_ID,  
           flip_trade.SHARE_QTY, 
           flip_trade.FILLED_QTY,
           flip_trade.ssgm_loan_qty,
      	   flip_trade.SSGM_LOAN_RETURN_QTY,
           flip_trade.min_qty,
           flip_trade.inc_qty,
           flip_trade.SETTLE_DATE,
           flip_trade.trade_country_cd,
           flip_trade.TRANSACTION_CD,
           flip_trade.RECALL_FLAG
      FROM GEC_FLIP_TRADE flip_trade
      JOIN GEC_TRADE_COUNTRY gtc 
			ON flip_trade.TRADE_COUNTRY_CD = gtc.TRADE_COUNTRY_CD
      WHERE  instr(nvl(p_trade_countries,flip_trade.TRADE_COUNTRY_CD), flip_trade.TRADE_COUNTRY_CD) > 0 
          AND instr(p_settle_dates, GEC_UTILS_PKG.NUMBER_TO_CHAR(flip_trade.SETTLE_DATE)) > 0
         -- AND gtc.PREBORROW_ELIGIBLE_FLAG != 'Y'
          AND flip_trade.status NOT IN('M','C') 
          AND flip_trade.EXPORT_STATUS != 'I'
          AND flip_trade.share_qty-flip_trade.filled_qty-flip_trade.SSGM_LOAN_RETURN_QTY > 0
      ORDER BY flip_trade.FLIP_TRADE_ID ASC
      FOR UPDATE OF flip_trade.FLIP_TRADE_ID;
    v_unfilled_qty NUMBER;
    v_valid VARCHAR2(1):='Y';
	BEGIN		
  
		--get shorts for FT Trade
    FOR v_item IN v_cur_ft_trades
    LOOP
    	v_valid := 'Y';
        --min qty/inc qty/unfilled qty
        v_unfilled_qty := v_item.share_qty-v_item.filled_qty+v_item.SSGM_LOAN_QTY-v_item.SSGM_LOAN_RETURN_QTY;
        IF v_unfilled_qty <0 THEN
          v_unfilled_qty := 0;
        END IF;
        IF mod(v_unfilled_qty,v_item.inc_qty)!=0 OR mod(v_item.min_qty,v_item.inc_qty)!=0 THEN
          v_valid:='N';
        END IF;
        --if unfilled Qty = Min Qty, Inc Qty = Min Qty. 
        IF v_unfilled_qty = v_item.min_qty AND v_item.min_qty != v_item.inc_qty THEN
          v_valid:='N';
        END IF;
        --if unfilled Qty greater than Min Qty, Inc Qty should not greater than the difference between Brw Qty and Min Qty
        IF v_unfilled_qty != v_item.min_qty AND v_item.inc_qty > v_unfilled_qty-v_item.min_qty THEN
          v_valid:='N';
        END IF;
        
        IF p_recall_flag='Y'AND v_item.RECALL_FLAG != 'Y' THEN
        	v_valid:='N';
        END IF;
        
        IF v_valid = 'Y' THEN
          INSERT INTO GEC_INFLIGHT_FT_TEMP(FLIP_TRADE_ID,ASSET_ID,SHARE_QTY,ssgm_loan_qty,SSGM_LOAN_RETURN_QTY,settle_date,trade_country_cd,FILLED_QTY,TRANSACTION_CD) 
          VALUES(v_item.FLIP_TRADE_ID,v_item.ASSET_ID,v_item.SHARE_QTY,v_item.ssgm_loan_qty,v_item.SSGM_LOAN_RETURN_QTY,v_item.settle_date,v_item.trade_country_cd,v_item.FILLED_QTY,v_item.TRANSACTION_CD);
        END IF;
    END LOOP;
    
	END GET_FT_TRADES; 
  
    PROCEDURE REMOVE_EXCEPTION_TRADES(p_auto_release_rule_id  IN NUMBER)
  IS 
    v_trade_countries VARCHAR2(500) := '';
    v_settle_dates VARCHAR2(200) := '';
    CURSOR v_cur_exceptions IS 
    select
    TRADE_COUNTRY_CD,
    TRADE_SETTLE_PERIOD 
    from GEC_AUTORELEASE_EXCEPTION 
    where AUTORELEASE_RULE_ID = p_auto_release_rule_id;
  BEGIN
    --delete the orders where in exception rule tables
    FOR v_item IN v_cur_exceptions
		LOOP
      v_trade_countries := GEC_BORROWREQUEST_PKG.GET_TRADE_COUNTRIES(v_item.TRADE_COUNTRY_CD);
      v_settle_dates := GEC_BORROWREQUEST_PKG.GET_SETTLE_DATES(v_item.TRADE_SETTLE_PERIOD);
      DELETE FROM GEC_INFLIGHT_FT_TEMP 
      where instr(nvl(v_trade_countries,TRADE_COUNTRY_CD),TRADE_COUNTRY_CD)>0
      AND instr(nvl(v_settle_dates,SETTLE_DATE), SETTLE_DATE)>0;
    END LOOP;
  END REMOVE_EXCEPTION_TRADES;
  
  	PROCEDURE FILL_DEMANDS_WITH_FLIP_TRADES(p_borrow_request_id 		IN NUMBER,
                                     p_type			IN VARCHAR2)
	IS
		v_borrow_order_id GEC_BORROW_ORDER.BORROW_ORDER_ID%TYPE;
		v_unfilled_qty NUMBER :=0;
		v_sys_date_str VARCHAR2(8);
		v_sys_date DATE;
    v_request_count NUMBER := 0;
		CURSOR v_flip_trades IS
			SELECT flip_trade_id, 
      asset_id, 
      share_qty,
      settle_date,
      filled_qty, 
      ssgm_loan_qty,
      SSGM_LOAN_RETURN_QTY,
      transaction_cd
			FROM GEC_INFLIGHT_FT_TEMP;
	BEGIN
		
		SELECT sysdate into v_sys_date from dual;
		v_sys_date_str := TO_CHAR(v_sys_date, 'YYMMDD');
	
		FOR v_cur_ft IN v_flip_trades
		LOOP
			v_unfilled_qty := v_cur_ft.share_qty - v_cur_ft.filled_qty + v_cur_ft.ssgm_loan_qty - v_cur_ft.ssgm_loan_return_qty;
				
      --Create New Borrow Order
      SELECT GEC_BORROW_ORDER_ID_SEQ.NEXTVAL INTO v_borrow_order_id FROM DUAL;
      INSERT INTO GEC_BORROW_ORDER(BORROW_ORDER_ID,BORROW_REQUEST_ID,LOG_NUMBER,ASSET_ID,SETTLE_DATE,
      SHARE_QTY,STATUS,STATUS_MSG)
      VALUES(v_borrow_order_id,p_borrow_request_id, GEC_BORROWREQUEST_PKG.GET_LOG_NUMBER(v_cur_ft.transaction_cd, v_sys_date_str),
        v_cur_ft.asset_id,v_cur_ft.settle_date,v_unfilled_qty, decode(p_type,GEC_CONSTANTS_PKG.C_FILE_REQUEST,null,GEC_CONSTANTS_PKG.C_BORROW_ORDER_INFLIGHT),
                decode(p_type,GEC_CONSTANTS_PKG.C_FILE_REQUEST,null,GEC_CONSTANTS_PKG.C_BORROW_ORDER_INFLIGHT_MSG));
				
			--InFlight flip trade
			UPDATE GEC_FLIP_TRADE SET EXPORT_STATUS='I' WHERE FLIP_TRADE_ID = v_cur_ft.flip_trade_id;
			--Create trade detail
			INSERT INTO GEC_FLIP_TRADE_DETAIL(BORROW_ORDER_ID, FLIP_TRADE_ID, FULL_FILLED_QTY, REQUEST_QTY)
							VALUES(v_borrow_order_id, v_cur_ft.flip_trade_id, v_cur_ft.filled_qty, v_unfilled_qty);
		END LOOP;
    
    --Update request count for borrow request
    select count(*) into v_request_count from GEC_BORROW_ORDER where BORROW_REQUEST_ID = p_borrow_request_id;
		update GEC_BORROW_REQUEST set request_count = v_request_count where borrow_request_id = p_borrow_request_id;
    
	END FILL_DEMANDS_WITH_FLIP_TRADES;  
	
	PROCEDURE NORESPONSE_FLIP_TRADE(p_borrowRequestId IN NUMBER,p_flip_trades OUT SYS_REFCURSOR,p_borrowRequest OUT SYS_REFCURSOR)
	IS
  	CURSOR v_flip_trades IS
		SELECT gft.flip_trade_id
    FROM gec_flip_trade gft
		JOIN gec_flip_trade_detail gftd
     	on gft.flip_trade_id = gftd.flip_trade_id
      	JOIN GEC_BORROW_ORDER gbo
      	on gbo.borrow_order_id = gftd.borrow_order_id
	  	WHERE gbo.borrow_request_id = p_borrowRequestId
	  	FOR UPDATE
    order by gft.flip_trade_id; --for dead lock
	BEGIN
        FOR v_item IN v_flip_trades
				LOOP
						UPDATE gec_flip_trade SET EXPORT_STATUS = 'R' WHERE flip_trade_id = v_item.flip_trade_id;
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
        ON f.REQUEST_ID = rf.REQUEST_ID AND rf.FILE_TYPE = 'RES'
        LEFT JOIN GEC_SCHEDULE gs
	    ON br.EQUILEND_SCHEDULE_ID = gs.EQUILEND_SCHEDULE_ID
	    LEFT JOIN (select gc.equilend_chain_ID, REPLACE(GEC_NO_DUP_STRACAT_FNC(Broker_Cd),';',',') as CHAIN_LENDER from gec_chain_schedule gcs
	    LEFT JOIN gec_chain gc
	    ON gc.CHAIN_ID = gcs.CHAIN_ID
	    group by gc.equilend_chain_ID) gcs
	    ON br.EQUILEND_CHAIN_ID = gcs.equilend_chain_ID
        WHERE br.BORROW_REQUEST_ID = p_borrowRequestId;
        
        OPEN p_flip_trades FOR
        SELECT 
				gft.flip_trade_id,
				gft.ASSET_ID,
				ga.cusip,
				ga.isin,
				ga.sedol,
				ga.ticker,
				ga.quik,
				ga.description,
				gft.trade_country_cd,
				gft.transaction_cd,
				gft.trade_date,
				gft.settle_date,
				gft.recall_due_date,
				gft.share_qty,
				gft.filled_qty,
				gft.min_qty,
				gft.inc_qty,
				gft.status,
				gft.export_status,
				gft.RETURN_BRANCH_CD,
				gft.borrow_return_cpty,
				gft.RETURN_BARGAIN_REF,
				gft.ssgm_loan_qty,
				gft.ssgm_loan_return_qty,
				gft.nsb_loan_rate,
				gft.recall_comment_txt,
				gft.recall_flag,
				gtc.PREBORROW_ELIGIBLE_FLAG,
				gtc.PREPAY_DATE_VALUE,
				gft.share_qty-gft.filled_qty-gft.ssgm_loan_return_qty as export_enable_qty
			FROM gec_flip_trade gft
			JOIN gec_asset ga
			on gft.asset_id = ga.asset_id
			JOIN GEC_TRADE_COUNTRY gtc 
			ON gft.TRADE_COUNTRY_CD = gtc.TRADE_COUNTRY_CD
			WHERE gft.flip_trade_id in(SELECT gft.flip_trade_id
                        from GEC_BORROW_ORDER gbo
                        JOIN gec_flip_trade_detail gftd
                        ON gbo.borrow_order_id = gftd.borrow_order_id
                        JOIN gec_flip_trade gft
                        ON gft.flip_trade_id = gftd.flip_trade_id
                        WHERE gbo.borrow_request_id = p_borrowRequestId);
        
	END NORESPONSE_FLIP_TRADE;
	
  --p_asset_id flip trade's asset id
	--p_transaction_type B or L
	--p_trade_date borrow's trade date
	--p_settle_Date borrow's settle date
	--p_return_cpty return cpty
	--p_trade_country_cd asset's trade country
	PROCEDURE GENERATE_RETURN(
							  p_fund_cd IN VARCHAR2,
							  p_asset_id IN NUMBER,
							  p_flip_trade_id IN NUMBER,
							  p_flip_borrow_id IN NUMBER,
							  p_transaction_type IN VARCHAR2,
							  p_trade_date IN NUMBER,
							  p_settle_Date IN NUMBER,
							  p_return_cpty IN VARCHAR2,
							  p_bargain_ref IN VARCHAR2,
							  p_qty IN NUMBER,
							  p_status OUT VARCHAR2,
							  p_error_msg OUT VARCHAR2
							  )
	IS
		v_trade_country_cd GEC_G1_RETURN.TRADE_COUNTRY_CD%type;
		v_return_id GEC_G1_RETURN.G1_RETURN_ID%type;
		v_flip_borrow_broker_cd GEC_BORROW.BROKER_CD%type;
		v_flip_borrow_broker_cd_name GEC_BROKER.BROKER_NAME%type;
		v_return_branch GEC_FLIP_TRADE.RETURN_BRANCH_CD%type;
		v_borrow_coll_type GEC_BORROW.COLLATERAL_TYPE%type;
		v_borrow_coll_code GEC_BORROW.COLLATERAL_CURRENCY_CD%type;
		v_borrow_request_type GEC_BROKER.BORROW_REQUEST_TYPE%type;
		v_flip_broker_cd_name GEC_BROKER.BROKER_NAME%type;
	BEGIN
		SELECT TRADE_COUNTRY_CD
		INTO v_trade_country_cd
		FROM GEC_ASSET 
		WHERE ASSET_ID=p_asset_id;
		SELECT 
	    	GEC_G1_RETURN_ID_SEQ.nextval
	    INTO
	    	v_return_id
	    FROM DUAL;
	    SELECT 
	    	GB.BROKER_CD,
	    	GBR.BROKER_NAME,
	    	GFT.RETURN_BRANCH_CD,
	    	GB.COLLATERAL_TYPE,
	    	GB.COLLATERAL_CURRENCY_CD,
	    	GBR.BORROW_REQUEST_TYPE,
	    	GBR2.BROKER_NAME
			INTO
			v_flip_borrow_broker_cd,
			v_flip_borrow_broker_cd_name,
			v_return_branch,
			v_borrow_coll_type,
			v_borrow_coll_code,
			v_borrow_request_type,
			v_flip_broker_cd_name
			FROM GEC_FLIP_TRADE GFT
			LEFT JOIN GEC_BROKER GBR2
     		ON GBR2.BROKER_CD=GFT.BORROW_RETURN_CPTY
     		,GEC_FLIP_BORROW GFB,GEC_BORROW GB
			LEFT JOIN GEC_BROKER GBR
      		ON GBR.BROKER_CD = GB.BROKER_CD
			WHERE GFT.FLIP_TRADE_ID = p_flip_trade_id
			AND GFT.FLIP_TRADE_ID=GFB.FLIP_TRADE_ID
			AND GFB.BORROW_ID=GB.BORROW_ID
			AND GB.BORROW_ID = p_flip_borrow_id;
			
			IF v_borrow_coll_type='CASH' THEN
				v_borrow_coll_type:='C';
			ELSIF v_borrow_coll_type='POOL' THEN
				v_borrow_coll_type:='p';
			ELSE
				v_borrow_coll_type:='N';
			END IF;
				
		IF v_borrow_request_type='SB' THEN
			BEGIN
					SELECT 
					NVL(GGC.COLL_TYPE,GGB.COLL_TYPE),
					NVL(GGC.COLLATERAL_CURRENCY_CD,GGB.COLLATERAL_CURRENCY_CD)
		 			INTO 
		 			v_borrow_coll_type,
		 			v_borrow_coll_code
					FROM GEC_FUND GF,GEC_G1_BOOKING GGB
					LEFT JOIN GEC_G1_COLLATERAL GGC
					ON GGC.G1_BOOKING_ID=GGB.G1_BOOKING_ID AND GGC.TRADE_COUNTRY_CD=v_trade_country_cd
					WHERE GF.DML_SB_BROKER=v_flip_borrow_broker_cd
					AND GGB.FUND_CD=GF.FUND_CD
					AND GGB.TRANSACTION_CD=GEC_CONSTANTS_PKG.C_G1L
					AND GGB.POS_TYPE='NSB';
			EXCEPTION 
			WHEN NO_DATA_FOUND THEN
				p_status:='CE';
				p_error_msg:='Can not get fund NSB G1 Loan CPTY base on SB Broker CODE '||p_return_cpty||', please check fund configuration.';
			WHEN TOO_MANY_ROWS THEN
				p_status:='CE';
				p_error_msg:='Get duplicate fund NSB G1 Loan CPTY base on SB Broker CODE '||p_return_cpty||', please check fund configuration.';
			END;
		END IF;
			  
		INSERT INTO GEC_G1_RETURN(G1_RETURN_ID,
							 ASSET_ID,
							 IM_ORDER_ID,
							 FLIP_TRADE_ID,
							 TRANSACTION_TYPE,
							 TRANSACTION_CD,
							 TRADE_DATE,
							 SETTLE_DATE,
							 COUNTERPARTY_CD,
							 BARGAIN_REF,
							 TRADE_COUNTRY_CD,
							 QTY,
							 REC_TYPE,
							 FUND_CD,
							 STATUS,
							 NEW_BORROW_CPTY_CD,
							 NEW_BORROW_CPTY_NAME,
							 BRANCH_CD,
							 NEW_BORROW_COLL_TYPE,
							 NEW_BORROW_COLL_CODE,
							 COUNTERPARTY_NAME,
							 DIVIDEND_TRADE_FLAG,
							 SOURCE_CD)
		VALUES(v_return_id,
			   p_asset_id,
			   null,
			   p_flip_trade_id,
			   p_transaction_type,
			   'FT',
			   p_trade_date,
			   p_settle_Date,
			   p_return_cpty,
			   p_bargain_ref,
			   v_trade_country_cd,
			   p_qty,
			   '1',
			   NULL,
			   'P',
			   v_flip_borrow_broker_cd,
			   v_flip_borrow_broker_cd_name,
			   v_return_branch,
			   v_borrow_coll_type,
			   v_borrow_coll_code,
			   v_flip_broker_cd_name,
			   null,
			   'FT'
			   );
		IF p_fund_cd='0189' THEN
			UPDATE GEC_FLIP_BORROW SET SSGM_LOAN_RETURN_ID = v_return_id WHERE BORROW_ID=p_flip_borrow_id;
		ELSE
			IF p_transaction_type='L' THEN
				UPDATE GEC_FLIP_BORROW SET G1_LOAN_RETURN_ID = v_return_id WHERE BORROW_ID=p_flip_borrow_id;
			ELSE
				UPDATE GEC_FLIP_BORROW SET G1_BORROW_RETURN_ID= v_return_id WHERE BORROW_ID=p_flip_borrow_id;
			END IF;
		END IF;
	END GENERATE_RETURN;
	-- FUND exist fund's counterparty exist
	-- COLL TYPE COLL CODE RATE NOT exist in ggc GGR get the ggb's coll type coll code rate
	-- GB_COLLATERAL_PERCENTAGE  prepay rate not exist in GEC_COUNTERPARTY
	-- field mean in GGR
	-- GEC_LOAN TYPE field and BORROW_REQUEST_TYPE field
	-- p_asset_id flip trade's asset id
	-- p_fund_cd flip trade's fund
	-- 
	PROCEDURE GENERATE_LOAN(p_asset_id IN NUMBER,
							p_fund_cd IN VARCHAR2,
							p_trade_date IN NUMBER,
							p_settle_Date IN NUMBER,
							p_loan_qty IN NUMBER,
			   				p_rate IN NUMBER,
			   				p_price IN NUMBER,
			   				p_broker_cd IN VARCHAR2,
			   				p_user_id IN VARCHAR2,
			   				p_prepay_date IN NUMBER,
			   				p_pos_type IN VARCHAR2,
			   				p_trade_country_cd IN VARCHAR2,
			   				p_flip_trade_id IN VARCHAR2,
			   				p_flip_borrow_id IN NUMBER)
	IS
		v_counter_party_cd GEC_G1_BOOKING.COUNTERPARTY_CD%type;
		v_coll_type GEC_G1_COLLATERAL.COLL_TYPE%type;
		v_coll_cd GEC_G1_COLLATERAL.COLLATERAL_CURRENCY_CD%type;
		v_coll_per GEC_COUNTERPARTY.GB_COLLATERAL_PERCENTAGE%type;
		v_reclaim_rate GEC_G1_RECLAIM_RATE.RECLAIM_RATE%type;
		v_overseas_tax GEC_G1_RECLAIM_RATE.OVERSEAS_TAX_PERCENTAGE%type;
		v_dom_tax GEC_G1_RECLAIM_RATE.DOMESTIC_TAX_PERCENTAGE%type;
		v_prepay_rate GEC_COUNTERPARTY.PREPAY_RATE%type;
		v_link_reference GEC_LOAN.LINK_REFERENCE%TYPE;
		v_loan_id GEC_LOAN.LOAN_ID%type;
	BEGIN
		v_link_reference := (GEC_ALLOCATION_PKG.GENERATE_BORROW_LINK_REF());
		SELECT 
	    	GEC_LOAN_ID_SEQ.nextval
	    INTO
	    	v_loan_id
	    FROM DUAL;
		SELECT 
		GGB.COUNTERPARTY_CD,
		NVL(GGC.COLL_TYPE,GGB.COLL_TYPE),
		NVL(GGC.COLLATERAL_CURRENCY_CD,GGB.COLLATERAL_CURRENCY_CD),
		NVL(GGRR.RECLAIM_RATE,GGB.RECLAIM_RATE),
		NVL(GGRR.OVERSEAS_TAX_PERCENTAGE,GGB.OVERSEAS_TAX_PERCENTAGE),
		NVL(GGRR.DOMESTIC_TAX_PERCENTAGE,GGB.DOMESTIC_TAX_PERCENTAGE ),
		GC.GB_COLLATERAL_PERCENTAGE,
		NVL(GBIR.RATE,GC.PREPAY_RATE)
		INTO
		v_counter_party_cd,
		v_coll_type,
		v_coll_cd,
		v_reclaim_rate,
		v_overseas_tax,
		v_dom_tax,
		v_coll_per,
		v_prepay_rate
		FROM GEC_FUND GF,GEC_G1_BOOKING GGB
		LEFT JOIN GEC_G1_COLLATERAL GGC
			 ON GGC.G1_BOOKING_ID=GGB.G1_BOOKING_ID AND GGC.TRADE_COUNTRY_CD=p_trade_country_cd
		LEFT JOIN GEC_COUNTERPARTY GC
			 ON GC.COUNTERPARTY_CD=GGB.COUNTERPARTY_CD AND GC.TRANSACTION_CD=GEC_CONSTANTS_PKG.C_G1L
		LEFT JOIN GEC_G1_RECLAIM_RATE GGRR
			 ON GGRR.G1_BOOKING_ID=GGB.G1_BOOKING_ID AND GGRR.TRADE_COUNTRY_CD=p_trade_country_cd
		LEFT JOIN GEC_BENCHMARK_INDEX_RATE GBIR
			 ON GBIR.BENCHMARK_INDEX_CD = GC.BENCHMARK_INDEX_CD
		WHERE GF.FUND_CD=p_fund_cd
			  AND GGB.FUND_CD=GF.FUND_CD
			  AND GGB.TRANSACTION_CD=GEC_CONSTANTS_PKG.C_G1L
			  AND GGB.POS_TYPE=p_pos_type;
		IF p_pos_type IS NOT NULL AND p_pos_type <>'SB' AND p_trade_country_cd IS NOT NULL AND p_trade_country_cd<>'US' AND p_trade_country_cd<>'CA' THEN
			IF (v_coll_type <>'P' AND v_coll_type <>'C') THEN
				v_prepay_rate:=0;
			END IF;
		ELSE
			IF (v_coll_type <>'P' AND v_coll_type <>'C') OR p_prepay_date>=p_settle_Date THEN
				v_prepay_rate:=0;
			END IF;
		END IF;
		
		
		INSERT INTO GEC_LOAN(LOAN_ID,
							 ASSET_ID,
							 FUND_CD,
							 TRADE_DATE,
							 SETTLE_DATE,
							 COLLATERAL_TYPE,
							 COLLATERAL_CURRENCY_CD,
							 LOAN_QTY,
							 RATE,
							 PRICE,
							 BORROW_REQUEST_TYPE,
							 LINK_REFERENCE,
							 CREATED_AT,
							 CREATED_BY,
							 UPDATED_AT,
							 UPDATED_BY,
							 TYPE,
							 STATUS,
							 PREPAY_DATE,
							 PREPAY_RATE,
							 RECLAIM_RATE,
							 OVERSEAS_TAX_PERCENTAGE,
							 DOMESTIC_TAX_PERCENTAGE,
							 MINIMUM_FEE,
							 MINIMUM_FEE_CD,
							 COUNTERPARTY_CD,
							 COLLATERAL_PERCENTAGE) 
		VALUES(v_loan_id,
			   p_asset_id,
			   p_fund_cd,
			   p_trade_date,
			   p_settle_Date,
			   v_coll_type,
			   v_coll_cd,
			   p_loan_qty,
			   p_rate,
			   p_price,
			   p_pos_type,
			   v_link_reference,
			   sysdate,
			   p_user_id,
			   sysdate,
			   p_user_id,
			   'COMMON',
			   'P',
			   p_prepay_date,
			   v_prepay_rate,
			   v_reclaim_rate,
			   v_overseas_tax,
			   v_dom_tax,
			   null,
			   v_coll_cd,
			   v_counter_party_cd,
			   v_coll_per);
		INSERT INTO GEC_FLIP_LOAN(FLIP_TRADE_ID,
								  LOAN_ID)
		VALUES(p_flip_trade_id,
				v_loan_id);
		IF p_fund_cd='0189' THEN
			UPDATE GEC_FLIP_BORROW SET SSGM_LOAN_ID = v_loan_id WHERE BORROW_ID=p_flip_borrow_id;
		ELSE
			UPDATE GEC_FLIP_BORROW SET LOAN_ID = v_loan_id WHERE BORROW_ID=p_flip_borrow_id;
		END IF;
	END GENERATE_LOAN;
	--p_cpty_type BB BookBorrow BL BookLoan RB ReturnBorrow RL ReturnLoan
	--p_status S success E error
	PROCEDURE GET_CPTY(p_return_cpty IN VARCHAR2,
					  p_new_borrow_cpty IN VARCHAR2,
					  p_cpty_type IN VARCHAR2,
					  p_cpty OUT VARCHAR2,
					  p_fund OUT VARCHAR2,
					  p_status OUT VARCHAR2,
					  p_error_msg OUT VARCHAR2)
	IS 
		v_counter_party_cd GEC_G1_BOOKING.COUNTERPARTY_CD%type;
		v_fund GEC_FUND.FUND_CD%type;
		v_return_request_type GEC_BORROW_REQUEST.BORROW_REQUEST_TYPE%type;
		v_new_request_type GEC_BORROW_REQUEST.BORROW_REQUEST_TYPE%type;
	BEGIN
		p_status:='S';
		p_error_msg:='';
		IF p_return_cpty IS NULL THEN
	      v_return_request_type:='';
	    ELSE
	      SELECT BORROW_REQUEST_TYPE INTO v_return_request_type
	      FROM GEC_BROKER WHERE BROKER_CD=p_return_cpty;
	    END IF;
		SELECT BORROW_REQUEST_TYPE INTO  v_new_request_type
		FROM GEC_BROKER WHERE BROKER_CD=p_new_borrow_cpty;
		IF v_return_request_type=GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB THEN
			IF p_cpty_type='BB' THEN
				p_cpty:= p_new_borrow_cpty;
				p_fund:= '';
			ELSIF p_cpty_type='BL' THEN
				BEGIN
					SELECT GGB.COUNTERPARTY_CD,GF.FUND_CD INTO v_counter_party_cd,v_fund
					FROM GEC_FUND GF,GEC_G1_BOOKING GGB
					WHERE GF.DML_SB_BROKER=p_return_cpty
					AND GGB.FUND_CD=GF.FUND_CD
					AND GGB.TRANSACTION_CD=GEC_CONSTANTS_PKG.C_G1L
					AND GGB.POS_TYPE='NSB';
					p_cpty:= v_counter_party_cd;
					p_fund:= v_fund;
				EXCEPTION 
				WHEN NO_DATA_FOUND THEN
					p_status:='CE';
					p_error_msg:='Can not get fund NSB G1 Loan CPTY base on SB Broker CODE '||p_return_cpty||', please check fund configuration.';
				WHEN TOO_MANY_ROWS THEN
					p_status:='CE';
					p_error_msg:='Get duplicate fund NSB G1 Loan CPTY base on SB Broker CODE '||p_return_cpty||', please check fund configuration.';
				END;
			ELSIF p_cpty_type='RL' THEN
				BEGIN
					SELECT GGB.COUNTERPARTY_CD,GF.FUND_CD INTO v_counter_party_cd,v_fund
					FROM GEC_FUND GF,GEC_G1_BOOKING GGB 
					WHERE GF.DML_SB_BROKER=p_return_cpty
					AND GGB.FUND_CD=GF.FUND_CD
					AND GGB.TRANSACTION_CD=GEC_CONSTANTS_PKG.C_G1L
					AND GGB.POS_TYPE='SB';
					p_cpty:= v_counter_party_cd;
					p_fund:= v_fund;
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
					p_status:='CE';
					p_error_msg:='Can not get fund SB G1 Loan CPTY base on SB Broker CODE '||p_return_cpty||', please check fund configuration.';
				WHEN TOO_MANY_ROWS THEN
					p_status:='CE';
					p_error_msg:='Get duplicate fund SB G1 Loan CPTY base on SB Broker CODE '||p_return_cpty||', please check fund configuration.';
				END;
			ELSIF p_cpty_type='RB' THEN
				BEGIN
					SELECT GGB.COUNTERPARTY_CD,GF.FUND_CD  INTO v_counter_party_cd,v_fund
					FROM GEC_FUND GF,GEC_G1_BOOKING GGB
					WHERE GF.DML_SB_BROKER=p_return_cpty
					AND GGB.FUND_CD=GF.FUND_CD
					AND GGB.TRANSACTION_CD=GEC_CONSTANTS_PKG.C_G1B
					AND GGB.POS_TYPE='SB';
					p_cpty:= v_counter_party_cd;
					p_fund:= v_fund;
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
					p_status:='CE';
					p_error_msg:='Can not get fund SB G1 Borrow CPTY base on SB Broker CODE '||p_return_cpty||', please check fund configuration.';
				WHEN TOO_MANY_ROWS THEN
					p_status:='CE';
					p_error_msg:='Get duplicate fund SB G1 Borrow CPTY base on SB Broker CODE '||p_return_cpty||', please check fund configuration.';
				END;
			ELSE
				p_cpty:= '';
				p_fund:= '';
			END IF;
		ELSE
			IF v_new_request_type=GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB THEN
				IF p_cpty_type='BB' THEN
					BEGIN
						SELECT GGB.COUNTERPARTY_CD,GF.FUND_CD INTO v_counter_party_cd,v_fund
						FROM GEC_FUND GF,GEC_G1_BOOKING GGB
						WHERE GF.DML_SB_BROKER=p_new_borrow_cpty
						AND GGB.FUND_CD=GF.FUND_CD
						AND GGB.TRANSACTION_CD=GEC_CONSTANTS_PKG.C_G1B
						AND GGB.POS_TYPE='SB';
						p_cpty:= v_counter_party_cd;
						p_fund:= v_fund;
					EXCEPTION
					WHEN NO_DATA_FOUND THEN
						p_status:='CE';
						p_error_msg:='Can not get fund SB G1 Borrow CPTY base on SB Broker CODE '||p_new_borrow_cpty||', please check fund configuration.';
					WHEN TOO_MANY_ROWS THEN
						p_status:='CE';
						p_error_msg:='Get duplicate fund SB G1 Borrow CPTY base on SB Broker CODE '||p_new_borrow_cpty||', please check fund configuration.';
					END;
				ELSIF p_cpty_type='BL' THEN
					BEGIN
						SELECT GGB.COUNTERPARTY_CD,GF.FUND_CD INTO v_counter_party_cd,v_fund
						FROM GEC_FUND GF,GEC_G1_BOOKING GGB
						WHERE GF.DML_SB_BROKER=p_new_borrow_cpty
						AND GGB.FUND_CD=GF.FUND_CD
						AND GGB.TRANSACTION_CD=GEC_CONSTANTS_PKG.C_G1L
						AND GGB.POS_TYPE='SB';
						p_cpty:= v_counter_party_cd;
						p_fund:= v_fund;
					EXCEPTION
					WHEN NO_DATA_FOUND THEN
						p_status:='CE';
						p_error_msg:='Can not get fund SB G1 Loan CPTY base on SB Broker CODE '||p_new_borrow_cpty||', please check fund configuration.';
					WHEN TOO_MANY_ROWS THEN
						p_status:='CE';
						p_error_msg:='Get duplicate fund SB G1 Loan CPTY base on SB Broker CODE '||p_new_borrow_cpty||', please check fund configuration.';
					END;
					
				ELSIF p_cpty_type='RL' THEN
					BEGIN
						SELECT GGB.COUNTERPARTY_CD,GF.FUND_CD INTO v_counter_party_cd,v_fund
						FROM GEC_FUND GF,GEC_G1_BOOKING GGB
						WHERE GF.DML_SB_BROKER=p_new_borrow_cpty
						AND GGB.FUND_CD=GF.FUND_CD
						AND GGB.TRANSACTION_CD=GEC_CONSTANTS_PKG.C_G1L
						AND GGB.POS_TYPE='NSB';
						p_cpty:= v_counter_party_cd;
						p_fund:= v_fund;
					EXCEPTION
					WHEN NO_DATA_FOUND THEN
						p_status:='CE';
						p_error_msg:='Can not get fund NSB G1 Loan CPTY base on SB Broker CODE '||p_new_borrow_cpty||', please check fund configuration.';
					WHEN TOO_MANY_ROWS THEN
						p_status:='CE';
						p_error_msg:='Get duplicate fund NSB G1 Loan CPTY base on SB Broker CODE '||p_new_borrow_cpty||', please check fund configuration.';
					END;
				ELSIF p_cpty_type='RB' THEN
					p_cpty:= p_return_cpty;
					p_fund:='';
				ELSE
					p_cpty:=  '';
					p_fund:='';
				END IF;
			ELSE
				IF p_cpty_type='BB' THEN
					p_cpty:= p_new_borrow_cpty;
					p_fund:='';
				ELSIF p_cpty_type='RB' THEN
					p_cpty:= p_return_cpty;
					p_fund:='';
				ELSE
					p_cpty:= '';
					p_fund:='';
				END IF;
			END IF;
		END IF;
	END GET_CPTY;
	PROCEDURE GENERATE_BOOK_DATA(p_flip_borrow_id IN NUMBER,
								p_flip_trade_id IN NUMBER,
								p_user_id IN VARCHAR2,
								p_status OUT VARCHAR2,
								p_error_msg OUT VARCHAR2,
								p_error_hint OUT VARCHAR2)
	IS
	-- gecFlipTrade
		v_asset_id NUMBER;
		v_flip_counter_party_cd  GEC_FLIP_TRADE.BORROW_RETURN_CPTY%type;
		v_flip_nsb_loan_rate NUMBER;
		v_trade_country_cd GEC_FLIP_TRADE.TRADE_COUNTRY_CD%type;
		v_ssgm_loan_qty NUMBER;
		v_ssgm_loan_return_qty NUMBER;
		v_return_request_type GEC_BORROW_REQUEST.BORROW_REQUEST_TYPE%type;
		v_bargain_ref GEC_G1_RETURN.BARGAIN_REF%type;
	-- gecFlipBorrow
		v_b_trade_date GEC_BORROW.TRADE_DATE%type;
		v_b_settle_Date GEC_BORROW.SETTLE_DATE%type;
		v_b_price GEC_BORROW.PRICE%type;
		v_b_prepay_date GEC_BORROW.PREPAY_DATE%type;
		v_new_borrow_broker_cd GEC_BORROW.BROKER_CD% TYPE;
		v_new_borrow_qty NUMBER;
		v_new_request_type GEC_BORROW_REQUEST.BORROW_REQUEST_TYPE%type;
	-- 
		var_rate NUMBER;
		v_fund_cd GEC_FUND.FUND_CD% TYPE;
		v_0189_qty NUMBER:=0;
		v_qty NUMBER;
		v_unfilled_qty NUMBER;
		v_last_unfilled_qty NUMBER;
		
		v_0189_loan_count NUMBER;
		v_0189_loan_id NUMBER;
		v_0189_return_cpty GEC_G1_BOOKING.COUNTERPARTY_CD%type;
		v_book_counter_party GEC_FLIP_TRADE.BORROW_RETURN_CPTY%type;
    	V_0189_return_qty NUMBER:=0;
		
	BEGIN
			p_status:='S';
			p_error_msg:='';
			SELECT 
			GFT.ASSET_ID,
			GFT.BORROW_RETURN_CPTY,
			GFT.NSB_LOAN_RATE,
			GFT.TRADE_COUNTRY_CD,
			GFT.SSGM_LOAN_QTY,
			GFT.SSGM_LOAN_RETURN_QTY,
			GFT.RETURN_BARGAIN_REF,
			GBR2.BORROW_REQUEST_TYPE,
			GB.TRADE_DATE ,
			GB.SETTLE_DATE,
			GB.PRICE,
			GB.PREPAY_DATE,
			GB.BROKER_CD,
			GB.BORROW_QTY,
			GBR.BORROW_REQUEST_TYPE,
			GFT.SHARE_QTY-GFT.FILLED_QTY+GFT.SSGM_LOAN_QTY-GFT.SSGM_LOAN_RETURN_QTY,
			GFT.SHARE_QTY-GFT.FILLED_QTY+GFT.SSGM_LOAN_QTY-GFT.SSGM_LOAN_RETURN_QTY + GB.BORROW_QTY
			INTO
			v_asset_id,
			v_flip_counter_party_cd,
			v_flip_nsb_loan_rate,
			v_trade_country_cd,
			v_ssgm_loan_qty,
			v_ssgm_loan_return_qty,
			v_bargain_ref,
			v_return_request_type,
			v_b_trade_date,
			v_b_settle_Date,
			v_b_price,
			v_b_prepay_date,
			v_new_borrow_broker_cd,
			v_new_borrow_qty,
			v_new_request_type,
			v_unfilled_qty,
			v_last_unfilled_qty
			FROM GEC_FLIP_TRADE GFT
			LEFT JOIN GEC_BROKER GBR2
     		ON GBR2.BROKER_CD=GFT.BORROW_RETURN_CPTY
     		,GEC_FLIP_BORROW GFB,GEC_BORROW GB
			LEFT JOIN GEC_BROKER GBR
      		ON GBR.BROKER_CD = GB.BROKER_CD
			WHERE GFT.FLIP_TRADE_ID = p_flip_trade_id
			AND GFT.FLIP_TRADE_ID=GFB.FLIP_TRADE_ID
			AND GFB.BORROW_ID=GB.BORROW_ID
			AND GB.BORROW_ID = p_flip_borrow_id;
			
      		SELECT COUNT(*) INTO v_0189_loan_count
			FROM GEC_LOAN GL,GEC_FLIP_LOAN GFL,GEC_FLIP_TRADE GFT
			WHERE GL.LOAN_ID=GFL.LOAN_ID AND GFL.FLIP_TRADE_ID=GFT.FLIP_TRADE_ID AND GL.FUND_CD='0189' AND GFT.FLIP_TRADE_ID=p_flip_trade_id;
			
     
    --generate 0189 loan
		IF v_ssgm_loan_qty IS NOT NULL AND v_ssgm_loan_qty>0 AND v_last_unfilled_qty>0 AND v_ssgm_loan_qty>v_unfilled_qty THEN
			IF v_unfilled_qty<0 THEN
         		v_0189_qty:=v_ssgm_loan_qty;
				IF v_0189_loan_count =0 THEN
					BEGIN
					  SELECT GGB.COUNTERPARTY_CD
				      INTO v_0189_return_cpty
				      FROM GEC_FUND GF,GEC_G1_BOOKING GGB
				      WHERE GF.FUND_CD=GGB.FUND_CD
				      AND GF.FUND_CD='0189' 
				      AND GGB.TRANSACTION_CD='G1L'
				      AND POS_TYPE='NSB';
					EXCEPTION WHEN NO_DATA_FOUND THEN
						  p_status:='CE';
						  p_error_msg:='0189 fund G1L NSB Counterparty is not exist.';
						  RETURN;
					END;
					GENERATE_LOAN(v_asset_id,GEC_CONSTANTS_PKG.C_FUND_0189,v_b_trade_date,v_b_settle_Date,v_0189_qty,0,v_b_price,v_new_borrow_broker_cd,p_user_id,v_b_prepay_date,'NSB',v_trade_country_cd,p_flip_trade_id,p_flip_borrow_id);
				ELSE
					SELECT GL.LOAN_ID INTO v_0189_loan_id 
					FROM GEC_LOAN GL,GEC_FLIP_LOAN GFL,GEC_FLIP_TRADE GFT
					WHERE GL.LOAN_ID=GFL.LOAN_ID AND GFL.FLIP_TRADE_ID=GFT.FLIP_TRADE_ID AND GL.FUND_CD='0189' AND GFT.FLIP_TRADE_ID=p_flip_trade_id;
					UPDATE GEC_LOAN SET LOAN_QTY=v_ssgm_loan_qty WHERE GEC_LOAN.LOAN_ID=v_0189_loan_id;
				END IF;
			ELSE
         		v_0189_qty:=v_ssgm_loan_qty-v_unfilled_qty;
				IF v_0189_loan_count =0 THEN
					BEGIN
					  SELECT GGB.COUNTERPARTY_CD
				      INTO v_0189_return_cpty
				      FROM GEC_FUND GF,GEC_G1_BOOKING GGB
				      WHERE GF.FUND_CD=GGB.FUND_CD
				      AND GF.FUND_CD='0189' 
				      AND GGB.TRANSACTION_CD='G1L'
				      AND POS_TYPE='NSB';
					EXCEPTION WHEN NO_DATA_FOUND THEN
						  p_status:='CE';
						  p_error_msg:='0189 fund G1L NSB Counterparty is not exist.';
						  RETURN;
					END;
					GENERATE_LOAN(v_asset_id,GEC_CONSTANTS_PKG.C_FUND_0189,v_b_trade_date,v_b_settle_Date,v_0189_qty,0,v_b_price,v_new_borrow_broker_cd,p_user_id,v_b_prepay_date,'NSB',v_trade_country_cd,p_flip_trade_id,p_flip_borrow_id);
				ELSE
					SELECT GL.LOAN_ID INTO v_0189_loan_id 
					FROM GEC_LOAN GL,GEC_FLIP_LOAN GFL,GEC_FLIP_TRADE GFT
					WHERE GL.LOAN_ID=GFL.LOAN_ID AND GFL.FLIP_TRADE_ID=GFT.FLIP_TRADE_ID AND GL.FUND_CD='0189' AND GFT.FLIP_TRADE_ID=p_flip_trade_id;
					UPDATE GEC_LOAN SET LOAN_QTY=v_ssgm_loan_qty-v_unfilled_qty WHERE GEC_LOAN.LOAN_ID=v_0189_loan_id;
				END IF;
			END IF;
		ELSE
		--generate 0189 loan return
			IF v_ssgm_loan_return_qty IS NOT NULL AND v_ssgm_loan_return_qty>0 AND v_last_unfilled_qty>0 AND v_unfilled_qty<=0 THEN
				BEGIN
				  SELECT GGB.COUNTERPARTY_CD
			      INTO v_0189_return_cpty
			      FROM GEC_FUND GF,GEC_G1_BOOKING GGB
			      WHERE GF.FUND_CD=GGB.FUND_CD
			      AND GF.FUND_CD='0189' 
			      AND GGB.TRANSACTION_CD='G1L'
			      AND POS_TYPE='NSB';
				EXCEPTION WHEN NO_DATA_FOUND THEN
					  p_status:='CE';
					  p_error_msg:='0189 fund G1L NSB Counterparty is not exist.';
					  RETURN;
				END;
        		v_0189_return_qty:=v_ssgm_loan_return_qty;
        		GENERATE_RETURN('0189',v_asset_id,p_flip_trade_id,p_flip_borrow_id,'L',v_b_trade_date,v_b_settle_Date,v_0189_return_cpty,null,v_ssgm_loan_return_qty,p_status,p_error_msg);
			END IF;
		END IF;
		IF v_ssgm_loan_qty<v_last_unfilled_qty THEN
			--generate loan return loan return borrow
			 IF v_return_request_type IS NULL THEN
		        v_return_request_type:='NSB';
		      END IF;
			IF v_new_request_type='SB' THEN
				IF v_return_request_type<>'SB' THEN
					v_qty:=least(v_last_unfilled_qty,v_new_borrow_qty)-v_0189_qty;
					--generate book loan
					 GET_CPTY(v_flip_counter_party_cd,v_new_borrow_broker_cd,'BL',v_book_counter_party,v_fund_cd,p_status,p_error_msg);
					 IF p_status='CE'THEN
					 	RETURN;
					 END IF;
					var_rate := gec_allocation_pkg.GET_LOAN_RATE('SB',v_fund_cd,v_trade_country_cd,NULL, p_error_msg);
					IF p_error_msg IS NOT NULL THEN
						p_status:='FE';
						p_error_hint :=v_fund_cd;
						RETURN;
					END IF;
					GENERATE_LOAN(v_asset_id,v_fund_cd,v_b_trade_date,v_b_settle_Date,v_qty,var_rate,v_b_price,v_new_borrow_broker_cd,p_user_id,v_b_prepay_date,'SB',v_trade_country_cd,p_flip_trade_id,p_flip_borrow_id);
					--generate return loan
					 GET_CPTY(v_flip_counter_party_cd,v_new_borrow_broker_cd,'RL',v_book_counter_party,v_fund_cd,p_status,p_error_msg);
					IF p_status='CE'THEN
					 	RETURN;
					 END IF;
					GENERATE_RETURN(v_fund_cd,v_asset_id,p_flip_trade_id,p_flip_borrow_id,'L',v_b_trade_date,v_b_settle_Date,v_book_counter_party,null,v_qty,p_status,p_error_msg);
					--generate return borrow
	        		v_qty:=least(v_last_unfilled_qty,v_new_borrow_qty)-v_0189_qty+v_0189_return_qty;
					 GET_CPTY(v_flip_counter_party_cd,v_new_borrow_broker_cd,'RB',v_book_counter_party,v_fund_cd,p_status,p_error_msg);
					IF p_status='CE'THEN
					 	RETURN;
					END IF;
					GENERATE_RETURN(v_fund_cd,v_asset_id,p_flip_trade_id,p_flip_borrow_id,'B',v_b_trade_date,v_b_settle_Date,v_book_counter_party,v_bargain_ref,v_qty,p_status,p_error_msg);
				END IF;
			ELSE
		        IF  v_return_request_type<>'SB' THEN
					--generate return borrow
	        		GET_CPTY(v_flip_counter_party_cd,v_new_borrow_broker_cd,'RB',v_book_counter_party,v_fund_cd,p_status,p_error_msg);
	        		IF p_status='CE'THEN
					 	RETURN;
					 END IF;
	        		v_qty:=least(v_last_unfilled_qty,v_new_borrow_qty)-v_0189_qty+v_0189_return_qty;
					GENERATE_RETURN(v_fund_cd,v_asset_id,p_flip_trade_id,p_flip_borrow_id,'B',v_b_trade_date,v_b_settle_Date,v_book_counter_party,v_bargain_ref,v_qty,p_status,p_error_msg);
		        ELSE
		          v_qty:=least(v_last_unfilled_qty,v_new_borrow_qty)-v_0189_qty;
		          --generate book loan
				  GET_CPTY(v_flip_counter_party_cd,v_new_borrow_broker_cd,'BL',v_book_counter_party,v_fund_cd,p_status,p_error_msg);
				  IF p_status='CE'THEN
					 	RETURN;
				  END IF;
				  IF v_flip_nsb_loan_rate IS NULL THEN
				  	var_rate := gec_allocation_pkg.GET_LOAN_RATE('NSB',v_fund_cd,v_trade_country_cd,NULL, p_error_msg);
					IF p_error_msg IS NOT NULL THEN
						p_status:='FE';
						p_error_hint :=v_fund_cd;
						RETURN;
					END IF;
				  END IF; 
		          GENERATE_LOAN(v_asset_id,v_fund_cd,v_b_trade_date,v_b_settle_Date,v_qty,NVL(v_flip_nsb_loan_rate,var_rate),v_b_price,v_new_borrow_broker_cd,p_user_id,v_b_prepay_date,'NSB',v_trade_country_cd,p_flip_trade_id,p_flip_borrow_id);
		          --generate return loan
		          GET_CPTY(v_flip_counter_party_cd,v_new_borrow_broker_cd,'RL',v_book_counter_party,v_fund_cd,p_status,p_error_msg);
		          IF p_status='CE'THEN
					 	RETURN;
				  END IF;
		          GENERATE_RETURN(v_fund_cd,v_asset_id,p_flip_trade_id,p_flip_borrow_id,'L',v_b_trade_date,v_b_settle_Date,v_book_counter_party,null,v_qty,p_status,p_error_msg);
		          --generate return borrow
		          GET_CPTY(v_flip_counter_party_cd,v_new_borrow_broker_cd,'RB',v_book_counter_party,v_fund_cd,p_status,p_error_msg);
		          IF p_status='CE'THEN
					 	RETURN;
				  END IF;
		          v_qty:=least(v_last_unfilled_qty,v_new_borrow_qty)-v_0189_qty+v_0189_return_qty;
		          GENERATE_RETURN(v_fund_cd,v_asset_id,p_flip_trade_id,p_flip_borrow_id,'B',v_b_trade_date,v_b_settle_Date,v_book_counter_party,v_bargain_ref,v_qty,p_status,p_error_msg);
		        END IF;
			END IF;
		END IF;
	END GENERATE_BOOK_DATA;
	PROCEDURE LOCK_FLIP_TRADES(p_demand_request_id NUMBER,p_input_type IN VARCHAR2,p_flip_trade_id NUMBER)
	IS
	CURSOR file_flip_trades IS
		SELECT GFT.FLIP_TRADE_ID 
			FROM GEC_BORROW_ORDER bo,GEC_FLIP_TRADE_DETAIL d,GEC_FLIP_TRADE GFT
			WHERE bo.BORROW_ORDER_ID = d.BORROW_ORDER_ID AND
					d.FLIP_TRADE_ID=GFT.FLIP_TRADE_ID AND 
					bo.BORROW_REQUEST_ID = p_demand_request_id
			ORDER BY GFT.FLIP_TRADE_ID ASC
			FOR UPDATE OF GFT.FLIP_TRADE_ID;
		
	CURSOR non_file_flip_trades IS 
		SELECT GFT.FLIP_TRADE_ID 
			FROM GEC_FLIP_TRADE GFT
			WHERE GFT.FLIP_TRADE_ID = p_flip_trade_id
		ORDER BY GFT.FLIP_TRADE_ID  ASC
		FOR UPDATE OF GFT.FLIP_TRADE_ID;
	BEGIN
		GEC_LOG_PKG.LOG_PERFORMANCE_START('LOCK_FLIP_TRADES');
		IF p_input_type = GEC_CONSTANTS_PKG.C_BORROW_FILE THEN -- for file response
			FOR s IN file_flip_trades
			LOOP
				NULL; -- only for lock shorts
			END LOOP;
		ELSE -- for manual input
			FOR n_s IN non_file_flip_trades
			LOOP
				NULL; -- only for lock shorts
			END LOOP;
		END IF;
		GEC_LOG_PKG.LOG_PERFORMANCE_END('LOCK_FLIP_TRADES');
	END LOCK_FLIP_TRADES;
	PROCEDURE FILL_FLIP_ERROR_RST(p_flip_cursor OUT SYS_REFCURSOR, p_borrows_cursor OUT SYS_REFCURSOR)
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
		
		OPEN p_flip_cursor FOR
				SELECT NULL as FLIP_TRADE_ID, NULL as ASSET_ID, NULL as CUSIP, NULL as isin,NULL AS sedol,NULL AS ticker,
				NULL AS quik,NULL AS description, NULL as TRADE_COUNTRY_CD,NULL AS RETURN_BARGAIN_REF,NULL AS transaction_cd,NULL as TRADE_DATE, NULL AS settle_date,
				NULL AS recall_due_date,NULL AS share_qty, NULL AS filled_qty,NULL AS min_qty,NULL AS inc_qty,NULL AS status,NULL AS export_status,NULL as RETURN_BRANCH_CD,
				NULL AS borrow_return_cpty,NULL AS ssgm_loan_qty,NULL AS ssgm_loan_return_qty,NULL AS nsb_loan_rate,NULL AS recall_comment_txt,NULL AS recall_flag,
				NULL AS PREBORROW_ELIGIBLE_FLAG,NULL AS export_enable_qty, NULL AS PREPAY_DATE_VALUE
				FROM DUAL;
	END FILL_FLIP_ERROR_RST;
	
	PROCEDURE SINGLE_FLIP_ALLOCATION(p_flip_trade_id IN NUMBER,
									p_user_id IN VARCHAR2,
									p_status OUT VARCHAR2,
									p_error_msg OUT VARCHAR2,
									p_error_hint OUT VARCHAR2)
	IS
		CURSOR v_flip_borrows IS
			SELECT GBT.BORROW_QTY,GBT.BORROW_ID,GBT.BOOK_G1_BORROW_FLAG
			FROM GEC_FLIP_TRADE GFT,GEC_FLIP_BORROW GFB,GEC_BORROW_TEMP GBT
			WHERE GBT.BORROW_ID=GFB.BORROW_ID 
			AND GFB.FLIP_TRADE_ID = GFT.FLIP_TRADE_ID
			AND GFT.FLIP_TRADE_ID=p_flip_trade_id
			AND GFB.STATUS='N'
			ORDER BY GBT.BOOK_G1_BORROW_FLAG ASC ,GBT.ALLOCATION_ORDER ASC ;
	BEGIN
		FOR v_flip_borrow IN v_flip_borrows
		LOOP
			p_status:='S';
			p_error_msg:='';
			UPDATE GEC_FLIP_TRADE
			SET FILLED_QTY=FILLED_QTY+v_flip_borrow.borrow_qty
			WHERE GEC_FLIP_TRADE.FLIP_TRADE_ID = p_flip_trade_id;
			UPDATE GEC_FLIP_BORROW
			SET STATUS='P'
			WHERE BORROW_ID=v_flip_borrow.BORROW_ID AND FLIP_TRADE_ID=p_flip_trade_id;
			IF v_flip_borrow.BOOK_G1_BORROW_FLAG ='Y'THEN
				GENERATE_BOOK_DATA(v_flip_borrow.BORROW_ID,p_flip_trade_id,p_user_id,p_status,p_error_msg,p_error_hint);
				IF p_status='CE' OR  p_status='FE'THEN
					UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR WHERE BORROW_ID = v_flip_borrow.BORROW_ID;
					RETURN;
				END IF;
			END IF;
		END LOOP;
		UPDATE GEC_FLIP_TRADE
		SET STATUS='P'
		WHERE GEC_FLIP_TRADE.FLIP_TRADE_ID = p_flip_trade_id;
		UPDATE GEC_FLIP_TRADE
				SET EXPORT_STATUS ='R'
		WHERE FLIP_TRADE_ID=p_flip_trade_id AND EXPORT_STATUS='I';
	END SINGLE_FLIP_ALLOCATION;
	
	--p_user_id the user who allocate the flip trade
	--p_demand_request_id the request id for file or message
	--p_input_type  F is from File or Message; S is from single; B is from batch Null is from ui
	--p_borrow_file_type 
	--p_tran_type FT for flip trades SHORTSB for shortSB
	--p_flip_trade_id the flip trade id for ui
	PROCEDURE PROCESS_FLIP_ALLOCATION(
												p_user_id IN VARCHAR2,
												p_demand_request_id IN NUMBER,
                            					p_input_type IN VARCHAR2,
                            					p_borrow_file_type IN VARCHAR2,
                            					p_trans_type IN VARCHAR2,
                            					p_flip_trade_id IN NUMBER,
                            					p_is_dirty IN VARCHAR2,
                            					p_status OUT VARCHAR2,
                            					p_error_msg OUT VARCHAR2,
                            					p_error_hint OUT VARCHAR2,
                            					p_flip_cursor OUT SYS_REFCURSOR,
												p_borrows_cursor OUT SYS_REFCURSOR)
   	IS 
  		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_ALLOCATION_PKG.PROCESS_FLIP_ALLOCATION';
  		var_valid VARCHAR2(3);
  		var_run_flag VARCHAR2(1); 
  		var_log_number VARCHAR2(20);
  		var_manual_flag VARCHAR2(1);
  		v_error_msg VARCHAR2(200);
  		v_error_hint VARCHAR2(200);
  		CURSOR v_flip_trades IS
			SELECT GFT.FLIP_TRADE_ID,GBO.LOG_NUMBER
			FROM GEC_FLIP_TRADE GFT,GEC_FLIP_TRADE_DETAIL GFTD,GEC_BORROW_ORDER GBO
			WHERE GFT.FLIP_TRADE_ID=GFTD.FLIP_TRADE_ID 
			AND GFTD.BORROW_ORDER_ID = GBO.BORROW_ORDER_ID
			AND GBO.BORROW_REQUEST_ID=p_demand_request_id;
  	BEGIN
    	GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);		
		-- prepare borrow temp
		GEC_ALLOCATION_PKG.PREPARE_TEMP_BORROWS(p_input_type, p_borrow_file_type, p_trans_type, var_valid);
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME||' prepare borrow end-');
		-- validation error
		IF var_valid = 'N' THEN
			p_status := 'VE';
			FILL_FLIP_ERROR_RST(p_flip_cursor, p_borrows_cursor);
			RETURN;
		END IF;
		-- lock GEC_FLIP_TRADE
		LOCK_FLIP_TRADES(p_demand_request_id,p_input_type,p_flip_trade_id);
		GEC_ALLOCATION_PKG.MERGE_BORROWS(p_user_id, p_input_type,p_trans_type, var_valid);
		
		GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME||' merge borrow end-');
		IF var_valid = 'N' THEN
			p_status := 'UE';
			FILL_FLIP_ERROR_RST(p_flip_cursor, p_borrows_cursor);
			RETURN;
		ELSIF var_valid = 'E' THEN
			p_status := 'OE';
			FILL_FLIP_ERROR_RST(p_flip_cursor, p_borrows_cursor);
			RETURN;
		END IF;
		
		--------------------------------------------------------------------------------------------------------------
		------------------------------------------- BEGIN MAIN AUTO ALLOCATION LOGIC----------------------------------
		--------------------------------------------------------------------------------------------------------------
		IF p_input_type = GEC_CONSTANTS_PKG.C_BORROW_FILE THEN
			-- insert into GEC_FLIP_BORROW
			FOR v_flip_trade IN v_flip_trades
			LOOP
				INSERT INTO GEC_FLIP_BORROW(FLIP_BORROW_ID,BORROW_ID,FLIP_TRADE_ID,ALLOCATION_QTY,STATUS) 
				SELECT GEC_FLIP_BORROW_ID_SEQ.nextval,GBT.BORROW_ID,v_flip_trade.FLIP_TRADE_ID,GBT.BORROW_QTY,'N' FROM GEC_BORROW_TEMP GBT WHERE GBT.RESPONSE_LOG_NUM=v_flip_trade.LOG_NUMBER;
			END LOOP;
			-- allocate
			FOR v_flip_trade IN v_flip_trades
			LOOP
				VALIDATE_BORROWS(v_flip_trade.FLIP_TRADE_ID,var_valid);
				IF var_valid='NIE' THEN
					 p_status:='NIE';
					 FILL_FLIP_ERROR_RST(p_flip_cursor, p_borrows_cursor);
					 RETURN;
				ELSIF var_valid= 'IE' THEN
					 p_status:='IE';
					 FILL_FLIP_ERROR_RST(p_flip_cursor, p_borrows_cursor);
					 RETURN;
				ELSIF var_valid ='SBE'THEN
					p_status:='SBE';
					FILL_FLIP_ERROR_RST(p_flip_cursor, p_borrows_cursor);
					RETURN;
				ELSIF var_valid ='CE'THEN
					p_status:='FCE';
					FILL_FLIP_ERROR_RST(p_flip_cursor, p_borrows_cursor);
					RETURN;
				END IF;
					-- validate manual intervation
	        	VALIDATE_MANUAL_INTERVATION(v_flip_trade.FLIP_TRADE_ID,p_is_dirty,var_manual_flag);
        		IF var_manual_flag ='Y' THEN
					SINGLE_FLIP_ALLOCATION(v_flip_trade.FLIP_TRADE_ID,p_user_id,var_valid,v_error_msg,v_error_hint);
					IF var_valid='CE' THEN
						p_status:='CE';
						p_error_msg:=v_error_msg;
						FILL_FLIP_ERROR_RST(p_flip_cursor, p_borrows_cursor);
						RETURN;
					ELSIF var_valid='FE' THEN
						p_status:='FE';
						p_error_msg:=v_error_msg;
						p_error_hint:=v_error_hint;
						FILL_FLIP_ERROR_RST(p_flip_cursor, p_borrows_cursor);
						RETURN;
					END IF;
				END IF;
			END LOOP;
		ELSE 
			INSERT INTO GEC_FLIP_BORROW(FLIP_BORROW_ID,BORROW_ID,FLIP_TRADE_ID,ALLOCATION_QTY,STATUS) 
				SELECT GEC_FLIP_BORROW_ID_SEQ.nextval,GBT.BORROW_ID,p_flip_trade_id,GBT.BORROW_QTY,'N' FROM GEC_BORROW_TEMP GBT;		
			VALIDATE_BORROWS(p_flip_trade_id,var_valid);
			IF var_valid='NIE' THEN
					 p_status:='NIE';
					 FILL_FLIP_ERROR_RST(p_flip_cursor, p_borrows_cursor);
					 RETURN;
			ELSIF var_valid= 'IE' THEN
					 p_status:='IE';
					 FILL_FLIP_ERROR_RST(p_flip_cursor, p_borrows_cursor);
					 RETURN;
			ELSIF var_valid ='SBE'THEN
				p_status:='SBE';
				FILL_FLIP_ERROR_RST(p_flip_cursor, p_borrows_cursor);
				RETURN;
			ELSIF var_valid ='CE'THEN
				p_status:='FCE';
				FILL_FLIP_ERROR_RST(p_flip_cursor, p_borrows_cursor);
				RETURN;
			END IF;
				-- validate manual intervation
	      	VALIDATE_MANUAL_INTERVATION(p_flip_trade_id,p_is_dirty,var_manual_flag);
      		IF var_manual_flag ='Y' THEN
				SINGLE_FLIP_ALLOCATION(p_flip_trade_id,p_user_id,var_valid,v_error_msg,v_error_hint);
				IF var_valid='CE' THEN
					p_status:='CE';
					p_error_msg:=v_error_msg;
					FILL_FLIP_ERROR_RST(p_flip_cursor, p_borrows_cursor);
					RETURN;
				ELSIF var_valid='FE' THEN
					p_status:='FE';
					p_error_msg:=v_error_msg;
					p_error_hint:=v_error_hint;
					FILL_FLIP_ERROR_RST(p_flip_cursor, p_borrows_cursor);
					RETURN;
				END IF;
			END IF;
		END IF;
		p_status := 'S';
		
		-- set the the allocation status of borrow request to C-omplete
		UPDATE GEC_BORROW_REQUEST SET ALLOCATE_STATUS='C' WHERE BORROW_REQUEST_ID = p_demand_request_id AND p_demand_request_id IS NOT NULL;
		
		IF p_input_type <> GEC_CONSTANTS_PKG.C_BORROW_FILE THEN -- for manual input borrows
					OPEN p_flip_cursor FOR
						SELECT 
								gft.flip_trade_id,gft.ASSET_ID,ga.cusip,ga.isin,ga.sedol,ga.ticker,ga.quik,ga.description,gft.trade_country_cd,gft.transaction_cd,gft.trade_date,
								gft.settle_date,gft.recall_due_date,gft.share_qty,gft.filled_qty,gft.min_qty,gft.inc_qty,gft.status,gft.export_status,gft.RETURN_BRANCH_CD,gft.borrow_return_cpty,gft.RETURN_BARGAIN_REF,
								gft.ssgm_loan_qty,gft.ssgm_loan_return_qty,gft.nsb_loan_rate,gft.recall_comment_txt,gft.recall_flag,gtc.PREBORROW_ELIGIBLE_FLAG,gft.share_qty-gft.filled_qty-gft.ssgm_loan_return_qty as export_enable_qty,
								gtc.PREPAY_DATE_VALUE AS PREPAY_DATE_VALUE
							FROM gec_flip_trade gft
							JOIN gec_asset ga
							on gft.asset_id = ga.asset_id
							JOIN GEC_TRADE_COUNTRY gtc 
							ON gft.TRADE_COUNTRY_CD = gtc.TRADE_COUNTRY_CD
							WHERE gft.flip_trade_id=p_flip_trade_id;
	
				ELSE -- for file response
					OPEN p_flip_cursor FOR
						SELECT 
								gft.flip_trade_id,gft.ASSET_ID,ga.cusip,ga.isin,ga.sedol,ga.ticker,ga.quik,ga.description,gft.trade_country_cd,gft.transaction_cd,gft.trade_date,
								gft.settle_date,gft.recall_due_date,gft.share_qty,gft.filled_qty,gft.min_qty,gft.inc_qty,gft.status,gft.export_status,gft.RETURN_BRANCH_CD,gft.borrow_return_cpty,gft.RETURN_BARGAIN_REF,
								gft.ssgm_loan_qty,gft.ssgm_loan_return_qty,gft.nsb_loan_rate,gft.recall_comment_txt,gft.recall_flag,gtc.PREBORROW_ELIGIBLE_FLAG,gft.share_qty-gft.filled_qty-gft.ssgm_loan_return_qty as export_enable_qty,
								gtc.PREPAY_DATE_VALUE AS PREPAY_DATE_VALUE
							FROM gec_flip_trade gft
							JOIN gec_asset ga
							on gft.asset_id = ga.asset_id
							JOIN GEC_TRADE_COUNTRY gtc 
							ON gft.TRADE_COUNTRY_CD = gtc.TRADE_COUNTRY_CD
							JOIN GEC_FLIP_TRADE_DETAIL GFTD
							ON GFTD.FLIP_TRADE_ID=GFT.FLIP_TRADE_ID
							JOIN GEC_BORROW_ORDER GBO
							ON GBO.BORROW_ORDER_ID=GFTD.BORROW_ORDER_ID
							WHERE GBO.BORROW_REQUEST_ID=p_demand_request_id;
						
				END IF;  
		OPEN p_borrows_cursor FOR
				SELECT t.BORROW_ID as BORROW_ID, NULL as TRADE_DATE, NULL as BORROW_ORDER_ID, NULL as ASSET_ID,NULL as BROKER_CD, NULL as SETTLE_DATE,NULL as COLLATERAL_TYPE, NULL as COLLATERAL_CURRENCY_CD,
					NULL as COLLATERAL_LEVEL,NULL as BORROW_QTY,NULL as RATE,NULL as POSITION_FLAG,NULL as COMMENT_TXT,NULL as TYPE,NULL as STATUS,NULL as CREATED_AT,NULL as CREATED_BY, NULL as TRADE_COUNTRY_CD,
					NULL as UPDATED_AT,NULL as UPDATED_BY,NULL as PRICE, NULL as NO_DEMAND_FLAG, NULL as INTERVENTION_REASON, NULL as RESPONSE_LOG_NUM, NULL as CUSIP, NULL as SEDOL, NULL as ISIN,NULL as QUIK, NULL as TICKER, NULL as ASSET_CODE, NULL as BORROW_REQUEST_TYPE, NULL as UI_ROW_NUMBER, NULL as ERROR_CODE,
					NULL as PREPAY_DATE, NULL as PREPAY_RATE, NULL as RECLAIM_RATE, NULL as OVERSEAS_TAX_PERCENTAGE, NULL as DOMESTIC_TAX_PERCENTAGE, NULL as MINIMUM_FEE,NULL as MINIMUM_FEE_CD, NULL as EQUILEND_MESSAGE_ID, NULL AS TERM_DATE, NULL AS EXPECTED_RETURN_DATE
				FROM GEC_BORROW_TEMP t;
	GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME, 'S', 'SUCCESS');
	EXCEPTION WHEN OTHERS THEN
		GEC_LOG_PKG.LOG_PERFORMANCE_EXCEPTION(V_PROCEDURE_NAME);
		RAISE;
  	END PROCESS_FLIP_ALLOCATION;
  -- validate manual intervation for flip trade
  -- if p_manual flag is N is manual intervation
  PROCEDURE VALIDATE_MANUAL_INTERVATION(p_flip_trade_id IN NUMBER,p_is_dirty IN VARCHAR2,p_manual_flag OUT VARCHAR2)
  IS
    var_borrow_qty NUMBER;
    var_unfilled_qty NUMBER;
    var_auto_book_flag GEC_TRADE_COUNTRY.G1_AUTO_BOOKING%TYPE;
    v_return_request_type GEC_BORROW_REQUEST.BORROW_REQUEST_TYPE%type;
    v_0189_qty NUMBER;
    v_0189_return_qty NUMBER;
    var_sb_borrow_qty NUMBER;
    var_borrow_count NUMBER;
    CURSOR v_prepare_rate_null IS
			SELECT GBT.BORROW_ID, GBT.ASSET_ID 
			FROM GEC_BORROW_TEMP GBT,GEC_FLIP_TRADE GFT, GEC_FLIP_BORROW GFB
			WHERE 
			GFT.FLIP_TRADE_ID = p_flip_trade_id
			AND GFT.FLIP_TRADE_ID = GFB.FLIP_TRADE_ID
			AND GFB.BORROW_ID = GBT.BORROW_ID
			AND GBT.PREPAY_RATE IS NULL 
			AND ((GBT.PREPAY_DATE < GBT.SETTLE_DATE AND (GBT.COLLATERAL_TYPE = 'CASH' OR GBT.COLLATERAL_TYPE='POOL') AND GBT.BORROW_REQUEST_TYPE <> 'SB' AND (GBT.TRADE_COUNTRY_CD='US' OR GBT.TRADE_COUNTRY_CD='CA')) OR ((GBT.COLLATERAL_TYPE = 'CASH' OR GBT.COLLATERAL_TYPE='POOL') AND GBT.BORROW_REQUEST_TYPE <> 'SB' AND (GBT.TRADE_COUNTRY_CD<>'US' AND GBT.TRADE_COUNTRY_CD<>'CA')));
  BEGIN
    p_manual_flag:='Y';
    SELECT 
    count(GBT.BORROW_ID)
    INTO 
    var_borrow_count
    FROM GEC_BORROW_TEMP GBT,GEC_FLIP_TRADE GFT, GEC_FLIP_BORROW GFB
    WHERE
    GFT.FLIP_TRADE_ID = p_flip_trade_id
	AND GFT.FLIP_TRADE_ID = GFB.FLIP_TRADE_ID
	AND GFB.BORROW_ID = GBT.BORROW_ID;
	IF var_borrow_count =0 THEN
		RETURN;
	END IF;
    
    SELECT GFT.share_qty-GFT.FILLED_QTY+ GFT.ssgm_loan_qty- GFT.ssgm_loan_return_qty,GBR.BORROW_REQUEST_TYPE,GTC.G1_AUTO_BOOKING,
    GFT.SSGM_LOAN_QTY,GFT.SSGM_LOAN_RETURN_QTY
    INTO var_unfilled_qty,v_return_request_type,var_auto_book_flag,v_0189_qty,v_0189_return_qty
    FROM GEC_TRADE_COUNTRY GTC,GEC_FLIP_TRADE GFT
    LEFT JOIN GEC_BROKER GBR
    ON GBR.BROKER_CD=GFT.BORROW_RETURN_CPTY
    WHERE GFT.TRADE_COUNTRY_CD = GTC.TRADE_COUNTRY_CD
    AND GFT.flip_trade_id=p_flip_trade_id;
    -- validate more than demand
    SELECT SUM(GB.BORROW_QTY)
    INTO var_borrow_qty
    FROM GEC_BORROW GB, GEC_FLIP_BORROW GFB,GEC_FLIP_TRADE GFT
    WHERE GB.BORROW_ID= gfb.borrow_id
    AND GFB.FLIP_TRADE_ID= gft.flip_trade_id
    AND gft.flip_trade_id=p_flip_trade_id
    AND GFB.STATUS='N';
    IF p_is_dirty='Y' THEN 
    	IF var_borrow_qty>var_unfilled_qty THEN
	       UPDATE_FLIP_TRADE_BORROW_TO_M(p_flip_trade_id,GEC_CONSTANTS_PKG.C_BORROW_MORE_THAN_DEMAND);
	       p_manual_flag:='N';
	      RETURN;
	    END IF;
	    -- validate auto book flag
		IF var_auto_book_flag='N'THEN
		  UPDATE_FLIP_TRADE_BORROW_TO_M(p_flip_trade_id,GEC_CONSTANTS_PKG.C_BORROW_AUTO_BOOKING_NO);
		  p_manual_flag:='N';
		END IF;
		-- validate no prepare rate 
		FOR v_p_r_n IN v_prepare_rate_null
		LOOP
			UPDATE_FLIP_TRADE_BORROW_TO_M(p_flip_trade_id,GEC_CONSTANTS_PKG.C_BORROW_NO_PREPAY_RATE);
			p_manual_flag:='N';
			EXIT;
		END LOOP;
    END IF;
	-- validate sb to nsb 0189 has value
	IF v_return_request_type IS NULL OR v_return_request_type<>GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB THEN
		IF v_0189_qty>0 THEN
				SELECT NVL(SUM(GB.BORROW_QTY),0)
				INTO var_sb_borrow_qty
				FROM GEC_FLIP_BORROW GFB,GEC_FLIP_TRADE GFT,GEC_BORROW GB
				LEFT JOIN GEC_BROKER GBR
				ON GBR.BROKER_CD=GB.BROKER_CD
				WHERE GB.BORROW_ID= gfb.borrow_id
			    AND GFB.FLIP_TRADE_ID= gft.flip_trade_id
			    AND gft.flip_trade_id=p_flip_trade_id
			    AND GFB.STATUS='N'
			    AND GBR.BORROW_REQUEST_TYPE=GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB;
			
		    IF var_sb_borrow_qty > var_unfilled_qty-v_0189_qty THEN
		    	UPDATE_FLIP_TRADE_BORROW_TO_M(p_flip_trade_id,GEC_CONSTANTS_PKG.C_BORROW_0189_LOAN);
	  	   		p_manual_flag:='N';
		    END IF;
		END IF;
	END IF;
	--validate nsb to sb 0189 rt has value
	IF v_return_request_type=GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB THEN
		IF v_0189_return_qty>0 THEN 
		   UPDATE_FLIP_TRADE_BORROW_TO_M(p_flip_trade_id,GEC_CONSTANTS_PKG.C_BORROW_0189_LOAN_RT);
	  	   p_manual_flag:='N';
		END IF;
	END IF;
	
  END VALIDATE_MANUAL_INTERVATION;
  	PROCEDURE UPDATE_FLIP_TRADE_BORROW_TO_M(p_flip_trade_id IN NUMBER,p_intervation_reason IN VARCHAR2)
  	IS
  	 CURSOR var_update_borrows IS
  	  SELECT GB.BORROW_ID 
      FROM GEC_BORROW GB,GEC_FLIP_BORROW GFB,GEC_FLIP_TRADE GFT 
      WHERE GB.BORROW_ID=GFB.BORROW_ID
      AND GFB.FLIP_TRADE_ID=GFT.FLIP_TRADE_ID
      AND GFT.FLIP_TRADE_ID=p_flip_trade_id
      AND GFB.STATUS='N';
  	BEGIN
  	 UPDATE GEC_FLIP_TRADE
      SET STATUS='M'
      WHERE FLIP_TRADE_ID=p_flip_trade_id;
      
     
      FOR var_update_borrow IN var_update_borrows
      LOOP
      	  UPDATE GEC_BORROW 
	      SET STATUS=GEC_CONSTANTS_PKG.C_BORROW_MANUAL,INTERVENTION_REASON=p_intervation_reason
	      WHERE 
	      BORROW_ID=var_update_borrow.BORROW_ID;
      END LOOP;
  	END UPDATE_FLIP_TRADE_BORROW_TO_M; 	 	
  		
	PROCEDURE CANCEL_FLIP_BORROW(p_borrow_id IN NUMBER,
								 p_status OUT VARCHAR2,
								 p_flip_trade_cursor OUT SYS_REFCURSOR
								 )
	IS
		v_flip_borrow_id GEC_FLIP_BORROW.FLIP_BORROW_ID%type;
		v_borrow_qty GEC_FLIP_BORROW.ALLOCATION_QTY%type;
		v_flip_trade_id GEC_FLIP_TRADE.FLIP_TRADE_ID%type;
		v_status GEC_FLIP_BORROW.STATUS%type;
		v_flip_trade_export_status GEC_FLIP_TRADE.EXPORT_STATUS%type;
		v_flip_trade_status GEC_FLIP_TRADE.STATUS%type;
	BEGIN
		SELECT FLIP_BORROW_ID,ALLOCATION_QTY,FLIP_TRADE_ID,STATUS INTO v_flip_borrow_id,v_borrow_qty,v_flip_trade_id,v_status FROM GEC_FLIP_BORROW WHERE BORROW_ID=p_borrow_id;
		IF v_status<>'P' THEN
			p_status:='E';
			FILL_FLIP_TRADE_ERROR_RST(p_flip_trade_cursor);
			RETURN;
		END IF;
		SELECT EXPORT_STATUS,STATUS INTO v_flip_trade_export_status,v_flip_trade_status FROM GEC_FLIP_TRADE WHERE FLIP_TRADE_ID= v_flip_trade_id;
		IF v_flip_trade_export_status='I' OR v_flip_trade_status ='C'THEN
			p_status:='E';
			FILL_FLIP_TRADE_ERROR_RST(p_flip_trade_cursor);
			RETURN;
		END IF;
		UPDATE GEC_FLIP_TRADE
		SET FILLED_QTY=(FILLED_QTY-v_borrow_qty)
		WHERE
		FLIP_TRADE_ID = v_flip_trade_id;
		
		UPDATE GEC_FLIP_BORROW
		SET STATUS='C'
		WHERE FLIP_BORROW_ID=v_flip_borrow_id;
		
		OPEN p_flip_trade_cursor FOR
						SELECT 
								gft.flip_trade_id,gft.ASSET_ID,ga.cusip,ga.isin,ga.sedol,ga.ticker,ga.quik,ga.description,gft.trade_country_cd,gft.transaction_cd,gft.trade_date,
								gft.settle_date,gft.recall_due_date,gft.share_qty,gft.filled_qty,gft.min_qty,gft.inc_qty,gft.status,gft.export_status,gft.RETURN_BRANCH_CD,gft.borrow_return_cpty,gft.RETURN_BARGAIN_REF,
								gft.ssgm_loan_qty,gft.ssgm_loan_return_qty,gft.nsb_loan_rate,gft.recall_comment_txt,gft.recall_flag,gtc.PREBORROW_ELIGIBLE_FLAG,gft.share_qty-gft.filled_qty-gft.ssgm_loan_return_qty as export_enable_qty,
								gtc.PREPAY_DATE_VALUE AS PREPAY_DATE_VALUE
							FROM gec_flip_trade gft
							JOIN gec_asset ga
							on gft.asset_id = ga.asset_id
							JOIN GEC_TRADE_COUNTRY gtc 
							ON gft.TRADE_COUNTRY_CD = gtc.TRADE_COUNTRY_CD
							WHERE gft.flip_trade_id=v_flip_trade_id;
	END CANCEL_FLIP_BORROW;
  	-- Delete flip borrow during manual intervention.
	-- Only delete the borrow from GEC_BORROW, GEC_FLIP_BORROW.
	-- Not do allocate.
	PROCEDURE DELETE_MANU_INTERV_FLIP_BORROW(
											p_flip_trade_id IN NUMBER,
											p_borrow_id IN NUMBER,
											p_status OUT VARCHAR2,
											p_flip_trade_cursor OUT SYS_REFCURSOR
										)
	IS			
		
   CURSOR flip_trade IS
      SELECT STATUS
      FROM GEC_FLIP_TRADE 
      WHERE FLIP_TRADE_ID = p_flip_trade_id 
      FOR UPDATE OF STATUS;
      
    CURSOR exist_borrow IS
			SELECT BORROW_ID, STATUS
			FROM GEC_BORROW WHERE BORROW_ID = p_borrow_id
			ORDER BY BORROW_ID ASC			
			FOR UPDATE OF STATUS;
			
	var_borrow_count NUMBER;
				
	BEGIN
		
		SELECT COUNT(1) INTO var_borrow_count FROM GEC_BORROW WHERE BORROW_ID = p_borrow_id;
		IF var_borrow_count = 0 THEN
			FILL_FLIP_TRADE_ERROR_RST(p_flip_trade_cursor);
			RETURN;
		END IF;
		
		-- Lock flip trade to avoid dead lock with auto process flip borrow.
		FOR e_ft IN flip_trade
	    LOOP
	        IF e_ft.STATUS <> GEC_CONSTANTS_PKG.C_FLIP_TRADE_MANUAL THEN
		        p_status := 'FE';
		        FILL_FLIP_TRADE_ERROR_RST(p_flip_trade_cursor);
		        RETURN;
	        END IF;
	    END LOOP;
		    
		FOR e_b IN exist_borrow
		LOOP
			IF e_b.STATUS <> GEC_CONSTANTS_PKG.C_BORROW_MANUAL THEN
				p_status := 'OE';
				FILL_FLIP_TRADE_ERROR_RST(p_flip_trade_cursor);
				RETURN;
			END IF;
		END LOOP;		
					
		-- delete the relationship for this manual borrow on GEC_FLIP_BORROW table.
		-- Generally, one borrow only matched to one flip trade.
		DELETE FROM GEC_FLIP_BORROW WHERE BORROW_ID = p_borrow_id and FLIP_TRADE_ID = p_flip_trade_id;		
	
		DELETE FROM GEC_BORROW WHERE BORROW_ID = p_borrow_id;
		
		-- If no manual borrow for this flip trade, should update flip trade status to 'P' from 'M'.
		UPDATE GEC_FLIP_TRADE SET STATUS = GEC_CONSTANTS_PKG.C_FLIP_TRADE_PENDING 
			WHERE NOT EXISTS(SELECT 1 FROM GEC_FLIP_BORROW gfb, GEC_BORROW gb 
								WHERE gfb.BORROW_ID = gb.BORROW_ID
								AND gfb.FLIP_TRADE_ID = p_flip_trade_id
								AND gb.STATUS = GEC_CONSTANTS_PKG.C_BORROW_MANUAL)
			AND FLIP_TRADE_ID = p_flip_trade_id
			AND STATUS = GEC_CONSTANTS_PKG.C_FLIP_TRADE_MANUAL;
		
		OPEN p_flip_trade_cursor FOR
			SELECT 
				gft.flip_trade_id,
				gft.ASSET_ID,
				ga.cusip,
				ga.isin,
				ga.sedol,
				ga.ticker,
				ga.quik,
				ga.description,
				gft.trade_country_cd,
				gft.transaction_cd,
				gft.trade_date,
				gft.settle_date,
				gft.recall_due_date,
				gft.share_qty,
				gft.filled_qty,
				gft.min_qty,
				gft.inc_qty,
				gft.status,
				gft.export_status,
				gft.RETURN_BRANCH_CD,
				gft.borrow_return_cpty,
				gft.RETURN_BARGAIN_REF,
				gft.ssgm_loan_qty,
				gft.ssgm_loan_return_qty,
				gft.nsb_loan_rate,
				gft.recall_comment_txt,
				gft.recall_flag,
				gtc.PREBORROW_ELIGIBLE_FLAG,
				gtc.PREPAY_DATE_VALUE,
				gft.share_qty-gft.filled_qty-gft.ssgm_loan_return_qty as export_enable_qty
			FROM gec_flip_trade gft
			JOIN gec_asset ga
			on gft.asset_id = ga.asset_id
			JOIN GEC_TRADE_COUNTRY gtc 
			ON gft.TRADE_COUNTRY_CD = gtc.TRADE_COUNTRY_CD
			WHERE gft.FLIP_TRADE_ID = p_flip_trade_id;			
										
	END DELETE_MANU_INTERV_FLIP_BORROW;
	
	PROCEDURE VALIDATE_BORROWS(p_flip_trade_id IN NUMBER,var_valid OUT VARCHAR2)
	IS
		v_return_request_type GEC_BORROW_REQUEST.BORROW_REQUEST_TYPE%type;
		v_export_status GEC_FLIP_TRADE.EXPORT_STATUS%type;
		v_status GEC_FLIP_TRADE.STATUS%type;
		CURSOR v_borrows IS
			SELECT GBT.BORROW_ID,GBR.BORROW_REQUEST_TYPE,GBT.TYPE
			FROM GEC_FLIP_BORROW GFB,GEC_FLIP_TRADE GFT,GEC_BORROW_TEMP GBT
			LEFT JOIN GEC_BROKER GBR
		  	ON GBT.BROKER_CD=GBR.BROKER_CD
			WHERE GBT.BORROW_ID= gfb.borrow_id
		    AND GFB.FLIP_TRADE_ID= gft.flip_trade_id
		    AND gft.flip_trade_id=p_flip_trade_id
		    AND GFB.STATUS='N';
	BEGIN
		var_valid:='';
		SELECT 
			GBR.BORROW_REQUEST_TYPE,GFT.EXPORT_STATUS,GFT.STATUS
		INTO
			v_return_request_type,v_export_status,v_status
		FROM GEC_FLIP_TRADE GFT
		LEFT JOIN GEC_BROKER GBR
		ON GBR.BROKER_CD=GFT.BORROW_RETURN_CPTY
		WHERE GFT.FLIP_TRADE_ID = p_flip_trade_id;
		
		IF v_status='C'THEN
			var_valid:='CE';
			RETURN;
		END IF;
		FOR v_borrow IN v_borrows
		LOOP
			IF v_borrow.TYPE =GEC_CONSTANTS_PKG.C_BORROW_AUTO_INPUT THEN
				IF v_export_status <>GEC_CONSTANTS_PKG.C_INFLIGHT_STATUS THEN
					var_valid:='NIE';
					UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR WHERE BORROW_ID = v_borrow.BORROW_ID;
					RETURN;
				END IF;
			ELSE
				IF v_export_status =GEC_CONSTANTS_PKG.C_INFLIGHT_STATUS THEN
					var_valid:='IE';
					UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR WHERE BORROW_ID = v_borrow.BORROW_ID;
					RETURN;
				END IF;
			END IF;
			IF v_borrow.BORROW_REQUEST_TYPE=GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB AND v_return_request_type = GEC_CONSTANTS_PKG.C_BORROW_REQUEST_SB  THEN
					var_valid:='SBE';
					UPDATE GEC_BORROW_TEMP SET STATUS = GEC_CONSTANTS_PKG.C_BORROW_ERROR WHERE BORROW_ID = v_borrow.BORROW_ID;
					RETURN;
				END IF;
		END LOOP;
	END VALIDATE_BORROWS;
	
	PROCEDURE FILL_FLIP_TRADE_ERROR_RST(p_flip_cursor OUT SYS_REFCURSOR)
	IS
	BEGIN		
		OPEN p_flip_cursor FOR
				SELECT NULL as FLIP_TRADE_ID, NULL as ASSET_ID, NULL as CUSIP, NULL as isin,NULL AS sedol,NULL AS ticker,
				NULL AS quik,NULL AS description, NULL as TRADE_COUNTRY_CD,NULL AS RETURN_BARGAIN_REF,NULL AS transaction_cd,NULL as TRADE_DATE, NULL AS settle_date,
				NULL AS recall_due_date,NULL AS share_qty, NULL AS filled_qty,NULL AS min_qty,NULL AS inc_qty,NULL AS status,NULL AS export_status,NULL AS RETURN_BRANCH_CD,
				NULL AS borrow_return_cpty,NULL AS ssgm_loan_qty,NULL AS ssgm_loan_return_qty,NULL AS nsb_loan_rate,NULL AS recall_comment_txt,NULL AS recall_flag,
				NULL AS PREBORROW_ELIGIBLE_FLAG,NULL AS export_enable_qty,NULL AS PREPAY_DATE_VALUE
				FROM DUAL;
	END FILL_FLIP_TRADE_ERROR_RST;
	
	--GEC2.2 CHANGE
	PROCEDURE BATCH_VLD_FLIP_TRADE_DATE(p_desktop_date IN DATE,p_faild_counts OUT NUMBER)
	IS
		V_T_DAYS NUMBER := NULL;
		V_T_DATE_NUM NUMBER :=NULL;
		V_TODAY_NUM NUMBER :=NULL;
		CURSOR v_cur_dates
		IS
			SELECT TRADE_DATE,SETTLE_DATE,TRADE_COUNTRY_CD
			FROM GEC_FLIP_TRADE_TEMP;
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
	END BATCH_VLD_FLIP_TRADE_DATE;
END GEC_FLIP_TRADE_PKG;
/