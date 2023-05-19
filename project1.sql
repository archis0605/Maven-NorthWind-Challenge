/*1. Count the no. of country where the customer is located*/
select count(distinct country) as no_of_countries
from customers;

/*2. Count the no. of customers who placed the order*/
select count(distinct customerID) as no_of_companies
from customers;

/*3. Count the no. of various products.*/
select count(distinct productID) as no_of_products
from products;

/*4. Count the no. of employees who processed the order.*/
select count(employeeID) as no_of_employee
from employees;

/*5. Count the total no. of orders ordered.*/
select count(*) as total_orders
from orders;

/*6. Count the total no. of products ordered.*/
select count(*) as total_product_orders
from order_details;

/*7. Create a view where the sales amount for each product is shown.*/
create view sales_details as(select *, (unitPrice * quantity) as sales_amount
from order_details);

/*8. Find the total sales generated in the given period.*/
select sum(sales_amount) as net_sales
from sales_details;

/*9. Total Shipping Cost for the placed orders.*/
select round(sum(freight),2) as total_shipping_cost
from orders;

/*10. Average days required to deliver the orders.*/
with avgdays as (select orderID, customerID, shipperID, requiredDate,
		shippedDate,
        datediff(shippedDate, orderDate) as days_required
from orders)
select round(avg(days_required)) as average_days
from avgdays;

/*11. Top 10 countries w.r.t the customer.*/
select country, count(*) as customer_cnt
from customers
group by country
order by customer_cnt desc;

-- 2155 are the total number of orders which are processed in Northwind Traders.

/*12. Count the total no.of continued products.*/
select count(*) as continue_products
from products
where discontinued = 0;

-- These are the total number of continued products.

/*13. Count the total no. of discontinued orders.*/
select count(*) as continue_products
from products
where discontinued = 1;

-- These are the total number of discontinued products.

/*14. Count the total no. of orders in each year.*/
select
	case
		when month(o.orderDate) between 1 and 6 then year(o.orderDate)
		else year(o.orderDate) + 1
        end as years,
    count(*) as cnt_order
from sales_details sd
inner join orders o using(orderID)
group by years
order by cnt_order desc;

-- In the 2015, the largest number of food products are ordered by resturants, cafe,
-- and special food retailer around the world.

/*15. Net Sales of the orders in each year.*/
select 
	case
		when month(o.orderDate) between 1 and 6 then year(o.orderDate)
		else year(o.orderDate) + 1
        end as years,
    concat("$ ",round(sum(sales_amount),2)) as net_sales
from sales_details sd
inner join orders o using(orderID)
group by years
order by net_sales desc;

-- Largest number of sales revenue generated for the food products in the year 2014.

/*16. In which month has the largest sales revenue generated in each year.*/
with topmonth_sales as
	(with month_rank as
			(select 
				case
					when month(o.orderDate) between 1 and 6 then year(o.orderDate)
                    else year(o.orderDate) + 1 
                    end as years, 
					month(o.orderDate) as months, round(sum(sd.sales_amount),2) as month_sales
			from orders o 
			inner join sales_details sd using(orderID)
			group by years, months
			)
	 select years, months, month_sales,
			rank() over (partition by years order by month_sales desc) as month_rnk
	 from month_rank
     )
     select *
     from topmonth_sales;	
     
/*The month of "October" recorded the highest sales in both 2013 and 2014, 
while in 2015, the month of "April" witnessed the highest sales.*/

/*17. Count the number of orders delivered on time by each shipping services in the year 2014.*/
select
	year(o.orderDate) as years, shipperID,
    count(*) as cnt
from sales_details sd
inner join orders o using (orderID)
where o.shippedDate is not null
group by years, shipperID with rollup
having years = 2014;

-- In 2014, United package delivered the most numbers of items followed by Speedy Express, and Federal Shipping.

/*18. List the topmost products delivered by each shipping services in the year 2014.*/
with top_three as(with high_products as (select year(o.orderDate) as years, 
    shipperID, productID,
    count(*) as cnt
from sales_details sd
inner join orders o using (orderID)
where o.shippedDate is not null
group by years, shipperID, productID with rollup
having years = 2014 and productID is not null)
select shipperID, productID, cnt,
		row_number() over(partition by shipperID order by cnt desc) as row_num
from high_products)
select shipperID, productID, cnt
from top_three
where row_num = 1;

