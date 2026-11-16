-- 05_verify_data.sql
-- Run after 01–04, connected to retail_analytics. Every line of output should say what it says
-- here; if one does not, re-run the scripts in order (see README.md).
--
--   psql -U postgres -d retail_analytics -f 05_verify_data.sql

SELECT 'customers'                         AS check_name, COUNT(*)::text AS result, '150' AS expected FROM customers
UNION ALL SELECT 'orders',                   COUNT(*)::text, '800' FROM orders
UNION ALL SELECT 'orders with no customer',  COUNT(*)::text, '0'   FROM orders o LEFT JOIN customers c USING (customer_id) WHERE c.customer_id IS NULL
UNION ALL SELECT 'first order date',         MIN(order_date)::text, '2025-01-..' FROM orders
UNION ALL SELECT 'last order date',          MAX(order_date)::text, '2026-09-..' FROM orders
UNION ALL SELECT 'customers with no orders', COUNT(*)::text, 'more than 0' FROM customers c WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id)
UNION ALL SELECT 'customers with 2+ orders', COUNT(*)::text, 'more than 0' FROM (SELECT customer_id FROM orders GROUP BY customer_id HAVING COUNT(*) >= 2) t
UNION ALL SELECT 'customers with 6+ orders', COUNT(*)::text, 'more than 0' FROM (SELECT customer_id FROM orders GROUP BY customer_id HAVING COUNT(*) > 5) t
UNION ALL SELECT 'categories',               COUNT(DISTINCT product_category)::text, '5' FROM orders
UNION ALL SELECT 'statuses',                 string_agg(DISTINCT order_status, ', '), 'Cancelled, Completed, Pending' FROM orders
UNION ALL SELECT 'orders before registration', COUNT(*)::text, '0' FROM orders o JOIN customers c USING (customer_id) WHERE o.order_date < c.registration_date;

-- Completed-order revenue, cost and profit (see "Business rules" in README.md).
SELECT
    ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2) AS completed_revenue,
    ROUND(SUM(quantity * cost_price), 2)                         AS completed_cost,
    ROUND(SUM(quantity * unit_price * (1 - discount / 100)) - SUM(quantity * cost_price), 2) AS completed_profit
FROM orders
WHERE order_status = 'Completed';


-------------------------------------------------------------------
-------------------------------------------------------------------

-- 1. Retrieve all customer records.

select * from customers;

-- 2. Display customer names, cities, and segments.

SELECT * FROM customers;

select c.customer_name, c.city, c.customer_segment
from customers c;

-- 3. Find customers living in Nairobi.

select c.customer_name
from customers c 
where c.city = 'Nairobi';

-- 4. Find customers registered after January 1, 2025.
 
select  c.customer_name, c.registration_date
from customers c
where c.registration_date > '2025-01-01'
order by registration_date asc;

-- 5. Display all unique customer cities.

select distinct(c.city)
from customers c;

-- 6. Retrieve the 10 most recent orders.

select * from orders;

select order_id, product_name, order_date, product_category, payment_method, order_status
from orders o 
order by order_date 
limit 10;

-- 7. Find orders with unit prices above KSh 10,000.

select order_id, product_name, order_date, product_category, unit_price, order_status
from orders 
where cost_price > 10000
order by cost_price asc;

-- 8. Find customers whose names start with A.

select * from customers;

select customer_name
from customers
where customer_name ILIKE 'A%';

-- 9. Retrieve orders with quantities between 2 and 5

select * from orders;

select order_id, product_name, quantity, payment_method
from orders o 
where quantity between 2 and 5;

-- 10. Find orders paid through M-Pesa.
select * from orders;

select order_id, product_name, quantity, payment_method
from orders o 
where payment_method = 'M-Pesa';

-------------------------------------------------------------------
-------------------------------------------------------------------

-- 11. Count all customers

select count(*) from customers;

-- 12. Count all orders.

select count(*) 
from orders;

-- 13. Calculate completed-order revenue

select * from orders;

select sum(quantity * unit_price * (1 - discount / 100)) as order_revenue 
from orders 
where order_status = 'Completed';

