USE <YOUR_DATABASE_NAME>
GO
sp_MSforeachtable @command1="print '?'", @command2="SELECT COUNT(*) AS '?' FROM ?" 