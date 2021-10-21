/*
-------------------------------------------------
CS541 -Project 1 -Part 1(SQL Queries)

--Last name, firstname: Mukherjee, Chandrika
--Purdue email: cmukherj@purdue.edu

----------------------------


*/

select o.order_id, p.PRODUCT_ID, p.PRODUCT_NAME, p.DESCRIPTION, o.status, o.order_date
from PRODUCTS p join ORDER_ITEMS oi on p.product_id = oi.product_id
join ORDERS o on oi.order_id = o.order_id
join product_categories pc on p.category_id = pc.category_id
where p.description like '%Cores:6%' and o.status = 'Shipped'
and pc.category_name = 'CPU'
and extract(YEAR from o.ORDER_DATE)>=2015 and extract(YEAR from o.ORDER_DATE)<=2016
order by p.product_id;