declare @beginDrawDate datetime
declare @endDrawDate datetime
set @beginDrawDate = '3/25/2011'
set @endDrawDate = '3/25/2011'

declare @maxReturnsId int
declare @counter int

set @counter = 1

select @maxReturnsId = max(ReturnsAuditId)
from scReturnsAudit ra
join scDraws d
	on ra.DrawId = d.DrawID
where d.DrawDate between @beginDrawDate and @endDrawDate

declare @cols nvarchar(2000)
declare @selectValueCols nvarchar(2000)
declare @selectUserCols nvarchar(2000)
declare @selectDateCols nvarchar(2000)

while @counter <= @maxReturnsId
begin
	set @cols = coalesce(@cols + ',[' + cast(@counter as varchar) + ']', '[' + cast(@counter as varchar) + ']' )
	set @selectUserCols = coalesce( @selectUserCols
		+ ',[' + cast(@counter as varchar) + '] as [RetAuditUser' + cast(@counter as varchar) + ']'
		 , '[' + cast(@counter as varchar) + '] as [RetAuditUser' + cast(@counter as varchar) + ']' )
	set @selectValueCols = coalesce( @selectValueCols
		+ ',[' + cast(@counter as varchar) + '] as [RetAuditValue' + cast(@counter as varchar) + ']'
		 , '[' + cast(@counter as varchar) + '] as [RetAuditValue' + cast(@counter as varchar) + ']' )
	set @selectDateCols = coalesce( @selectDateCols
		+ ',[' + cast(@counter as varchar) + '] as [RetAuditDate' + cast(@counter as varchar) + ']'
		 , '[' + cast(@counter as varchar) + '] as [RetAuditDate' + cast(@counter as varchar) + ']' )	 
	set @counter = @counter + 1
end	
--print @cols
--print @selectUserCols
--print @selectValueCols
--print @selectDateCols

/*
	select DrawId, [1] as [RetAuditValue1], [2] as [RetAuditValue2], [3] as [RetAuditValue3], [4] as [RetAuditValue4], [5] as [RetAuditValue5]
	into #RetAuditValues
	from (
		select ra.DrawId, ra.ReturnsAuditId, cast(ra.RetAuditValue as int) as [RetAuditValue]
		from scReturnsAudit ra
		join scDraws d
			on ra.DrawId = d.DrawId
		where datediff(d, d.DrawDate, getdate()) < @threshold
		) as t
	pivot (
		sum(RetAuditValue)
		for ReturnsAuditId in ([1], [2], [3], [4], [5])
		) as RetAuditValues
*/		

declare @sql varchar(4000)
set @sql = N'select DrawId, ' + @selectValueCols + '
	--into #RetAuditValues
	from (
		select ra.DrawId, ra.ReturnsAuditId, cast(ra.RetAuditValue as int) as [RetAuditValue]
		from scReturnsAudit ra
		join scDraws d
			on ra.DrawId = d.DrawId
		where d.DrawDate between ''' + convert(varchar, @beginDrawDate, 1) + ''' and ''' + convert(varchar, @endDrawDate, 1) + '''
		) as t
	pivot (
		sum(RetAuditValue)
		for ReturnsAuditId in (' + @cols + ')
		) as pvtValues'
	
print @sql	
exec(@sql)		

drop table #RetAuditValues