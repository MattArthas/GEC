-------------------------------------------------------------------------
-- Copyright (c) 2009 State Street Bank and Trust Corp.
-- 225 Franklin Street, Boston, MA 02110, U.S.A.
-- All rights reserved.
--
-- "GEC_UTILS_PKG.sql is the copyrighted,
-- proprietary property of State Street Bank and Trust Company and its
-- subsidiaries and affiliates which retain all right, title and interest
-- therein."
--
-- Revision History
--
-- Date            Programmer                Notes
-- ------------    --------------------      ----------------------------
-- May 24, 2010    Gubo, Huang               initial
-- Jul 02, 2010    Gubo, Huang               delete operation on gec_asset_identifier, since it is token by trigger
-- Nov 18, 2010    Kui, Jiang				 update security price from IR pricing file
-- Aug 18, 2010	   Shi, Yi                   add ADD_ASSET, UPDATE_ASSET, UPDATEASSET_FOR_LOCATESECMSTR, ADD_UPDATE_ASSET_IDENTIFIER 3 SP, and update ADD_UPDATE_SECURITY_MASTER for the change of deleting trigger gec_asset_tr
-------------------------------------------------------------------------
create or replace PACKAGE GEC_ASSET_PKG AS
	PROCEDURE ADD_UPDATE_SECURITY_MASTER(secArray 	IN 	GEC_ASSET_TP_ARRAY);
	-- Load security price from DML file
	PROCEDURE UPDATE_OR_ADD_SECURITY_PRICE(
			securityArray		IN		GEC_ASSET_RATE_TP_ARRAY,
			p_ret_fail_number	OUT		NUMBER
		);
	PROCEDURE ADD_UPDATE_ASSET_IDENTIFIER(
          new_cusip IN GEC_ASSET.CUSIP%type, 
          new_sedol IN GEC_ASSET.SEDOL%type, 
          new_isin IN GEC_ASSET.ISIN%type, 
          new_quik IN GEC_ASSET.QUIK%type, 
          new_ticker IN GEC_ASSET.TICKER%type, 
          old_cusip IN GEC_ASSET.CUSIP%type, 
          old_sedol IN GEC_ASSET.SEDOL%type, 
          old_isin IN GEC_ASSET.ISIN%type, 
          old_quik IN GEC_ASSET.QUIK%type, 
          old_ticker IN GEC_ASSET.TICKER%type, 
          new_asset_id IN GEC_ASSET.ASSET_ID%type, 
          is_insert IN NUMBER
               );
    PROCEDURE ADD_ASSET(
       v_securityType IN GEC_ASSET.ASSET_TYPE_ID%type, 
       v_cusip IN GEC_ASSET.CUSIP%type, 
       v_sedol IN GEC_ASSET.SEDOL%type, 
       v_isin IN GEC_ASSET.ISIN%type, 
       v_ticker IN GEC_ASSET.TICKER%type, 
       v_description IN GEC_ASSET.DESCRIPTION%type, 
       v_sourceFlag IN GEC_ASSET.SOURCE_FLAG%type, 
       v_quik IN GEC_ASSET.QUIK%type, 
       v_tradeCountryCd IN GEC_ASSET.TRADE_COUNTRY_CD%type, 
       v_updatedBy IN GEC_ASSET.UPDATED_BY%type, 
       v_priceCurrency IN GEC_ASSET.PRICE_CURRENCY_CD%type, 
       v_cleanPrice IN GEC_ASSET.CLEAN_PRICE%type, 
       v_dirtyPrice IN GEC_ASSET.DIRTY_PRICE%type, 
       v_priceDate IN GEC_ASSET.PRICE_DATE%type, 
       v_assetID OUT GEC_ASSET.ASSET_ID%type,
       v_liquidity IN GEC_ASSET.LIQUIDITY_FLAG%type,
       v_noShortSell IN GEC_ASSET.NO_SHORT_SELL_REALTIME%type,
       v_noNakedShortSell IN GEC_ASSET.NO_NAKED_SHORT_SELL%type
    );
    PROCEDURE UPDATE_ASSET(
       v_cusip IN GEC_ASSET.CUSIP%type, 
       v_sedol IN GEC_ASSET.SEDOL%type, 
       v_isin IN GEC_ASSET.ISIN%type, 
       v_ticker IN GEC_ASSET.TICKER%type, 
       v_description IN GEC_ASSET.DESCRIPTION%type, 
       v_sourceFlag IN GEC_ASSET.SOURCE_FLAG%type, 
       v_quik IN GEC_ASSET.QUIK%type, 
       v_updatedBy IN GEC_ASSET.UPDATED_BY%type, 
       v_priceCurrency IN GEC_ASSET.PRICE_CURRENCY_CD%type, 
       v_cleanPrice IN GEC_ASSET.CLEAN_PRICE%type, 
       v_dirtyPrice IN GEC_ASSET.DIRTY_PRICE%type,
       v_priceDate IN GEC_ASSET.PRICE_DATE%type, 
       v_asset_id IN GEC_ASSET.ASSET_ID%type,
       v_liquidity IN GEC_ASSET.LIQUIDITY_FLAG%type,
       v_noShortSell IN GEC_ASSET.NO_SHORT_SELL_REALTIME%type,
       v_noNakedShortSell IN GEC_ASSET.NO_NAKED_SHORT_SELL%type
      );
  PROCEDURE UPDATEASSET_FOR_LOCATESECMSTR(
   v_cusip IN GEC_ASSET.CUSIP%type, 
   v_sedol IN GEC_ASSET.SEDOL%type, 
   v_isin IN GEC_ASSET.ISIN%type, 
   v_ticker IN GEC_ASSET.TICKER%type,    
   v_quik IN GEC_ASSET.QUIK%type, 
   v_tradeCountryCd IN GEC_ASSET.TRADE_COUNTRY_CD%type, 
   v_description IN GEC_ASSET.DESCRIPTION%type, 
   v_updatedBy IN GEC_ASSET.UPDATED_BY%type, 
   v_priceCurrency IN GEC_ASSET.PRICE_CURRENCY_CD%type, 
   v_cleanPrice IN GEC_ASSET.CLEAN_PRICE%type, 
   v_dirtyPrice IN GEC_ASSET.DIRTY_PRICE%type, 
   v_priceDate IN GEC_ASSET.PRICE_DATE%type, 
   v_asset_id IN GEC_ASSET.ASSET_ID%type,
   v_liquidity IN GEC_ASSET.LIQUIDITY_FLAG%type,
   v_noShortSell IN GEC_ASSET.NO_SHORT_SELL_REALTIME%type,
   v_noNakedShortSell IN GEC_ASSET.NO_NAKED_SHORT_SELL%type 
      );
