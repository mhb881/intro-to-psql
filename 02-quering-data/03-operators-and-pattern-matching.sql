-- 较为繁琐的条件筛选
select *
from users
where
    id = 1
    or id = 2
    or id = 3
    or id = 4;

-- 更好的做法
select * from users where id in (1, 2, 3, 4);

select * from users where id not in (1, 2, 3, 4);

-- 模式匹配
select * from users where name like 'a%';

select * from users where name like 'A%';

select * from users where name ilike 'A%';

select * from users where name not ilike 'A%';

select * from users where name like '%John%';

-- 严格匹配
select * from users where lower(name) = 'aaron';

select *
from users
where
    country in ('US', 'CA')
    and email ILIKE '%@gmail.com'
    and status = 'active';

select *
from users
where
    country in ('US', 'CA')
    and name ILIKE 'a%'
    and status = 'active'
    and created_at >= '2024-01-01'
    and created_at < '2025-01-01';