

SELECT  left( cast(SERVERPROPERTY('productversion') as varchar), charindex('.', cast( SERVERPROPERTY('productversion') as varchar), 0) - 1) as [version]
