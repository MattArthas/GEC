CREATE OR REPLACE VIEW GEC_SELECT_SHORT_FILLED_VW AS
SELECT loc.BUSINESS_DATE,loc.INVESTMENT_MANAGER_CD,loc.transaction_cd,
	loc.FUND_CD,loc.CLIENT_CD,loc.SHARE_QTY,asset.CUSIP,
	asset.ISIN,asset.SEDOL,asset.TICKER,asset.DESCRIPTION,
	loc.RESERVED_SB_QTY,loc.SB_QTY_RAL,
	loc.RESERVED_NSB_QTY,loc.source_cd,loc.updated_by,
	loc.STATUS,--loc.ACTUAL_SB_QTY,--loc.SB_LOAN_NO,
	loc.SB_RATE,--loc.ACTUAL_NSB_QTY--,loc.NSB_LOAN_NO,
	loc.NSB_RATE,--loc.SETTLE_DATE,
  loc.REMAINING_SFP,
	loc.POSITION_FLAG,--loc.LOG_NUMBER,
  loc.SB_BROKER,
	loc.UPDATED_AT,--loc.TRADE_DATE,loc.CLIENT_REF_NO,
	--loc.LOAN_SETTLE_DATE,
  loc.TRADE_COUNTRY_CD,loc.RESTRICTION_CD,
	loc.RESERVED_NFS_QTY,--loc.ACTUAL_NFS_QTY,
  loc.NFS_BORROW_ID,
	loc.NFS_RATE,loc.RESERVED_EXT2_QTY,--loc.ACTUAL_EXT2_QTY,
	loc.EXT2_BORROW_ID,loc.EXT2_RATE,--loc.SFA_EXTRACT,
	--loc.G1_EXTRACT--,loc.SFP_SB_PRICE,--loc.SB_AMOUNT,
	--loc.SFP_NSB_PRICE,--loc.NSB_AMOUNT,
  loc.CREATED_BY,
	loc.CREATED_AT,loc.LOCATE_PREBORROW_ID,loc.COMMENT_TXT, 
	loc.ASSET_ID, loc.ASSET_CODE, loc.ASSET_CODE_TYPE,
	NVL(loc.Reserved_SB_Qty, 0) + NVL(loc.SB_Qty_RAL, 0) + NVL(loc.Reserved_NSB_Qty, 0) + NVL(loc.Reserved_NFS_Qty, 0) + NVL(loc.Reserved_EXT2_Qty, 0) Approved_Qty,
	loc.IM_AVAILABILITY_ID,loc.indicative_rate
FROM GEC_Locate_Preborrow loc, gec_asset asset
WHERE loc.ASSET_ID = asset.ASSET_ID
  AND ( ( ( loc.transaction_cd = 'LOCATE' OR loc.transaction_cd = 'PREBORROW' ) AND (loc.Status = 'P' OR loc.Status = 'E' OR loc.Status = 'F') )  )
  AND loc.initial_flag = 'N';

