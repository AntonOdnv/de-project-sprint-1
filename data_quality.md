1. Таблица 'orders':

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

2. Таблица 'orderitems':

- Для всех полей таблицы установлено ограничение NOT NULL
- Поле 'id' - primary key, автоинкремент - always
- FOREIGN KEY (order_id) REFERENCES production.orders(order_id)
- FOREIGN KEY (product_id) REFERENCES production.products(id)
- Поля 'price', 'discount' имеют значение по умолчанию 0
- Типы данных полей согласуются с логикой
- Установлены ограничения: 'price' >= 0 , 'quantity' > 0 , 'discount' >= 0 and 'discount' <= 'price'

3. Таблица 'orderstatuses':

- Для всех полей таблицы установлено ограничение NOT NULL
- Поле 'id' - primary key
- Поля 'price', 'discount' имеют значение по умолчанию 0
- Типы данных полей согласуются с логикой

4. Таблица 'orderstatuslog':

- Для всех полей таблицы установлено ограничение NOT NULL
- Поле 'id' - primary key, автоинкремент - always
- FOREIGN KEY (order_id) REFERENCES production.orders(order_id)
- FOREIGN KEY (status_id) REFERENCES production.orderstatuses(id)
- Типы данных полей согласуются с логикой
- На поля 'order_id', 'status_id' наложено ограничение UNIQUE

5. Таблица 'products':

- Для всех полей таблицы установлено ограничение NOT NULL
- Поле 'id' - primary key
- Поле 'price' имеет значение по умолчанию 0
- Типы данных полей согласуются с логикой
- Установлены ограничения: 'price' >= 0 

6. Таблица 'orderstatuslog':

- Для всех полей таблицы кроме 'name' установлено ограничение NOT NULL
- Поле 'id' - primary key
- Типы данных полей согласуются с логикой