-------------------------------------------------------------------------
-- Copyright (c) 2009 State Street Bank and Trust Corp.
-- 225 Franklin Street, Boston, MA 02110, U.S.A.
-- All rights reserved.
--
-- "GEC_AUTO_RETURN_PKG.sql is the copyrighted,
-- proprietary property of State Street Bank and Trust Company and its
-- subsidiaries and affiliates which retain all right, title and interest
-- therein."
--
-- Revision History
--
-- Date            Programmer                Notes
-- ------------    --------------------      ----------------------------
-- Jul 16, 2013    Wanhua, Zhang.            initial
-------------------------------------------------------------------------
-- genearte g1_return_detail based on gec_auto_return_activity
create or replace PACKAGE GEC_AUTO_RETURN_PKG AS
	PROCEDURE GENEATE_G1_RETURN_DETAIL(
		p_user_id IN VARCHAR2,
		p_g1_trade_activity_id IN GEC_G1_TRADE_ACTIVITY.G1_TRADE_ACTIVITY_ID%type,
		p_return_detail_cursor OUT SYS_REFCURSOR,
		p_status OUT VARCHAR2,
		p_error_msg OUT VARCHAR2
	);
	PROCEDURE FILL_AUTO_RETURN_ERROR_RST(p_return_detail_cursor OUT SYS_REFCURSOR);
	PROCEDURE GET_RTACCA_MSG_CONTENT(
		p_return_detail_id IN NUMBER,
		p_g1_return_lender_accept_id IN NUMBER,
		p_update_reason OUT VARCHAR2,
		p_narrative OUT VARCHAR2,
		p_equilendReturnSeqNbr OUT NUMBER,
		p_equilendReturnId OUT NUMBER,
		p_lenderLegalEntityId OUT NUMBER,
		p_legalEntityId OUT NUMBER,
		p_corpId OUT NUMBER,
		p_recipient_corpId OUT NUMBER,
		p_internalRefId OUT VARCHAR2,
		p_status OUT VARCHAR2,
		p_error_msg OUT VARCHAR2
	);
	PROCEDURE GET_RTCBIN_MSG_CONTENT(
		p_return_detail_id IN NUMBER,
		p_corpId OUT NUMBER,
		p_recipient_corpId OUT NUMBER,
		p_lenderLegalEntityId OUT NUMBER,
		p_legalEntityId OUT NUMBER,
		p_secId OUT VARCHAR2,
		p_secIdType OUT VARCHAR2,
		p_collType OUT VARCHAR2,
		p_rate OUT NUMBER,
		p_fee OUT NUMBER,
		p_reclaim_rate OUT NUMBER,
		p_tradeDate OUT NUMBER,
		p_settlementDate OUT NUMBER,
		p_unitQty OUT NUMBER,
		p_internalRefId OUT VARCHAR2,
		p_currency OUT VARCHAR2,
		p_term_date OUT NUMBER,
		p_update_comment OUT VARCHAR2,
		p_status OUT VARCHAR2,
		p_error_msg OUT VARCHAR2
	);
	PROCEDURE GET_BROKER_CONFIG(
		p_broker_cd IN VARCHAR2,
		p_trade_country_cd IN VARCHAR2,
		p_auto_return_flag OUT VARCHAR2,
		p_dividend_rate_tag_flag OUT VARCHAR2,
		p_collateral_type_tag_flag OUT VARCHAR2,
		p_collateral_currency_tag_flag OUT VARCHAR2,
		p_fee_tag_flag OUT VARCHAR2,
		p_rate_tag_flag OUT VARCHAR2
	);
	PROCEDURE GET_BROKER_CONFIG(
		p_return_detail_id IN NUMBER,
		p_auto_return_flag OUT VARCHAR2,
		p_dividend_rate_tag_flag OUT VARCHAR2,
		p_collateral_type_tag_flag OUT VARCHAR2,
		p_collateral_currency_tag_flag OUT VARCHAR2,
		p_fee_tag_flag OUT VARCHAR2,
		p_rate_tag_flag OUT VARCHAR2
	);
	FUNCTION GET_LOG_NUMBER(p_legal_entity_id IN VARCHAR2,
							p_area_id IN VARCHAR2,
							p_bargain_ref IN VARCHAR2)RETURN VARCHAR2;
END GEC_AUTO_RETURN_PKG;
/

