--- 1. 

create or replace trigger ord_cust
before insert 
on orders
for each row

    DECLARE
    
    adr VARCHAR(2000);
    
    cnt_ord NUMBER;
    
    BEGIN
    select address into adr from customers where customer_id=:NEW.customer_id;
    SELECT count(o.order_id) into cnt_ord from orders o where o.customer_id in (
    select customer_id from customers where address= (select address from customers where 
    customer_id=:NEW.customer_id)) and status = 'Pending';
    IF cnt_ord=5 and :NEW.status='Pending' THEN
    
        raise_application_error(-20001,'Address - '||adr);
    
    END IF;
    
    END;




-- 3.

create or replace trigger cust_cred
before insert 
on order_items
for each row

    DECLARE
    
    total_ord NUMBER;
    current_ord NUMBER  := :NEW.quantity * :NEW.unit_price;
    cred_lim NUMBER;
    fname VARCHAR(255);
    lname VARCHAR(255);
    email VARCHAR(255);
    ord_date DATE;
    
    BEGIN
    
    select order_date into ord_date from orders where order_id = :NEW.order_id;
    select 95*credit_limit/100 into cred_lim from customers where customer_id=(select customer_id from orders where order_id=:NEW.order_id);
    select COALESCE(sum(COALESCE(quantity,0)* COALESCE(unit_price,0)),0) into total_ord from order_items oi where oi.order_id in
    (select order_id from orders where customer_id = (select customer_id from orders where order_id=:NEW.order_id) 
    and order_date>=(ord_date - INTERVAL '30' DAY));
    
    select first_name into fname from contacts where customer_id=(select customer_id from orders where order_id=:NEW.order_id);
    select last_name into lname from contacts where customer_id=(select customer_id from orders where order_id=:NEW.order_id);
    select email into email from contacts where customer_id=(select customer_id from orders where order_id=:NEW.order_id);
    
    
    IF total_ord + current_ord >cred_lim THEN
        DBMS_OUTPUT.PUT_LINE(fname|| ' '||lname||' '||email||'  '|| total_ord|| '   '|| current_ord);
    
    END IF;
    
    END; 


-- 4.
create or replace trigger sales_lim
before update
on orders
for each row
    DECLARE
    pragma autonomous_transaction;
    cancel_ord NUMBER:= 0;
    fname VARCHAR(255);
    lname VARCHAR(255);
    eml VARCHAR(255);
    sid NUMBER:= :NEW.salesman_id;
    status VARCHAR(255):= :NEW.status;
    
    BEGIN

        select count(order_id)+1 into cancel_ord  from orders where salesman_id=sid and 
        status= 'Canceled' and order_date=SYSDATE;
        select first_name into fname from employees where employee_id = sid;
        select last_name into lname from employees where employee_id = sid;
        select email into eml from employees where employee_id = (select manager_id from employees where employee_id = sid);
        
        if cancel_ord>=5 and :NEW.status='Canceled' then
            DBMS_OUTPUT.PUT_LINE('Employee Name - '|| fname || ' '|| lname|| ', Manager Email Address- '|| eml);
        END IF;
        commit;
    END;


---5.

create or replace trigger good_sale
before update
on orders
FOR EACH ROW
DECLARE
    pragma autonomous_transaction;
    sid NUMBER := :NEW.salesman_id;
    status VARCHAR(255) := :NEW.status;
    fname VARCHAR(255);
    lname VARCHAR(255);
    prev_sum NUMBER;
    cur_sum NUMBER ;
    total_sum NUMBER;
    count_sh NUMBER;
  
        BEGIN
        select first_name into fname from employees where employee_id = sid;
        select last_name into lname from employees where employee_id = sid;
        select sum(quantity*unit_price) into prev_sum from order_items where order_id in (select order_id 
        from orders where salesman_id=sid  and status = 'Shipped' order by order_date desc fetch first 4 rows only); 
        select count(order_id)+1 into count_sh from orders where salesman_id = sid and status='Shipped';
        select (quantity*unit_price) into cur_sum from order_items where order_id =: NEW.order_id;
        total_sum := (cur_sum+prev_sum)*0.01;
        
        
        if MOD(count_sh,5)=0 and status='Shipped' then
            DBMS_OUTPUT.PUT_LINE('Employee Name - '|| fname ||' '|| lname|| ' '||  count_sh || ' ' || total_sum);
        end if;
        commit;
    END ;



-- 2.

create or replace trigger ware_goods
before insert or update of quantity
on inventories
for each row
DECLARE
    pragma autonomous_transaction;
    total_prod NUMBER;
    storage_prod NUMBER;
    cur_prod_cat VARCHAR(255);
