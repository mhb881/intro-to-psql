select * from users LIMIT 10;

-- 原则：只查询你需要的数据
select
    name,
    email,
    created_at as registration_date
from users
where
    id = 1
LIMIT 10;

select name, 'username: ' || username as display_label
from users
where
    id = 1
LIMIT 10;

select * from users ORDER BY name ASC, id ASC LIMIT 10;