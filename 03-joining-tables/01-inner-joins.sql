select * from users LIMIT 10;

select * from posts LIMIT 10;

-- 这样行不通，尽管 postgres 很聪明，但它不知道要连接的字段
select title from posts INNER JOIN users LIMIT 10;

-- 你要告诉 postgres 两张表格根据哪个字段连接起来
select users.name, posts.title, users.id, posts.user_id
from posts
    INNER JOIN users ON posts.user_id = users.id
LIMIT 10;

-- 使用 alias 偷懒
select u.name, p.title, u.id, p.user_id
from posts p
    INNER JOIN users u ON p.user_id = u.id
LIMIT 10;

-- 当然你可以进行过滤
select u.name, p.title, u.id, p.user_id, p.created_at
from posts p
    INNER JOIN users u ON p.user_id = u.id
WHERE
    p.created_at > now() - INTERVAL '395 days';