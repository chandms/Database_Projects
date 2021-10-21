-------------------------------------------------
/*CS541 -Project 1 -Part 2 (Oracletriggers)

-- Last name, firstname: Mukherjee, Chandrika
-- Purdue email: cmukherj@purdue.edu

--Approach:

Trigger Name - ware_surp
Before INSERT or UPDATE of Quantity in INVENTORIES

1. Storing the current quantity (INSERTED or UPDATED Quantity )
2. Selected Threshold = 40
3. If Current Quantity>= Threshold, then I am printing the current quantity 
4. Else,
	a. printing that current quantity is is less than threshold.
	b. selecting the postal_code, city, state and country_name of the current warehouse.
	c. prepared five different queries to obtain 	
		i. all the warehouses with same postal code and having the same product quantity> threshold (first checking the count).
			if count>0, then storing the warehouse id with max quantity of the product and with same postal_code in ids1

		ii. all the warehouses within same city and different posal_code and having the same product quantity> threshold (first checking the count).
			if count>0, then storing the warehouse id with max quantity of the product and with same city in ids2

		iii. all the warehouses with same state and different city and having the same product quantity> threshold (first checking the count).
			if count>0, then storing the warehouse id with max quantity of the product and with same state in ids3

		iv. all the warehouses with same country and having the same product quantity> threshold (first checking the count).
			if count>0, then storing the warehouse id with max quantity of the product and with same country in ids4

		v. all the warehouses with different country and having the same product quantity> threshold (first checking the count).
			if count>0, then storing the warehouse id with max quantity of the product and with different country in ids5
	
	d. While showing the output, we prefer the nearest one.
		Therefore,
			1. if ids1!=-1 (-1 default value), then we output details of ids1 warehouse
			2. if ids1=-1 and ids2!=-1 (-1 default value), then we output details of ids2 warehouse
			3. if ids1=-1 and ids2=-1 and ids3!=-1 (-1 default value), then we output details of ids3 warehouse
			4. if ids1=-1 and ids2=-1 and ids3=-1 and ids4!=-1 (-1 default value), then we output details of ids4 warehouse
			5. if ids1=-1 and ids2=-1 and ids3=-1 and ids4=-1 and ids5!=-1 (-1 default value), then we output details of ids5 warehouse
			6. if all are -1, then we don't have any other warehouse with quantity>threshold

*/


-------------

create or replace trigger ware_surp
before insert or update of quantity
on inventories
for each row
DECLARE
    pragma autonomous_transaction;
    cur_quant NUMBER;
    threshold NUMBER := 40;
    post_cd VARCHAR(255) :='#';
    ct VARCHAR(255) :='#';
    st VARCHAR(255) :='#';
    ctry VARCHAR(255) :='#';
    
    fnl_post_cd VARCHAR(255);
    fnl_ct VARCHAR(255);
    fnl_st VARCHAR(255);
    fnl_ctry VARCHAR(255);
    
    ids1 NUMBER:=-1;
    ids2 NUMBER:=-1;
    ids3 NUMBER:=-1;
    ids4 NUMBER:=-1;
    ids5 NUMBER:=-1;
    
