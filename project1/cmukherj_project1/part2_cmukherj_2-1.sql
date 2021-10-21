-------------------------------------------------
/*CS541 -Project 1 -Part 2 (Oracletriggers)

-- Last name, firstname: Mukherjee, Chandrika
-- Purdue email: cmukherj@purdue.edu

--Approach:

Assumption : Only while order placing for the first time, status becomes 'Pending'. 
			 Therefore, I only activated the trigger for INSERT action

Trigger Name is ord_cust

Trigger is called before insert to orders table

I store the address corresponding to the customer who placed an order.
I identify all the customer ids which are associated with the stored address.
Then I calcualte the total number of Pending orders by all those customers (by same household).

If the count is equal to 5 and the status of new inserted order is Pending imply that the household is crossing the limit (more than five pending orders).
If that is the scenario, then raising application error with code 20001 and Address of household.


*/


-------------
create or replace trigger ord_cust
before insert 
on orders
for each row

    DECLARE
    
    adr VARCHAR(255); -- To store the address of the customer
    
    cnt_ord NUMBER; -- To capture the total number of current Pending orders of the customer before INSERT
    
    BEGIN
    select address into adr from customers where customer_id=:NEW.customer_id; -- storing address

    SELECT count(o.order_id) into cnt_ord from orders o where o.customer_id in (  
    select customer_id from customers where address= adr) and status = 'Pending'; -- storing the current count of Pending orders by a household

    IF cnt_ord=5 and :NEW.status='Pending' THEN
    
        raise_application_error(-20001,'Address - '||adr);
    
    END IF;
    
    END;