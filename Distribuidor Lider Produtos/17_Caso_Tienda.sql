# SPRINT SEMANA 2 - TAREA 1
---------------------------------------------

-- Importa la bbdd a partir de dump: caso.sql 

-- Activala como la bbdd por defecto
use caso;

-- Revisa el contenido de las 4 tablas

Select * from canales;
Select * from productos;
Select * from tiendas;
Select * from ventas;

-- ¿Cuantos registos tiene la tabla ventas?

select count(*) from ventas; 
#La tabla tiene 148257 registros


-- Revisa el tipo de los datos, ¿ves algo raro?

# La variable fecha esta texto, hay que pasarla a tipo fecha.

-- ALTER TABLE ventas MODIFY fecha DATE;
-- UPDATE ventas SET fecha = str_to_date(fecha,'%m%d%Y')


-- ¿Está al nivel que necesitamos? tienda - producto - canal – fecha (no tiene que haber duplicados)


#Truco para ver si tenemos la tabla a ese nivel: group by por tienda- prod-canal- fecha y aparece que cada registro está una única vez, la tabla esta a ese nivel.

select count(*) as conteo
from ventas
group by id_tienda, id_prod, id_canal, fecha
having conteo > 1;


-- Si hay duplicados muéstralos para identificar algún caso concreto

select id_tienda,id_prod,id_canal, fecha, count(*) as conteo
from ventas
group by id_tienda, id_prod, id_canal, fecha
having conteo > 1
order by id_tienda, id_prod, id_canal, fecha;


-- Revisa un par de ellos
select *
from ventas
where id_tienda = 1115
	and id_prod = 127110
    and id_canal = 5
    and fecha = '22/12/2016';
    #Mirando la tabla estamos viendo que lo que nos esta provocando la duplicidad de los registros es la cantidad
    #No sabemos por que esta pasando esto, es decir que la cantidad sea diferente, podría ser que hubiera otro campo como la hora, lo cual nos diría que 
    #la misma fecha el mismo prod en la misma tienda se hizo en en 2 horas diferentes 12:00 y 17:00 por ejemplo y por eso viene recogido como 2 registros diferentes
    #o podria ser que fuera un producto diferente, pero no tenemos el id del producto.

#Revisamos otro caso
select *
from ventas
where id_tienda = 1133
	and id_prod = 122140
    and id_canal = 5
    and fecha = '15/01/2018';

