/*
-------------------------------------------------
CS541 -Project 1 -Part 1(SQL Queries)

--Last name, firstname: Mukherjee, Chandrika
--Purdue email: cmukherj@purdue.edu

----------------------------


*/

select o.order_id,p.product_id,  count(p.product_id) as OCCURRENCES from products p 
join order_items oi on oi.product_id = p.product_id
join orders o on o.order_id = oi.order_id
group by o.order_id, p.product_id
having count(p.product_id)>1
order by o.order_id;