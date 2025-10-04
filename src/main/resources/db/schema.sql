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

