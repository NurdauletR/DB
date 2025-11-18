--Part1
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id INT,
    salary DECIMAL(10,2),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

CREATE TABLE projects (
    proj_id INT PRIMARY KEY,
    proj_name VARCHAR(100),
    budget DECIMAL(12,2),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

INSERT INTO departments VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Operations', 'Building C');

INSERT INTO employees VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 101, 55000),
(3, 'Mike Johnson', 102, 48000),
(4, 'Sarah Williams', 102, 52000),
(5, 'Tom Brown', 103, 60000);

INSERT INTO projects VALUES
(201, 'Website Redesign', 75000, 101),
(202, 'Database Migration', 120000, 101),
(203, 'HR System Upgrade', 50000, 102);


--Part2
-- Exercise 2.1: Create a Simple B-tree Index
CREATE INDEX emp_salary_idx ON employees(salary);

-- Verify the index was created
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';
-- Question: How many indexes exist on the employees table? (Hint: PRIMARY KEY creates an automatic index)
-- Answer: 2 indexes - employees_pkey (automatic PRIMARY KEY index) and emp_salary_idx (the one we just created)

-- Exercise 2.2: Create an Index on a Foreign Key
CREATE INDEX emp_dept_idx ON employees(dept_id);

-- Test the index usage
SELECT * FROM employees WHERE dept_id = 101;
-- Question: Why is it beneficial to index foreign key columns?
-- Answer: It improves JOIN performance between tables and speeds up queries filtering by foreign key columns

-- Exercise 2.3: View Index Information
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
-- Question: List all the indexes you see. Which ones were created automatically?
-- Answer: departments_pkey, employees_pkey, projects_pkey (automatic PRIMARY KEY indexes), emp_dept_idx, emp_salary_idx (manual indexes)


--Part3
-- Part 3: Multicolumn Indexes

-- Exercise 3.1: Create a Multicolumn Index
CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);

-- Test the multicolumn index
SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;
-- Question: Would this index be useful for a query that only filters by salary (without dept_id)? Why or why not?
-- Answer: No, this index would NOT be useful for a query that only filters by salary because multicolumn indexes follow left-to-right ordering.
-- The index is organized by dept_id first, then salary, so it cannot efficiently search by salary alone.

-- Exercise 3.2: Understanding Column Order
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);

-- Compare with queries
-- Query 1: Filters by dept_id first
SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;

-- Query 2: Filters by salary first
SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;
-- Question: Does the order of columns in a multicolumn index matter? Explain.
-- Answer: Yes, the order of columns in a multicolumn index matters significantly.
-- The index can only be used efficiently when the query includes the leftmost columns in the index.
-- emp_dept_salary_idx works best for dept_id queries, while emp_salary_dept_idx works best for salary queries.


--Part4
-- Part 4: Unique Indexes

-- Exercise 4.1: Create a Unique Index
-- First, add a new column for employee email
ALTER TABLE employees ADD COLUMN email VARCHAR(100);

UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

-- Now create a unique index on the email column
CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

-- Test the uniqueness constraint
INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');
-- Question: What error message did you receive?
-- Answer: ERROR: duplicate key value violates unique constraint "emp_email_unique_idx"
-- Detail: Key (email)=(john.smith@company.com) already exists.

-- Exercise 4.2: Unique Index vs UNIQUE Constraint
-- Add a phone column with UNIQUE constraint
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;

-- View the indexes
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';
-- Question: Did PostgreSQL automatically create an index? What type of index?
-- Answer: Yes, PostgreSQL automatically created a unique B-tree index when we added the UNIQUE constraint
-- The index name will be something like employees_phone_key and it's a B-tree index


--Part5
-- Part 5: Indexes and Sorting

-- Exercise 5.1: Create an Index for Sorting
-- Create an index optimized for descending salary queries
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);

-- Test with an ORDER BY query
SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;
-- Question: How does this index help with ORDER BY queries?
-- Answer: This DESC index stores data in descending order, so when we query with ORDER BY salary DESC,
-- PostgreSQL can read the data directly in the required order without performing a separate sorting step.

-- Exercise 5.2: Index with NULL Handling
-- Create an index that handles NULL values specially
CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);

-- Test the index
SELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;
-- This index helps when we want NULL values to appear first in sorted results,
-- optimizing queries that specifically use NULLS FIRST ordering


--Part6
-- Part 6: Indexes on Expressions

-- Exercise 6.1: Create a Function-Based Index
-- Create an index for case-insensitive employee name searches
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));

-- Test the expression index
SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';
-- Question: Without this index, how would PostgreSQL search for names case-insensitively?
-- Answer: Without this index, PostgreSQL would have to perform a full table scan (sequential scan)
-- and apply the LOWER() function to every row, which is much slower on large tables.

-- Exercise 6.2: Index on Calculated Values
-- Add a hire_date column and create an index on the year
ALTER TABLE employees ADD COLUMN hire_date DATE;

UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

-- Create index on the year extracted from hire_date
CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));

-- Test the index
SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;
-- This index allows efficient searching by year without having to scan and calculate for every row


--Part7
-- Part 7: Managing Indexes

-- Exercise 7.1: Rename an Index
-- Rename the emp_salary_idx index to employees_salary_index
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;

-- Verify the rename
SELECT indexname FROM pg_indexes WHERE tablename = 'employees';
-- The index name should now be 'employees_salary_index' instead of 'emp_salary_idx'

