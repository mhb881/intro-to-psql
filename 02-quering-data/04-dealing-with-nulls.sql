select * from users LIMIT 10;

-- PostgreSQL 中 = 不支持 NULL 判等
select * from users WHERE phone = NULL;

-- 在 psql 中要使用 is 关键字来查询 NULL 值
select * from users WHERE phone is NULL;

select name, phone from users where id in (1, 2, 6, 8);

select name, COALESCE(phone, 'No phone given')
from users
where
    id in (1, 2, 6, 8);

select name, COALESCE(phone, email, 'NA') as contact
from users
where
    id in (1, 2, 6, 8);

select id, name, username, COALESCE(name, username) as display
from users
where
    id in (1, 2, 28);