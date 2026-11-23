# Joining Tables — INNER JOIN（内连接）

前面学习的查询主要围绕单张表展开，但实际业务数据通常分布在多张表中（如何跨表操作）。

例如，一个博客系统可能有两张表：

- `users`：保存用户信息。
- `posts`：保存文章信息。

如果想查询文章标题以及文章作者的名字，就**需要将两张表关联起来**。

本节介绍 `JOIN` 的基础知识，以及最常见的连接方式：`INNER JOIN`。

---

## 1. 理解表之间的关系：Primary Key 与 Foreign Key

在连接两张表之前，需要先理解两个概念。

**主键（Primary Key，PK）**

主键用于唯一标识一张表中的一条记录。

例如，`users` 表：

| id   | name  | email             |
| ---- | ----- | ----------------- |
| 1    | Aaron | aaron@example.com |
| 2    | Sarah | sarah@example.com |
| 3    | Emma  | emma@example.com  |

这里的 `id` 就是主键，每个用户都有唯一的 ID。

**外键（Foreign Key，FK）**

外键是**用于关联其他表记录**的字段。通常，**它保存另一张表的主键值**。

例如，`posts` 表：

| id   | title               | user_id |
| ---- | ------------------- | ------- |
| 1    | Learning PostgreSQL | 1       |
| 2    | SQL Basics          | 2       |
| 3    | Database Design     | 1       |
| 4    | Advanced Queries    | 3       |

其中：

- `posts.id` 是文章表自己的主键。
- `posts.user_id` 保存文章作者对应的用户 ID，是关联 `users.id` 的外键。

两张表通过下面的关系建立联系：

```mermaid
flowchart LR
    %% 节点定义
    U("users 表")
    ID(["id（主键 PK）"])
    R("建立关联")
    UID(["user_id（外键 FK）"])
    P("posts 表")

    %% 连线
    U --> ID --> R --> UID --> P

    %% 样式定义
    classDef table fill:#E8F1FC,stroke:#5487C7,stroke-width:1.5px,color:#1D3557,rx:12,ry:12;
    classDef relation fill:#EAF5ED,stroke:#5B9B70,stroke-width:1.5px,color:#245B37,rx:12,ry:12;
    classDef capsule fill:#FFFFFF,stroke:#A9BEDC,stroke-width:1.5px,color:#1D3557;

    %% 应用样式
    class U,P table;
    class R relation;
    class ID,UID capsule;

    %% 统一连线样式（灰色）
    linkStyle default stroke:#999999,stroke-width:1.5px;
```

这种命名方式也是常见约定：

| 类型 | 命名约定         | 示例            |
| ---- | ---------------- | --------------- |
| 主键 | `id`             | `users.id`      |
| 外键 | 单数表名 + `_id` | `posts.user_id` |

这样能够比较直观地看出字段之间的关联关系。

---

## 2. INNER JOIN：只返回匹配成功的记录

假设现在需要查询每篇文章的标题，以及它对应的作者名字。

如果只查询 `posts`：

```sql
SELECT *
FROM posts
LIMIT 10;
```

我们可以得到文章标题，但是不知道作者的具体名字，因为作者信息保存在 `users` 表中。

这时就需要使用 `INNER JOIN`。

基本语法：

```sql
SELECT columns
FROM table_A
INNER JOIN table_B
    ON table_A.foreign_key = table_B.primary_key;
```

其中：

- `FROM`：指定查询的起始表。
- `INNER JOIN`：将另一张表连接进来。
- `ON`：明确告诉 PostgreSQL 两张表应该按照什么条件关联。

例如：

```sql
SELECT
    users.name,
    posts.title,
    users.id,
    posts.user_id
FROM posts
INNER JOIN users
    ON posts.user_id = users.id
LIMIT 10;
```

这里最重要的是：

```sql
ON posts.user_id = users.id
```

它告诉 PostgreSQL：将 `posts.user_id` 与 `users.id` 相等的记录关联起来。

PostgreSQL 不会自动猜测两张表应该通过哪个字段连接，**因此需要明确指定连接条件**。

---

### INNER JOIN 的匹配规则

`INNER JOIN` 只返回两张表中能够匹配成功的记录。

可以通过维恩图理解：

![image-20261124014643542](./01-inner-join.assets/image-20261124014643542.png)

具体来说：

