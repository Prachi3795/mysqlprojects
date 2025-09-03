/*---------------------------------------------------------------------------------------------
Product report
-----------------------------------------------------------------------------------------------
Purpose:
-Consolidated key product mettrics and behaviours

Highlights:
1. Essential field such as name, category, sub category and cost.
2. Product segmentation based on their performance.
3. Aggregated product- level metrics:
   - total orders, total sales, total quantity sold, total customers, lifespan 
4. Calculated KPIs:
   - Recency, average order revenue, average monthly revenue
---------------------------------------------------------------------------------------------------

*/
create view gold.report_products as 
with base_query as (

/* Retriving core column from fact tables and dimension product table*/
select
f.order_number,
f.order_date,
f.customer_key,
f.sales_amount,
f.quantity,
p.product_key,
p.product_name,
p.category,
p.subcategory,
p.cost
from gold.fact_sales f
left join gold.dim_products p
on p.product_key=f.product_key
where order_date is not null),-- considering valid sales dates

/* Product segmentation to summarizes key metrics at the product level */

product_aggregations as (select
product_key,
product_name,
category,
subcategory,
cost,
datediff(month, min(order_date), max(order_date)) as lifespan,
max(order_date) as last_sale_date,
count(distinct order_number) as total_orders,
count(distinct customer_key) as total_customers,
sum(sales_amount) as total_sales,
sum(quantity) as total_quantity,
round(avg(cast(sales_amount as float)/nullif(quantity,0)),1) as avg_selling_price
from base_query
group by 
product_key,
product_name,
category,
subcategory,
cost)

select
product_key,
product_name,
category,
subcategory,
cost,
last_sale_date,
datediff(month, last_sale_date, getdate()) as recency_in_months,
case 
when total_sales >50000 then 'High Performer'
when total_sales >=10000 then 'Mid range'
else 'Low performer'
end as product_segment,
lifespan,
total_orders,
total_sales,
total_quantity,
total_customers,
avg_selling_price,
---Avergae order revenue
case when total_orders=0 then 0
else total_sales/total_orders 
end as avg_order_revenue,

--Average monthly spending
case when lifespan =0 then total_sales
else total_sales/lifespan
end as avg_monthly_revenue
from product_aggregations