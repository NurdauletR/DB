--Lab5
--Part 1
CREATE TABLE employees (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CHECK (salary > 0)
);

CREATE TABLE products_catalog (
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0 AND
        discount_price > 0 AND
        discount_price < regular_price
    )
);

CREATE TABLE products_catalog (
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0 AND
        discount_price > 0 AND
        discount_price < regular_price
    )
);

INSERT INTO employees VALUES (1, 'John', 'Doe', 25, 50000);
INSERT INTO employees VALUES (2, 'Jane', 'Smith', 30, 60000);

INSERT INTO employees VALUES (3, 'Bob', 'Brown', 17, 40000);
INSERT INTO employees VALUES (4, 'Alice', 'Green', 28, -1000);

INSERT INTO products_catalog VALUES (1, 'Laptop', 1000, 800);
INSERT INTO products_catalog VALUES (2, 'Phone', 500, 450);

INSERT INTO products_catalog VALUES (3, 'Tablet', 0, 300);
INSERT INTO products_catalog VALUES (4, 'Monitor', 400, 500);

INSERT INTO bookings VALUES (1, '2024-01-01', '2024-01-05', 2);
INSERT INTO bookings VALUES (2, '2024-02-01', '2024-02-03', 4);

INSERT INTO bookings VALUES (3, '2024-03-01', '2024-02-28', 3);
INSERT INTO bookings VALUES (4, '2024-04-01', '2024-04-05', 0);


--Part 2
CREATE TABLE lab5_customers (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE lab5_inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

INSERT INTO lab5_customers VALUES (1, 'john@email.com', '123456789', '2024-01-15');
INSERT INTO lab5_customers VALUES (2, 'jane@email.com', NULL, '2024-02-20');

INSERT INTO lab5_customers VALUES (3, NULL, '987654321', '2024-03-10');
INSERT INTO lab5_customers VALUES (NULL, 'bob@email.com', '555555555', '2024-04-05');

INSERT INTO lab5_inventory VALUES (1, 'Laptop', 10, 999.99, '2024-01-01 10:00:00');
INSERT INTO lab5_inventory VALUES (2, 'Mouse', 25, 29.99, '2024-01-02 14:30:00');

INSERT INTO lab5_inventory VALUES (3, NULL, 15, 49.99, '2024-01-03 09:15:00');
INSERT INTO lab5_inventory VALUES (4, 'Keyboard', -5, 79.99, '2024-01-04 16:45:00');


--Part 3
CREATE TABLE lab5_users (
    user_id INTEGER,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP
);

CREATE TABLE lab5_course_enrollments (
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    UNIQUE (student_id, course_code, semester)
);

CREATE TABLE lab5_users_named (
    user_id INTEGER,
    username TEXT,
    email TEXT,
    created_at TIMESTAMP,
    CONSTRAINT unique_username UNIQUE (username),
    CONSTRAINT unique_email UNIQUE (email)
);

INSERT INTO lab5_users_named VALUES (1, 'john_doe', 'john@email.com', '2024-01-01');
INSERT INTO lab5_users_named VALUES (2, 'jane_smith', 'jane@email.com', '2024-01-02');

INSERT INTO lab5_users_named VALUES (3, 'john_doe', 'bob@email.com', '2024-01-03');
INSERT INTO lab5_users_named VALUES (4, 'alice_brown', 'john@email.com', '2024-01-04');


--Part 4
CREATE TABLE lab5_departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO lab5_departments VALUES (1, 'IT', 'New York');
INSERT INTO lab5_departments VALUES (2, 'HR', 'Boston');
INSERT INTO lab5_departments VALUES (3, 'Finance', 'Chicago');

INSERT INTO lab5_departments VALUES (1, 'Marketing', 'LA');
INSERT INTO lab5_departments VALUES (NULL, 'Sales', 'Miami');

CREATE TABLE lab5_student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);

CREATE TABLE lab5_comparison_exercise (
    id INTEGER PRIMARY KEY,
    question TEXT,
    answer TEXT
);

INSERT INTO lab5_comparison_exercise VALUES
(1, 'Difference between UNIQUE and PRIMARY KEY', 'PRIMARY KEY is UNIQUE + NOT NULL, only one PK per table'),
(2, 'Single-column vs composite PRIMARY KEY', 'Use composite when single column cannot uniquely identify records'),
(3, 'Why one PRIMARY KEY but multiple UNIQUE', 'PK defines main identity, UNIQUE ensures data integrity for other columns');


--Part 5
CREATE TABLE lab5_employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES lab5_departments(dept_id),
    hire_date DATE
);

INSERT INTO lab5_employees_dept VALUES (1, 'John Smith', 1, '2024-01-15');
INSERT INTO lab5_employees_dept VALUES (2, 'Jane Doe', 2, '2024-02-20');

