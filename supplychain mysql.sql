use supplychain_dataset;

SELECT 
    *
FROM
    sales_data;


-- How many orders were placed in total?

SELECT 
    COUNT(DISTINCT ordernumber) AS total_orders
FROM
    sales_data;
    
    
    
-- What is the total net sales generated after discounts?

SELECT 
    ROUND(SUM(order_quantity * unit_price * (1 - discount_applied)),
            2) AS total_net_sales
FROM
    sales_data;


-- What is the total profit generated?

SELECT 
    ROUND(SUM(order_quantity * unit_price * (1 - discount_applied) - (unit_cost * order_quantity)),
            2) AS total_profit
FROM
    sales_data;


-- What is the average order value?

SELECT 
    ROUND(SUM(order_quantity * unit_price * (1 - discount_applied)) / COUNT(DISTINCT ordernumber),
            2) AS avg_order_value
FROM
    sales_data;


-- How does sales vary by sales channel?

SELECT 
    sales_channel,
    ROUND(SUM(order_quantity * unit_price * (1 - discount_applied)),
            2) AS net_sales
FROM
    sales_data
GROUP BY sales_channel
ORDER BY net_sales DESC;



-- How does profit trend month over month?

SELECT 
    YEAR(orderdate) AS year,
    MONTH(orderdate) AS month,
    ROUND(SUM(unit_price * order_quantity * (1 - discount_applied) - (order_quantity * unit_cost)),
            2) AS monthly_profit
FROM
    sales_data
GROUP BY year , month
ORDER BY year , month;



-- Which products generate the highest and lowest profit?

select product_id,  ROUND(SUM((unit_price * order_quantity * (1 - discount_applied))-(order_quantity * unit_cost)),
            2) AS profit
from sales_data
group by product_id
order by profit desc;


-- Are there any products that are loss-making?

SELECT 
    product_id,
    ROUND(SUM((order_quantity * unit_cost) - (unit_price * order_quantity * (1 - discount_applied))),
            2) AS profit
FROM
    sales_data
GROUP BY product_id
ORDER BY profit < 0
LIMIT 10;



-- Which warehouses contribute the most and least to total profit?

SELECT 
    warehousecode,
    ROUND(SUM((unit_price * order_quantity * (1 - discount_applied)) - (order_quantity * unit_cost)),
            2) AS profit
FROM
    sales_data
GROUP BY warehousecode
ORDER BY profit DESC;



-- Do higher discounts always lead to higher sales volume?

SELECT 
    discount_applied, SUM(order_quantity) AS total_quantity
FROM
    sales_data
GROUP BY discount_applied
ORDER BY discount_applied;



-- What is the average time taken to ship an order after it is placed?

SELECT 
    AVG(DATEDIFF(shipdate, orderdate)) AS avg_order_to_ship_days
FROM
    sales_data
WHERE
    shipdate IS NOT NULL;



-- How many orders are handled by each warehouse?

SELECT 
    warehousecode, COUNT(distinct ordernumber) AS total_orders
FROM
    sales_data
GROUP BY warehousecode 
order by total_orders desc;


-- What is the average delivery time after shipment?

SELECT 
    AVG(DATEDIFF(deliverydate, shipdate)) AS avg_ship_to_delivery_days
FROM
    sales_data
WHERE
    deliverydate IS NOT NULL;
    
    
    
-- What is the total order-to-delivery lead time?

SELECT 
    AVG(DATEDIFF(deliverydate, orderdate)) AS avg_order_to_delivery_days
FROM
    sales_data
WHERE
    deliverydate IS NOT NULL;
    
    
-- Which warehouses have the fastest and slowest delivery times?

SELECT 
    warehousecode,
    AVG(DATEDIFF(deliverydate, shipdate)) AS delivery_time
FROM
    sales_data
GROUP BY warehousecode
ORDER BY delivery_time DESC;


-- How many orders are handled by each warehouse?

SELECT 
    warehousecode, COUNT(DISTINCT ordernumber) AS total_orders
FROM
    sales_data
GROUP BY warehousecode;


-- Is delivery performance consistent across warehouses?

SELECT 
    warehousecode,
    MIN(DATEDIFF(deliverydate, shipdate)) AS min_days,
    MAX(DATEDIFF(deliverydate, shipdate)) AS max_days,
    AVG(DATEDIFF(deliverydate, shipdate)) AS avg_days
FROM
    sales_data
GROUP BY warehousecode;



-- Is higher order volume linked to longer delivery times?

SELECT 
    warehousecode,
    COUNT(DISTINCT ordernumber) AS orders,
    AVG(DATEDIFF(deliverydate, shipdate)) AS avg_delivery_date
FROM
    sales_data
GROUP BY warehousecode
ORDER BY orders DESC;


-- Are high-volume warehouses less profitable?

SELECT 
    warehousecode,
    COUNT(DISTINCT ordernumber) AS total_orders,
    ROUND(SUM((unit_price * order_quantity * (1 - discount_applied))-(order_quantity * unit_cost)),
            2) AS profit
FROM
    sales_data
GROUP BY warehousecode
ORDER BY total_orders DESC;


-- Which sales teams generate the highest profit?

SELECT 
    sales_team_id,
    ROUND(SUM((unit_price * order_quantity * (1 - discount_applied)) - (order_quantity * unit_cost)),
            2) AS profit
FROM
    sales_data
GROUP BY sales_team_id
ORDER BY profit DESC
LIMIT 10;


-- Do certain sales teams apply higher discounts impacting margins?

select sales_team_id, total_orders, avg_discount, round((profit/ net_sales *100), 2) as profit_margin_percent
from
(SELECT 
    sales_team_id, count(distinct ordernumber) as total_orders, round(AVG(discount_applied), 2) AS avg_discount, 
    ROUND(SUM((unit_price * order_quantity * (1 - discount_applied))-(order_quantity * unit_cost)),
            2) AS profit, ROUND(SUM(unit_price * order_quantity * (1 - discount_applied)), 2) as net_sales
FROM
    sales_data
GROUP BY sales_team_id
order by avg_discount desc)t;


-- Which products rank highest in profitability?

select product_id, ROUND(SUM((unit_price * order_quantity * (1 - discount_applied)) - (order_quantity * unit_cost)),
            2) AS profit, rank() over (order by ROUND(SUM((unit_price * order_quantity * (1 - discount_applied)) 
- (order_quantity * unit_cost)), 2) desc) as profit_rank
from 
     sales_data
group by product_id ;

