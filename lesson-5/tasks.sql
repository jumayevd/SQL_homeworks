CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Department VARCHAR(50) NOT NULL,
    Salary DECIMAL(10,2) NOT NULL,
    HireDate DATE NOT NULL
);

INSERT INTO Employees (Name, Department, Salary, HireDate) VALUES
    ('Alice', 'HR', 50000, '2020-06-15'),
    ('Bob', 'HR', 60000, '2018-09-10'),
    ('Charlie', 'IT', 70000, '2019-03-05'),
    ('David', 'IT', 80000, '2021-07-22'),
    ('Eve', 'Finance', 90000, '2017-11-30'),
    ('Frank', 'Finance', 75000, '2019-12-25'),
    ('Grace', 'Marketing', 65000, '2016-05-14'),
    ('Hank', 'Marketing', 72000, '2019-10-08'),
    ('Ivy', 'IT', 67000, '2022-01-12'),
    ('Jack', 'HR', 52000, '2021-03-29');


-- Assign a Unique Rank to Each Employee Based on Salary
SELECT 
    EmployeeID, 
    Name, 
    Salary, 
    DENSE_RANK() OVER (ORDER BY Salary DESC) AS SalaryRank
FROM 
    Employees;

-- Find Employees Who Have the Same Salary Rank
WITH RankedEmployees AS (
    SELECT 
        EmployeeID, 
        Name, 
        Salary, 
        DENSE_RANK() OVER (ORDER BY Salary DESC) AS SalaryRank
    FROM 
        Employees
)
SELECT 
    SalaryRank, 
    COUNT(EmployeeID) AS NumberOfEmployees
FROM 
    RankedEmployees
GROUP BY 
    SalaryRank
HAVING 
    COUNT(EmployeeID) > 1;

-- Identify the Top 2 Highest Salaries in Each Department
WITH RankedSalaries AS (
    SELECT 
        EmployeeID, 
        Name, 
        Department, 
        Salary, 
        DENSE_RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS SalaryRank
    FROM 
        Employees
)
SELECT 
    EmployeeID, 
    Name, 
    Department, 
    Salary
FROM 
    RankedSalaries
WHERE 
    SalaryRank <= 2;

-- Find the Lowest-Paid Employee in Each Department
WITH LowestPaid AS (
    SELECT 
        EmployeeID, 
        Name, 
        Department, 
        Salary, 
        ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Salary ASC) AS RowNum
    FROM 
        Employees
)
SELECT 
    EmployeeID, 
    Name, 
    Department, 
    Salary
FROM 
    LowestPaid
WHERE 
    RowNum = 1;

-- Calculate the Running Total of Salaries in Each Department
SELECT 
    EmployeeID, 
    Name, 
    Department, 
    Salary, 
    SUM(Salary) OVER (PARTITION BY Department ORDER BY HireDate ROWS UNBOUNDED PRECEDING) AS RunningTotal
FROM 
    Employees;

-- Find the Total Salary of Each Department Without GROUP BY
SELECT DISTINCT
    Department, 
    SUM(Salary) OVER (PARTITION BY Department) AS TotalSalary
FROM 
    Employees;

-- Calculate the Average Salary in Each Department Without GROUP BY
SELECT DISTINCT
    Department,
    CAST(AVG(Salary) OVER (PARTITION BY Department) AS DECIMAL(10, 2)) AS AvgSalary
FROM 
    Employees;

-- Find the Difference Between an Employee’s Salary and Their Department’s Average
SELECT 
    EmployeeID, 
    Name, 
    Department, 
    Salary, 
    CAST(Salary - AVG(Salary) OVER (PARTITION BY Department) AS DECIMAL(10, 2)) AS SalaryDifference
FROM 
    Employees;

-- Calculate the Moving Average Salary Over 3 Employees (Including Current, Previous, and Next)
SELECT 
    EmployeeID, 
    Name, 
    Salary, 
    CAST(AVG(Salary) OVER (ORDER BY EmployeeID ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS DECIMAL(10, 2)) AS MovingAvgSalary
FROM 
    Employees;

-- Find the Sum of Salaries for the Last 3 Hired Employees
WITH LastHired AS (
    SELECT 
        Salary,
        ROW_NUMBER() OVER (ORDER BY HireDate DESC) AS RowNum
    FROM 
        Employees
)
SELECT 
    SUM(Salary) AS SumLast3Salaries
FROM 
    LastHired
WHERE 
    RowNum <= 3;

-- Calculate the Running Average of Salaries Over All Previous Employees
SELECT 
    EmployeeID, 
    Name, 
    Salary, 
    CAST(AVG(Salary) OVER (ORDER BY HireDate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS DECIMAL(10, 2)) AS RunningAvgSalary
FROM 
    Employees;

-- Find the Maximum Salary Over a Sliding Window of 2 Employees Before and After
SELECT 
    EmployeeID, 
    Name, 
    Salary, 
    MAX(Salary) OVER (ORDER BY HireDate ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) AS MaxInWindow
FROM 
    Employees;

-- Determine the Percentage Contribution of Each Employee’s Salary to Their Department’s Total Salary
SELECT 
    EmployeeID, 
    Name, 
    Department, 
    Salary, 
    CAST((Salary * 100.0) / SUM(Salary) OVER (PARTITION BY Department) AS DECIMAL(10, 2)) AS SalaryPercentage
FROM 
    Employees;