- 有用户，但是没有发布文章：不会出现在结果中。
- 有文章，但是找不到对应用户：不会出现在结果中。
- 用户和文章能够匹配：保留关联后的记录。

因此，`INNER JOIN` 可以理解为：**只保留连接条件成立的记录组合。**

另外，`INNER JOIN` 是 SQL 中默认的连接类型，因此：

```sql
FROM posts
INNER JOIN users ON posts.user_id = users.id
```

等价于：

```sql
FROM posts
JOIN users ON posts.user_id = users.id
```

不过，明确写出 `INNER` 有助于阅读代码时快速识别连接类型。

---

## 3. 多表查询：字段限定、别名与过滤

当查询涉及多张表时，很容易出现一个问题：**字段名冲突（Ambiguous Column）**。

例如，`users` 和 `posts` 都有自己的 `id`：

```sql
SELECT id
FROM posts
INNER JOIN users
    ON posts.user_id = users.id;
```

PostgreSQL 不知道这里的 `id` 指的是哪张表，因此会报错：

```text
column reference "id" is ambiguous
```

解决方法是使用 `表名.字段名` 明确指定字段：

```sql
SELECT
    users.name,
    posts.title,
    users.id,
    posts.user_id
FROM posts
INNER JOIN users
    ON posts.user_id = users.id;
```

即使某个字段当前只存在于其中一张表，关联查询中主动使用表名前缀，也有助于提高代码可读性。

---

### 使用表别名（Alias）

如果表名比较长，每次都写完整名称可能比较繁琐。SQL 允许使用别名简化：

```sql
SELECT
    u.name,
    p.title,
    u.id,
    p.user_id
FROM posts AS p
INNER JOIN users AS u
    ON p.user_id = u.id;
```

也可以省略 `AS`：

```sql
FROM posts p
INNER JOIN users u
    ON p.user_id = u.id;
```

这里：

- `p` 代表 `posts`。
- `u` 代表 `users`。

别名只是当前查询中对表的简短引用，不会修改数据库中的真实表名。

讲师对别名的态度比较灵活：有人喜欢使用短别名，有人更倾向于写完整表名。实际项目中保持团队代码风格一致即可。

---

### JOIN 之后仍然可以使用 WHERE

连接两张表之后，前面学过的过滤语法依然有效。

例如，只查询最近一段时间发布的文章及其作者：

```sql
SELECT
    u.name,
    p.title,
    u.id,
    p.user_id,
    p.created_at
FROM posts p
INNER JOIN users u
    ON p.user_id = u.id
WHERE p.created_at > NOW() - INTERVAL '395 days';
```

这里新增的条件：

```sql
p.created_at > NOW() - INTERVAL '395 days'
```

表示只保留创建时间晚于当前时间往前 395 天的文章。

注意，这里的 `created_at` 属于 `posts`，因此使用 `p.created_at` 明确指定来源。

JOIN 和 WHERE 可以配合使用：先根据连接条件关联两张表，再通过过滤条件进一步缩小查询结果。

---

## 本节重点回顾

| 知识点            | 核心内容                         |
| ----------------- | -------------------------------- |
| Primary Key（PK） | 唯一标识表中的一条记录           |
| Foreign Key（FK） | 保存关联表主键值的字段           |
| `JOIN`            | 连接多张表                       |
| `INNER JOIN`      | 只返回连接条件匹配成功的记录     |
| `ON`              | 指定两张表之间的连接条件         |
| `table.column`    | 明确指定字段所属的表             |
| `AS` / Alias      | 为表或字段设置别名               |
| `WHERE`           | 对连接后的查询结果进行进一步过滤 |

**本节需要建立的核心认识：**

1. 数据库通常将不同类型的数据保存在不同的表中，**通过主键和外键建立关联**。
2. `INNER JOIN` 根据 `ON` 条件匹配两张表，只保留能够匹配的记录组合。
3. 多表查询时要注意字段歧义，使用表名前缀或别名明确字段来源。
4. JOIN 不会取代之前学习的查询能力，`WHERE`、聚合函数等仍然可以与 JOIN 组合使用。

**知识衔接：** 本节学习的是 `INNER JOIN`，它只保留匹配成功的部分。接下来学习其他 JOIN 类型时，可以继续沿用主键、外键和 `ON` 的概念，重点关注不同连接类型如何处理未匹配的记录。