-- GEC GEC_G1_GLOBAL_BTC_DETAIL_VW
--USE FOR BTC UI BOTH US AND NON US
CREATE OR REPLACE  VIEW GEC_G1_GLOBAL_BTC_DETAIL_VW
AS
SELECT 
  O.IM_ORDER_ID, 
  O.fund_cd as Fund, 
  asset.ASSET_ID,
  asset.CUSIP, 
  O.Share_Qty, 
  O.Settle_date as Settle_DT, 
  '1' AS Rec_Type,
  O.TRADE_COUNTRY_CD as TRADE_COUNTRY_CD,
  O.business_date as Request_DT,
  trade_date as TRADE_DATE,
  gf.G1_INSTANCE_CD as G1_INSTANCE_CD,
  asset.SEDOL as SEDOL,
  gf.CLIENT_CD as FUND_NAME
  FROM GEC_IM_ORDER O
  join gec_asset asset
    on O.asset_id = asset.asset_id
  join gec_fund gf
    on gf.fund_cd= O.fund_cd
 WHERE O.Transaction_cd='COVER' 
   AND O.status = 'P'
   AND O.asset_type_id IN ('4','2')
   AND (G1_EXTRACTED_FLAG IS NULL OR G1_EXTRACTED_FLAG = 'N');