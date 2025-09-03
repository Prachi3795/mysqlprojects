/*Group customers into three segments based on their spending behavior */
with customer_spending as (select 
c.customer_key,

sum(f.sales_amount) as total_spending,
min(order_date) as first_order,
max(order_date) as last_order,
datediff(month, min(order_date), max(order_date)) as lifespan
from gold.fact_sales f
left join gold.dim_customers c
on f.customer_key=c.customer_key
group by c.customer_key)


select customer_segment,
count(customer_key) as total_customers
from
(select
customer_key,
total_spending,
lifespan,
case when lifespan >=12 and total_spending >5000 then 'vip'
when lifespan >=12 and total_spending <=5000 then 'Regular'
else 'new'
end customer_segment
from customer_spending) t
group by customer_segment
order by total_customers desc