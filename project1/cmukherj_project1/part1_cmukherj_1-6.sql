/*
-------------------------------------------------
CS541 -Project 1 -Part 1(SQL Queries)

--Last name, firstname: Mukherjee, Chandrika
--Purdue email: cmukherj@purdue.edu

----------------------------


*/

select distinct country_name from countries 
where country_name not in (
 select distinct country_name from countries c
 join locations loc on c.country_id = loc.country_id
 join warehouses w on w.location_id = loc.location_id
);