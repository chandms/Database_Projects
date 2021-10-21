/*
-------------------------------------------------
CS541 -Project 1 -Part 1(SQL Queries)

--Last name, firstname: Mukherjee, Chandrika
--Purdue email: cmukherj@purdue.edu

----------------------------


*/

select ORDER_ID,CUSTOMER_ID,STATUS, SALESMAN_ID,ORDER_DATE from orders where salesman_id is not null and status='Shipped';