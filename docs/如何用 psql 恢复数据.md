## 如何用 psql 恢复数据

这份文件其实只有 **345 条** `INSERT` 语句（`users` 75 条、`posts` 150 条、`customers` 50 条、`orders` 30 条、`current_employees` 25 条、`former_employees` 15 条）。

如果执行时觉得慢，核心瓶颈不是数据量大，而是**文件没有包裹事务（`BEGIN; ... COMMIT;`）**——默认自动提交模式下，每一条 `INSERT` 都会触发一次网络往返和一次磁盘 WAL 刷盘（fsync）；连远程数据库时，345 次往返就会拖成几十秒。

### 1. 用单个事务包裹执行（最省事，提速最明显）

将所有语句合并为一次提交，把 345 次磁盘刷盘降为 1 次：

- **命令行（`psql`）**：直接加 `-1`（`--single-transaction`）参数：

  ```bash
  psql -1 -U postgres -d your_db_name -f series03-final-inserts.sql
  ```

- **图形界面（pgAdmin / DBeaver / TablePlus）**：在文件最开头加上 `BEGIN;`，最末尾加上 `COMMIT;`，然后全选执行。

### 2. 使用 `COPY` 命令（PostgreSQL 写入天花板）

`COPY` 绕过了 SQL 解析器和逐行插入开销，适合大批量数据导入（速度通常是逐条 `INSERT` 的 10~50 倍）。你上一轮提到的 `03-pg-dump` 备份文件，内部默认就是用 `COPY` 来恢复数据的。如果你有 CSV 数据，也可以直接执行：

```sql
COPY users (id, name, email, created_at, updated_at)
FROM '/path/to/users.csv' WITH (FORMAT csv, HEADER true);
```

### 3. 合并为多值 `INSERT`（Multi-row INSERT）

把多条单行语句合并成一条多值语句，大幅减少 SQL 解析和网络往返：

```sql
INSERT INTO users (id, name, email, created_at, updated_at) VALUES
  ('1', 'Yesenia Schroeder', 'domenick20@example.net', '2025-02-16 22:52:46', '2025-11-29 05:23:46'),
  ('2', 'Aurelie Denesik',    'jerod72@example.net',    '2025-05-05 04:08:32', '2025-11-29 05:23:46');
```

> 注：通常每批合并 500~1000 行效果最佳。

### 4. 导入百万级数据时的进阶手段

- **后置索引与约束**：先插数据，再建主键、唯一索引和外键（你这份文件**已经**把 `PRIMARY KEY`、`UNIQUE` 和 `FOREIGN KEY` 放在了文件末尾，本身就符合这个最佳实践）。
- **临时关闭同步刷盘**：导入练习数据或可重跑的离线数据时，在当前会话执行 `SET synchronous_commit = off;` 可进一步减少磁盘等待。
