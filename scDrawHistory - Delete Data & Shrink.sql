/*
	Loop through scDrawHistory, deleting records a month at a time, shrinking the log file as you go
*/
set nocount on

declare @retentionMonths int
declare @months int

set @retentionMonths = 12

declare @sql varchar(1000)

while 1=1
begin
	select @months =  datediff( month, min(drawdate), getdate())	
	from scDrawHistory
	
	if @months = @retentionMonths
		break
	
	print 'Deleting month ' 
		+ cast( datepart(month, dateadd(month, -1*@months, getdate())) as varchar )
		+ '/'
		+ cast( datepart(yy, dateadd(month, -1*@months, getdate())) as varchar )
		+ ' from scDrawHistory'

	delete scDrawHistory 
	from scDrawHistory 
	where datediff(month, DrawDate, getdate()) = @months 
	print cast(@@rowcount as varchar) + ' rows deleted from scDrawHistory'	
		
	select @sql = 'dbcc shrinkfile(' + cast(fileid as varchar) + ', 1)'
	from sysfiles
	where rtrim(filename) like '%.ldf'
	
	exec(@sql)
end

select min(drawdate) as [Min(DrawDate)], datediff( month, min(drawdate), getdate()) as [Months Retained]
from scDrawHistory

/*
select *
from sysfiles
*/
