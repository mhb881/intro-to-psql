select * from users where name != 'Aaron';

select * from users where id > 10 and id < 20;

select * from users where id <= 5 or id > 100;

select * from users where id <= 5 or ( id > 100 and id < 110 );

select name, status
from users
where
    name = 'Sarah Johnson'
    or name = 'Aaron'
    and status = 'active';

select name, status
from users
where (
        name = 'Sarah Johnson'
        or name = 'Aaron'
    )
    and status = 'active';