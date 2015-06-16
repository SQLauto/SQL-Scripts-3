	
	;with cteReturns_Prelim ( DrawId, DrawDate, AccountId, PublicationId, ReturnsAuditId, RetAuditUser, RetAuditValue, RetAuditDate, Diff )
	as 
		(
		select d.DrawId, d.DrawDate, d.AccountId, d.PublicationId, ra.ReturnsAuditId, u.UserName, ra.RetAuditValue, ra.RetAuditDate, cast(ra.RetAuditValue as int)
		from scDraws d
		join scReturnsAudit ra
			on d.DrawId = ra.DrawId
		join Users u
			on ra.RetAuditUserId = u.UserID	
		where DATEDIFF(d, RetExpDateTime, getdate()) = 0
		and ReturnsAuditId = 1
		union all 
			select d.DrawId, d.DrawDate, d.AccountId, d.PublicationId, ra.ReturnsAuditId, u.UserName, ra.RetAuditValue, ra.RetAuditDate, cast(ra.RetAuditValue as int) - cast(cte.RetAuditValue as int) as [Diff]
			from scDraws d
			join scReturnsAudit ra
				on d.DrawId = ra.DrawId
			join Users u
				on ra.RetAuditUserId = u.UserID	
			join cteReturns_Prelim cte
				on cte.DrawId = d.DrawId
				and cte.ReturnsAuditId + 1 = ra.ReturnsAuditId
		)
		
	select a.AcctCode, tmp.ReturnsAuditId, cte.*
	from cteReturns_Prelim cte
	join scAccounts a
		on cte.AccountId = a.AccountID
	join #LastReturn tmp
		on cte.DrawId = tmp.DrawId	
		and cte.ReturnsAuditId = tmp.ReturnsAuditId
	where RetAuditDate < '2012-03-12 15:04:40.113'
	order by DrawId