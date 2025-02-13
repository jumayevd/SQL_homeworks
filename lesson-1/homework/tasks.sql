-- NOT NULL Constraint
CREATE TABLE student (
	id INT, 
	name NVARCHAR(50),
	age INT);

ALTER TABLE student
ALTER COLUMN id INT NOT NULL;


--UNIQUE Constraint

CREATE TABLE product (
	product_id INT UNIQUE,
	product_name NVARCHAR,
	price DECIMAL(10,2),
	CONSTRAINT UQ_product_id UNIQUE (product_id)
);

ALTER TABLE product
DROP CONSTRAINT UQ_product_id; 

ALTER TABLE product
ADD CONSTRAINT UQ_product_id UNIQUE(product_id);

ALTER TABLE product
ADD CONSTRAINT UQ_product_id_product_name UNIQUE (product_id, product_name);

-- PRIMARY KEY Constraint

CREATE TABLE orders(
	order_id INT,
	customer_name NVARCHAR (50),
	order_date DATE,
	CONSTRAINT PK_orders PRIMARY KEY (order_id)
);

ALTER TABLE orders
DROP CONSTRAINT PK_orders;

ALTER TABLE orders
ADD CONSTRAINT PK_orders PRIMARY KEY (order_id);



--FOREIGN KEY Constraint

CREATE TABLE category (
	category_id INT PRIMARY KEY,
	category_name NVARCHAR(50)
);

CREATE TABLE item(
	item_id INT PRIMARY KEY,
	item_name NVARCHAR(50),
	category_id INT,
	CONSTRAINT FK_category_id FOREIGN KEY (category_id) REFERENCES category(category_id)
);

ALTER TABLE item
DROP CONSTRAINT FK_category_id;

ALTER TABLE item
ADD CONSTRAINT FK_category_id FOREIGN KEY (category_id) REFERENCES category(category_id);



--CHECK Constraint

CREATE TABLE account(
	account_id INT PRIMARY KEY,
	balance DECIMAL(10,2),
	account_type NVARCHAR(50),
	CONSTRAINT CK_balance CHECK (balance >= 0),
	CONSTRAINT CK_account_type CHECK (account_type IN ('Saving', 'Checking'))
);

ALTER TABLE account
DROP CONSTRAINT CK_balance;

ALTER TABLE account
DROP CONSTRAINT CK_account_type;



ALTER TABLE account
ADD CONSTRAINT CK_balance CHECK (balance >= 0),
	CONSTRAINT CK_account_type CHECK (account_type IN ('Saving', 'Checking'));



--DEFAULT Constraint

CREATE TABLE customer(
	customer_id INT PRIMARY KEY,
	name NVARCHAR(50),
	city NVARCHAR(50) CONSTRAINT DF_customer_city DEFAULT ('Unknown')
);

ALTER TABLE customer
DROP CONSTRAINT DF_customer_city

ALTER TABLE customer
ADD CONSTRAINT DF_customer_city DEFAULT ('Uknown') FOR city;



--IDENTITY Column

CREATE TABLE invoice(
	invoice_id INT IDENTITY (1, 1) PRIMARY KEY,
	amount DECIMAL(10, 2),
);

-- Inserting values
INSERT INTO invoice(amount) VALUES
	(100.50),
	(192.75),
	(205.50),
	(293.00),
	(106.25);

-- Handling IDENTITY_INSERT only when necessary
SET IDENTITY_INSERT invoice ON;
INSERT INTO invoice (invoice_id, amount) 
VALUES (100, 500.00); 
SET IDENTITY_INSERT invoice OFF;


--All at once

CREATE TABLE books(
	book_id INT PRIMARY KEY IDENTITY,
	title NVARCHAR(100) NOT NULL,
	price DECIMAL (10,2) CHECK (price > 0),
	genre NVARCHAR(50) DEFAULT 'Unknown'
);

-- Inserting sample records with valid data
INSERT INTO books (title, price, genre) VALUES
	('Book A', 15.99, 'Fiction'),  
	('Book B', 20.00, 'Non-Fiction'),    
	('Book E', 10.75, 'Science');


--Scenario: Library Management System

-- Creating the Book table
CREATE TABLE Book (
    book_id INT PRIMARY KEY,         
    title NVARCHAR(255) NOT NULL,     
    author NVARCHAR(255),            
    published_year INT           
);

-- Creating the Member table
CREATE TABLE Member (
    member_id INT PRIMARY KEY,        
    name NVARCHAR(255) NOT NULL,      
    email NVARCHAR(255) NOT NULL,     
    phone_number NVARCHAR(15)        
);

-- Creating the Loan table
CREATE TABLE Loan (
    loan_id INT PRIMARY KEY,       
    book_id INT,                      
    member_id INT,                    
    loan_date DATE NOT NULL,          
    return_date DATE,                
    FOREIGN KEY (book_id) REFERENCES Book(book_id), 
    FOREIGN KEY (member_id) REFERENCES Member(member_id)  
);


-- Inserting sample records into Book table
INSERT INTO Book (book_id, title, author, published_year) VALUES
    (1, 'The Great Gatsby', 'F. Scott Fitzgerald', 1925),
    (2, '1984', 'George Orwell', 1949),
    (3, 'To Kill a Mockingbird', 'Harper Lee', 1960);

-- Inserting sample records into Member table
INSERT INTO Member (member_id, name, email, phone_number) VALUES
    (1, 'Alice Johnson', 'alice@example.com', '555-1234'),
    (2, 'Bob Smith', 'bob@example.com', '555-5678'),
    (3, 'Charlie Brown', 'charlie@example.com', '555-9876');

-- Inserting sample records into Loan table
INSERT INTO Loan (loan_id, book_id, member_id, loan_date, return_date) VALUES
    (1, 1, 1, '2025-02-01', NULL),  
    (2, 2, 2, '2025-02-05', '2025-02-10'),  
    (3, 3, 3, '2025-02-07', NULL); 