select quantity * unit_price * (1 - discount / 100) as revenue
from orders o;

-- 14. Calculate the average completed-order value

select avg(quantity * cost_price) as avg_cost_price
from orders 
where order_status = 'Completed';

-- 15. Find the highest and lowest product prices.

select max(unit_price) as Highest_product_Price, min(unit_price) as Lowest_product_Price
from orders;

-- 16. Calculate revenue by product category.

select product_category, sum(quantity * unit_price * (1 - discount / 100)) as revenue 
from orders 
group by product_category;

-- 17. Count customers by city.

select * from customers;

select city, count(*) as customer_numbers from customers 
group by city;

-- 18. Calculate quantity sold by product.

select * from orders;

select product_name, count(*) as quantity
from orders 
group by product_name;

-- 19. Find categories generating more than KSh 100,000 in revenue.

select o.product_category, sum(quantity * unit_price * (1 - discount / 100)) as revenue 
from orders o
group by o.product_category
having sum(quantity * unit_price * (1 - discount / 100))> 100000;

-- 20. Calculate the percentage of cancelled orders.
   
select round(100.0 * count(*) filter(where order_status ='Cancelled')/ count(*),2)
as cancelled_pct
from orders;

------------------------------------------------------------------
------------------------------------------------------------------

--  21. Display orders with customer names and cities.
select * from customers;

select order_id, c.customer_id, customer_name, city order_date, product_name,
product_category, quantity, unit_price, cost_price, 
discount, payment_method, order_status 
from orders o
join customers c
on o.customer_id = c.customer_id;

-- 22. Calculate total spending by customer.

select sum (quantity*unit_price) as customer_spending 
from orders 
where order_status = 'Completed';

-- 23. Identify customers who have never ordered.

select c.customer_name, c.customer_id
from customers c
left join orders o 
on c.customer_id = o.customer_id
where c.customer_id not in (select o.customer_id from orders o);

-- 24. Find the 10 highest-spending customers.

select customer_name, sum (quantity*unit_price) as customer_spending
from orders o
join customers c
on o.customer_id = c.customer_Id
where order_status = 'Completed'
group by customer_name
order by customer_spending desc 
limit 10;

-- 25. Calculate revenue by customer city.

select c.city, sum(quantity * unit_price * (1 - discount / 100)) as revenue
from customers c 
join orders o 
on o.customer_id = c.customer_id 
group by city;

-- 26. Identify customers with more than five orders.

select * from customers;
select * from orders;

select c.customer_name, count(o.order_id) as orders
from customers c
join orders o 
on c.customer_id = o.customer_id 
group by c.customer_name, o.customer_id
having count(o.order_id) > 5
order by count(o.order_id) asc;

-- 27. Calculate average customer spending by segment.

select * from orders;
select * from customers;

select c.customer_segment, avg(o.quantity * o.unit_price)
from customers c 
join orders o 
on c.customer_id = c.customer_id
group by customer_segment;

-- 28. Identify the most popular category among VIP customers.

select * from customers;
select * from orders;

select c.customer_segment, o.product_category, sum(o.quantity) as total
from customers c 
join orders o 
on c.customer_id = o.customer_id 
group by customer_segment, product_category
having customer_segment = 'VIP'
order by total desc limit 1;

-- 29. Find customers spending above the average total spending per purchasing customer.

select * from orders o;
select * from customers c;

with customer_spending as (
    select
        c.customer_id,
        c.customer_name,
        c.customer_segment,
        sum(o.quantity * o.unit_price * (1 - o.discount / 100)) as total_spent
    from customers c
    join orders o on o.customer_id = c.customer_id
    where o.order_status = 'Completed'
    group by c.customer_id, c.customer_name, c.customer_segment)
select customer_id, customer_name, customer_segment,
    round(total_spent, 2) as total_spent,
    round((select avg(total_spent) from customer_spending), 2) as avg_spent_per_customer
from customer_spending
where total_spent > (select avg(total_spent) from customer_spending)
order by total_spent desc;

-- 30. Find products priced above the overall average unit price.

