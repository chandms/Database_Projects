/*
-------------------------------------------------
CS541 -Project 1 -Part 1(SQL Queries)

--Last name, firstname: Mukherjee, Chandrika
--Purdue email: cmukherj@purdue.edu

----------------------------


*/
select  distinct p.product_id from products p 
join order_items oi on p.product_id = oi.product_id 
join orders o on oi.order_id = o.order_id
where o.status<>'Canceled'
and o.order_date BETWEEN TO_DATE('24-AUG-16', 'DD-Mon-YY') AND TO_DATE('07-JAN-17', 'DD-Mon-YY')
order by p.product_id;
