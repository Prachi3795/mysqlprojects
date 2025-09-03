/*---------------------------------------------------------------------------------------------
Customer report
-----------------------------------------------------------------------------------------------
Purpose:
-Consolidated key customer mettrics and behaviours

Highlights:
1. Essential field such as names, ages and transaction details.
2. Customer segmentation based on their purchasing behaviour and age group.
3. Aggregated customer- level metrics:
   - total orders, total sales, total quantity purchased, total products, lifespan 
4. Calculated KPIs:
   - Recency, average order value, average monthly spending
---------------------------------------------------------------------------------------------------

*/
create view gold.report_custmers as 
with base_query as (
select
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
concat(c.first_name,' ',c.last_name) as customer_name,
datediff(year, c.birthdate, getdate()) age
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key=f.customer_key
where order_date is not null)


, customer_aggregation as (select
customer_key,
customer_number,
customer_name,
age,
count(distinct order_number) as total_orders,
sum(sales_amount) as total_sales,
sum(quantity) as total_quantity,
count(distinct product_key) as total_product,
max(order_date) as last_order_date,
datediff(month, min(order_date), max(order_date)) as lifespan
from base_query
group by 
customer_key,
customer_number,
customer_name,
age)

select
customer_key,
customer_number,
customer_name,
age,
case when age <20 then 'under 20'
when age between 20 and 29 then '20-29'
when age between 30 and 39 then '20-29'
when age between 40 and 49 then '20-29'
else '50 and above'
end as age_group,
case
when lifespan >=12 and total_sales > 5000 then 'vip'
when lifespan >=12 and total_sales <= 5000 then 'regular'
else 'new'
end as customer_segment,
last_order_date,
datediff(month, last_order_date, getdate()) as recency,
total_orders,
total_sales,
total_quantity,
total_product,
lifespan,
---Avergae order value
case when total_sales=0 then 0
else total_sales/total_orders 
end as avg_order_value,
--Average monthly spending
case when lifespan =0 then total_sales
else total_sales/lifespan
end as avg_monthly_spend
from customer_aggregation