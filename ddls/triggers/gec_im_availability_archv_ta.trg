CREATE OR REPLACE TRIGGER GEC_IM_AVAILABILITY_ARCHV_TA
   BEFORE INSERT OR UPDATE OR DELETE OF
         IM_AVAILABILITY_ID,
         ASSET_ID,
         BUSINESS_DATE,
         CLIENT_CD,
         INVESTMENT_MANAGER_CD,
         ASSET_CODE,
         ASSET_CODE_TYPE,
         POSITION_FLAG,
         RESTRICTION_CD,
         NSB_QTY,
         NSB_RATE,
         SB_QTY,
         SB_QTY_RAL,
         SB_RATE,
         NFS_QTY,
         NFS_RATE,
         EXT2_QTY,
         EXT2_RATE,
         SB_QTY_SOD,
         NSB_QTY_SOD,
         SB_QTY_RAL_SOD,
         NFS_QTY_SOD,
         EXT2_QTY_SOD,
         SOURCE_CD,
         CREATED_BY,
         CREATED_AT,
         STRATEGY_ID,
		 TRADE_COUNTRY_CD,
		 STATUS,
		 COLLATERAL_CURRENCY_CD,
		 COLLATERAL_TYPE,
  		 INDICATIVE_RATE,
  		 INTERNAL_COMMENT_TXT   
   ON GEC_IM_AVAILABILITY_ARCHIVE
   FOR EACH ROW
DECLARE
   v_opCode CHAR(1);
BEGIN
   v_opCode := CASE WHEN INSERTING THEN 'I'
                    WHEN UPDATING  THEN 'U'
                    WHEN DELETING  THEN 'D'
               END;
   IF v_opCode = 'I' OR v_opCode = 'U'
   THEN
   :new.LAST_UPDATED_AT := sysdate;
   :new.LAST_UPDATED_BY := substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
   	   sys_context('USERENV','OS_USER')|| '@' || sys_context('USERENV','HOST')),1,32);
   END IF;

END GEC_IM_AVAILABILITY_ARCHV_TA;
/


