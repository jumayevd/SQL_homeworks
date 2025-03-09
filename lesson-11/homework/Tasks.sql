-- ==============================================================
--                          Puzzle 1 DDL                         
-- ==============================================================

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(50),
    Department VARCHAR(50),
    Salary DECIMAL(10,2)
);

INSERT INTO Employees (EmployeeID, Name, Department, Salary)
VALUES
    (1, 'Alice', 'HR', 5000),
    (2, 'Bob', 'IT', 7000),
    (3, 'Charlie', 'Sales', 6000),
    (4, 'David', 'HR', 5500),
    (5, 'Emma', 'IT', 7200);


-- ==============================================================
--                          Puzzle 2 DDL
-- ==============================================================

CREATE TABLE Orders_DB1 (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(50),
    Product VARCHAR(50),
    Quantity INT
);

INSERT INTO Orders_DB1 VALUES
(101, 'Alice', 'Laptop', 1),
(102, 'Bob', 'Phone', 2),
(103, 'Charlie', 'Tablet', 1),
(104, 'David', 'Monitor', 1);

CREATE TABLE Orders_DB2 (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(50),
    Product VARCHAR(50),
    Quantity INT
);

INSERT INTO Orders_DB2 VALUES
(101, 'Alice', 'Laptop', 1),
(103, 'Charlie', 'Tablet', 1);


-- ==============================================================
--                          Puzzle 3 DDL
-- ==============================================================

CREATE TABLE WorkLog (
    EmployeeID INT,
    EmployeeName VARCHAR(50),
    Department VARCHAR(50),
    WorkDate DATE,
    HoursWorked INT
);

INSERT INTO WorkLog VALUES
(1, 'Alice', 'HR', '2024-03-01', 8),
(2, 'Bob', 'IT', '2024-03-01', 9),
(3, 'Charlie', 'Sales', '2024-03-02', 7),
(1, 'Alice', 'HR', '2024-03-03', 6),
(2, 'Bob', 'IT', '2024-03-03', 8),
(3, 'Charlie', 'Sales', '2024-03-04', 9);



-- SOLUTIONS

-- ==============================================
-- PUZZLE 1: Employee Rotational Transfer
-- ==============================================

-- Create the temporary table to store the updated employee records
CREATE TABLE #EmployeeTransfers (
    EmployeeID INT,
    Name VARCHAR(100),
    Department VARCHAR(50),
    Salary INT
);

-- Insert employees with their new department assignments
INSERT INTO #EmployeeTransfers (EmployeeID, Name, Department, Salary)
SELECT 
    EmployeeID,
    Name,
    -- Shift departments in a circular manner:
    -- HR → IT → Sales → HR
    CASE 
        WHEN Department = 'HR' THEN 'IT'
        WHEN Department = 'IT' THEN 'Sales'
        WHEN Department = 'Sales' THEN 'HR'
    END AS Department,
    Salary
FROM Employees;

-- Retrieve the updated records to verify department changes
SELECT * FROM #EmployeeTransfers;

-- Drop the temporary table to free memory (temporary tables are session-based)
DROP TABLE #EmployeeTransfers;

-- ==============================================
-- PUZZLE 2: Find Missing Orders
-- ==============================================

-- Declare a table variable to store missing orders from Orders_DB1 that are not in Orders_DB2
DECLARE @MissingOrders TABLE (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100),
    Quantity INT
);

-- Insert missing orders (orders that exist in Orders_DB1 but are absent in Orders_DB2)
INSERT INTO @MissingOrders
SELECT o1.OrderID, o1.CustomerName, o1.Product, o1.Quantity
FROM Orders_DB1 o1
-- Use LEFT JOIN to retain all orders from Orders_DB1 and check if they exist in Orders_DB2
LEFT JOIN Orders_DB2 o2 ON o1.OrderID = o2.OrderID
-- Only include orders that have no match in Orders_DB2 (i.e., missing orders)
WHERE o2.OrderID IS NULL;

-- Retrieve and display missing orders for validation
SELECT * FROM @MissingOrders;

-- ==============================================
-- PUZZLE 3: Monthly Employee Work Summary Report
-- ==============================================
GO
-- Create a view to generate the monthly work summary report
CREATE VIEW vw_MonthlyWorkSummary AS
SELECT 
    e.EmployeeID,             -- Unique identifier for each employee
    e.EmployeeName,           -- Employee's name
    d.Department,             -- Department name from department summary
    e.TotalHoursWorked,       -- Total hours worked by each employee
    d.TotalHoursDepartment,   -- Total hours worked by all employees in the department
    d.AvgHoursDepartment      -- Average hours worked per department
FROM 
    -- Subquery: Calculate total hours worked per employee
    (SELECT 
         EmployeeID,
         EmployeeName,
         Department,
         SUM(HoursWorked) AS TotalHoursWorked -- Sum up hours for each employee
     FROM 
         WorkLog
     GROUP BY 
         EmployeeID, EmployeeName, Department) e
-- Join with department-level work summary
JOIN 
    (SELECT 
         Department,
         SUM(HoursWorked) AS TotalHoursDepartment, -- Total hours worked in the department
         AVG(HoursWorked) AS AvgHoursDepartment   -- Average hours worked per employee in the department
     FROM 
         WorkLog
     GROUP BY 
         Department) d
ON 
    e.Department = d.Department; -- Join based on department

GO
-- Retrieve all records from the view for analysis
SELECT * FROM vw_MonthlyWorkSummary;
