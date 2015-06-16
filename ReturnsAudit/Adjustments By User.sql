	
	declare @threshold int
	set @threshold = 7

	select *, UserName as [ManifestOwnerName]
	into #mfsts
	from dbo.listMfstsAccts('Delivery',null, null, -1, null) m
	join users u
		on m.ManifestOwner = u.UserId
	
	select DrawId, [1] as [AdjAdminAuditValue1], [2] as [AdjAdminAuditValue2], [3] as [AdjAdminAuditValue3], [4] as [AdjAdminAuditValue4], [5] as [AdjAdminAuditValue5]
	into #AdjAdminAuditValues
	from (
		select da.DrawId, da.DrawAdjustmentAuditId, cast(da.AdjAuditValue as int) as [AdjAdminAuditValue]
		from scDrawAdjustmentsAudit da
		join scDraws d
			on da.DrawId = d.DrawId
		where datediff(d, d.DrawDate, getdate()) < @threshold
		and AdjAuditField = 'Admin Amount'
		and AdjAuditValue > 0
		) as t
	pivot (
		sum([AdjAdminAuditValue])
		for DrawAdjustmentAuditId in ([1], [2], [3], [4], [5])
		) as AdjAdminAuditValues

	select DrawId, [1] as [AdjAdminAuditUser1], [2] as [AdjAdminAuditUser2], [3] as [AdjAdminAuditUser3], [4] as [AdjAdminAuditUser4], [5] as [AdjAdminAuditUser5]
	into #AdjAdminAuditUsers
	from (
		select da.DrawId, da.DrawAdjustmentAuditId, UserName as [AdjAdminUser]
		from scDrawAdjustmentsAudit da
		join scDraws d
			on da.DrawId = d.DrawId
		join Users u
			on da.AdjAuditUserId = u.UserId	
		where datediff(d, d.DrawDate, getdate()) < @threshold
		and AdjAuditField = 'Admin Amount'
		and AdjAuditValue > 0
		) as t
	pivot (
		max([AdjAdminUser])
		for DrawAdjustmentAuditId in ([1], [2], [3], [4], [5])
		) as AdjAdminAuditUsers

	select DrawId, [1] as [AdjAdminAuditDate1], [2] as [AdjAdminAuditDate2], [3] as [AdjAdminAuditDate3], [4] as [AdjAdminAuditDate4], [5] as [AdjAdminAuditDate5]
	into #AdjAdminAuditDates
	from (
		select da.DrawId, da.DrawAdjustmentAuditId, AdjAuditDate as [AdjAdminAuditDate]
		from scDrawAdjustmentsAudit da
		join scDraws d
			on da.DrawId = d.DrawId
		where datediff(d, d.DrawDate, getdate()) < @threshold
		and AdjAuditField = 'Admin Amount'
		and AdjAuditValue > 0
		) as t
	pivot (
		max([AdjAdminAuditDate])
		for DrawAdjustmentAuditId in ([1], [2], [3], [4], [5])
		) as AdjAdminAuditDates

	select 
		MfstCode
		, convert(varchar, d.DrawDate, 1) as [DrawDate]
		, m.AcctCode
		, m.PubShortName
		, d.DrawAmount
		, case 
			when AdjAdminAuditUser1 = ManifestOwnerName
				then AdjAdminAuditUser1 + ' (owner)'
			else
				AdjAdminAuditUser1 
			end as AdjAdminAuditUser1 	
		, convert(varchar, AdjAdminAuditDate1) as [AdjAdminAuditDate1]
		, AdjAdminAuditValue1
		, case 
			when AdjAdminAuditUser2 = ManifestOwnerName
				then AdjAdminAuditUser2 + ' (owner)'
			else
				AdjAdminAuditUser2 
			end as AdjAdminAuditUser2 	
		, convert(varchar, AdjAdminAuditDate2) as [AdjAdminAuditDate2]
		, AdjAdminAuditValue2 - AdjAdminAuditValue1 as [AdjAdminAuditValue2]
		, case 
			when AdjAdminAuditUser3 = ManifestOwnerName
				then AdjAdminAuditUser3 + ' (owner)'
			else
				AdjAdminAuditUser3
			end as AdjAdminAuditUser3
		, convert(varchar, AdjAdminAuditDate3) as [AdjAdminAuditDate3]
		, AdjAdminAuditValue3 - AdjAdminAuditValue2 as [AdjAdminAuditValue3]
		, case 
			when AdjAdminAuditUser4 = ManifestOwnerName
				then AdjAdminAuditUser4 + ' (owner)'
			else
				AdjAdminAuditUser4
			end as AdjAdminAuditUser4 	
		, convert(varchar, AdjAdminAuditDate4) as [AdjAdminAuditDate4]
		, AdjAdminAuditValue4 - AdjAdminAuditValue3 as [AdjAdminAuditValue4]
		, case 
			when AdjAdminAuditUser5 = ManifestOwnerName
				then AdjAdminAuditUser5 + ' (owner)'
			else
				AdjAdminAuditUser5
			end as AdjAdminAuditUser5
		, convert(varchar, AdjAdminAuditDate5) as [AdjAdminAuditDate5]
		, AdjAdminAuditValue5 - AdjAdminAuditValue4 as [AdjAdminAuditValue5]
	from #AdjAdminAuditUsers u
	join #AdjAdminAuditValues v
		on u.DrawId = v.DrawId
	join #AdjAdminAuditDates dt
		on u.DrawId = dt.DrawId
	join scDraws d
		on v.DrawId = d.DrawId
	join #mfsts m
		on d.AccountId = m.AccountId
		and d.PublicationId = m.PublicationId
		and dbo.scGetDayFrequency(d.DrawDate) & m.Frequency > 0
	order by m.MfstCode, d.DrawDate, m.AcctCode, m.PubShortName

	
drop table #mfsts
drop table #AdjAdminAuditValues
drop table #AdjAdminAuditDates
drop table #AdjAdminAuditUsers