select posts.id as post_id, posts.title, users.name
from posts
    inner join users on posts.user_id = users.id;

select posts.id as post_id, posts.title, COALESCE(users.name, 'Unknown author') as author
from posts
    left join users on posts.user_id = users.id
WHERE
    users.id is NULL