--How many new customers were added each year
select datetrunc(year, create_date) as create_year,
count(customer_key) as total_customer
from gold.dim_customers
group by datetrunc(year, create_date)
order by datetrunc(year, create_date)

--Discovering seasonality/trend for the business
select 
year(order_date) as order_year,
month(order_date) as order_month,
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold.fact_sales 
where order_date is  not null 
group by month(order_date), year(order_date)
order by month(order_date), year(order_date)

select 
format(order_date, 'yyyy-MMM') as order_date,
/*datetrunc(month, order_date) as order_date,*/
/*year(order_date) as order_year, */
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold.fact_sales 
where order_date is  not null 
/group by format(order_date, 'yyyy-MMM')
order by format(order_date, 'yyyy-MMM')