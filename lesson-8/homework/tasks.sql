
-- TASK 1

-- Select the minimum and maximum StepNumber for each consecutive group of Status
SELECT 
    MIN("StepNumber") AS "Min Step Number",  -- Find the first StepNumber in the consecutive sequence
    MAX("StepNumber") AS "Max Step Number",  -- Find the last StepNumber in the consecutive sequence
    Status,  -- The test case result (e.g., Passed or Failed)
    COUNT(*) AS "Consecutive Count"  -- Count the number of consecutive occurrences
FROM (
    -- Subquery: Create a grouping key for consecutive StepNumbers with the same Status
    SELECT 
        "StepNumber",
        Status,
        -- Generate a grouping key by subtracting the row number from the StepNumber
        -- This ensures that consecutive StepNumbers with the same Status have the same group key
        "StepNumber" - ROW_NUMBER() OVER (PARTITION BY Status ORDER BY StepNumber) AS grp  
    FROM Groupings
) AS GroupedTable
-- Group by Status and the generated group key to find consecutive ranges
GROUP BY Status, grp  
-- Sort the output by the minimum StepNumber to maintain order
ORDER BY "Min Step Number";


-- TASK 2

-- Create a table of all years from 1975 to the current year
SELECT TOP (YEAR(GETDATE()) - 1975 + 1) 
    1975 + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS Year
INTO #AllYears
FROM master.dbo.spt_values; -- Generates a series of numbers

-- Get distinct hired years
SELECT DISTINCT YEAR(HIRE_DATE) AS Year 
INTO #HiredYears 
FROM EMPLOYEES_N;

-- Step 3: Find missing years (years when no employees were hired)
SELECT a.Year 
INTO #MissingYears
FROM #AllYears a
LEFT JOIN #HiredYears h ON a.Year = h.Year
WHERE h.Year IS NULL;

-- Step 4: Assign grouping key to consecutive missing years
SELECT 
    Year,
    Year - ROW_NUMBER() OVER (ORDER BY Year) AS grp
INTO #GroupedYears
FROM #MissingYears;

-- Step 5: Aggregate consecutive missing years into intervals
SELECT CAST(MIN(Year) AS VARCHAR) + '-' + CAST(MAX(Year) AS VARCHAR) AS Years
FROM #GroupedYears
GROUP BY grp
ORDER BY Years;


-- Cleanup temporary tables
DROP TABLE #AllYears;
DROP TABLE #HiredYears;
DROP TABLE #MissingYears;
DROP TABLE #GroupedYears;

 