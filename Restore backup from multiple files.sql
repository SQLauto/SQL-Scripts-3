RESTORE DATABASE NSDB_OLY_TEST FROM
DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\Backup\nsdb_oly_1.bak', 
DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\Backup\nsdb_oly_2.bak', 
DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\Backup\nsdb_oly_3.bak', 
DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\Backup\nsdb_oly_4.bak', 
DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\Backup\nsdb_oly_5.bak'
WITH  FILE = 1, 
MOVE 'nsdb_Data' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\nsdb_oly_test.MDF',
MOVE 'nsdb_Log'  TO 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\nsdb_oly_test_log.LDF'
, REPLACE