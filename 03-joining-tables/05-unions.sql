-- 这是一个设计上面的取舍，你可以将某一个实体表拆分成多个表，每个表负责存储不同的数据
-- 这是很合理的设计，但是如何查询所有员工的信息？或者说连接这两个表？使用 UNION
select name, email
from current_employees
UNION
select name, email
from former_employees;

-- 常见错误：每一个 UNION 查询必须有相同的字段个数
select id, name, email
from current_employees
UNION
select name, email
from former_employees;

-- 常见错误：虽然拥有相同的字段个数，但是字段类型必须相同
select id, name, email
from current_employees
UNION
select 'footbar', name, email
from former_employees;

-- 常见业务场景：我想区分当前员工和前员工
select id, name, email, 'current' as type
from current_employees
UNION
select id, name, email, 'former'
from former_employees;

-- union 默认行为：会自动去重
SELECT 1 UNION SELECT 1 UNION SELECT 2;

-- 如果你想保留所有的行，包括重复的行，你可以使用 UNION ALL
SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 2;
-- 1, 1, 2