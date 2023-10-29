# Витрина RFM

## 1.1. Выясните требования к целевой витрине.

- Витрина должна быть создана в базе 'de', схема - 'analysis', название - 'dm_rfm_segments'
- Поля витрины: user_id, recency (число от 1 до 5), frequency (число от 1 до 5), monetary_value (число от 1 до 5)
- Распределение по категориям от 1 до 5 равномерное. Если в строках одинаковое значение параметра, не имеет значения, в какую категорию будет отнесен пользователь 
- Период данных: с начала 2022 года
- Для витрины должны быть отобраны только заказы в статусе "closed' (в таблице orderstatuses - 4)
- Обновление витрины не требуется
  

## 1.2. Изучите структуру исходных данных.

- Для построения витрины нам достаточно данных таблицы 'orders'. Таблица содержит 'user_id', информацию о дате и сумме заказа, а так же статус заказа.
- Нас интересуют заказы в статусе 'closed'. В 'orders' статус заказа представлен числовым значением. Используя данные таблиц 'orderstatuses' и 'orderstatuses' определяем, что значение 4 соответствует статусу 'closed'.

## 1.3. Проанализируйте качество данных

Нас будет интересовать только таблица 'orders'.

Наблюдения:
- В таблице ровно 10 000 записей
- Для всех полей таблицы установлено ограничение NOT NULL
- Поле 'order_id' - primary key
- Поля 'bonus_payment', 'payment', 'cost', 'bonus_grant' имеют значение по умолчанию 0
- Типы данных полей согласуются с логикой
- В таблице построен индекс по 'order_id'
- Проверка показала отсутствие дубликатов по составному ключу из полей 'order_id' + 'order_ts'

Уточним органичения:

SELECT constraint_name, constraint_type, pg_get_constraintdef(c.oid) as constraint_definition
FROM information_schema.table_constraints tc
JOIN pg_constraint c ON tc.constraint_name = c.conname
WHERE tc.table_name = 'orders';

Дополнительное ограничение имеет поле 'cost' -> cost  = (payment + bonus_payment)

## 1.4. Подготовьте витрину данных

### 1.4.1. Сделайте VIEW для таблиц из базы production.**

```SQL
--Впишите сюда ваш ответ
CREATE VIEW analysis.users AS SELECT * FROM production.users;
CREATE VIEW analysis.orderitems AS SELECT * FROM production.orderitems;
CREATE VIEW analysis.orderstatuses AS SELECT * FROM production.orderstatuses;
CREATE VIEW analysis.products AS SELECT * FROM production.products;
CREATE VIEW analysis.orders AS SELECT * FROM production.orders;
```

### 1.4.2. Напишите DDL-запрос для создания витрины.**

```SQL
--Впишите сюда ваш ответ
DROP TABLE IF EXISTS analysis.dm_rfm_segments;
DROP TABLE IF EXISTS analysis.tmp_rfm_recency;
DROP TABLE IF EXISTS analysis.tmp_rfm_frequency;
DROP TABLE IF EXISTS analysis.tmp_rfm_monetary_value;

CREATE TABLE analysis.dm_rfm_segments(
  user_id int4 NOT NULL PRIMARY KEY,
  recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5),
  frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5),
  monetary_value INT NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);

CREATE TABLE analysis.tmp_rfm_recency (
 user_id INT NOT NULL PRIMARY KEY,
 recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);
CREATE TABLE analysis.tmp_rfm_frequency (
 user_id INT NOT NULL PRIMARY KEY,
 frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
);
CREATE TABLE analysis.tmp_rfm_monetary_value (
 user_id INT NOT NULL PRIMARY KEY,
 monetary_value INT NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);

```

### 1.4.3. Напишите SQL запрос для заполнения витрины

```SQL
--Впишите сюда ваш ответ

--tmp_rfm_frequency
INSERT INTO analysis.tmp_rfm_frequency (user_id, frequency)
SELECT  usr.id AS user_id,
		NTILE(5) OVER (ORDER BY orders_data.count_orders ASC NULLS FIRST) AS frequency
FROM (
  	SELECT DISTINCT ord.user_id AS user_id,
    	   COUNT(ord.order_id) AS count_orders
	FROM analysis.orders AS ord
  	WHERE ord.status = 4
	GROUP BY ord.user_id
) AS orders_data
RIGHT JOIN analysis.users AS usr ON orders_data.user_id=usr.id
GROUP BY usr.id, orders_data.count_orders
ORDER BY frequency ASC;

--tmp_rfm_recency
INSERT INTO analysis.tmp_rfm_recency (user_id, recency)
SELECT usr.id AS user_id,
	   NTILE(5) OVER (ORDER BY orders_data.last_date ASC NULLS FIRST) AS recency
FROM (
  	SELECT DISTINCT ord.user_id AS user_id,
    	   MAX(ord.order_ts) AS last_date
	FROM analysis.orders as ord
  	WHERE ord.status = 4
	GROUP BY ord.user_id
) AS orders_data
RIGHT JOIN analysis.users AS usr ON orders_data.user_id=usr.id
GROUP BY usr.id, orders_data.last_date
ORDER BY recency ASC;

--tmp_rfm_monetary_value
INSERT INTO analysis.tmp_rfm_monetary_value (user_id, monetary_value)
SELECT usr.id AS user_id,
	   NTILE(5) OVER (ORDER BY SUM(orders_data.order_sum) ASC NULLS FIRST) AS monetary_value
FROM (
  	SELECT DISTINCT ord.user_id AS user_id,
    	   SUM(ord.cost) AS order_sum
	FROM analysis.orders AS ord
  	WHERE ord.status = 4
	GROUP BY ord.user_id
) AS orders_data
RIGHT JOIN analysis.users AS usr ON orders_data.user_id=usr.id
GROUP BY usr.id, orders_data.order_sum
ORDER BY monetary_value ASC;
	
--dm_rfm_segments
INSERT INTO analysis.dm_rfm_segments (user_id, recency, frequency, monetary_value)
SELECT DISTINCT trr.user_id AS user_id,
	   trr.recency AS recency,
	   trf.frequency AS frequency,
	   trmv.monetary_value AS monetary_value
FROM analysis.tmp_rfm_recency AS trr
LEFT JOIN analysis.tmp_rfm_frequency AS trf ON trr.user_id = trf.user_id	
LEFT JOIN analysis.tmp_rfm_monetary_value AS trmv ON trr.user_id = trmv.user_id
ORDER BY trr.user_id
LIMIT 10;

```



