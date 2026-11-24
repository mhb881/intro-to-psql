-- 下面两个 sql 是一致的
select users.name, posts.title
from users
    right join posts on users.id = posts.user_id
order by posts.id ASC
LIMIT 10;

select users.name, posts.title
from posts
    left join users on users.id = posts.user_id
order by posts.id ASC
LIMIT 10;

-- 快速演示一下 full outer join
select users.name, posts.title
from posts
    full join users on users.id = posts.user_id
WHERE
    users.id is NULL
    or posts.id is NULL
order by posts.id ASC;