-- Crea una nueva tabla de ventas_agr agregada a ese nivel, y además:
	-- Cambia la fecha a tipo date 
    -- (pista: usa la función de texto str_to_date con formato '%d/%m/%Y'. Ver: https://www.w3schools.com/sql/func_mysql_str_to_date.asp)
	-- Crea un campo facturación como la multiplicación de la cantidad por el precio_oferta

create table ventas_agr as
select str_to_date(fecha, '%d/%m/%Y') as fecha,
		id_prod, id_tienda, id_canal,
        sum(cantidad) as cantidad,
        avg(precio_oficial) as precio_oficial,
        avg(precio_oferta) as precio_oferta,
        round(sum(cantidad) * avg(precio_oferta),2) as facturacion
from ventas
group by 1,2,3,4; #por posición para evitar ambigous error


-- Revisa la nueva tabla creada
select * from ventas_agr;

-- Revisa cuantos registros tiene la nueva tabla
select count(*) from ventas_agr;


# SPRINT SEMANA 2 - TAREA 2
---------------------------------------------

-- Crea un diagrama ER para ver cómo está relacionada la nueva tabla

#La tabla venta_agr no esta relacionada con el resto de las tablas de nuestra bbdd

-- Haz un join con la tabla productos para comprobar que aunque no esté relacionada se pueden hacer igualmente las consultas

select *
from productos as p inner join ventas_agr as v
	on p.id_prod = v.id_prod;

-- Pero vamos a hacerlo bien. Modifica la tabla ventas_agr para:
	--  Incluir un nuevo campo clave incremental llamado id_venta
	--  Que id_prod sea un FK con su tabla y campo correspondiente
	--  Que id_tienda sea un FK con su tabla y campo correspondiente
	--  Que id_canal sea un FK con su tabla y campo correspondiente

ALTER TABLE ventas_agr
	ADD id_venta int auto_increment primary key,
    ADD foreign key(id_prod) references productos(id_prod) on delete cascade,
    ADD foreign key(id_tienda) references tiendas(id_tienda) on delete cascade,
    ADD foreign key(id_canal) references canales(id_canal) on delete cascade;
    
-- Vuelve a crear el diagrama ER para ver cómo se relaciona ahora la nueva tabla

-- Crea una vista sobre la tabla ventas_agr que incluya el pedido
	-- (Consideramos que será el mismo pedido cuando se haya hecho en la misma fecha, por la misma tienda y con el mismo canal, solo cambian los productos)
create view v_ventas_agr_pedido as
with maestro_pedidos as(
	select fecha,id_tienda,id_canal, row_number() over() as id_pedido
	from ventas_agr
	group by fecha, id_tienda, id_canal)

select v.id_venta, id_pedido, v.fecha, id_prod,v.id_tienda,v.id_canal,cantidad,precio_oficial,v.precio_oferta,facturacion
from ventas_agr as v
	left join maestro_pedidos as m
    on (v.fecha = m.fecha) and (v.id_tienda = m.id_tienda) and (v.id_canal = m.id_canal);
     
select fecha,id_tienda,id_canal,row_number() over() as id_ventas
from ventas_agr
group by fecha, id_tienda,id_canal;
     
     
# SPRINT SEMANA 3 - TAREA 1
---------------------------------------------

-- ¿Cuántos pedidos tenemos en nuestro histórico?
#la tabla esta a nivel de pedido producto, no a nivel de pedidos
#si hacemos count all, tendriamos el numero total de ventas, no de pedidos

select max(id_pedido)
from v_ventas_agr_pedido; #tenemos 22721 pedidos

select count(distinct id_pedido)
from v_ventas_agr_pedido;

-- ¿Desde qué día a qué dia tenemos datos?
select min(fecha),max(fecha)
from v_ventas_agr_pedido; 
#desde 2015-01-12 hasta 2018-07-20

-- ¿Cuántos productos distintos tenemos en nuestro catálogo?

select count(distinct id_prod)
from productos;


-- ¿A cuántas tiendas distintas distribuimos?
select count(distinct id_tienda)
from tiendas; 
#A 562 diferentes


-- ¿A través de qué canales nos pueden hacer pedidos?
select distinct canal
from canales;


# SPRINT SEMANA 3 - TAREA 2
---------------------------------------------

-- Cuales son los 3 canales en los que más facturamos

select c.canal,round(sum(facturacion),4) as facturacion
from ventas_agr as v
	left join
    canales as c
    on v.id_canal = c.id_canal
group by v.id_canal
order by facturacion desc
limit 3;


-- Cual ha sido la evolución mensual de la facturación por canal en los últimos 12 meses completos


select canal, month(fecha) as mes, sum(facturacion)
from ventas_agr as v
	left join
    canales as c
    on v.id_canal = c.id_canal
where fecha between '2017-07-01' and '2018-06-30' 
group by v.id_canal,mes
order by v.id_canal, mes;


-- Localiza el nombre de nuestros 50 mejores clientes (tiendas con mayor facturación)

select nombre_tienda, sum(facturacion) as facturacion_tienda
from ventas_agr as v
	left join
    tiendas as t
    on v.id_tienda = t.id_tienda
group by v.id_tienda
order by facturacion_tienda desc
limit 50;

-- Analiza la evolución de la facturación de cada país por trimestre desde 2017	

select pais, year(fecha) as año, quarter(fecha) as trimestre,sum(facturacion) as facutracion_trimestre
from ventas_agr as v
	left join
    tiendas as t
    on v.id_tienda = t.id_tienda
where fecha between '2017-01-01' and '2018-06-30' #el ultimo dato del trimestre completo es junio, julio pertenece al siguiente trimestre
group by pais, año,trimestre
order by pais, año,trimestre;


# SPRINT SEMANA 4 - TAREA 1
---------------------------------------------

-- Encuentra los 20 productos en los que sacamos mayor margen ((precio - coste) / coste * 100) en cada línea
USE caso;
#1 Generar la variable margen y seleccionar todo
#2 Hacemos una CTE
#3 Hacemos el ranking por linea
#4 Para sacer los 20 primeros tenemos que crear otra subconsulta de donde extraemos los 20 productos

with tabla_margen as(
	select *, round(((precio - coste) / coste) *100,2) as margen
	from productos)
select *
from (select id_prod,linea,producto,margen, row_number() over(partition by linea order by margen desc) as ranking
	from tabla_margen) as tabla_ranking
where ranking <=20;



-- Encuentra aquellos productos (su identificador) en los que estemos haciendo descuentos (en porcentaje) superiores al valor de decuento que deja por debajo al 90% de los descuentos

#1 Hay que calcular la variable descuento.
#2 Ilustraivamente es como si pusieramos esta variable en el eje de las X de un grafico y calcularamos cual es el valor del descuento que deja por debajo
#al 90% del total dfe los datos, esto en estadística se conoce como el percentil, en este caso el percentil 90.
# Fitrar aquelos productos cuyo descuento ocupe la posicion 90 o que deje por debajo al 90% de los descuentos.

#Como definimos el descuento?
# Precio oficial - precio en oferta.
#A que nivel estamos trabajando?
#Vamos a trabajar a nivel de producto, pero la tabla no esta ese nivel.
#Al no tener la tabla a nivel de producto no podemos identiificar al 90% de productos, si lo hicieramos tal cual esta la tabla identificariamos los registros que estan por debajo del 90%
#El 90% de los registros no implica el 90% de los productos que estan por debajo ya que un producto se ha vendido varias veces.

#1 Hemos puesto la tabla a nivel al que necesitamos
select id_prod,avg(precio_oficial) as precio_oficial_medio ,avg(precio_oferta) as precio_oferta_medio
from ventas_agr
group by id_prod;

#2 Calcular la metrica del descuento
with tabla_descuentos as (
	select *, round(((precio_oficial_medio - precio_oferta_medio) / precio_oficial_medio),2) as descuento
	from    (select id_prod,avg(precio_oficial) as precio_oficial_medio ,avg(precio_oferta) as precio_oferta_medio
			from ventas_agr
			group by id_prod) as nivel_producto)
select *
from 	(select id_prod,descuento, cume_dist() over(order by descuento) as distribucion_acumulada
		from tabla_descuentos) as acumulados
where distribucion_acumulada >= 0.9;

#La respuesta es: Hay 28 productos en los cuales nos estamos pasando en el descuento, tenemos el id de cada producto y tenemos el descuento medio de cada uno.
#Hay que bajarles el descuento a estos productos.


# SPRINT SEMANA 4 - TAREA 2
---------------------------------------------

-- ¿Cuántos productos diferentes estamos vendiendo?

select count(distinct producto)
from productos;

-- ¿Con qué productos necesitaríamos quedarnos para mantener el 90% de la facturación actual?
#Al mantener solo los productos que mantienen el 90% de facturación, tendremos un ahorro de costes, ese ahorra de costes será superior al 10% que perdemos si no mantenemos esos productos, por lo tanto el balance es positivo.


use caso;

#Poner la tabla a nivel de produdcto
select id_prod,sum(facturacion) as facturacion_prod
from ventas_agr
group by id_prod
order by facturacion_prod desc;

#Calcular facturación actumulada
with tabla_fact_acum_prod as (
	select *, round(fact_acumulada / facturacion_total,2) as fact_prod_acum_porc
	from  (select id_prod, 
			  facturacion_prod,sum(facturacion_prod) over(order by facturacion_prod desc) as fact_acumulada,
			  sum(facturacion_prod) over() as facturacion_total
			from  (select id_prod, sum(facturacion) as facturacion_prod
						from ventas_agr
						group by id_prod
						order by facturacion_prod desc) as tabla_fact_prod) as tabla_acum_y_total)
select id_prod
from tabla_fact_acum_prod
where fact_prod_acum_porc <=0.9;



-- Y por tanto ¿qué productos concretos podríamos eliminar y seguir manteniendo el 90% de la facturación?
#Construymos la CTE DE LOS PRODUCTOS A MANTENER
with prod_a_mantener as (
	with tabla_fact_acum_prod as (
		select *, round(fact_acumulada / facturacion_total,2) as fact_prod_acum_porc
		from  (select id_prod, 
				  facturacion_prod,sum(facturacion_prod) over(order by facturacion_prod desc) as fact_acumulada,
				  sum(facturacion_prod) over() as facturacion_total
				from  (select id_prod, sum(facturacion) as facturacion_prod
							from ventas_agr
							group by id_prod
							order by facturacion_prod desc) as tabla_fact_prod) as tabla_acum_y_total)
	select id_prod
	from tabla_fact_acum_prod
	where fact_prod_acum_porc <=0.9)

#Primero creamos el maestro de productos distintos
#Los campos que son nulos, son los porductos que no existen en la tabla de mantener
#Si no existen en la tabla de mantener es porque es un producto a eliminar
select distinct(v.id_prod)
from ventas_agr as v
	left join prod_a_mantener as m
    on v.id_prod = m.id_prod
where m.id_prod IS NULL; #Por lo tanto hay 130 productos que se pueden eliminar del total que son 244
#Eliminando estos 130 productos de mi total, seguiria manteniendo el 90% de la facturacion total 



# SPRINT SEMANA 4 - TAREA 3
---------------------------------------------

-- ¿Qué líneas de producto diferentes estamos vendiendo?
select distinct *
from productos;


-- ¿Cual es la contribución (en porcentaje) de cada línea al total de facturación?
with facturacion_linea as (
	select *, sum(facturacion_linea) over() as facturacion_total
	from (select linea,sum(facturacion) as facturacion_linea
		from ventas_agr as v
			left join productos as p
			on v.id_prod = p.id_prod
		group by linea) as fact_linea)
        
select linea, facturacion_linea, round(facturacion_linea / facturacion_total,2) as pct_linea
from facturacion_linea
order by pct_linea desc;

-- ¿Podríamos prescindir de alguna línea de productos sin que afecte mucho a la facturación?

# Podriamos prescindir de la linea Outdoor Protection ya que nos esta facturando unicamente el 1% de la facturacion total.

-- Dentro de la línea que más facture ¿hay algún producto concreto que esté en tendencia?
-- Definimos tendencia como el crecimiento de Q2-2018 sobre Q1-2018
-- Personal Accessories

with producto_trimestre as (
	select linea,v.id_prod,quarter(fecha) as trimestre,sum(facturacion) as fact_prod
	from ventas_agr as v
			left join productos as p
			on v.id_prod = p.id_prod
	where linea = 'Personal Accessories' and fecha between '2018-01-01' and '2018-06-30'
	group by id_prod,trimestre
	order by 2,3)
select id_prod,crecimiento
from (select *, 
	fact_prod / lag(fact_prod) over(partition by id_prod order by trimestre) as crecimiento 
from producto_trimestre) as subconsulta_limpieza #despues de haber generado el crecimiento, limpiamos la tabla,lo hacemos con una subconsulta
where crecimiento is not null
order by crecimiento desc;
#Una vez acabada la limpieza podemos ir atrar a la CTE y cambiar id_producto por producto para ver el nombre.
#Productos en tendencia: id 82110 y algunos más.





# SPRINT SEMANA 5 - TAREA 1
---------------------------------------------

-- Segmentación de clientes: 
	-- Crea una matriz de 4 segmentos en base al número de pedidos y la facturación de cada cliente (tienda)
	-- Cada eje dividirá entre los que están por encima y por debajo de la media
	-- Guarda la consulta como una vista para ejecutarla frecuentemente
use caso;

#1 Conteo de pedidos y la facturacion por tienda
select id_tienda, count(id_pedido) as num_pedidos, sum(facturacion) as fact_tienda
from v_ventas_agr_pedido
group by id_tienda;

#2 Utilizar una CTE, para hacer 2 precalculos donde calcularemos la media del nº pedidos y facturacion tienda
create view v_matriz_segmentacion as (
with  pedidos_fact_tienda as (
	select id_tienda, count(id_pedido) as num_pedidos, sum(facturacion) as fact_tienda
	from v_ventas_agr_pedido
	group by id_tienda),
    medias as (
    select avg(num_pedidos) as media_pedidos,
			avg(fact_tienda) as media_facturacion
	from pedidos_fact_tienda
    )
    
#Hay un problema y es que queremos las medias para poder referirnos a ellas, no necesitamos cruzarlas
#Podemos hacer seleccion de varias tablas sin unirlas, para poder acceder a campos que estan en diferentes campos

select *,
	case
    when num_pedidos <= media_pedidos and fact_tienda <= media_facturacion then 'P- F-'
    when num_pedidos <= media_pedidos and fact_tienda > media_facturacion then 'P- F+'
    when num_pedidos > media_pedidos and fact_tienda <= media_facturacion then 'P+ F-'
    when num_pedidos > media_pedidos and fact_tienda > media_facturacion then 'P+ F+'
    else 'ERROR_SEGMENTO'
    END AS segmentacion
from pedidos_fact_tienda,medias);



-- Calcula cuantos clientes tenemos en cada segmento de la matriz

select  segmentacion,count(id_tienda) as num_clientes
from v_matriz_segmentacion
group by segmentacion
order by num_clientes desc;
#Lo normal es que la mayoria de los clientes esten entre P- F- Y F+ P+, es decir entre malos-malos y buenos-buenos


-- Potencial de desarrollo: 
	-- Segmenta las tiendas por su tipo, y calcula el P75 de la facturación
	-- Para cada tienda que esté por debajo del P75 calcula su potencial de desarrollo (diferencia entre la facturación P75 y su facturación)

#1 Preparar la tabla segmentada por tipo.
#2 Calcular el dato ideal que ocupa el P75 en cada uno de los segmnetos, para despues comparar el dato de facturacion de cada tienda contra su dato de facturacion ideal
#3 calcular una variable que sea la diferencia entre el objetivo ideal y facturacion actual, para crear la variable del potencial de desarrollo.
#Aqui hay un problema, que pasa con las tiendas que estan por encima del p75? Si lo hacemoS de esta manera nos metera un dato negativo, por lo tanto no tiene sentido.
#Le meteremos mas complejidad que sea cuando nosotros creemoS esa variable de potencial, le meteremos una logica: si la facturacion actual ya esta por encima de la 
#facutracion ideal entonces que me ponga un potencial de desarrolo 0 ,si la facturacion actual esta por debajo de la facturacion ideal, que me haga esa reste
#del ideal - facturacion actual, y ese dato sera el dato de potencial.


#Poner la tabla a nivel de tienda y agregar la facturacion, despues incorporar el tipo de tienda
select v.id_tienda,tipo,facturacion
from tiendas as t
	inner join
    (select id_tienda,sum(facturacion) as facturacion
	from ventas_agr
	group by id_tienda) as v
    on t.id_tienda = v.id_tienda;

#Mirar la salida : Si la tienda 1149 que es de Golf factura 23M, porque la tienda 1115 que tambien es de golf factura solamenet 1.5M?
#El objetivo es el poder comprar en base a cada uno de los tipos y los distintos niveles de facturacion.

#Metemos en una CTE y calculamos el P75
with nivel_tienda as (select v.id_tienda,tipo,facturacion
from tiendas as t
	inner join
    (select id_tienda,sum(facturacion) as facturacion
	from ventas_agr
	group by id_tienda) as v
    on t.id_tienda = v.id_tienda
    )
    
#tenemos que hacer el percentil por tienda
#muy importante, ordenar por facturacion, porque queremos seleccionar un percentil determinado ya que si los numeros estan desordenados no va funcionar
select *, round(percent_rank() over(partition by tipo order by facturacion) * 100,2) as percentil
from nivel_tienda;
 
 #Miramos la salida de la tabla: Vemos el tipo de la tienda Department Store en el percentil 75 factura 13.5M, la pregunta es porque los otros Department Store
 #no facturan cercano a 13.5M? Ya que vemos algunos que solo factura 90k, 140k, 173k ...esta muy lejos de los 13M. Si hay un department que pueda facturar 13.5M 
 #no te digo que todas facturen 13.5kM pero tampoco puedes tener 140k o 500k, tendriamos que estar mas cerca de los 13.5M

#El siguiente paso es quedarnos con el P75 de cada tipo de tienda.
# Primero filtrar todos aquellos percentiles que sean iguales o mayores a 75

with nivel_tienda as (select v.id_tienda,tipo,facturacion
from tiendas as t
	inner join
    (select id_tienda,sum(facturacion) as facturacion
	from ventas_agr
	group by id_tienda) as v
    on t.id_tienda = v.id_tienda
    )
	select * 
	from (select *,row_number() over(partition by tipo order by percentil) as ranking
		from (select *, round(percent_rank() over(partition by tipo order by facturacion) * 100,2) as percentil
			from nivel_tienda) as con_percentil
		where percentil >= 75) as primer_filtro # ponemos este filtro primero, y luego hay que quedarse con el primer registro de cada tipo
	where ranking = 1; #el segundo filtro es un ranking para solamente quedarnos donde el ranking es 1,desde una subconsulta
				
#La sailida es: La tabla con los objetivos ideales del p75 por cada uno de los tipos de tienda.

#El siguiente paso es añadir la facturacion que viene en el p75 de la tabla p75_ideales

with nivel_tienda as (select v.id_tienda,tipo,facturacion
from tiendas as t
	inner join
    (select id_tienda,sum(facturacion) as facturacion
	from ventas_agr
	group by id_tienda) as v
    on t.id_tienda = v.id_tienda
    ),
	p75_ideales as ( 
    select tipo,facturacion as ideal #para no confundir facturacion ideal con la facturacion de la otra tabla que vamos a cruzar
	from (select *,row_number() over(partition by tipo order by percentil) as ranking
		from (select *, round(percent_rank() over(partition by tipo order by facturacion) * 100,2) as percentil
			from nivel_tienda) as con_percentil
		where percentil >= 75) as primer_filtro 
	where ranking = 1 
	)
#Cruzar las tablas p75_ideales y nivel de tienda a traves de tipo, para añadir el campo ideal
select id_tienda,t.tipo,facturacion,ideal
from nivel_tienda as t
	inner join #porque solo queremos los registros que se comparten entre ambas tablas
    p75_ideales as i
    on t.tipo = i.tipo;
    
#Calcular el potencial, como la diferencia entre el ideal - facturacion, pero hay un problema y es:
#Que pasa con los datos que estan facturando mas que el ideal? Pues el potencial de desarrollo seria de 0 porque ha superado su objetivo ideal.
#Le ponemos condiciones para distinguir esa casuistica

with nivel_tienda as (select v.id_tienda,tipo,facturacion
from tiendas as t
	inner join
    (select id_tienda,sum(facturacion) as facturacion
	from ventas_agr
	group by id_tienda) as v
    on t.id_tienda = v.id_tienda
    ),
	p75_ideales as ( 
    select tipo,facturacion as ideal 
	from (select *,row_number() over(partition by tipo order by percentil) as ranking
		from (select *, round(percent_rank() over(partition by tipo order by facturacion) * 100,2) as percentil
			from nivel_tienda) as con_percentil
		where percentil >= 75) as primer_filtro 
	where ranking = 1 
	)
select id_tienda,t.tipo,facturacion,ideal,
	case
    when (ideal - facturacion) <=0 then 0 #no tiene potencial
    when (ideal - facturacion) >=0 then (ideal-facturacion) 
    else -999999999999999999
    end as potencial
from nivel_tienda as t
	inner join 
    p75_ideales as i
    on t.tipo = i.tipo
order by potencial desc;

#salida: tienda 1133 factura 6M y el ideal es 1.3M el potencial de desarrollo es 0, esta tienda habra que trabajar sobre ella para mantenerla, fidelizarla
#a priori no existe potencial de desarrollo

#Si ordenamos en descendente podriamos ver aquellas tiendas que tienen mayor potencial de desarrollo en base a la metodologia de el calculo del potencial de la cuota de cartera de cada uno de los clientes


-- Reactivación de clientes
	-- Identifica clientes que lleven más de 3 meses sin comprar (versus la última fecha disponible)
use caso;

with ultima_fecha_total as (
		select max(fecha) as ult_fecha_total
		from ventas_agr),
	ultima_fecha_tienda as (
		select id_tienda,max(fecha) as ult_fecha_tienda
		from ventas_agr
		group by id_tienda)
select *
from ( 
	select *, datediff(ult_fecha_total,ult_fecha_tienda) as dias_sin_comprar
	from ultima_fecha_tienda,ultima_fecha_total) as tabla_compras_sin_comprar
where dias_sin_comprar >= 90
;
#SALIDA: HAY 15 TIENDAS QUE LLEVAMOS MAS DE 90 DIAS SIN COMPRAR



# SPRINT SEMANA 6 - TAREA 1
---------------------------------------------

-- Genera un sistema de recomendación item-item
	-- Que localice aquellos productos que son comprados frecuentemente en el mismo pedido
	-- Y recomiende a cada tienda según su propio historial de productos comprados
	-- cambiar una opción para que no genere timeout:
	-- Edit --> Preferences --> SQL Editor --> DBMS connection read timeout interval (in seconds)
-- Pasos a seguir:
-- Crea una tabla con el maestro de recomendaciones item-item


-- Crea una consulta que genere las recomendaciones para cada cliente concreto
-- Y que sea capaz de eliminar los productos ya comprados por ese cliente concreto

create table recomendador
select v1.id_prod as antecedente, v2.id_prod as consecuente, count(v1.id_pedido) as frecuencia
from v_ventas_agr_pedido as v1
	inner join v_ventas_agr_pedido as v2
     on v1.id_pedido = v2.id_pedido #cruzamos pedido con pedido para identificar los productos que se compran en el mismo pedido
        and v1.id_prod != v2.id_prod #quitamos los registros de cada producto consigo mismo
        and v1.id_prod < v2.id_prod #evitar matriz simetrica
group by v1.id_prod, v2.id_prod; #en cuantos pedidos aparecen juntos	

with input_cliente as (
		SELECT distinct id_prod, id_tienda
		FROM caso.ventas_agr
		where id_tienda = '1201'),
    productos_recomendados as (
		select consecuente, sum(frecuencia) as frecuencia
		from input_cliente as c
			left join
			 recomendador as r
			on c.id_prod = r.antecedente
		group by consecuente
		order by frecuencia desc)
#Hacer un antijoin para quitar los productos ya comprados de los recomendados
select consecuente as recomendado, frecuencia
from productos_recomendados as r
	left join
     input_cliente as c
	on r.consecuente = c.id_prod
    where id_prod is null;



