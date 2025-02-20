CREATE DATABASE lesson4
USE lesson4

-- TASK 1

-- Creating the table
CREATE TABLE [dbo].[TestMultipleZero]
(
    [A] [int] NULL,
    [B] [int] NULL,
    [C] [int] NULL,
    [D] [int] NULL
);
GO

-- Inserting into the table
INSERT INTO [dbo].[TestMultipleZero](A,B,C,D)
VALUES 
    (0,0,0,1),
    (0,0,1,0),
    (0,1,0,0),
    (1,0,0,0),
    (0,0,0,0),
    (1,1,1,0);

-- Filtering out the rows with 0s in all columns
SELECT *
FROM TestMultipleZero
WHERE A <> 0 or B <> 0 or C <> 0 or D <> 0;


-- TASK 2

-- Creating the table
CREATE TABLE TestMax
(
    Year1 INT
    ,Max1 INT
    ,Max2 INT
    ,Max3 INT
);
GO
 
-- Inserting values into the table
INSERT INTO TestMax 
VALUES
    (2001,10,101,87)
    ,(2002,103,19,88)
    ,(2003,21,23,89)
    ,(2004,27,28,91);


SELECT Year1,
       CASE 
           WHEN Max1 >= Max2 AND Max1 >= Max3 THEN Max1
           WHEN Max2 >= Max1 AND Max2 >= Max3 THEN Max2
           ELSE Max3      -- Manual comparison
       END AS Max_Value	
FROM TestMax;


-- TASK 3

-- Creating the table
CREATE TABLE EmpBirth
(
    EmpId INT  IDENTITY(1,1) 
    ,EmpName VARCHAR(50) 
    ,BirthDate DATETIME 
);
 
--Inserting values into the table
INSERT INTO EmpBirth(EmpName,BirthDate)
SELECT 'Pawan' , '12/04/1983'
UNION ALL
SELECT 'Zuzu' , '11/28/1986'
UNION ALL
SELECT 'Parveen', '05/07/1977'
UNION ALL
SELECT 'Mahesh', '01/13/1983'
UNION ALL
SELECT'Ramesh', '05/09/1983';

SELECT 
    EmpId,
    EmpName,
    BirthDate
FROM EmpBirth
WHERE 
    MONTH(BirthDate) = 5 -- Filter for May
    AND DAY(BirthDate) BETWEEN 7 AND 15; -- Filter for days between 7 and 15


-- TASK 4

-- Creating the table
CREATE TABLE letters
(letter CHAR(1));

-- Inserting values into the table
INSERT INTO letters
VALUES ('a'), ('a'), ('a'), 
  ('b'), ('c'), ('d'), ('e'), ('f');



-- 'b' coming in the first position

SELECT letter
FROM letters
ORDER BY 
    CASE WHEN letter = 'b' THEN 0 ELSE 1 END, -- 'b' first
    letter; -- Secondary sort  



-- 'b' coming in the last position

SELECT letter
FROM letters
ORDER BY 
    CASE WHEN letter = 'b' THEN 1 ELSE 0 END, -- 'b' last
    letter;




-- 'b' coming in the 3rd position

WITH OrderedLetters AS (
    SELECT letter, ROW_NUMBER() OVER (ORDER BY letter) AS rn
    FROM letters WHERE letter <> 'b'
)
SELECT letter FROM OrderedLetters WHERE rn < 3 -- First 2 letters
UNION ALL
SELECT 'b' -- Place 'b' in 3rd position
UNION ALL
SELECT letter FROM OrderedLetters WHERE rn >= 3 -- Remaining letters
ORDER BY rn;



