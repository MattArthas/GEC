CREATE OR REPLACE TYPE GEC_IM_AVAILABILITY_TP AS OBJECT
(
--  IM_AVAILABILITY_ID    NUMBER(38),
--  ASSET_ID              NUMBER(38),
  BUSINESS_DATE         NUMBER(8),
  CLIENT_CD             VARCHAR2(32),
  INVESTMENT_MANAGER_CD VARCHAR2(50),
  ASSET_CODE            VARCHAR2(20),
  ASSET_CODE_TYPE       VARCHAR2(3),
  POSITION_FLAG         VARCHAR2(2),
  RESTRICTION_CD        VARCHAR2(1),
  NSB_QTY               NUMBER(38),
  NSB_RATE              NUMBER(9,6),
  SB_QTY                NUMBER(38),
  SB_QTY_RAL            NUMBER(38),
  SB_RATE               NUMBER(9,6),
  NFS_QTY               NUMBER(38),
  NFS_RATE              NUMBER(9,6),
  EXT2_QTY              NUMBER(38),
  EXT2_RATE             NUMBER(9,6),
  SB_QTY_SOD            NUMBER(38),
  NSB_QTY_SOD           NUMBER(38),
  SB_QTY_RAL_SOD        NUMBER(38),
  NFS_QTY_SOD           NUMBER(38),
  EXT2_QTY_SOD          NUMBER(38),
  SOURCE_CD             VARCHAR2(10),
--  CREATED_BY            VARCHAR2(64),
--  CREATED_AT            DATE,
  --the following columns are not in availability table.
  CUSIP           VARCHAR2(9),
  ISIN            VARCHAR2(12),
  SEDOL           VARCHAR2(7),
  TICKER          VARCHAR2(50),
  DESCRIPTION     VARCHAR2(50)
);
/

