USE farmers_market;

-- Basic Case Statement

SELECT *,
	CASE booth_type
		WHEN 'standard' THEN 1
        ELSE 0
	END AS is_standard    
FROM booth;

-- Verbose Case Statements

-- -- Creating New Categories
SELECT product_category_name,
	CASE 
		WHEN product_category_name LIKE '%fresh%' THEN 'Fresh'
        WHEN product_category_name LIKE '%packaged%' THEN 'Packaged'
        ELSE 'Non-Edible'
	END
FROM product_category;

-- -- Investigate Prices
SELECT DISTINCT cost_to_customer_per_qty
FROM customer_purchases
ORDER BY cost_to_customer_per_qty;

-- -- Create Price Categories
SELECT *,
	CASE
		WHEN cost_to_customer_per_qty <= 1 THEN 'Cheap'
        WHEN cost_to_customer_per_qty > 1 AND cost_to_customer_per_qty < 5  THEN 'Mid-range'
        WHEN cost_to_customer_per_qty >= 5 THEN 'High-end'
	END AS price_category
FROM customer_purchases;

-- IF() Function
SELECT AVG(quantity)
FROM customer_purchases;

SELECT *,
	IF(quantity > (SELECT AVG(quantity) FROM customer_purchases), 'Large Purchase', 'Normal Purchase') AS purchase_type
FROM customer_purchases;

-- Making Pivot Tables
-- Here, I'm building up my columns and values before I group by departments and use an aggregate function to get a count of values in each column.
USE employees;

SELECT
    dept_name,
    CASE WHEN title = 'Senior Engineer' THEN title ELSE NULL END AS 'Senior Engineer',
    CASE WHEN title = 'Staff' THEN title ELSE NULL END AS 'Staff',
    CASE WHEN title = 'Engineer' THEN title ELSE NULL END AS 'Engineer',
    CASE WHEN title = 'Senior Staff' THEN title ELSE NULL END AS 'Senior Staff',
    CASE WHEN title = 'Assistant Engineer' THEN title ELSE NULL END AS 'Assistant Engineer',
    CASE WHEN title = 'Technique Leader' THEN title ELSE NULL END AS 'Technique Leader',
    CASE WHEN title = 'Manager' THEN title ELSE NULL END AS 'Manager'
FROM departments
JOIN dept_emp USING(dept_no)
JOIN titles USING(emp_no);

-- Next, I add my GROUP BY clause and COUNT function to get a count of all employees who have historically ever held a title by department. (I'm not filtering for current employees or current titles.)
SELECT
    dept_name,
    COUNT(CASE WHEN title = 'Senior Engineer' THEN title ELSE NULL END) AS 'Senior Engineer',
    COUNT(CASE WHEN title = 'Staff' THEN title ELSE NULL END) AS 'Staff',
    COUNT(CASE WHEN title = 'Engineer' THEN title ELSE NULL END) AS 'Engineer',
    COUNT(CASE WHEN title = 'Senior Staff' THEN title ELSE NULL END) AS 'Senior Staff',
    COUNT(CASE WHEN title = 'Assistant Engineer' THEN title ELSE NULL END) AS 'Assistant Engineer',
    COUNT(CASE WHEN title = 'Technique Leader' THEN title ELSE NULL END) AS 'Technique Leader',
    COUNT(CASE WHEN title = 'Manager' THEN title ELSE NULL END) AS 'Manager'
FROM departments
JOIN dept_emp USING(dept_no)
JOIN titles USING(emp_no)
GROUP BY dept_name
ORDER BY dept_name;


-- In this query, I filter in my JOINs for current employees who currently hold each title.
SELECT
    dept_name,
    COUNT(CASE WHEN title = 'Senior Engineer' THEN title ELSE NULL END) AS 'Senior Engineer',
    COUNT(CASE WHEN title = 'Staff' THEN title ELSE NULL END) AS 'Staff',
    COUNT(CASE WHEN title = 'Engineer' THEN title ELSE NULL END) AS 'Engineer',
    COUNT(CASE WHEN title = 'Senior Staff' THEN title ELSE NULL END) AS 'Senior Staff',
    COUNT(CASE WHEN title = 'Assistant Engineer' THEN title ELSE NULL END) AS 'Assistant Engineer',
    COUNT(CASE WHEN title = 'Technique Leader' THEN title ELSE NULL END) AS 'Technique Leader',
    COUNT(CASE WHEN title = 'Manager' THEN title ELSE NULL END) AS 'Manager'
FROM departments
JOIN dept_emp
    ON departments.dept_no = dept_emp.dept_no AND dept_emp.to_date > CURDATE()
JOIN titles
    ON dept_emp.emp_no = titles.emp_no AND titles.to_date > CURDATE()
GROUP BY dept_name
ORDER BY dept_name;

-- With Farmers Market
USE farmers_market;

SELECT vendor_name,
	COUNT(CASE WHEN booth_type = 'Standard' THEN booth_type ELSE NULL END) AS 'Standard',
    COUNT(CASE WHEN booth_type = 'Large' THEN booth_type ELSE NULL END) AS 'Large',
    COUNT(CASE WHEN booth_type = 'Small' THEN booth_type ELSE NULL END) AS 'Small'
FROM vendor_booth_assignments vba
JOIN booth b ON vba.booth_number = b.booth_number
JOIN vendor v ON vba.vendor_id = v.vendor_id
GROUP BY vendor_name;