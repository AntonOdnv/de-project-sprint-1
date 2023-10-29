INSERT INTO analysis.dm_rfm_segments (user_id, recency, frequency, monetary_value)
SELECT DISTINCT trr.user_id AS user_id,
	   trr.recency AS recency,
	   trf.frequency AS frequency,
	   trmv.monetary_value AS monetary_value
FROM analysis.tmp_rfm_recency AS trr
LEFT JOIN analysis.tmp_rfm_frequency AS trf ON trr.user_id = trf.user_id	
LEFT JOIN analysis.tmp_rfm_monetary_value AS trmv ON trr.user_id = trmv.user_id
ORDER BY trr.user_id
LIMIT 10;