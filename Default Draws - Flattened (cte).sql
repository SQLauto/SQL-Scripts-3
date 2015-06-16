

;with cte
as (
	select 1 as dw
		, a.AcctCode, p.PubShortName
		, CASE DrawWeekday when 1 then dd.DrawAmount
			else null end as [SUN]
		, CASE DrawWeekday when 2  then dd.DrawAmount
			else null end as [MON]
		, CASE DrawWeekday when 3  then dd.DrawAmount
			else null end as [TUE]	
		, CASE DrawWeekday when 4  then dd.DrawAmount
			else null end as [WED]
		, CASE DrawWeekday when 5  then dd.DrawAmount
			else null end as [THU]
		, CASE DrawWeekday when 6  then dd.DrawAmount
			else null end as [FRI]
		, CASE DrawWeekday when 7  then dd.DrawAmount
			else null end as [SAT]
	from scDefaultDraws dd
	join scAccountsPubs ap
		on dd.AccountId = ap.AccountID
		and dd.PublicationID = ap.PublicationId
	join scAccounts a
		on ap.AccountId = a.AccountID
	join nsPublications p
		on ap.PublicationId = p.PublicationID
	where dd.DrawWeekday = 1
	union all
	select dw + 1
		, a.AcctCode, p.PubShortName
		, CASE DrawWeekday when 1 then dd.DrawAmount
			else null end as [SUN]
		, CASE DrawWeekday when 2  then dd.DrawAmount
			else null end as [MON]
		, CASE DrawWeekday when 3  then dd.DrawAmount
			else null end as [TUE]	
		, CASE DrawWeekday when 4  then dd.DrawAmount
			else null end as [WED]
		, CASE DrawWeekday when 5  then dd.DrawAmount
			else null end as [THU]
		, CASE DrawWeekday when 6  then dd.DrawAmount
			else null end as [FRI]
		, CASE DrawWeekday when 7  then dd.DrawAmount
			else null end as [SAT]
	from scDefaultDraws dd
	join scAccounts a
		on dd.AccountId = a.AccountID
	join nsPublications p
		on dd.PublicationId = p.PublicationID
	join cte
		on cte.AcctCode = a.AcctCode
		and cte.PubShortName = p.PubShortName
		
	where dd.DrawWeekday = dw + 1
	and dw + 1 <= 7
)
select AcctCode, PubShortName
		, MAX(SUN) as SUN
		, MAX(MON) as MON
		, MAX(TUE) as TUE
		, MAX(WED) as WED
		, MAX(THU) as THU
		, MAX(FRI) as FRI
		, MAX(SAT) as SAT
from cte
group by AcctCode, PubShortName
order by AcctCode
