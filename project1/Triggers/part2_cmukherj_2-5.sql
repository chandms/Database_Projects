-------------------------------------------------
/*CS541 -Project 1 -Part 2 (Oracletriggers)

-- Last name, firstname: Mukherjee, Chandrika
-- Purdue email: cmukherj@purdue.edu

--Approach:


1. Storing the total number of shipped orders by particular salesman till now
2. calculating the number of time the incentive was canculated for the employee 
    (if total = 10, then 10/5 = 2 times incentive was canculated).


3. Calculating incentive for each five order since starting 
    a. inner table comb gets all the price (quantity* unit_price) of different product_id under order_id
    b. then we calculate sum of price for each order_id
    c. we set an offset x (to exclude first x rows) and use fetch y (to fetch next y rows)
    d. we calculate the sum of price *0.01 as incentive



*/


-------------

create or replace trigger good_sale
before update
on orders
FOR EACH ROW
DECLARE
    pragma autonomous_transaction;
    sid NUMBER := :NEW.salesman_id; -- salesman id
    status VARCHAR(255) := :NEW.status; -- status

    fname VARCHAR(255); -- firstname
    lname VARCHAR(255); -- lastname
    total_sum NUMBER:=0; -- total sum to store total incentive
    count_sh NUMBER:=0; -- total shipped orderes by the particular salesman till now
    st NUMBER:=0; -- loop starting element
    wr_num NUMBER:=0;
    cur_inc NUMBER;
    quo INTEGER:=0; -- how many time the for loop will run
  
        BEGIN
        select first_name into fname from employees where employee_id = sid;
        select last_name into lname from employees where employee_id = sid;
        select count(order_id)+1 into count_sh from orders where salesman_id = sid and status='Shipped';

        quo :=count_sh/5;
        if(MOD(count_sh,5)!=0) then quo:= quo+1;
        end if;

        if MOD(count_sh,5)=0 and status='Shipped' then -- if the current status is Shipped and total%5=0 (time to calculate incentive)
            for loop_one in 1..quo
            loop
                   DBMS_OUTPUT.PUT_LINE(' ************* ');
                   cur_inc:=0;

                   -- calculation of incentive into cur_inc

                   select sum(comb2.price)*0.01 into cur_inc from
                   (select sum(comb.price) as price,  comb.order_id from
                    (select COALESCE(oi.quantity,0)* COALESCE(oi.unit_price,0) as price, oi.order_id from order_items oi
                    join orders o on o.order_id = oi.order_id
                    and o.salesman_id = sid and status='Shipped'  order by o.order_date desc )comb
                    group by comb.order_id OFFSET st ROWS FETCH NEXT 5 ROWS ONLY) comb2 ;

                    wr_num := st+5;
                    if wr_num > count_sh then
                        wr_num := count_sh;
                    end if;  
                    st :=st+1;

                    DBMS_OUTPUT.PUT_LINE('from '|| st||' to ' ||wr_num||' individual incentive is '||cur_inc);
                    st := st+4;
                    total_sum := total_sum+cur_inc; -- summing incentives
            end loop;
            DBMS_OUTPUT.PUT_LINE('Employee Name - '|| fname ||' '|| lname|| ', total shipped orders - '||  count_sh || ' 
                total incentive till now -' || total_sum);
        end if;
        commit;
    END ;