-------------------------------------------------
/*CS541 -Project 1 -Part 2 (Oracletriggers)

-- Last name, firstname: Mukherjee, Chandrika
-- Purdue email: cmukherj@purdue.edu

--Approach:

Trigger Name - sales_lim
Before UPDATE on orders the trigger is activated

1. First selecting all the orders which were canceled today and adding one to it (cancel_ord) [to calculate max possible cancel orders for today]
2. Storing the first, last name of the salesman using employee table
3. Storing the email address of the manager who is also an employee (so, using employee table)
4. If cancel_ord>=5 (today, total canceled order exceeds 5 or more) and the status of the updated order is 'Canceled' 
	(this condition keeps a check even if the limit has exceeded, but if current status is 'Shipped' or 'Pending', email should not be triggered.)
		Then, printing the employee information and manager's email address.


*/


-------------

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
        status= 'Canceled' and order_date=SYSDATE; -- (total possible cancel orders today)

        select first_name into fname from employees where employee_id = sid; -- firstname
        select last_name into lname from employees where employee_id = sid; -- lastname
        select email into eml from employees where employee_id = (select manager_id from employees where employee_id = sid); -- email
        
        if cancel_ord>=5 and :NEW.status='Canceled' then -- if updated status is Canceled and total cancel_order exceeds 5 or more
            DBMS_OUTPUT.PUT_LINE('Exceeding Daily Cancellation Limit - Employee Name - '|| fname || ' '|| lname|| ', Manager Email Address- '|| eml); 
        END IF;
        commit;
    END;