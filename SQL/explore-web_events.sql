# Check all web events
SELECT *
FROM web_events;

# Check all organic and adwords events
SELECT *
FROM web_events
WHERE channel IN ('organic', 'adwords');

# Analyze Query Plan
EXPLAIN
SELECT *
FROM web_events
WHERE occurred_at >= '2016-01-01'
	AND occurred_at < '2018-07-01';

# Check organic and adwords web events for the year of 2016
SELECT *
FROM web_events
WHERE channel IN ('organic', 'adwords') AND occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
ORDER BY occurred_at;

# Check all web events that occurred after but not more that 1 day after another web event (for the same account)
SELECT w1.id AS w1_id, w1.account_id AS w1_acc_id,
		w1.occurred_at AS w1_date, w1.channel AS w1_channel,
		w2.id AS w2_id, w2.account_id AS w2_acc_id,
		w2.occurred_at AS w2_date, w2.channel AS w2_channel
FROM web_events AS w1
LEFT JOIN web_events AS w2
ON w1.account_id = w2.account_id
AND w2.occurred_at > w1.occurred_at
AND w2.occurred_at <= w1.occurred_at + INTERVAL '1 day'
ORDER BY w1.account_id, w1.occurred_at;

# Check dates of web events for Walmart
SELECT w.occurred_at,
	a.primary_poc,
	w.channel,
	a.name
FROM web_events w
JOIN accounts a
ON 	w.account_id = a.id
WHERE a.name LIKE 'Walmart';

# Check what kind of web events have been made for Walmart
SELECT DISTINCT a.name,
				w.channel
FROM accounts a
JOIN web_events w
ON w.account_id = a.id
WHERE a.id = 1001;

# Check most recent web event
SELECT a.name, w.channel, w.occurred_at
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
ORDER BY w.occurred_at DESC
LIMIT 1;

# Count all web events per channel
SELECT w.channel,
		COUNT(w.channel)
FROM web_events w
GROUP BY w.channel;

# Count all web events per channel and company
SELECT account_id,
		channel,
		COUNT(id) as events
FROM web_events
GROUP BY account_id, channel
ORDER BY account_id, events DESC;

# Count all web events per channel and region
SELECT r.name,
		w.channel,
		COUNT(*) as total_chan
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON s.region_id = r.id
GROUP BY r.name, w.channel
ORDER BY name, total_chan DESC;

# Which channel was most frequently used by most accounts?
SELECT w.channel as channel,
		COUNT(w.channel) as event_total
FROM web_events w
GROUP BY w.channel
ORDER BY COUNT(w.channel) DESC;

# For the customer that spent the most (over their lifetime as a customer), how many web events id they have for each channel?
WITH t1 AS (SELECT a.id AS account_id,
				 		SUM(o.total_amt_usd) AS total_usd
					FROM accounts a
					JOIN orders o
					ON a.id = o.account_id
				 	GROUP BY 1
				  	ORDER BY 2 DESC
				  	LIMIT 1)

SELECT a.name,
		w.channel,
		COUNT(*)
FROM web_events  w
JOIN t1
ON w.account_id = t1.account_id
JOIN accounts a
ON w.account_id = a.id
GROUP BY 1, 2
