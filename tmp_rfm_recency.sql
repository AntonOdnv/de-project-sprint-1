INSERT INTO analysis.tmp_rfm_recency (user_id, recency)
SELECT usr.id AS user_id,
	   NTILE(5) OVER (ORDER BY orders_data.last_date ASC NULLS FIRST) AS recency
FROM (
  	SELECT DISTINCT ord.user_id AS user_id,
    	   MAX(ord.order_ts) AS last_date
	FROM analysis.orders as ord
  	WHERE ord.status = 4
	GROUP BY ord.user_id
) AS orders_data
RIGHT JOIN analysis.users AS usr ON orders_data.user_id=usr.id
GROUP BY usr.id, orders_data.last_date
ORDER BY recency ASC;