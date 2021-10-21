/*
-------------------------------------------------
CS541 -Project 1 -Part 1(SQL Queries)

--Last name, firstname: Mukherjee, Chandrika
--Purdue email: cmukherj@purdue.edu

----------------------------


*/

select customer_id,name,address, website, credit_limit from CUSTOMERS where 
credit_limit > (select avg(credit_limit) from CUSTOMERS);