END GEC_ASSET_PKG;
/

create or replace
PACKAGE BODY GEC_ASSET_PKG AS
	PROCEDURE ADD_UPDATE_SECURITY_MASTER(secArray 	IN 	GEC_ASSET_TP_ARRAY)
	IS  
	TYPE ARRAY IS TABLE OF GEC_ASSET%ROWTYPE;
	l_data ARRAY;
	
	CURSOR v_updates IS
		SELECT ass.ASSET_ID, ass.CUSIP as O_CUSIP, ass.ISIN as O_ISIN, ass.SEDOL as O_SEDOL, ass.QUIK as O_QUIK, ass.TICKER as O_TICKER,
			in_ass.CUSIP, in_ass.ISIN, in_ass.SEDOL, in_ass.QUIK, in_ass.TICKER, 
			in_ass.DESCRIPTION, in_ass.TRADE_COUNTRY_CD, in_ass.ASSET_TYPE_ID
		FROM GEC_ASSET ass, TABLE ( cast ( secArray as GEC_ASSET_TP_ARRAY) ) in_ass
		WHERE 
				ass.CUSIP = in_ass.CUSIP AND ass.CUSIP IS NOT NULL; --OR
			--	(ass.SEDOL = in_ass.SEDOL AND ass.SEDOL IS NOT NULL) OR
			--	(ass.ISIN = in_ass.ISIN AND ass.ISIN IS NOT NULL AND ass.TRADE_COUNTRY_CD = in_ass.TRADE_COUNTRY_CD) OR
			--	(ass.QUIK = in_ass.QUIK AND ass.QUIK IS NOT NULL);

	CURSOR v_inserts IS
		SELECT GEC_ASSET_ID_SEQ.nextval as ASSET_ID, in_ass.CUSIP, in_ass.ISIN, in_ass.SEDOL, in_ass.QUIK, in_ass.ASSET_TYPE_ID,in_ass.TICKER, in_ass.DESCRIPTION, 'S' as SOURCE_FLAG, in_ass.TRADE_COUNTRY_CD, NULL as LAST_UPDATED_BY, NULL as LAST_UPDATED_AT
  		FROM TABLE ( cast ( secArray as GEC_ASSET_TP_ARRAY) ) in_ass
  		LEFT OUTER JOIN GEC_ASSET ass
    		ON ass.CUSIP = in_ass.CUSIP AND ass.CUSIP IS NOT NULL
    	--	OR (ass.SEDOL = in_ass.SEDOL AND ass.SEDOL IS NOT NULL)
    	--	OR (ass.ISIN = in_ass.ISIN AND ass.ISIN IS NOT NULL AND ass.TRADE_COUNTRY_CD = in_ass.TRADE_COUNTRY_CD)
    	--	OR (ass.QUIK = in_ass.QUIK AND ass.QUIK IS NOT NULL)
 		WHERE ass.asset_id IS NULL;

	BEGIN
		-- update the trade_country_cd to 2 letters for 3 letters' CD in gec_asset
		UPDATE GEC_ASSET ass
		SET ass.TRADE_COUNTRY_CD = NVL(( SELECT tc.TRADE_COUNTRY_CD
             						 FROM GEC_TRADE_COUNTRY tc
            						 WHERE tc.CURRENCY_CD = ass.TRADE_COUNTRY_CD  AND (tc.STATUS IS NULL OR tc.STATUS <> 'D') AND rownum = 1
								    ), ass.TRADE_COUNTRY_CD)
		WHERE 
			length(ass.TRADE_COUNTRY_CD) = 3 AND
                        EXISTS (SELECT 1 from GEC_TRADE_COUNTRY tc WHERE tc.CURRENCY_CD = ass.TRADE_COUNTRY_CD AND (tc.STATUS IS NULL OR tc.STATUS <> 'D'));

		-- lock the gec_asset, block the insert/update/delete operation on gec_asset from UI until commit/rollback, 
		-- select from UI will not be blocked
		LOCK TABLE gec_asset IN SHARE MODE;
		
		-- update the existed ones
		FOR v_update IN v_updates
		LOOP
			-- update gec_asset table
			UPDATE GEC_ASSET ass
			SET 
			--	SOURCE_FLAG = CASE WHEN (v_update.O_CUSIP IS NULL AND v_update.CUSIP IS NULL OR v_update.O_CUSIP IS NOT NULL AND v_update.CUSIP IS NOT NULL AND v_update.O_CUSIP = v_update.CUSIP) AND
			--							(v_update.O_ISIN IS NULL AND v_update.ISIN IS NULL   OR v_update.O_ISIN IS NOT NULL AND v_update.ISIN IS NOT NULL AND v_update.O_ISIN = v_update.ISIN) AND
			--							(v_update.O_SEDOL IS NULL AND v_update.SEDOL IS NULL OR v_update.O_SEDOL IS NOT NULL AND v_update.SEDOL IS NOT NULL AND v_update.O_SEDOL = v_update.SEDOL) AND
			--							(v_update.O_QUIK IS NULL AND v_update.QUIK IS NULL   OR v_update.O_QUIK IS NOT NULL AND v_update.QUIK IS NOT NULL AND v_update.O_QUIK = v_update.QUIK) AND
			--							(v_update.O_TICKER IS NULL AND v_update.TICKER IS NULL OR v_update.O_TICKER IS NOT NULL AND v_update.TICKER IS NOT NULL AND v_update.O_TICKER = v_update.TICKER)
			--					   THEN 'S' ELSE 'U' END,
				SOURCE_FLAG = 'S',
				CUSIP = v_update.CUSIP, 
				SEDOL = v_update.SEDOL, 
				ISIN = v_update.ISIN, 
				QUIK = v_update.QUIK, 
				TICKER = v_update.TICKER, 
				DESCRIPTION = v_update.DESCRIPTION, 
				TRADE_COUNTRY_CD = v_update.TRADE_COUNTRY_CD,
				ASSET_TYPE_ID = v_update.ASSET_TYPE_ID,
				UPDATED_BY = '',
				UPDATED_AT = sysdate
			WHERE ass.ASSET_ID = v_update.ASSET_ID;
                        -- update the record into GEC_ASSET_IDENTIFIER table.
                        ADD_UPDATE_ASSET_IDENTIFIER(v_update.CUSIP,v_update.SEDOL,v_update.ISIN,v_update.QUIK,v_update.TICKER, 
                        v_update.O_CUSIP,v_update.O_SEDOL,v_update.O_ISIN,v_update.O_QUIK,v_update.O_TICKER,v_update.ASSET_ID,0);
		END LOOP;

		-- insert the new ones which is not existed in current gec_asset table
		FOR v_insert IN v_inserts
		LOOP
			INSERT INTO GEC_ASSET(ASSET_ID, CUSIP, ISIN, SEDOL, QUIK, TICKER, DESCRIPTION, TRADE_COUNTRY_CD, SOURCE_FLAG, ASSET_TYPE_ID,UPDATED_BY, UPDATED_AT)
					VALUES(v_insert.ASSET_ID, v_insert.CUSIP, v_insert.ISIN, v_insert.SEDOL, v_insert.QUIK, v_insert.TICKER, v_insert.DESCRIPTION, v_insert.TRADE_COUNTRY_CD, v_insert.SOURCE_FLAG, v_insert.ASSET_TYPE_ID, '', sysdate);
                        -- insert the new record into GEC_ASSET_IDENTIFIER table.
                        ADD_UPDATE_ASSET_IDENTIFIER(v_insert.CUSIP,v_insert.SEDOL,v_insert.ISIN,v_insert.QUIK,v_insert.TICKER, 
                        NULL,NULL,NULL,NULL,NULL,v_insert.ASSET_ID,1);

                END LOOP;

    END ADD_UPDATE_SECURITY_MASTER;

	-- Load security price from DML file and update security price.
	-- seurityArray: security price records
	-- p_ret_fail_number: failed record number
	PROCEDURE UPDATE_OR_ADD_SECURITY_PRICE(
			securityArray		IN		GEC_ASSET_RATE_TP_ARRAY,
			p_ret_fail_number	OUT		NUMBER )
	IS
		V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_ASSET_PKG.UPDATE_OR_ADD_SECURITY_PRICE';
		v_total_count NUMBER(8);
		v_update_count NUMBER(8);
		v_fail_count NUMBER(8);
		CURSOR v_cur_update_records IS
			SELECT a.rowid as row_id, a.ASSET_ID, a.CUSIP, tp.PRICE_DATE, tp.PRICE_CURRENCY_CD, tp.CLEAN_PRICE, tp.DIRTY_PRICE
			  FROM gec_asset a, TABLE ( cast (securityArray as GEC_ASSET_RATE_TP_ARRAY) ) tp
			 WHERE a.cusip = tp.asset_code;
	BEGIN
		v_fail_count:= 0;
		v_update_count:= 0;
		-- get total number
		SELECT COUNT(1) INTO v_total_count FROM TABLE ( cast (securityArray as GEC_ASSET_RATE_TP_ARRAY) );

		-- lock the GEC_ASSET_RATE, block the insert/update operation on GEC_ASSET_RATE from UI until commit/rollback, 
		-- select from UI will not be blocked
		LOCK TABLE GEC_ASSET IN SHARE MODE;

		-- update the existed securities price
		FOR v_update IN v_cur_update_records
		LOOP
			-- update gec_asset_rate table
			UPDATE GEC_ASSET
			SET
				PRICE_CURRENCY_CD = v_update.PRICE_CURRENCY_CD,
				PRICE_DATE = v_update.PRICE_DATE,
				CLEAN_PRICE = v_update.CLEAN_PRICE,
				DIRTY_PRICE = v_update.DIRTY_PRICE,
				UPDATED_AT = sysdate,
				UPDATED_BY = GEC_CONSTANTS_PKG.C_SYSTEM
			WHERE rowid = v_update.row_id;
			v_update_count:= v_update_count + 1;
		END LOOP;

		-- get misMatch records number
		p_ret_fail_number:= v_total_count - v_update_count;
	EXCEPTION WHEN OTHERS THEN
		GEC_LOG_PKG.LOG_PERFORMANCE_EXCEPTION(V_PROCEDURE_NAME);
		RAISE;
	END UPDATE_OR_ADD_SECURITY_PRICE;

        PROCEDURE ADD_UPDATE_ASSET_IDENTIFIER(
          new_cusip IN GEC_ASSET.CUSIP%type, 
          new_sedol IN GEC_ASSET.SEDOL%type, 
          new_isin IN GEC_ASSET.ISIN%type, 
          new_quik IN GEC_ASSET.QUIK%type, 
          new_ticker IN GEC_ASSET.TICKER%type, 
          old_cusip IN GEC_ASSET.CUSIP%type, 
          old_sedol IN GEC_ASSET.SEDOL%type, 
          old_isin IN GEC_ASSET.ISIN%type, 
          old_quik IN GEC_ASSET.QUIK%type, 
          old_ticker IN GEC_ASSET.TICKER%type, 
          new_asset_id IN GEC_ASSET.ASSET_ID%type, 
          is_insert IN NUMBER
          ) 
          IS       
          V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_ASSET_PKG.ADD_UPDATE_ASSET_IDENTIFIER';
          v_asset_id GEC_ASSET.ASSET_ID%type;
          v_cusip GEC_ASSET.CUSIP%type; 
          v_sedol GEC_ASSET.SEDOL%type; 
          v_isin GEC_ASSET.ISIN%type;
          v_quik GEC_ASSET.QUIK%type;
          v_ticker GEC_ASSET.TICKER%type;
          BEGIN
          
          
          IF is_insert = 1 THEN
        
              IF new_cusip IS NOT NULL THEN
              INSERT INTO GEC_ASSET_IDENTIFIER(ASSET_CODE, ASSET_CODE_TYPE, ASSET_ID)
                  VALUES(new_cusip, 'CSP', new_asset_id);
              END IF;
              IF new_isin IS NOT NULL THEN
                  INSERT INTO GEC_ASSET_IDENTIFIER(ASSET_CODE, ASSET_CODE_TYPE, ASSET_ID)
                      VALUES(new_isin, 'ISN', new_asset_id);
              END IF;
              IF new_sedol IS NOT NULL THEN
                  INSERT INTO GEC_ASSET_IDENTIFIER(ASSET_CODE, ASSET_CODE_TYPE, ASSET_ID)
                      VALUES(new_sedol, 'SED', new_asset_id);
              END IF;
              IF new_quik IS NOT NULL THEN
                  INSERT INTO GEC_ASSET_IDENTIFIER(ASSET_CODE, ASSET_CODE_TYPE, ASSET_ID)
                      VALUES(new_quik, 'QUK', new_asset_id);
              END IF;
              IF new_ticker IS NOT NULL THEN
                  INSERT INTO GEC_ASSET_IDENTIFIER(ASSET_CODE, ASSET_CODE_TYPE, ASSET_ID)
                      VALUES(new_ticker, 'TIK', new_asset_id);
              END IF;
          ELSE 
                IF old_cusip IS NULL AND
                   old_sedol IS NULL AND
                   old_isin IS NULL AND
                   old_quik IS NULL AND
                   old_ticker IS NULL AND
                   new_asset_id IS NOT NULL THEN
                SELECT ass.CUSIP, ass.ISIN, ass.SEDOL, ass.QUIK, ass.TICKER
                  INTO v_cusip, v_isin, v_sedol, v_quik, v_ticker
                  FROM GEC_ASSET ass  
                  WHERE ass.ASSET_ID = new_asset_id;  
                ELSE
                  v_cusip := old_cusip;
                  v_sedol := old_sedol;
                  v_isin  := old_isin;
                  v_quik  := old_quik;
                  v_ticker:= old_ticker;
                END IF;
                
                -- UPDATE CUSIP
                      IF new_cusip IS NOT NULL THEN
                              IF v_cusip IS NULL THEN
                              -- INSERT INTO
                                              INSERT INTO GEC_ASSET_IDENTIFIER(ASSET_CODE, ASSET_CODE_TYPE, ASSET_ID) VALUES(new_cusip, 'CSP', new_asset_id);
                                      ELSIF v_cusip <>  new_cusip THEN
                                              -- UPDATE
                                              UPDATE 	GEC_ASSET_IDENTIFIER 
                                              SET		ASSET_CODE = new_cusip
                                              WHERE 	ASSET_ID = new_asset_id AND ASSET_CODE_TYPE = 'CSP';
                                      END IF;                       
                      ELSE
                              --DELETE FROM 
                              IF v_cusip IS NOT NULL THEN
                                      DELETE FROM GEC_ASSET_IDENTIFIER WHERE ASSET_ID = new_asset_id AND ASSET_CODE = v_cusip;
                              END IF;
                      END IF;
              
              -- UPDATE ISIN
                      IF new_isin IS NOT NULL THEN       
                      IF v_isin IS NULL THEN
                              -- INSERT INTO
                                      INSERT INTO GEC_ASSET_IDENTIFIER(ASSET_CODE, ASSET_CODE_TYPE, ASSET_ID) VALUES(new_isin, 'ISN', new_asset_id);
                              ELSIF v_isin <>  new_isin THEN
                                      -- UPDATE
                                      UPDATE 	GEC_ASSET_IDENTIFIER 
                                      SET		ASSET_CODE = new_isin
                                      WHERE 	ASSET_ID = new_asset_id AND ASSET_CODE_TYPE='ISN';
                              END IF;                       
                      ELSE
                      --DELETE FROM 
                      IF v_isin IS NOT NULL THEN
                              DELETE FROM GEC_ASSET_IDENTIFIER WHERE ASSET_ID = new_asset_id AND ASSET_CODE = v_isin;
                              END IF;                
              END IF;
              
               -- UPDATE SEDOL       
              IF new_sedol IS NOT NULL THEN
                              IF v_sedol IS NULL THEN
                              -- INSERT INTO
                                              INSERT INTO GEC_ASSET_IDENTIFIER(ASSET_CODE, ASSET_CODE_TYPE, ASSET_ID) VALUES(new_sedol, 'SED', new_asset_id);
                                      ELSIF v_sedol <>  new_sedol THEN
                                              -- UPDATE
                                              UPDATE 	GEC_ASSET_IDENTIFIER 
                                              SET		ASSET_CODE = new_sedol
                                              WHERE 	ASSET_ID = new_asset_id AND ASSET_CODE_TYPE='SED';
                                      END IF;                       
                      ELSE
                              --DELETE 
                              IF v_sedol IS NOT NULL THEN
                                      DELETE FROM GEC_ASSET_IDENTIFIER WHERE ASSET_ID = new_asset_id AND ASSET_CODE = v_sedol;
                              END IF;        
              END IF;
              
              --UPDATE QUIK
              IF new_quik IS NOT NULL THEN
                     
                              IF v_quik IS NULL THEN
                              -- INSERT 
                                              INSERT INTO GEC_ASSET_IDENTIFIER(ASSET_CODE, ASSET_CODE_TYPE, ASSET_ID) VALUES(new_quik, 'QUK', new_asset_id);
                                      ELSIF v_quik <>  new_quik THEN
                                              -- UPDATE
                                              UPDATE 	GEC_ASSET_IDENTIFIER 
                                              SET		ASSET_CODE = new_quik
                                              WHERE 	ASSET_ID = new_asset_id AND ASSET_CODE_TYPE='QUK';
                                      END IF;                       
                      ELSE
                              --DELETE  
                              IF v_quik IS NOT NULL THEN
                                      DELETE FROM GEC_ASSET_IDENTIFIER WHERE ASSET_ID = new_asset_id AND ASSET_CODE = v_quik;
                              END IF;       
              END IF;
              
              --UPDATE TICKER
              IF new_ticker IS NOT NULL THEN
              
                              IF v_ticker IS NULL THEN
                              -- INSERT INTO
                                              INSERT INTO GEC_ASSET_IDENTIFIER(ASSET_CODE, ASSET_CODE_TYPE, ASSET_ID) VALUES(new_ticker, 'TIK', new_asset_id);
                                      ELSIF v_ticker <>  new_ticker THEN
                                              -- UPDATE
                                              UPDATE 	GEC_ASSET_IDENTIFIER 
                                              SET		ASSET_CODE = new_ticker
                                              WHERE 	ASSET_ID = new_asset_id AND ASSET_CODE_TYPE='TIK';
                                      END IF;                       
                      ELSE
                              --DELETE 
                              IF v_ticker IS NOT NULL THEN
                                      DELETE FROM GEC_ASSET_IDENTIFIER WHERE ASSET_ID = new_asset_id AND ASSET_CODE = v_ticker;
                              END IF;        
              END IF;        
          END IF;
          
          
        END ADD_UPDATE_ASSET_IDENTIFIER;
        
        
        
       PROCEDURE ADD_ASSET(
       v_securityType IN GEC_ASSET.ASSET_TYPE_ID%type, 
       v_cusip IN GEC_ASSET.CUSIP%type, 
       v_sedol IN GEC_ASSET.SEDOL%type, 
       v_isin IN GEC_ASSET.ISIN%type, 
       v_ticker IN GEC_ASSET.TICKER%type, 
       v_description IN GEC_ASSET.DESCRIPTION%type, 
       v_sourceFlag IN GEC_ASSET.SOURCE_FLAG%type, 
       v_quik IN GEC_ASSET.QUIK%type, 
       v_tradeCountryCd IN GEC_ASSET.TRADE_COUNTRY_CD%type, 
       v_updatedBy IN GEC_ASSET.UPDATED_BY%type, 
       v_priceCurrency IN GEC_ASSET.PRICE_CURRENCY_CD%type, 
       v_cleanPrice IN GEC_ASSET.CLEAN_PRICE%type, 
       v_dirtyPrice IN GEC_ASSET.DIRTY_PRICE%type, 
       v_priceDate IN GEC_ASSET.PRICE_DATE%type, 
       v_assetID OUT GEC_ASSET.ASSET_ID%type,
       v_liquidity IN GEC_ASSET.LIQUIDITY_FLAG%type,
       v_noShortSell IN GEC_ASSET.NO_SHORT_SELL_REALTIME%type,
       v_noNakedShortSell IN GEC_ASSET.NO_NAKED_SHORT_SELL%type
        )
        IS
        V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_ASSET_PKG.ADD_ASSET';
        BEGIN
        
        GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
        
          SELECT GEC_ASSET_ID_SEQ.NEXTVAL INTO v_assetID FROM DUAL;
          INSERT INTO GEC_ASSET(
                    ASSET_ID, 
                    ASSET_TYPE_ID, 
                    CUSIP, 
                    SEDOL, 
                    ISIN, 
                    TICKER, 
                    DESCRIPTION, 
                    SOURCE_FLAG, 
                    QUIK, 
                    TRADE_COUNTRY_CD,
                    UPDATED_BY,
                    UPDATED_AT,
                    PRICE_CURRENCY_CD,
                    CLEAN_PRICE,
                    DIRTY_PRICE,
                    PRICE_DATE,
                    LIQUIDITY_FLAG,
                    NO_SHORT_SELL_REALTIME,
                    NO_NAKED_SHORT_SELL)
                          values( v_assetID,
                                  v_securityType,
                                  UPPER(TRIM(v_cusip)),
                                  UPPER(TRIM(v_sedol)),
                                  UPPER(TRIM(v_isin)),
                                  UPPER(TRIM(v_ticker)),
                                  UPPER(v_description),
                                  v_sourceFlag,
                                  UPPER(TRIM(v_quik)),
                                  v_tradeCountryCd,
                                  v_updatedBy,
                                  sysdate,
                                  TRIM(v_priceCurrency),
                                  v_cleanPrice,
                                  v_dirtyPrice,
                                  v_priceDate,
                                  DECODE(v_liquidity,
			   							GEC_CONSTANTS_PKG.C_LIQUID,
			   							GEC_CONSTANTS_PKG.C_LIQUID_DB,
			   							GEC_CONSTANTS_PKG.C_ILLIQUID,
			   							GEC_CONSTANTS_PKG.C_ILLIQUID_DB,
			   							GEC_CONSTANTS_PKG.C_NALIQUID,
			   							GEC_CONSTANTS_PKG.C_NALIQUID_DB,
			   							null),
                                  v_noShortSell,
                                  v_noNakedShortSell
                          );
            ADD_UPDATE_ASSET_IDENTIFIER(UPPER(TRIM(v_cusip)),UPPER(TRIM(v_sedol)),UPPER(TRIM(v_isin)),UPPER(TRIM(v_quik)),UPPER(trim(v_ticker)), 
                        NULL,NULL,NULL,NULL,NULL,v_assetID,1);

      GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME, 'S', 'SUCCESS');
      
      END ADD_ASSET;
      
      PROCEDURE UPDATE_ASSET(
       v_cusip IN GEC_ASSET.CUSIP%type, 
       v_sedol IN GEC_ASSET.SEDOL%type, 
       v_isin IN GEC_ASSET.ISIN%type, 
       v_ticker IN GEC_ASSET.TICKER%type, 
       v_description IN GEC_ASSET.DESCRIPTION%type, 
       v_sourceFlag IN GEC_ASSET.SOURCE_FLAG%type, 
       v_quik IN GEC_ASSET.QUIK%type, 
       v_updatedBy IN GEC_ASSET.UPDATED_BY%type, 
       v_priceCurrency IN GEC_ASSET.PRICE_CURRENCY_CD%type, 
       v_cleanPrice IN GEC_ASSET.CLEAN_PRICE%type, 
       v_dirtyPrice IN GEC_ASSET.DIRTY_PRICE%type,
       v_priceDate IN GEC_ASSET.PRICE_DATE%type, 
       v_asset_id IN GEC_ASSET.ASSET_ID%type,
       v_liquidity IN GEC_ASSET.LIQUIDITY_FLAG%type,
       v_noShortSell IN GEC_ASSET.NO_SHORT_SELL_REALTIME%type,
       v_noNakedShortSell IN GEC_ASSET.NO_NAKED_SHORT_SELL%type
      )
      IS
      V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_ASSET_PKG.UPDATE_ASSET';
      BEGIN
      
      GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
      
      ADD_UPDATE_ASSET_IDENTIFIER(UPPER(TRIM(v_cusip)),UPPER(TRIM(v_sedol)),UPPER(TRIM(v_isin)),UPPER(TRIM(v_quik)),UPPER(TRIM(v_ticker)), 
                        NULL,NULL,NULL,NULL,NULL,v_asset_id,0);
      
          UPDATE GEC_ASSET
		   SET CUSIP = NVL(UPPER(TRIM(v_cusip)), CUSIP),
		       ISIN = NVL(UPPER(TRIM(v_isin)), ISIN),
		       SEDOL = NVL(UPPER(TRIM(v_sedol)), SEDOL),
		       TICKER = NVL(UPPER(TRIM(v_ticker)), TICKER),
		       DESCRIPTION = NVL(TRIM(v_description), DESCRIPTION),
		       source_flag = v_sourceFlag,
		       updated_by = v_updatedBy,
		       updated_at = sysdate,
                       PRICE_CURRENCY_CD = v_priceCurrency,
                       CLEAN_PRICE  = v_cleanPrice,
                       DIRTY_PRICE = v_dirtyPrice,
                       PRICE_DATE  = v_priceDate,
                       LIQUIDITY_FLAG = DECODE(v_liquidity,
				   							GEC_CONSTANTS_PKG.C_LIQUID,
				   							GEC_CONSTANTS_PKG.C_LIQUID_DB,
				   							GEC_CONSTANTS_PKG.C_ILLIQUID,
				   							GEC_CONSTANTS_PKG.C_ILLIQUID_DB,
				   							GEC_CONSTANTS_PKG.C_NALIQUID,
				   							GEC_CONSTANTS_PKG.C_NALIQUID_DB,
				   							null),
         			   NO_SHORT_SELL_REALTIME = v_noShortSell,
              		   NO_NAKED_SHORT_SELL = v_noNakedShortSell
		 WHERE 
                        (
                         (TRIM(v_cusip) IS NOT NULL AND (CUSIP IS NULL OR CUSIP != UPPER(TRIM(v_cusip))))
                      OR (TRIM(v_isin) IS NOT NULL AND (ISIN IS NULL OR ISIN != UPPER(TRIM(v_isin))) )
                      OR (TRIM(v_sedol) IS NOT NULL AND (SEDOL IS NULL OR SEDOL != UPPER(TRIM(v_sedol))) )
                      OR (TRIM(v_ticker) IS NOT NULL AND (TICKER IS NULL OR TICKER != UPPER(TRIM(v_ticker))) )
                      OR (TRIM(v_description) IS NOT NULL AND (DESCRIPTION IS NULL OR DESCRIPTION != TRIM(v_description)) )
		 	)
		 	AND asset_id = v_asset_id;
                        
          GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME, 'S', 'SUCCESS');
          
      END UPDATE_ASSET;
      
      
      PROCEDURE UPDATEASSET_FOR_LOCATESECMSTR(
       v_cusip IN GEC_ASSET.CUSIP%type, 
       v_sedol IN GEC_ASSET.SEDOL%type, 
       v_isin IN GEC_ASSET.ISIN%type, 
       v_ticker IN GEC_ASSET.TICKER%type,    
       v_quik IN GEC_ASSET.QUIK%type, 
       v_tradeCountryCd IN GEC_ASSET.TRADE_COUNTRY_CD%type, 
       v_description IN GEC_ASSET.DESCRIPTION%type, 
       v_updatedBy IN GEC_ASSET.UPDATED_BY%type, 
       v_priceCurrency IN GEC_ASSET.PRICE_CURRENCY_CD%type, 
       v_cleanPrice IN GEC_ASSET.CLEAN_PRICE%type, 
       v_dirtyPrice IN GEC_ASSET.DIRTY_PRICE%type, 
       v_priceDate IN GEC_ASSET.PRICE_DATE%type, 
       v_asset_id IN GEC_ASSET.ASSET_ID%type,
       v_liquidity IN GEC_ASSET.LIQUIDITY_FLAG%type,
       v_noShortSell IN GEC_ASSET.NO_SHORT_SELL_REALTIME%type,
       v_noNakedShortSell IN GEC_ASSET.NO_NAKED_SHORT_SELL%type
      )
      IS
      V_PROCEDURE_NAME CONSTANT VARCHAR2(61) := 'GEC_ASSET_PKG.UPDATEASSET_FOR_LOCATESECMSTR';
      BEGIN
      
      GEC_LOG_PKG.LOG_PERFORMANCE_START(V_PROCEDURE_NAME);
      
      ADD_UPDATE_ASSET_IDENTIFIER(UPPER(TRIM(v_cusip)),UPPER(TRIM(v_sedol)),UPPER(TRIM(v_isin)),UPPER(TRIM(v_quik)),UPPER(TRIM(v_ticker)), 
                        NULL,NULL,NULL,NULL,NULL,v_asset_id,0);
         UPDATE GEC_ASSET
		   SET CUSIP  = UPPER(trim(v_cusip)),
		       ISIN   = UPPER(trim(v_isin)),
		       SEDOL  = UPPER(trim(v_sedol)),
		       TICKER = UPPER(trim(v_ticker)),
		       QUIK   = UPPER(trim(v_quik)),
		       TRADE_COUNTRY_CD = trim(v_tradeCountryCd),
		       DESCRIPTION = trim(v_description),
		       UPDATED_BY = v_updatedBy,
			   UPDATED_AT = sysdate
			   ,PRICE_CURRENCY_CD = TRIM(v_priceCurrency)
			   ,CLEAN_PRICE  = v_cleanPrice
			   ,DIRTY_PRICE = v_dirtyPrice
			   ,PRICE_DATE  = v_priceDate
			   ,LIQUIDITY_FLAG = DECODE(v_liquidity,
		   							 GEC_CONSTANTS_PKG.C_LIQUID,
		   							 GEC_CONSTANTS_PKG.C_LIQUID_DB,
		   							 GEC_CONSTANTS_PKG.C_ILLIQUID,
		   							 GEC_CONSTANTS_PKG.C_ILLIQUID_DB,
		   							 GEC_CONSTANTS_PKG.C_NALIQUID,
		   							 GEC_CONSTANTS_PKG.C_NALIQUID_DB,
		   							 null)
         	   ,NO_SHORT_SELL_REALTIME = v_noShortSell
         	   ,NO_NAKED_SHORT_SELL = v_noNakedShortSell
		 WHERE ASSET_ID = v_asset_id;
                 
        GEC_LOG_PKG.LOG_PERFORMANCE_END(V_PROCEDURE_NAME, 'S', 'SUCCESS');
        
      END UPDATEASSET_FOR_LOCATESECMSTR;
      
      
      
END GEC_ASSET_PKG;
/