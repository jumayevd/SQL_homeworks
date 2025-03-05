
-- TASK 1

;WITH EmployeeHierarchy AS (
    -- Anchor member: Start with the President (depth = 0)
    SELECT 
        EmployeeID,
        ManagerID,
        JobTitle,
        0 AS Depth
    FROM 
        Employees
    WHERE 
        ManagerID IS NULL

    UNION ALL

    -- Recursive member: Join with the Employees table to find subordinates
    SELECT 
        e.EmployeeID,
        e.ManagerID,
        e.JobTitle,
        eh.Depth + 1 AS Depth
    FROM 
        Employees e
    INNER JOIN 
        EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
)
SELECT 
    EmployeeID,
    ManagerID,
    JobTitle,
    Depth
FROM 
    EmployeeHierarchy
ORDER BY 
    EmployeeID;



-- TASK 2

DECLARE @n INT = 10; -- Set the value of n here

WITH Factorials AS (
    -- Anchor member: Start with 1! = 1
    SELECT 
        1 AS Num,
        1 AS Factorial

    UNION ALL

    -- Recursive member: Calculate factorial for the next number
    SELECT 
        Num + 1 AS ordinal,
        Factorial * (Num + 1) AS Factorial
    FROM 
        Factorials
    WHERE 
        Num < @n -- Stop after calculating n!
)
SELECT * FROM Factorials
OPTION (MAXRECURSION 0); -- Allow unlimited recursion depth


-- TASK 3

DECLARE @N3 INT = 10; -- Set the value of N here

;WITH cte AS (
    -- Anchor member: Start with the first two Fibonacci numbers
    SELECT 
        1 AS n,
        1 AS Fibonacci_Number,
        0 AS fib2

    UNION ALL

    -- Recursive member: Calculate the next Fibonacci number
    SELECT 
        n + 1 AS n,
        Fibonacci_Number + fib2 AS Fibonacci_Number, 
        Fibonacci_Number AS fib2 -- Update fib2 to the previous Fibonacci_Number
    FROM 
        cte
    WHERE 
        n < @N3 -- Stop after reaching N
)
SELECT n, Fibonacci_Number
FROM cte
OPTION (MAXRECURSION 0); -- Allow unlimited recursion depth