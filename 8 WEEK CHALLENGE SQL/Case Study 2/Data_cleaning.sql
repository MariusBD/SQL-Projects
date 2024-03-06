-- Data cleaning
use pizza_runner;

select * from customer_orders;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;
select * from runner_orders;
select * from runners;

-- Tabla customer_orders


-- Convertir valores nulos y valores de texto 'nulo' en la columna extras y en la columna exclusions en espacios en blanco '' 
UPDATE customer_orders
SET exclusions = ''
WHERE exclusions IS NULL OR exclusions LIKE 'null';


UPDATE customer_orders
SET extras = ''
WHERE extras IS NULL OR extras LIKE 'null';

#Comprobar cambios
select * from customer_orders;

-- Tabla runner_orders
-- Convertir valores de texto 'nulo' en pickup_time, duration, distance y cancellation  en valores nulos.

UPDATE runner_orders
SET pickup_time = NULL
WHERE pickup_time LIKE 'null';

UPDATE runner_orders
SET distance = NULL
WHERE distance LIKE 'null';

UPDATE runner_orders
SET duration = NULL
WHERE duration LIKE 'null';

UPDATE runner_orders
SET cancellation = NULL
WHERE cancellation LIKE 'null';

-- Convertir valores vacios en la columna cancellation  en valores nulos.

UPDATE runner_orders
SET cancellation = NULL
WHERE cancellation IN ('');

#Comprobar cambios

select * from runner_orders;

-- Extraer los 'km' de la columna  distance y convertir a tipo de datos FLOAT

UPDATE runner_orders
SET DISTANCE = TRIM('km' FROM distance)
WHERE DISTANCE LIKE '%km';

-- Cambiar tipo de datos a float

#1. Añadir una nueva columna a float
ALTER TABLE runner_orders
ADD COLUMN distance_float FLOAT;

#2. Actualizar la nueva columna con los valores de la antigua columna

UPDATE runner_orders
SET distance_float = CAST(distance AS FLOAT);

#3. Eliminar columna distance
ALTER TABLE runner_orders
DROP COLUMN distance;

#4. Renombrar la nueva variable float 

ALTER TABLE runner_orders
CHANGE COLUMN distance_float distance FLOAT;

#Comprobar cambios
select * from runner_orders;


-- Convertir la columna pickup_time  a tipo de datos timestamp without time zone
-- ALTER TABLE runner_orders
-- ADD COLUMN pick_up_notz DATE;


-- UPDATE runner_orders
-- SET pick_up_notz = DATE(pickup_time);

-- ALTER TABLE runner_orders
-- DROP COLUMN pickup_time;

-- ALTER TABLE runner_orders
-- CHANGE COLUMN pick_up_notz pickup_time DATE;

#Comprobamos
select * from runner_orders;

-- Extraer los 'minutos' de la columna Duration y convertir a tipo de datos INT

UPDATE runner_orders
SET duration = TRIM('mins' FROM duration)
WHERE duration LIKE '%mins';

UPDATE runner_orders
SET duration = TRIM('minute' FROM duration)
WHERE duration LIKE '%minute';

UPDATE runner_orders
SET duration = TRIM('minutes' FROM duration)
WHERE duration LIKE '%minutes';


#1. Añadir una nueva columna a float
ALTER TABLE runner_orders
ADD COLUMN duration_int INTEGER;


#2. Actualizar la nueva columna con los valores de la antigua columna

UPDATE runner_orders
SET duration_int = CAST(duration AS UNSIGNED);

#3. Eliminar columna distance
ALTER TABLE runner_orders
DROP COLUMN duration;

#4. Renombrar la nueva variable float 

ALTER TABLE runner_orders
CHANGE COLUMN duration_int duration INTEGER;

#Comprobamos las tablas
select * from runner_orders;
select * from customer_orders;


