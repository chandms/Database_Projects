/*
-------------------------------------------------
CS541 -Project 1 -Part 1(SQL Queries)

--Last name, firstname: Mukherjee, Chandrika
--Purdue email: cmukherj@purdue.edu

----------------------------


*/

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