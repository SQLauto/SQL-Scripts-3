

;with cteDefaultDraw
as (
	select 1 as dw
		, a.AccountId, p.PublicationId
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
	join Users u
		on a.AcctOwner = u.UserID		
	where dd.DrawWeekday = 1
	and u.UserName = 'djose@dcmdistribution.com'
	union all
	select dw + 1
		, a.AccountId, p.PublicationId
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
	join cteDefaultDraw cte
		on cte.AccountID = a.AccountID
		and cte.PublicationID = p.PublicationID
		
	where dd.DrawWeekday = dw + 1
	and dw + 1 <= 7
)
, cteDefaultDraw_Flat as (
	select 
		AccountID, PublicationID
		, MAX(SUN) as SUN
		, MAX(MON) as MON
		, MAX(TUE) as TUE
		, MAX(WED) as WED
		, MAX(THU) as THU
		, MAX(FRI) as FRI
		, MAX(SAT) as SAT
		
	from cteDefaultDraw
	group by AccountID, PublicationID
)
select a.AcctCode, p.PubShortName, a.AcctActive, ap.Active as [PubActive]
		, case when ap.APCustom3 <> '' then ap.APCustom3
			else r.RollupCode end as [RollupCode]
		, cte.SUN, cte.MON, cte.TUE, cte.WED, cte.THU, cte.FRI, cte.SAT
from cteDefaultDraw_Flat cte
join scAccounts a
	on cte.AccountID = a.AccountID
join nsPublications p
	on cte.PublicationId = p.PublicationID	
join Users u
	on a.AcctOwner = u.UserID
left join scChildAccounts ca
	on a.AccountID = ca.ChildAccountID
left join scRollups r
	on ca.AccountID = r.RollupID
join scAccountsPubs ap
	on a.AccountID = ap.AccountId
	and p.PublicationID = ap.PublicationId
order by AcctCode
