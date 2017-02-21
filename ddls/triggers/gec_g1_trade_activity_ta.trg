CREATE OR REPLACE TRIGGER GEC_G1_TRADE_ACTIVITY_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE OF 
         G1_TRADE_ACTIVITY_ID, 
         G1_MESSAGE_ID, 
         AREA_ID, 
         SFP_LEAGAL_ENTITY_ID, 
         BGNREF, 
         CPTY, 
         STOCK, 
         COLL_FLG, 
         CASH, 
         LNCUR, 
         ACT_TYPE, 
         EFF_DT, 
         TRADE, 
         CSDT, 
         SSDT, 
         LNRATE, 
         ACT_QTY, 
         DIV_AGE_6DP, 
         DIV_DOM_6DP, 
         BL, 
         CNTRY_ISS, 
         DVP, 
         USR_FLD1, 
         INS_REQD, 
         AMENDMENT, 
         AUTH_USER_ID, 
         AUTH_REQD, 
         CREATED_AT, 
         CREATED_BY, 
         ACT_PRC, 
         ACT_VALUE, 
         TERMDT, 
         USR_FLD2, 
         USER_ID,
         DIV_OSEAS_6DP
   ON GEC_G1_TRADE_ACTIVITY
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

   INSERT INTO GEC_G1_TRADE_ACTIVITY_AUD(
         G1_TRADE_ACTIVITY_ID, 
         G1_MESSAGE_ID, 
         AREA_ID, 
         SFP_LEAGAL_ENTITY_ID, 
         BGNREF, 
         CPTY, 
         STOCK, 
         COLL_FLG, 
         CASH, 
         LNCUR, 
         ACT_TYPE, 
         EFF_DT, 
         TRADE, 
         CSDT, 
         SSDT, 
         LNRATE, 
         ACT_QTY, 
         DIV_AGE_6DP, 
         DIV_DOM_6DP, 
         BL, 
         CNTRY_ISS, 
         DVP, 
         USR_FLD1, 
         INS_REQD, 
         AMENDMENT, 
         AUTH_USER_ID, 
         AUTH_REQD, 
         CREATED_AT, 
         CREATED_BY, 
         ACT_PRC, 
         ACT_VALUE, 
         TERMDT, 
         USR_FLD2, 
         USER_ID,
         DIV_OSEAS_6DP,
         LAST_UPDATED_BY,
         LAST_UPDATED_AT,
         OP_CODE
      )
   VALUES (
         DECODE(v_opCode, 'D', :OLD.G1_TRADE_ACTIVITY_ID, :NEW.G1_TRADE_ACTIVITY_ID), 
         DECODE(v_opCode, 'D', :OLD.G1_MESSAGE_ID, :NEW.G1_MESSAGE_ID), 
         DECODE(v_opCode, 'D', :OLD.AREA_ID, :NEW.AREA_ID), 
         DECODE(v_opCode, 'D', :OLD.SFP_LEAGAL_ENTITY_ID, :NEW.SFP_LEAGAL_ENTITY_ID), 
         DECODE(v_opCode, 'D', :OLD.BGNREF, :NEW.BGNREF), 
         DECODE(v_opCode, 'D', :OLD.CPTY, :NEW.CPTY), 
         DECODE(v_opCode, 'D', :OLD.STOCK, :NEW.STOCK), 
         DECODE(v_opCode, 'D', :OLD.COLL_FLG, :NEW.COLL_FLG), 
         DECODE(v_opCode, 'D', :OLD.CASH, :NEW.CASH), 
         DECODE(v_opCode, 'D', :OLD.LNCUR, :NEW.LNCUR), 
         DECODE(v_opCode, 'D', :OLD.ACT_TYPE, :NEW.ACT_TYPE), 
         DECODE(v_opCode, 'D', :OLD.EFF_DT, :NEW.EFF_DT), 
         DECODE(v_opCode, 'D', :OLD.TRADE, :NEW.TRADE), 
         DECODE(v_opCode, 'D', :OLD.CSDT, :NEW.CSDT), 
         DECODE(v_opCode, 'D', :OLD.SSDT, :NEW.SSDT), 
         DECODE(v_opCode, 'D', :OLD.LNRATE, :NEW.LNRATE), 
         DECODE(v_opCode, 'D', :OLD.ACT_QTY, :NEW.ACT_QTY), 
         DECODE(v_opCode, 'D', :OLD.DIV_AGE_6DP, :NEW.DIV_AGE_6DP), 
         DECODE(v_opCode, 'D', :OLD.DIV_DOM_6DP, :NEW.DIV_DOM_6DP), 
         DECODE(v_opCode, 'D', :OLD.BL, :NEW.BL), 
         DECODE(v_opCode, 'D', :OLD.CNTRY_ISS, :NEW.CNTRY_ISS), 
         DECODE(v_opCode, 'D', :OLD.DVP, :NEW.DVP), 
         DECODE(v_opCode, 'D', :OLD.USR_FLD1, :NEW.USR_FLD1), 
         DECODE(v_opCode, 'D', :OLD.INS_REQD, :NEW.INS_REQD), 
         DECODE(v_opCode, 'D', :OLD.AMENDMENT, :NEW.AMENDMENT), 
         DECODE(v_opCode, 'D', :OLD.AUTH_USER_ID, :NEW.AUTH_USER_ID), 
         DECODE(v_opCode, 'D', :OLD.AUTH_REQD, :NEW.AUTH_REQD), 
         DECODE(v_opCode, 'D', :OLD.CREATED_AT, :NEW.CREATED_AT), 
         DECODE(v_opCode, 'D', :OLD.CREATED_BY, :NEW.CREATED_BY), 
         DECODE(v_opCode, 'D', :OLD.ACT_PRC, :NEW.ACT_PRC), 
         DECODE(v_opCode, 'D', :OLD.ACT_VALUE, :NEW.ACT_VALUE), 
         DECODE(v_opCode, 'D', :OLD.TERMDT, :NEW.TERMDT), 
         DECODE(v_opCode, 'D', :OLD.USR_FLD2, :NEW.USR_FLD2), 
         DECODE(v_opCode, 'D', :OLD.USER_ID, :NEW.USER_ID),
         DECODE(v_opCode, 'D', :OLD.DIV_OSEAS_6DP, :NEW.DIV_OSEAS_6DP),
         substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), 
                    sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
         SYSDATE,
         v_opCode
   );

END GEC_G1_TRADE_ACTIVITY_TA;
/
