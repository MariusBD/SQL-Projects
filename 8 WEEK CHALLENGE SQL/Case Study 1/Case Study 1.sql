# Crear base de datos
CREATE DATABASE IF NOT EXISTS casestudy1;

use casestudy1;
-- Crear la tabla sales
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

-- Insertar datos en la tabla sales
INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);

-- Crear la tabla menu
CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

-- Insertar datos en la tabla menu
INSERT INTO menu
  (product_id, product_name, price)
VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);

-- Crear la tabla members
CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

-- Insertar datos en la tabla members
INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  

  
  
  #-----------------------Consultas --------------------------

use casestudy1;

select * from menu;
select * from members;
select * from sales;

-- ¿Cuál es la cantidad total que gastó cada cliente en el restaurante?

select customer_id,sum(price)
from sales as s
left join menu as m
on m.product_id = s.product_id
group by s.customer_id;

-- ¿Cuántos días ha visitado cada cliente el restaurante?

select count(distinct day(order_date)),customer_id
from sales
group by customer_id;

-- Cuál fue el primer artículo del menú comprado por cada cliente?
select customer_id,product_name
from sales as s
left join menu as m
on s.product_id = m.product_id
where order_date = (select min(order_date) from sales)
group by s.customer_id,product_name
order by customer_id;


-- ¿Cuál es el artículo más comprado en el menú y cuántas veces lo compraron todos los clientes?


select product_name,count(product_name) as frec_compra_prod
from sales as s
left join menu as m
on s.product_id = m.product_id
group by s.product_id,product_name;

-- ¿Qué artículo fue el más popular para cada cliente?


select customer_id,product_name
from (
	select *, row_number() over(partition by customer_id) as ranking
	from  (
			select customer_id, product_name,count(product_name) as freq_prod_cliente
			from sales as s
			left join menu as m
			on s.product_id = m.product_id
			group by customer_id,product_name
			order by customer_id,freq_prod_cliente desc) as freq_productos) as ranking
where ranking = 1;

-- ¿Qué artículo compró primero el cliente después de convertirse en miembro?

select temp.customer_id,temp.order_date,temp.join_date,product_name
from
	(select s.customer_id,
			order_date,
			product_id,
			join_date, 
			dense_rank() over(partition by s.customer_id order by order_date) as ranking_compra
	from sales as s
	left join members as m
	on s.customer_id = m.customer_id
	where order_date >= join_date) as temp
left join menu as m
on m.product_id = temp.product_id
where ranking_compra = 1;


-- 	¿Qué artículo se compró justo antes de que el cliente se convirtiera en miembro?

select temp.customer_id,temp.order_date,temp.join_date,product_name
from
	(select s.customer_id,
			order_date,
			product_id,
			join_date, 
			dense_rank() over(partition by s.customer_id order by order_date) as ranking_compra
	from sales as s
	left join members as m
	on s.customer_id = m.customer_id
	where order_date < join_date) as temp
left join menu as m
on m.product_id = temp.product_id
where ranking_compra = 1;

-- ¿Cuál es el total de artículos y la cantidad gastada por cada miembro antes de convertirse en miembro?
with temp as (
	select s.customer_id,s.product_id,order_date,join_date,product_name,price
	from sales as s
	left join menu as m
	on s.product_id = s.product_id
	left join members as mem
	on mem.customer_id = s.customer_id)
select customer_id,
	   count(*) as total_commprado,
       sum(price) as total_gastado
from temp
where order_date < join_date
group by customer_id
;

-- Si cada $ 1 gastado equivale a 10 puntos y el sushi tiene un multiplicador de puntos 2x, ¿cuántos puntos tendría cada cliente?
-- Suposición: Solo los clientes que son miembros reciben puntos al comprar artículos, los puntos los reciben en las ordenes iguales o posteriores a la fecha
-- en la que se convierten en miembros. 

select tabla_puntuaciones.customer_id,sum(puntuaciones) as puntos_cliente
from
	(select s.customer_id,order_date,s.product_id,price,
		case
			when product_name = 'sushi' then m.price * 20 
			when product_name != 'sushi' then m.price * 10
			else -99999999999999999
		end as puntuaciones
	from sales as s
	left join menu as m
	on s.product_id = m.product_id
	left join members as me
	on me.customer_id = s.customer_id
	where join_date <= order_date) as tabla_puntuaciones
group by s.customer_id;

--  En la primera semana después de que un cliente se une al programa (incluida la fecha de ingreso), gana el doble de puntos en todos los artículos, no solo en sushi.
-- ¿Cuántos puntos tienen los clientes A y B a fines de enero?
-- Suposición: Solo los clientes que son miembros reciben puntos al comprar artículos, los puntos los reciben en las ordenes iguales o posteriores a la fecha
-- en la que se convierten en miembros. Solo las ordenes de la primer semana en la que se convierten en miembros suman 20 puntos para todos los articulos. 

select customer_id,sum(precio_cliente_miembro) as total_puntos_cliente_enero
from (
	SELECT *,
		case
		when dias_membresia between 0 and 7 then price * 20 #primera semana todos los articulos
		when product_name = 'sushi' and dias_membresia > 7 then price * 10 #membreisa superior a la semana y el producto es sushi sigue ganando 20 puntos
		when product_name != 'sushi' and dias_membresia > 7 then price * 10 #dias membresia superior a la semana ganan 10 puntos si no es sushi
		end as precio_cliente_miembro
	from
		(select s.customer_id,order_date,join_date,m.product_name,price,DATEDIFF(order_date,join_date) as dias_membresia
		from sales as s
			left join menu as m
			on s.product_id = m.product_id
			left join members as me
			on me.customer_id = s.customer_id
		where order_date >= join_date) as temp
	where order_date < '2021-01-31') as temp
group by customer_id;











