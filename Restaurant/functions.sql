CREATE OR REPLACE FUNCTION lunches_for_50_people()
    RETURNS TABLE(l_id integer, l_name character varying, price numeric(5, 2))
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    
BEGIN

	CREATE TEMP TABLE lunches_comp AS
		SELECT set_lunches.l_id AS id_, set_lunches.l_name AS name_, dish_composition.ing_amount*50 AS amount_, ingredients.available_count AS i_left, ingredients.price*50 AS price_ FROM set_lunches
			JOIN lunch_composition ON set_lunches.l_id = lunch_composition.l_id
			JOIN dishes ON lunch_composition.d_id = dishes.d_id
			JOIN dish_composition ON dishes.d_id = dish_composition.dish_id
			JOIN ingredients ON dish_composition.ing_id = ingredients.i_id;

    RETURN QUERY (SELECT id_, name_, SUM(price_) AS Price FROM lunches_comp WHERE id_ NOT IN (SELECT DISTINCT id_ FROM lunches_comp WHERE amount_ > i_left) GROUP BY id_,name_ ORDER BY Price DESC LIMIT 1)
			union (SELECT id_, name_, SUM(price_) AS Price FROM lunches_comp WHERE id_ NOT IN (SELECT DISTINCT id_ FROM lunches_comp WHERE amount_ > i_left) GROUP BY id_,name_ ORDER BY Price ASC LIMIT 1);
	DROP TABLE lunches_comp;
	RETURN;
END;
$BODY$;

-------------------------------------------------

CREATE OR REPLACE PROCEDURE public.max_order(IN dish_name character varying)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	found_dish_id INTEGER := NULL;
	max_count INTEGER := 10000000;
	id_to_change INTEGER := NULL;
	change_price NUMERIC(5, 2);
	
	id__ INTEGER;
	name__ VARCHAR(50);
	amount__ INTEGER;
	available__ INTEGER;
	price__ NUMERIC(5, 2);
BEGIN	
	SELECT dishes.d_id INTO found_dish_id FROM dishes WHERE dishes.d_name = max_order.dish_name;
	IF found_dish_id IS NULL THEN
		RAISE NOTICE 'There"s no such dish';
		RETURN;
	ELSE
		CREATE TEMP TABLE dish_ingr
			(id_ INTEGER, amount_ INTEGER, price_ NUMERIC(5, 2));
			
		FOR id__, name__, amount__, available__, price__ IN
			(SELECT ingredients.i_id, ingredients.d_name, dish_composition.ing_amount, ingredients.available_count, ingredients.price FROM dishes
			JOIN dish_composition ON dishes.d_id = dish_composition.dish_id
			JOIN ingredients ON dish_composition.ing_id = ingredients.i_id
			WHERE dishes.d_id = found_dish_id)
		LOOP
			IF amount__ > available__ THEN
				SELECT change_id INTO id_to_change FROM ingredients_replacement WHERE i_id = id__;
				IF (id_to_change IS NULL) OR ((SELECT available_count FROM ingredients WHERE ingredients.i_id = id_to_change) < amount__) THEN
					RAISE NOTICE 'ingredient is missing, you can''t order even one';
					RETURN;
				ELSE
					RAISE NOTICE 'change % to %', name__, (SELECT d_name FROM ingredients WHERE ingredients.i_id = id_to_change);
					SELECT price INTO change_price FROM ingredients WHERE ingredients.i_id = id_to_change;
					INSERT INTO dish_ingr VALUES (id_to_change, amount__, change_price);
				END IF;
			ELSE
				INSERT INTO dish_ingr VALUES (id__, amount__, price__);
				IF available__ / amount__ < max_count THEN
					max_count = available__ / amount__;
				END IF;
			END IF;
		END LOOP;
		
		RAISE NOTICE 'You can order no more than % %', max_count, dish_name;
		DROP TABLE dish_ingr;
		RETURN;
	END IF;
END;
$BODY$;

-----------------------

CREATE OR REPLACE PROCEDURE public.add_dish(
	d_name VARCHAR(50),
	d_type VARCHAR(10),
	d_count INTEGER)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	found_id INTEGER := NULL;
BEGIN
	IF d_type = 'dish' THEN
		SELECT dishes.d_id INTO found_id FROM dishes WHERE dishes.d_name = add_dish.d_name;
		IF found_id IS NULL THEN
			RAISE NOTICE 'There''s no such dish';
		ELSE
			INSERT INTO new_order_composition VALUES (found_id, add_dish.d_count);
		END IF;
	ELSIF d_type = 'lunch' THEN
		SELECT set_lunches.l_id INTO found_id FROM set_lunches WHERE set_lunches.l_name = add_dish.d_name;
		IF found_id IS NULL THEN
			RAISE NOTICE 'There''s no such lunch';
		ELSE
			INSERT INTO new_order_composition (
				SELECT lunch_composition.d_id, add_dish.d_count 
				FROM lunch_composition 
				WHERE lunch_composition.l_id = found_id
			);
		END IF;
	ELSE
		RAISE NOTICE 'Wrong type';
	END IF;
END;
$BODY$;

-----------------------

