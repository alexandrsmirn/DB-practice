/*-------------- ПРОСТЫЕ ЗАПРОСЫ --------------- */
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



/*------------- АНАЛИТИЧЕСКИЕ ЗАПРОСЫ -------------*/
--1
SELECT COUNT(employeeid) FROM employees;

--2
SELECT COUNT(productid) FROM products
WHERE price < 10;

--3
SELECT MAX(price) FROM products;

--4
SELECT * FROM products
ORDER BY price DESC
FETCH FIRST 1 ROWS WITH TIES;

--5
SELECT COUNT(productid) FROM products
WHERE name LIKE 'Metal Plate%';

--6
SELECT AVG(price) FROM products
WHERE name LIKE '% silver %';

--7
SELECT COUNT(customerid) from customers
WHERE firstname = 'Alicia';

--8
SELECT DISTINCT COUNT(firstname) FROM customers;

--9
SELECT COUNT(customerid) FROM customers
WHERE middleinitial IS NOT null;

--10
SELECT middleinitial FROM customers
GROUP BY middleinitial
ORDER BY COUNT(middleinitial) DESC
LIMIT 1;

--11
SELECT COUNT(customerid) FROM customers
WHERE middleinitial IS null;

--12
SELECT firstname, COUNT(firstname) FROM customers
GROUP BY firstname;

--13
SELECT firstname, middleinitial, COUNT(*) FROM customers
GROUP BY firstname, middleinitial
HAVING middleinitial IS NOT null;

--14
SELECT lastname, COUNT(*) AS emp_count FROM employees
GROUP BY lastname HAVING COUNT(*) > 1;

--15
SELECT COUNT(*)
FROM employees INNER JOIN sales ON employees.employeeid = sales.salespersonid
WHERE employees.firstname = 'Ann';

--16
SELECT COUNT(DISTINCT products.productid)
FROM sales INNER JOIN employees ON sales.salespersonid = employees.employeeid
			INNER JOIN products ON products.productid = sales.productid
WHERE employees.firstname = 'Ann';

--17
SELECT salespersonid, COUNT(salespersonid)
FROM sales
GROUP BY salespersonid;

--18
SELECT customerid, COUNT(customerid)
FROM sales
GROUP BY customerid;

--19
SELECT salespersonid, COUNT(salespersonid)
FROM sales
GROUP BY salespersonid