-- Exercise 7.2: Drop Unused Indexes
-- Drop the redundant multicolumn index we created earlier
DROP INDEX emp_salary_dept_idx;
-- Question: Why might you want to drop an index?
-- Answer: We might want to drop an index to free up disk space, reduce write overhead (INSERT/UPDATE/DELETE operations become slower with more indexes),
-- or remove redundant/unused indexes that don't improve query performance.

-- Exercise 7.3: Reindex
-- Rebuild an index to optimize its structure
REINDEX INDEX employees_salary_index;
-- When is REINDEX useful?
-- Answer: REINDEX is useful after bulk INSERT operations, when an index becomes bloated/fragmented,
-- or after significant data modifications to improve performance and reclaim space.


--Part8
-- Part 8: Practical Scenarios

-- Exercise 8.1: Optimize a Slow Query
-- Consider this query that runs frequently:
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

-- Create indexes to optimize this query:
-- Index for the WHERE clause (partial index for high salaries)
CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;
-- Index for the JOIN (already created: emp_dept_idx)
-- Index for ORDER BY (already created: emp_salary_desc_idx)

-- Exercise 8.2: Partial Index
-- Create an index only for high-budget projects (budget > 80000)
CREATE INDEX proj_high_budget_idx ON projects(budget)
WHERE budget > 80000;

-- Test the partial index
SELECT proj_name, budget
FROM projects
WHERE budget > 80000;
-- Question: What's the advantage of a partial index compared to a regular index?
-- Answer: Partial indexes are smaller (less disk space), faster to maintain (only updated when relevant rows change),
-- and more efficient for queries that only access the filtered subset of data.

-- Exercise 8.3: Analyze Index Usage
-- Use EXPLAIN to see if indexes are being used
EXPLAIN SELECT * FROM employees WHERE salary > 52000;
-- Question: Does the output show an "Index Scan" or a "Seq Scan" (Sequential Scan)? What does this tell you?
-- Answer: It should show "Index Scan" using one of our salary indexes, which tells us that PostgreSQL is using the index
-- to efficiently find the rows instead of scanning the entire table.


--Part9
-- Part 9: Index Types Comparison

-- Exercise 9.1: Create a Hash Index
-- Create a hash index on department name
CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);

-- Test the hash index
SELECT * FROM departments WHERE dept_name = 'IT';
-- Question: When should you use a HASH index instead of a B-tree index?
-- Answer: Use HASH indexes only for simple equality comparisons (=), as they are faster than B-tree for exact matches
-- but don't support range queries, sorting, or pattern matching. B-tree is more versatile and is the default choice.

-- Exercise 9.2: Compare Index Types
-- Create both B-tree and Hash indexes on the project name
-- B-tree index
CREATE INDEX proj_name_btree_idx ON projects(proj_name);

-- Hash index
CREATE INDEX proj_name_hash_idx ON projects USING HASH (proj_name);

-- Test with different queries
-- Equality search (both can be used)
SELECT * FROM projects WHERE proj_name = 'Website Redesign';

-- Range search (only B-tree can be used)
SELECT * FROM projects WHERE proj_name > 'Database';
-- Hash indexes cannot be used for range queries - only B-tree indexes support <, >, BETWEEN operations


--Part10
-- Part 10: Cleanup and Best Practices

-- Exercise 10.1: Review All Indexes
-- List all indexes and their sizes
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
-- Question: Which index is the largest? Why?
-- Answer: The largest index is typically the one on the largest table or the one with the most columns. 
-- In our case, it might be one of the multicolumn indexes or the table with the most data.

-- Exercise 10.2: Drop Unnecessary Indexes
-- Drop the duplicate expression indexes
DROP INDEX IF EXISTS proj_name_hash_idx;
-- Keep only necessary indexes
-- We're removing the hash index since B-tree is more versatile for most use cases

-- Exercise 10.3: Document Your Indexes
-- Create a view that documents all custom indexes
CREATE VIEW index_documentation AS
SELECT
  tablename,
  indexname,
  indexdef,
  'Improves salary-based queries' as purpose
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE '%salary%';

SELECT * FROM index_documentation;

-- Summary Questions
-- 1. What is the default index type in PostgreSQL?
-- Answer: B-tree is the default index type in PostgreSQL.

-- 2. Name three scenarios where you should create an index:
-- Answer: 
--   1. Columns frequently used in WHERE clauses
--   2. Foreign key columns for JOIN performance
--   3. Columns used in ORDER BY clauses

-- 3. Name two scenarios where you should NOT create an index:
-- Answer:
--   1. On tables with frequent write operations (INSERT/UPDATE/DELETE)
--   2. On columns with low cardinality (few unique values)

-- 4. What happens to indexes when you INSERT, UPDATE, or DELETE data?
-- Answer: Indexes must be updated along with the table data, which slows down write operations.

-- 5. How can you check if a query is using an index?
-- Answer: Use the EXPLAIN command before the query to see the execution plan and check for "Index Scan".

-- Best Practices Checklist (for reference):
-- - Index columns used frequently in WHERE clauses
-- - Index foreign key columns
-- - Index columns used in JOIN conditions
-- - Index columns used in ORDER BY
-- - Don't over-index (indexes have overhead)
-- - Consider multicolumn indexes for queries with multiple filters
-- - Use partial indexes for frequently queried subsets
-- - Regularly analyze and remove unused indexes
-- - Use EXPLAIN to verify index usage
-- - Consider expression indexes for computed values
