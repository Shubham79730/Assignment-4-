-- First Normal Form (1NF):
-- Question - Identify a table in the Sakila database that violates 1NF. Explain how you would normalize it to achieve 1NF.

-- Answer -  In the provided Sakila database, the table 'film' may violate the second normal form (2NF) rather than the first normal form (1NF).
--	The reason is that the 'original_language_id' column in the 'film' table might introduce partial dependencies. The 'original_language_id' 
--  column references the 'language table', and if it is not nullable, it implies that the other attributes in the 'language' table might be 
--  functionally dependent on only a part of the primary key (film_id).

-- Second Normal Form (2NF):
-- Question - Choose a table in Sakila and describe how you would determine whether it is in 2NFb If it violates 2NF,explain the steps to normalize it.

-- Answer -   The 'film_category' table has a composite primary key '(film_id, category_id)', and there are foreign key constraints referencing
--            the 'film' and 'category' tables. To determine whether it is in 2NF, we need to check if it has partial dependencies.

-- 			  In this case, the table appears to be in 2NF because the primary key is composite and includes both 'film_id' and 'category_id'.
--            Each of these attributes seems to be functionally dependent on the entire primary key.

--            If there were columns related to only one part of the primary key (e.g., if category_id depended on only film_id or vice versa),
--            it would violate 2NF.

--            Since the current structure seems appropriate, there's no need for further normalization steps for the 'film_category' table 
--            regarding 2NF.

-- Third Normal Form (3NF):
-- Question - Identify a table in Sakila that violates 3NF Describe the transitive dependencies present and outline the steps to normalize 
--            the table to 3NF.

-- Answer -   Let's analyze the 'staff' table in the Sakila database to determine whether it is in the third normal form (3NF). If it violates 
--            3NF, we'll identify the transitive dependencies and outline the steps to normalize the table.

--            The potential violation of 3NF in the staff table can be identified through the 'store_id' column. It appears that there 
--            might be a transitive dependency between 'store_id' and other non-key attributes, such as 'store_id' → 'address_id'.

--            To normalize the table to 3NF, we can create a new table specifically for the 'store' information:

--            Now, the 'staff' table is normalized to 3NF, and the transitive dependency between 'store_id' and 
--            'address_id' is resolved by introducing a new table for the store information.

-- Normalization Process:
-- Question - Take a specific table in Sakila and guide through the process of normalizing it from the initial
--            unnormalized form up to at least 2NF.

-- Answer -   Let's consider the customer table in the Sakila database for normalization. We'll go through the process of normalizing it from 
--            an initial unnormalized form up to at least the second normal form (2NF).

--            Step 1: Identify Functional Dependencies
--            1.Customer_id → First_name, Last_name, Email, Address_id, Active, Create_date, Last_update
--            2.Address_id → Address, Address2, District, City_id, Postal_code, Phone
--            3.Store_id → [Attributes related to the store]

--            Step 2: Eliminate Partial Dependencies
--            Since there are no partial dependencies in the initial table, we can move on to the next step.

--            Step 3: Eliminate Transitive Dependencies (Normalization to 2NF)
--            The transitive dependency we need to address is Store_id → [Attributes related to the store]. To do this, we create a new 
--            table for the store information.

--            Now, the 'customer' table is in at least the second normal form (2NF). We have eliminated the transitive dependency by creating 
--            a separate table for store information, ensuring that each non-prime attribute is fully functionally dependent on the primary 
--            key. Further normalization to 3NF can be done if needed by addressing any remaining transitive dependencies.


-- CTE Basics
-- Write a query using a CTE to retrieve the distinct list of actor names and the number of films they have acted in from the actor and film_actor tables.
   with Actorfilmcount as(
   select a.actor_id,a.first_name,a.last_name,count(fa.film_id) as film_count from actor a join film_actor fa on a.actor_id = fa.actor_id group by a.actor_id)
   select actor_id,first_name,last_name,film_count from Actorfilmcount;
   
-- Recursive CTE>
-- Use a recursive CTE to generate a hierarchical list of categories and their subcategories from the category table in Sakila.
     --  data set is not allign
   WITH RecursiveCategory  AS (
    SELECT
        category_id,
        name,
        0 AS level
    FROM
        category
        
    UNION ALL
    SELECT
        c.category_id,
        c.name,
        rc.level + 1 AS level
    FROM
        category c
    INNER JOIN
        RecursiveCategory rc ON c.category_id = rc.category_id
)

