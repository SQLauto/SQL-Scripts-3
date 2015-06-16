	declare @threshold int
	set @threshold = 7

	select *, UserName as [ManifestOwnerName]
	into #mfsts
	from dbo.listMfstsAccts('Delivery',null, null, -1, null) m
	join users u
		on m.ManifestOwner = u.UserId
	
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

	select DrawId, [1] as [RetAuditUser1], [2] as [RetAuditUser2], [3] as [RetAuditUser3], [4] as [RetAuditUser4], [5] as [RetAuditUser5]
	into #RetAuditUsers
	from (
		select ra.DrawId, ra.ReturnsAuditId, u.UserName as [RetAuditUser] --cast(ra.RetAuditUserId as int) as [RetAuditUser]
		from scReturnsAudit ra
		join scDraws d
			on ra.DrawId = d.DrawId
		join Users u
			on ra.RetAuditUserId = u.UserId
		where datediff(d, d.DrawDate, getdate()) < @threshold
		) as t
	pivot (
		max(RetAuditUser)
		for ReturnsAuditId in ([1], [2], [3], [4], [5])
		) as RetAuditUsers

	select DrawId, [1] as [RetAuditDate1], [2] as [RetAuditDate2], [3] as [RetAuditDate3], [4] as [RetAuditDate4], [5] as [RetAuditDate5]
	into #RetAuditDates
	from (
		select d.DrawID, ra.ReturnsAuditId, ra.RetAuditDate
		from scDraws d
		join scReturnsAudit ra
			on d.DrawID = ra.DrawId
		where datediff(d, d.DrawDate, getdate()) < @threshold
		) as t
	pivot (
		max(RetAuditDate)
		for ReturnsAuditId in ([1], [2], [3], [4], [5])
		) as p		

	select 
		MfstCode
		, convert(varchar, d.DrawDate, 1) as [DrawDate]
		, m.AcctCode
		, m.PubShortName
		, d.DrawAmount
		, case 
			when RetAuditUser1 = ManifestOwnerName
				then RetAuditUser1 + ' (owner)'
			else
				RetAuditUser1 
			end as RetAuditUser1 	
		, convert(varchar, RetAuditDate1) as [RetAuditDate1]
		, RetAuditValue1
		, case 
			when RetAuditUser2 = ManifestOwnerName
				then RetAuditUser2 + ' (owner)'
			else
				RetAuditUser2 
			end as RetAuditUser2 	
		, convert(varchar, RetAuditDate2) as [RetAuditDate2]
		, RetAuditValue2 - RetAuditValue1 as [RetAuditValue2]
		, case 
			when RetAuditUser3 = ManifestOwnerName
				then RetAuditUser3 + ' (owner)'
			else
				RetAuditUser3
			end as RetAuditUser3
		, convert(varchar, RetAuditDate3) as [RetAuditDate3]
		, RetAuditValue3 - RetAuditValue2 as [RetAuditValue3]
		, case 
			when RetAuditUser4 = ManifestOwnerName
				then RetAuditUser4 + ' (owner)'
			else
				RetAuditUser4
			end as RetAuditUser4 	
		, convert(varchar, RetAuditDate4) as [RetAuditDate4]
		, RetAuditValue4 - RetAuditValue3 as [RetAuditValue4]
		, case 
			when RetAuditUser5 = ManifestOwnerName
				then RetAuditUser5 + ' (owner)'
			else
				RetAuditUser5
			end as RetAuditUser5
		, convert(varchar, RetAuditDate5) as [RetAuditDate5]
		, RetAuditValue5 - RetAuditValue4 as [RetAuditValue5]
	from #RetAuditUsers u
	join #RetAuditValues v
		on u.DrawId = v.DrawId
	join #RetAuditDates dt
		on u.DrawId = dt.DrawId
	join scDraws d
		on v.DrawId = d.DrawId
	join #mfsts m
		on d.AccountId = m.AccountId
		and d.PublicationId = m.PublicationId
		and dbo.scGetDayFrequency(d.DrawDate) & m.Frequency > 0
	order by m.MfstCode, d.DrawDate, m.AcctCode, m.PubShortName
		

	
drop table #mfsts
drop table #RetAuditValues
drop table #RetAuditDates
drop table #RetAuditUsers