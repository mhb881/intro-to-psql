# Querying Data — Dealing with NULLs（处理 NULL）

本节介绍 PostgreSQL 中 `NULL` 的含义，以及**如何在查询、数据展示和计算中正确处理它**。

最重要的概念是：**`NULL` 表示未知或缺失的数据，它不是一个普通值，因此不能像数字、字符串或布尔值一样直接比较。**

## 1. 理解 NULL：SQL 的三值逻辑

在普通的布尔逻辑中，判断结果只有两种：

- `TRUE`：条件成立。
- `FALSE`：条件不成立。

但 SQL 引入了第三种状态：`UNKNOWN`（未知）。

这是因为数据库中的某些字段可能没有数据。当参与比较的内容是 `NULL` 时，数据库无法确定比较结果。

例如：

| 表达式        | 结果      | 原因                       |
| ------------- | --------- | -------------------------- |
| `5 = 5`       | `TRUE`    | 两个值相等                 |
| `5 = 10`      | `FALSE`   | 两个值不相等               |
| `5 = NULL`    | `UNKNOWN` | 不知道 `NULL` 代表什么     |
| `NULL = NULL` | `UNKNOWN` | 无法确定两个未知值是否相等 |

特别注意：**`NULL = NULL` 的结果仍然是 `NULL`，而不是 `TRUE`。**

因为 `NULL` 不是一个具体的值，它表示我们不知道实际内容是什么。

同样，`NULL` 也不等于以下任何一种情况：

- `0`：数字零。
- `''`：空字符串。
- `FALSE`：布尔值假。

它们代表的是不同的含义。

---

### 如何筛选 NULL？

理解三值逻辑之后，就能解释为什么下面的查询无法找到 `phone` 为空的用户：

```sql
-- 错误：不能使用 = NULL 判断空值
SELECT *
FROM users
WHERE phone = NULL;
```

原因是 `phone = NULL` 的结果是 `UNKNOWN`，而不是 `TRUE`。

SQL 的 `WHERE` 子句只会保留条件结果为 `TRUE` 的记录。结果为 `FALSE` 或 `UNKNOWN` 的记录都会被过滤掉。

因此，PostgreSQL 提供了专门的判断语法：

```sql
-- 查询 phone 为 NULL 的用户
SELECT *
FROM users
WHERE phone IS NULL;

-- 查询 phone 不为 NULL 的用户
SELECT *
FROM users
WHERE phone IS NOT NULL;
```

| 运算符        | 含义                    |
| ------------- | ----------------------- |
| `IS NULL`     | 判断字段是否为 `NULL`   |
| `IS NOT NULL` | 判断字段是否不为 `NULL` |

这里需要记住：**判断 `NULL` 必须使用 `IS NULL` 或 `IS NOT NULL`，不能使用 `=` 或 `!=`。**

---

## 2. COALESCE：为 NULL 提供备用值

在查询结果中出现 `NULL` 本身并不是问题。应用程序可以自行处理这些空值。

但有时我们希望数据库直接返回一个可用的替代值，而不是让查询结果中出现 `NULL`。

这时可以使用 `COALESCE()`。

它的作用是：**按照参数从左到右的顺序检查，返回第一个非 `NULL` 的值。**

基本语法：

```sql
COALESCE(value1, value2, value3, ...)
```

例如，我们希望用户没有电话号码时，显示一段默认文本：

```sql
SELECT
    name,
    COALESCE(phone, 'No phone given')
FROM users
WHERE id IN (1, 2, 6, 8);
```

执行逻辑：

- 如果 `phone` 有值，就返回 `phone`。
- 如果 `phone` 是 `NULL`，就返回 `'No phone given'`。

因此，查询结果不再直接展示空值。

---

### 使用多个备用字段

`COALESCE()` 不局限于提供固定的默认值，也可以依次检查多个字段。

例如，一个用户可能没有填写 `name`，但有 `username`。我们希望优先展示真实姓名，如果没有，就使用用户名。

```sql
SELECT
    id,
    name,
    username,
    COALESCE(name, username) AS display
FROM users
WHERE id IN (1, 2, 28);
```

其逻辑是：

1. 优先检查 `name`。
2. 如果 `name` 不为 `NULL`，就使用 `name`。
3. 如果 `name` 为 `NULL`，就继续检查 `username`。
4. 返回第一个非 `NULL` 的字段，作为 `display`。

这里的 `AS display` 是为计算结果指定一个列别名，方便应用程序使用。

`COALESCE()` 的参数需要能够转换为兼容的数据类型。例如，多个文本字段可以作为备用值依次传入。

---

## 3. NULL 对数学运算的影响

`NULL` 不仅会影响条件判断，也会影响数学计算。

在 PostgreSQL 中，涉及 `NULL` 的普通算术运算通常会返回 `NULL`。

例如：

```sql
SELECT 10 + 10;   -- 20
SELECT 10 + NULL; -- NULL
```

原因很简单：如果其中一个操作数的值未知，就无法确定最终的计算结果。

这在实际业务中可能造成问题。

例如，假设有一个销售报表，需要统计商品数量和金额：

```sql
SELECT
    id,
    price,
    quantity,
    price * quantity AS total
FROM orders;
```

如果 `quantity` 是 `NULL`，那么 `total` 也会变成 `NULL`，而不是一个正常的计算结果。

如果业务规则明确规定：数量缺失时按 `0` 处理，可以使用 `COALESCE()`：

```sql
SELECT
    id,
    price,
    quantity,
    price * COALESCE(quantity, 0) AS total
FROM orders;
```

此时：

- `quantity` 有值时，使用实际数量。
- `quantity` 为 `NULL` 时，使用 `0` 参与计算。

不过需要注意，**将 `NULL` 替换为 `0` 必须符合业务含义**。未知数量不一定真的代表数量为零，不能为了让计算结果完整而随意替换。

---

## 本节重点回顾

| 知识点             | 核心内容                                       |
| ------------------ | ---------------------------------------------- |
| `NULL`             | 表示未知或缺失的数据，不是普通值               |
| Three-Valued Logic | SQL 条件判断包含 `TRUE`、`FALSE`、`UNKNOWN`    |
| `= NULL`           | 结果是 `UNKNOWN`，不能用于判断空值             |
| `IS NULL`          | 筛选 `NULL`                                    |
| `IS NOT NULL`      | 筛选非 `NULL`                                  |
| `COALESCE()`       | 返回参数列表中第一个非 `NULL` 的值             |
| NULL in Arithmetic | 普通算术运算中，`NULL` 通常会使结果变为 `NULL` |

**本节最重要的三个实践习惯：**

1. 判断空值时使用 `IS NULL` / `IS NOT NULL`，不要使用 `= NULL`。
2. 使用 `COALESCE()` 为查询结果提供备用值，例如默认文本或备用字段。
3. 数学计算涉及可能为 `NULL` 的字段时，先考虑如何处理空值，但替代规则必须符合业务语义。

**知识之间的联系：**

前面学习的 `WHERE`、`IN`、`LIKE` 等过滤操作，都是在判断记录是否满足某些条件。而本节进一步说明：当条件涉及 `NULL` 时，判断结果可能不是 `TRUE` 或 `FALSE`，而是 `UNKNOWN`。

理解这一点，是正确编写 SQL 查询和处理数据库数据的重要基础。