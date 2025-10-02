--  Список всех заказов с именем покупателя и описанием товара.
SELECT c.cst_firstname, c.cst_lastname, p.prd_name, p.prd_price, o2.ord_quantity ,p.prd_price*o2.ord_quantity as sum, os.ost_name, o2.ord_date 
FROM order2 o2  
JOIN customer c ON o2.cst_id = c.cst_id
join product p on o2.prd_id = p.prd_id 
join order_status os on o2.ost_id = os.ost_id 

-- Топ-3 самых популярных товара.
select  p.prd_name, sum(o2.ord_quantity) as sum 
from product p
join order2 o2 on o2.prd_id = p.prd_id 
group by p.prd_name
order by sum desc
limit 3;

-- клиенты без заказов
SELECT c.cst_firstname, c.cst_lastname
FROM customer c
LEFT JOIN order2 o2 on o2.cst_id = c.cst_id
WHERE o2.cst_id IS NULL;