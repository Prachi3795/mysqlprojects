--Measuring success through compare performance
/*Analyzing yearly performance of products by comparing each product's sale to its average sale
performance */

with yearly_product_sales as(
select 
year(f.order_date) as order_year,
p.product_name,
sum(f.sales_amount) as current_sales
from gold.fact_sales f
left join gold.dim_products p
on f.product_key=p.product_key
where f.order_date is not null
group by
year(f.order_date),
p.product_name
)

select order_year,
product_name,
current_sales,
avg(current_sales) over (partition by product_name) avg_sales,
current_sales - avg(current_sales) over (partition by product_name) as diff_avg,
case when current_sales- avg(current_sales) over (partition by product_name) >0 then 'above avg'
when current_sales- avg(current_sales) over (partition by product_name) >0 then 'Below avg'
Else 'avg'
end avg_change
from yearly_product_sales
