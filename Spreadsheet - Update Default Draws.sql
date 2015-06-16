
begin tran

;with cteDefaultDraws
as (
	select dd.AccountID, a.AcctCode, dd.PublicationID, p.PubShortName
		, dd.DrawWeekday
		, case 
			when dd.DrawWeekday = 1 then SUN
			when dd.DrawWeekday = 2 then MON
			when dd.DrawWeekday = 3 then TUE
			when dd.DrawWeekday = 4 then WED
			when dd.DrawWeekday = 5 then THU
			when dd.DrawWeekday = 6 then FRI
			when dd.DrawWeekday = 7 then SAT
			end as [DrawAmount]
			--, SUN, MON, TUE, WED, THU, FRI, SAT
			
	from [WSJ DefaultDraws No Inactive(1)] tmp
	join scAccounts a
		on tmp.AcctCode = a.AcctCode
	join nsPublications p
		on tmp.PubShortName = p.PubShortName
	join scDefaultDraws dd
		on a.AccountID = dd.AccountID
		and p.PublicationID = dd.PublicationID
	--order by tmp.AcctCode
)
select cte.*
	, dd.DrawAmount as [OldDrawAmount]
into support_DefaultDrawUpdate_05132013
from cteDefaultDraws cte
join scDefaultDraws dd
	on cte.AccountID = dd.AccountID	
	and cte.PublicationID = dd.PublicationID
	and cte.DrawWeekday = dd.DrawWeekday
where cte.DrawAmount <> dd.DrawAmount

update scDefaultDraws
set DrawAmount = bkp.DrawAmount
from support_DefaultDrawUpdate_05132013 bkp
join scDefaultDraws dd
	on bkp.AccountID = dd.AccountID	
	and bkp.PublicationID = dd.PublicationID
	and bkp.DrawWeekday = dd.DrawWeekday
where bkp.DrawAmount <> dd.DrawAmount

select *
from support_DefaultDrawUpdate_05132013

;with cteDefaultDraws
as (
	select dd.AccountID, a.AcctCode, dd.PublicationID, p.PubShortName
		, dd.DrawWeekday
		, case 
			when dd.DrawWeekday = 1 then SUN
			when dd.DrawWeekday = 2 then MON
			when dd.DrawWeekday = 3 then TUE
			when dd.DrawWeekday = 4 then WED
			when dd.DrawWeekday = 5 then THU
			when dd.DrawWeekday = 6 then FRI
			when dd.DrawWeekday = 7 then SAT
			end as [DrawAmount]
			--, SUN, MON, TUE, WED, THU, FRI, SAT
			
	from [WSJ DefaultDraws No Inactive(1)] tmp
	join scAccounts a
		on tmp.AcctCode = a.AcctCode
	join nsPublications p
		on tmp.PubShortName = p.PubShortName
	join scDefaultDraws dd
		on a.AccountID = dd.AccountID
		and p.PublicationID = dd.PublicationID
	--order by tmp.AcctCode
)
select cte.*
	, dd.DrawAmount as [OldDrawAmount]
from cteDefaultDraws cte
join scDefaultDraws dd
	on cte.AccountID = dd.AccountID	
	and cte.PublicationID = dd.PublicationID
	and cte.DrawWeekday = dd.DrawWeekday
where cte.DrawAmount <> dd.DrawAmount

commit tran