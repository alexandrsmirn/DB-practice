INSERT INTO ingredients(d_name, available_count, reserved_count, price) VALUES
	('Chicken', 5000, 0, 50.00), --1
	('Potato', 20000, 0, 6.00),  --2
	('Pasta', 10000, 0, 10.00),	 --3
	('Fish', 5000, 0, 100.00),	 --4
	('Buckwheat', 20000, 0, 11.00), --5
	('Rise', 10000, 0, 10.00),		 --6
	('Sausage', 5000, 0, 10.00),	 --7
	('Pork', 5000, 0, 60.00),		 --8
	('Cucumber', 5000, 0, 20.00),	 --9
	('Tomato', 5000, 0, 20.00),	 --10
	('Minced meat', 5000, 0, 40.00), --11
	('Apple juice', 5000, 0, 20.00), --12
	('Green tea', 100, 0, 20.00),	  --13
	('Water', 100000, 0, 30.00),	  --14
	('Milk', 10000, 0, 40.00),	  --15	
	('Cheese', 5000, 0, 60.00),		  --16
	('Dough', 20000, 0, 20.00),	  --17
	('Black tea', 100, 0, 30.00),	  --18
	('Ice cream', 7000, 0, 20.00),	--19
	('Caramel', 5000, 0, 60.00), 	--20
	('Chocolate', 5000, 0, 50.00),	--21
	('Strawberry', 2000, 0, 70.00),	--22
	('Banana', 7000, 0, 50.00),		--23
	('Apple', 7000, 0, 50.00),		--24
	('Pear', 7000, 0, 50.00);		--25
	
	
INSERT INTO dishes(d_name, d_type) VALUES
	('Pilaf', 'Georgian'),					--1
	('Buckwheat with sausages', 'Russian'),	--2
	('Puree with cutlet', 'Russian'),		--3
	('Apple juice', 'Cold drink'),			--4
	('Green tea', 'Hot drink'),				--5
	('Pizza', 'Italian'),					--6
	('Sushi', 'Japanece'),					--7
	('Vegetable salad', 'Salad'),			--8
	('Fried potato', 'Russian'),			--9
	('Black tea', 'Hot drink'),				--10
	('Pasta with cheese', 'Italian'),		--11	
	('Ice cream with chocolate', 'Dessert'),--12
	('Ice cream with caramel', 'Dessert'),	--13
	('Ice cream with strawberry', 'Dessert'),--14
	('Banana with strawberry and chocolate', 'Dessert'), --15
	('Banana with caramel', 'Dessert'),		--16	
	('Fruit salad', 'Dessert'),				--17
	('Apples with caramel', 'Dessert');		--18
	
		
--INSERT INTO ingredients_replacement VALUES

INSERT INTO dish_composition(dish_id, ing_id, ing_amount) VALUES
	(1, 6, 200),
	(1, 8, 100),
	
	(2, 5, 250),
	(2, 7, 60),
	
	(3, 11, 100),
	(3, 2, 250),
	(3, 15, 70),
	
	(4, 12, 200),
		
	(5, 13, 1),
	(5, 14, 200),
	
	(6, 17, 300),
	(6, 16, 100),
	(6, 10, 50),
	(6, 1, 100),
	
	(7, 6, 100),
	(7, 4, 50),
	
	(8, 9, 100),
	(8, 10, 100),
	
	(9, 2, 300),
	(9, 15, 200),
	
	(10, 18, 1),
	(10, 14, 200),
	
	(11, 3, 300),
	(11, 16, 50),
	
	(12, 19, 250),
	(12, 21, 70),
	
	(13, 19, 250),
	(13, 20, 70),
	
	(14, 19, 250),
	(14, 22, 50),
	
	(15, 21, 70),
	(15, 22, 100),
	(15, 23, 200),
	
	(16, 23, 200),
	(16, 20, 50),
	
	(17, 23, 100),
	(17, 24, 100),
	(17, 25, 100),
	
	(18, 24, 200),
	(18, 20, 50);

INSERT INTO set_lunches(l_name) VALUES
	('Lunch_1'),
	('Lunch_2'),
	('Lunch_3');
	
	
INSERT INTO lunch_composition VALUES
	(1, 8),  --salad
	(1, 2),  --buckweat with sausages
	(1, 10), --black tea
	
	(2, 7),  --sushi
	(2, 3),  --pure with cutlet
	(2, 5),  --green tea
	
	(3, 6),  --pizza
	(3, 11), --pasta with cheese
	(3, 12); --apple juice
	
INSERT INTO ingredients_replacement VALUES
	(1, 8),		--chicken with pork
	(8, 1),
	
	(13, 18),	--black tea with green tea
	(18, 13),
	
	(24, 25),	--apple and pear
	(25, 24),
	
	(7, 11),	--minced meat and sausage
	(11, 7),
	
	(5, 6),		--buckwheat and rise
	(6, 5),
	
	(20, 21),	--caramel and chocolate
	(21, 20);
	
	
	
	
	
	
	
	
	
