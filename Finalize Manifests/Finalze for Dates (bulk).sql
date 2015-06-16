
--delete from scManifestSequences
--delete from scManifestHistory
--delete from scManifests
--truncate table scManifestSequences

declare @date datetime

declare @begindate datetime
declare @enddate datetime


set @begindate = '2/1/2015'
set @enddate = convert(varchar, getdate(), 101)

declare @dates table ( [date] datetime )

while @begindate <= @enddate
begin
	print convert(varchar, @begindate, 101)
	insert into @dates
	select @begindate

	select @begindate = DATEADD(d, 1, @begindate)
end

declare finalizer_cursor cursor
for 
	select distinct [date]
	from @dates
	order by [date] desc
open finalizer_cursor
fetch next from finalizer_cursor into @date	
while @@FETCH_STATUS = 0
begin
	print 'finalizing for ' + convert(varchar, @date, 1)
	exec scManifestSequence_Finalizer @manifestdate=@date	
	
	fetch next from finalizer_cursor into @date	
end


close finalizer_cursor
deallocate finalizer_cursor