with product_prices as (select product_name, product_category, max(unit_price) as unit_price
from orders
group by product_name, product_category)
select product_name, product_category, unit_price,
round((select avg(unit_price) from product_prices), 2) as avg_unit_price
from product_prices
where unit_price > (select avg(unit_price) from product_prices)
order by unit_price desc;

-- 31. Use a CTE to identify the three highest-revenue months.

with monthly_revenue as (select date_trunc('month', order_date)::date as month,
round(sum(quantity * unit_price * (1 - discount / 100)), 2) as revenue
from orders
where order_status = 'Completed'
group by date_trunc('month', order_date))
select to_char(month, 'YYYY-MM') as month, revenue
from monthly_revenue
order by revenue desc
limit 3;


-- 32. Find customers purchasing from at least three categories.

with customer_categories as (select customer_id, count(distinct product_category) as categories_bought
from orders
where order_status = 'Completed'
group by customer_id)
select c.customer_id, c.customer_name, c.customer_segment, cc.categories_bought
from customer_categories cc
join customers c on c.customer_id = cc.customer_id
where cc.categories_bought >= 3
order by cc.categories_bought desc, c.customer_id;

-- 33. Use a CTE to calculate category revenue, cost, profit, and profit margin.

with category_totals as (
select product_category, sum(quantity * unit_price * (1 - discount / 100)) as revenue,
sum(quantity * cost_price) as cost
from orders
where order_status = 'Completed'
group by product_category)
select product_category, round(revenue, 2) as revenue, round(cost, 2) as cost, 
round(revenue - cost, 2) as profit, round((revenue - cost) / nullif(revenue, 0) * 100, 2) as profit_margin_pct
from category_totals
order by profit desc;

-- 34. Find customers whose latest completed order is more than 90 days before the latest order date in the dataset.

with last_purchase as (
select customer_id, max(order_date) as last_completed_date
from orders
where order_status = 'Completed'
group by customer_id),
dataset_end as (
select max(order_date) as today
from orders)
select c.customer_id, c.customer_name, c.city, c.customer_segment,
lp.last_completed_date, d.today - lp.last_completed_date as days_since_last_purchase
from last_purchase lp
join customers c 
on c.customer_id = lp.customer_id
cross join dataset_end d
where d.today - lp.last_completed_date > 90
order by days_since_last_purchase desc;

-- 35. Rank customers by spending using RANK()

with customer_spending as (
select c.customer_id, c.customer_name, c.customer_segment,
round(sum(o.quantity * o.unit_price * (1 - o.discount / 100)), 2) as total_spent
from customers c
join orders o 
on o.customer_id = c.customer_id
where o.order_status = 'Completed'
group by c.customer_id, c.customer_name, c.customer_segment)
select rank() over (order by total_spent desc) as spending_rank,
customer_id, customer_name, customer_segment, total_spent
from customer_spending
order by spending_rank, customer_id;

-- 36. Number each customer's orders by recency using ROW_NUMBER().

select customer_id, order_id, order_date, order_status,
row_number() over (partition by customer_id order by order_date desc, order_id desc) as order_recency
from orders
order by customer_id, order_recency;

-- 37. Rank products within categories using DENSE_RANK().

with product_revenue as (
select product_category, product_name,
round(sum(quantity * unit_price * (1 - discount / 100)), 2) as revenue
from orders
where order_status = 'Completed'
group by product_category, product_name)
select product_category, 
dense_rank() over (partition by product_category order by revenue desc) as rank_in_category,
product_name, revenue
from product_revenue
order by product_category, rank_in_category, product_name;

-- 38. Calculate cumulative monthly revenue.

with monthly as (
select date_trunc('month', order_date)::date as month,
sum(quantity * unit_price * (1 - discount / 100)) as revenue
from orders
where order_status = 'Completed'
group by date_trunc('month', order_date))
select to_char(month, 'YYYY-MM') as month, round(revenue, 2) as monthly_revenue,
round(sum(revenue) over (order by month), 2) as cumulative_revenue
from monthly
order by month;

-- 39. Compare monthly revenue using LAG()

