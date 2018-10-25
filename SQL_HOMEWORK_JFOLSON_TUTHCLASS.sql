-- SQL assignment J Francis Olson:  Answer the following questions
--  1a. Display the first and last names of all actors from the table `actor`.
USE sakila;

SELECT actor_id AS id, first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column 
-- in upper case letters. Name the column `Actor Name`.
SELECT CONCAT(first_name, ' ', last_name) AS 'Actor Name' FROM actor
ORDER BY last_name;

-- 2a. You need to find the ID number, first name, and last name of an actor,
-- of whom you know only the first name, "Joe."
-- What is one query would you use to obtain this information?
SELECT * FROM actor WHERE first_name LIKE 'Joe%';

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT * FROM actor WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. 
-- This time, order the rows by last name and first name, in that order:

SELECT last_name, first_name  
FROM actor
WHERE last_name LIKE'%LI%'
ORDER BY last_name, first_name ASC;

-- 2d. Using `IN`, display the `country_id` and `country` columns 
-- of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');
 
-- 3a. You want to keep a description of each actor. You don't think you 
-- will be performing queries on a description, so create a column in the 
-- table `actor` named `description` and use the data type `BLOB` 
-- (Make sure to research the type `BLOB`, as the difference 
-- between it and `VARCHAR` are significant).

ALTER TABLE actor
ADD COLUMN description BLOB(300) AFTER last_update;

-- 3b. Very quickly you realize that entering descriptions for each actor 
-- is too much effort. Delete the `description` column.

ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(*)
FROM actor
GROUP BY last_name ASC;
    
-- 4b. List last names of actors and the number of actors 
-- who have that last name, but only for names that are shared by at least two actors

SELECT 
    last_name, 
    COUNT(last_name)
FROM
    actor
GROUP BY last_name
HAVING COUNT(last_name) > 1
ORDER BY COUNT(last_name) DESC;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the
-- `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
 
 -- ** CHECK THE TABLE
SELECT actor_id, first_name, last_name FROM actor WHERE  last_name='WILLIAMS';
 -- ** MAKE THE CHANGE
UPDATE actor
SET first_name='HARPO'
WHERE first_name= 'Groucho' AND last_name='WILLIAMS';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
-- It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, if the first name of the actor is currently `HARPO`,
-- change it to `GROUCHO`.
 
 -- ** CHECK THE TABLE AGAIN
SELECT actor_id, first_name, last_name FROM actor WHERE  last_name='WILLIAMS';
 -- ** MAKE THE CHANGE
UPDATE actor
SET first_name='GROUCHO'
WHERE first_name= 'HARPO' AND last_name='WILLIAMS';
 -- ** CHECK THE TABLE AGAIN
SELECT actor_id, first_name, last_name FROM actor WHERE  last_name='WILLIAMS';

-- 5a. You cannot locate the schema of the `address` table. Which query would you 
-- use to re-create it?
-- Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>

DESCRIBE sakila.address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, 
-- of each staff member. Use the tables `staff` and `address`:

SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON staff.staff_id=address.address_id;

-- select* from staff;
-- select* from payment;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in 
-- August of 2005. Use tables `staff` and `payment`.

SELECT staff.first_name, staff.last_name, sum(payment.amount)
FROM staff
INNER JOIN payment ON staff.staff_id=payment.staff_id
WHERE payment.payment_date LIKE '2005-08-%';

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables `film_actor` and `film`. Use inner join.
-- select * from film;
-- select * from film_actor;

SELECT film.title, COUNT(film_actor.actor_id)
FROM film_actor
INNER JOIN film ON film_actor.film_id = film.film_id
GROUP BY film.title ASC;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the 
-- inventory system?

SELECT film.title, COUNT(inventory.film_id)
FROM inventory
INNER JOIN film ON film.film_id = inventory.film_id
WHERE film.title = "Hunchback Impossible";

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, 
-- list the total paid by each customer. 
-- List the customers alphabetically by last 
-- name:![Total amount paid](Images/total_payment.png)
-- SELECT * FROM payment;
-- SELECT * FROM customer;

SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(payment.amount)
FROM customer
INNER JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY payment.customer_id
ORDER BY SUM(payment.amount) DESC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
-- As an unintended consequence, films starting with the letters `K` and `Q` have 
-- also soared in popularity. Use subqueries to display the titles of movies 
-- starting with the letters `K` and `Q` whose language is English.

SELECT film.title  
FROM film
WHERE film.title LIKE 'K%' OR film.title LIKE 'Q%' AND film.language_id IN
(
    SELECT language.language_id
    FROM language 
    WHERE language.name='English'
);

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT actor.first_name, actor.last_name
FROM actor
WHERE actor_id IN
	(   SELECT film_actor.actor_id 
		FROM film_actor 
        WHERE film_actor.film_id IN
        (	SELECT film.film_id
			FROM film 
            WHERE film.title='Alone Trip'
        )
	)
ORDER BY last_name ASC;

-- 7c. You want to run an email marketing campaign in Canada, for which 
-- you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
select * from film_category;

SELECT country.country, customer.first_name, customer.last_name, customer.email 
FROM country 
JOIN customer
ON customer.customer_id = country.country_id
WHERE country.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to 
-- target all family movies for a promotion. Identify all movies categorized 
-- as family films.

SELECT film.title, film.film_id, film_category.category_id, category.category_id
FROM film 
INNER JOIN film_category ON film.film_id = film_category.film_id
LEFT JOIN category ON film_category.category_id=category.category_id
WHERE category.name = 'Family'
ORDER BY film.title;
	
-- 7e. Display the most frequently rented movies in descending order.

-- select *  from rental;
-- I havnt used aliasing yet cos I need to carefully follow the joins

SELECT film.title, inventory.inventory_id, COUNT(rental.inventory_id)
FROM film
INNER JOIN inventory ON inventory.film_id = film.film_id
JOIN rental ON rental.inventory_id=inventory.inventory_id
GROUP BY film.title
ORDER BY COUNT(rental.inventory_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT staff.store_id, sum(payment.amount)
FROM staff
LEFT JOIN payment ON staff.staff_id=payment.staff_id
GROUP BY staff.store_id;
ORDER BY SUM(payment.amount) DESC;


-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT store.store_id, city.city, country.country
FROM store 
RIGHT JOIN customer 
ON store.store_id = customer.store_id
INNER JOIN staff
ON store.store_id = staff.store_id
LEFT JOIN address
ON customer.address_id = address.address_id
LEFT JOIN city 
ON address.city_id = city.city_id
JOIN country
ON city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category,
--   inventory, payment, and rental.)



-- 8a. In your new role as an executive, you would like to have an easy way 
-- of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.



-- 8b. How would you display the view that you created in 8a?



-- 8c. You find that you no longer need the view `top_five_genres`. 
-- Write a query to delete it.

