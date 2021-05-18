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




CREATE OR REPLACE PROCEDURE public.make_order(
		dish_name VARCHAR(50);
		)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	dish_id INTEGER := NULL;
	max_count INTEGER := 10000000;
	id_to_change INTEGER := NULL;
BEGIN	
	SELECT dishes.d_id INTO dish_id FROM dishes WHERE dishes.d_name = make_order.dish_name;
	IF dish_id IS NULL THEN
		RAISE ERROR 'There"s no such dish';
		RETURN;
	ELSE
		CREATE TEMP TALBE dish_ingr AS
			SELECT id_ AS ingredients.i_id, ingredients.d_name AS name_, dish_composition.ing_amount AS amount_, ingredients.available_count AS available_, ingredients.price AS price_ FROM dishes
			JOIN dish_composition ON dishes.d_id = dish_composition.dish_id
			JOIN ingredients ON dish_composition.ing_id = ingredients.i_id;
			
		FOR id__, name__, amount__, available__, price__ IN dish_ingr
		LOOP
			IF amount__ > available__ THEN
				SELECT change_id INTO id_to_change FROM ingredients_replacement WHERE i_id = id__;
				IF change_id IS NULL THEN
					RAISE ERROR 'ingredient is missing';
					RETURN;
				ELSE
					RAISE NOTICE 'change ingredient';
					--DELETE FROM dish_ingr WHERE dish_ing.id_ = id__;
					--INSERT INTO dish_ingr VALUES (SELECT i_id, )
					UPDATE dish_ingr SET price_ = (SELECT price FROM ingredients WHERE i_id = change_id) WHERE id_ = id__;
				END IF;
			ELSIF available__ / amount__ < max_count THEN
				max_count = available__ / amount__;
			END IF;
		END LOOP;
		SELECT COUNT(price_)*max_count FROM dish_ingr;
	END IF;
END;
$BODY$;