with monthly as (
select date_trunc('month', order_date)::date as month,
sum(quantity * unit_price * (1 - discount / 100)) as revenue
from orders
where order_status = 'Completed'
group by date_trunc('month', order_date))
select to_char(month, 'YYYY-MM') as month, round(revenue, 2) as revenue,
round(lag(revenue) over (order by month), 2) as previous_month_revenue,
round(revenue - lag(revenue) over (order by month), 2) as change_in_revenue
from monthly
order by month;

-- 40. Calculate month-over-month revenue growth (%).

with monthly as (
select date_trunc('month', order_date)::date as month,
sum(quantity * unit_price * (1 - discount / 100)) as revenue
from orders
where order_status = 'Completed'
group by date_trunc('month', order_date)),
with_previous as (
select month, revenue, lag(revenue) over (order by month) as previous_revenue
from monthly)
select to_char(month, 'YYYY-MM') as month, round(revenue, 2) as revenue,
round(previous_revenue, 2) as previous_month_revenue,
round((revenue - previous_revenue) / nullif(previous_revenue, 0) * 100, 2) as growth_pct
from with_previous
order by month;

-- 41. Divide customers into four spending groups using NTILE(4).

with customer_spending as (
select c.customer_id, c.customer_name, c.customer_segment,
sum(o.quantity * o.unit_price * (1 - o.discount / 100)) as total_spent
from customers c
join orders o on o.customer_id = c.customer_id
where o.order_status = 'Completed'
group by c.customer_id, c.customer_name, c.customer_segment)
select ntile(4) over (order by total_spent desc, customer_id) as spending_group,
customer_id, customer_name, customer_segment, round(total_spent, 2) as total_spent
from customer_spending
order by spending_group, total_spent desc;

-- 42. Calculate each category's share of total revenue using window functions.

select product_category,
round(sum(quantity * unit_price * (1 - discount / 100)), 2) as category_revenue, round(
        sum(quantity * unit_price * (1 - discount / 100)) * 100.0
        / sum(sum(quantity * unit_price * (1 - discount / 100))) over (),
        2
    ) as revenue_share_pct
from orders
where order_status = 'Completed'
group by product_category
order by revenue_share_pct desc;

-- 43. Create a monthly_sales_summary view (month, orders, revenue, cost, profit), then select from it.

create or replace view monthly_sales_summary as
select
date_trunc('month', order_date)::date as month,
count(*) as orders,
round(coalesce(sum(quantity * unit_price * (1 - discount / 100))
filter (where order_status = 'Completed'), 0), 2) as revenue,
round(coalesce(sum(quantity * cost_price)
filter (where order_status = 'Completed'), 0), 2) as cost,
round(coalesce(sum(quantity * unit_price * (1 - discount / 100) - quantity * cost_price)
filter (where order_status = 'Completed'), 0), 2) as profit
from orders
group by date_trunc('month', order_date);

-- select from the view
select
    to_char(month, 'YYYY-MM') as month,
    orders,
    revenue,
    cost,
    profit
from monthly_sales_summary
order by month;

-- 44. Create a PL/pgSQL function that returns completed-order revenue for a supplied customer ID — show it for one customer and for an ID that does not exist (it must return 0).

create or replace function customer_completed_revenue(p_customer_id integer)
returns numeric
language plpgsql
as $$
declare
    v_result numeric;
begin
    select coalesce(sum(quantity * unit_price * (1 - discount / 100)), 0)
    into v_result
    from orders
    where customer_id = p_customer_id
      and order_status = 'Completed';

    return round(v_result, 2);
end;
$$;

select customer_completed_revenue(141) as revenue_customer_141;

select customer_completed_revenue(9999) as revenue_customer_9999;

-- 45. Segment customers into High, Medium and Low Value, and explain why you chose your thresholds.