/*Based on the provided data for the fiscal year 2014, we can draw the following analysis:
1. Speedy Express (ShipperID: Speedy) delivered the topmost product "Gnocchi di nonna Alice" with a total of 13 orders.
2. United Shipping Services (ShipperID: United) delivered the topmost product "Camembert Pierrot" also with 13 orders.
3. Federal Shipping Services (ShipperID: Federal) delivered the third topmost product "Sir Rodney's Scones" with 11 orders.*/

/*19. Average days required to deliver the order by each shipping services.*/
with avgdays as (select orderID, customerID, shipperID, requiredDate,
		shippedDate,
        datediff(shippedDate, orderDate) as days_required
from orders)
select shipperID, round(avg(days_required)) as average_days
from avgdays
group by shipperID
order by average_days asc;

/*20. Average shipping cost for the order by each shipping service.*/
select shipperID, concat("$ ", round(avg(freight),2)) as average_price
from orders
group by shipperID
order by average_price asc;

/*Federal Shipping Services offers expedited shipping, making it the quickest option available compared to other services. 
While providing swift delivery, the average cost per order amounts to $80. On the other hand, 
Speedy Express stands out as the most economical shipping service, taking an average of 9 days to transport orders.*/

/*21. List top 5 category w.r.t. ordered products.
(descending order)*/
with qty_measure1 as (select p.categoryID, count(*) as order_cnt
from products p
inner join order_details od using(productID)
group by p.categoryID
order by order_cnt desc)
select c.categoryID, c.categoryName, qm.order_cnt
from categories c
inner join qty_measure1 qm using(categoryID)
order by qm.order_cnt desc;

/*This analysis indicates that the "Beverages" category received the highest number of orders, 
followed by "Dairy Products" and "Confections" categories.*/

/*22. List top 5 category w.r.t. selling product units.
(descending order)*/
with qty_measure as (select p.categoryID, sum(od.quantity) as total_quantity
from products p
inner join order_details od using(productID)
group by p.categoryID
order by total_quantity desc)
select c.categoryID, c.categoryName, qm.total_quantity
from categories c
inner join qty_measure qm using(categoryID)
order by qm.total_quantity desc
limit 5;

/*This analysis reveals that the "Beverages" category had the highest number of product units sold, 
followed by "Dairy Products" and "Confections" categories.*/

/*23. List the top 5 category w.r.t. net sales*/
with sales_measure as (select p.categoryID, concat("$ ", round(sum(sales_amount),2)) as revenue
from products p
inner join sales_details sd using(productID)
group by p.categoryID
order by revenue desc)
select c.categoryID, c.categoryName, sm.revenue
from categories c
inner join sales_measure sm using(categoryID)
order by sm.revenue desc;

/* From this analysis, we can observe that the "Beverages" category generated the highest net sales, 
followed by "Dairy Products" and "Meat & Poultry" categories.*/

/*Overall, the analysis indicates that the "Beverages" category performed well in terms of both order count, 
product units sold, and net sales, making it a significant contributor to the overall business performance. 
Dairy Products and Confections also showed strong performance across these metrics. 
Additionally, Meat & Poultry category stood out in terms of net sales, suggesting 
it could be a profitable category for the business.*/

/*24. List the topmost products net sales w.r.t the top 5 category.*/
create view top5category as(with qty_measure as (select p.categoryID, sum(od.quantity) as total_quantity
from products p
inner join order_details od using(productID)
group by p.categoryID
order by total_quantity desc)
select c.categoryID, c.categoryName, qm.total_quantity
from categories c
inner join qty_measure qm using(categoryID)
order by qm.total_quantity desc
limit 5);

