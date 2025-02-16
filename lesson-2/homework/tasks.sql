CREATE DATABASE lesson2;

USE lesson2;

--TASK 1

-- Creating the table with an IDENTITY column
CREATE TABLE test_identity (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(50)
);

-- Inserting 5 rows
INSERT INTO test_identity (name) 
VALUES ('Doniyor'), ('Ruxshona'), ('Muhammad'), ('Fotima'), ('Unknown');


-- Checking the data
SELECT * FROM test_identity;

-- DELETE some rows (Keep structure, identity continues)
DELETE FROM test_identity WHERE id > 2;

-- Inserting a new row to check
INSERT INTO test_identity (name) VALUES ('Frank');

-- Checking the data again
SELECT * FROM test_identity;

-- TRUNCATE the table (Removes all rows, resets identity)
TRUNCATE TABLE test_identity;

-- Inserting a new row to check
INSERT INTO test_identity (name) VALUES ('George');

-- Checking the data again
SELECT * FROM test_identity;

-- DROP the table (Completely removes table structure)
DROP TABLE test_identity;

-- Checking selecting data 
SELECT * FROM test_identity;

/* 
Main difference between DELETE, TRUNCATE and DROP keywords are 
	DELETE deletes some part of the data and keeps the structure, 
	TRUNCATE removes all the data and resets the identity,
	DROP completely removes the table structure 
*/



-- TASK 2

-- Creating the table with different data types
CREATE TABLE data_types_demo (
    id UNIQUEIDENTIFIER DEFAULT NEWID(),   
    tiny_int_col TINYINT,                  
    small_int_col SMALLINT,              
    int_col INT,                         
    big_int_col BIGINT,                   
    decimal_col DECIMAL(10,2),             
    float_col FLOAT,                       
    char_col CHAR(10),                      
    nchar_col NCHAR(10),                   
    varchar_col VARCHAR(50),             
    nvarchar_col NVARCHAR(50),              
    text_col TEXT,                         
    ntext_col NTEXT,                        
    date_col DATE,                          
    time_col TIME,                          
    datetime_col DATETIME,          
    varbinary_col VARBINARY(50)            
);

-- Inserting values into the table
INSERT INTO data_types_demo (
    tiny_int_col, small_int_col, int_col, big_int_col, decimal_col, float_col,
    char_col, nchar_col, varchar_col, nvarchar_col, text_col, ntext_col,
    date_col, time_col, datetime_col, varbinary_col
)
VALUES 
(
    255, 32767, 2147483647, 9223372036854775807, 12345.67, 3.14159,
    'A123456789', N'B123456789', 'Hello World!', N'Привет Мир!', 
    'This is a text', N'This is an ntext',
    '2025-02-15', '12:30:45', '2025-02-15 14:45:00', CONVERT(VARBINARY, 'Hello')
);

-- Displaying the values
SELECT * FROM data_types_demo;


-- TASK 3

-- Creating Table

CREATE TABLE photos (
	id INT PRIMARY KEY IDENTITY,
	image_data varbinary(MAX)
);

-- Insterting the Image Data
INSERT INTO photos (image_data)
SELECT BulkColumn 
FROM OPENROWSET(BULK 'C:\Users\user\Downloads\random_image.jpg', SINGLE_BLOB) AS img;


-- TASK 4

-- Creating the table 
CREATE TABLE student (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(50),
    classes INT,
    tuition_per_class DECIMAL(10,2),
    total_tuition AS (classes * tuition_per_class) PERSISTED
);

-- Inserting sample data
INSERT INTO student (name, classes, tuition_per_class) 
VALUES 
    ('Alice', 5, 100.50),
    ('Bob', 3, 200.75),
    ('Charlie', 4, 150.25);

-- Retrieving all data
SELECT * FROM student;


-- TASK 5

-- Creating the table 
CREATE TABLE worker (
    id INT PRIMARY KEY,
    name VARCHAR(50)
);

-- Importing the csv file into the table
BULK INSERT worker
FROM 'C:\BI-AI\SQL_Homeworks\lesson-2\homework\workers.csv'
WITH (
	FORMAT = 'CSV',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	TABLOCK
);

-- Verifying the imported data
SELECT * FROM worker;

