IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_ddSnapshotView_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_ddSnapshotView_Update]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[support_ddSnapshotView_Update]
AS
/*
	[dbo].[support_ddSnapshotView_Update]
	
	$History:  $
*/
BEGIN
	set nocount on
	
	declare @sql nvarchar(max)
	declare @obj nvarchar(256)
	declare @obj_owner nvarchar(256)
	declare @obj_count int
	declare @counter int
	declare @snapshotTaken nvarchar(20)

	set @counter = 1

	select ident_current=identity(int,1,1), name, user_name(uid) as [owner]
		, left(substring(name, len('scDefaultDraws_Snapshot_') + 1, 8), 2)
		+ '/' + substring( substring(name, len('scDefaultDraws_Snapshot_') + 1, 8), 3, 2)
		+ '/' + right(substring(name, len('scDefaultDraws_Snapshot_') + 1, 8), 2)
		+ '  ' + left(right(name, 6),2)
		+ ':' + substring( right(name, 6),3,2)
		+ ':' + right(right(name, 6),2) as [SnapshotTaken]
	into #objects
	from sysobjects
	where name like 'scDefaultDraws_Snapshot_%'
	and type = 'u'
	order by crdate desc

	set @sql = 'IF EXISTS (select * from dbo.sysobjects where id = object_id(N''dbo.support_ddSnapshotView'') and OBJECTPROPERTY(id, N''IsView'') = 1)
		DROP VIEW dbo.support_ddSnapshotView
	'
	--print @sql
	exec (@sql)

	set @sql = '
	CREATE VIEW dbo.support_ddSnapshotView
	AS'

	--select @obj_count = max([ident_current])
	--from #objects

	--|initialize SELECT statement
	set @sql = @sql + '
		select a.AcctCode, p.PubShortName
			, dd.AccountID, dd.PublicationID, dd.DrawWeekday
			, dd.DrawAmount, dd.DrawRate '

	declare obj_cursor cursor
	for
		select [ident_current], name, owner, snapshottaken
		from #objects
		order by [ident_current]

	open obj_cursor
	fetch next from obj_cursor into @counter, @obj, @obj_owner, @snapshotTaken

	while @@fetch_status = 0
	begin
		--set @sql = @sql + '
		--	, dd' + cast(@counter as varchar) + '.DrawAmount as [DrawAmount_' + replace(@obj, 'scDefaultDraws_Snapshot_', '') + '], dd' + cast(@counter as varchar) + '.DrawRate as [DrawRate_' + replace(@obj, 'scDefaultDraws_Snapshot_', '') + ']'

		set @sql = @sql + '
			, dd' + cast(@counter as varchar) + '.DrawAmount as [DrawAmount (' + @snapshotTaken + ')], dd' + cast(@counter as varchar) + '.DrawRate as [DrawRate (' + @snapshotTaken + ')]'

		set @counter = @counter + 1
		fetch next from obj_cursor into @counter, @obj, @obj_owner, @snapshotTaken
	end

	close obj_cursor
	deallocate obj_cursor

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

	--print @sql
	exec (@sql)

	drop table #objects	
END
GO	

exec support_ddSnapshotView_Update