with top_3_products as (with product_by_category as 
							(with product_sales as
								(select p.categoryID, p.productName, round(sum(sales_amount),2) as net_sales
								from products p
								inner join sales_details sd using(productID)
								group by p.categoryID, p.productName with rollup
								having p.productName is not null),
								top_id as
								(select categoryID, categoryName from top5category)

							-- first cte
							select t.categoryID, ps.productName, ps.net_sales
							from top_id t
							inner join product_sales ps using(categoryID))

						-- second cte
						select categoryID, productName, net_sales,
						rank() over (partition by categoryID order by net_sales desc) as rnk
						from product_by_category)

				-- third cte
				select categoryID, productName, concat("$ ", net_sales) as sales_revenue 
				from top_3_products
				where rnk <= 3;
/*From this analysis, we can observe the top-selling products in terms of net sales for each category. 
These products have contributed significantly to the overall revenue generated in their respective categories.

Additionally, we can infer that the product "Côte de Blaye" has achieved the highest net sales 
across all categories, making it a particularly successful product for the business.*/

/*25. List the top 5 customer with respect to net sales*/
select o.customerID, round(sum(sd.sales_amount),2) as customer_sales
from sales_details sd
inner join orders o using (orderID)
group by o.customerID
order by customer_sales desc
limit 10;

/*This analysis indicates that the customers QUICK, SAVEA, and ERNSH are the top three customers in terms of net sales, 
contributing significantly to the overall revenue of the business. 
HUNGO and RATTC are also among the top 5 customers but with relatively lower net sales compared to the top three.*/

/*26. List the top 5 customers w.r.t the no. of orders*/
select o.customerID, count(*) as customer_orders
from sales_details sd
inner join orders o using (orderID)
group by o.customerID
order by customer_orders desc
limit 5;

/*This analysis reveals the top 5 customers who placed the highest number of orders. 
SAVEA has the highest number of orders, followed by ERNSH, QUICK, RATTC, and HUNGO. 
These customers are significant contributors to the overall order volume of the business.*/

/*27. List of top 5 customer w.r.t. the freight. (desc. order)*/
select customerID, round(sum(freight),2) as net_freight
from orders o
inner join sales_details sd using(orderID)
group by customerID
order by net_freight desc
limit 5;

/*This analysis indicates the top 5 customers who incurred the highest freight costs. 
SAVEA has the highest freight expenses, followed by ERNSH, QUICK, HUNGO, and QUEEN. 
These customers contribute significantly to the overall freight expenditure of the business.*/

/*28. Find the 10 topmost Average order Value of customers w.r.t. net sales and no. of orders.*/
with netsales as (select o.customerID, round(sum(sd.sales_amount),2) as customer_sales
from sales_details sd
inner join orders o using (orderID)
group by o.customerID
order by customer_sales desc
),
totalorders as (select o.customerID, count(*) as customer_orders
from sales_details sd
inner join orders o using (orderID)
group by o.customerID
order by customer_orders desc
)
select n.customerID, round(n.customer_sales/t.customer_orders) as AOV
from netsales n
inner join totalorders t using(customerID)
order by AOV desc
limit 10;

/*"QUICK" stands out with the highest average order value of $1366. 
This suggests that their individual orders contribute significantly to the net sales, 
indicating the potential for high-value or large-volume purchases.

Customers with lower average order values, such as "BOLID" may present opportunities 
for upselling or cross-selling to increase their average order values and overall net sales. 
By analyzing their purchasing patterns and preferences, targeted marketing strategies can be implemented.*/

/*29. Find the efficiency of top 10 customers on the basis of net sales and freight cost.*/
with netsales as (select o.customerID, round(sum(sd.sales_amount),2) as customer_sales
from sales_details sd
inner join orders o using (orderID)
group by o.customerID
order by customer_sales desc
),
freightcost as (select customerID, round(sum(freight),2) as net_freight
from orders o
inner join sales_details sd using(orderID)
group by customerID
order by net_freight desc
)
select n.customerID, round(((n.customer_sales - ft.net_freight)/ft.net_freight),2) as efficiency
from netsales n
inner join freightcost ft using(customerID)
order by efficiency desc
limit 10;

/* "LONEP" indicates a higher return compared to the expense, suggesting a profitable use of freight resources.
   "GALED" indicates a less return compared to the expense, suggesting a loss due to the use of freight resources.*/

