WITH new_fraudsters as(

WITH pattern as(
	WITH B as (
		WITH A as(
		SELECT *
		FROM transactions
		LEFT JOIN fraudsters
		ON fraudsters.user_id=transactions.USER_ID
		WHERE fraudsters.user_id is not null
		ORDER BY user_id, created_date
		)

	SELECT user_id, CREATED_DATE, amount, Count(*) OVER (partition by user_id) as cuenta, avg(amount) OVER (partition by user_id) as mean_amount, power(amount - avg(amount) OVER (partition by user_id),2) as suma
	from A
	order by user_id, created_date
	)
	SELECT DISTINCT user_id as p_user_id, mean_amount as p_mean_amount, sqrt(sum(suma) OVER (partition by user_id)/cuenta) p_stdev
	from B
),
tran as (
	WITH B as (
		WITH A as(
		SELECT *
		FROM transactions
		LEFT JOIN fraudsters
		ON fraudsters.user_id=transactions.USER_ID
		WHERE fraudsters.user_id is null
		ORDER BY user_id, created_date
		)

	SELECT user_id, CREATED_DATE, amount, Count(*) OVER (partition by user_id) as cuenta, avg(amount) OVER (partition by user_id) as mean_amount, power(amount - avg(amount) OVER (partition by user_id),2) as suma
	from A
	order by user_id, created_date
	)
	SELECT DISTINCT user_id as t_user_id, mean_amount as t_mean_amount, sqrt(sum(suma) OVER (partition by user_id)/cuenta) t_stdev
	from B
)
SELECT t_user_id, p_user_id, t_mean_amount, p_mean_amount, t_stdev, p_stdev,  abs(t_mean_amount-p_mean_amount) m_diff, abs(t_stdev-p_stdev) sd_diff
from tran
LEFT JOIN pattern
WHERE m_diff=0 AND sd_diff=0
ORDER BY m_diff, sd_diff
)
SELECT DISTINCT t_user_id from new_fraudsters;

