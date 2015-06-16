/*
Value of error log file you want to read: 0 = current, 1 = Archive #1, 2 = Archive #2, etc...
Log file type: 1 or NULL = error log, 2 = SQL Agent log
Search string 1: String one you want to search for
Search string 2: String two you want to search for to further refine the results
Search from start time  
Search to end time
Sort order for results: N'asc' = ascending, N'desc' = descending
*/
EXEC master.dbo.xp_readerrorlog 0, 1, null, null, '2013-09-16', null, N'desc' 
EXEC master.dbo.xp_readerrorlog 0, 2, null, null, '2013-09-16 10:00:01.000', '2013-09-16 11:03:01.000', N'desc' 
