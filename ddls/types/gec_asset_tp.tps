--This type will be used in: 1. mapping to JAVA object GecAssetSQLData, 2. stored procedure
CREATE OR REPLACE TYPE GEC_ASSET_TP AS OBJECT
(
  ASSET_ID            	NUMBER(38),
  CUSIP               	VARCHAR2(9),
  ISIN                	VARCHAR2(12),
  SEDOL				  	VARCHAR2(7),
  QUIK                	VARCHAR2(5),
  TICKER              	VARCHAR2(50),
  DESCRIPTION         	VARCHAR2(50),
  SOURCE_FLAG		  	VARCHAR2(1),
  TRADE_COUNTRY_CD	  	VARCHAR2(3),
  ASSET_CODE          	VARCHAR2(20),
  ASSET_CODE_TYPE     	VARCHAR2(3),
  ASSET_TYPE_ID			VARCHAR2(1)  
);
/

