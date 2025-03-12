-- TASK 1: Retrieve all table columns with their data types across databases

-- Creating a temporary table to store results
CREATE TABLE #temp (
    DatabaseName NVARCHAR(255),  -- Stores database name
    SchemaName NVARCHAR(128),    -- Stores schema name
    TableName NVARCHAR(128),     -- Stores table name
    ColumnName NVARCHAR(128),    -- Stores column name
    DataType NVARCHAR(50)        -- Stores column data type with size
);

DECLARE @name NVARCHAR(255);  -- Variable to hold database name
DECLARE @i INT = 1;           -- Loop counter
DECLARE @count INT;           -- Total number of user databases
DECLARE @sql NVARCHAR(MAX);   -- Variable to store dynamic SQL

-- Get the total count of user databases (excluding system databases)
SELECT @count = COUNT(1)
FROM sys.databases 
WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb');

-- Loop through each user database
WHILE @i <= @count
BEGIN
    -- Retrieve the database name based on row number
    WITH cte AS (
        SELECT name, ROW_NUMBER() OVER(ORDER BY name) AS rn
        FROM sys.databases 
        WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb')
    )
    SELECT @name = name FROM cte WHERE rn = @i;

    -- Check if a valid database name is retrieved
    IF @name IS NOT NULL
    BEGIN
        -- Construct dynamic SQL to fetch table column details
        SET @sql = N'
            SELECT 
                ''' + @name + N''' AS DatabaseName,  
                TABLE_SCHEMA AS SchemaName,
                TABLE_NAME AS TableName,          
                COLUMN_NAME AS ColumnName,           
                DATA_TYPE + ''('' + 
                    CASE 
                        WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN ''max''  
                        ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS NVARCHAR) 
                    END + '')'' AS DataType  -- Store data type with size
            FROM ' + @name + N'.INFORMATION_SCHEMA.COLUMNS;  
        ';

        -- Execute dynamic SQL and insert results into the temporary table
        INSERT INTO #temp
        EXEC sp_executesql @sql;
    END;

    -- Increment loop counter
    SET @i = @i + 1;
END;

-- Display final results
SELECT * FROM #temp;


-- ===================================================================
-- TASK 2: Retrieve all stored procedures and functions across databases
-- ===================================================================

GO

-- Creating a temporary table to store results
CREATE TABLE #temp2 (
    DatabaseName NVARCHAR(25),   -- Stores database name
    SchemaName NVARCHAR(25),     -- Stores schema name
    ObjectName NVARCHAR(100),    -- Stores procedure/function name
    ObjectType NVARCHAR(50),     -- Type (Stored Procedure, Function)
    ParameterName NVARCHAR(50),  -- Parameter name (if exists)
    DataType NVARCHAR(25),       -- Parameter data type
    MaxLength INT                -- Max length of parameter (if applicable)
);

GO 

-- Create stored procedure to retrieve stored procedures and functions
CREATE PROCEDURE GetStoredProceduresAndFunctions
    @DatabaseName NVARCHAR(256) = NULL  -- Optional parameter for specific database
AS
BEGIN
    SET NOCOUNT ON;  -- Prevent unnecessary message outputs

    DECLARE @SQL NVARCHAR(MAX) = '';  -- Variable to store dynamic SQL

    -- If a specific database is provided, query only that database
    IF @DatabaseName IS NOT NULL
    BEGIN
        SET @SQL = '
        SELECT 
            ''' + @DatabaseName + ''' AS DatabaseName,  
            s.name AS SchemaName,                       
            o.name AS ObjectName,                      
            o.type_desc AS ObjectType,                 
            p.name AS ParameterName,                    
            t.name AS DataType,                         
            CASE 
                WHEN t.name IN (''nchar'', ''nvarchar'') AND p.max_length <> -1 THEN p.max_length / 2  
                ELSE p.max_length  
            END AS MaxLength  
        FROM ' + QUOTENAME(@DatabaseName) + '.sys.objects o
        JOIN ' + QUOTENAME(@DatabaseName) + '.sys.schemas s ON o.schema_id = s.schema_id
        LEFT JOIN ' + QUOTENAME(@DatabaseName) + '.sys.parameters p ON o.object_id = p.object_id
        LEFT JOIN ' + QUOTENAME(@DatabaseName) + '.sys.types t ON p.user_type_id = t.user_type_id
        WHERE o.type IN (''P'', ''FN'', ''IF'', ''TF'');';  -- Filter for procedures and functions

        EXEC sp_executesql @SQL;  -- Execute SQL query
    END
    ELSE
    BEGIN
        -- ==========================
        -- Process for ALL databases
        -- ==========================
        DECLARE @DBName NVARCHAR(256);
        DECLARE @Index INT = 1;
        DECLARE @DBCount INT;

        -- Temporary table to store all database names
        DECLARE @DBs TABLE (ID INT IDENTITY(1,1), Name NVARCHAR(256));

        -- Insert all online databases into the table
        INSERT INTO @DBs (Name)
        SELECT name FROM sys.databases WHERE state_desc = 'ONLINE';

        -- Get total count of databases
        SELECT @DBCount = COUNT(*) FROM @DBs;

        -- Loop through each database
        WHILE @Index <= @DBCount
        BEGIN
            -- Retrieve database name from temporary table
            SELECT @DBName = Name FROM @DBs WHERE ID = @Index;

            -- Construct dynamic SQL for each database
            SET @SQL = '
            SELECT 
                ''' + @DBName + ''' AS DatabaseName,  
                s.name AS SchemaName,                 
                o.name AS ObjectName,                
                o.type_desc AS ObjectType,           
                p.name AS ParameterName,              
                t.name AS DataType,                 
                CASE 
                    WHEN t.name IN (''nchar'', ''nvarchar'') AND p.max_length <> -1 THEN p.max_length / 2  
                    ELSE p.max_length  
                END AS MaxLength 
            FROM ' + QUOTENAME(@DBName) + '.sys.objects o
            JOIN ' + QUOTENAME(@DBName) + '.sys.schemas s ON o.schema_id = s.schema_id
            LEFT JOIN ' + QUOTENAME(@DBName) + '.sys.parameters p ON o.object_id = p.object_id
            LEFT JOIN ' + QUOTENAME(@DBName) + '.sys.types t ON p.user_type_id = t.user_type_id
            WHERE o.type IN (''P'', ''FN'', ''IF'', ''TF'');';  -- Filter for procedures and functions

            -- Insert results into temporary table
            INSERT INTO #temp2
            EXEC sp_executesql @SQL;
            
            -- Move to the next database
            SET @Index = @Index + 1;
        END
    END
END;

-- Retrieve final results
SELECT * FROM #temp2;