/*30. List the 5 most popular products w.r.t. the no. of orders.*/
select p.productName, count(*) as products_cnt
from products p
inner join sales_details sd using(productID)
group by p.productName
order by products_cnt desc
limit 5;

/*31. List the 5 least popular products w.r.t. the no. of orders.*/
select p.productName, count(*) as products_cnt
from products p
inner join sales_details sd using(productID)
group by p.productName
order by products_cnt asc
limit 5;

/*32. List the 5 most popular products w.r.t. the net sales.*/
select p.productName, round(sum(sales_amount),2) as net_sales
from products p
inner join sales_details sd using(productID)
group by p.productName
order by net_sales desc
limit 10;

/*33. List the 5 least popular products w.r.t. the net sales.*/
select p.productName, round(sum(sales_amount),2) as net_sales
from products p
inner join sales_details sd using(productID)
group by p.productName
order by net_sales asc
limit 5;

/*34. List the 5 most popular products w.r.t. the freight.*/
select p.productName, round(sum(freight),2) as net_freight
from products p
inner join sales_details sd using(productID)
inner join orders o using(orderID)
group by p.productName
order by net_freight desc;

/*35. List the 5 least popular products w.r.t. the freight.*/
select p.productName, round(sum(freight),2) as net_freight
from products p
inner join sales_details sd using(productID)
inner join orders o using(orderID)
group by p.productName
order by net_freight asc
limit 5;

/*36. Find the 10 topmost Average order Value of products w.r.t. net sales and no. of orders.*/
with netsales as (select p.productName, round(sum(sales_amount),2) as net_sales
from products p
inner join sales_details sd using(productID)
group by p.productName
order by net_sales desc
),
totalorders as (select p.productName, count(*) as products_cnt
from products p
inner join sales_details sd using(productID)
group by p.productName
order by products_cnt desc
)
select n.productName, round(n.net_sales/t.products_cnt) as AOV
from netsales n
inner join totalorders t using(productName)
order by AOV desc
limit 10;

/*1. The products with the highest average order values, such as "Côte de Blaye" and "Thüringer Rostbratwurst" 
indicate that these items contribute significantly to the overall net sales. 
They are likely high-value products that customers are willing to purchase in larger quantities or at higher prices.

2. Products with higher average order values such as "Côte de Blaye" 
and "Thüringer Rostbratwurst" suggest higher profitability per order. Businesses can focus on promoting and 
marketing these products to maximize revenue and increase overall profitability.*/

/*37. List the top 5 countries w.r.t number of orders.*/
with customerorder as (select customerID, count(*) as customers_order_cnt
from orders
group by customerID
order by customers_order_cnt asc),
country as(
select customerID, country
from customers)
select country, sum(customers_order_cnt) as orders_count
from customerorder co
inner join country c using (customerID)
group by country
order by orders_count desc
limit 5;

/*38. List of top 5 country w.r.t the Net Sales.*/
with country_netsales as
	(with country_sales_details as 
		(with net_cust as
			(with cust_order as 
				(
				select orderID, round(sum(sales_amount),2) as total
				from sales_details
				group by orderID
				order by total desc
                )
			select o.customerID, ct.orderID, ct.total
			from cust_order ct
			inner join orders o using(orderID)
            )
		select customerID, sum(total) as cust_total
		from net_cust
		group by customerID
		order by cust_total desc
        )
select c.country, cs.customerID, cs.cust_total
from country_sales_details cs
inner join customers c using(customerID)
)
select country, round(sum(cust_total),2) as country_net_sales
from country_netsales
group by country
order by country_net_sales desc
limit 5;

/*39. List the top 5 countries w.r.t. average order value.*/
with total_orders as 
	(with customerorder as 
		(
        select customerID, count(*) as customers_order_cnt
		from orders
		group by customerID
		order by customers_order_cnt asc
        ),
		country as
        (
		select customerID, country
		from customers
        )
	select country, sum(customers_order_cnt) as orders_count
	from customerorder co
	inner join country c using (customerID)
	group by country
	order by orders_count desc
    ),
