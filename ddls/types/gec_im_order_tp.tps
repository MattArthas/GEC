CREATE OR REPLACE TYPE GEC_IM_ORDER_TP AS OBJECT
(
  BUSINESS_DATE            	NUMBER(8),
  INVESTMENT_MANAGER_CD 	VARCHAR2(100),
  TRANSACTION_CD        	VARCHAR2(20),
  FUND_CD                   VARCHAR2(4),
  SHARE_QTY          		NUMBER(38),
  CUSIP                   	VARCHAR2(9),
  ISIN                    	VARCHAR2(12),
  SEDOL                   	VARCHAR2(7),
  DESCRIPTION    			VARCHAR2(100),
  TRADE_DATE              	NUMBER(8),
  SETTLE_DATE         		NUMBER(8),
  CLIENT_REF_NO 			VARCHAR2(20),
  CREATED_AT               	DATE,
  LOG_NUMBER              	VARCHAR2(50),
  SOURCE_CD                 VARCHAR2(50),
  QUIK                   	VARCHAR2(4),
  TICKER                 	VARCHAR2(50),
  TRADE_COUNTRY_CD          VARCHAR2(3),
  FILE_VERSION           	NUMBER(2),
  STATUS					VARCHAR2(1),
  REQUEST_ID				NUMBER(38),
  COMMENT_TXT				VARCHAR2(4000),
  ASSET_CODE           		VARCHAR2(20),
  ASSET_CODE_TYPE       	VARCHAR2(3)
);
/

