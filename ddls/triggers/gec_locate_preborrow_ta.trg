CREATE OR REPLACE TRIGGER GEC_LOCATE_PREBORROW_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         LOCATE_PREBORROW_ID,
         LOCATE_ID,
         IM_AVAILABILITY_ID,
         ASSET_ID,
         BUSINESS_DATE,
         CLIENT_CD,
         IM_USER_ID,
         INVESTMENT_MANAGER_CD,
         FUND_CD,
         FUND_SOURCE,
         IM_DEFAULT_FUND_CD,
         IM_DEFAULT_CLIENT_CD,
         STRATEGY_ID,
         TRANSACTION_CD,
         ASSET_CODE,
         ASSET_CODE_TYPE,
         CUSIP,
         ISIN,
         SEDOL,
         QUIK,
         TICKER,
  		 ASSET_TYPE_ID,  
         DESCRIPTION,
         FILE_VERSION,
         SHARE_QTY,
         RESERVED_SB_QTY,
         SB_QTY_RAL,
         RESERVED_NSB_QTY,
         SB_RATE,
         NSB_LOAN_NO,
         NSB_RATE,
         INDICATIVE_RATE,
         SOURCE_CD,
         REMAINING_SFP,
         POSITION_FLAG,
         SB_BROKER,
         RESTRICTION_CD,
         RESERVED_NFS_QTY,
         NFS_BORROW_ID,
         NFS_RATE,
         RESERVED_EXT2_QTY,
         EXT2_BORROW_ID,
         EXT2_RATE,
         STATUS,
         INITIAL_FLAG,
         UPDATED_BY,
         UPDATED_AT,
         CREATED_BY,
         CREATED_AT,
         COMMENT_TXT,
         INTERNAL_COMMENT_TXT,
         TRADER_APPROVED_QTY,
         REQUEST_ID,
         IM_REQUEST_ID,
         IM_LOCATE_ID, 
         TRADE_COUNTRY_CD,
         TRADE_COUNTRY_ALIAS_CD,
  		 SCHEDULED_AT,
  		 AT_POINT_AVAIL_QTY,
  		 AGENCY_BORROW_RATE,
  		 RECLAIM_RATE,
  		 ROW_NUMBER,
  		 LIQUIDITY_FLAG
   ON GEC_LOCATE_PREBORROW
   FOR EACH ROW
DECLARE
   v_opCode CHAR(1);
   v_lastUpdatedBy GEC_LOCATE_PREBORROW.LAST_UPDATED_BY%TYPE;
