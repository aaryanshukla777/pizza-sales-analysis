USE pizza_sales;

/*
   Pizza Sales Analysis
   Dataset: pizza_orders (1004 rows)
   SQL analysis covering sales, product demand and delivery performance.
*/

-- 0. Total number of orders
SELECT COUNT(*) AS total_orders
FROM pizza_orders;

-- 0.1 Check for duplicate Order IDs
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_orders
FROM pizza_orders;

SELECT
    order_month,
    COUNT(*) AS total_orders
FROM pizza_orders
GROUP BY order_month
ORDER BY FIELD(
    order_month,
    'January','February','March','April','May','June',
    'July','August','September','October','November','December'
);

SELECT
    pizza_type,
    COUNT(*) AS total_orders
FROM pizza_orders
GROUP BY pizza_type
ORDER BY total_orders DESC;

-- Top 5 pizza types
SELECT
    pizza_type,
    COUNT(*) AS total_orders
FROM pizza_orders
GROUP BY pizza_type
ORDER BY total_orders DESC
LIMIT 5;

SELECT
    CASE
        WHEN LOWER(TRIM(is_weekend)) IN ('true','1','yes')
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*) AS total_orders
FROM pizza_orders
GROUP BY
    CASE
        WHEN LOWER(TRIM(is_weekend)) IN ('true','1','yes')
            THEN 'Weekend'
        ELSE 'Weekday'
    END
ORDER BY day_type;

SELECT
    CAST(order_hour AS UNSIGNED) AS order_hour,
    COUNT(*) AS total_orders
FROM pizza_orders
GROUP BY CAST(order_hour AS UNSIGNED)
ORDER BY order_hour;

-- Peak vs non-peak orders
SELECT
    CASE
        WHEN LOWER(TRIM(is_peak_hour)) IN ('true','1','yes')
            THEN 'Peak Hour'
        ELSE 'Non-Peak Hour'
    END AS peak_status,
    COUNT(*) AS total_orders
FROM pizza_orders
GROUP BY
    CASE
        WHEN LOWER(TRIM(is_peak_hour)) IN ('true','1','yes')
            THEN 'Peak Hour'
        ELSE 'Non-Peak Hour'
    END;

SELECT
    CASE
        WHEN LOWER(TRIM(is_delayed)) IN ('true','1','yes')
            THEN 'Delayed'
        ELSE 'Not Delayed'
    END AS delay_status,
    COUNT(*) AS total_orders,
    ROUND(AVG(CAST(NULLIF(delay_min, '') AS DECIMAL(10,2))), 2) AS avg_delay_min,
    ROUND(MIN(CAST(NULLIF(delay_min, '') AS DECIMAL(10,2))), 2) AS min_delay_min,
    ROUND(MAX(CAST(NULLIF(delay_min, '') AS DECIMAL(10,2))), 2) AS max_delay_min
FROM pizza_orders
GROUP BY
    CASE
        WHEN LOWER(TRIM(is_delayed)) IN ('true','1','yes')
            THEN 'Delayed'
        ELSE 'Not Delayed'
    END;

SELECT
    CAST(toppings_count AS UNSIGNED) AS toppings_count,
    COUNT(*) AS total_orders
FROM pizza_orders
GROUP BY CAST(toppings_count AS UNSIGNED)
ORDER BY total_orders DESC;

SELECT
    location,
    COUNT(*) AS total_orders,
    ROUND(AVG(CAST(NULLIF(delivery_duration_min, '') AS DECIMAL(10,2))), 2) AS avg_delivery_time,
    ROUND(AVG(CAST(NULLIF(delay_min, '') AS DECIMAL(10,2))), 2) AS avg_delay
FROM pizza_orders
GROUP BY location
ORDER BY total_orders DESC;

SELECT
    traffic_level,
    COUNT(*) AS total_orders,
    ROUND(AVG(CAST(NULLIF(traffic_impact, '') AS DECIMAL(10,2))), 2) AS avg_traffic_impact,
    ROUND(AVG(CAST(NULLIF(delay_min, '') AS DECIMAL(10,2))), 2) AS avg_delay,
    ROUND(AVG(CAST(NULLIF(delivery_duration_min, '') AS DECIMAL(10,2))), 2) AS avg_delivery_time
