--Part A
CREATE DATABASE advanced_lab;
\c advanced_lab;

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50),
    budget INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER
);



--Part B
INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (1, 'John', 'Doe', 'IT');

INSERT INTO employees (first_name, last_name, department, hire_date)
VALUES ('Jane', 'Smith', 'HR', CURRENT_DATE);

INSERT INTO departments (dept_name, budget, manager_id)
VALUES
    ('IT', 100000, 1),
    ('HR', 80000, 2),
    ('Finance', 120000, 3);

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Mike', 'Johnson', 'Finance', 50000 * 1.1, CURRENT_DATE);

CREATE TABLE temp_employees AS
SELECT * FROM employees WHERE department = 'IT';


--Part C
UPDATE employees SET salary = salary * 1.10;

UPDATE employees SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';

UPDATE employees SET department =
    CASE
        WHEN salary > 80000 THEN 'Management'
        WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
        ELSE 'Junior'
    END;

UPDATE employees SET department = DEFAULT
WHERE status = 'Inactive';

UPDATE departments
SET budget = (
    SELECT AVG(salary) * 1.20
    FROM employees
    WHERE employees.department = departments.dept_name
);

UPDATE employees
SET salary = salary * 1.15, status = 'Promoted'
WHERE department = 'Sales';


--Part D
DELETE FROM employees WHERE status = 'Terminated';

DELETE FROM employees
WHERE salary < 40000 AND hire_date > '2023-01-01' AND department IS NULL;

DELETE FROM departments
WHERE dept_id NOT IN (
    SELECT DISTINCT dept_id
    FROM employees
    WHERE dept_id IS NOT NULL
);

DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;


--Part E
INSERT INTO employees (first_name, last_name, salary, department)
VALUES ('Alex', 'Brown', NULL, NULL);

UPDATE employees SET department = 'Unassigned'
WHERE department IS NULL;

DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;


--Part F
INSERT INTO employees (first_name, last_name, department, salary)
VALUES ('Sarah', 'Wilson', 'IT', 55000)
RETURNING emp_id, first_name || ' ' || last_name AS full_name;

UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;

DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;


--Part G
INSERT INTO employees (first_name, last_name, department, salary)
SELECT 'Tom', 'Anderson', 'IT', 60000
WHERE NOT EXISTS (
    SELECT 1 FROM employees
    WHERE first_name = 'Tom' AND last_name = 'Anderson'
);

UPDATE employees
SET salary = CASE
    WHEN department IN (
        SELECT dept_name FROM departments WHERE budget > 100000
    ) THEN salary * 1.10
    ELSE salary * 1.05
END;

INSERT INTO employees (first_name, last_name, department, salary) VALUES
('Emma', 'Davis', 'IT', 52000),
('James', 'Miller', 'HR', 48000),
('Lisa', 'Wilson', 'Finance', 62000),
('Robert', 'Brown', 'IT', 58000),
('Maria', 'Garcia', 'HR', 51000);

UPDATE employees
SET salary = salary * 1.10
WHERE first_name IN ('Emma', 'James', 'Lisa', 'Robert', 'Maria');

CREATE TABLE employee_archive AS
SELECT * FROM employees WHERE status = 'Inactive';

DELETE FROM employees WHERE status = 'Inactive';

UPDATE projects
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000
AND dept_id IN (
    SELECT dept_id FROM employees
    GROUP BY dept_id
    HAVING COUNT(*) > 3
);