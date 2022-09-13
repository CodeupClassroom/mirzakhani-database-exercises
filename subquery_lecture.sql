USE farmers_market;

-- Scalar Subquery
SELECT *
FROM market_date_info
WHERE market_min_temp < (
							SELECT AVG(macrket_min_temp) 
                            FROM market_date_info
                            WHERE market_day = 'Saturday'
						);
                            

-- Column Subquery
SELECT *
FROM vendor
WHERE vendor_id IN (
                        SELECT vendor_id
                        FROM vendor_booth_assignments
                        WHERE market_date = '2019-04-03'
                    );


-- Row Subquery
USE farmers_market;

SELECT customer_first_name, customer_last_name
FROM customer
WHERE customer_id = (
						SELECT customer_id
						FROM customer_purchases
						ORDER BY market_date DESC, transaction_time DESC
						LIMIT 1
                    );

-- Table Subquery
USE farmers_market;

SELECT *
FROM customer;

SELECT *
FROM (
		SELECT *
		FROM customer
	) AS c
JOIN customer_purchases cp ON c.customer_id = cp.customer_id;

SELECT *
FROM customer_purchases cp
JOIN (
		SELECT *
		FROM customer
	) AS c ON cp.customer_id = c.customer_id;