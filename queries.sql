select count(*) as customers_count
from
    customers; -- считаем общее количество покупателей

select
    --объединяем имя и фамилию в одну строку
    e.first_name||' '||e.last_name as seller,
    count(s.sales_id) as operations, -- считаем количество проведенных продаж
    -- считаем выручку с округлением до целого
    floor(sum(p.price * s.quantity)) as income
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id
inner join products as p on s.product_id = p.product_id
group by e.first_name, e.last_name -- группируем по имени и фамилии сотрудника
order by income desc -- сортируем по убыванию выручки
limit 10; -- оставляем 10 лучших сотрудников

select
    e.first_name||' '||e.last_name as seller,
    floor(avg(p.price * s.quantity)) as average_income
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id
inner join products as p on s.product_id = p.product_id
group by e.first_name, e.last_name
having -- сортируем результаты
    floor(
        -- делаем подзапрос для поиска средней общей выручки
        avg(p.price * s.quantity)) < (
        select floor(avg(p.price * s.quantity))
        from sales as s
        inner join products as p
            on s.product_id = p.product_id
    )
order by average_income; /* сортируем по возрастанию продавцов,
чья выручка ниже средней выручки всех продавцов */

select
    e.first_name||' '||e.last_name as seller,
    to_char(s.sale_date, 'day') as day_of_week, -- берем день недели
    floor(sum(p.price * s.quantity)) as income
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id
inner join products as p on s.product_id = p.product_id
group by
    e.first_name||' '||e.last_name,
    -- группируем по продавцу и дню недели
    to_char(s.sale_date, 'day'), to_char(s.sale_date - 1, 'd')
order by to_char(s.sale_date - 1, 'd'), seller;  -- сортируем по дням недели


select
    case
        when c.age between 16 and 25 then '16-25'
        when c.age between 26 and 40 then '26-40'
        when c.age > 40 then '40+'
    --разбиваем покупателей на категории с помощью условной агрегации
    end as age_category,
    count(*) as age_count -- считаем количество записей в каждой категории
from customers as c
group by age_category -- группируем по названию категории
order by age_category;

select
    --переводим дату в нужный нам формат
    to_char(s.sale_date, 'YYYY-MM') as selling_month,
    --считаем количество уникальных покупателей
    count(distinct s.customer_id) as total_customers,
    floor(sum(s.quantity * p.price)) as income
from
    sales as s
inner join products as p on s.product_id = p.product_id
group by to_char(s.sale_date, 'YYYY-MM') -- группируем выручку по месяцам
order by selling_month;


with tb1 as ( -- создаем представление для удобства работы
    select
        s.sale_date,
        p.price,
        s.customer_id,
        -- с оконной функцией разбиваем данные по покупателям
        c.first_name|| ' '|| c.last_name as customer,
        e.first_name||' '||e.last_name as seller,
        row_number()
            over (partition by s.customer_id order by s.sale_date)
        as rn
    from sales as s
    inner join employees as e on s.sales_person_id = e.employee_id
    inner join products as p on s.product_id = p.product_id
    inner join customers as c on s.customer_id = c.customer_id
)

select
    tb1.customer,
    tb1.sale_date,
    tb1.seller
from tb1
where tb1.rn = 1 and tb1.price = 0
order by tb1.customer_id;