BEGIN
    cur_quant := :NEW.quantity;
    if cur_quant>= threshold then
        DBMS_OUTPUT.PUT_LINE('Current quantity is more than threshold '|| cur_quant ); 
    else
        DBMS_OUTPUT.PUT_LINE('Current quantity '|| cur_quant || ' is less than threshold ' || threshold);
        select COALESCE(loc.postal_code,'#') into post_cd from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
        join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
        and iv.product_id = :NEW.product_id and w.warehouse_id = :NEW.warehouse_id;
        
        select COALESCE(loc.city,'#') into ct from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
        join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
        and iv.product_id = :NEW.product_id and w.warehouse_id = :NEW.warehouse_id;
        
         select COALESCE(loc.state,'#') into st from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
        join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
        and iv.product_id = :NEW.product_id and w.warehouse_id = :NEW.warehouse_id;
        
        select COALESCE(c.country_name,'#') into ctry from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
        join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
        and iv.product_id = :NEW.product_id and w.warehouse_id = :NEW.warehouse_id;
        DBMS_OUTPUT.PUT_LINE ('Current WareHouse - postal_cd= '||post_cd || ',city=  '||ct|| ', state= '||st ||',country =  '||ctry);
    
      
        -- when postal code of another warehouse is same -- getting the count (postal_code will be unique in whole world) (1st near)
        select count(w.warehouse_id) into ids1 from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
        join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
        and iv.product_id = :NEW.product_id and w.warehouse_id <> :NEW.warehouse_id  and iv.quantity>threshold and loc.postal_code = post_cd; 
        
        if ids1>0 then  -- if count>0, then storing the warehouse with max quantity of the same product
        select w.warehouse_id into ids1 from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
        join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
        and iv.product_id = :NEW.product_id and w.warehouse_id <> :NEW.warehouse_id  and iv.quantity>threshold and loc.postal_code = post_cd 
        order by iv.quantity desc fetch first 1 row only;
        else ids1:=-1;
        end if;

        -- when city same, and postal_cd, state, country different (state , country included if different state/country has same city name) (2nd near)
        select count(w.warehouse_id) into ids2 from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
        join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
        and iv.product_id = :NEW.product_id and w.warehouse_id <> :NEW.warehouse_id  and  iv.quantity>threshold and loc.postal_code <> post_cd 
        and loc.city =ct and loc.state <> st and c.country_name <> ctry;
        
        if ids2>0 then -- if count>0, then storing the warehouse with max quantity of the same product
        select w.warehouse_id into ids2 from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
        join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
        and iv.product_id = :NEW.product_id and w.warehouse_id <> :NEW.warehouse_id  and  iv.quantity>threshold and loc.postal_code <> post_cd 
        and loc.city =ct and loc.state <> st and c.country_name <> ctry order by iv.quantity desc fetch first 1 row only;
        else ids2 :=-1;
        end if;
        
        -- when state same, postal_code, city, country different (different country can have same state name) (3rd near)
        select count(w.warehouse_id) into ids3 from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
        join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
        and iv.product_id = :NEW.product_id and w.warehouse_id <> :NEW.warehouse_id  and iv.quantity>threshold and loc.postal_code <> post_cd and loc.city <> ct 
        and loc.state = st and c.country_name <> ctry; 
        
        if ids3>0 then -- if count>0, then storing the warehouse with max quantity of the same product
            select w.warehouse_id into ids3 from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
            join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
            and iv.product_id = :NEW.product_id and w.warehouse_id <> :NEW.warehouse_id  and iv.quantity>threshold and loc.postal_code <> post_cd and loc.city <> ct 
            and loc.state = st and c.country_name <> ctry order by iv.quantity desc fetch first 1 row only;
        else
            ids3 := -1;
        end if;

        -- when same country and postal_code, city, state different (4th near)
        select count(w.warehouse_id) into ids4 from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
        join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
        and iv.product_id = :NEW.product_id and w.warehouse_id <> :NEW.warehouse_id  and  iv.quantity>threshold and loc.postal_code <> post_cd and loc.city <> ct 
        and loc.state <> st and c.country_name = ctry ;
        
        if ids4>0 then -- if count>0, then storing the warehouse with max quantity of the same product
            select w.warehouse_id into ids4 from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
            join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
            and iv.product_id = :NEW.product_id and w.warehouse_id <> :NEW.warehouse_id  and  iv.quantity>threshold and loc.postal_code <> post_cd and loc.city <> ct 
            and loc.state <> st and c.country_name = ctry order by iv.quantity desc fetch first 1 row only;
        else
            ids4 := -1;
        end if;

        -- when country, postal_code, city, state all different (5th near or max distance)
        select count(w.warehouse_id) into ids5 from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
        join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
        and iv.product_id = :NEW.product_id and w.warehouse_id <> :NEW.warehouse_id  and  iv.quantity>threshold and loc.postal_code <> post_cd and loc.city <> ct 
        and loc.state <> st and c.country_name <> ctry; 
        
        if ids5>0 then -- if count>0, then storing the warehouse with max quantity of the same product
            select w.warehouse_id into ids5 from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
            join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
            and iv.product_id = :NEW.product_id and w.warehouse_id <> :NEW.warehouse_id  and  iv.quantity>threshold and loc.postal_code <> post_cd and loc.city <> ct 
            and loc.state <> st and c.country_name <> ctry order by iv.quantity desc fetch first 1 row only;
        else 
            ids5 := -1;
        end if;

    -- details of the next section is described in the approach
    case 
        when ids1!=-1 then
            select postal_code into fnl_post_cd from locations where location_id = (select location_id from warehouses where warehouse_id=ids1);
            select city into fnl_ct from locations where location_id = (select location_id from warehouses where warehouse_id=ids1);
            select state into fnl_st from locations where location_id = (select location_id from warehouses where warehouse_id=ids1);
            select country_name into fnl_ctry from countries where country_id = (select country_id  from locations where location_id = (select location_id from warehouses where warehouse_id=ids1));
            DBMS_OUTPUT.PUT_LINE ('Destination Warehouse- id= '||ids1|| ', postal_cd= '||fnl_post_cd|| ', city= '||fnl_ct||',state= '||fnl_st||',country= '||fnl_ctry);
        when ids1=-1 and ids2!=-1 then
            select postal_code into fnl_post_cd from locations where location_id = (select location_id from warehouses where warehouse_id=ids2);
            select city into fnl_ct from locations where location_id = (select location_id from warehouses where warehouse_id=ids2);
            select state into fnl_st from locations where location_id = (select location_id from warehouses where warehouse_id=ids2);
            select country_name into fnl_ctry from countries where country_id = (select country_id  from locations where location_id = (select location_id from warehouses where warehouse_id=ids2));
            DBMS_OUTPUT.PUT_LINE ('Destination Warehouse- id= '||ids2|| ', postal_cd= '||fnl_post_cd|| ',city= '||fnl_ct||', state= '||fnl_st||', country= '||fnl_ctry);
        when (ids1=-1 and ids2=-1 and ids3!=-1) then
            select postal_code into fnl_post_cd from locations where location_id = (select location_id from warehouses where warehouse_id=ids3);
            select city into fnl_ct from locations where location_id = (select location_id from warehouses where warehouse_id=ids3);
            select state into fnl_st from locations where location_id = (select location_id from warehouses where warehouse_id=ids3);
            select country_name into fnl_ctry from countries where country_id = (select country_id  from locations where location_id = (select location_id from warehouses where warehouse_id=ids3));
            DBMS_OUTPUT.PUT_LINE ('Destination Warehouse- id= '||ids3|| ', postal_cd= '||fnl_post_cd|| ',city =  '||fnl_ct||', state=  '||fnl_st||', country= '||fnl_ctry);
        when (ids1=-1 and ids2=-1 and ids3=-1 and ids4!=-1) then
            select postal_code into fnl_post_cd from locations where location_id = (select location_id from warehouses where warehouse_id=ids4);
            select city into fnl_ct from locations where location_id = (select location_id from warehouses where warehouse_id=ids4);
            select state into fnl_st from locations where location_id = (select location_id from warehouses where warehouse_id=ids4);
            select country_name into fnl_ctry from countries where country_id = (select country_id  from locations where location_id = (select location_id from warehouses where warehouse_id=ids4));
            DBMS_OUTPUT.PUT_LINE ('Destination Warehouse- id='||ids4|| ',postal_cd= '||fnl_post_cd|| ',city= '||fnl_ct||',state=  '||fnl_st||', country= '||fnl_ctry);
        when (ids1=-1 and ids2=-1 and ids3=-1 and ids4=-1 and ids5!=-1) then
            select postal_code into fnl_post_cd from locations where location_id = (select location_id from warehouses where warehouse_id=ids5);
            select city into fnl_ct from locations where location_id = (select location_id from warehouses where warehouse_id=ids5);
            select state into fnl_st from locations where location_id = (select location_id from warehouses where warehouse_id=ids5);
            select country_name into fnl_ctry from countries where country_id = (select country_id  from locations where location_id = (select location_id from warehouses where warehouse_id=ids5));
            DBMS_OUTPUT.PUT_LINE ('Destination Warehouse- id= '||ids5|| ',postal_cd= '||fnl_post_cd|| ',city= '||fnl_ct||', state= '||fnl_st||', country= '||fnl_ctry);
        when (ids1=-1 and ids2=-1 and ids3=-1 and ids4=-1 and ids5=-1) then
            DBMS_OUTPUT.PUT_LINE ('No other warehouse has supply more than threshold');
    end case;
    end if;
   commit;     
END;
