-- Step 1: Retrieve Index Metadata and Format as HTML
DECLARE @html NVARCHAR(MAX);

SET @html = (
    SELECT 
        '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse:collapse;">' +
        '<tr><th>Table Name</th><th>Index Name</th><th>Index Type</th><th>Column Name</th><th>Is Included Column</th></tr>' +
        CAST((
            SELECT 
                '<tr>' +
                '<td>' + t.name + '</td>' +
                '<td>' + i.name + '</td>' +
                '<td>' + i.type_desc + '</td>' +
                '<td>' + c.name + '</td>' +
                '<td>' + CASE WHEN ic.is_included_column = 1 THEN 'Yes' ELSE 'No' END + '</td>' +
                '</tr>'
            FROM 
                sys.tables t
            INNER JOIN 
                sys.indexes i ON t.object_id = i.object_id
            INNER JOIN 
                sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
            INNER JOIN 
                sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
            WHERE 
                i.type_desc IN ('CLUSTERED', 'NONCLUSTERED')
            ORDER BY 
                t.name, i.name, ic.key_ordinal
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)') AS NVARCHAR(MAX)) +
        '</table>'
);

-- Step 2: Send the Email
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'MyMailProfile', 
    @recipients = 'jumayevdoniyor03355@gmail.com', 
    @subject = 'Index Metadata Report',
    @body = @html,
    @body_format = 'HTML';