total_sales as 
	(with country_netsales as
		(with country_sales_details as 
			(with net_cust as
				(with cust_order as 
					(
					select orderID, round(sum(sales_amount),2) as total
					from sales_details
					group by orderID
					order by total desc
					)
				select o.customerID, ct.orderID, ct.total
				from cust_order ct
				inner join orders o using(orderID)
				)
			select customerID, sum(total) as cust_total
			from net_cust
			group by customerID
			order by cust_total desc
			)
		select c.country, cs.customerID, cs.cust_total
		from country_sales_details cs
		inner join customers c using(customerID)
		)
	select country, round(sum(cust_total),2) as country_net_sales
	from country_netsales
	group by country
	order by country_net_sales desc)

select country, round(ts.country_net_sales/td.orders_count,2) as AOV
from total_sales ts
inner join total_orders td using(country)
order by AOV desc
limit 5;

/*40. List the 5 most popular products (max. count of product) in the USA country.*/
create view topcountry as 
	(
    with customerorder as 
		(
        select customerID, count(*) as customers_order_cnt
		from orders
		group by customerID
		order by customers_order_cnt asc
        ),
		country as(
		select customerID, country
		from customers
        )
	select country, sum(customers_order_cnt) as orders_count
	from customerorder co
	inner join country c using (customerID)
	group by country
	order by orders_count desc
	);

with product_usa as
	(with group_product as 
		(with country_product_details as 
			(with product_qty as 
				(
				select o.customerID, sd.productID, sum(quantity) as total_qty
				from orders o 
				inner join sales_details sd using(orderID)
				group by o.customerID, sd.productID with rollup
				having o.customerID is not null
				)		 
			select c.country, pq.customerID, pq.productID, pq.total_qty
			from customers c
			inner join product_qty pq using(customerID)
			)
		select tc.country, d.productID, d.total_qty
		from country_product_details d
		inner join topcountry tc using(country)
		where tc.country = "USA"
		having d.productID is not null
		)
	select productID, sum(total_qty) as Qty
	from group_product
	group by productID
	order by Qty desc
	)
select p1.productID, p2.productName, p1.Qty
from product_usa p1
inner join products p2 using(productID)
order by 3 desc
limit 5;

/*41. List the 5 most popular products (max. count of product) in the GERMANY country.*/
with product_germany as
	(with group_product as 
		(with country_product_details as 
			(with product_qty as 
				(
                select o.customerID, sd.productID, sum(quantity) as total_qty
				from orders o 
				inner join sales_details sd using(orderID)
				group by o.customerID, sd.productID with rollup
				having o.customerID is not null
				)		 
			select c.country, pq.customerID, pq.productID, pq.total_qty
			from customers c
			inner join product_qty pq using(customerID)
			)
		select tc.country, d.productID, d.total_qty
		from country_product_details d
		inner join topcountry tc using(country)
		where tc.country = "Germany"
		having d.productID is not null
		)
	select productID, sum(total_qty) as Qty
	from group_product
	group by productID
	order by Qty desc
	)
select p1.productID, p2.productName, p1.Qty
from product_germany p1
inner join products p2 using(productID)
order by 3 desc
limit 5;

/*42. Count total no. of orders shipped by each shipping services from 2013 to 2015.*/
select o.shipperID, count(*) as orders_cnt
from orders o
inner join sales_details sd using(orderID)
group by o.shipperID
order by orders_cnt desc;

/*43. Count the no. of orders delivered every year through each shipping services.*/
select year(orderDate) as year, shipperID, count(*) as orders_cnt
from orders
group by year, shipperID with rollup
having shipperID is not null;

/*44. Find average shipping cost grouped by top 5 customers.*/
with top5customers as (select customerID, count(*) as cnt
from orders
group by customerID
order by cnt desc
limit 5),
avg_freight_customers as(
select customerID, round(avg(freight),2) as average_freight
from orders
group by customerID)
select t5.customerID, afc.average_freight
from top5customers t5
inner join avg_freight_customers afc using(customerID)
order by afc.average_freight desc;

/*45. Count the no. of orders processed by each employee.*/
select employeeID, count(*) as order_processed
from orders
group by employeeID
order by order_processed desc;