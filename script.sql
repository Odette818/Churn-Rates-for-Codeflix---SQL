 # To preview a table Subscriptions
 SELECT *
 FROM subscriptions
 LIMIT 100;

# To determine how many distinct segment the table contains and count the number of users in each segment
 SELECT DISTINCT segment, COUNT(*) AS 'total'
 FROM subscriptions
 GROUP BY 1;

# To determine the months range available in the data
 SELECT MIN(subscription_start) AS 'start', MAX(subscription_start) AS 'end'
 FROM subscriptions;

# To create a temporary table months
 WITH months AS 
 (SELECT 
    '2017-01-01' AS first_day,
    '2017-01-31' AS last_day
    UNION
     SELECT
      '2017-02-01' AS first_day,
      '2017-02-28' AS last_day
    UNION
     SELECT
      '2017-03-01' AS first_day,
      '2017-03-31' AS last_day      
 )
 SELECT * 
 FROM months;
 
 # To create a temporary table cross_join from subscriptions and months
  WITH months AS 
 (SELECT 
    '2017-01-01' AS first_day,
    '2017-01-31' AS last_day
    UNION
     SELECT
      '2017-02-01' AS first_day,
      '2017-02-28' AS last_day
    UNION
     SELECT
      '2017-03-01' AS first_day,
      '2017-03-31' AS last_day      
 ),
cross_join AS
  (SELECT *
  FROM subscriptions
  CROSS JOIN months
  )
SELECT *
FROM cross_join
LIMIT 3;

# To create a temporary table status
 WITH months AS 
 (SELECT 
    '2017-01-01' AS first_day,
    '2017-01-31' AS last_day
    UNION
     SELECT
      '2017-02-01' AS first_day,
      '2017-02-28' AS last_day
    UNION
     SELECT
      '2017-03-01' AS first_day,
      '2017-03-31' AS last_day      
 ),
cross_join AS
  (SELECT *
  FROM subscriptions
  CROSS JOIN months
  ),
status AS 
(SELECT 
   id,
   first_day AS month,
   CASE
    WHEN (subscription_start < first_day) AND(subscription_end > first_day OR subscription_end IS NULL) AND (segment = 87)  THEN 1
  ELSE 0
END AS is_active_87,
CASE
    WHEN (subscription_start < first_day) AND (subscription_end > first_day OR subscription_end IS NULL) AND (segment = 30)THEN 1
 ELSE 0
END AS is_active_30,
CASE
    WHEN (subscription_end BETWEEN first_day AND last_day) AND (segment = 87) THEN 1
    ELSE 0
    END AS is_canceled_87,
CASE
    WHEN (subscription_end BETWEEN first_day AND last_day) AND (segment = 30) THEN 1
    ELSE 0
    END AS is_canceled_30
  FROM cross_join
  )
SELECT *
FROM status
LIMIT 10;

# To create a temporary table status_aggregate
 WITH months AS 
 (SELECT 
    '2017-01-01' AS first_day,
    '2017-01-31' AS last_day
    UNION
     SELECT
      '2017-02-01' AS first_day,
      '2017-02-28' AS last_day
    UNION
     SELECT
      '2017-03-01' AS first_day,
      '2017-03-31' AS last_day      
 ),
cross_join AS
  (SELECT *
  FROM subscriptions
  CROSS JOIN months
  ),
status AS 
(SELECT 
   id,
   first_day AS month,
   CASE
    WHEN (subscription_start < first_day) AND(subscription_end > first_day OR subscription_end IS NULL) AND (segment = 87)  THEN 1
  ELSE 0
END AS is_active_87,
CASE
    WHEN (subscription_start < first_day) AND (subscription_end > first_day OR subscription_end IS NULL) AND (segment = 30)THEN 1
 ELSE 0
END AS is_active_30,
CASE
    WHEN (subscription_end BETWEEN first_day AND last_day) AND (segment = 87) THEN 1
    ELSE 0
    END AS is_canceled_87,
CASE
    WHEN (subscription_end BETWEEN first_day AND last_day) AND (segment = 30) THEN 1
    ELSE 0
    END AS is_canceled_30
  FROM cross_join
  ),
  status_aggregate AS
  (SELECT 
    month,
    SUM(is_active_87) AS sum_active_87,
    SUM(is_active_30) AS sum_active_30,
    SUM(is_canceled_87) AS sum_canceled_87,
    SUM(is_canceled_30) AS sum_canceled_30
  FROM status
  GROUP BY month)
SELECT *
FROM status_aggregate;

# To calculate churn rates for every month for each segment
 WITH months AS 
 (SELECT 
    '2017-01-01' AS first_day,
    '2017-01-31' AS last_day
    UNION
     SELECT
      '2017-02-01' AS first_day,
      '2017-02-28' AS last_day
    UNION
     SELECT
      '2017-03-01' AS first_day,
      '2017-03-31' AS last_day      
 ),
cross_join AS
  (SELECT *
  FROM subscriptions
  CROSS JOIN months
  ),
status AS 
(SELECT 
   id,
   first_day AS month,
   CASE
    WHEN (subscription_start < first_day) AND(subscription_end > first_day OR subscription_end IS NULL) AND (segment = 87)  THEN 1
  ELSE 0
END AS is_active_87,
CASE
    WHEN (subscription_start < first_day) AND (subscription_end > first_day OR subscription_end IS NULL) AND (segment = 30)THEN 1
 ELSE 0
END AS is_active_30,
CASE
    WHEN (subscription_end BETWEEN first_day AND last_day) AND (segment = 87) THEN 1
    ELSE 0
    END AS is_canceled_87,
CASE
    WHEN (subscription_end BETWEEN first_day AND last_day) AND (segment = 30) THEN 1
    ELSE 0
    END AS is_canceled_30
  FROM cross_join
  ),
  status_aggregate AS
  (SELECT 
    month,
    SUM(is_active_87) AS sum_active_87,
    SUM(is_active_30) AS sum_active_30,
    SUM(is_canceled_87) AS sum_canceled_87,
    SUM(is_canceled_30) AS sum_canceled_30
  FROM status
  GROUP BY month)
  SELECT month,
   ROUND(1.0 * sum_canceled_87/sum_active_87, 2) AS churn_rate_87,
  ROUND(1.0 * sum_canceled_30/sum_active_30, 2) AS churn_rate_30
   FROM status_aggregate;
