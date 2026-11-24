SELECT u.id, u.name, p.title
from users as u
    left join posts as p on u.id = p.user_id
WHERE
    p.id IS NULL
ORDER BY u.id ASC
LIMIT 10;

SELECT p.id as post_id, u.id as user_id, p.title
from posts as p
    LEFT join users as u on p.user_id = u.id
WHERE
    u.id is NULL