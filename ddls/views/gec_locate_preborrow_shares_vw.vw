--- This view is used for report Executed Orders Recon -----
CREATE OR REPLACE VIEW GEC_LOCATE_PREBORROW_SHARES_VW (LOCSHARES, BUSINESS_DATE, INVESTMENT_MANAGER_CD, FUND_CD, ASSET_ID) AS 
SELECT SUM(LocShares) AS LocShares,
	BUSINESS_DATE, INVESTMENT_MANAGER_CD, FUND_CD, ASSET_ID
FROM (	
	SELECT (CASE tbl_Locate_Preborrow.Transaction_cd 
			WHEN 'LOCATE' THEN Sum(NVL(Reserved_SB_Qty,0)+NVL(SB_Qty_RAL,0)+NVL(Reserved_NSB_Qty,0)+NVL(Reserved_NFS_Qty,0)+NVL(Reserved_EXT2_Qty,0))
			WHEN 'PREBORROW' THEN Sum(NVL(Reserved_SB_Qty,0)+NVL(SB_Qty_RAL,0)+NVL(Reserved_NSB_Qty,0)+NVL(Reserved_NFS_Qty,0)+NVL(Reserved_EXT2_Qty,0))			
			ELSE null
			END) AS LocShares, 
		   tbl_Locate_Preborrow.BUSINESS_DATE, tbl_Locate_Preborrow.INVESTMENT_MANAGER_CD, tbl_Locate_Preborrow.FUND_CD, tbl_Locate_Preborrow.ASSET_ID
	FROM GEC_LOCATE_PREBORROW tbl_Locate_Preborrow
	GROUP BY tbl_Locate_Preborrow.BUSINESS_DATE, tbl_Locate_Preborrow.INVESTMENT_MANAGER_CD, tbl_Locate_Preborrow.FUND_CD, tbl_Locate_Preborrow.ASSET_ID, tbl_Locate_Preborrow.TRANSACTION_CD, tbl_Locate_Preborrow.Status
	HAVING (tbl_Locate_Preborrow.TRANSACTION_CD='LOCATE' AND (tbl_Locate_Preborrow.Status='E' Or tbl_Locate_Preborrow.Status='P'))
			 OR (tbl_Locate_Preborrow.Transaction_cd='PREBORROW' AND (tbl_Locate_Preborrow.Status='E' Or tbl_Locate_Preborrow.Status='P'))
	) 
GROUP BY BUSINESS_DATE, INVESTMENT_MANAGER_CD, FUND_CD, ASSET_ID;
