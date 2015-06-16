begin tran
	set nocount on

	declare @threshold int  --|  number of days with zero draw

	set @threshold = 7

	print  'Accts/Pubs with no draw since ' + convert(varchar, dateadd(d, -1*@threshold, convert(varchar, getdate(), 1)), 101) + ' will be deactivated'
	
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
	where lastNonZeroDrawDate < dateadd(d, -1*@threshold, convert(varchar, getdate(), 1))
	and ap.Active = 1
	order by cast(LastNonZeroDrawDate as datetime) desc
	print 'Found ' + cast(@@rowcount as varchar) + ' AcctPubs to deactivate'

	--|  zero out default draw
	update scDefaultDraws
	set DrawAmount = 0
	from scDefaultDraws dd
	join @AcctPubsToDeactivate tmp
		on dd.AccountID = tmp.AccountId
		and dd.PublicationID = tmp.PublicationId
	print 'Zeroed out Default Draw for ' + cast(@@rowcount/7 as varchar) + ' AcctPubs'

	--|  zero out future draw
	update scDraws 
	set DrawAmount = 0
	from scDraws d
	join @AcctPubsToDeactivate tmp
		on d.AccountID = tmp.AccountId
		and d.PublicationID = tmp.PublicationId
	where d.DrawDate > getdate()
	and d.DrawAmount > 0
	print 'Zeroed out ' + cast(@@rowcount as varchar) + ' non-zero scDraws records'
	
	--|  deactivate AcctsPubs
	update scAccountsPubs
	set Active = 0
	from scAccountsPubs ap
	join @AcctPubsToDeactivate tmp
		on ap.AccountId = tmp.AccountId
		and ap.PublicationId = tmp.PublicationId
	print 'Deactivated ' + cast(@@rowcount as varchar) + ' AcctPubs'

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
	print 'Deactivated ' + cast(@@rowcount as varchar) + ' Accounts where all Pubs are inactive'


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
		, N'support_DeactivateAcctPubs' as [Source]   --|nvarchar(100)
		--, newid() as [GroupId]
	from @AcctPubsToDeactivate tmp
	join scAccounts a
		on tmp.AccountId = a.AccountID
	join nsPublications p
		on tmp.PublicationId = p.PublicationID
	order by a.AcctCode, p.PubShortName




rollback tran