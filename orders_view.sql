CREATE OR REPLACE VIEW analysis.orders AS  
SELECT 	DISTINCT prod_ord.order_id, 
		prod_ord.order_ts, 
		prod_ord.user_id, 
		prod_ord.bonus_payment, 
		prod_ord.payment, 
		prod_ord.cost, 
		prod_ord.bonus_grant, 
		inc.status 
FROM ( 
  	SELECT 	DISTINCT order_id, 
			ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY dttm DESC) AS last_date,
			status_id as status
  	FROM production.orderstatuslog 
  	GROUP BY order_id, status_id, dttm 
  	) AS inc 
RIGHT JOIN production.orders AS prod_ord ON inc.order_id=prod_ord.order_id 
WHERE inc.last_date = 1
GROUP BY prod_ord.order_id, inc.status;