DECLARE @BackupDirectory VARCHAR(100) 
EXEC master..xp_regread @rootkey='HKEY_LOCAL_MACHINE', 
  @key='SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL.1\MSSQLServer', 
  @value_name='BackupDirectory', 
  @BackupDirectory=@BackupDirectory OUTPUT 
SELECT @BackupDirectory