BEGIN
   v_opCode := CASE WHEN INSERTING THEN 'I'
                    WHEN UPDATING  THEN 'U'
                    WHEN DELETING  THEN 'D'
               END;
   v_lastUpdatedBy := substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
   	                           sys_context('USERENV','OS_USER')|| '@' || sys_context('USERENV','HOST')),1,32);

   IF v_opCode = 'I' OR v_opCode = 'U'
   THEN
      :new.LAST_UPDATED_AT := sysdate;
      :new.LAST_UPDATED_BY := v_lastUpdatedBy;
   END IF;

   IF v_opCode = 'U' OR v_opCode = 'D' THEN
      INSERT INTO GEC_LOCATE_PREBORROW_AUD(
            LOCATE_PREBORROW_ID,
            LOCATE_ID,
            IM_AVAILABILITY_ID,
            ASSET_ID,
            BUSINESS_DATE,
            CLIENT_CD,
            IM_USER_ID,
            INVESTMENT_MANAGER_CD,
            FUND_CD,
            FUND_SOURCE,
            IM_DEFAULT_FUND_CD,
            IM_DEFAULT_CLIENT_CD,
            STRATEGY_ID,
            TRANSACTION_CD,
            ASSET_CODE,
            ASSET_CODE_TYPE,
            CUSIP,
            ISIN,
            SEDOL,
            QUIK,
            TICKER,
  		 	ASSET_TYPE_ID,  
            DESCRIPTION,
            FILE_VERSION,
            SHARE_QTY,
            RESERVED_SB_QTY,
            SB_QTY_RAL,
            RESERVED_NSB_QTY,
            --ACTUAL_SB_QTY,
            --SB_LOAN_NO,
            SB_RATE,
            --ACTUAL_NSB_QTY,
            NSB_LOAN_NO,
            NSB_RATE,
            INDICATIVE_RATE,
            SOURCE_CD,
            --SETTLE_DATE,
            REMAINING_SFP,
            POSITION_FLAG,
            --LOG_NUMBER,
            SB_BROKER,
            --TRADE_DATE,
            --CLIENT_REF_NO,
            --LOAN_SETTLE_DATE,
            RESTRICTION_CD,
            RESERVED_NFS_QTY,
            --ACTUAL_NFS_QTY,
            NFS_BORROW_ID,
            NFS_RATE,
            RESERVED_EXT2_QTY,
            --ACTUAL_EXT2_QTY,
            EXT2_BORROW_ID,
            EXT2_RATE,
            --SFA_EXTRACT,
            --G1_EXTRACT,
            --SFP_SB_PRICE,
            --SB_AMOUNT,
            --SFP_NSB_PRICE,
            --NSB_AMOUNT,
            STATUS,
            INITIAL_FLAG,
            UPDATED_BY,
            UPDATED_AT,
            CREATED_BY,
            CREATED_AT,
            COMMENT_TXT,
            INTERNAL_COMMENT_TXT,
            --ACTUAL_SB_RATE,
            --ACTUAL_NSB_RATE,
            TRADER_APPROVED_QTY,
            REQUEST_ID,
            IM_REQUEST_ID,
            IM_LOCATE_ID,  
            TRADE_COUNTRY_CD,
            TRADE_COUNTRY_ALIAS_CD,
            SCHEDULED_AT,
            AT_POINT_AVAIL_QTY,
            AGENCY_BORROW_RATE,
            RECLAIM_RATE,
            ROW_NUMBER,
            LIQUIDITY_FLAG,
            LAST_UPDATED_BY,
            LAST_UPDATED_AT,
            OP_CODE
         )
      VALUES (
            :OLD.LOCATE_PREBORROW_ID,
            :OLD.LOCATE_ID,
            :OLD.IM_AVAILABILITY_ID,
            :OLD.ASSET_ID,
            :OLD.BUSINESS_DATE,
            :OLD.CLIENT_CD,
            :OLD.IM_USER_ID,
            :OLD.INVESTMENT_MANAGER_CD,
            :OLD.FUND_CD,
            :OLD.FUND_SOURCE,
            :OLD.IM_DEFAULT_FUND_CD,
            :OLD.IM_DEFAULT_CLIENT_CD,
            :OLD.STRATEGY_ID,
            :OLD.TRANSACTION_CD,
            :OLD.ASSET_CODE,
            :OLD.ASSET_CODE_TYPE,
            :OLD.CUSIP,
            :OLD.ISIN,
            :OLD.SEDOL,
            :OLD.QUIK,
            :OLD.TICKER,
  		 	:OLD.ASSET_TYPE_ID,  
            :OLD.DESCRIPTION,
            :OLD.FILE_VERSION,
            :OLD.SHARE_QTY,
            :OLD.RESERVED_SB_QTY,
            :OLD.SB_QTY_RAL,
            :OLD.RESERVED_NSB_QTY,
            --:OLD.ACTUAL_SB_QTY,
            --:OLD.SB_LOAN_NO,
            :OLD.SB_RATE,
            --:OLD.ACTUAL_NSB_QTY,
            :OLD.NSB_LOAN_NO,
            :OLD.NSB_RATE,
            :OLD.INDICATIVE_RATE,
            :OLD.SOURCE_CD,
            --:OLD.SETTLE_DATE,
            :OLD.REMAINING_SFP,
            :OLD.POSITION_FLAG,
            --:OLD.LOG_NUMBER,
            :OLD.SB_BROKER,
            --:OLD.TRADE_DATE,
            --:OLD.CLIENT_REF_NO,
            --:OLD.LOAN_SETTLE_DATE,
            :OLD.RESTRICTION_CD,
            :OLD.RESERVED_NFS_QTY,
            --:OLD.ACTUAL_NFS_QTY,
            :OLD.NFS_BORROW_ID,
            :OLD.NFS_RATE,
            :OLD.RESERVED_EXT2_QTY,
            --:OLD.ACTUAL_EXT2_QTY,
            :OLD.EXT2_BORROW_ID,
            :OLD.EXT2_RATE,
            --:OLD.SFA_EXTRACT,
            --:OLD.G1_EXTRACT,
            --:OLD.SFP_SB_PRICE,
            --:OLD.SB_AMOUNT,
            --:OLD.SFP_NSB_PRICE,
            --:OLD.NSB_AMOUNT,
            :OLD.STATUS,
            :OLD.INITIAL_FLAG,
            :OLD.UPDATED_BY,
            :OLD.UPDATED_AT,
            :OLD.CREATED_BY,
            :OLD.CREATED_AT,
            :OLD.COMMENT_TXT,
            :OLD.INTERNAL_COMMENT_TXT,
            --:OLD.ACTUAL_SB_RATE,
            --:OLD.ACTUAL_NSB_RATE,
            :OLD.TRADER_APPROVED_QTY,
            :OLD.REQUEST_ID,
            :OLD.IM_REQUEST_ID,
            :OLD.IM_LOCATE_ID,
            :OLD.TRADE_COUNTRY_CD,
            :OLD.TRADE_COUNTRY_ALIAS_CD,
            :OLD.SCHEDULED_AT,
            :OLD.AT_POINT_AVAIL_QTY,
            :OLD.AGENCY_BORROW_RATE,
            :OLD.RECLAIM_RATE,
            :OLD.ROW_NUMBER,
            :OLD.LIQUIDITY_FLAG,
            DECODE(v_opCode, 'D', v_lastUpdatedBy, :OLD.LAST_UPDATED_BY),
            DECODE(v_opCode, 'D', SYSDATE, :OLD.LAST_UPDATED_AT),
            v_opCode
      );
   END IF;

END GEC_LOCATE_PREBORROW_TA;
/

