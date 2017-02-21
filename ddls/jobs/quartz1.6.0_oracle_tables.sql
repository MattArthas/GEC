--
-- A hint submitted by a user: Oracle DB MUST be created as "shared" and the 
-- job_queue_processes parameter  must be greater than 2, otherwise a DB lock 
-- will happen.   However, these settings are pretty much standard after any
-- Oracle install, so most users need not worry about this.
--

delete from qtz_job_listeners;
delete from qtz_trigger_listeners;
delete from qtz_fired_triggers;
delete from qtz_simple_triggers;
delete from qtz_cron_triggers;
delete from qtz_blob_triggers;
delete from qtz_triggers;
delete from qtz_job_details;
delete from qtz_calendars;
delete from qtz_paused_trigger_grps;
delete from qtz_locks;
delete from qtz_scheduler_state;

drop table qtz_calendars;
drop table qtz_fired_triggers;
drop table qtz_trigger_listeners;
drop table qtz_blob_triggers;
drop table qtz_cron_triggers;
drop table qtz_simple_triggers;
drop table qtz_triggers;
drop table qtz_job_listeners;
drop table qtz_job_details;
drop table qtz_paused_trigger_grps;
drop table qtz_locks;
drop table qtz_scheduler_state;


CREATE TABLE qtz_job_details
  (
    JOB_NAME  VARCHAR2(80) NOT NULL,
    JOB_GROUP VARCHAR2(80) NOT NULL,
    DESCRIPTION VARCHAR2(120) NULL,
    JOB_CLASS_NAME   VARCHAR2(128) NOT NULL, 
    IS_DURABLE VARCHAR2(1) NOT NULL,
    IS_VOLATILE VARCHAR2(1) NOT NULL,
    IS_STATEFUL VARCHAR2(1) NOT NULL,
    REQUESTS_RECOVERY VARCHAR2(1) NOT NULL,
    JOB_DATA BLOB NULL
)TABLESPACE GEC;
CREATE TABLE qtz_job_listeners
  (
    JOB_NAME  VARCHAR2(80) NOT NULL, 
    JOB_GROUP VARCHAR2(80) NOT NULL,
    JOB_LISTENER VARCHAR2(80) NOT NULL
)TABLESPACE GEC;
CREATE TABLE qtz_triggers
  (
    TRIGGER_NAME VARCHAR2(80) NOT NULL,
    TRIGGER_GROUP VARCHAR2(80) NOT NULL,
    JOB_NAME  VARCHAR2(80) NOT NULL, 
    JOB_GROUP VARCHAR2(80) NOT NULL,
    IS_VOLATILE VARCHAR2(1) NOT NULL,
    DESCRIPTION VARCHAR2(120) NULL,
    NEXT_FIRE_TIME NUMBER(13) NULL,
    PREV_FIRE_TIME NUMBER(13) NULL,
    PRIORITY NUMBER(13) NULL,
    TRIGGER_STATE VARCHAR2(16) NOT NULL,
    TRIGGER_TYPE VARCHAR2(8) NOT NULL,
    START_TIME NUMBER(13) NOT NULL,
    END_TIME NUMBER(13) NULL,
    CALENDAR_NAME VARCHAR2(80) NULL,
    MISFIRE_INSTR NUMBER(2) NULL,
    JOB_DATA BLOB NULL
)TABLESPACE GEC;
CREATE TABLE qtz_simple_triggers
  (
    TRIGGER_NAME VARCHAR2(80) NOT NULL,
    TRIGGER_GROUP VARCHAR2(80) NOT NULL,
    REPEAT_COUNT NUMBER(7) NOT NULL,
    REPEAT_INTERVAL NUMBER(12) NOT NULL,
    TIMES_TRIGGERED NUMBER(7) NOT NULL
)TABLESPACE GEC;
CREATE TABLE qtz_cron_triggers
  (
    TRIGGER_NAME VARCHAR2(80) NOT NULL,
    TRIGGER_GROUP VARCHAR2(80) NOT NULL,
    CRON_EXPRESSION VARCHAR2(80) NOT NULL,
    TIME_ZONE_ID VARCHAR2(80)
)TABLESPACE GEC;
CREATE TABLE qtz_blob_triggers
  (
    TRIGGER_NAME VARCHAR2(80) NOT NULL,
    TRIGGER_GROUP VARCHAR2(80) NOT NULL,
    BLOB_DATA BLOB NULL
)TABLESPACE GEC;
CREATE TABLE qtz_trigger_listeners
  (
    TRIGGER_NAME  VARCHAR2(80) NOT NULL, 
    TRIGGER_GROUP VARCHAR2(80) NOT NULL,
    TRIGGER_LISTENER VARCHAR2(80) NOT NULL
)TABLESPACE GEC;
CREATE TABLE qtz_calendars
  (
    CALENDAR_NAME  VARCHAR2(80) NOT NULL, 
    CALENDAR BLOB NOT NULL
)TABLESPACE GEC;
CREATE TABLE qtz_paused_trigger_grps
  (
    TRIGGER_GROUP  VARCHAR2(80) NOT NULL
)TABLESPACE GEC;
CREATE TABLE qtz_fired_triggers 
  (
    ENTRY_ID VARCHAR2(95) NOT NULL,
    TRIGGER_NAME VARCHAR2(80) NOT NULL,
    TRIGGER_GROUP VARCHAR2(80) NOT NULL,
    IS_VOLATILE VARCHAR2(1) NOT NULL,
    INSTANCE_NAME VARCHAR2(80) NOT NULL,
    FIRED_TIME NUMBER(13) NOT NULL,
    PRIORITY NUMBER(13) NOT NULL,
    STATE VARCHAR2(16) NOT NULL,
    JOB_NAME VARCHAR2(80) NULL,
    JOB_GROUP VARCHAR2(80) NULL,
    IS_STATEFUL VARCHAR2(1) NULL,
    REQUESTS_RECOVERY VARCHAR2(1) NULL
)TABLESPACE GEC;
CREATE TABLE qtz_scheduler_state 
  (
    INSTANCE_NAME VARCHAR2(80) NOT NULL,
    LAST_CHECKIN_TIME NUMBER(13) NOT NULL,
    CHECKIN_INTERVAL NUMBER(13) NOT NULL
)TABLESPACE GEC;
CREATE TABLE qtz_locks
  (
    LOCK_NAME  VARCHAR2(40) NOT NULL
)TABLESPACE GEC;
INSERT INTO qtz_locks values('TRIGGER_ACCESS');
INSERT INTO qtz_locks values('JOB_ACCESS');
INSERT INTO qtz_locks values('CALENDAR_ACCESS');
INSERT INTO qtz_locks values('STATE_ACCESS');
INSERT INTO qtz_locks values('MISFIRE_ACCESS');
create index idx_qtz_j_req_recovery on qtz_job_details(REQUESTS_RECOVERY) TABLESPACE GEC;
create index idx_qtz_t_next_fire_time on qtz_triggers(NEXT_FIRE_TIME) TABLESPACE GEC;
create index idx_qtz_t_state on qtz_triggers(TRIGGER_STATE) TABLESPACE GEC;
create index idx_qtz_t_nft_st on qtz_triggers(NEXT_FIRE_TIME,TRIGGER_STATE) TABLESPACE GEC;
create index idx_qtz_t_volatile on qtz_triggers(IS_VOLATILE) TABLESPACE GEC;
create index idx_qtz_ft_trig_name on qtz_fired_triggers(TRIGGER_NAME) TABLESPACE GEC;
create index idx_qtz_ft_trig_group on qtz_fired_triggers(TRIGGER_GROUP) TABLESPACE GEC;
create index idx_qtz_ft_trig_nm_gp on qtz_fired_triggers(TRIGGER_NAME,TRIGGER_GROUP) TABLESPACE GEC;
create index idx_qtz_ft_trig_volatile on qtz_fired_triggers(IS_VOLATILE) TABLESPACE GEC;
create index idx_qtz_ft_trig_inst_name on qtz_fired_triggers(INSTANCE_NAME) TABLESPACE GEC;
create index idx_qtz_ft_job_name on qtz_fired_triggers(JOB_NAME) TABLESPACE GEC;
create index idx_qtz_ft_job_group on qtz_fired_triggers(JOB_GROUP) TABLESPACE GEC;
create index idx_qtz_ft_job_stateful on qtz_fired_triggers(IS_STATEFUL) TABLESPACE GEC;
create index idx_qtz_ft_job_req_recovery on qtz_fired_triggers(REQUESTS_RECOVERY) TABLESPACE GEC;

