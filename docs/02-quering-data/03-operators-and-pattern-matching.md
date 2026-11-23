# Querying Data — Operators and Pattern Matching（运算符与模式匹配）

本节继续介绍 SQL 的数据过滤，重点是两类操作：使用 `IN` 判断一个值是否属于指定集合，以及使用 `LIKE` / `ILIKE` 对文本进行模式匹配。

## 1. IN：匹配一组指定值

当需要判断某一列是否等于多个候选值中的任意一个时，可以使用 `OR`：

```sql
SELECT *
FROM users
WHERE id = 1
   OR id = 2
   OR id = 3
   OR id = 4;
```

这种写法没有问题，但当候选值越来越多时，条件会变得冗长。

`IN` 可以将这些条件简化为一个列表：

```sql
SELECT *
FROM users
WHERE id IN (1, 2, 3, 4);
```

它表示：只要 `id` 等于括号中的任意一个值，就满足过滤条件。

如果希望排除这些值，可以使用 `NOT IN`：

```sql
SELECT *
FROM users
WHERE id NOT IN (1, 2, 3, 4);
```

---

### IN 的另一个用途：子查询

`IN` 不仅可以接收手动指定的值，还可以接收另一个 `SELECT` 查询的结果。

```sql
SELECT *
FROM users
WHERE id IN (
    SELECT id
    FROM users
    WHERE status = 'active'
);
```

这里内部的 `SELECT` 称为**子查询（Subquery）**。它先定义一个结果集合，外层查询再判断 `id` 是否属于这个集合。

这种方式有一个重要价值：**可以把数据筛选逻辑交给数据库在一次查询中完成，而不必先取出一批 ID，再由应用程序发起第二次查询。**

例如，应用程序原本可能需要执行：

1. 向数据库查询符合条件的用户 ID；
2. 将这些 ID 返回给应用程序；
3. 应用程序再携带这些 ID 查询完整记录。

这样会产生两次数据库往返（Round Trips），还可能引入数据变化导致的不一致：两次查询之间，数据库中的记录可能已经发生变化。

使用子查询则可以将两个步骤合并：

```sql
SELECT *
FROM users
WHERE id IN (
    SELECT id
    FROM users
    WHERE status = 'active'
);
```

数据库可以根据查询结构和执行计划选择合适的执行方式，例如利用索引或采用连接相关的执行策略。

需要注意：`IN` 的主要优势是表达简洁、方便传递列表，以及支持子查询。

不能简单认为它在所有情况下都比多个 `OR` 更快，实际性能仍取决于查询计划和数据情况。

---

## 2. LIKE 和 ILIKE：文本模式匹配

前面使用 `=` 时，要求列中的值与指定内容相等。但有时我们不需要完整匹配，而是希望查找符合某种文本模式的记录。

例如：

- 查找名字以 `A` 开头的用户；
- 查找邮箱以 `gmail.com` 结尾的用户；
- 查找名字中包含 `John` 的用户。

这时可以使用 `LIKE` 运算符。

`LIKE` 使用**通配符（Wildcard）**描述需要匹配的文本模式。其中最常用的是 `%`，表示任意长度的字符串，包括空字符串。

| 模式       | 含义      | 示例                      |
| ---------- | --------- | ------------------------- |
| `'A%'`     | 以 A 开头 | Aaron、Apple              |
| `'%A'`     | 以 A 结尾 | Anna                      |
| `'%A%'`    | 包含 A    | Aaron、Sarah              |
| `'%John%'` | 包含 John | John Smith、Sarah Johnson |

例如：

```sql
-- 名字以 a 开头
SELECT *
FROM users
WHERE name LIKE 'a%';

-- 名字中包含 John
SELECT *
FROM users
WHERE name LIKE '%John%';

-- 邮箱以 gmail.com 结尾
SELECT *
FROM users
WHERE email LIKE '%@gmail.com';
```

这里有一个容易忽略的细节：`LIKE` 默认区分大小写。

```sql
SELECT *
FROM users
WHERE name LIKE 'A%';
```

这个查询不会匹配以小写 `a` 开头的名字。

---

### LIKE 与 ILIKE 的区别

PostgreSQL 提供了 `ILIKE`，用于执行不区分大小写的模式匹配。

```sql
-- 区分大小写
SELECT *
FROM users
WHERE name LIKE 'A%';

-- 不区分大小写
SELECT *
FROM users
WHERE name ILIKE 'A%';
```

使用 `ILIKE` 后，`Aaron` 和 `apple` 都可以匹配 `'A%'`。

同样，也可以使用 `NOT ILIKE` 排除符合指定模式的记录：

```sql
SELECT *
FROM users
WHERE name NOT ILIKE 'A%';
```

