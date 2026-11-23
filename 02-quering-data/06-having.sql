SELECT shipping_country, count(*) as order_count
from orders
GROUP BY
    shipping_country;

-- 如何获取订单量大于 50 的国家
-- 你可能会尝试这样做，但会报错：聚合函数不允许出现在WHERE中
SELECT shipping_country, count(*) as order_count
from orders
where
    count(*) > 50
GROUP BY
    shipping_country;

-- 你可以在 group by 后面使用 having 来过滤聚合结果
SELECT shipping_country, count(*) as order_count
from orders
GROUP BY
    shipping_country
HAVING
    count(*) > 50;

-- 遗憾的是 psql 没有下面这个功能，在 Mysql 中你可以重复使用 alias
SELECT shipping_country, count(*) as order_count
from orders
GROUP BY
    shipping_country
HAVING
    order_count > 50;