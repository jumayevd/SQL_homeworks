WITH DateSequence AS (
    -- Anchor: Start with the first day of the month
    SELECT 
        DATEFROMPARTS(YEAR(@date), MONTH(@date), 1) AS Date,
        DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(@date), MONTH(@date), 1)) AS DayOfWeek,
        DATEPART(DAY, DATEFROMPARTS(YEAR(@date), MONTH(@date), 1)) AS DayOfMonth
    UNION ALL
    -- Recursive: Add one day until the end of the month
    SELECT 
        DATEADD(DAY, 1, Date),
        DATEPART(WEEKDAY, DATEADD(DAY, 1, Date)),
        DATEPART(DAY, DATEADD(DAY, 1, Date))
    FROM DateSequence
    WHERE Date < EOMONTH(@date)
),
CalendarGrid AS (
    SELECT 
        DATEPART(WEEK, Date) - DATEPART(WEEK, DATEFROMPARTS(YEAR(@date), MONTH(@date), 1)) + 1 AS WeekNumber,
        MAX(CASE WHEN DayOfWeek = 1 THEN DayOfMonth END) AS Sunday,
        MAX(CASE WHEN DayOfWeek = 2 THEN DayOfMonth END) AS Monday,
        MAX(CASE WHEN DayOfWeek = 3 THEN DayOfMonth END) AS Tuesday,
        MAX(CASE WHEN DayOfWeek = 4 THEN DayOfMonth END) AS Wednesday,
        MAX(CASE WHEN DayOfWeek = 5 THEN DayOfMonth END) AS Thursday,
        MAX(CASE WHEN DayOfWeek = 6 THEN DayOfMonth END) AS Friday,
        MAX(CASE WHEN DayOfWeek = 7 THEN DayOfMonth END) AS Saturday
    FROM DateSequence
    GROUP BY DATEPART(WEEK, Date) - DATEPART(WEEK, DATEFROMPARTS(YEAR(@date), MONTH(@date), 1)) + 1
)
SELECT 
    WeekNumber,
    Sunday,
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday
FROM CalendarGrid



DECLARE @date DATE = getdate();
SELECT * 
FROM dbo.Calendar(@date)
ORDER BY WeekNumber; -- Sorting applied here