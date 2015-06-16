	declare @entryStartDate datetime
	declare @entryEndDate datetime

	
	set @entryStartDate = '2/22/2015'
	set @entryEndDate = convert(varchar, @entryStartDate,101) + ' 23:59:59'	

	;with cteReturns_Prelim ( DrawId, DrawDate, AccountId, PublicationId, ReturnsAuditId, RetAuditUser, RetAuditValue, RetAuditDate, Diff )
	as 
		(
		select d.DrawId, d.DrawDate, d.AccountId, d.PublicationId, ra.ReturnsAuditId, u.UserName, ra.RetAuditValue, ra.RetAuditDate, cast(ra.RetAuditValue as int)
		from scDraws d
		join scReturnsAudit ra
			on d.DrawId = ra.DrawId
		join Users u
			on ra.RetAuditUserId = u.UserID
		where ra.RetAuditDate between @entryStartDate and @entryEndDate
		and ReturnsAuditId = 1
		union all 
			select d.DrawId, d.DrawDate, d.AccountId, d.PublicationId, ra.ReturnsAuditId, u.UserName, ra.RetAuditValue
				, ra.RetAuditDate, cast(ra.RetAuditValue as int) - cast(cte.RetAuditValue as int) as [Diff]
			from scDraws d
			join scReturnsAudit ra
				on d.DrawId = ra.DrawId
			join Users u
				on ra.RetAuditUserId = u.UserID	
			join cteReturns_Prelim cte
				on cte.DrawId = d.DrawId
				and cte.ReturnsAuditId + 1 = ra.ReturnsAuditId
			where ra.RetAuditDate between @entryStartDate and @entryEndDate	
		)
	, cteManifests as (
			select
			ap.AccountId
		,	ap.PublicationId
		,	m.ManifestDate
		,	m.MfstCode
		from (
			select distinct AccountId, PublicationId, RetAuditDate
			from cteReturns_Prelim 
		) tmp
		join scAccountsPubs ap on ap.AccountId = tmp.AccountId and ap.PublicationId = tmp.PublicationId
		join scManifestSequences ms on ms.AccountPubId = ap.AccountPubID
		join scManifests m on m.ManifestID = ms.ManifestId
			and m.ManifestDate = convert(varchar, tmp.RetAuditDate, 1)
		where m.ManifestDate between @entryStartDate and @entryEndDate
		and m.ManifestTypeId = 1
		)
	select a.AcctCode
		, d.DrawAmount, d.RetAmount
		, cte.*
		, m.MfstCode
	from cteReturns_Prelim cte
	left join cteManifests m
		on cte.AccountId = m.AccountId
		and cte.PublicationId = m.PublicationId
		and convert(varchar, cte.RetAuditDate, 1) = m.ManifestDate
	join scAccounts a
		on cte.AccountId = a.AccountID
	join nsPublications p
		on cte.PublicationId = p.PublicationID	
	join scDraws d
		on cte.DrawId = d.DrawID	
	--where a.AccountId = 1636
	order by AcctCode, PubShortName
	
	
	exec ReturnsAdjustmentsSource @entryStartDate = '02-22-2015', 
@entryEndDate = '02-22-2015', @drawStartDate = null, @drawEndDate = 
null, @userName = null, @entryType = null
	
	-- support_account '102775', 'inc'
	
	