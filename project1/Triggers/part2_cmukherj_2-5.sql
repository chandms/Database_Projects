-------------------------------------------------
/*CS541 -Project 1 -Part 2 (Oracletriggers)

-- Last name, firstname: Mukherjee, Chandrika
-- Purdue email: cmukherj@purdue.edu

--Approach:




*/


-------------

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
            DBMS_OUTPUT.PUT_LINE('Employee Name - '|| fname ||' '|| lname|| ' total shipped orders -'||  count_sh || ' 
            	for last five orders, total commision received-' || total_sum);
        end if;
        commit;
    END ;