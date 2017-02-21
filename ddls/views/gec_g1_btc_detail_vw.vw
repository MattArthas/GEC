-- GEC GEC_G1_BTC_DETAIL_VW
--USE FOR BTC CONTINGENCY 
CREATE OR REPLACE  VIEW GEC_G1_BTC_DETAIL_VW
AS
SELECT 
	O.IM_ORDER_ID,
	O.fund_cd as Fund,
	asset.CUSIP, 
	O.Share_Qty,
	O.Settle_date as Settle_DT,
	'1' AS Rec_Type,
	O.business_date as Request_DT 
  FROM GEC_IM_ORDER O
  join gec_asset asset
    on O.asset_id = asset.asset_id
 WHERE O.Transaction_cd='COVER' 
   AND O.status = 'P'
   AND O.trade_country_cd = 'US'
   AND O.asset_type_id IN ('4','2')
   AND (G1_EXTRACTED_FLAG IS NULL OR G1_EXTRACTED_FLAG = 'N');
