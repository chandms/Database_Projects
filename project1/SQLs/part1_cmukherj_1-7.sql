/*
-------------------------------------------------
CS541 -Project 1 -Part 1(SQL Queries)

--Last name, firstname: Mukherjee, Chandrika
--Purdue email: cmukherj@purdue.edu

----------------------------


*/

select  customer_id, count(order_id) as  "#OF CANCELED ORDERS" from orders 
where status = 'Canceled'
group by customer_id
order by customer_id;