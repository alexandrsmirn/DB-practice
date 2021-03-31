/* ПРОСТЫЕ ЗАПРОСЫ */
--1
SELECT * FROM employees;
	
--2
SELECT * FROM employees
ORDER BY firstname;
	
--3
SELECT * FROM employees WHERE firstname = 'Ann';
	
--4
SELECT lastname FROM employees WHERE firstname = 'Ann';
	
--5
SELECT MAX(employeeid) AS max_id FROM employees;
	
--6
SELECT * FROM products WHERE price < 10;

--7
SELECT * FROM products
ORDER BY price DESC
LIMIT 1;

--8
SELECT * FROM products
ORDER BY price DESC
FETCH FIRST 1 ROWS WITH TIES;

--9
SELECT * FROM products
WHERE name LIKE 'Metal Plate%';
	
--10
SELECT * FROM products
WHERE name LIKE '% silver %';
	
--11
SELECT * FROM customers
WHERE firstname = 'Alicia';

--12
SELECT * FROM customers
WHERE firstname = 'Alicia' AND middleinitial IS NOT null;

--13
SELECT * FROM customers
WHERE firstname = 'Alicia' AND middleinitial IS null;

--14
SELECT DISTINCT firstname FROM customers;

--15
SELECT t1.employeeid, t2.employeeid, t1.lastname
FROM employees AS t1, employees AS t2
WHERE t1.lastname = t2.lastname AND t1.employeeid < t2.employeeid;
	
--16
SELECT * 
FROM sales INNER JOIN employees ON sales.salespersonid = employees.employeeid
WHERE employees.firstname = 'Ann';

--17
SELECT DISTINCT products.name
FROM sales INNER JOIN employees ON sales.salespersonid = employees.employeeid
			INNER JOIN products ON products.productid = sales.productid
WHERE employees.firstname = 'Ann';
