
-- Marketplace Optimization SQL Project

-- 1. Identify high-potential underperforming sellers
SELECT seller_id,
       SUM(revenue) AS total_revenue,
       SUM(impressions) AS impressions,
       SUM(clicks) AS clicks,
       (SUM(clicks)*1.0 / NULLIF(SUM(impressions), 0)) AS ctr
FROM orders o
JOIN traffic_logs t USING(product_id)
GROUP BY 1
HAVING ctr < 0.02 AND impressions > 50000;

-- 2. Supply-demand gaps by category
SELECT category,
       COUNT(DISTINCT product_id) AS supply,
       SUM(impressions) AS demand,
       (SUM(impressions) / COUNT(product_id)) AS demand_per_product
FROM products p
JOIN traffic_logs t USING(product_id)
GROUP BY 1
ORDER BY demand_per_product DESC;

-- 3. Revenue at risk due to operational delays
SELECT ticket_type,
       AVG(response_time) AS avg_response_hours,
       SUM(CASE WHEN resolution_status='delayed' THEN revenue END) AS revenue_at_risk
FROM support_tickets s
JOIN orders o USING(seller_id)
GROUP BY 1;

-- 4. Funnel analysis
SELECT
  product_id,
  SUM(impressions) AS impressions,
  SUM(clicks) AS clicks,
  COUNT(order_id) AS conversions,
  ROUND((SUM(clicks) * 1.0) / SUM(impressions), 4) AS ctr,
  ROUND((COUNT(order_id) * 1.0) / SUM(clicks), 4) AS cvr
FROM traffic_logs t
LEFT JOIN orders o USING(product_id)
GROUP BY 1
ORDER BY conversions DESC;
