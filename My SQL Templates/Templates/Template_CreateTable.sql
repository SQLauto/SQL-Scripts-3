IF OBJECT_ID('<schema_name, sysname, dbo>.<table_name, sysname, sample_table>', 'U') IS NOT NULL
  DROP TABLE <schema_name, sysname, dbo>.<table_name, sysname, sample_table>
GO

CREATE TABLE <schema_name, sysname, dbo>.<table_name, sysname, sample_table> 
(

)
GO

GRANT SELECT ON [<schema_name, sysname, dbo>.<table_name, sysname, sample_table>] TO [nsUser]
GO
