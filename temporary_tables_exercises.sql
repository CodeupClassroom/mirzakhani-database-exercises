use andrew_king;
	
-- Exercise 1
-- Using the example from the lesson, create a temporary table called employees_with_departments 
-- Add a column named full_name to this table. It should be a VARCHAR whose length is the sum of the lengths of the first name and last name columns
-- Update the table so that full name column contains the correct data
-- Remove the first_name and last_name columns from the table.
-- What is another way you could have ended up with this same table?

-- step 1: create the query using the db_name.table_name syntax
select first_name, last_name, dept_name
from employees.employees
join employees.dept_emp using(emp_no)
join employees.departments using(dept_no)
where to_date > curdate();

-- use that query to make a temporary table

drop table if exists employees_with_departments;

create temporary table employees_with_departments as (
    select first_name, last_name, dept_name
    from employees.employees
    join employees.dept_emp using(emp_no)
    join employees.departments using(dept_no)
    where to_date > curdate()
);


-- check that our table exists
select * from employees_with_departments;


-- step 3: add the full_name column
alter table employees_with_departments add full_name VARCHAR(30);

-- step 4: set the values for the full_name column
update employees_with_departments set full_name = concat(first_name, ' ', last_name);

-- step 5: drop any unused columns
ALTER TABLE employees_with_departments DROP COLUMN first_name;
ALTER TABLE employees_with_departments DROP COLUMN last_name;

-- double check the work
select * from employees_with_departments;

-- Another way to create the same result? Create the full_name in the original query
drop table if exists employees_with_departments;

-- If our query can produce the right pooutput in the selects, then let's do that
create temporary table employees_with_departments as 
select concat(first_name, " ", last_name) as full_name, dept_name
from employees.employees
join employees.dept_emp using(emp_no)
join employees.departments using(dept_no)
where to_date > curdate();

select * from employees_with_departments;

-- Exercise 2
-- Write the SQL necessary to transform the amount column such that it is stored as an integer representing the number of cents of the payment. For example, 1.99 should become 199.

use andrew_king;

-- clean up any old version of this table (only if it already exists)
drop table if exists payments;
select * from sakila.payment;

create temporary table payments as (
    select payment_id, customer_id, staff_id, rental_id, amount * 100 as amount_in_pennies, payment_date, last_update
    from sakila.payment
);

select * from payments;
describe payments;

ALTER TABLE payments MODIFY amount_in_pennies int NOT NULL;




use andrew_king;
-- Exercise 3
-- 

-- Overall current salary stats
select avg(salary), std(salary) from employees.salaries where to_date > now();

-- 72,012 overall average salary
-- 17,310 overall standard deviation

-- Saving my values for later... that's what variables do (with a name)
-- Think about temp tables like variables
create temporary table overall_aggregates as (
    select avg(salary) as avg_salary, std(salary) as std_salary
    from employees.salaries  where to_date > now()
);

-- double check that the values look good.
select * from overall_aggregates;


-- Let's check out our current average salaries for each department
-- If you see "for each" in the English for a query to build..
-- Then, you're probably going to use a group by..
select dept_name, avg(salary) as department_current_average
from employees.salaries
join employees.dept_emp using(emp_no)
join employees.departments using(dept_no)
where employees.dept_emp.to_date > curdate()
and employees.salaries.to_date > curdate()
group by dept_name;

drop table if exists current_info;

# create the temp table using the query above
create temporary table current_info as (
    select dept_name, avg(salary) as department_current_average
    from employees.salaries
    join employees.dept_emp using(emp_no)
    join employees.departments using(dept_no)
    where employees.dept_emp.to_date > curdate()
    and employees.salaries.to_date > curdate()
    group by dept_name
);

select * from current_info;

-- add on all the columns we'll end up needing:
alter table current_info add overall_avg float(10,2);
alter table current_info add overall_std float(10,2);
alter table current_info add zscore float(10,2);

# peek at the table again
select * from current_info;

-- set the avg and std
update current_info set overall_avg = (select avg_salary from overall_aggregates);
update current_info set overall_std = (select std_salary from overall_aggregates);



-- update the zscore column to hold the calculated zscores
update current_info 
set zscore = (department_current_average - overall_avg) / overall_std;



select * from andrew_king.current_info
order by zscore desc;


SELECT AVG(salary), STDDEV(salary)
FROM employees.salaries;