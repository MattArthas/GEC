CREATE OR REPLACE TRIGGER GEC_IM_ORDER_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         IM_ORDER_ID,
         REQUEST_ID,
         FUND_CD,
         BRANCH_CD,
         STRATEGY_ID,
         INVESTMENT_MANAGER_CD,
         BUSINESS_DATE,
         ASSET_ID,
         ASSET_TYPE_ID,
         ASSET_CODE,
         ASSET_CODE_TYPE,
         CUSIP,
         ISIN,
         QUIK,
         SEDOL,
         RATE, 
         TICKER,
         DESCRIPTION,
         TRADE_COUNTRY_CD,
         AT_POINT_AVAIL_QTY,
         CLIENT_REF_NO,
         FILE_VERSION,
         POSITION_FLAG,
         SHARE_QTY,
         RESERVED_SB_QTY,
         RESERVED_SB_QTY_RAL,
         RESERVED_NSB_QTY,
         RESERVED_NFS_QTY,
         RESERVED_EXT2_QTY,
         FILLED_QTY,
         RESTRICTION_CD,
         SB_BROKER_CD,
         SETTLE_DATE,
         STATUS,
         EXPORT_STATUS,
         TRADE_DATE,
         TRANSACTION_CD,
         HOLDBACK_FLAG,
         SFA_EXTRACTED_AT,
         G1_EXTRACTED_AT,
         G1_EXTRACTED_FLAG,
         INTERNAL_COMMENT_TXT,
         COMMENT_TXT,
         SOURCE_CD,
         MATCHED_ID,
         LOCATE_PREBORROW_ID,
         CREATED_AT,
         CREATED_BY,
         UPDATED_AT,
         UPDATED_BY,
         SETTLEMENT_LOCATION_CD,
         LEGAL_ENTITY_CD,
         TICKET_SIZE,
         LOAN_AMOUNT,
         P_SHARES_SETTLE_DATE
   ON GEC_IM_ORDER
   FOR EACH ROW
DECLARE
   v_opCode CHAR(1);
