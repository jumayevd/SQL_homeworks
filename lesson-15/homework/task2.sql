
;WITH cte AS (
    SELECT
        ID,
        ChangeType,
        QuantityChange,
        Change_datetime,
        DATEDIFF(day, (select MIN(Change_datetime) from items), Change_datetime) as daydiff 
    FROM items
),
cte2 as (
    SELECT
        ID,
        ChangeType,
        QuantityChange,
        Change_datetime,
        daydiff,
        CASE
            WHEN daydiff BETWEEN 0 AND 90 THEN '0-90 days'
            WHEN daydiff BETWEEN 91 AND 180 THEN '91-180 days'
            WHEN daydiff BETWEEN 181 AND 270 THEN '181-270 days'
            WHEN daydiff BETWEEN 271 AND 360 THEN '271-360 days'
            WHEN daydiff BETWEEN 361 AND 450 THEN '361-450 days'
            ELSE '>450 days'
        END as TimeInterval
    FROM cte
),
Summed as (
    SELECT
        TimeInterval,
        SUM(CASE WHEN ChangeType = 'in' THEN QuantityChange ELSE -QuantityChange END) as newq
    FROM cte2
    GROUP BY TimeInterval
)
SELECT
    ISNULL([0-90 days], 0) as '0-90 days',
    ISNULL([91-180 days], 0) as '91-180 days',
    ISNULL([181-270 days], 0) as '181-270 days',
    ISNULL([271-360 days], 0) as '271-360 days',
    ISNULL([361-450 days], 0) as '361-450 days'
FROM Summed
PIVOT (
    SUM(newq)
    FOR TimeInterval IN ([0-90 days], [91-180 days], [181-270 days], [271-360 days], [361-450 days])
) as PivotTable;