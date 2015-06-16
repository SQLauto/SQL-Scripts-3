

declare @begindate datetime
declare @emddate datetime

set @begindate = '5/19/2014'
set @emddate = '6/9/2014'

while @begindate <= @emddate
begin
	print convert(varchar, @begindate, 101)
	select @begindate = DATEADD(d, 1, @begindate)
end


