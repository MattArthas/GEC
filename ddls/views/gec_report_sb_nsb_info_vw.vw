CREATE OR REPLACE VIEW GEC_REPORT_SB_NSB_INFO_VW AS
select 
  NVL(gec_sb_info.im_order_id,gec_nsb_info.im_order_id) as im_order_id,
  gec_sb_info.ACTUAL_SB_QTY,
  gec_sb_info.SB_LOAN_NO,
  gec_sb_info.SFP_SB_PRICE,
  gec_nsb_info.ACTUAL_NSB_QTY,
  gec_nsb_info.SFP_NSB_PRICE
  from
  (select 
    ga.im_order_id,
    sum(ga.ALLOCATION_QTY) AS ACTUAL_SB_QTY,
    max(gb.LOAN_NO) KEEP (DENSE_RANK FIRST ORDER BY (ga.borrow_id))  AS SB_LOAN_NO,
    max(gb.PRICE) KEEP (DENSE_RANK FIRST ORDER BY (ga.borrow_id)) AS SFP_SB_PRICE
    from gec_allocation ga,GEC_BORROW gb,gec_broker bk
    where ga.borrow_id = gb.borrow_id
    and   gb.broker_cd = bk.broker_cd
    and bk.borrow_request_type = 'SB'
    group by ga.im_order_id)  gec_sb_info
  full outer join 
(select 
  ga.im_order_id,
  sum(ga.ALLOCATION_QTY) AS ACTUAL_NSB_QTY,  
  max(gb.PRICE) KEEP (DENSE_RANK FIRST ORDER BY (ga.borrow_id)) AS SFP_NSB_PRICE  
  from gec_allocation ga,GEC_BORROW gb,gec_broker bk
  where ga.borrow_id = gb.borrow_id
  and   gb.broker_cd = bk.broker_cd
  and bk.borrow_request_type = 'NSB'
  group by ga.im_order_id )  gec_nsb_info
  on gec_sb_info.im_order_id = gec_nsb_info.im_order_id;