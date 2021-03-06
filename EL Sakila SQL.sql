-- Display the first and last names of all actors from the table `actor`
select first_name, last_name
from sakila.actor;

-- Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT(upper(first_name), " ",upper(last_name)) as 'Actor Name'
from sakila.actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name 
from sakila.actor a
where a. first_name = 'Joe';
    
-- 2b. Find all actors whose last name contain the letters `GEN`:
select first_name, last_name 
from sakila.actor a
where a.last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select last_name, first_name
from sakila.actor a
where a.last_name like '%LI%'
order by a.last_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from sakila.country c
where c.country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP COLUMN description; 

-- 4a. List the last names of actors, as well as how many actors have that last name.
select distinct last_name, count(last_name) as'Count'
from actor
group by last_name;


-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
Create view actor_count as
select last_name, count(last_name) as 'count'
group by last_name 
order by count(last_name) desc;
select * from actor_count
where count >=2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE sakila.actor a
set a.first_name = 'Harpo'
where a.first_name = 'GROUCHO' and
a.last_name = 'Williams';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE sakila.actor a
set a.first_name = 'GROUCHO'
where a.first_name = 'HARPO';

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
select staff.first_name, staff.last_name, address.address, address.district, address.postal_code
From sakila.staff
INNER JOIN sakila.address on 
staff.address_id = address.address_id; 

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
select staff.staff_id, staff.first_name, staff.last_name, sum(payment.amount)
from sakila.staff
inner join sakila.payment on
payment.staff_id = staff.staff_id
where payment.payment_date like '2005-08-%'
group by payment.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select film.title as 'Title', count(film_actor.actor_id) as 'Actor Count'
from sakila.film
inner join sakila.film_actor on
film.film_id = film_actor.film_id
group by film.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?;
select film.title as 'Movie Title', film.film_id as 'SKU', count(inventory.inventory_id) as 'In Stock'
from sakila.film
inner join sakila.inventory on
film.film_id = inventory.film_id
and film.title = 'Hunchback Impossible';

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
select customer.last_name as 'Customer last', customer.first_name as 'Customer First',  sum(payment.amount) as 'Total Rented'
from sakila.customer
inner join sakila.payment on
customer.customer_id = payment.customer_id
group by payment.customer_id
order by customer.Last_Name asc;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select title from film
where language_id in
(select language_id from language
where name = 'English')
and title like 'K%' or title like 'Q%';

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
   SELECT film_id
   FROM film
   WHERE title = 'Alone Trip'
  )
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select first_name, last_name, email
from Sakila.customer
Inner join sakila.customer_list
where customer_list.id = customer.customer_id
and customer_list.country = 'CANADA';


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT film.title, category.name
from sakila.film
inner join sakila.film_category on 
film.film_id = film_category.film_id
inner join sakila.category on
film_category.category_id = category.category_id
and category.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
select film.title, count(rental.rental_id) as 'Rental Count'
from sakila.film
inner join sakila.inventory on
film.film_id = inventory.film_id
inner join sakila.rental on
inventory.inventory_id = rental.inventory_id
group by (title)
order by count(rental.rental_id) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select * from sales_by_store;

-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, a.address, c.city, y.country
from store s
inner join address a on
s.address_id = a.address_id
inner join city c on
a.city_id = c.city_id
inner join country y on
c.country_id = y.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select * from sales_by_film_category
order by total_sales desc
limit 5;
                                           
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_5_Genres_by_Gross_Revenue AS
select * from sales_by_film_category
order by total_sales desc
limit 5;
                                           
-- 8b. How would you display the view that you created in 8a?
select * from top_5_genres_by_gross_revenue;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
Drop view top_5_genres_by_gross_revenue;
