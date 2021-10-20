select customer_id,name,address, website, credit_limit from CUSTOMERS where 
credit_limit > (select avg(credit_limit) from CUSTOMERS);


select ORDER_ID,CUSTOMER_ID,STATUS, SALESMAN_ID,ORDER_DATE from orders where salesman_id is not null and status='Shipped';


select product_id from products where product_id not in (select distinct product_id from inventories);

select PRODUCT_ID, PRODUCT_NAME, DESCRIPTION, STANDARD_COST, LIST_PRICE, CATEGORY_ID from products prod 
where prod.product_id not in 
(
select p.product_id from products p 
join inventories iv on p.product_id = iv.product_id
join warehouses w on w.warehouse_id = iv.warehouse_id
)
order by prod.product_id;



select o.order_id, p.PRODUCT_ID, p.PRODUCT_NAME, p.DESCRIPTION, o.status, o.order_date
from PRODUCTS p join ORDER_ITEMS oi on p.product_id = oi.product_id
join ORDERS o on oi.order_id = o.order_id
join product_categories pc on p.category_id = pc.category_id
where p.description like '%Cores:6%' and o.status = 'Shipped'
and pc.category_name = 'CPU'
and extract(YEAR from o.ORDER_DATE)>=2015 and extract(YEAR from o.ORDER_DATE)<=2016
order by p.product_id;

select distinct country_name from countries 
where country_name not in (
 select distinct country_name from countries c
 join locations loc on c.country_id = loc.country_id
 join warehouses w on w.location_id = loc.location_id
);


select  customer_id, count(order_id) as  "#OF CANCELED ORDERS" from orders 
where status = 'Canceled'
group by customer_id
order by customer_id;

select  distinct p.product_id from products p 
join order_items oi on p.product_id = oi.product_id 
join orders o on oi.order_id = o.order_id
where o.status<>'Canceled'
and o.order_date BETWEEN TO_DATE('24-AUG-16', 'DD-Mon-YY') AND TO_DATE('07-JAN-17', 'DD-Mon-YY')
order by p.product_id;

select o.order_id,p.product_id,  count(p.product_id) as OCCURRENCES from products p 
join order_items oi on oi.product_id = p.product_id
join orders o on o.order_id = oi.order_id
group by o.order_id, p.product_id
having count(p.product_id)>1
order by o.order_id;

select r.region_name, sum(oi.quantity * oi.unit_price) as TOTAL_SALES from regions r 
join countries c on r.region_id = c.region_id
join locations loc on loc.country_id = c.country_id
join warehouses w on w.location_id = loc.location_id
join inventories iv on w.warehouse_id = iv.warehouse_id
join products p on p.product_id = iv.product_id
join order_items oi on oi.product_id = p.product_id
join orders o on oi.order_id = o.order_id
where o.status <>'Canceled'
group by r.region_name;




select category_id, category_name from 
(
select  count(o.order_id) as cnt_order, pc.category_id, pc.category_name from products p 
join product_categories pc on p.category_id = pc.category_id
join order_items oi on oi.product_id = p.product_id
join orders o on o.order_id = oi.order_id
group by pc.category_id, pc.category_name
order by cnt_order desc
)
where ROWNUM = 1;


select man.salesman_id, man.SM_LAST_NAME, man.SM_FIRST_NAME, man.manager_id,em.last_name as M_LAST_NAME, em.first_name as M_FIRST_NAME  from (
select sales.salesman_id, emp.last_name as SM_LAST_NAME, emp.first_name as SM_FIRST_NAME,
emp.manager_id
from (
select o.salesman_id from orders o join 
order_items oi on o.order_id = oi.order_id
join employees e on e.employee_id = o.salesman_id
and o.salesman_id is not null
and o.status <>'Canceled'
and extract(YEAR from o.order_date)>=2014
group by o.salesman_id
having sum(oi.quantity*oi.unit_price)>500000.00
) sales join employees emp on emp.employee_id = sales.salesman_id)
man join employees em on em.employee_id = man.manager_id
order by man.sm_last_name, man.sm_first_name;







