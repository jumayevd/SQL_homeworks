CREATE TABLE Shipments (
    N INT PRIMARY KEY,
    Num INT
);

INSERT INTO Shipments (N, Num) VALUES
(1, 1), (2, 1), (3, 1), (4, 1), (5, 1), (6, 1), (7, 1), (8, 1),
(9, 2), (10, 2), (11, 2), (12, 2), (13, 2), (14, 4), (15, 4), 
(16, 4), (17, 4), (18, 4), (19, 4), (20, 4), (21, 4), (22, 4), 
(23, 4), (24, 4), (25, 4), (26, 5), (27, 5), (28, 5), (29, 5), 
(30, 5), (31, 5), (32, 6), (33, 7);



-- SOLUTION

-- Create a temporary table with all 40 days

;WITH AllDays AS (
    SELECT TOP 40 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Day
    FROM master..spt_values
),
-- Add the zero shipments for the missing days
MissingDays AS (
    SELECT Day, 0 AS Num
    FROM AllDays
    WHERE Day NOT IN (SELECT N FROM Shipments)
)
-- Combine the recorded shipments with the missing days
SELECT N AS Day, Num INTO AllShipments
FROM Shipments
UNION ALL
SELECT Day, Num
FROM MissingDays;
--==============
WITH OrderedShipments AS (
    SELECT Num,
           ROW_NUMBER() OVER (ORDER BY Num, Day) AS RowAsc,
           ROW_NUMBER() OVER (ORDER BY Num DESC, Day DESC) AS RowDesc
    FROM AllShipments
)
SELECT AVG(Num) AS Median
FROM OrderedShipments
WHERE RowAsc = RowDesc
   OR RowAsc + 1 = RowDesc
   OR RowAsc - 1 = RowDesc;