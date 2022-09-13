-- Join Example Database

-- 1. Use the join_example_db. 
-- Select all the records from both the users and roles tables.

USE join_example_db;

SELECT *
FROM users;

/*
id  name    email               role_id
_________________________________________
1	bob	    bob@example.com	    1
2	joe	    joe@example.com  	2
3	sally	sally@example.com	3
4	adam	adam@example.com	3
5	jane	jane@example.com	NULL
6	mike	mike@example.com	NULL
*/

SELECT *
FROM roles;

/*
id  name
______________
1	admin
2	author
3	reviewer
4	commenter
*/


-- 2. Use join, left join, and right join to combine results 
-- from the users and roles tables as we did in the lesson. 
-- Before you run each query, guess the expected number of results

-- a. Use JOIN (INNER JOIN - a logical AND statement, the intersection of the users table and the roles table). This returns only the rows with matches on both the left AND right tables. No NULL values.

SELECT *
FROM users
JOIN roles ON users.role_id = roles.id;

-- (4 rows) (No NULL values, Jane and Mike are missing (from users table), and the commenter role is missing (from the roles table) because they don't have matches on BOTH tables.)

/*
id  name     email             role_id  id  name
_____________________________________________________
1	bob	    bob@example.com	       1	1	admin
2	joe	    joe@example.com	       2	2	author
3	sally	sally@example.com	   3	3	reviewer
4	adam	adam@example.com	   3	3	reviewer
*/

-- If I want to handle the duplicate names in my tables, I could tweak my SELECT statement like this. I'll use this SELECT statement going forward for clarity in my joined table.

SELECT
	users.*,
	roles.name AS role_name
FROM users
JOIN roles ON users.role_id = roles.id;

/*
id  name    email             role_id  role_name
____________________________________________________
1	bob	    bob@example.com	    1	   admin
2	joe	    joe@example.com   	2	   author
3	sally	sally@example.com	3	   reviewer
4	adam	adam@example.com	3	   reviewer
*/

-- b. Use LEFT JOIN. This returns all of the rows from the users (left) table and only rows from the roles (right) table that have a match on the users (left) table.

SELECT
	users.*,
	roles.name AS role_name
FROM users
LEFT JOIN roles ON users.role_id = roles.id;

-- (6 rows) (Jane and Mike are here now with NULL values for role_id and role_name because all rows brought from the left table, users, but commenter still missing because no match on the left table.)

/*
id  name     email             role_id  role_name
_____________________________________________________
1	bob	    bob@example.com	       1	admin
2	joe	    joe@example.com	       2	author
3	sally	sally@example.com	   3	reviewer
4	adam	adam@example.com	   3	reviewer
5	jane	jane@example.com	 NULL   NULL
6	mike	mike@example.com	 NULL   NULL
*/

-- c. Use RIGHT JOIN. This does the opposite of the LEFT JOIN. This is not a common join because you can just reverse the order of your tables in your join and use a LEFT JOIN.

SELECT
	*
FROM users
RIGHT JOIN roles ON users.role_id = roles.id;

-- (5 rows) (Jane and Mike are missing now, but the non-matching rows from the right table, roles, are present with NULL values for the missing info from the left table, users.)

/*
id  name     email             role_id  role_name
_____________________________________________________
1	bob	    bob@example.com	       1	admin
2	joe	    joe@example.com	       2	author
3	sally	sally@example.com	   3	reviewer
4	adam	adam@example.com	   3	reviewer
NULL NULL	NULL	              NULL	commenter
*/

-- has 4 rows of data in the original table, but output has 5 rows. Why? To show all relevant relationships, values from the original table had to be duplicated
SELECT roles.name
FROM roles 
LEFT JOIN users ON roles.id = users.role_id;

-- 3. Although not explicitly covered in the lesson, aggregate functions like count can be used with join queries. Use count and the appropriate join type to get a list of roles along with the number of users that has the role. Hint: You will also need to use group by in the query.

SELECT
    -- rename roles.name column to role_name for clarity.
	roles.name AS role_name,
    
    -- I want to count the employees (users.name) for each role_name.
    -- my metric
	COUNT(users.name) AS number_of_employees
FROM users
RIGHT JOIN roles ON users.role_id = roles.id

-- my dimension (rows)
GROUP BY role_name;

/*
role_name   number_of_employees
_________________________________
admin	    1
author	    1
commenter	0
reviewer	2
*/

-- 1. Use the employees database.

USE employees;

-- 2. Using the example in the Associative Table Joins section as a guide, write a query that shows each department along with the name of the current manager for that department.

-- Inspect columns for each table first.

-- emp_no, birth_date, first_name, last_name, gender, hire_date (Use to get employees name.)
SELECT
	*
FROM employees
LIMIT 5;

-- emp_no, dept_no, from_date, to_date (Use to_date to find current managers)
SELECT
	*
FROM dept_manager;

-- dept_no, dept_name (Use to get department name.)
SELECT
	*
FROM departments;

-- JOIN tables and query.

SELECT
	d.dept_name,
	CONCAT(e.first_name, ' ', e.last_name) AS current_department_manager
FROM employees AS e
-- I can have multiple conditions in my JOIN logic. Only current department managers. I have to use "ON".
JOIN dept_manager AS dm ON e.emp_no = dm.emp_no
	AND to_date > CURDATE()
JOIN departments AS d USING(dept_no)
ORDER BY dept_name;

-- 3. Find the name of all departments currently managed by women.

SELECT
	d.dept_name,
	CONCAT(e.first_name, ' ', e.last_name) AS current_department_manager,
	gender
FROM employees AS e
-- I can add logic into my JOIN to now also filter for females only.
JOIN dept_manager AS dm ON e.emp_no = dm.emp_no
	AND to_date > CURDATE()
	AND gender = 'F'
JOIN departments AS d USING(dept_no)
ORDER BY dept_name;


-- 4. Find the current titles of employees currently working in the Customer Service department.

-- Inspect columns for each table first.

-- emp_no, dept_no, from_date, to_date (Use to find current employees.)
SELECT
	*
FROM dept_emp;

-- emp_no, title, from_date, to_date (Use to find current titles.)
SELECT
	*
FROM titles;

-- dept_no, dept_name (Use to get department name.)
SELECT
	*
FROM departments;

-- JOIN tables and query.

SELECT 
	t.title,
    -- My metric.
	COUNT(de.emp_no) AS Count
FROM dept_emp AS de
-- I can have multiple conditions in my JOIN logic. Only current employees and current titles.
JOIN titles AS t ON de.emp_no = t.emp_no
	AND t.to_date > CURDATE()
	AND de.to_date > CURDATE()
-- I can have multiple conditions in my JOIN logic. Only the Customer Service department.
JOIN departments AS d ON d.dept_no = de.dept_no
	AND dept_name = 'Customer Service'
-- My dimension. (rows)
GROUP BY t.title;

-- 5. Find the current salary of all current managers.

-- Inspect columns for each table first.
USE employees;
-- emp_no, birth_date, first_name, last_name, gender, hire_date (Use to find employee name)
SELECT
	*
FROM employees
LIMIT 5;

-- emp_no, salary, from_date, to_date (Use to find current salaries)
SELECT
	*
FROM salaries;

-- emp_no, dept_no, from_date, to_date (Use to_date to find current managers)
SELECT
	*
FROM dept_manager;

-- dept_no, dept_name (Use to get department name.)
SELECT
	*
FROM departments;

-- JOIN tables and query.

SELECT
	d.dept_name,
	CONCAT(e.first_name, ' ', e.last_name) AS current_department_manager,
	s.salary
FROM employees AS e
JOIN salaries AS s ON e.emp_no = s.emp_no
	AND s.to_date > CURDATE()
JOIN dept_manager AS dm ON dm.emp_no = e.emp_no
	AND dm.to_date > CURDATE()
JOIN departments AS d USING(dept_no)
ORDER BY dept_name;

-- 6. Find the number of current employees in each department.

-- Inspect columns for each table first.

-- emp_no, dept_no, from_date, to_date (Use to get current employees.)
SELECT
	*
FROM dept_emp;


-- dept_no, dept_name (Use to get department number and name.)
SELECT
	*
FROM departments;

-- JOIN tables and query.

SELECT
	d.dept_no,
	d.dept_name,
	COUNT(emp_no) AS num_employees
FROM dept_emp AS de
JOIN departments AS d ON de.dept_no = d.dept_no
	AND de.to_date > CURDATE()
GROUP BY dept_no, dept_name;

-- 7. Which department has the highest average salary? Hint: Use current not historic information.

-- Inspect columns for each table first.

-- emp_no, dept_no, from_date, to_date (Use to get current employees.)
SELECT
	*
FROM dept_emp;

-- emp_no, salary, from_date, to_date (Use to find current salaries)
SELECT
	*
FROM salaries;

-- dept_no, dept_name (Use to get department name.)
SELECT
	*
FROM departments;

-- JOIN tables and query.

SELECT
	d.dept_name,
	ROUND(AVG(salary), 2) AS average_salary
FROM dept_emp AS de
JOIN salaries AS s ON de.emp_no = s.emp_no
	AND de.to_date > CURDATE()
	AND s.to_date > CURDATE()
JOIN departments AS d ON de.dept_no = d.dept_no
GROUP BY d.dept_name
ORDER BY average_salary DESC
LIMIT 1;

-- 8. Who is the highest paid employee in the Marketing department?

-- Inspect columns for each table first.

-- emp_no, dept_no, from_date, to_date (Use to get current employees.)
SELECT
	*
FROM dept_emp;

-- emp_no, salary, from_date, to_date (Use to find current salaries)
SELECT
	*
FROM salaries;

-- dept_no, dept_name (Use to get department name.)
SELECT
	*
FROM departments;

-- JOIN tables and query.

SELECT
	e.first_name,
	e.last_name
FROM employees AS e
JOIN dept_emp AS de ON e.emp_no = de.emp_no
	AND de.to_date > CURDATE()
JOIN salaries AS s ON e.emp_no = s.emp_no
	AND s.to_date > CURDATE()
JOIN departments AS d ON de.dept_no = d.dept_no
	AND d.dept_name = 'Marketing'
ORDER BY s.salary DESC
LIMIT 1;

-- 9. Which current department manager has the highest salary?

-- Inspect columns for each table first.

-- emp_no, birth_date, first_name, last_name, gender, hire_date
SELECT
	*
FROM employees
LIMIT 5;

-- emp_no, dept_no, from_date, to_date (Use to_date to find current managers)
SELECT
	*
FROM dept_manager;

-- emp_no, salary, from_date, to_date (Use to find current salaries)
SELECT
	*
FROM salaries;

-- dept_no, dept_name (Use to get department name.)
SELECT
	*
FROM departments;

-- JOIN tables and query.

SELECT
	e.first_name,
	e.last_name,
	s.salary,
	d.dept_name
FROM employees AS e
JOIN dept_manager AS dm ON e.emp_no = dm.emp_no
	AND to_date > CURDATE()
JOIN salaries AS s ON e.emp_no = s.emp_no
	AND s.to_date > CURDATE()
JOIN departments AS d USING(dept_no)
ORDER BY s.salary DESC
LIMIT 1;

-- 10. Determine the average salary for each department. Use all salary information and round your results.
SELECT d.dept_name, ROUND(AVG(s.salary),0) AS avg_dept_salary
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN salaries s ON e.emp_no = s.emp_no
GROUP BY d.dept_name
ORDER BY avg_dept_salary DESC;

-- 11. Bonus: Find the names of all current employees, their department name, and their current manager's name.

-- Inspect columns for each table first.

-- emp_no, birth_date, first_name, last_name, gender, hire_date (Use to get employee and manager names.)
SELECT
	*
FROM employees
LIMIT 5;

-- emp_no, dept_no, from_date, to_date (Use to get current employees.)
SELECT
	*
FROM dept_emp;

-- emp_no, dept_no, from_date, to_date (Use to_date to find current managers)
SELECT
	*
FROM dept_manager;

-- dept_no, dept_name (Use to get department name.)
SELECT
	*
FROM departments;

-- JOIN tables and query.

-- Create table to get current manager names and department numbers. Join this table as m in larger query below.

SELECT
	dm.dept_no,
	CONCAT(e.first_name, ' ', e.last_name) AS managers
FROM employees AS e
JOIN dept_manager AS dm ON e.emp_no = dm.emp_no
	AND to_date > CURDATE();

-- Create query to get current employee names and dept names and manager names by joining subquery above.

SELECT
	CONCAT(e.first_name, ' ', e.last_name) AS 'Employee Name',
	d.dept_name AS 'Department Name',
	m.managers AS 'Manager Name'
FROM employees AS e
JOIN dept_emp AS de ON de.emp_no = e.emp_no
	AND de.to_date > CURDATE()
JOIN departments AS d ON de.dept_no = d.dept_no 
JOIN (SELECT
		 dm.dept_no,
		 CONCAT(e.first_name, ' ', e.last_name) AS managers
	 FROM employees AS e
	 JOIN dept_manager AS dm ON e.emp_no = dm.emp_no
		 AND to_date > CURDATE()) AS m ON m.dept_no = d.dept_no
ORDER BY d.dept_name;

-- Bonus 11 using a self-join.

-- Using a self join.

SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS 'Employee Name',
    d.dept_name AS 'Department Name',
    CONCAT(managers.first_name, ' ', managers.last_name) AS 'Manager_name'
FROM dept_emp AS de
JOIN employees AS e USING(emp_no)
JOIN departments AS d ON d.dept_no = de.dept_no
-- Get the current department managers, join on dept_no.
JOIN dept_manager AS dm ON dm.dept_no = d.dept_no 
    AND dm.to_date > CURDATE()
-- Join employees again as managers to get manager names.
JOIN employees AS managers ON managers.emp_no = dm.emp_no
WHERE de.to_date > CURDATE()
ORDER BY d.dept_name;