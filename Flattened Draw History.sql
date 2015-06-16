declare @drawDate datetime
declare @pubId int
declare @acctId int

set @drawDate = '9/9/2010'
set @pubId = 1
set @acctId = null

select a.AcctCode, p.PubShortName
	, convert(varchar, d1.DrawDate, 1) as [DrawDate1]
		, d1.DrawAmount + isnull(d1.AdjAmount,0) + isnull(d1.AdjAdminAmount,0) + isnull(d1.RetAmount,0) as [Net1]
	, convert(varchar, d2.DrawDate,1) as [DrawDate2]
		, d2.DrawAmount + isnull(d2.AdjAmount,0) + isnull(d2.AdjAdminAmount,0) + isnull(d2.RetAmount,0) as [Net2]
		, convert(varchar, d3.DrawDate,1) as [DrawDate3]
		, d3.DrawAmount + isnull(d3.AdjAmount,0) + isnull(d3.AdjAdminAmount,0) + isnull(d3.RetAmount,0) as [Net3]
	, convert(varchar, d4.DrawDate,1) as [DrawDate4]
		, d4.DrawAmount + isnull(d4.AdjAmount,0) + isnull(d4.AdjAdminAmount,0) + isnull(d4.RetAmount,0) as [Net4]
	, convert(varchar, d5.DrawDate,1) as [DrawDate5]
		, d5.DrawAmount + isnull(d5.AdjAmount,0) + isnull(d5.AdjAdminAmount,0) + isnull(d5.RetAmount,0) as [Net5]
	, convert(varchar, d6.DrawDate,1) as [DrawDate6]
		, d6.DrawAmount + isnull(d6.AdjAmount,0) + isnull(d6.AdjAdminAmount,0) + isnull(d6.RetAmount,0) as [Net6]
	, convert(varchar, d7.DrawDate,1) as [DrawDate7]
		, d7.DrawAmount + isnull(d7.AdjAmount,0) + isnull(d7.AdjAdminAmount,0) + isnull(d7.RetAmount,0) as [Net7]
from scDraws d1
join nsPublications p
	on d1.PublicationId = p.PublicationId
join scAccounts a
	on d1.AccountId = a.AccountId	
left join scDraws d2
	on d1.AccountId = d2.AccountId
	and d1.PublicationId = d2.PublicationId
	and d1.DrawWeekday = d2.DrawWeekday
left join scDraws d3
	on d2.AccountId = d3.AccountId
	and d2.PublicationId = d3.PublicationId
	and d2.DrawWeekday = d3.DrawWeekday
left join scDraws d4
	on d3.AccountId = d4.AccountId
	and d3.PublicationId = d4.PublicationId
	and d3.DrawWeekday = d4.DrawWeekday
left join scDraws d5
	on d4.AccountId = d5.AccountId
	and d4.PublicationId = d5.PublicationId
	and d4.DrawWeekday = d5.DrawWeekday
left join scDraws d6
	on d5.AccountId = d6.AccountId
	and d5.PublicationId = d6.PublicationId
	and d5.DrawWeekday = d6.DrawWeekday
left join scDraws d7
	on d6.AccountId = d7.AccountId
	and d6.PublicationId = d7.PublicationId
	and d6.DrawWeekday = d7.DrawWeekday
where d1.DrawDate = @drawDate
and (
	@pubId is null and p.PublicationId > 0
	or @pubId is not null and p.PublicationId = @pubId 
	)
and (
	@acctId is null and a.AccountId > 0
	or @acctId is not null and a.AccountId = @acctId
	)	
and ( 
	datediff(d, d1.DrawDate, d2.DrawDate) = -7
	)
and ( 
	datediff(d, d2.DrawDate, d3.DrawDate) = -7
	)	
and ( 
	datediff(d, d3.DrawDate, d4.DrawDate) = -7
	)	
and ( 
	datediff(d, d4.DrawDate, d5.DrawDate) = -7
	)	
and ( 
	datediff(d, d5.DrawDate, d6.DrawDate) = -7
	)		
and ( 
	datediff(d, d6.DrawDate, d7.DrawDate) = -7
	)		