-- Add explicit name for Primary Key.
ALTER TABLE QTZ_TRIGGER_LISTENERS 
	ADD ( CONSTRAINT QTZ_TRIGGER_LISTENERS_PK PRIMARY KEY (TRIGGER_NAME,TRIGGER_GROUP,TRIGGER_LISTENER) USING INDEX TABLESPACE GEC ) ;
ALTER TABLE QTZ_TRIGGERS 
	ADD ( CONSTRAINT QTZ_TRIGGERS_PK PRIMARY KEY (TRIGGER_NAME,TRIGGER_GROUP) USING INDEX TABLESPACE GEC ) ;
ALTER TABLE QTZ_SIMPLE_TRIGGERS 
	ADD ( CONSTRAINT QTZ_SIMPLE_TRIGGERS_PK PRIMARY KEY (TRIGGER_NAME,TRIGGER_GROUP) USING INDEX TABLESPACE GEC ) ;
ALTER TABLE QTZ_SCHEDULER_STATE 
	ADD ( CONSTRAINT QTZ_SCHEDULER_STATE_PK PRIMARY KEY (INSTANCE_NAME) USING INDEX TABLESPACE GEC ) ;
ALTER TABLE QTZ_PAUSED_TRIGGER_GRPS 
	ADD ( CONSTRAINT QTZ_PAUSED_TRIGGER_GRPS_PK PRIMARY KEY (TRIGGER_GROUP) USING INDEX TABLESPACE GEC ) ;
