use employees;

# 1. Find all the current employees with the same hire date as employee 101010 using a sub-query.
select *
from employees
JOIN dept_emp using(emp_no)
where to_date > now()
and hire_date =
	(select hire_date
	from employees
	where emp_no = 101010);
	

# 2
# Find all the titles ever held by all current employees with the first name Aamod.

select distinct title
from titles
where emp_no IN (
   select emp_no
   from employees
   join dept_emp using(emp_no)
   where first_name = 'aamod'
   and to_date > now()
);

# 3 How many people in the employees table are no longer working for the company? 

select count(*) # count all the records
from employees # from the employees table
where emp_no not in 
	(select emp_no
	from dept_emp
	where to_date > now()
);
-- Same solution using 'salaries' table:
select *
from employees
where emp_no NOT IN
	(
	select emp_no
	from salaries
	where to_date > now()
	);


# 4
-- # Find all the current department managers that are female. List their names in a comment in your code.
select *
from employees
where emp_no in (
    select emp_no
       from dept_manager
          where to_date > now()
)
and gender = "F";


-- # 5 Find all the employees who currently have a higher salary than the 
-- #companies overall, historical average salary (154,726 records )

-- # (154,543 records). 
select emp_no
from salaries s
join employees e using(emp_no)
where to_date > now() 
and  salary > (select avg(salary) from salaries) ;



# 6
# How many current salaries are within 1 standard deviation of the current highest salary? 
#(Hint: you can use a built in function to calculate the standard deviation.) 
# What percentage of all salaries is this?





-- # what is the max current salary:
select max(salary) from salaries where to_date > now();

-- # what is the 1 std for current salary;
select stddev(salary) from salaries where to_date > now();

-- Count of current salaries > (Max-1 std). (count = 83)
select count(*)
from salaries
where to_date > now()
and salary > (
(select max(salary) from salaries where to_date > now()) - 
(select std(salary) from salaries where to_date > now())
);

-- Denominator, count of all current salaries (240,124)
select count(*)
from salaries 
where to_date > now();


-- What percentage of all salaries is this?
-- SELECT (Numerator)/ (Denominator)
select((select count(*)
from salaries
where to_date > now()
and salary > (
(select max(salary) from salaries where to_date > now()) - 
(select std(salary) from salaries where to_date > now())
))/(select count(*)
from salaries 
where to_date > now())) * 100 as "percentage of salaries within 1 Stdev of Max";