create or replace
PACKAGE BODY GEC_AUTO_RETURN_PKG AS
	PROCEDURE GENEATE_G1_RETURN_DETAIL(
		p_user_id IN VARCHAR2,
		p_g1_trade_activity_id IN GEC_G1_TRADE_ACTIVITY.G1_TRADE_ACTIVITY_ID%type,
		p_return_detail_cursor OUT SYS_REFCURSOR,
		p_status OUT VARCHAR2,
		p_error_msg OUT VARCHAR2
	)
	IS
		var_asset_id NUMBER(38); 
		var_broker_cd VARCHAR2(6);
		var_fee NUMBER(9,6);
		var_rate NUMBER(9,6);
		var_g1_return_detail_id NUMBER(38); 
		var_coll_type VARCHAR2(3);
		var_eql_eligible_flag GEC_G1_RETURN_DETAIL.EQL_ELIGIBLE_FLAG%TYPE;
		var_auto_return_flag GEC_BROKER_RETURN_RULE.AUTO_RETURN_FLAG%type;
		var_trade_country GEC_ASSET.TRADE_COUNTRY_CD%type;
		var_div_tag_flag GEC_BROKER_RETURN_RULE.DIVIDEND_RATE_TAG%type;
		var_coll_type_flag GEC_BROKER_RETURN_RULE.COLLATERAL_TYPE_TAG%type;
		var_coll_currency_flag GEC_BROKER_RETURN_RULE.COLLATERAL_CURRENCY_TAG%type;
		var_fee_tag_flag GEC_BROKER_RETURN_RULE.FEE_TAG%type;
		var_rate_tag_flag GEC_BROKER_RETURN_RULE.RATE_TAG%type;
		CURSOR gec_g1_trade_activity IS
			SELECT AREA_ID,SFP_LEAGAL_ENTITY_ID,BGNREF,CPTY,STOCK,CASH,TRADE,SSDT,ACT_TYPE,
	  			   LNRATE,DIV_AGE_6DP,BL,ACT_PRC,ACT_VALUE,USR_FLD2,INS_REQD,COLL_FLG,LNCUR,ACT_QTY,TERMDT,USR_FLD1,DIV_DOM_6DP,DIV_OSEAS_6DP
			FROM GEC_G1_TRADE_ACTIVITY
			WHERE G1_TRADE_ACTIVITY_ID=p_g1_trade_activity_id;
	BEGIN
		FOR g_g_t_a IN gec_g1_trade_activity
		LOOP
			-- get asset ID by stock
			BEGIN
			 	SELECT ASSET_ID,TRADE_COUNTRY_CD INTO var_asset_id,var_trade_country
			 	FROM GEC_ASSET
			 	WHERE CUSIP=g_g_t_a.STOCK;
		 	EXCEPTION
		 	WHEN NO_DATA_FOUND THEN
		 		p_status:='E';
				p_error_msg:='no asset found base on cusip '|| g_g_t_a.STOCK;
				FILL_AUTO_RETURN_ERROR_RST(p_return_detail_cursor);
				RETURN;
		 	WHEN TOO_MANY_ROWS THEN
		 		p_status:='E';
				p_error_msg:='duplicate asset found base on cusip ' || g_g_t_a.STOCK;
				FILL_AUTO_RETURN_ERROR_RST(p_return_detail_cursor);
				RETURN;
		 	END;
		 	-- get broker cd
			BEGIN
			 	SELECT BROKER_CD INTO var_broker_cd
			 	FROM GEC_BROKER
			 	WHERE BROKER_CD=g_g_t_a.CPTY AND BORROW_REQUEST_TYPE<>GEC_CONSTANTS_PKG.C_SB;
		 	EXCEPTION
		 	WHEN NO_DATA_FOUND THEN
		 		BEGIN
				 	SELECT DML_SB_BROKER INTO var_broker_cd
				 	FROM GEC_FUND GF,GEC_G1_BOOKING GGB
				 	WHERE GGB.FUND_CD=GF.FUND_CD AND GGB.TRANSACTION_CD=GEC_CONSTANTS_PKG.C_G1B AND GGB.POS_TYPE=GEC_CONSTANTS_PKG.C_SB AND GGB.counterparty_cd=g_g_t_a.CPTY;
			 	EXCEPTION
			 	WHEN NO_DATA_FOUND THEN
			 		p_status:='CE';
					p_error_msg:='Counterparty ' ||g_g_t_a.CPTY || ' can not be found in GEC';
					FILL_AUTO_RETURN_ERROR_RST(p_return_detail_cursor);
					RETURN;
			 	WHEN TOO_MANY_ROWS THEN
			 		p_status:='E';
					p_error_msg:='duplicate Counterparty ' ||g_g_t_a.CPTY ||' are found in GEC';
					FILL_AUTO_RETURN_ERROR_RST(p_return_detail_cursor);
					RETURN;
			 	END;
		 	END;
		 		--check eligible flag
			GET_BROKER_CONFIG(var_broker_cd,var_trade_country,var_auto_return_flag,var_div_tag_flag,var_coll_type_flag,var_coll_currency_flag,var_fee_tag_flag,var_rate_tag_flag);
			var_eql_eligible_flag:='N';
			IF var_auto_return_flag='Y' AND (g_g_t_a.INS_REQD is not null and g_g_t_a.INS_REQD='Y') AND (g_g_t_a.USR_FLD2 is null or g_g_t_a.USR_FLD2<>'N') AND g_g_t_a.BL='B' AND g_g_t_a.COLL_FLG='T' THEN
				var_eql_eligible_flag:='Y';
			END IF;
		 	-- get fee and rate
		 	IF g_g_t_a.CASH='C' THEN
		 		var_rate:=g_g_t_a.LNRATE;
		 	END IF;
		 	IF g_g_t_a.CASH='N' OR g_g_t_a.CASH='P' THEN
		 		var_fee:=g_g_t_a.LNRATE;
		 	END IF;
		 	
		 	IF g_g_t_a.CASH='C'THEN
				var_coll_type:='CA';
			ELSIF g_g_t_a.CASH='P'THEN
				var_coll_type:='CP';
			ELSIF g_g_t_a.CASH='N' THEN
				var_coll_type:='NC';
			END IF;
		 	-- insert GEC_G1_RETURN_DETAIL
			SELECT gec_g1_return_detail_id_seq.NEXTVAL INTO var_g1_return_detail_id FROM DUAL;
		 	INSERT INTO GEC_G1_RETURN_DETAIL(G1_RETURN_DETAIL_ID,
											  ASSET_ID,
											  AREA_ID,
											  LEGAL_ENTITY_CD,
											  BARGAIN_REF,
											  CPTY,
											  BROKER_CD,
											  QTY,
											  RATE,
											  FEE,
											  RECLAIM_RATE,
											  SETTLE_DATE,
											  TRADE_DATE,
											  TERM_DATE,
											  TRANSACTION_TYPE,
											  G1_STATUS,
											  G1_STATUS_MSG,
											  GEC_STATUS,
											  GEC_STATUS_MSG,
											  EQL_STATUS,
											  EQL_STATUS_MSG,
											  EQL_COLLATERAL_TYPE,
											  COLLATERAL_CURRENCY_CD,
											  CREATED_AT,
											  CREATED_BY,
											  UPDATED_AT,
											  UPDATED_BY,
											  RETURN_PRICE,
											  RETURN_VALUE,
											  EQL_ELIGIBLE_FLAG,
											  EQL_RETURN_ID,
											  EXPECTED_RETURN_DATE,
											  DOMESTIC_TAX_PERCENTAGE,
											  OVERSEAS_TAX_PERCENTAGE)
									  VALUES(var_g1_return_detail_id,
									  		 var_asset_id,
									  		 g_g_t_a.AREA_ID,
									  		 g_g_t_a.SFP_LEAGAL_ENTITY_ID,
									  		 g_g_t_a.BGNREF,
									  		 g_g_t_a.CPTY,
									  		 var_broker_cd,
									  		 g_g_t_a.ACT_QTY,
									  		 var_rate,
									  		 var_fee,
									  		 g_g_t_a.DIV_AGE_6DP/100,
									  		 g_g_t_a.SSDT,
									  		 g_g_t_a.TRADE,
									  		 g_g_t_a.TERMDT,
									  		 g_g_t_a.BL,
									  		 g_g_t_a.ACT_TYPE,
									  		 g_g_t_a.ACT_TYPE,
									  		 'P',
									  		 'Pending',
									  		 NULL,
									  		 NULL,
									  		 var_coll_type,
									  		 g_g_t_a.LNCUR,
									  		 SYSDATE,
									  		 p_user_id,
									  		 SYSDATE,
									  		 p_user_id,
									  		 g_g_t_a.ACT_PRC,
									  		 g_g_t_a.ACT_VALUE,
									  		 var_eql_eligible_flag,
									  		 NULL,
									  		 g_g_t_a.USR_FLD1,
									  		 g_g_t_a.DIV_DOM_6DP/100,
									  		 g_g_t_a.DIV_OSEAS_6DP/100);
			INSERT INTO GEC_G1_TRADE_ACT_RTN(G1_TRADE_ACTIVITY_ID,
	  										 G1_RETURN_DETAIL_ID)
	  										 VALUES
	  										 (
	  										 p_g1_trade_activity_id,
	  										 var_g1_return_detail_id
	  										 );
		END LOOP;
		
		OPEN p_return_detail_cursor FOR
			SELECT G1_RETURN_DETAIL_ID,ASSET_ID,AREA_ID,LEGAL_ENTITY_CD,BARGAIN_REF,CPTY,BROKER_CD,RATE,FEE,RECLAIM_RATE*100 as RECLAIM_RATE,SETTLE_DATE,TRADE_DATE,TRANSACTION_TYPE,
				   G1_STATUS,G1_STATUS_MSG,GEC_STATUS,GEC_STATUS_MSG,EQL_STATUS,EQL_STATUS_MSG,ACCEPT_IN_LOTS_FLAG, EQL_COLLATERAL_TYPE,
				   RETURN_PRICE,RETURN_VALUE,EQL_ELIGIBLE_FLAG,EQL_RETURN_ID,QTY,UPDATED_AT,UPDATED_BY,EQL_UPDATE_REASON_CD,EQL_UPDATE_REASON_COMMENT,COLLATERAL_CURRENCY_CD,OLD_RETURN_PRICE,OLD_RETURN_VALUE,
				   EXPECTED_RETURN_DATE,DOMESTIC_TAX_PERCENTAGE*100 as DOMESTIC_TAX_PERCENTAGE,OVERSEAS_TAX_PERCENTAGE*100 as OVERSEAS_TAX_PERCENTAGE,null as LEND_SETTLE_INSTR_ID,NULL AS DESCRIPTION,null as CUSIP,null as ISIN,null as SEDOL,null as QUIK,null as TICKER,null as TRADE_COUNTRY_CD,
				   null as  req_st,null as  resp_st, null as  req_tr, null as  resp_tr
			FROM
				GEC_G1_RETURN_DETAIL
			WHERE
				G1_RETURN_DETAIL_ID=var_g1_return_detail_id;

	END GENEATE_G1_RETURN_DETAIL;
	PROCEDURE FILL_AUTO_RETURN_ERROR_RST(p_return_detail_cursor OUT SYS_REFCURSOR)
	IS
	BEGIN		
		OPEN p_return_detail_cursor FOR
				SELECT NULL AS G1_RETURN_DETAIL_ID,NULL AS ASSET_ID,NULL AS AREA_ID,NULL AS LEGAL_ENTITY_CD,NULL AS BARGAIN_REF,NULL AS CPTY,NULL AS BROKER_CD,
				NULL AS RATE,NULL AS FEE,NULL AS RECLAIM_RATE,NULL AS SETTLE_DATE,NULL AS TRADE_DATE,NULL AS TRANSACTION_TYPE,
				NULL AS G1_STATUS,NULL AS G1_STATUS_MSG,NULL AS GEC_STATUS,NULL AS GEC_STATUS_MSG,NULL AS EQL_STATUS,NULL AS EQL_STATUS_MSG,
				NULL AS ACCEPT_IN_LOTS_FLAG,NULL AS EQL_COLLATERAL_TYPE,
				NULL AS RETURN_PRICE,NULL AS RETURN_VALUE,NULL AS EQL_ELIGIBLE_FLAG,NULL AS EQL_RETURN_ID,NULL AS QTY,NULL AS UPDATED_AT,
				NULL AS UPDATED_BY,NULL AS EQL_UPDATE_REASON_CD,NULL AS EQL_UPDATE_REASON_COMMENT,NULL AS COLLATERAL_CURRENCY_CD,NULL AS OLD_RETURN_VALUE, NULL AS OLD_RETURN_PRICE,
				NULL AS EXPECTED_RETURN_DATE,NULL AS DOMESTIC_TAX_PERCENTAGE,NULL AS OVERSEAS_TAX_PERCENTAGE,NULL AS LEND_SETTLE_INSTR_ID,NULL AS DESCRIPTION,null as CUSIP,null as ISIN,null as SEDOL,null as QUIK,null as TICKER,null as TRADE_COUNTRY_CD,
				null as  req_st,null as  resp_st, null as  req_tr, null as  resp_tr
				FROM DUAL;
	END FILL_AUTO_RETURN_ERROR_RST;
	
	PROCEDURE GET_RTCBIN_MSG_CONTENT(
		p_return_detail_id IN NUMBER,
		p_corpId OUT NUMBER,
		p_recipient_corpId OUT NUMBER,
		p_lenderLegalEntityId OUT NUMBER,
		p_legalEntityId OUT NUMBER,
		p_secId OUT VARCHAR2,
		p_secIdType OUT VARCHAR2,
		p_collType OUT VARCHAR2,
		p_rate OUT NUMBER,
		p_fee OUT NUMBER,
		p_reclaim_rate OUT NUMBER,
		p_tradeDate OUT NUMBER,
		p_settlementDate OUT NUMBER,
		p_unitQty OUT NUMBER,
		p_internalRefId OUT VARCHAR2,
		p_currency OUT VARCHAR2,
		p_term_date OUT NUMBER,
		p_update_comment OUT VARCHAR2,
		p_status OUT VARCHAR2,
		p_error_msg OUT VARCHAR2
	)
	IS
		var_agency	VARCHAR2(1);
		var_auto_return_flag GEC_BROKER_RETURN_RULE.AUTO_RETURN_FLAG%type;
		var_div_tag_flag GEC_BROKER_RETURN_RULE.DIVIDEND_RATE_TAG%type;
		var_coll_type_flag GEC_BROKER_RETURN_RULE.COLLATERAL_TYPE_TAG%type;
		var_coll_currency_flag GEC_BROKER_RETURN_RULE.COLLATERAL_CURRENCY_TAG%type;
		var_fee_tag_flag GEC_BROKER_RETURN_RULE.FEE_TAG%type;
		var_rate_tag_flag GEC_BROKER_RETURN_RULE.RATE_TAG%type;
		CURSOR gec_g1_return_detail IS
			SELECT EQL_COLLATERAL_TYPE,ASSET_ID,BROKER_CD,RATE,FEE,RECLAIM_RATE,TRADE_DATE,SETTLE_DATE,QTY,LEGAL_ENTITY_CD,AREA_ID,BARGAIN_REF,CPTY,COLLATERAL_CURRENCY_CD,TERM_DATE
			FROM GEC_G1_RETURN_DETAIL
			WHERE G1_RETURN_DETAIL_ID=p_return_detail_id;
	BEGIN
		FOR g_g_r_d IN gec_g1_return_detail
		LOOP
			GET_BROKER_CONFIG(p_return_detail_id,var_auto_return_flag,var_div_tag_flag,var_coll_type_flag,var_coll_currency_flag,var_fee_tag_flag,var_rate_tag_flag);
			BEGIN
				 	SELECT AGENCY_FLAG,LEGAL_ENTITY_ID,CORP_ID INTO var_agency,p_legalEntityId,p_corpId
				 	FROM GEC_BROKER
				 	WHERE BROKER_CD=g_g_r_d.BROKER_CD;
				 	p_lenderLegalEntityId:=8;
				 	p_recipient_corpId:=2;
				 	IF var_agency='N' THEN
				 		p_lenderLegalEntityId:=p_legalEntityId;
				 		p_recipient_corpId:=p_corpId;
				 		IF upper(g_g_r_d.LEGAL_ENTITY_CD)='SSBT' THEN
				 			BEGIN
				 				SELECT LEGAL_ENTITY_ID,CORP_ID INTO p_legalEntityId,p_corpId
				 				FROM GEC_BROKER
				 				WHERE BROKER_CD='0997';
				 				EXCEPTION
						 		WHEN NO_DATA_FOUND THEN
						 			p_status:='E';
									p_error_msg:='can not find broker 0997';
									RETURN;
				 			END;
				 		ELSIF upper(g_g_r_d.LEGAL_ENTITY_CD)='GMBH' THEN
				 			BEGIN
				 				SELECT LEGAL_ENTITY_ID,CORP_ID INTO p_legalEntityId,p_corpId
				 				FROM GEC_BROKER
				 				WHERE BROKER_CD='G0997';
				 				EXCEPTION
						 		WHEN NO_DATA_FOUND THEN
						 			p_status:='E';
									p_error_msg:='can not find broker G0997';
									RETURN;
				 			END;
				 		ELSE
				 			p_status:='E';
							p_error_msg:='can not find legal entity id base on cpty '||g_g_r_d.cpty;
							RETURN;
				 		END IF;
				 	END IF;
			 		EXCEPTION
			 		WHEN NO_DATA_FOUND THEN
			 			p_status:='E';
						p_error_msg:='can not find broker '||g_g_r_d.BROKER_CD;
						RETURN;
			END;
			
			BEGIN
				SELECT DECODE(TRADE_COUNTRY_CD,'US',CUSIP,NVL(SEDOL,NVL(ISIN,CUSIP))),DECODE(TRADE_COUNTRY_CD,'US','C',DECODE(SEDOL,NULL,DECODE(ISIN,NULL,'C','I'),'S')) INTO p_secId,p_secIdType
				FROM GEC_ASSET
				WHERE ASSET_ID=g_g_r_d.ASSET_ID;
			END;
			IF var_coll_currency_flag='Y'THEN
				p_currency:=g_g_r_d.COLLATERAL_CURRENCY_CD;
			ELSE
				p_currency:=NULL;
			END IF;
			IF var_coll_type_flag='Y' THEN
				p_collType:=g_g_r_d.EQL_COLLATERAL_TYPE;
			ELSE
				p_collType:=NULL;
			END IF;
			IF var_fee_tag_flag='Y' THEN
				p_fee:=g_g_r_d.FEE;
			ELSE
				p_fee:=NULL;
			END IF;
			IF var_rate_tag_flag='Y' THEN
				p_rate:=g_g_r_d.RATE;
			ELSE
				p_rate:=NULL;
			END IF;
			IF var_div_tag_flag='Y' THEN
				p_reclaim_rate:=g_g_r_d.RECLAIM_RATE*100;
			ELSE
				p_reclaim_rate:=NULL;
			END IF;
			
			IF p_reclaim_rate=0 THEN
				p_reclaim_rate:=NULL;
			END IF;
			IF p_recipient_corpId IS NULL THEN
				p_status:='E';
				p_error_msg:='corp Id is blank';
			END IF;
			IF p_corpId IS NULL THEN
				p_status:='E';
				p_error_msg:='corp Id is blank';
			END IF;
			IF p_legalEntityId IS NULL THEN
				p_status:='E';
				p_error_msg:='legal Entity Id is blank';
			END IF;
			IF p_lenderLegalEntityId IS NULL THEN
				p_status:='E';
				p_error_msg:='legal Entity Id is blank';
			END IF;
			p_term_date:=g_g_r_d.TERM_DATE;
			p_tradeDate:=g_g_r_d.TRADE_DATE;
			p_settlementDate:=g_g_r_d.SETTLE_DATE;
			p_unitQty:=g_g_r_d.QTY;
			p_internalRefId:=GET_LOG_NUMBER( g_g_r_d.LEGAL_ENTITY_CD, g_g_r_d.AREA_ID,g_g_r_d.BARGAIN_REF);
		END LOOP;
	END GET_RTCBIN_MSG_CONTENT;
	
	PROCEDURE GET_RTACCA_MSG_CONTENT(
		p_return_detail_id IN NUMBER,
		p_g1_return_lender_accept_id IN NUMBER,
		p_update_reason OUT VARCHAR2,
		p_narrative OUT VARCHAR2,
		p_equilendReturnSeqNbr OUT NUMBER,
		p_equilendReturnId OUT NUMBER,
		p_lenderLegalEntityId OUT NUMBER,
		p_legalEntityId OUT NUMBER,
		p_corpId OUT NUMBER,
		p_recipient_corpId OUT NUMBER,
		p_internalRefId OUT VARCHAR2,
		p_status OUT VARCHAR2,
		p_error_msg OUT VARCHAR2
	)
	IS
		var_agency            VARCHAR2(1);
		CURSOR gec_g1_return_detail IS
			SELECT BROKER_CD,EQL_RETURN_ID,EQL_UPDATE_REASON_CD,EQL_UPDATE_REASON_COMMENT,LEGAL_ENTITY_CD,AREA_ID,BARGAIN_REF,cpty
			FROM GEC_G1_RETURN_DETAIL
			WHERE G1_RETURN_DETAIL_ID=p_return_detail_id;
	BEGIN
		FOR g_g_r_d IN gec_g1_return_detail
		LOOP
			p_internalRefId:=GET_LOG_NUMBER( g_g_r_d.LEGAL_ENTITY_CD, g_g_r_d.AREA_ID,g_g_r_d.BARGAIN_REF);
			BEGIN
				IF p_g1_return_lender_accept_id IS NULL THEN
					p_equilendReturnId:=g_g_r_d.EQL_RETURN_ID;
					p_update_reason:=g_g_r_d.EQL_UPDATE_REASON_CD;
					p_narrative:=g_g_r_d.EQL_UPDATE_REASON_COMMENT;
					BEGIN
					SELECT max(EQL_RETURN_SEQ_NBR) INTO p_equilendReturnSeqNbr
					FROM 
					GEC_EQL_MSG_RTN_ACTIVITY
	        		WHERE G1_RETURN_DETAIL_ID=p_return_detail_id AND EQL_RETURN_ID=g_g_r_d.EQL_RETURN_ID;
					EXCEPTION 
	        		WHEN NO_DATA_FOUND THEN
						p_status:='E';
						p_error_msg:='equilend return seq number is blank';
						RETURN;
					END;
				ELSE
					BEGIN
					SELECT EQL_UPDATE_REASON_CD,EQL_UPDATE_REASON_COMMENT,EQL_RETURN_ID INTO p_update_reason,p_narrative,p_equilendReturnId
					FROM
					GEC_G1_RETURN_LENDER_ACCEPT
					WHERE
					G1_RETURN_LENDER_ACCEPT_ID=p_g1_return_lender_accept_id;
					END;
					BEGIN
					SELECT max(EQL_RETURN_SEQ_NBR) INTO p_equilendReturnSeqNbr
					FROM 
					GEC_EQL_MSG_RTN_ACTIVITY
	        		WHERE G1_RETURN_DETAIL_ID=p_return_detail_id AND EQL_RETURN_ID=p_equilendReturnId;
					EXCEPTION 
	        		WHEN NO_DATA_FOUND THEN
						p_status:='E';
						p_error_msg:='equilend return seq number is blank';
						RETURN;
					END;
				END IF;
				
			END;
			
			BEGIN
				 	SELECT AGENCY_FLAG,LEGAL_ENTITY_ID,CORP_ID INTO var_agency,p_legalEntityId,p_corpId
				 	FROM GEC_BROKER
				 	WHERE BROKER_CD=g_g_r_d.BROKER_CD;
				 	p_lenderLegalEntityId:=8;
				 	p_recipient_corpId:=2;
				 	IF var_agency='N' THEN
				 		p_lenderLegalEntityId:=p_legalEntityId;
				 		p_recipient_corpId:=p_corpId;
				 		IF upper(g_g_r_d.LEGAL_ENTITY_CD)='SSBT' THEN
				 			BEGIN
				 				SELECT LEGAL_ENTITY_ID,CORP_ID INTO p_legalEntityId,p_corpId
				 				FROM GEC_BROKER
				 				WHERE BROKER_CD='0997';
				 				EXCEPTION
						 		WHEN NO_DATA_FOUND THEN
						 			p_status:='E';
									p_error_msg:='can not find broker 0997';
									RETURN;
				 			END;
				 		ELSIF upper(g_g_r_d.LEGAL_ENTITY_CD)='GMBH' THEN
				 			BEGIN
				 				SELECT LEGAL_ENTITY_ID,CORP_ID INTO p_legalEntityId,p_corpId
				 				FROM GEC_BROKER
				 				WHERE BROKER_CD='G0997';
				 				EXCEPTION
						 		WHEN NO_DATA_FOUND THEN
						 			p_status:='E';
									p_error_msg:='can not find broker G0997';
									RETURN;
				 			END;
				 		ELSE
				 			RETURN;
				 		END IF;
				 	END IF;
			 		EXCEPTION
			 		WHEN NO_DATA_FOUND THEN
			 			p_status:='E';
						p_error_msg:='can not find legal entity id base on cpty '||g_g_r_d.cpty;
						RETURN;
			 		RETURN;
			END;
			IF p_corpId IS NULL THEN
				p_status:='E';
				p_error_msg:='corp Id is blank';
			END IF;
			IF p_recipient_corpId IS NULL THEN
				p_status:='E';
				p_error_msg:='corp Id is blank';
			END IF;
			IF p_legalEntityId IS NULL THEN
				p_status:='E';
				p_error_msg:='legal Entity Id is blank';
			END IF;
			IF p_lenderLegalEntityId IS NULL THEN
				p_status:='E';
				p_error_msg:='legal Entity Id is blank';
			END IF;
			IF p_equilendReturnId IS NULL THEN 
				p_status:='E';
				p_error_msg:='equilend return Id is blank';
			END IF;
			IF p_equilendReturnSeqNbr IS NULL THEN 
				p_status:='E';
				p_error_msg:='equilend return seq number is blank';
			END IF;
		END LOOP;
		
		
	END GET_RTACCA_MSG_CONTENT;
	PROCEDURE GET_BROKER_CONFIG(
		p_broker_cd IN VARCHAR2,
		p_trade_country_cd IN VARCHAR2,
		p_auto_return_flag OUT VARCHAR2,
		p_dividend_rate_tag_flag OUT VARCHAR2,
		p_collateral_type_tag_flag OUT VARCHAR2,
		p_collateral_currency_tag_flag OUT VARCHAR2,
		p_fee_tag_flag OUT VARCHAR2,
		p_rate_tag_flag OUT VARCHAR2
	)
	IS
		var_auto_return_flag GEC_BROKER.AUTO_RETURN_FLAG%type;
	BEGIN
		BEGIN
			SELECT AUTO_RETURN_FLAG INTO var_auto_return_flag
			FROM
				GEC_BROKER
			WHERE
				BROKER_CD=p_broker_cd;
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
			RETURN;
		END;
		IF var_auto_return_flag='Y' THEN
			BEGIN
				SELECT AUTO_RETURN_FLAG,DIVIDEND_RATE_TAG,COLLATERAL_TYPE_TAG,COLLATERAL_CURRENCY_TAG,FEE_TAG,RATE_TAG
				INTO  p_auto_return_flag,p_dividend_rate_tag_flag,p_collateral_type_tag_flag,p_collateral_currency_tag_flag,p_fee_tag_flag,p_rate_tag_flag
				FROM
					GEC_BROKER_RETURN_RULE
				WHERE
					BROKER_CD=p_broker_cd AND TRADE_COUNTRY_CD=p_trade_country_cd;
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
					BEGIN
						SELECT AUTO_RETURN_FLAG,DIVIDEND_RATE_TAG,COLLATERAL_TYPE_TAG,COLLATERAL_CURRENCY_TAG,FEE_TAG,RATE_TAG
						INTO  p_auto_return_flag,p_dividend_rate_tag_flag,p_collateral_type_tag_flag,p_collateral_currency_tag_flag,p_fee_tag_flag,p_rate_tag_flag
						FROM
							GEC_BROKER_RETURN_RULE
						WHERE
							BROKER_CD=p_broker_cd AND TRADE_COUNTRY_CD='ALL';
						EXCEPTION
						WHEN NO_DATA_FOUND THEN
							BEGIN
								SELECT AUTO_RETURN_FLAG,DIVIDEND_RATE_TAG,COLLATERAL_TYPE_TAG,COLLATERAL_CURRENCY_TAG,FEE_TAG,RATE_TAG
									INTO p_auto_return_flag,p_dividend_rate_tag_flag,p_collateral_type_tag_flag,p_collateral_currency_tag_flag,p_fee_tag_flag,p_rate_tag_flag
								FROM
									GEC_BROKER_RETURN_RULE
								WHERE
									BROKER_CD='ALL' AND TRADE_COUNTRY_CD='ALL';	
							END;
					END;
			END;
		ELSE
			p_auto_return_flag:='N';
		END IF;
	END;
	
	PROCEDURE GET_BROKER_CONFIG(
		p_return_detail_id IN NUMBER,
		p_auto_return_flag OUT VARCHAR2,
		p_dividend_rate_tag_flag OUT VARCHAR2,
		p_collateral_type_tag_flag OUT VARCHAR2,
		p_collateral_currency_tag_flag OUT VARCHAR2,
		p_fee_tag_flag OUT VARCHAR2,
		p_rate_tag_flag OUT VARCHAR2
	)
	IS
		
		CURSOR gec_g1_return_detail IS
			SELECT GGRD.BROKER_CD,GA.TRADE_COUNTRY_CD
			FROM GEC_G1_RETURN_DETAIL GGRD
			LEFT JOIN GEC_ASSET GA
			ON GGRD.ASSET_ID=GA.ASSET_ID
			WHERE GGRD.G1_RETURN_DETAIL_ID=p_return_detail_id;
	BEGIN
		FOR g_g_r_d IN gec_g1_return_detail
		LOOP
			GET_BROKER_CONFIG(g_g_r_d.BROKER_CD,g_g_r_d.TRADE_COUNTRY_CD,p_auto_return_flag,p_dividend_rate_tag_flag,p_collateral_type_tag_flag,p_collateral_currency_tag_flag,p_fee_tag_flag,p_rate_tag_flag);
		END LOOP;
	END GET_BROKER_CONFIG;
	FUNCTION GET_LOG_NUMBER(p_legal_entity_id		IN VARCHAR2,
							p_area_id IN VARCHAR2,
							p_bargain_ref IN VARCHAR2) RETURN VARCHAR2
	IS
		v_log_number   GEC_EQL_MSG_RTN_ACTIVITY.LOG_NUMBER%TYPE;
	BEGIN
		
		SELECT p_legal_entity_id || '_' || p_area_id || '_' ||p_bargain_ref || '_' || LPAD( GEC_UTILS_PKG.RIGHT_ ( GEC_Log_Number_SEQ.NEXTVAL , 11), 11, '0')
			   INTO v_log_number from dual;
		
		RETURN v_log_number;
	END GET_LOG_NUMBER;
END GEC_AUTO_RETURN_PKG;
/