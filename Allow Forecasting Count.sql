

;with cteDefaultDraws
as
(
	select dd.accountid
		, case	
			when sum(allowforecasting) > 0 then 'Yes'
			else 'No'
			end as [allowforecasting]
	from scdefaultdraws dd
	join scaccounts a
		on dd.accountid = a.accountid
	join scaccountspubs ap
		on dd.accountid = ap.accountid
		and dd.publicationid = ap.publicationid	
	where a.acctactive = 1
	and ap.active = 1
	group by dd.accountid
)
select allowforecasting as [Allows Forecasting], count(*) as [# of Accts]
from ctedefaultdraws
group by allowforecasting
