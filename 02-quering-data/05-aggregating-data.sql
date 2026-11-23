select count(*) from users LIMIT 10;

select count(id) as id_count, count(phone) as phone_count
from users
LIMIT 10;

SELECT * from orders LIMIT 10;

SELECT AVG(total) from orders;

SELECT min(total) from orders;

SELECT max(total) from orders;

-- 按客户分组统计订单数量，但没什么意义，因为你不知道这些客户是谁
SELECT count(*) from orders GROUP BY customer_id;

SELECT
    customer_id,
    sum(total) as total_revenue,
    count(*) as order_count
from orders
GROUP BY
    customer_id;

-- psql 如何提取日期时间中的年份
select extract(
        year
        from created_at
    ) as year
from orders;

-- 按年份再次分组统计
SELECT
    customer_id,
    extract(
        year
        from created_at
    ) as year,
    sum(total) as total_revenue,
    count(*) as order_count
from orders
where
    discount is null
GROUP BY
    customer_id,
    extract(
        year
        from created_at
    );

-- 最后你真正应该担心的是你写的 group by 本身是一个错误
-- 字段 "orders.total" 必须出现在 GROUP BY 子句中或者在聚合函数中使用
select customer_id, total from orders GROUP BY customer_id

select customer_id, sum(total) as total_revenue
from orders
GROUP BY
    customer_id