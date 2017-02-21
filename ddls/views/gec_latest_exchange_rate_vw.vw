CREATE OR REPLACE VIEW GEC_LATEST_EXCHANGE_RATE_VW AS
	select max(exchange_date) as exchange_date, 
		   exchange_currency_cd 
		   from gec_exchange_rate group by exchange_currency_cd;