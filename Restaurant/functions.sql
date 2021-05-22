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

CREATE OR REPLACE FUNCTION public.make_order_func(IN dish_name character varying)
    RETURNS integer
    LANGUAGE 'plpgsql'
    VOLATILE
    PARALLEL UNSAFE
    COST 100
    
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
	total INTEGER;
BEGIN	
	SELECT dishes.d_id INTO found_dish_id FROM dishes WHERE dishes.d_name = make_order_func.dish_name;
	IF found_dish_id IS NULL THEN
		RAISE NOTICE 'There"s no such dish';
		RETURN 0;
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
					RAISE NOTICE 'ingredient is missing';
					RETURN 0;
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
		SELECT SUM(price_)*max_count INTO total FROM dish_ingr;
		DROP TABLE dish_ingr;
		RETURN total;
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
		IF d_id IS NULL THEN
			RAISE NOTICE 'There''s no such dish';
		ELSE
			INSERT INTO new_order_composition VALUES (add_dish.d_name, 'dish', add_dish.d_count);
		END IF;
	ELSIF d_type = 'lunch' THEN
		SELECT set_lunches.l_id INTO found_id FROM set_lunches WHERE set_lunches.l_name = add_dish.d_name;
		IF d_id IS NULL THEN
			RAISE NOTICE 'There''s no such lunch';
		ELSE
			INSERT INTO new_order_composition VALUES (add_dish.d_name, 'lunch', add_dish.d_count);
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
BEGIN
	IF NOT EXISTS(SELECT * FROM new_order_compositionn LIMIT 1) THEN
		RAISE NOTICE 'Nothing to order';
		RETURN;
	ELSE
		INSERT INTO processing_orders(ord_start_time) VALUES (time_to_wait);
		--SELECT ord_id INTO new_ord_id FROM processing_orders ORDER BY ord_id DESC LIMIT 1;
		--INSERT INTO order_structure VALUES(SELECT new_ord_id, new_order_composition.d_id)
		IF (time_to_wait < INTERVAL '10m') THEN
			IF EXISTS (
				SELECT * FROM new_order_composition
						 JOIN dish_composition ON new_order_composition.d_id = dish_composition.dish_id
						 JOIN ingredients ON dish_composition.ing_id = ingredients.i_id)
						 WHERE *new_order_composition.d_cout
			FOR ... IN (SELECT d_name, d_category, d_count)
		ELSE

		END IF;
	END IF;
END;
$BODY$;


--итак планы: думаю стоит развернуть все ланчи в табличке new_order_composition, чтобы были только блюда.

