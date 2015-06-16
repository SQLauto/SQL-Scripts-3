IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_DeactivateAcctPubs_NoRecentDraw]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_DeactivateAcctPubs_NoRecentDraw]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[support_DeactivateAcctPubs_NoRecentDraw]
	@daysOfNonZeroDraw int  --|  number of days since last non-zero draw
AS
/*
	[dbo].[support_DeactivateAcctPubs_NoRecentDraw]
	
	$History:  $
*/
BEGIN
	set nocount on

	--|  Declarations
	declare @msg nvarchar(1024)

	set @msg = 'Accts/Pubs with no draw since ' + convert(varchar, dateadd(d, -1*@daysOfNonZeroDraw, convert(varchar, getdate(), 1)), 101) + ' will be deactivated'
	print @msg
	exec nsSystemLog_Insert @ModuleId=2, @SeverityId=0, @Message=@msg
	
	declare @AcctPubsToDeactivate table (
		  AccountId int
		, PublicationId int
		, LastNonZeroDrawDate datetime
	)
	insert into @AcctPubsToDeactivate (AccountId, PublicationId, LastNonZeroDrawDate )
	select d.AccountID, d.PublicationID, LastNonZeroDrawDate
	from scDraws d
	join scAccounts a
		on d.AccountID = a.AccountID
	join nsPublications p
		on d.PublicationID = p.PublicationID
	join scAccountsPubs ap
		on a.AccountID = ap.AccountId
		and p.PublicationID = ap.PublicationId
	join (
		select AccountID, PublicationID, max(DrawDate) as [LastNonZeroDrawDate]
		from scDraws
		where DrawAmount > 0
		group by AccountID, PublicationID
		) as lastNonZeroDraw
		on d.AccountID = lastNonZeroDraw.AccountID
		and d.PublicationID = lastNonZeroDraw.PublicationID
		and d.DrawDate = lastNonZeroDraw.lastNonZeroDrawDate
	where lastNonZeroDrawDate < dateadd(d, -1*@daysOfNonZeroDraw, convert(varchar, getdate(), 1))
	and ap.Active = 1
	order by cast(LastNonZeroDrawDate as datetime) desc
	set @msg = 'Found ' + cast(@@rowcount as varchar) + ' AcctPubs to deactivate'
	print @msg
	exec nsSystemLog_Insert @ModuleId=2, @SeverityId=0, @Message=@msg

	--|  zero out default draw
	update scDefaultDraws
	set DrawAmount = 0
	from scDefaultDraws dd
	join @AcctPubsToDeactivate tmp
		on dd.AccountID = tmp.AccountId
		and dd.PublicationID = tmp.PublicationId
	set @msg = 'Zeroed out Default Draw for ' + cast(@@rowcount/7 as varchar) + ' AcctPubs'
	print @msg
	exec nsSystemLog_Insert @ModuleId=2, @SeverityId=0, @Message=@msg

	--|  zero out future draw
	update scDraws 
	set DrawAmount = 0
	from scDraws d
	join @AcctPubsToDeactivate tmp
		on d.AccountID = tmp.AccountId
		and d.PublicationID = tmp.PublicationId
	where d.DrawDate > getdate()
	and d.DrawAmount > 0
	set @msg = 'Zeroed out ' + cast(@@rowcount as varchar) + ' non-zero scDraws records'
	print @msg
	exec nsSystemLog_Insert @ModuleId=2, @SeverityId=0, @Message=@msg

	--|  deactivate AcctsPubs
	update scAccountsPubs
	set Active = 0
	from scAccountsPubs ap
	join @AcctPubsToDeactivate tmp
		on ap.AccountId = tmp.AccountId
		and ap.PublicationId = tmp.PublicationId
	set @msg = 'Deactivated ' + cast(@@rowcount as varchar) + ' AcctPubs'
	print @msg
	exec nsSystemLog_Insert @ModuleId=2, @SeverityId=0, @Message=@msg

	--|  deactivate accounts where all acctpubs are inactvie
	update scAccounts	
		set AcctActive = 0
	from scaccounts a
	join (
		select AccountId
		from scAccountsPubs
		group by AccountId 
		having sum(Active) = 0
	) prelim
	on a.AccountID = prelim.AccountId
	where a.AcctActive = 1
	set @msg = 'Deactivated ' + cast(@@rowcount as varchar) + ' Accounts where all Pubs are inactive'
	print @msg
	exec nsSystemLog_Insert @ModuleId=2, @SeverityId=0, @Message=@msg

	--| log
	insert into syncSystemLog ( 
		  LogMessage  
		, SLTimeStamp
		, ModuleId
		, SeverityId
		, CompanyId
		, [Source]
		--, GroupId 
		)
	select 'Acct/Pub ' + a.AcctCode + '/' + p.PubShortName + ' was deactivated on ' + convert(varchar, getdate(), 101) +  '.  Last non-zero draw occurred on ' + convert(varchar, LastNonZeroDrawDate, 101)
		, getdate() as [SLTimeStamp]
		, 2 as [ModuleId]	--|2=SingleCopy
		, 0 as [SeverityId] --|1=Warning
		, 1 as [CompanyId]
		, N'support_DeactivateAcctPubs_NoRecentDraw' as [Source]   --|nvarchar(100)
		--, newid() as [GroupId]
	from @AcctPubsToDeactivate tmp
	join scAccounts a
		on tmp.AccountId = a.AccountID
	join nsPublications p
		on tmp.PublicationId = p.PublicationID
	order by a.AcctCode, p.PubShortName
	
END
GO	

GRANT EXECUTE ON [dbo].[support_DeactivateAcctPubs_NoRecentDraw] TO [nsUser]
GO