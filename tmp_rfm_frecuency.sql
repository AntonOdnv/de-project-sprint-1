INSERT INTO analysis.tmp_rfm_frequency (user_id, frequency)
SELECT  usr.id AS user_id,
		NTILE(5) OVER (ORDER BY orders_data.count_orders ASC NULLS FIRST) AS frequency
FROM (
  	SELECT DISTINCT ord.user_id AS user_id,
    	   COUNT(ord.order_id) AS count_orders
	FROM analysis.orders AS ord
  	WHERE ord.status = 4
	GROUP BY ord.user_id
) AS orders_data
RIGHT JOIN analysis.users AS usr ON orders_data.user_id=usr.id
GROUP BY usr.id, orders_data.count_orders
ORDER BY frequency ASC;