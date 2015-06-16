BACKUP DATABASE nsdb TO
DISK = 'C:\Program Files\Syncronex\Support\DbBackup\nsdb01.bak',
DISK = 'C:\Program Files\Syncronex\Support\DbBackup\nsdb02.bak',
DISK = 'C:\Program Files\Syncronex\Support\DbBackup\nsdb03.bak',
DISK = 'C:\Program Files\Syncronex\Support\DbBackup\nsdb04.bak'
WITH COMPRESSION

RESTORE DATABASE nsdb_36 FROM
DISK = 'C:\Program Files\Syncronex\Support\NewDb\nsdb01.bak', 
DISK = 'C:\Program Files\Syncronex\Support\NewDb\nsdb02.bak', 
DISK = 'C:\Program Files\Syncronex\Support\NewDb\nsdb03.bak', 
DISK = 'C:\Program Files\Syncronex\Support\NewDb\nsdb04.bak', 
WITH  FILE = 1, 
MOVE 'nsdb_Data' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\nsdb_36.MDF',
MOVE 'nsdb_Log'  TO 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\nsdb_36_log.LDF'
--,RECOVERY, REPLACE

/* 

Check the help for more on RECOVERY and REPLACE.
For the MOVE option, if you don't know the logical names of the data and log files, use this to find them:

RESTORE FILELISTONLY
from DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\Backup\nsdb01.bak'
WITH  FILE = 1

*/
 
