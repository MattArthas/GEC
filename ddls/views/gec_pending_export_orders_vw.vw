CREATE OR REPLACE VIEW GEC_PENDING_EXPORT_ORDERS_VW AS
	SELECT 
    	im_order.IM_ORDER_ID,
    	im_order.ASSET_ID,
    	DECODE(gccm.COUNTRY_CATEGORY_CD,'PS1',DECODE(fund.FUND_CATEGORY_CD,'SGF',im_order.SETTLE_DATE,'OBF',
    	GEC_UTILS_PKG.GET_TMINUSN_NUM(im_order.SETTLE_DATE,1,im_order.TRADE_COUNTRY_CD,'S'),im_order.SETTLE_DATE),'PS2',
    	DECODE(fund.FUND_CATEGORY_CD,'SGF',im_order.SETTLE_DATE,'OBF',GEC_UTILS_PKG.GET_TMINUSN_NUM(im_order.SETTLE_DATE,1,im_order.TRADE_COUNTRY_CD,'S'),
    	im_order.SETTLE_DATE),im_order.SETTLE_DATE) SETTLE_DATE,
    	im_order.HOLDBACK_FLAG,
    	im_order.TRADE_COUNTRY_CD,
    	im_order.SHARE_QTY, 
    	im_order.FILLED_QTY,
    	im_order.TRANSACTION_CD, 
    	im_order.FUND_CD,
    	im_order.POSITION_FLAG,
    	fund.DML_SB_BROKER,
    	fund.DML_NSB_BROKER,
    	fund.SB_COLLATERAL_TYPE,
    	fund.NSB_COLLATERAL_TYPE,
    	fund.BRANCH_CD,
      nvl(sb_g1_collateral.COLLATERAL_CURRENCY_CD,sb_g1_booking.COLLATERAL_CURRENCY_CD) as SB_COLLATERAL_CURRENCY_CD,
      nvl(nsb_g1_collateral.COLLATERAL_CURRENCY_CD,nsb_g1_booking.COLLATERAL_CURRENCY_CD) as NSB_COLLATERAL_CURRENCY_CD
	FROM GEC_IM_ORDER_VW im_order
	JOIN GEC_TRADE_COUNTRY trade_country ON im_order.trade_country_cd = trade_country.trade_country_cd
	JOIN GEC_FUND fund ON fund.FUND_CD = im_order.FUND_CD
	LEFT JOIN GEC_COUNTRY_CATEGORY_MAP gccm ON trade_country.TRADE_COUNTRY_CD = gccm.COUNTRY_CD
  	LEFT JOIN GEC_G1_BOOKING sb_g1_booking ON(fund.FUND_CD = sb_g1_booking.FUND_CD 
         	AND sb_g1_booking.pos_type = 'SB' AND sb_g1_booking.transaction_cd = 'G1L')
  	LEFT JOIN GEC_G1_COLLATERAL sb_g1_collateral on (sb_g1_booking.g1_booking_id = sb_g1_collateral.g1_booking_id
          AND im_order.TRADE_COUNTRY_CD = sb_g1_collateral.trade_country_cd)
	LEFT JOIN GEC_G1_BOOKING nsb_g1_booking ON(fund.FUND_CD = nsb_g1_booking.FUND_CD 
         	AND nsb_g1_booking.pos_type = 'NSB' AND nsb_g1_booking.transaction_cd = 'G1L')
  	LEFT JOIN GEC_G1_COLLATERAL nsb_g1_collateral on (nsb_g1_booking.g1_booking_id = nsb_g1_collateral.g1_booking_id
          AND im_order.TRADE_COUNTRY_CD = nsb_g1_collateral.trade_country_cd)
	JOIN GEC_ASSET_TYPE asset_type ON asset_type.ASSET_TYPE_ID = im_order.ASSET_TYPE_ID
	WHERE (im_order.TRANSACTION_CD = 'SHORT' OR im_order.TRANSACTION_CD = 'SHORTSB')
		AND im_order.ASSET_ID IS NOT NULL
		AND im_order.EXPORT_STATUS != 'I' AND im_order.EXPORT_STATUS != 'C'
		AND (im_order.STATUS = 'P' OR im_order.STATUS = 'E' OR im_order.STATUS = 'B')
		AND im_order.SHARE_QTY > im_order.FILLED_QTY
		AND im_order.settle_date > TO_NUMBER(TO_CHAR(sysdate-1, 'YYYYMMDD'))    
		AND (UPPER(asset_type.ASSET_TYPE_DESC) = 'CORP BOND' OR UPPER(asset_type.ASSET_TYPE_DESC) = 'EQUITY');
