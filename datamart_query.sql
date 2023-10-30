INSERT INTO analysis.dm_rfm_segments (user_id, recency, frequency, monetary_value)
SELECT DISTINCT trr.user_id AS user_id,
	   trr.recency AS recency,
	   trf.frequency AS frequency,
	   trmv.monetary_value AS monetary_value
FROM analysis.tmp_rfm_recency AS trr
LEFT JOIN analysis.tmp_rfm_frequency AS trf ON trr.user_id = trf.user_id	
LEFT JOIN analysis.tmp_rfm_monetary_value AS trmv ON trr.user_id = trmv.user_id
ORDER BY trr.user_id;

user_id | recency | frequency | monetary_value
----------------------------------------------
    0   |	 1    | 	3     | 	4
    1   |	 4    |	    3     |	    3
    2   |	 2    |	    3     |	    5
    3   |	 2    |	    4     |	    3
    4   |	 4    |	    3     |	    3
    5   |	 5    |	    5     |	    5
    6   |	 1    |	    3     |	    5
    7   |	 4    |	    2     |	    2
    8   |	 1    |	    2     |	    3
    9   |	 1    |	    2     |	    2