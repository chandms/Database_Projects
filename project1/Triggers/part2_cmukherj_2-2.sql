-------------------------------------------------
/*CS541 -Project 1 -Part 2 (Oracletriggers)

-- Last name, firstname: Mukherjee, Chandrika
-- Purdue email: cmukherj@purdue.edu

--Approach:
Trigger Name - ware_goods
Trigger is activated BEFORE INSERT or UPDATE of quantity

1. Storing the total product quantity (before INSERT or UPDATE) in the warehouse associated with the new insert or update (total_prod)
2. Storing the total Storage product quantity (before INSERT or UPDATE) in the warehouse associated with the new insert or update (storage_prod)
	a. First, selecting all products and quantity associated with the warehouse and of Storage category
	b. Then Summing the quantity of the selected Storage products.

3. Storing the category of the product which is inserted or updated in inventory

4. If the action is INSERT, 
	a. if the current product category is Storage, then storage_prod+= inserted quantity and total_prod+= inserted quantity
	b. if the current product category is something else, then total_prod+= inserted quantity

5. if the action is UPDATE,
	a. if the current product category is Storage, then storage_prod+= (new quantity - old quantity) and total_prod+= (new quantity - old_qunatity)
	b. if the current product category is something else, then total_prod+= (new quantity - old quantity)

6. If storage_prod < (0.5*total_prod) then Raising application Error with code 20002, and Warehouse_id


*/


-------------


create or replace trigger ware_goods
before insert or update of quantity
on inventories
for each row
DECLARE
    pragma autonomous_transaction;
    total_prod NUMBER; -- total quantity of different products in a warehouse is stored here
    storage_prod NUMBER; -- total quantity of Storage product in a warehouse is stored here
    cur_prod_cat VARCHAR(255); -- to capture the category of the inserted product or updates product
BEGIN
    select sum(COALESCE(Quantity,0)) into total_prod from inventories where warehouse_id = :NEW.warehouse_id; -- update total_prod

    select sum(comb.quantity) into storage_prod
    from
    (select p.product_id, iv.warehouse_id, pc.category_id, pc.category_name, COALESCE(iv.quantity,0) as quantity from inventories iv join products p 
    on iv.product_id = p.product_id
    join product_categories pc on pc.category_id = p.category_id and category_name = 'Storage' and iv.warehouse_id=:NEW.warehouse_id) comb
    group by comb.warehouse_id,  comb.category_name;
    select category_name into cur_prod_cat from product_categories where category_id = (select category_id from products where product_id = :NEW.product_id); -- update storage_prod 

    case 
        when inserting then -- when INSERT
            if cur_prod_cat='Storage' then
                storage_prod := storage_prod+ :NEW.quantity;
                total_prod := total_prod + :NEW.quantity;
            else 
                total_prod := total_prod + :NEW.quantity;
            end if;
        when updating then -- when UPDATE
            if cur_prod_cat='Storage' then
                storage_prod := storage_prod+ :NEW.quantity - :OLD.quantity;
                total_prod := total_prod + :NEW.quantity - :OLD.quantity;
            else
                total_prod := total_prod + :NEW.quantity - :OLD.quantity;
            end if;
    end case;
    DBMS_OUTPUT.PUT_LINE('Storage Product = '||storage_prod||' , Total Products = '||total_prod||' in warehouse = '||:NEW.warehouse_id);
    if(storage_prod< (0.5*total_prod)) then -- If Violating the rule
        raise_application_error(-20002,'Warehouse Id = '||:NEW.warehouse_id);
    end if;
commit;
END;