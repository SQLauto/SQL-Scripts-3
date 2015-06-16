--Version 1
declare @sql nvarchar(max)
declare @obj nvarchar(256)
declare @obj_owner nvarchar(256)
declare @obj_count int
declare @counter int

set @counter = 1

set @sql = 'IF EXISTS (select * from dbo.sysobjects where id = object_id(N''dbo.support_ddSnapshotView'') and OBJECTPROPERTY(id, N''IsView'') = 1)
	DROP VIEW dbo.support_ddSnapshotView
'
print @sql
exec (@sql)

set @sql = '
CREATE VIEW dbo.support_ddSnapshotView
AS'

select @obj_count = count(*)
from sysobjects
where name like 'scDefaultDraws_Snapshot_%'
and type = 'u'

set @sql = @sql + '
	select a.AcctCode, p.PubShortName
		, dd.AccountID, dd.PublicationID, dd.DrawWeekday
		, dd.DrawAmount, dd.DrawRate '

while @counter <= @obj_count
begin
	set @sql = @sql + '
		, dd' + cast(@counter as varchar) + '.DrawAmount as [DrawAmount' + cast(@counter as varchar) + '], dd' + cast(@counter as varchar) + '.DrawRate as [DrawRate' + cast(@counter as varchar) + ']'

	set @counter = @counter + 1
end

set @sql = @sql + ' 
	from scDefaultDraws dd 
	join scAccounts a
		on dd.AccountId = a.AccountId
	join nsPublications p
		on dd.PublicationId = p.PublicationId '
	
set @counter = 1
	
declare obj_cursor cursor
for 
	select name, user_name(uid)
	from sysobjects
	where name like 'scDefaultDraws_Snapshot_%'
	and type = 'u'
	order by crdate desc

open obj_cursor
fetch next from obj_cursor into @obj, @obj_owner

while @@fetch_status = 0
begin
	if @counter = 1
	begin
		set @sql = @sql + ' 
	join ' + @obj_owner + '.' + @obj + ' dd' + cast(@counter as varchar) + '
		on dd.AccountId = dd' + cast(@counter as varchar) + '.AccountId
		and dd.PublicationId = dd' + cast(@counter as varchar) + '.PublicationId
		and dd.DrawWeekday = dd' + cast(@counter as varchar) + '.DrawWeekday'
	end
	else
	begin
		set @sql = @sql + ' 
	join ' + @obj_owner + '.' + @obj + ' dd' + cast(@counter as varchar) + '
		on dd' + cast(@counter - 1 as varchar) + '.AccountId = dd' + cast(@counter as varchar) + '.AccountId
		and dd' + cast(@counter - 1 as varchar) + '.PublicationId = dd' + cast(@counter as varchar) + '.PublicationId
		and dd' + cast(@counter - 1 as varchar) + '.DrawWeekday = dd' + cast(@counter as varchar) + '.DrawWeekday'
	end	
		
	set @counter = @counter + 1	
	fetch next from obj_cursor into @obj, @obj_owner
end

--set @sql = @sql + ' GO'

close obj_cursor
deallocate obj_cursor

print @sql
exec (@sql)

select *
from support_ddSnapshotView