FROM pizza_orders
GROUP BY traffic_level
ORDER BY avg_traffic_impact DESC;

SELECT
    payment_method,
    COUNT(*) AS total_orders
FROM pizza_orders
GROUP BY payment_method
ORDER BY total_orders DESC;

-- Payment category breakdown
SELECT
    payment_category,
    COUNT(*) AS total_orders
FROM pizza_orders
GROUP BY payment_category
ORDER BY total_orders DESC;

SELECT
    pizza_size,
    COUNT(*) AS total_orders
FROM pizza_orders
GROUP BY pizza_size
ORDER BY total_orders DESC;

-- Delivery efficiency by traffic level
SELECT
    traffic_level,
    COUNT(*) AS total_orders,
    ROUND(
        AVG(
            CAST(NULLIF(delivery_duration_min, '') AS DECIMAL(10,2)) /
            NULLIF(CAST(NULLIF(distance_km, '') AS DECIMAL(10,2)), 0)
        ),
        2
    ) AS avg_duration_per_km
FROM pizza_orders
WHERE NULLIF(distance_km, '') IS NOT NULL
  AND CAST(NULLIF(distance_km, '') AS DECIMAL(10,2)) > 0
GROUP BY traffic_level
ORDER BY avg_duration_per_km DESC;

-- Overall delivery efficiency
SELECT
    ROUND(
        AVG(
            CAST(NULLIF(delivery_duration_min, '') AS DECIMAL(10,2)) /
            NULLIF(CAST(NULLIF(distance_km, '') AS DECIMAL(10,2)), 0)
        ),
        2
    ) AS overall_avg_duration_per_km,
    ROUND(MIN(
        CAST(NULLIF(delivery_duration_min, '') AS DECIMAL(10,2)) /
        NULLIF(CAST(NULLIF(distance_km, '') AS DECIMAL(10,2)), 0)
    ), 2) AS best_duration_per_km,
    ROUND(MAX(
        CAST(NULLIF(delivery_duration_min, '') AS DECIMAL(10,2)) /
        NULLIF(CAST(NULLIF(distance_km, '') AS DECIMAL(10,2)), 0)
    ), 2) AS worst_duration_per_km
FROM pizza_orders
WHERE NULLIF(distance_km, '') IS NOT NULL
  AND CAST(NULLIF(distance_km, '') AS DECIMAL(10,2)) > 0;

SELECT
    order_id,
    restaurant_name,
    location,
    traffic_level,
    CAST(NULLIF(distance_km, '') AS DECIMAL(10,2)) AS distance_km,
    CAST(NULLIF(delivery_duration_min, '') AS DECIMAL(10,2)) AS delivery_duration_min,
    CAST(NULLIF(delay_min, '') AS DECIMAL(10,2)) AS delay_min,
    ROUND(
        CAST(NULLIF(delivery_duration_min, '') AS DECIMAL(10,2)) /
        NULLIF(CAST(NULLIF(distance_km, '') AS DECIMAL(10,2)), 0),
        2
    ) AS duration_per_km
FROM pizza_orders
WHERE NULLIF(distance_km, '') IS NOT NULL
  AND CAST(NULLIF(distance_km, '') AS DECIMAL(10,2)) > 0
ORDER BY duration_per_km DESC
LIMIT 10;

SELECT
    restaurant_name,
    COUNT(*) AS total_orders,
    ROUND(AVG(CAST(NULLIF(delivery_duration_min, '') AS DECIMAL(10,2))), 2) AS avg_delivery_time
FROM pizza_orders
GROUP BY restaurant_name
ORDER BY total_orders DESC;

SELECT
    COUNT(*) AS total_orders,
    COUNT(order_id) AS order_id_filled,
    COUNT(restaurant_name) AS restaurant_filled,
    COUNT(location) AS location_filled,
    COUNT(order_time) AS order_time_filled,
    COUNT(delivery_time) AS delivery_time_filled,
    COUNT(delivery_duration_min) AS delivery_duration_filled,
    COUNT(pizza_size) AS pizza_size_filled,
    COUNT(pizza_type) AS pizza_type_filled,
    COUNT(toppings_count) AS toppings_filled,
    COUNT(distance_km) AS distance_filled,
    COUNT(traffic_level) AS traffic_filled,
    COUNT(payment_method) AS payment_filled
FROM pizza_orders;