ALTER TABLE QTZ_LOCKS 
	ADD ( CONSTRAINT QTZ_LOCKS_PK PRIMARY KEY (LOCK_NAME) USING INDEX TABLESPACE GEC ) ;
ALTER TABLE QTZ_JOB_LISTENERS 
	ADD ( CONSTRAINT QTZ_JOB_LISTENERS_PK PRIMARY KEY (JOB_NAME,JOB_GROUP,JOB_LISTENER) USING INDEX TABLESPACE GEC ) ;
ALTER TABLE QTZ_JOB_DETAILS 
	ADD ( CONSTRAINT QTZ_JOB_DETAILS_PK PRIMARY KEY (JOB_NAME,JOB_GROUP) USING INDEX TABLESPACE GEC ) ;
ALTER TABLE QTZ_FIRED_TRIGGERS 
	ADD ( CONSTRAINT QTZ_FIRED_TRIGGERS_PK PRIMARY KEY (ENTRY_ID) USING INDEX TABLESPACE GEC ) ;
ALTER TABLE QTZ_CRON_TRIGGERS 
	ADD ( CONSTRAINT QTZ_CRON_TRIGGERS_PK PRIMARY KEY (TRIGGER_NAME,TRIGGER_GROUP) USING INDEX TABLESPACE GEC ) ;
ALTER TABLE QTZ_CALENDARS 
	ADD ( CONSTRAINT QTZ_CALENDARS_PK PRIMARY KEY (CALENDAR_NAME) USING INDEX TABLESPACE GEC ) ;
ALTER TABLE QTZ_BLOB_TRIGGERS 
	ADD ( CONSTRAINT QTZ_BLOB_TRIGGERS_PK PRIMARY KEY (TRIGGER_NAME,TRIGGER_GROUP) USING INDEX TABLESPACE GEC ) ;

-- Add explicit name for Foreign Key.
ALTER TABLE QTZ_JOB_LISTENERS
  ADD CONSTRAINT QTZ_JOB_LISTENERS_FK FOREIGN KEY (JOB_NAME,JOB_GROUP) 
	REFERENCES QTZ_JOB_DETAILS(JOB_NAME,JOB_GROUP);   

ALTER TABLE QTZ_TRIGGERS
  ADD CONSTRAINT QTZ_TRIGGERS_FK FOREIGN KEY (JOB_NAME,JOB_GROUP) 
  REFERENCES QTZ_JOB_DETAILS(JOB_NAME,JOB_GROUP);   
  
ALTER TABLE QTZ_SIMPLE_TRIGGERS
  ADD CONSTRAINT QTZ_SIMPLE_TRIGGERS_FK FOREIGN KEY (TRIGGER_NAME,TRIGGER_GROUP) 
	REFERENCES QTZ_TRIGGERS(TRIGGER_NAME,TRIGGER_GROUP);
    
ALTER TABLE QTZ_CRON_TRIGGERS
  ADD CONSTRAINT QTZ_CRON_TRIGGERS_FK FOREIGN KEY (TRIGGER_NAME,TRIGGER_GROUP) 
	REFERENCES QTZ_TRIGGERS(TRIGGER_NAME,TRIGGER_GROUP);

ALTER TABLE QTZ_BLOB_TRIGGERS
  ADD CONSTRAINT QTZ_BLOB_TRIGGERS_FK FOREIGN KEY (TRIGGER_NAME,TRIGGER_GROUP) 
        REFERENCES QTZ_TRIGGERS(TRIGGER_NAME,TRIGGER_GROUP);
		    
ALTER TABLE QTZ_TRIGGER_LISTENERS
  ADD CONSTRAINT QTZ_TRIGGER_LISTENERS_FK FOREIGN KEY (TRIGGER_NAME,TRIGGER_GROUP) 
	REFERENCES QTZ_TRIGGERS(TRIGGER_NAME,TRIGGER_GROUP);
        

commit;