INSERT INTO lab5_employees_dept VALUES (3, 'Bob Brown', 5, '2024-03-10');

CREATE TABLE lab5_authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE lab5_publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE lab5_books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES lab5_authors(author_id),
    publisher_id INTEGER REFERENCES lab5_publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

INSERT INTO lab5_authors VALUES (1, 'Stephen King', 'USA');
INSERT INTO lab5_authors VALUES (2, 'J.K. Rowling', 'UK');

INSERT INTO lab5_publishers VALUES (1, 'Penguin Books', 'New York');
INSERT INTO lab5_publishers VALUES (2, 'Bloomsbury', 'London');

INSERT INTO lab5_books VALUES (1, 'The Shining', 1, 1, 1977, '978-0385121675');
INSERT INTO lab5_books VALUES (2, 'Harry Potter', 2, 2, 1997, '978-0439708180');

CREATE TABLE lab5_categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE lab5_products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES lab5_categories ON DELETE RESTRICT
);

CREATE TABLE lab5_orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE lab5_order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES lab5_orders ON DELETE CASCADE,
    product_id INTEGER REFERENCES lab5_products_fk,
    quantity INTEGER CHECK (quantity > 0)
);

INSERT INTO lab5_categories VALUES (1, 'Electronics');
INSERT INTO lab5_categories VALUES (2, 'Books');

INSERT INTO lab5_products_fk VALUES (1, 'Laptop', 1);
INSERT INTO lab5_products_fk VALUES (2, 'Novel', 2);

INSERT INTO lab5_orders VALUES (1, '2024-01-15');
INSERT INTO lab5_orders VALUES (2, '2024-01-16');

INSERT INTO lab5_order_items VALUES (1, 1, 1, 2);
INSERT INTO lab5_order_items VALUES (2, 1, 2, 1);

DELETE FROM lab5_categories WHERE category_id = 1;
DELETE FROM lab5_orders WHERE order_id = 1;


--Part 6
CREATE TABLE lab5_customers_eco (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE lab5_products_eco (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC CHECK (price >= 0),
    stock_quantity INTEGER CHECK (stock_quantity >= 0)
);

CREATE TABLE lab5_orders_eco (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES lab5_customers_eco(customer_id),
    order_date DATE NOT NULL,
    total_amount NUMERIC CHECK (total_amount >= 0),
    status TEXT CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);

CREATE TABLE lab5_order_details_eco (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES lab5_orders_eco ON DELETE CASCADE,
    product_id INTEGER REFERENCES lab5_products_eco,
    quantity INTEGER CHECK (quantity > 0),
    unit_price NUMERIC CHECK (unit_price >= 0)
);

INSERT INTO lab5_customers_eco VALUES
(1, 'John Smith', 'john@email.com', '123-456-7890', '2024-01-15'),
(2, 'Jane Doe', 'jane@email.com', '123-456-7891', '2024-01-16'),
(3, 'Bob Johnson', 'bob@email.com', '123-456-7892', '2024-01-17'),
(4, 'Alice Brown', 'alice@email.com', '123-456-7893', '2024-01-18'),
(5, 'Charlie Wilson', 'charlie@email.com', '123-456-7894', '2024-01-19');

INSERT INTO lab5_products_eco VALUES
(1, 'Laptop', 'Gaming laptop', 999.99, 10),
(2, 'Mouse', 'Wireless mouse', 29.99, 50),
(3, 'Keyboard', 'Mechanical keyboard', 79.99, 25),
(4, 'Monitor', '27 inch monitor', 299.99, 15),
(5, 'Headphones', 'Noise cancelling', 199.99, 30);

INSERT INTO lab5_orders_eco VALUES
(1, 1, '2024-01-20', 1029.98, 'processing'),
(2, 2, '2024-01-21', 29.99, 'shipped'),
(3, 3, '2024-01-22', 379.98, 'delivered'),
(4, 4, '2024-01-23', 199.99, 'pending'),
(5, 5, '2024-01-24', 1299.97, 'processing');

INSERT INTO lab5_order_details_eco VALUES
(1, 1, 1, 1, 999.99),
(2, 1, 2, 1, 29.99),
(3, 2, 2, 1, 29.99),
(4, 3, 3, 1, 79.99),
(5, 3, 4, 1, 299.99),
(6, 4, 5, 1, 199.99),
(7, 5, 1, 1, 999.99),
(8, 5, 4, 1, 299.99);

INSERT INTO lab5_customers_eco VALUES (6, 'Test', NULL, '123-456-7895', '2024-01-25');
INSERT INTO lab5_products_eco VALUES (6, 'Test Product', 'Desc', -10, 5);
INSERT INTO lab5_orders_eco VALUES (6, 1, '2024-01-25', 100, 'invalid_status');
INSERT INTO lab5_order_details_eco VALUES (9, 1, 1, 0, 50);