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
-- Date            Programmer                Note
-- ------------    --------------------      ----------------------------
-- Feb 13, 2012    Hu, Gaoxiang              initial
-------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE GEC_AUTOBORROW_PKG AS
	PROCEDURE VALIDATE_ABSB_MESSAGE(p_corp_id IN NUMBER,  p_autoborrow_batch_id IN VARCHAR2, p_request_id OUT NUMBER, p_status OUT VARCHAR2);
	PROCEDURE UPDATE_STATUS(p_borrow_request_Id IN NUMBER, p_date IN DATE, p_user_id IN VARCHAR2, p_allocation_flag IN VARCHAR2, p_borrow_request_cursor OUT SYS_REFCURSOR);
	PROCEDURE VALIDATE_RESPONSE(p_corp_id IN NUMBER, p_autoborrow_batch_id IN VARCHAR2, p_aggregated_id IN NUMBER, p_request_id OUT NUMBER, p_status OUT VARCHAR2);
END GEC_AUTOBORROW_PKG;
/

CREATE OR REPLACE PACKAGE BODY GEC_AUTOBORROW_PKG
AS
		
	PROCEDURE UPDATE_STATUS(p_borrow_request_Id IN NUMBER, p_date IN DATE, p_user_id IN VARCHAR2, p_allocation_flag IN VARCHAR2, p_borrow_request_cursor OUT SYS_REFCURSOR)
	IS
		v_status VARCHAR(1);
		v_order_status VARCHAR(2);
		v_order_status_msg GEC_BORROW_ORDER.STATUS_MSG%type;
		v_shtt_flag VARCHAR(1);
		v_reject_flag VARCHAR(1);
		v_abcaco_flag VARCHAR(1);
		v_borrow_order_id GEC_BORROW_ORDER.BORROW_ORDER_ID%type;
		v_shtt_count NUMBER(10);
		v_abre_count NUMBER(10);
		v_borrow_request_type GEC_BORROW_REQUEST.BORROW_REQUEST_TYPE%type;
		
		CURSOR v_orders IS
			SELECT  bo.BORROW_ORDER_ID
			FROM GEC_BORROW_REQUEST br, GEC_BORROW_ORDER bo
			WHERE br.BORROW_REQUEST_ID = bo.BORROW_REQUEST_ID AND
				  br.BORROW_REQUEST_ID = p_borrow_request_Id AND 
				  br.STATUS IN (GEC_CONSTANTS_PKG.C_REQUEST_IN_FLIGHT, GEC_CONSTANTS_PKG.C_REQUEST_PENDING, GEC_CONSTANTS_PKG.C_REQUEST_PENDING_CANCEL) AND
				  bo.STATUS = GEC_CONSTANTS_PKG.C_ORDER_IN_FLIGHT 
			ORDER BY bo.BORROW_ORDER_ID;
		
		CURSOR v_shtt_messages IS
			SELECT DISTINCT em.MESSAGE_TYPE, em.MESSAGE_SUB_TYPE 
			FROM GEC_BORROW_ORDER bo, GEC_EQL_MSG_BRW_ORDER mo, GEC_EQUILEND_MESSAGE em
			WHERE mo.EQUILEND_MESSAGE_ID = em.EQUILEND_MESSAGE_ID AND
				  (em.STATUS = 'N' OR em.STATUS = 'S') AND
				  em.IN_OUT = 'I' AND
				  mo.BORROW_ORDER_ID = v_borrow_order_id AND
				  em.MESSAGE_TYPE = GEC_CONSTANTS_PKG.C_MESSAGE_TYPE_SHTT AND
				  em.MESSAGE_SUB_TYPE = GEC_CONSTANTS_PKG.C_MESSAGE_SUBTYPE_ABNO;

		CURSOR v_abre_messages IS
			SELECT DISTINCT em.MESSAGE_TYPE, em.MESSAGE_SUB_TYPE 
			FROM GEC_BORROW_ORDER bo, GEC_EQL_MSG_BRW_ORDER mo, GEC_EQUILEND_MESSAGE em
			WHERE mo.EQUILEND_MESSAGE_ID = em.EQUILEND_MESSAGE_ID AND
				  (em.STATUS = 'N' OR em.STATUS = 'S') AND
				  em.IN_OUT = 'I' AND
				  mo.BORROW_ORDER_ID = v_borrow_order_id AND
				  em.MESSAGE_TYPE = GEC_CONSTANTS_PKG.C_MESSAGE_TYPE_ORAC AND
				  em.MESSAGE_SUB_TYPE = GEC_CONSTANTS_PKG.C_MESSAGE_SUBTYPE_ABRE;		
				  
		CURSOR v_abcaco_messages IS
			SELECT DISTINCT em.MESSAGE_TYPE, em.MESSAGE_SUB_TYPE 
			FROM GEC_BORROW_ORDER bo, GEC_EQL_MSG_BRW_ORDER mo, GEC_EQUILEND_MESSAGE em
			WHERE mo.EQUILEND_MESSAGE_ID = em.EQUILEND_MESSAGE_ID AND
				  (em.STATUS = 'N' OR em.STATUS = 'S') AND
				  em.IN_OUT = 'I' AND
				  mo.BORROW_ORDER_ID = v_borrow_order_id AND
				  em.MESSAGE_TYPE = GEC_CONSTANTS_PKG.C_MESSAGE_TYPE_ORAC AND
				  em.MESSAGE_SUB_TYPE = GEC_CONSTANTS_PKG.C_MESSAGE_SUBTYPE_ABCACO;					  	
		
		CURSOR v_canceled_trades IS
			SELECT o.STATUS FROM GEC_BORROW_ORDER o, GEC_BORROW_REQUEST r
			WHERE o.BORROW_REQUEST_ID = r.BORROW_REQUEST_ID AND
				  r.BORROW_REQUEST_ID = p_borrow_request_Id AND
				  r.status IN (GEC_CONSTANTS_PKG.C_REQUEST_IN_FLIGHT, GEC_CONSTANTS_PKG.C_REQUEST_PENDING, GEC_CONSTANTS_PKG.C_REQUEST_PENDING_CANCEL) AND
				  o.status IN (GEC_CONSTANTS_PKG.C_ORDER_CANCELLED, GEC_CONSTANTS_PKG.C_ORDER_PARTIALLY_CANCELLED);
				  
		CURSOR v_in_flight_orders IS
			SELECT o.IM_ORDER_ID, o.MATCHED_ID, o.TRANSACTION_CD FROM GEC_IM_ORDER o, GEC_BORROW_ORDER bo, GEC_BORROW_ORDER_DETAIL detail
			WHERE o.EXPORT_STATUS = 'I' AND 
				  detail.IM_ORDER_ID = o.IM_ORDER_ID AND
				  detail.BORROW_ORDER_ID = bo.BORROW_ORDER_ID AND
				  bo.BORROW_REQUEST_ID = p_borrow_request_Id;
			  
		CURSOR v_in_flight_fliptrades IS
			SELECT ft.FLIP_TRADE_ID FROM GEC_FLIP_TRADE ft, GEC_BORROW_ORDER bo, GEC_FLIP_TRADE_DETAIL detail
			WHERE ft.EXPORT_STATUS = 'I' AND 
				  detail.FLIP_TRADE_ID = ft.FLIP_TRADE_ID AND
				  detail.BORROW_ORDER_ID = bo.BORROW_ORDER_ID AND
				  bo.BORROW_REQUEST_ID = p_borrow_request_Id;			
	BEGIN	
		
		SELECT br.BORROW_REQUEST_TYPE INTO v_borrow_request_type
		FROM GEC_BORROW_REQUEST br
		WHERE br.BORROW_REQUEST_ID = p_borrow_request_Id;
		
		SELECT COUNT(sd.EQUILEND_MESSAGE_ID) INTO v_shtt_count 
		FROM GEC_BORROW_REQUEST br, GEC_BORROW_ORDER bo, GEC_SHTT_ABNO_MSG_DTL sd, GEC_EQL_MSG_BRW_ORDER mo, GEC_EQUILEND_MESSAGE em
		WHERE br.BORROW_REQUEST_ID = bo.BORROW_REQUEST_ID AND
			  bo.BORROW_ORDER_ID = mo.BORROW_ORDER_ID AND
			  mo.EQUILEND_MESSAGE_ID = sd.EQUILEND_MESSAGE_ID AND
			  sd.EQUILEND_MESSAGE_ID = em.EQUILEND_MESSAGE_ID AND
			  br.BORROW_REQUEST_ID = p_borrow_request_Id AND 
			  br.STATUS IN (GEC_CONSTANTS_PKG.C_REQUEST_IN_FLIGHT, GEC_CONSTANTS_PKG.C_REQUEST_PENDING, GEC_CONSTANTS_PKG.C_REQUEST_PENDING_CANCEL) AND
			  bo.STATUS = GEC_CONSTANTS_PKG.C_ORDER_IN_FLIGHT AND
			  (em.STATUS = 'N' OR em.STATUS = 'S');
			  
		SELECT COUNT(ad.EQUILEND_MESSAGE_ID) INTO v_abre_count 
		FROM GEC_BORROW_REQUEST br, GEC_BORROW_ORDER bo, GEC_ORAC_ABRE_MSG_DTL ad, GEC_EQL_MSG_BRW_ORDER mo, GEC_EQUILEND_MESSAGE em
		WHERE br.BORROW_REQUEST_ID = bo.BORROW_REQUEST_ID AND
			  bo.BORROW_ORDER_ID = mo.BORROW_ORDER_ID AND
			  mo.EQUILEND_MESSAGE_ID = ad.EQUILEND_MESSAGE_ID AND
			  ad.EQUILEND_MESSAGE_ID = em.EQUILEND_MESSAGE_ID AND
			  br.BORROW_REQUEST_ID = p_borrow_request_Id AND 
			  br.STATUS IN (GEC_CONSTANTS_PKG.C_REQUEST_IN_FLIGHT, GEC_CONSTANTS_PKG.C_REQUEST_PENDING, GEC_CONSTANTS_PKG.C_REQUEST_PENDING_CANCEL) AND
			  bo.STATUS = GEC_CONSTANTS_PKG.C_ORDER_IN_FLIGHT AND
			  (em.STATUS = 'N' OR em.STATUS = 'S'); 			  
				
		-- update borrow order status
		-- a.	2 ABRE – Rejected (all responses received are ABRE – Rejected)
		-- b.	1 SHTT and 1 ABRE – Responsed (Atleast one SHTT received and no cancel received – Responded)
		-- c.	1 SHTT and 1 ABCACO – Partial Canceled (atleast one SHTT received and atleast one ABCACO received – Partially Cancelled)
		-- d.	1 ABRE and 1 ABCACO – Canceled (No SHTT received and ABCACO received – Cancelled)
		-- e.	2 ABCACO – Canceled (No SHTT received and ABCACO received – Cancelled)
		-- f.	1 SHTT – Responsed (Atleast one SHTT received and no cancel received – Responded)
		-- g.	1 ABRE – Rejected (all responses received are ABRE – Rejected)
		-- h.	1 ABCACO – Canceled (No SHTT received and ABCACO received – Cancelled)
		-- i.	No message - (No Response received  – Rejected)

		FOR o IN v_orders 
		LOOP
			v_borrow_order_id := o.BORROW_ORDER_ID;
			v_shtt_flag := 'N';
			v_reject_flag := 'N';
			v_abcaco_flag := 'N';	
					
			FOR shtt IN v_shtt_messages 
			LOOP
				v_shtt_flag := 'Y';
				EXIT WHEN v_shtt_flag = 'Y';	
			END LOOP;
			
			FOR abre IN v_abre_messages 
			LOOP
				v_reject_flag := 'Y';			
				EXIT WHEN v_reject_flag = 'Y';				
			END LOOP;
		
			FOR abcaco IN v_abcaco_messages 
			LOOP
				v_abcaco_flag := 'Y';			
				EXIT WHEN v_abcaco_flag = 'Y';				
			END LOOP;
			
			IF v_shtt_flag = 'N' AND v_reject_flag = 'Y' AND v_abcaco_flag = 'N' THEN
				v_order_status := GEC_CONSTANTS_PKG.C_ORDER_REJECTED;
				v_order_status_msg := GEC_CONSTANTS_PKG.C_ORDER_M_REJECTED;
			ELSIF v_shtt_flag = 'Y' AND  v_abcaco_flag = 'N' THEN
				v_order_status := GEC_CONSTANTS_PKG.C_ORDER_RESPONDED;
				v_order_status_msg := GEC_CONSTANTS_PKG.C_ORDER_M_RESPONDED;				
			ELSIF v_shtt_flag = 'Y' AND v_abcaco_flag = 'Y' THEN
				v_order_status := GEC_CONSTANTS_PKG.C_ORDER_PARTIALLY_CANCELLED;
				v_order_status_msg := GEC_CONSTANTS_PKG.C_ORDER_M_PARTIALLY_CANCELLED;				
			ELSIF v_shtt_flag = 'N' AND v_abcaco_flag = 'Y' THEN
				v_order_status := GEC_CONSTANTS_PKG.C_ORDER_CANCELLED;
				v_order_status_msg := GEC_CONSTANTS_PKG.C_ORDER_M_CANCELLED;				
			ELSIF v_shtt_flag = 'N' AND v_reject_flag = 'N' AND v_abcaco_flag = 'N' THEN
				v_order_status := GEC_CONSTANTS_PKG.C_ORDER_REJECTED;
				v_order_status_msg := GEC_CONSTANTS_PKG.C_ORDER_M_REJECTED;				
			END IF;
			
			IF v_order_status IS NOT NULL THEN
				UPDATE GEC_BORROW_ORDER 
				SET STATUS = v_order_status, STATUS_MSG = v_order_status_msg WHERE BORROW_ORDER_ID = v_borrow_order_id;
			END IF;		
		END LOOP;
		
		-- When GEC receive EOB message, but no SHTT message received, system would not go to supply alloction process.
		-- If complete process EOB message, system should release this batch im order, and change allocate status of this request to 'C-omplete'.
		IF p_allocation_flag = 'N' THEN	
			IF (v_borrow_request_type = GEC_CONSTANTS_PKG.C_FLIP_TRADE) THEN				
				FOR in_ft IN v_in_flight_fliptrades
				LOOP
					UPDATE GEC_FLIP_TRADE ft SET ft.EXPORT_STATUS = 'R' WHERE ft.FLIP_TRADE_ID = in_ft.FLIP_TRADE_ID;	
				END LOOP;
			ELSE
				FOR in_o IN v_in_flight_orders
				LOOP
					UPDATE GEC_IM_ORDER o SET o.EXPORT_STATUS = CASE WHEN in_o.TRANSACTION_CD = GEC_CONSTANTS_PKG.C_SB_SHORT THEN 'C' ELSE 'R' END, o.UPDATED_AT= sysdate,o.UPDATED_BY = p_user_id WHERE o.IM_ORDER_ID = in_o.IM_ORDER_ID;
					IF in_o.MATCHED_ID IS NOT NULL THEN -- set pending cancel to cancel, set the short cancel to M-atched
						UPDATE GEC_IM_ORDER o SET o.STATUS = 'C', o.UPDATED_AT= sysdate,o.UPDATED_BY = p_user_id WHERE o.IM_ORDER_ID = in_o.IM_ORDER_ID;
						UPDATE GEC_IM_ORDER o SET o.STATUS = 'M', o.UPDATED_AT= sysdate,o.UPDATED_BY = p_user_id WHERE o.IM_ORDER_ID = in_o.MATCHED_ID;
					END IF;		
				END LOOP;
			END IF;			   
			UPDATE GEC_BORROW_REQUEST SET ALLOCATE_STATUS = 'C' WHERE BORROW_REQUEST_ID = p_borrow_request_Id;
		END IF;
		
		-- check if any order has been canceled, if canceled the batch status is 'Canceled'	
		v_status := 'N';
		FOR c_t IN v_canceled_trades
		LOOP 
			v_status := 'Y';
			EXIT WHEN v_status = 'Y';		
		END LOOP;
	
		IF v_status = 'Y' THEN
			UPDATE GEC_BORROW_REQUEST 
			SET STATUS = GEC_CONSTANTS_PKG.C_REQUEST_CANCELED,
				STATUS_MSG = GEC_CONSTANTS_PKG.C_REQUEST_M_CANCELED,
				SHTT_ABNO_COUNT = v_shtt_count,
				ORAC_ABRE_COUNT = v_abre_count,
				RESPONSE_AT = p_date,
				RESPONSE_BY = p_user_id
			WHERE BORROW_REQUEST_ID = p_borrow_request_Id;
		ELSE
			UPDATE GEC_BORROW_REQUEST 
			SET STATUS = GEC_CONSTANTS_PKG.C_REQUEST_RESPONSE_RECEIVED,
				STATUS_MSG = GEC_CONSTANTS_PKG.C_REQUEST_M_RESPONSE_RECEIVED,			
				SHTT_ABNO_COUNT = v_shtt_count,
				ORAC_ABRE_COUNT = v_abre_count,
				RESPONSE_AT = p_date,
				RESPONSE_BY = p_user_id						
			WHERE BORROW_REQUEST_ID = p_borrow_request_Id;
		END IF;		
		
		-- update message status
		-- UPDATE GEC_EQUILEND_MESSAGE SET STATUS = 'S' WHERE EQUILEND_MESSAGE_ID = p_msg_id; -- It has been done on business service
		
		OPEN p_borrow_request_cursor FOR
			SELECT BORROW_REQUEST_ID, REQUEST_AT, REQUEST_BY, RESPONSE_AT, RESPONSE_BY, STATUS_MSG, STATUS, BROKER_CD, BRANCH_CD, SETTLEMENT_MARKET, TYPE, BORROW_REQUEST_TYPE, BORROW_REQUEST_FILE_TYPE,
				   COLLATERAL_TYPE, COLLATERAL_CURRENCY_CD, EQUILEND_CHAIN_ID, EQUILEND_SCHEDULE_ID, REQUEST_COUNT, SHTT_ABNO_COUNT, ORAC_ABRE_COUNT, EXPIRATION_TIME,
				   AUTOBORROW_BATCH_ID, AGGREGATE_ID, ALLOCATE_STATUS
			FROM GEC_BORROW_REQUEST 
			WHERE BORROW_REQUEST_ID = p_borrow_request_Id;
		
				
	END UPDATE_STATUS;
	
	
	PROCEDURE VALIDATE_RESPONSE(p_corp_id IN NUMBER, p_autoborrow_batch_id IN VARCHAR2, p_aggregated_id IN NUMBER,  p_request_id OUT NUMBER, p_status OUT VARCHAR2)
	IS
		v_borrow_request_id GEC_BORROW_REQUEST.BORROW_REQUEST_ID%type;
		v_borrow_order_id GEC_BORROW_ORDER.BORROW_ORDER_ID%type;
		v_schedule_id GEC_BORROW_REQUEST.EQUILEND_SCHEDULE_ID%type;
		v_expected_msg_count GEC_BORROW_REQUEST.REQUEST_COUNT%type;
		
		v_count NUMBER(10);
		v_in_found VARCHAR2(1);
		v_status GEC_BORROW_REQUEST.STATUS%type;
		
		CURSOR v_orders IS
			SELECT br.EQUILEND_SCHEDULE_ID, bo.BORROW_ORDER_ID
			FROM GEC_BORROW_REQUEST br, GEC_BORROW_ORDER bo
			WHERE br.BORROW_REQUEST_ID = bo.BORROW_REQUEST_ID AND
				  br.BORROW_REQUEST_ID = v_borrow_request_id;
				  
						  
		CURSOR v_messages IS
			SELECT em.STATUS
			FROM GEC_EQL_MSG_BRW_ORDER mo, GEC_EQUILEND_MESSAGE em
			WHERE mo.BORROW_ORDER_ID = v_borrow_order_id AND
				  mo.EQUILEND_MESSAGE_ID = em.EQUILEND_MESSAGE_ID AND
		  		  em.IN_OUT = 'I' AND 
		  		  (em.MESSAGE_TYPE = GEC_CONSTANTS_PKG.C_MESSAGE_TYPE_ERPA OR em.MESSAGE_SUB_TYPE IN (GEC_CONSTANTS_PKG.C_MESSAGE_SUBTYPE_ABNO, GEC_CONSTANTS_PKG.C_MESSAGE_SUBTYPE_ABRE, GEC_CONSTANTS_PKG.C_MESSAGE_SUBTYPE_ABINCO)) AND
		  		  em.STATUS <> 'F';
		
	BEGIN	
		v_expected_msg_count := 0;
		
        -- validate the corp id is the same in ABIN/IN	
		IF p_corp_id <> GEC_CONSTANTS_PKG.C_CORP_ID THEN
			p_request_id := NULL;
			p_status := 'CORP_ID';	
			RETURN;
		END IF;
				
		--  validate the request id is exist
		BEGIN
			SELECT BORROW_REQUEST_ID, REQUEST_COUNT, STATUS INTO v_borrow_request_id, v_expected_msg_count, v_status FROM GEC_BORROW_REQUEST
			WHERE AUTOBORROW_BATCH_ID = p_autoborrow_batch_id AND AGGREGATE_ID = p_aggregated_id AND ROWNUM = 1;
		EXCEPTION WHEN NO_DATA_FOUND THEN
			p_request_id := NULL;
			p_status := 'NOT_EXIST';
			RETURN;
		END;
		
		IF v_status NOT IN ('I','P','PC') THEN
			p_request_id := NULL;
			p_status := 'INVALID_STATUS';
			RETURN;				
		END IF;
		
		FOR o IN v_orders
		LOOP
			v_borrow_order_id := o.BORROW_ORDER_ID;
			v_schedule_id := o.EQUILEND_SCHEDULE_ID;
			v_in_found := 'N';			
			
			-- validate no more than one shtt/abre for one abin in schedule			
			IF v_schedule_id IS NOT NULL THEN
			   SELECT COUNT(*) INTO v_count FROM GEC_EQL_MSG_BRW_ORDER mo, GEC_EQUILEND_MESSAGE m
			   WHERE mo.EQUILEND_MESSAGE_ID = m.EQUILEND_MESSAGE_ID AND
			   		 mo.BORROW_ORDER_ID = v_borrow_order_id AND
			   		 m.MESSAGE_SUB_TYPE IN (GEC_CONSTANTS_PKG.C_MESSAGE_SUBTYPE_ABRE, GEC_CONSTANTS_PKG.C_MESSAGE_SUBTYPE_ABNO, GEC_CONSTANTS_PKG.C_MESSAGE_SUBTYPE_ABCACO) AND
			   		 m.STATUS <> 'F';
			   		 
			   IF v_count > 1 THEN
			   	  p_request_id := NULL;
			   	  p_status := 'DUP_REP';
			   	  RETURN;
			   END IF;
			END IF;
						
		END LOOP;
		
		p_request_id := v_borrow_request_id;
		p_status := 'S';
		
	END VALIDATE_RESPONSE;
	
	
	PROCEDURE VALIDATE_ABSB_MESSAGE(p_corp_id IN NUMBER,  p_autoborrow_batch_id IN VARCHAR2, p_request_id OUT NUMBER, p_status OUT VARCHAR2)
	IS
		v_borrow_request_id GEC_BORROW_REQUEST.BORROW_REQUEST_ID%type;
		v_schedule_id GEC_BORROW_REQUEST.EQUILEND_SCHEDULE_ID%type;
		v_chain_id GEC_BORROW_REQUEST.EQUILEND_CHAIN_ID%type;
		v_expected_msg_count GEC_BORROW_REQUEST.REQUEST_COUNT%type;	
		v_from_legal_entity_id GEC_SCHEDULE.SFP_LEGAL_ENTITY_ID%type;
	
	BEGIN
		v_expected_msg_count := 0;
		
        -- validate the corp id is the same in ABIN/IN	
		IF p_corp_id <> GEC_CONSTANTS_PKG.C_CORP_ID THEN
			p_request_id := NULL;
			p_status := 'CORP_ID';	
			RETURN;
		END IF;
				
		--  validate the request id is exist
		BEGIN
			SELECT BORROW_REQUEST_ID, REQUEST_COUNT, EQUILEND_SCHEDULE_ID, EQUILEND_CHAIN_ID INTO v_borrow_request_id,  v_expected_msg_count, v_schedule_id, v_chain_id FROM GEC_BORROW_REQUEST
			WHERE AUTOBORROW_BATCH_ID = p_autoborrow_batch_id AND ROWNUM = 1 AND STATUS IN ('I','P','PC');
		EXCEPTION WHEN NO_DATA_FOUND THEN
			p_request_id := NULL;
			p_status := 'NOT_EXIST';
			RETURN;
		END;
		
		p_request_id := v_borrow_request_id;
		p_status := 'S';
	
	END VALIDATE_ABSB_MESSAGE;
		
END GEC_AUTOBORROW_PKG;
/