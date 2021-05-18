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
BEGIN	
	SELECT dishes.d_id INTO dish_id FROM dishes WHERE dishes.d_name = make_order.dish_name;
	IF dish_id IS NULL THEN
		RAISE ERROR 'There"s no such dish';
		RETURN;
	ELSE
		IF 
	END IF;
END;
$BODY$;
