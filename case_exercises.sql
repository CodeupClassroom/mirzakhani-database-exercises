-- CASE STATEMENTS -- 
USE employees;


-- EXERCISES --

-- Write a query that returns all employees, their department number, their
-- start date, their end date, and a new column 'is_current_employee' that is a
-- 1 if the employee is still with the company and 0 if not.

SELECT
    de.emp_no,
    de.dept_no,
    de.from_date AS start_date,
    de.to_date AS end_date,
    de.to_date > NOW() AS is_current_employee
FROM dept_emp de
ORDER BY emp_no
LIMIT 100;

-- Write a query that returns all employee names (previous and current), and a
-- new column 'alpha_group' that returns 'A-H', 'I-Q', or 'R-Z' depending on the
-- first letter of their last name.

SELECT
    first_name,
    last_name,
    LEFT(last_name, 1) AS first_letter_of_last_name,
    CASE
        WHEN LEFT(last_name, 1) <= 'H' THEN 'A-H'
        WHEN SUBSTR(last_name, 1, 1) <= 'Q' THEN 'I-Q'
        WHEN LEFT(last_name, 1) <= 'Z' THEN 'R-Z'
    END AS alpha_group
FROM employees;

-- How many employees (current or previous) were born in each decade?

SELECT
    COUNT(CASE WHEN birth_date BETWEEN '1950-01-01' AND '1959-12-31' THEN birth_date ELSE NULL END) AS '50s',
    COUNT(CASE WHEN birth_date BETWEEN '1960-01-01' AND '1969-12-31' THEN birth_date ELSE NULL END) AS '60s'
FROM employees;

# Another way:
SELECT
    CONCAT(SUBSTR(birth_date, 1, 3), '0') as decade,
    COUNT(*)
FROM employees
GROUP BY decade;

-- What is the current average salary for each of the following department
-- groups: R&D, Sales & Marketing, Prod & QM, Finance & HR, Customer Service?

SELECT
    CASE
        WHEN d.dept_name IN ('Research', 'Development') THEN 'R&D'
        WHEN d.dept_name IN ('Sales', 'Marketing') THEN 'Sales & Marketing'
        WHEN d.dept_name IN ('Production', 'Quality Management') THEN 'Prod & QM'
        WHEN d.dept_name IN ('Finance', 'Human Resources') THEN 'Finanace & HR'
        ELSE d.dept_name
    END AS dept_group, salary
FROM departments d
JOIN dept_emp de USING (dept_no)
JOIN salaries s USING (emp_no)
WHERE s.to_date > NOW() AND de.to_date > NOW()
;

-- #1 but more complicated

SELECT 
	de.emp_no,
	dept_no,
	hire_date,
    from_date,
	to_date,
	IF(to_date > CURDATE(), 1, 0) AS current_employee
FROM dept_emp AS de
JOIN (SELECT 
			emp_no,
			MAX(to_date) AS max_date
		FROM dept_emp
		GROUP BY emp_no) as last_dept 
		ON de.emp_no = last_dept.emp_no
			AND de.to_date = last_dept.max_date
JOIN employees AS e ON e.emp_no = de.emp_no;
