--1
SELECT COUNT(*) FROM dishes WHERE dishes.d_type = 'Dessert';

--2
SELECT dishes.d_name, ingredients.d_name, dish_composition.ing_amount
	FROM dishes
	JOIN dish_composition ON dishes.d_id = dish_composition.dish_id
	JOIN ingredients ON dish_composition.ing_id = ingredients.i_id
	WHERE ingredients.d_name IN ('Apple', 'Banana', 'Pear');
