/*
-------------------------------------------------
CS541 -Project 1 -Part 1(SQL Queries)

--Last name, firstname: Mukherjee, Chandrika
--Purdue email: cmukherj@purdue.edu

----------------------------


*/


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