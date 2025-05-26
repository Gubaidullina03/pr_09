--Практическое задание №9
--Определить ближайший дилерский центр для каждого клиента. 
--Маркетологи пытаются повысить вовлеченность клиентов, помогая
-- им найти ближайший к ним дилерский центр. Команда разработчиков
-- также заинтересована в том, чтобы узнать, каково среднее расстояние
-- между каждым покупателем и его ближайшим дилерским центром.

--Во-первых, создадим таблицу с точками долготы и широты для каждого клиента:

CREATE TEMP TABLE customer_points AS (
SELECT
customer_id,
point(longitude, latitude) AS lng_lat_point
FROM customers
WHERE longitude IS NOT NULL
AND latitude IS NOT NULL
);

--Проверим данные во временной таблице.

SELECT * FROM customer_points;

--Создадим аналогичную таблицу для каждого дилерского центра:


CREATE TEMP TABLE dealership_points AS (
SELECT
dealership_id,
point(longitude, latitude) AS lng_lat_point
FROM dealerships
);

--Проверим данные во временной таблице:

SELECT * FROM dealership_points;


--Объединим эти таблицы, чтобы рассчитать расстояние от каждого клиента до каждого дилерского центра (в милях):

CREATE TEMP TABLE customer_dealership_distance AS (
SELECT
customer_id,
dealership_id,
c.lng_lat_point <@> d.lng_lat_point AS distance
FROM customer_points c
CROSS JOIN dealership_points d
);


--Проверим данные во временной таблице:

SELECT * FROM customer_dealership_distance;

--Выберем ближайший дилерский центр для каждого клиента, используя следующий запрос:

CREATE TEMP TABLE closest_dealerships AS (
SELECT DISTINCT ON (customer_id)
customer_id,
dealership_id,
distance
FROM customer_dealership_distance
ORDER BY customer_id, distance
);

--Проверим данные во временной таблице:

SELECT * FROM closest_dealerships;

--Рассчитаем среднее расстояние от каждого клиента до его ближайшего дилерского центра.

SELECT
AVG(distance) AS avg_dist,
PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY distance) AS
median_dist
FROM closest_dealerships;


--Удалим временные таблицы:

drop TABLE IF EXISTS customer_points;

drop TABLE IF EXISTS dealership_points;

drop TABLE IF EXISTS customer_dealership_distance;


