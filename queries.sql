select 
concat(e.first_name,' ', e.last_name)  as seller, --объединяем имя и фамилию в одну строку
count(s.sales_id)  as operations, -- считаем количество проведенных продаж
floor(sum(p.price * s.quantity))  as income -- считаем выручку с округлением до целого
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id 
inner join products as p on s.product_id =p.product_id 
group by first_name,last_name -- группируем по имени и фамилии сотрудника
order by income desc -- сортируем по убыванию выручки
limit 10; -- оставляем 10 лучших сотрудников

select 
concat(e.first_name,' ', e.last_name)  as seller, 
floor(avg(p.price * s.quantity))  as average_income 
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id 
inner join products as p on s.product_id =p.product_id 
group by first_name,last_name 
having -- сортируем результаты
floor(avg(p.price * s.quantity)) < (select floor(avg(p.price*s.quantity)) -- делаем подзапрос для поиска средней общей выручки
from sales as s 
inner join products as p 
on s.product_id =p.product_id)
order by average_income; -- сортируем по возрастанию продавцов, чья выручка ниже средней выручки всех продавцов

select 
concat(e.first_name,' ', e.last_name)  as seller,
to_char(s.sale_date, 'day') as day_of_week, -- берем день недели
floor(sum(p.price * s.quantity) ) as income 
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id 
inner join products as p on s.product_id =p.product_id
group by concat(e.first_name,' ', e.last_name),
to_char(s.sale_date, 'day'),to_char(s.sale_date - 1, 'd') -- группируем по продавцу и дню недели
order by to_char(s.sale_date - 1, 'd'), seller;  -- сортируем по дням недели

select 
case 
	when c.age between 16 and 25 then '16-25'
	when c.age between 26 and 40 then '26-40'
	when c.age > 40 then '40+'
end as age_category, --разбиваем покупателей на категории с помощью условной агрегации
count(*) as age_count -- считаем количество записей в каждой категории
from customers as c 
group by age_category -- группируем по названию категории
order by age_category; 

select 
to_char(s.sale_date, 'YYYY-MM') as selling_month, --переводим дату в нужный нам формат
count(distinct s.customer_id) as total_customers, --считаем количество уникальных покупателей
sum(s.quantity*p.price) as income
from
sales as s
inner join products p on s.product_id = p.product_id 
group  by to_char(s.sale_date, 'YYYY-MM') -- группируем выручку по месяцам
order by selling_month;


with tb1 as ( -- создаем представление для удобства работы
select  
concat(c.first_name,' ', c.last_name)  as customer, 
s.sale_date as sale_date,
concat(e.first_name,' ', e.last_name)  as seller,
row_number () over (partition by s.customer_id order by s.sale_date) as rn, -- с оконной функцией разбиваем данные по покупателям
p.price as price
from sales s
inner join employees e on e.employee_id = s.sales_person_id 
inner join products p on s.product_id =p.product_id 
inner join customers c on s.customer_id = c.customer_id) 

select 
tb1.customer,
tb1.sale_date,
tb1.seller
from tb1
where rn =1 and tb1.price = 0
order by tb1.sale_date; -- получаем список покупателей, совершивших первую покупку с акционным товаром по нулевой стоимости
