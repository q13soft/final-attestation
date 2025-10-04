CREATE SCHEMA IF NOT EXISTS public AUTHORIZATION pg_database_owner;

--Таблица товаров
CREATE TABLE IF NOT EXISTS public.product (
	prd_id serial NOT NULL, -- ID
	prd_name varchar(500) NOT NULL, -- Наименование, описание продукта
	prd_price numeric(12, 2) NOT NULL, -- Стоимость
	prd_quantity integer NOT NULL, -- Количество
	prd_category varchar(500) NOT NULL, -- Категория
	CONSTRAINT product_pkey PRIMARY KEY (prd_id),
	CONSTRAINT product_prd_price_check CHECK ((prd_price >= (0)::numeric)),
	CONSTRAINT product_prd_quantity_check CHECK ((prd_quantity >= 0))
);
CREATE INDEX IF NOT EXISTS idx_product_prd_id ON public.product USING btree (prd_id);

-- Column comments
COMMENT ON COLUMN public.product.prd_id IS 'ID';
COMMENT ON COLUMN public.product.prd_name IS 'Наименование, описание продукта';
COMMENT ON COLUMN public.product.prd_price IS 'Стоимость';
COMMENT ON COLUMN public.product.prd_quantity IS 'Количество';
COMMENT ON COLUMN public.product.prd_category IS 'Категория';

--Таблица покупателей
CREATE TABLE IF NOT EXISTS public.customer (
	cst_id serial NOT NULL, -- ID
	cst_firstname varchar(150) NOT NULL, -- Имя
	cst_lastname varchar(150) NOT NULL, -- Фамилия
	cst_phone varchar(18) NOT NULL, -- Телефон
	cst_email varchar(250) NULL, -- email
	CONSTRAINT customer_pkey PRIMARY KEY (cst_id)
);
CREATE INDEX IF NOT EXISTS idx_customer_cst_id ON public.customer USING btree (cst_id);

-- Column comments
COMMENT ON COLUMN public.customer.cst_id IS 'ID';
COMMENT ON COLUMN public.customer.cst_firstname IS 'Имя';
COMMENT ON COLUMN public.customer.cst_lastname IS 'Фамилия';
COMMENT ON COLUMN public.customer.cst_phone IS 'Телефон';
COMMENT ON COLUMN public.customer.cst_email IS 'email';

--Таблица статусов заказов
CREATE TABLE IF NOT EXISTS public.order_status (
	ost_id serial NOT NULL, -- ID
	ost_name varchar(100) NOT NULL, -- Имя статуса
	CONSTRAINT order_status_pkey PRIMARY KEY (ost_id)
);
CREATE INDEX IF NOT EXISTS idx_order_status_ost_id ON public.order_status USING btree (ost_id);

-- Column comments
COMMENT ON COLUMN public.order_status.ost_id IS 'ID';
COMMENT ON COLUMN public.order_status.ost_name IS 'Имя статуса';

--Таблица заказов
CREATE TABLE IF NOT EXISTS public.order2 (
	ord_id serial NOT NULL, -- ID
	prd_id integer NOT NULL, -- ID продукта
	cst_id integer NOT NULL, -- ID заказчика
	ord_date timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL, -- Дата заказа
	ord_quantity integer NOT NULL, -- Количество
	ost_id integer NOT NULL, -- ID Статуса
	CONSTRAINT order2_ord_quantity_check CHECK ((ord_quantity > 0)),
	CONSTRAINT order2_pkey PRIMARY KEY (ord_id)
);
CREATE INDEX IF NOT EXISTS idx_order2_ord_date ON public.order2 USING btree (ord_date);
CREATE INDEX IF NOT EXISTS idx_order2_ord_id ON public.order2 USING btree (ord_id);

-- Column comments
COMMENT ON COLUMN public.order2.ord_id IS 'ID';
COMMENT ON COLUMN public.order2.prd_id IS 'ID продукта';
COMMENT ON COLUMN public.order2.cst_id IS 'ID заказчика';
COMMENT ON COLUMN public.order2.ord_date IS 'Дата заказа';
COMMENT ON COLUMN public.order2.ord_quantity IS 'Количество';
COMMENT ON COLUMN public.order2.ost_id IS 'ID Статуса';

-- public.order2 внешние включи
ALTER TABLE public.order2 ADD CONSTRAINT order2_cst_id_fkey FOREIGN KEY (cst_id) REFERENCES public.customer(cst_id);
ALTER TABLE public.order2 ADD CONSTRAINT order2_ost_id_fkey FOREIGN KEY (ost_id) REFERENCES public.order_status(ost_id);
ALTER TABLE public.order2 ADD CONSTRAINT order2_prd_id_fkey FOREIGN KEY (prd_id) REFERENCES public.product(prd_id);


INSERT INTO public.product 
(prd_name, prd_price, prd_quantity, prd_category) VALUES
('Манго', 100.00, 50, 'Фрукты'),
('Дуриан', 350.00, 40, 'Фрукты'),
('Лонган', 90.00, 50, 'Фрукты'),
('Папайя', 50.00, 50, 'Фрукты'),
('Личи', 90.00, 50, 'Фрукты'),
('Джекфрут', 95.00, 50, 'Фрукты'),
('Картофель', 100.00, 50, 'Овощи');

INSERT INTO public.customer
(cst_firstname, cst_lastname, cst_phone, cst_email) values
('Иван', 'Петров', '911-387-8766', 'ipetrov@mail.ru'),
('Петр', 'Васечкин', '921-990-6730', 'vas@mail.ru'),
('Елена', 'Козлова', '991-439-2341', 'ekoz@mail.ru'),
('Юлия', 'Зайцева', '911-564-1008', ''),
('Екатерина', 'Редкая', '902-233-2237', 'red@ya.ru'),
('Андрей', 'Сидоров', '911-765-9500', 'a-sidor@mail.ru'),
('Алексей', 'Иванов', '911-345-3457', '');

INSERT INTO public.order_status
(ost_name) values 
('Формирование заказа'),
('Выполнен'),
('Доставка Grab'),
('Доставка 7 eleven'),
('Самовывоз 7 eleven'),
('Самовывоз Tesco Lotus');

INSERT INTO public.order2
(prd_id, cst_id, ord_date, ord_quantity, ost_id) values
(1, 2, '2025-10-01 12:25:00', 3, 2),
(4, 1, '2025-10-01 14:24:00', 4, 2),
(1, 4, '2025-10-01 15:42:00', 2, 3),
(2, 5, '2025-10-01 16:22:00', 4, 4),
(3, 6, '2025-10-01 09:54:00', 3, 4),
(5, 7, '2025-10-01 11:01:00', 2, 5),
(1, 2, '2025-10-01 13:08:00', 8, 6),
(7, 7, CURRENT_TIMESTAMP, 2, 1);
