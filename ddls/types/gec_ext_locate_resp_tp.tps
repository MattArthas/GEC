CREATE OR REPLACE TYPE GEC_EXT_LOCATE_RESP_TP AS OBJECT
(
  BUSINESS_DATE   NUMBER(8),
  REQUESTOR       VARCHAR(255),
  TRANSACTION_TYPE VARCHAR(255),
  REFID           VARCHAR(255),
  CUSIP           VARCHAR2(255),
  ISIN            VARCHAR2(255),
  SEDOL           VARCHAR2(255),
  TICKER          VARCHAR2(255),
  REQUEST_SHARE_QTY NUMBER(38),
  APPROVED_QTY    NUMBER(38),
  FEE  			  NUMBER(28,3),
  COMMENTS		  VARCHAR(255)
);
/

