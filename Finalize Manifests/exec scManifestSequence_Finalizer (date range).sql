begin tran

declare @begindate datetime
declare @enddate datetime

set @begindate = '4/23/2013'
set @enddate = '4/30/2013'

while @begindate <= @enddate
begin
	print 'finalizing for ' + convert(varchar, @begindate, 1)
	exec scmanifestsequence_finalizer @begindate
	
	set @begindate = dateadd(d, 1, @begindate)
end

commit tran

