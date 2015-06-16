DECLARE @firstdate DATETIME, @lastdate DATETIME, @today  DATETIME --varchar(10) 
declare @Cmd nvarchar(4000)
SET @today = CAST( FLOOR( CAST( GETDATE() AS FLOAT ) )AS DATETIME )
SET @firstdate = DATEADD( dd, 10, @today )
set @lastdate = DATEADD( dd, 16, @today )
SET @Cmd = 'D:\Syncronex\bin\syncExport.exe forecast "D:\Program Files\Syncronex\SingleCopy\DATAIO\WeeklyForecastExport.xml" /p StartDate="'
     + CONVERT(NVARCHAR(10),@firstdate,101)
	 + '",StopDate="'
	 + CONVERT(NVARCHAR(10),@lastdate,101)
	 + '"'

EXECUTE  master..xp_cmdshell  @Cmd