with customer_spending as (
select c.customer_id, c.customer_name, c.customer_segment,
sum(o.quantity * o.unit_price * (1 - o.discount / 100)) as total_spent
from customers c
join orders o
on o.customer_id = c.customer_id
where o.order_status = 'Completed'
group by c.customer_id, c.customer_name, c.customer_segment),
thresholds as (
select percentile_cont(0.25) within group (order by total_spent) as p25,
percentile_cont(0.75) within group (order by total_spent) as p75
from customer_spending)
select cs.customer_id, cs.customer_name, cs.customer_segment,
round(cs.total_spent, 2) as total_spent,
    case
        when cs.total_spent >= t.p75 then 'High Value'
        when cs.total_spent >= t.p25 then 'Medium Value'
        else 'Low Value'
    end as value_band
from customer_spending cs
cross join thresholds t
order by cs.total_spent desc;

-- 46. Produce a management report: top five customers, top five products, the most profitable category, and the lowest-revenue month.

with order_lines as (
    select
        customer_id,
        product_name,
        product_category,
        date_trunc('month', order_date)::date as month,
        quantity * unit_price * (1 - discount / 100) as revenue,
        quantity * unit_price * (1 - discount / 100) - quantity * cost_price as profit
    from orders
    where order_status = 'Completed'
),
top_customers as (
    select
        '1. top 5 customers by revenue' as section,
        row_number() over (order by sum(ol.revenue) desc) as position,
        c.customer_name as item,
        round(sum(ol.revenue), 2) as amount
    from order_lines ol
    join customers c on c.customer_id = ol.customer_id
    group by c.customer_id, c.customer_name
    order by sum(ol.revenue) desc
    limit 5
),
top_products as (
    select
        '2. top 5 products by revenue',
        row_number() over (order by sum(revenue) desc),
        product_name,
        round(sum(revenue), 2)
    from order_lines
    group by product_name
    order by sum(revenue) desc
    limit 5
),
best_category as (
    select
        '3. most profitable category',
        1::bigint,
        product_category,
        round(sum(profit), 2)
    from order_lines
    group by product_category
    order by sum(profit) desc
    limit 1
),
worst_month as (
    select
        '4. lowest-revenue month',
        1::bigint,
        to_char(month, 'YYYY-MM'),
        round(sum(revenue), 2)
    from order_lines
    group by month
    order by sum(revenue) asc
    limit 1
)
select * from top_customers
union all select * from top_products
union all select * from best_category
union all select * from worst_month
order by section, position;

-- Run EXPLAIN ANALYZE on your slowest query, add an index that helps, and show the before and after.

explain analyze
with cs as (
    select c.customer_id,
           sum(o.quantity * o.unit_price * (1 - o.discount / 100)) as t
    from customers c
    join orders o on o.customer_id = c.customer_id
    where o.order_status = 'Completed'
    group by c.customer_id
)
select * from cs where t > (select avg(t) from cs);

create index idx_orders_completed_cust
    on orders (customer_id)
    include (quantity, unit_price, discount)
    where order_status = 'Completed';
analyze orders;

create index idx_orders_date_completed
    on orders (order_date)
    include (customer_id, quantity, unit_price, discount)
    where order_status = 'Completed';

-- Build a monthly cohort-retention table: of customers who first ordered in each month, how many ordered again in later months?

with purchases as (
    select distinct customer_id, date_trunc('month', order_date)::date as order_month
    from orders
    where order_status = 'Completed'
),
cohorts as (
    select customer_id, min(order_month) as cohort_month
    from purchases
    group by customer_id
),
cohort_sizes as (
    select cohort_month, count(*) as cohort_size
    from cohorts
    group by cohort_month
),
activity as (
    select
        co.cohort_month,
        (extract(year from age(p.order_month, co.cohort_month)) * 12
         + extract(month from age(p.order_month, co.cohort_month)))::int as months_since_first,
        count(distinct p.customer_id) as active_customers
    from purchases p
    join cohorts co on co.customer_id = p.customer_id
    where p.order_month > co.cohort_month
    group by co.cohort_month, months_since_first
)
select
    to_char(a.cohort_month, 'YYYY-MM') as cohort_month,
    cs.cohort_size,
    a.months_since_first,
    a.active_customers,
    round(a.active_customers * 100.0 / cs.cohort_size, 1) as retention_pct
from activity a
join cohort_sizes cs on cs.cohort_month = a.cohort_month
order by a.cohort_month, a.months_since_first;