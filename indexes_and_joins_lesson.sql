-- INDEXES & JOINS LESSON QUERIES --

USE employees;

-- Let's get a sense of what the tables in our database look like. 
-- I'm particularly interested in identifying PRIMARY KEY and FOREIGN KEY columns
DESCRIBE departments;

SELECT * FROM departments;

DESCRIBE dept_emp;

-- dept_emp seems to have 2 primary keys from the output of DESCRIBE
-- Let's look at the table creation code to see what happened:
SHOW CREATE TABLE dept_emp;

/*'CREATE TABLE `dept_emp` (
  `emp_no` int NOT NULL,
  `dept_no` char(4) NOT NULL,
  `from_date` date NOT NULL,
  `to_date` date NOT NULL,
  PRIMARY KEY (`emp_no`,`dept_no`),
  KEY `dept_no` (`dept_no`),
  CONSTRAINT `dept_emp_ibfk_1` FOREIGN KEY (`emp_no`) REFERENCES `employees` (`emp_no`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `dept_emp_ibfk_2` FOREIGN KEY (`dept_no`) REFERENCES `departments` (`dept_no`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=latin1' 

It appears that the primary key is made up of two different columns
This table is a "joiner" table, used to connect two tables that wouldn't otherwise have a connection
*/

-- Let's try and inner join the employees table to the departments table
-- There is no direct connect, so we will join the employees table to the dept_emp table first
DESCRIBE employees;

-- What do these tables look like again?
SELECT * FROM employees LIMIT 50;

SELECT * FROM dept_emp LIMIT 50;

-- Inner join of employees and dept_emp
SELECT *
FROM employees
JOIN dept_emp ON employees.emp_no = dept_emp.emp_no
LIMIT 50;

-- Now that I've successfully joined employees to dept_emp, I'll add on to my query
-- Inner join of employees, dept_emp, and departments
SELECT *
FROM employees
JOIN dept_emp ON employees.emp_no = dept_emp.emp_no
JOIN departments ON dept_emp.dept_no = departments.dept_no
LIMIT 50;

-- Suppose I don't need every single column from all three tables. I can specify what I want
-- Selecting first_name, last_name, and dept_name from inner join of employees, dept_emp, and departments
SELECT employees.first_name,
		employees.last_name,
        departments.dept_name
FROM employees
JOIN dept_emp ON employees.emp_no = dept_emp.emp_no
JOIN departments ON dept_emp.dept_no = departments.dept_no
LIMIT 50;

-- Same as above, but with aliases
SELECT e.first_name,
		e.last_name,
        d.dept_name
FROM employees AS e
JOIN dept_emp AS de ON e.emp_no = de.emp_no
JOIN departments AS d ON de.dept_no = d.dept_no
LIMIT 50;

-- Same as above, but let's add a WHERE clause. 
-- Notice that it is filtering on a column that isn't in our SELECT statement and this is ok
SELECT e.first_name,
		e.last_name,
        d.dept_name
FROM employees AS e
JOIN dept_emp AS de ON e.emp_no = de.emp_no
JOIN departments AS d ON de.dept_no = d.dept_no
WHERE e.gender = 'F';