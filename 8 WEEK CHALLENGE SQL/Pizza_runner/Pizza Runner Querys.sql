use pizza_runner;
# A. Pizza Metrics
select * from runner_orders;
select * from customer_orders;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;
select * from runners;

-- 1.How mazy pizzas were ordered?

select count(*) as total_pizzas_ordered
from customer_orders;

-- 2.How many unique customer orders were made?

select count(distinct(customer_id))
from customer_orders;


-- 3.How many successful orders were delivered by each runner?

select runner_id, count(c.order_id) as delivered_orders
from customer_orders as c
	inner join runner_orders as ro
    on c.order_id = ro.order_id
where cancellation is null
group by runner_id;

-- 4.How many of each type of pizza was delivered?

select pizza_name, count(pizza_name) as pizza_type_delivery
from customer_orders as c
	left join pizza_names as p
    on c.pizza_id = p.pizza_id
    left join runner_orders as r
    on c.order_id = r.order_id
where cancellation is null
group by pizza_name;


-- 5.How many Vegetarian and Meatlovers were ordered by each customer?

select customer_id, pizza_name,count(pizza_name) as pizzas_por_cliente
from customer_orders as c
	left join pizza_names as p
    on c.pizza_id  = p.pizza_id
group by customer_id, pizza_name
order by customer_id;



-- 6.What was the maximum number of pizzas delivered in a single order?

select r.order_id, count(p.pizza_id) as number_of_pizza_per_order
from customer_orders as c
	left join pizza_names as p
    on c.pizza_id = p.pizza_id
    left join runner_orders as r
    on c.order_id = r.order_id
where cancellation is null
group by r.order_id
order by number_of_pizza_per_order desc
limit 1;


-- 7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

select customer_id, count(*) as changes
from customer_orders
where exclusions != '' or extras != ''
group by customer_id;

use pizza_runner;

-- 8.How many pizzas were delivered that had both exclusions and extras?

select count(co.order_id)
from customer_orders as co
inner join runner_orders as ro
	on ro.order_id = co.order_id
where exclusions !='' and extras !='';
    


-- 9.What was the total volume of pizzas ordered for each hour of the day?
select hour_order,count(order_id) as number_of_orders
from 
		(select order_id,customer_id,hour(order_time) as hour_order
		from customer_orders) as hour_table
group by hour_order;


-- 10.What was the volume of orders for each day of the week?
select week_order,count(order_id) as number_of_orders
from 
		(select *,dayofweek(order_time) as week_order
		from customer_orders) as week_table
group by week_order;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# B. Runner and Customer Experience

-- 1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select count(runner_id),weekofyear(registration_date) as week_year
from runners
group by week_year
order by week_year;

-- 2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

select runner_id, avg(TIMESTAMPDIFF(MINUTE, order_time, pickup_time)) as avg_time_pickup
from runner_orders as ro
inner join customer_orders as co
	on ro.order_id = co.order_id
where duration is not null
group by runner_id
order by avg_time_pickup asc;

-- 3.Is there any relationship between the number of pizzas and how long the order takes to prepare?
#pickuptime ordertime numberofpizzas
with cte as(
	SELECT co.order_id, 
	count(pizza_id) as number_of_pizzas,
	max(TIMESTAMPDIFF(MINUTE,order_time,pickup_time)) as prep_time
	from runner_orders as ro
	inner join customer_orders as co
		on ro.order_id = co.order_id
	where pickup_time is not null
	group by order_id)
SELECT
number_of_pizzas,
avg(prep_time) as avg_prep_time
from CTE
group by number_of_pizzas;


-- 4.What was the average distance travelled for each customer?
select customer_id, avg(distance) as distnace_x_runner
from runner_orders as ro
inner join customer_orders as co
	on ro.order_id = co.order_id
where cancellation is null
group by customer_id;


-- 5.What was the difference between the longest and shortest delivery times for all orders?


select max(duration) - min(duration) as time_diff_delivery
from runner_orders
where duration is not null;


-- 6.What was the average speed for each runner for each delivery and do you notice any trend for these values?

select runner_id, order_id, avg(round((distance /duration),2)) as speed
from runner_orders
where duration is not null
group by runner_id, order_id
order by speed;


-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# C. Ingredient Optimisation

-- 1.What are the standard ingredients for each pizza?
use pizza_runner;

-- 2.What was the most commonly added extra?

-- 3.What was the most common exclusion?

-- 4.Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

-- 5.Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?


-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# D. Pricing and Ratings

-- 1.If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

-- 2.What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra

-- 3.The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset 
-- generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

-- 4.Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
-- customer_id
-- order_id
-- runner_id
-- rating
-- order_time
-- pickup_time
-- Time between order and pickup
-- Delivery duration
-- Average speed
-- Total number of pizzas
-- 5.If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled 
-- -how much money does Pizza Runner have left over after these deliveries?


















