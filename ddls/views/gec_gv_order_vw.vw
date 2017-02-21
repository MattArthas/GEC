--GEC-1870. This view is created for Global View report outside of GEC
CREATE OR REPLACE VIEW GEC_GV_ORDER_VW AS
	SELECT 
		TO_CHAR(o.IM_ORDER_ID) AS IM_ORDER_ID,
		o.FUND_CD,
		DECODE(o.TRANSACTION_CD, 'SHORT', 'Short', 'COVER', 'BTC', o.TRANSACTION_CD) AS ACTIVITY_TYPE,
		o.SHARE_QTY AS QUANTITY,
		(CASE o.TRANSACTION_CD
			WHEN 'SHORT' THEN DECODE(o.G1_EXTRACTED_FLAG, 'Y', o.SHARE_QTY - DECODE(lqs.allocation_qty_sum, null, 0, lqs.allocation_qty_sum), o.SHARE_QTY)
			ELSE DECODE(o.G1_EXTRACTED_FLAG, 'Y', 0, o.SHARE_QTY)
		END) AS UNFILLED_QUANTITY,
		GEC_UTILS_PKG.NUMBER_TO_DATE(o.TRADE_DATE) AS TRADE_DATE,
    GEC_UTILS_PKG.NUMBER_TO_DATE(o.SETTLE_DATE) AS SETTLE_DATE,
		ga.CUSIP,
		ga.SEDOL,
		ga.ISIN,
		ga.QUIK AS QUICK,
		ga.TICKER,
		ga.DESCRIPTION AS FULL_SECURITY_NAME,
		NVL(tc.CURRENCY_CD,o.TRADE_COUNTRY_CD) AS SECURITY_COUNTRY_CODE,
		DECODE(o.STATUS, 'X', 'Error', 'P', 'Pending', 'B','Booked', 'C', 'Canceled','E','Exception') AS TRADE_STATE
	  FROM GEC_IM_ORDER o
    left outer join gec_asset ga
    on o.asset_id = ga.asset_id
	  LEFT OUTER JOIN GEC_TRADE_COUNTRY tc
	    ON o.TRADE_COUNTRY_CD = tc.TRADE_COUNTRY_CD
	  LEFT OUTER JOIN (
	              select ga.im_order_id allocation_im_order_id, 
	            		    sum(ga.ALLOCATION_QTY) allocation_qty_sum
	              from  GEC_ALLOCATION ga
	              where ga.status = 'B'
	              GROUP BY ga.im_order_id
	            ) lqs
	  on o.im_order_id = lqs.allocation_im_order_id
	 WHERE SOURCE_CD NOT LIKE 'Dummy%'
       AND o.TRANSACTION_CD in ('SHORT', 'COVER') 
	   AND o.SHARE_QTY >= 0;
