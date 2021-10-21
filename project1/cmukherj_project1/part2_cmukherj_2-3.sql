-------------------------------------------------
/*CS541 -Project 1 -Part 2 (Oracletriggers)

-- Last name, firstname: Mukherjee, Chandrika
-- Purdue email: cmukherj@purdue.edu

--Approach:

I have considered Trigger for Order_Items table during Insert (As to access the new quantity and unit price, 
we need to capture the data in Order_Items table. Also, Order entry will first be inserted in Orders table, then 
it will be inserted in Order_Items table. So, setting a trigger in order table will not be useful for this problem. )

Trigger name - cust_cred
Before INSERT on ORDER_ITEMS table

1. Storing the product of new entered quantity and unit price (current_ord)
2. Getting the order_date from orders table using the order_id
3. Storing the 95% of Monthly Credit Limit of the customer who has placed the new order
4. Storing the total purchase by the customer in the current month (From 1st of the month in the same year)
5. Storing the first, last name and email for the employee who placed the order

-------------


*/


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
    total NUMBER; -- total order of the current month + price new order 
    
    BEGIN
    
    select order_date into ord_date from orders where order_id = :NEW.order_id; -- order_date

    select 95*credit_limit/100 into cred_lim from customers where customer_id=(select customer_id from orders where order_id=:NEW.order_id); -- 95% of monthly credit limit

    select COALESCE(sum(COALESCE(quantity,0)* COALESCE(unit_price,0)),0) into total_ord from order_items oi where oi.order_id in
    (select order_id from orders where customer_id = (select customer_id from orders where order_id=:NEW.order_id) 
    and extract(DAY from order_date)>=1 and extract(MONTH from order_date)=extract(month from ord_date)
    and extract(YEAR from order_date)=extract(YEAR from ord_date)); --- total purchase in current month
    
    select first_name into fname from contacts where customer_id=(select customer_id from orders where order_id=:NEW.order_id); 
    select last_name into lname from contacts where customer_id=(select customer_id from orders where order_id=:NEW.order_id);
    select email into email from contacts where customer_id=(select customer_id from orders where order_id=:NEW.order_id);

    total := total_ord+current_ord;
    
    
    IF total >cred_lim THEN -- if exceeding the credit limit
        DBMS_OUTPUT.PUT_LINE('Monthly Credit Limit has exceeded for Customer - '||fname || ' ' ||lname||', email - '||email||'  
        	total order in current month - '|| total|| '  and monthly credit limit '|| cred_lim);
    
    END IF;
    
    END;

