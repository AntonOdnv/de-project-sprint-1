INSERT INTO analysis.tmp_rfm_monetary_value (user_id, monetary_value)
SELECT usr.id AS user_id,
	   NTILE(5) OVER (ORDER BY SUM(orders_data.order_sum) ASC NULLS FIRST) AS monetary_value
FROM (
  	SELECT DISTINCT ord.user_id AS user_id,
    	   SUM(ord.cost) AS order_sum
	FROM analysis.orders AS ord
  	WHERE ord.status = 4
	GROUP BY ord.user_id
) AS orders_data
RIGHT JOIN analysis.users AS usr ON orders_data.user_id=usr.id
GROUP BY usr.id, orders_data.order_sum
ORDER BY monetary_value ASC;