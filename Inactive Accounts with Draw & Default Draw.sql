

select a.AcctCode, p.PubShortName, 
	case dd.drawweekday
		when 1 then 'SUN'
		when 2 then 'MON'
		when 3 then 'TUE'
		when 4 then 'WED'
		when 5 then 'THU'
		when 6 then 'FRI'
		when 7 then 'SAT'
		end as [DrawWeekday]
		, dd.DrawAmount
		, a.AcctActive
		, ap.Active as [AcctPubActive]
from scaccounts a
join scAccountsPubs ap
	on a.accountid = ap.AccountId
join scDefaultDraws dd
	on ap.AccountId = dd.AccountID
	and ap.PublicationId = dd.PublicationID
join nsPublications p
	on ap.PublicationId = p.PublicationID	
where ( a.AcctActive = 0
		or ap.Active = 0 )
and dd.DrawAmount > 0
order by AcctCode, PubShortName, dd.DrawWeekday



select a.AcctCode, p.PubShortName
	, d.DrawDate
	, case dd.drawweekday
		when 1 then 'SUN'
		when 2 then 'MON'
		when 3 then 'TUE'
		when 4 then 'WED'
		when 5 then 'THU'
		when 6 then 'FRI'
		when 7 then 'SAT'
		end as [DrawWeekday]
		, dd.DrawAmount
		, d.DrawAmount
		, a.AcctActive
		, ap.Active as [AcctPubActive]
from scaccounts a
join scAccountsPubs ap
	on a.accountid = ap.AccountId
join nsPublications p
	on ap.PublicationId = p.PublicationID	
join scDefaultDraws dd
	on ap.AccountId = dd.AccountID
	and ap.PublicationId = dd.PublicationID
join scDraws d
	on dd.AccountID = d.AccountID
	and dd.PublicationID = d.PublicationID
	and dd.DrawWeekday = d.DrawWeekday
where ( a.AcctActive = 0
		or ap.Active = 0 )
and d.DrawDate in ( '3/7/2014' , '3/9/2014' )
and d.DrawAmount > 0
order by AcctCode, PubShortName, d.DrawDate