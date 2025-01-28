# https://8weeksqlchallenge.com/case-study-3/

use foodie_fi;

select *
from plans;

select *
from subscriptions as s
join plans as p
on s.plan_id = p.plan_id
where customer_id = 6;

# How many customers has Foodie-Fi ever had?

select count(DISTINCT customer_id) as num_customers
from subscriptions;

# What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

# Calculate the number of customers per month (we don't consider year)
select month(start_date) as month_trial, count(*)
from subscriptions
where plan_id = 0
group by month_trial
order by month_trial asc;

# Distribution is similar in all months, highest number of customeres was on March, lower number of customer were in february

# Q: What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name?

select count(plan_name),plan_name, year(start_date) as year_plans
from subscriptions as s
join plans as p
on s.plan_id = p.plan_id
where  year(start_date) > 2020
group by year_plans, plan_name
order by year_plans;

# We have a high number of churns and less number of basic plans

# Q: What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
# (total customers/ churn customers) * 100

select count(distinct customer_id)
from subscriptions;



