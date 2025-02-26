
-- DDL
-- Create Departments Table (First to avoid FK issues)
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName NVARCHAR(50) NOT NULL
);

-- Insert into Departments
INSERT INTO Departments VALUES 
(101, 'IT'), 
(102, 'HR'), 
(103, 'Finance'), 
(104, 'Marketing');

-- Create Employees Table
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL,
    DepartmentID INT NULL,
    Salary INT NOT NULL,
    CONSTRAINT FK_Employees_Department FOREIGN KEY (DepartmentID) 
    REFERENCES Departments(DepartmentID) ON DELETE SET NULL
);

-- Insert into Employees
INSERT INTO Employees (Name, DepartmentID, Salary) VALUES 
('Alice', 101, 60000),
('Bob', 102, 70000),
('Charlie', 101, 65000),
('David', 103, 72000),
('Eva', NULL, 68000); -- Eva has no department

-- Create Projects Table
CREATE TABLE Projects (
    ProjectID INT PRIMARY KEY IDENTITY(1,1),
    ProjectName NVARCHAR(50) NOT NULL,
    EmployeeID INT NULL,
    CONSTRAINT FK_Projects_Employee FOREIGN KEY (EmployeeID) 
    REFERENCES Employees(EmployeeID) ON DELETE SET NULL
);

-- Insert into Projects
INSERT INTO Projects (ProjectName, EmployeeID) VALUES 
('Alpha', 1), 
('Beta', 2), 
('Gamma', 1), 
('Delta', 4), 
('Omega', NULL); -- No employee assigned to Omega


-- TASKS
-- INNER JOIN

SELECT e.EmployeeID, e.Name, d.DepartmentName, e.Salary
FROM Employees e
JOIN Departments d
ON e.DepartmentID = d.DepartmentID;

-- LEFT JOIN

SELECT e.EmployeeID, e.Name, COALESCE(d.DepartmentName, 'No Department') AS DepartmentName, e.Salary
FROM Employees e
LEFT JOIN Departments d ON e.DepartmentID = d.DepartmentID;


-- RIGHT JOIN

SELECT COALESCE(e.EmployeeID, 0) AS EmployeeID, 
       COALESCE(e.Name, 'No Employee') AS Name, 
       d.DepartmentName, 
       COALESCE(e.Salary, 0) AS Salary
FROM Employees e
RIGHT JOIN Departments d ON e.DepartmentID = d.DepartmentID;


-- FULL OUTER JOIN

SELECT COALESCE(e.EmployeeID, 0) AS EmployeeID, 
       COALESCE(e.Name, 'No Employee') AS Name, 
       COALESCE(d.DepartmentName, 'No Department') AS DepartmentName, 
       COALESCE(e.Salary, 0) AS Salary
FROM Employees e
FULL OUTER JOIN Departments d ON e.DepartmentID = d.DepartmentID;


-- JOIN with Aggregation

SELECT d.DepartmentName, 
       COALESCE(SUM(e.Salary), 0) AS TotalSalary
FROM Departments d
LEFT JOIN Employees e ON d.DepartmentID = e.DepartmentID
GROUP BY d.DepartmentName;


-- CROSS JOIN

SELECT d.DepartmentName, p.ProjectName
FROM Departments d
CROSS JOIN Projects p;

-- Sometimes better performance CROSS JOIN
SELECT d.DepartmentName, p.ProjectName
FROM Departments d, Projects p;


-- MULTIPLE JOINS

SELECT e.EmployeeID, e.Name, 
       COALESCE(d.DepartmentName, 'No Department') AS DepartmentName, 
       COALESCE(p.ProjectName, 'No Project') AS ProjectName
FROM Employees e
LEFT JOIN Departments d ON e.DepartmentID = d.DepartmentID
LEFT JOIN Projects p ON e.EmployeeID = p.EmployeeID;
