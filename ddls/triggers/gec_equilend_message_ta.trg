CREATE OR REPLACE TRIGGER GEC_EQUILEND_MESSAGE_TA                                                                                                               
   BEFORE INSERT OR UPDATE OR DELETE
   ON GEC_EQUILEND_MESSAGE
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

   IF v_opCode = 'I' OR 
            (v_opCode = 'U' AND GEC_UTILS_PKG.COMPARE_BLOB(:OLD.MESSAGE_CONTENT, :NEW.MESSAGE_CONTENT) != 0) THEN
       INSERT INTO GEC_EQUILEND_MESSAGE_AUD(
              EQUILEND_MESSAGE_ID, 
               MESSAGE_TYPE, 
               MESSAGE_SUB_TYPE, 
               EQL_PROGRAM_REF, 
               JMS_MESSAGE_ID, 
               JMS_MESSAGE_TIMESTAMP, 
               STATUS, 
               STATUS_MSG,
               MESSAGE_CONTENT, 
               IN_OUT, 
               CREATED_AT, 
               CREATED_BY, 
               LAST_UPDATED_BY,
               LAST_UPDATED_AT,
               OP_CODE
          )
       VALUES (
             :NEW.EQUILEND_MESSAGE_ID,
             :NEW.MESSAGE_TYPE,
             :NEW.MESSAGE_SUB_TYPE,
             :NEW.EQL_PROGRAM_REF,
             :NEW.JMS_MESSAGE_ID,
             :NEW.JMS_MESSAGE_TIMESTAMP,
             :NEW.STATUS,
             :NEW.STATUS_MSG,
             :NEW.MESSAGE_CONTENT,
             :NEW.IN_OUT,
             :NEW.CREATED_AT,
             :NEW.CREATED_BY,
              substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                        sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
             SYSDATE,
             v_opCode
       );
   ELSE
          INSERT INTO GEC_EQUILEND_MESSAGE_AUD(
             EQUILEND_MESSAGE_ID, 
             MESSAGE_TYPE, 
             MESSAGE_SUB_TYPE, 
             EQL_PROGRAM_REF, 
             JMS_MESSAGE_ID, 
             JMS_MESSAGE_TIMESTAMP, 
             STATUS, 
             STATUS_MSG,
             MESSAGE_CONTENT, 
             IN_OUT, 
             CREATED_AT, 
             CREATED_BY, 
             LAST_UPDATED_BY,
             LAST_UPDATED_AT,
             OP_CODE
          )
       VALUES (
              DECODE(v_opCode, 'D', :OLD.EQUILEND_MESSAGE_ID, :NEW.EQUILEND_MESSAGE_ID), 
               DECODE(v_opCode, 'D', :OLD.MESSAGE_TYPE, :NEW.MESSAGE_TYPE), 
               DECODE(v_opCode, 'D', :OLD.MESSAGE_SUB_TYPE, :NEW.MESSAGE_SUB_TYPE), 
               DECODE(v_opCode, 'D', :OLD.EQL_PROGRAM_REF, :NEW.EQL_PROGRAM_REF), 
               DECODE(v_opCode, 'D', :OLD.JMS_MESSAGE_ID, :NEW.JMS_MESSAGE_ID), 
               DECODE(v_opCode, 'D', :OLD.JMS_MESSAGE_TIMESTAMP, :NEW.JMS_MESSAGE_TIMESTAMP), 
               DECODE(v_opCode, 'D', :OLD.STATUS, :NEW.STATUS), 
               DECODE(V_OPCODE, 'D', :OLD.STATUS_MSG, :NEW.STATUS_MSG),
             NULL,
            DECODE(v_opCode, 'D', :OLD.IN_OUT, :NEW.IN_OUT), 
             DECODE(v_opCode, 'D', :OLD.CREATED_AT, :NEW.CREATED_AT), 
             DECODE(v_opCode, 'D', :OLD.CREATED_BY, :NEW.CREATED_BY), 
             substr(NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
                        sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')),1,32),
             SYSDATE,
             v_opCode
       );
   END IF;
      
  END GEC_EQUILEND_MESSAGE_TA;
/