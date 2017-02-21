CREATE OR REPLACE VIEW GEC_COLLATERAL_TYPE_MAP
AS 
    SELECT 
    EQL_COLLATERAL_TYPE_ID COLLATERAL_TYPE_MAP_ID,
    EQL_COLLATERAL_TYPE EXTERNAL_COLLATERAL_TYPE,
    SUBACCOUNT_ID||EQL_COLLATERAL_TYPE_DESC SUBTYPE,
    GEC_COLLATERAL_TYPE GEC_COLLATERAL_TYPE,
    'Equilend' SOURCE,
    LAST_UPDATED_AT LAST_UPDATED_AT,
    LAST_UPDATED_BY LAST_UPDATED_BY
    FROM 
    GEC_EQL_COLLATERAL_TYPE;