--This type will be used in: 1. mapping to JAVA object GecAssetRateSqlData, 2. stored procedure
CREATE OR REPLACE TYPE GEC_ASSET_RATE_TP AS OBJECT
(
  ASSET_ID            	NUMBER(38),
  ASSET_CODE			VARCHAR2(20),
  PRICE_CURRENCY_CD     VARCHAR2(3),
  PRICE_DATE			NUMBER(8),
  CLEAN_PRICE		  	NUMBER(15,7),
  DIRTY_PRICE	  		NUMBER(15,7)
);
/