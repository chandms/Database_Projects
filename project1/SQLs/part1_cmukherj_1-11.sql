/*
-------------------------------------------------
CS541 -Project 1 -Part 1(SQL Queries)

--Last name, firstname: Mukherjee, Chandrika
--Purdue email: cmukherj@purdue.edu

----------------------------


*/



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