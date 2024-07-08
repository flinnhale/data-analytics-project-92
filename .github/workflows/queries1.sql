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
