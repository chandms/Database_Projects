/*
-------------------------------------------------
CS541 -Project 1 -Part 1(SQL Queries)

--Last name, firstname: Mukherjee, Chandrika
--Purdue email: cmukherj@purdue.edu

----------------------------


*/

select PRODUCT_ID, PRODUCT_NAME, DESCRIPTION, STANDARD_COST, LIST_PRICE, CATEGORY_ID from products prod 
where prod.product_id not in 
(
select p.product_id from products p 
join inventories iv on p.product_id = iv.product_id
join warehouses w on w.warehouse_id = iv.warehouse_id
)
order by prod.product_id;