BEGIN
   v_opCode := CASE WHEN INSERTING THEN 'I'
                    WHEN UPDATING  THEN 'U'
                    WHEN DELETING  THEN 'D'
               END;
   IF v_opCode = 'I' OR v_opCode = 'U'
   THEN
   :new.LAST_UPDATED_AT := sysdate;
   :new.LAST_UPDATED_BY := substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
   	   sys_context('USERENV','OS_USER')|| '@' || sys_context('USERENV','HOST')),1,32);
   END IF;

   INSERT INTO GEC_IM_ORDER_AUD(
         IM_ORDER_ID,
         REQUEST_ID,
         FUND_CD,
         BRANCH_CD,
         STRATEGY_ID,
         INVESTMENT_MANAGER_CD,
         BUSINESS_DATE,
         ASSET_ID,
         ASSET_TYPE_ID,
         ASSET_CODE,
         ASSET_CODE_TYPE,
         CUSIP,
         ISIN,
         QUIK,
         SEDOL,
         RATE,
         TICKER,
         DESCRIPTION,
         TRADE_COUNTRY_CD,
         AT_POINT_AVAIL_QTY,
         CLIENT_REF_NO,
         FILE_VERSION,
         POSITION_FLAG,
         SHARE_QTY,
         RESERVED_SB_QTY,
         RESERVED_SB_QTY_RAL,
         RESERVED_NSB_QTY,
         RESERVED_NFS_QTY,
         RESERVED_EXT2_QTY,
         FILLED_QTY,
         RESTRICTION_CD,
         SB_BROKER_CD,
         SETTLE_DATE,
         STATUS,
         EXPORT_STATUS,
         TRADE_DATE,
         TRANSACTION_CD,
         HOLDBACK_FLAG,
         SFA_EXTRACTED_AT,
         G1_EXTRACTED_AT,
         G1_EXTRACTED_FLAG,
         INTERNAL_COMMENT_TXT,
         COMMENT_TXT,
         SOURCE_CD,
         MATCHED_ID,
         LOCATE_PREBORROW_ID,
         CREATED_AT,
         CREATED_BY,
         UPDATED_AT,
         UPDATED_BY,
         SETTLEMENT_LOCATION_CD,
         LEGAL_ENTITY_CD,
         TICKET_SIZE,
         LOAN_AMOUNT,
         P_SHARES_SETTLE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.IM_ORDER_ID, :NEW.IM_ORDER_ID),
         DECODE(v_opCode, 'D', :OLD.REQUEST_ID, :NEW.REQUEST_ID),
         DECODE(v_opCode, 'D', :OLD.FUND_CD, :NEW.FUND_CD),
         DECODE(v_opCode, 'D', :OLD.BRANCH_CD, :NEW.BRANCH_CD),
         DECODE(v_opCode, 'D', :OLD.STRATEGY_ID, :NEW.STRATEGY_ID),
         DECODE(v_opCode, 'D', :OLD.INVESTMENT_MANAGER_CD, :NEW.INVESTMENT_MANAGER_CD),
         DECODE(v_opCode, 'D', :OLD.BUSINESS_DATE, :NEW.BUSINESS_DATE),
         DECODE(v_opCode, 'D', :OLD.ASSET_ID, :NEW.ASSET_ID),
         DECODE(v_opCode, 'D', :OLD.ASSET_TYPE_ID, :NEW.ASSET_TYPE_ID),
         DECODE(v_opCode, 'D', :OLD.ASSET_CODE, :NEW.ASSET_CODE),
         DECODE(v_opCode, 'D', :OLD.ASSET_CODE_TYPE, :NEW.ASSET_CODE_TYPE),
         DECODE(v_opCode, 'D', :OLD.CUSIP, :NEW.CUSIP),
         DECODE(v_opCode, 'D', :OLD.ISIN, :NEW.ISIN),
         DECODE(v_opCode, 'D', :OLD.QUIK, :NEW.QUIK),
         DECODE(v_opCode, 'D', :OLD.SEDOL, :NEW.SEDOL),
         DECODE(v_opCode, 'D', :OLD.RATE, :NEW.RATE),
         DECODE(v_opCode, 'D', :OLD.TICKER, :NEW.TICKER),
         DECODE(v_opCode, 'D', :OLD.DESCRIPTION, :NEW.DESCRIPTION),
         DECODE(v_opCode, 'D', :OLD.TRADE_COUNTRY_CD, :NEW.TRADE_COUNTRY_CD),
         DECODE(v_opCode, 'D', :OLD.AT_POINT_AVAIL_QTY, :NEW.AT_POINT_AVAIL_QTY),
         DECODE(v_opCode, 'D', :OLD.CLIENT_REF_NO, :NEW.CLIENT_REF_NO),
         DECODE(v_opCode, 'D', :OLD.FILE_VERSION, :NEW.FILE_VERSION),
         DECODE(v_opCode, 'D', :OLD.POSITION_FLAG, :NEW.POSITION_FLAG),
         DECODE(v_opCode, 'D', :OLD.SHARE_QTY, :NEW.SHARE_QTY),
         DECODE(v_opCode, 'D', :OLD.RESERVED_SB_QTY, :NEW.RESERVED_SB_QTY),
         DECODE(v_opCode, 'D', :OLD.RESERVED_SB_QTY_RAL, :NEW.RESERVED_SB_QTY_RAL),
         DECODE(v_opCode, 'D', :OLD.RESERVED_NSB_QTY, :NEW.RESERVED_NSB_QTY),
         DECODE(v_opCode, 'D', :OLD.RESERVED_NFS_QTY, :NEW.RESERVED_NFS_QTY),
         DECODE(v_opCode, 'D', :OLD.RESERVED_EXT2_QTY, :NEW.RESERVED_EXT2_QTY),
         DECODE(v_opCode, 'D', :OLD.FILLED_QTY, :NEW.FILLED_QTY),
         DECODE(v_opCode, 'D', :OLD.RESTRICTION_CD, :NEW.RESTRICTION_CD),
         DECODE(v_opCode, 'D', :OLD.SB_BROKER_CD, :NEW.SB_BROKER_CD),
         DECODE(v_opCode, 'D', :OLD.SETTLE_DATE, :NEW.SETTLE_DATE),
         DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS),
         DECODE(v_opCode, 'D', :OLD.EXPORT_STATUS, :NEW.EXPORT_STATUS),
         DECODE(v_opCode, 'D', :OLD.TRADE_DATE, :NEW.TRADE_DATE),
         DECODE(v_opCode, 'D', :OLD.TRANSACTION_CD, :NEW.TRANSACTION_CD),
         DECODE(v_opCode, 'D', :OLD.HOLDBACK_FLAG, :NEW.HOLDBACK_FLAG),
         DECODE(v_opCode, 'D', :OLD.SFA_EXTRACTED_AT, :NEW.SFA_EXTRACTED_AT),
         DECODE(v_opCode, 'D', :OLD.G1_EXTRACTED_AT, :NEW.G1_EXTRACTED_AT),
         DECODE(v_opCode, 'D', :OLD.G1_EXTRACTED_FLAG, :NEW.G1_EXTRACTED_FLAG),
         DECODE(v_opCode, 'D', :OLD.INTERNAL_COMMENT_TXT, :NEW.INTERNAL_COMMENT_TXT),
         DECODE(v_opCode, 'D', :OLD.COMMENT_TXT, :NEW.COMMENT_TXT),
         DECODE(v_opCode, 'D', :OLD.SOURCE_CD, :NEW.SOURCE_CD),
         DECODE(v_opCode, 'D', :OLD.MATCHED_ID, :NEW.MATCHED_ID),       
         DECODE(v_opCode, 'D', :OLD.LOCATE_PREBORROW_ID, :NEW.LOCATE_PREBORROW_ID),       
         DECODE(v_opCode, 'D', :OLD.CREATED_AT, :NEW.CREATED_AT),
         DECODE(v_opCode, 'D', :OLD.CREATED_BY, :NEW.CREATED_BY),
         DECODE(v_opCode, 'D', :OLD.UPDATED_AT, :NEW.UPDATED_AT),
         DECODE(v_opCode, 'D', :OLD.UPDATED_BY, :NEW.UPDATED_BY),
         DECODE(v_opCode, 'D', :OLD.SETTLEMENT_LOCATION_CD, :NEW.SETTLEMENT_LOCATION_CD),
         DECODE(v_opCode, 'D', :OLD.LEGAL_ENTITY_CD, :NEW.LEGAL_ENTITY_CD),
         DECODE(v_opCode, 'D', :OLD.TICKET_SIZE, :NEW.TICKET_SIZE),
         DECODE(v_opCode, 'D', :OLD.LOAN_AMOUNT, :NEW.LOAN_AMOUNT),
         DECODE(v_opCode, 'D', :OLD.P_SHARES_SETTLE_DATE, :NEW.P_SHARES_SETTLE_DATE),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_IM_ORDER_TA;
/

