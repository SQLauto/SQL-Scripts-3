IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_vdb_PeriodStartDate_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_vdb_PeriodStartDate_Update]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[support_vdb_PeriodStartDate_Update]
AS
/*
	[dbo].[support_vdb_PeriodStartDate_Update]
	
	$History:  $
*/
BEGIN
	set nocount on

	declare @msg varchar(256)

	
	select vdb.publicationid, pubshortname, periodstartdate
	into #vdb
	from scvariabledaysback vdb
	join nspublications p
		on vdb.PublicationId = p.PublicationId
	where p.PubShortName = 'USA'

	update scvariabledaysback
	set periodstartdate = dateadd(d, 7, vdb.periodstartdate)
	from scVariableDaysBack vdb
	join #vdb tmp
		on vdb.PublicationId = tmp.PublicationId 
	
	--| Insert an informational message into the System Log
	set @msg = 'Variable Days Back PeriodStartDates updated successfully.'
	exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
	--|print @msg

	declare @date datetime
	declare @user int

	set @date = getdate()
	select @user = UserId
	from Users
	where UserName = 'support@syncronex.com'

	exec nsMessages_INSERTNOTALREADY 
		@nsSubject='VDB PeriodStartDates Updated Successfully'
		, @nsMessageText=@msg
		, @nsFromId = @user
		, @nsToId = 0
		, @nsGroupId = 2
		, @nsTime = @date
		, @nsPriorityId = 2 	--|  Normal
		, @nsStatusId = 3  	--|
		, @nsTypeId = 1		--|  Memo 
		, @nsStateId = 1
		, @nsCompareTime = @date
		, @nsAccountId = 0

	insert into syncSystemLog ( 
		  LogMessage
		, SLTimeStamp
		, ModuleId
		, SeverityId
		, CompanyId
		, [Source]
		--, GroupId 
		)
	select 
		 'VDB:  PeriodStartDate updated for publication ''' + tmp.pubshortname + '''.  Old PeriodStartDate=' + convert(varchar, tmp.PeriodStartDate, 1) + '.  New PeriodStartDate=' + convert(varchar, vdb.PeriodStartDate, 1) + '.'
			as [LogMessage]
		, getdate() as [SLTimeStamp]
		, 2 as [ModuleId]	--|2=SingleCopy
		, 1 as [SeverityId] --|1=Warning
		, 1 as [CompanyId]
		, N'' as [Source]   --|nvarchar(100)
		--, newid() as [GroupId]
	from scvariabledaysback vdb
	join nspublications p
		on vdb.PublicationId = p.PublicationId
	join #vdb  tmp
		on vdb.PublicationId = tmp.PublicationId
	order by p.PrintSortOrder	
	
	drop table #vdb
END

GO