BEGIN
    select sum(Quantity) into total_prod from inventories where warehouse_id = :NEW.warehouse_id;
    select sum(comb.quantity) into storage_prod
    from
    (select p.product_id, iv.warehouse_id, pc.category_id, pc.category_name, iv.quantity from inventories iv join products p 
    on iv.product_id = p.product_id
    join product_categories pc on pc.category_id = p.category_id and category_name = 'Storage' and iv.warehouse_id=:NEW.warehouse_id) comb
    group by comb.warehouse_id,  comb.category_name;
    select category_name into cur_prod_cat from product_categories where category_id = (select category_id from products where product_id = :NEW.product_id);
    case 
        when inserting then
            if cur_prod_cat='Storage' then
                storage_prod := storage_prod+ :NEW.quantity;
                total_prod := total_prod + :NEW.quantity;
            else 
                total_prod := total_prod + :NEW.quantity;
            end if;
        when updating then
            if cur_prod_cat='Storage' then
                storage_prod := storage_prod+ :NEW.quantity - :OLD.quantity;
                total_prod := total_prod + :NEW.quantity - :OLD.quantity;
            else
                total_prod := total_prod + :NEW.quantity - :OLD.quantity;
            end if;
    end case;
    if(storage_prod< (0.5*total_prod)) then
        raise_application_error(-20002,:NEW.warehouse_id);
    end if;
commit;
END;



-- 6.

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
    
      
        select count(w.warehouse_id) into ids1 from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
        join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
        and iv.product_id = :NEW.product_id and w.warehouse_id <> :NEW.warehouse_id  and iv.quantity>threshold and loc.postal_code = post_cd; 
        
        if ids1>0 then 
        select w.warehouse_id into ids1 from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
        join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
        and iv.product_id = :NEW.product_id and w.warehouse_id <> :NEW.warehouse_id  and iv.quantity>threshold and loc.postal_code = post_cd order by iv.quantity desc fetch first 1 row only;
        else ids1:=-1;
        end if;
        select count(w.warehouse_id) into ids2 from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
        join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
        and iv.product_id = :NEW.product_id and w.warehouse_id <> :NEW.warehouse_id  and  iv.quantity>threshold and loc.postal_code <> post_cd and loc.city =ct and loc.state <> st and c.country_name <> ctry;-- order by iv.quantity desc fetch first 1 row only;
        
        if ids2>0 then 
        select w.warehouse_id into ids2 from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
        join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
        and iv.product_id = :NEW.product_id and w.warehouse_id <> :NEW.warehouse_id  and  iv.quantity>threshold and loc.postal_code <> post_cd and loc.city =ct and loc.state <> st and c.country_name <> ctry order by iv.quantity desc fetch first 1 row only;
        else ids2 :=-1;
        end if;
        
        select count(w.warehouse_id) into ids3 from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
        join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
        and iv.product_id = :NEW.product_id and w.warehouse_id <> :NEW.warehouse_id  and iv.quantity>threshold and loc.postal_code <> post_cd and loc.city <> ct 
        and loc.state = st and c.country_name <> ctry; 
        
        if ids3>0 then
            select w.warehouse_id into ids3 from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
            join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
            and iv.product_id = :NEW.product_id and w.warehouse_id <> :NEW.warehouse_id  and iv.quantity>threshold and loc.postal_code <> post_cd and loc.city <> ct 
            and loc.state = st and c.country_name <> ctry order by iv.quantity desc fetch first 1 row only;
        else
            ids3 := -1;
        end if;
        select count(w.warehouse_id) into ids4 from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
        join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
        and iv.product_id = :NEW.product_id and w.warehouse_id <> :NEW.warehouse_id  and  iv.quantity>threshold and loc.postal_code <> post_cd and loc.city <> ct 
        and loc.state <> st and c.country_name = ctry ;
        
        if ids4>0 then
            select w.warehouse_id into ids4 from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
            join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
            and iv.product_id = :NEW.product_id and w.warehouse_id <> :NEW.warehouse_id  and  iv.quantity>threshold and loc.postal_code <> post_cd and loc.city <> ct 
            and loc.state <> st and c.country_name = ctry order by iv.quantity desc fetch first 1 row only;
        else
            ids4 := -1;
        end if;
        select count(w.warehouse_id) into ids5 from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
        join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
        and iv.product_id = :NEW.product_id and w.warehouse_id <> :NEW.warehouse_id  and  iv.quantity>threshold and loc.postal_code <> post_cd and loc.city <> ct 
        and loc.state <> st and c.country_name <> ctry; 
        
        if ids5>0 then
            select w.warehouse_id into ids5 from inventories iv join warehouses w on iv.warehouse_id = w.warehouse_id
            join locations loc on w.location_id = loc.location_id join countries c on c.country_id = loc.country_id
            and iv.product_id = :NEW.product_id and w.warehouse_id <> :NEW.warehouse_id  and  iv.quantity>threshold and loc.postal_code <> post_cd and loc.city <> ct 
            and loc.state <> st and c.country_name <> ctry order by iv.quantity desc fetch first 1 row only;
        else 
            ids5 := -1;
        end if;
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