SELECT
    category_id
FROM
    RecursiveCategory
ORDER BY
    category_id;
    


-- CTE with Joins
-- Create a CTE that combines information from the film and language tables to display the film title,language name,and rental rate.
   with Filmlanguage as (
   select f.title,l.name,f.rental_rate from film f join language l on f.language_id=l.language_id)
   select title,name,rental_rate from Filmlanguage;
   
-- CTE for Aggregation
-- Write a query using a CTE to find the total revenue generated by each customer (sum of payments) from the customer and payment tables.
   with totalrevenue as (
   select c.customer_id,c.first_name,c.last_name,sum(p.amount) as total_revenue from customer c left join payment p on c.customer_id=p.customer_id group by customer_id)
   select customer_id,first_name,last_name,total_revenue from totalrevenue;
   
-- CTE with Window Functions
-- Utilize a CTE with a window function to rank films based on their rental duration from the film table.
   with filmRank as(
   select film_id, title,rental_duration,dense_rank() over (order by rental_duration desc) as rental_rank from film)
   select film_id,title,rental_duration,rental_rank from filmRank order by rental_rank;
   
-- CTE and Filtering
-- Create a CTE to list customers who have made more than two rentals, and then join this CTE with the customer table to retrieve additional customer details.
   with customerRental as (
   select customer_id,count(rental_id) as rental_count from rental group by customer_id having count(rental_id)>2)
   select c.customer_id,c.first_name,c.last_name,c.email,c.address_id,c.active,c.create_date,c.last_update,cr.rental_count 
   from customer c join customerRental cr on c.customer_id=cr.customer_id;
  
-- CTE for Date Calculations
-- Write a query using a CTE to find the total number of rentals made each month, considering the rental_date from the rental table.
   with MonthlyrentalCount as (
   select extract(year_month from rental_date)as rental_month,count(rental_id) as total_rental from rental group by rental_month)
   select rental_month,total_rental from MonthlyrentalCount order by rental_month;
   

-- CTE for Pivot Operations
-- Use a CTE to pivot the data from the payment table to display the total payments made by each customer in separate columns for different payment methods.
   with Pivotpayment as (
   select customer_id,
                     sum(case when "payment_type" = "cash" then amount else 0 end) as cash_total,
                     sum(case when "payment_type" = "credit card" then amount else 0 end) as credit_card_total,
                     sum(case when "payment_type" = "debit card" then amount else 0 end) as debit_card_total,
                     sum(case when "payment_type" = "check" then amount else 0 end) as check_total
  from payment group by customer_id )
  select cash_total,credit_card_total,debit_card_total,check_total from Pivotpayment;
  
-- CTE and Self-Join
-- Create a CTE to generate a report showing pairs of actors who have appeared in the same film together,using the film_actor table.
   WITH ActorPairs AS (
    SELECT
        fa1.actor_id AS actor1_id,
        fa2.actor_id AS actor2_id,
        f.film_id,
        f.title AS film_title
    FROM
        film_actor fa1
    JOIN
        film_actor fa2 ON fa1.film_id = fa2.film_id AND fa1.actor_id < fa2.actor_id
    JOIN
        film f ON fa1.film_id = f.film_id
)

SELECT
    ap.actor1_id,
    a1.first_name AS actor1_first_name,
    a1.last_name AS actor1_last_name,
    ap.actor2_id,
    a2.first_name AS actor2_first_name,
    a2.last_name AS actor2_last_name,
    ap.film_id,
    ap.film_title
FROM
    ActorPairs ap
JOIN
    actor a1 ON ap.actor1_id = a1.actor_id
JOIN
    actor a2 ON ap.actor2_id = a2.actor_id;  
    
-- CTE for Recursive Search:
-- Implement a recursive CTE to find all employees in the staff table who report to a specific manager,considering the reports_to column.
-- data set is not allign
  WITH RecursiveHierarchy AS (
    SELECT
        staff_id,
        first_name,
        last_name,
        reports_to
    FROM
        staff
    WHERE
        reports_to = 1  -- Replace 1 with the manager_id you are interested in

    UNION ALL

    SELECT
        s.staff_id,
        s.first_name,
        s.last_name,
        s.reports_to
    FROM
        staff s
    JOIN
        RecursiveHierarchy rh ON s.reports_to = rh.staff_id
)

SELECT
    staff_id,
    first_name,
    last_name,
    reports_to
FROM
    RecursiveHierarchy;
   
   
   