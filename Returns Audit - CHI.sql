declare @thresholdDate datetime
set @thresholdDate = '2/1/2011'

	select DrawId, [1] as [RetAuditValue1], [2] as [RetAuditValue2], [3] as [RetAuditValue3], [4] as [RetAuditValue4], [5] as [RetAuditValue5]
	into #RetAuditValues
	from (
		select d.DrawID, ra.ReturnsAuditId, cast(ra.RetAuditValue as int) as [RetAuditValue]
		from scDraws d
		join scReturnsAudit ra
			on d.DrawID = ra.DrawId
		where d.DrawDate >= @thresholdDate
		) as t
	pivot (
		sum(RetAuditValue)
		for ReturnsAuditId in ([1], [2], [3], [4], [5])
		) as RetAuditValues

	select DrawId, [1] as [RetAuditDate1], [2] as [RetAuditDate2], [3] as [RetAuditDate3], [4] as [RetAuditDate4], [5] as [RetAuditDate5]
	into #RetAuditDates
	from (
		select d.DrawID, ra.ReturnsAuditId, ra.RetAuditDate
		from scDraws d
		join scReturnsAudit ra
			on d.DrawID = ra.DrawId
		where d.DrawDate >= @thresholdDate
		) as t
	pivot (
		max(RetAuditDate)
		for ReturnsAuditId in ([1], [2], [3], [4], [5])
		) as p		

	select
		  a.AcctCode
		, p.PubShortName
		, d.DrawDate
		, dbo.scGetDayFrequency( d.DrawDate ) as [Frequency]
		, d.DrawAmount
		, cast(RetAuditDate1 as varchar) as [RetAuditDate1]
		, RetAuditValue1
		, cast(RetAuditDate2 as varchar) as [RetAuditDate2]
		, RetAuditValue2
		, cast(RetAuditDate3 as varchar) as [RetAuditDate3]
		, RetAuditValue3
		, cast(RetAuditDate4 as varchar) as [RetAuditDate4]
		, RetAuditValue4
		, cast(RetAuditDate5 as varchar) as [RetAuditDate5]
		, RetAuditValue5
	into #results	
	from #RetAuditValues rv
	join #RetAuditDates rd
		on rv.DrawId = rd.DrawId
	join scDraws d
		on rv.DrawId = d.DrawId	
	join scAccounts a
		on d.AccountId = a.AccountId
	join nsPublications p
		on d.PublicationId = p.PublicationId

	select m.MfstCode, tmp.AcctCode, tmp.PubShortName
		, convert(varchar, tmp.DrawDate, 1) as [DrawDate]
		, RetAuditDate1, RetAuditValue1
		, RetAuditDate2, RetAuditValue2
		, RetAuditDate3, RetAuditValue3
		, RetAuditDate4, RetAuditValue4
		, RetAuditDate5, RetAuditValue5
	from #results tmp
	join dbo.listMfstsAccts('Delivery','83',null,-1,null) m
		on tmp.AcctCode = m.AcctCode
		and tmp.PubShortName = m.PubShortName
		and tmp.Frequency & m.Frequency > 0
	where RetAuditDate2 is not null 	
	
	drop table #RetAuditValues
	drop table #RetAuditDates
	drop table #results