CREATE OR REPLACE PROCEDURE public.make_new_order(
		time_to_wait INTERVAL DAY TO MINUTE)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	new_ord_id INTEGER := NULL;
	ord_id_ INTEGER;
	expire_time_ TIMESTAMP;
	ing_id_ INTEGER;
	required_ INTEGER;
	ing_amount_ INTEGER;
BEGIN
	IF NOT EXISTS(SELECT * FROM new_order_composition LIMIT 1) THEN
		RAISE NOTICE 'Nothing to order';
		RETURN;
	ELSE
		CREATE TEMP TABLE required_ingr AS
			SELECT ing_id, required, available_count FROM (
				SELECT ing_id, sum(ing_amount*d_count) AS required
				FROM new_order_composition
				JOIN dish_composition ON new_order_composition.d_id = dish_composition.dish_id
				GROUP BY ing_id) AS ingr_needed
			JOIN ingredients ON ingredients.i_id = ing_id;
			
		INSERT INTO processing_orders(ord_expire_time) VALUES (NOW() + time_to_wait);
		SELECT ord_id INTO new_ord_id FROM processing_orders ORDER BY ord_id DESC LIMIT 1;
		
		IF EXISTS (SELECT * FROM required_ingr WHERE required > available_count) THEN
			RAISE NOTICE 'Some ingredients are missing, checking for expired orders';
			FOR ord_id_, expire_time_ IN (SELECT ord_id, ord_expire_time FROM processing_orders)
			LOOP
				IF (NOW() - expire_time_ > INTERVAL '10m') THEN
					FOR ing_id_, ing_amount_ IN (SELECT ing_id, ing_amount FROM order_structure WHERE order_structure.ord_id = ord_id_)
					LOOP
						UPDATE ingredients SET available_count = available_count + ing_amount_ WHERE ingredients.i_id = ing_id_;
						UPDATE required_ingr SET available_count = available_count + ing_amount_ WHERE required_ingr.ing_id = ing_id_;
					END LOOP;
					DELETE FROM processing_orders WHERE processing_orders.ord_id = ord_id_;
				END IF;
			END LOOP;
			
			IF EXISTS (SELECT * FROM required_ingr WHERE required > available_count) THEN
				RAISE NOTICE 'Some ingredients are still missing, can''t make order';
				DELETE FROM processing_orders WHERE ord_id = new_ord_id;
				DROP TABLE required_ingr;
				TRUNCATE TABLE new_order_composition;
				RETURN;
			END IF;
		END IF;
		
		INSERT INTO order_structure (SELECT new_ord_id, required_ingr.ing_id, required_ingr.required FROM required_ingr);
		
		FOR ing_id_, required_ IN (SELECT ing_id, required FROM required_ingr)
		LOOP
			UPDATE ingredients SET available_count = available_count - required_ WHERE ing_id_ = ingredients.i_id;
		END LOOP;
		
		IF (time_to_wait < INTERVAL '10m') THEN	
			DELETE FROM processing_orders WHERE ord_id = new_ord_id;
			INSERT INTO completed_orders VALUES(new_ord_id, NOW() + time_to_wait);			
		END IF;
		RAISE NOTICE 'Your order ID: %', new_ord_id;
		DROP TABLE required_ingr;
		TRUNCATE TABLE new_order_composition;
	END IF;
	RETURN NEW;
END;
$BODY$;

------------------------------------

CREATE OR REPLACE PROCEDURE public.take_order(
	ord_id INTEGER)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	found_id INTEGER := NULL;
BEGIN
	IF NOT EXISTS (SELECT * FROM processing_orders WHERE processing_orders.ord_id = take_order.ord_id) THEN
		RAISE NOTICE 'No such order';
		RETURN;
	ELSE
		DELETE FROM processing_orderes WHERE processing_orderes.ord_id = take_order.ord_id;
		INSERT INTO completed_orders VALUES(ord_id, NOW());
		RAISE NOTICE 'Order completed';
		RETURN;
	END IF;
END;
$BODY$;

-------------------------------------

CREATE OR REPLACE FUNCTION remove_old()
	RETURNS TRIGGER AS
$$
DECLARE
	ord_id_ INTEGER;
	ing_id_ INTEGER;
	ing_amount_ INTEGER;
BEGIN
	FOR ord_id_ IN (SELECT ord_id FROM completed_orders WHERE NOW() - ord_complete_time > INTERVAL'1 month')
	LOOP
		DELETE FROM order_structure WHERE order_structure.ord_id = ord_id_;
		DELETE FROM completed_orders WHERE completed_orders.ord_id = ord_id_;
	END LOOP;
		
	FOR ord_id_ IN (SELECT ord_id FROM processing_orders WHERE NOW() - ord_expire_time > INTERVAL'2 days')
	LOOP
		FOR ing_id_, ing_amount_ IN (SELECT ing_id, ing_amount FROM order_structure WHERE order_structure.ord_id = ord_id_)
		LOOP
			UPDATE ingredients SET available_count = available_count + ing_amount_ WHERE ingredients.i_id = ing_id_;
		END LOOP;
		
		DELETE FROM order_structure WHERE order_structure.ord_id = ord_id_;
		DELETE FROM processing_orders WHERE processing_orders.ord_id = ord_id_;
	END LOOP;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER clear_old_orders
	AFTER INSERT
	ON completed_orders
	FOR EACH ROW
	EXECUTE PROCEDURE remove_old();