| 运算符      | 匹配方式                       |
| ----------- | ------------------------------ |
| `LIKE`      | 区分大小写的模式匹配           |
| `ILIKE`     | 不区分大小写的模式匹配         |
| `NOT LIKE`  | 排除符合模式的文本             |
| `NOT ILIKE` | 排除符合不区分大小写模式的文本 |

补充：除了 `%`，`LIKE` 还支持 `_`，它表示任意单个字符。例如 `'A_'` 匹配两个字符组成、以 `A` 开头的文本。

---

## 3. 大小写敏感的相等比较与 LOWER()

需要注意，大小写敏感不只是 `LIKE` 的问题。在 PostgreSQL 常见的默认文本比较环境下，使用 `=` 进行字符串相等比较也会区分大小写。

例如：

```sql
SELECT *
FROM users
WHERE name = 'Aaron';
```

通常不会匹配 `aaron`。

如果业务需求**要求忽略大小写**，可以使用 `LOWER()` 函数，将文本转换为小写后再进行比较：

```sql
SELECT *
FROM users
WHERE LOWER(name) = 'aaron';
```

`LOWER(name)` 会将每条记录的 `name` 转换为小写，然后再与 `'aaron'` 比较。

这样，`Aaron`、`AARON` 和 `aaron` 都可以匹配。

讲师指出，这种写法对索引的使用有影响：如果只有普通的 `name` 索引，数据库不能直接将它当作 `LOWER(name)` 的索引使用。

一种解决方式是创建**表达式索引（Expression Index）**：

```sql
CREATE INDEX users_name_lower_idx
ON users (LOWER(name));
```

这样，针对 `LOWER(name)` 的查询就有机会使用对应的索引。

另外，如果业务本身规定邮箱等字段在写入数据库前就统一转换为小写，那么查询时也可以按照相同规则处理，不必每次都额外进行大小写转换。

更深入的文本比较规则还涉及 **Collation（排序规则）**。它定义了文本之间如何进行比较和排序，具体行为不只是简单地将字符串转换为大写或小写。本节暂时不展开。

---

## 4. 综合应用：组合不同的过滤条件

前面介绍的运算符可以组合使用，构建更接近实际业务需求的查询。

例如，查询来自美国或加拿大、名字以 A 开头、状态为 active 的用户：

```sql
SELECT *
FROM users
WHERE country IN ('US', 'CA')
  AND name ILIKE 'a%'
  AND status = 'active';
```

这里同时使用了三种过滤方式：

- `IN`：国家必须是 `US` 或 `CA`。
- `ILIKE`：名字必须以 A 开头，不区分大小写。
- `=`：用户状态必须严格匹配 `active`。

还可以继续添加日期范围：

```sql
SELECT *
FROM users
WHERE country IN ('US', 'CA')
  AND name ILIKE 'a%'
  AND status = 'active'
  AND created_at >= '2024-01-01'
  AND created_at < '2025-01-01';
```

这里使用了一个很常见的日期范围写法：

\[
[2024\text{-}01\text{-}01,\ 2025\text{-}01\text{-}01)
\]

它表示：

- 起始日期包含在范围内（`>=`）。
- 结束日期不包含在范围内（`<`）。

因此，查询覆盖整个 2024 年。

这种写法尤其适合 `timestamp` 类型的字段。它不需要人为计算某一天的最后一秒，也不会遗漏具有更高时间精度的记录。

---

## 本节重点回顾

| 知识点           | 核心作用                                     |
| ---------------- | -------------------------------------------- |
| `IN`             | 判断一个值是否属于指定列表                   |
| `NOT IN`         | 排除指定列表中的值                           |
| Subquery         | 在查询条件中嵌套另一个查询                   |
| `LIKE`           | 根据文本模式进行大小写敏感匹配               |
| `ILIKE`          | 根据文本模式进行大小写不敏感匹配             |
| `%`              | 匹配任意长度的字符串                         |
| `_`              | 匹配任意单个字符                             |
| `LOWER()`        | 将文本转换为小写                             |
| Expression Index | 为表达式建立索引，提高对应查询的索引使用机会 |
| Collation        | 定义文本比较和排序所遵循的规则               |

**本节最值得掌握的三个实践习惯：**

1. 同一列需要匹配多个候选值时，优先考虑 `IN`，而不是重复编写 `OR`。
2. 进行部分文本匹配时，使用 `LIKE` 或 `ILIKE`，注意两者的大小写行为。
3. 处理时间范围时，优先理解并使用左闭右开的区间，例如 `>= 起始时间 AND < 结束时间`。

**下一节：** 将继续介绍 SQL 中的 `NULL`，理解数据库如何表示缺失或未知的值，以及它为什么会影响条件判断。