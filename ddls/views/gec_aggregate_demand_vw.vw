CREATE OR REPLACE VIEW GEC_AGGREGATE_DEMAND_VW AS
	SELECT 
		im_order.IM_ORDER_ID,
		im_order.ASSET_ID,
		im_order.CUSIP,
		im_order.SEDOL,
		im_order.ISIN,
		im_order.QUIK,
        im_order.TICKER,
        im_order.DESCRIPTION,
        im_order.POSITION_FLAG,
        im_order.TRADE_COUNTRY_CD,
		im_order.FUND_CD,
		im_order.SB_BROKER_CD,
		DECODE(gccm.COUNTRY_CATEGORY_CD,'PS1',DECODE(fund.FUND_CATEGORY_CD,'SGF',im_order.SETTLE_DATE,'OBF',
		GEC_UTILS_PKG.GET_TMINUSN_NUM(im_order.SETTLE_DATE,1,im_order.TRADE_COUNTRY_CD,'S'),im_order.SETTLE_DATE),'PS2',
    	DECODE(fund.FUND_CATEGORY_CD,'SGF',im_order.SETTLE_DATE,'OBF',
		GEC_UTILS_PKG.GET_TMINUSN_NUM(im_order.SETTLE_DATE,1,im_order.TRADE_COUNTRY_CD,'S'),im_order.SETTLE_DATE),im_order.SETTLE_DATE) P_SHARES_SETTLE_DATE,
		im_order.SETTLE_DATE,
		im_order.STATUS,
		im_order.FILLED_QTY,
        im_order.SHARE_QTY, 
        im_order.RATE,
        im_order.TRANSACTION_CD, 
        im_order.SOURCE_CD,
        trade_country.trading_desk_cd,
        trade_country.PREPAY_DATE_VALUE,
        fund.BRANCH_CD,
		fund.nsb_collateral_type,
        nvl(g1_collateral.COLLATERAL_CURRENCY_CD,g1_booking.COLLATERAL_CURRENCY_CD) as COLLATERAL_CURRENCY_CD,
		asset_type.ASSET_TYPE_DESC
	FROM GEC_IM_ORDER_VW im_order
	JOIN GEC_FUND fund ON fund.FUND_CD = im_order.FUND_CD
	JOIN GEC_TRADE_COUNTRY trade_country ON im_order.trade_country_cd = trade_country.trade_country_cd
	LEFT JOIN GEC_COUNTRY_CATEGORY_MAP gccm ON trade_country.TRADE_COUNTRY_CD = gccm.COUNTRY_CD
	LEFT JOIN GEC_G1_BOOKING g1_booking ON(fund.FUND_CD = g1_booking.FUND_CD 
         	AND g1_booking.pos_type = 'NSB' AND g1_booking.transaction_cd = 'G1L')
  	LEFT JOIN GEC_G1_COLLATERAL g1_collateral on (g1_booking.g1_booking_id = g1_collateral.g1_booking_id
          AND im_order.TRADE_COUNTRY_CD = g1_collateral.trade_country_cd)
    JOIN GEC_ASSET_TYPE asset_type ON asset_type.ASSET_TYPE_ID = im_order.ASSET_TYPE_ID
	WHERE im_order.TRANSACTION_CD IN('SHORT','SHORTSB','COVER')
		AND im_order.ASSET_ID IS NOT NULL
		AND (im_order.STATUS = 'P' OR im_order.STATUS = 'E' OR im_order.STATUS = 'B')
		AND im_order.settle_date > TO_NUMBER(TO_CHAR(sysdate-1, 'YYYYMMDD'));