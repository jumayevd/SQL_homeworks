



DECLARE @properties NVARCHAR(MAX);


SELECT @properties = STRING_AGG(QUOTENAME(name) + ' as [' + name + '.value]', ', ')
FROM sys.columns 
WHERE object_id = OBJECT_ID('Contacts') 
AND name not in ('identifier_name', 'identifier_value')

DECLARE @sql NVARCHAR(MAX) = '
SELECT 
    (SELECT identifier_name as identifier, identifier_value as value 
     FROM Contacts 
     FOR JSON PATH) as identifiers,
    (SELECT ' + @properties + ' 
     FROM Contacts 
     FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as properties
FROM Contacts
FOR JSON PATH, ROOT(''contacts'');';
EXEC sp_executesql @sql;
