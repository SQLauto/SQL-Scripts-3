

;with cteDefaultDraw
as (
	select 1 as dw
		, a.AccountId, p.PublicationId
		, CASE DrawWeekday when 1 then dd.DrawAmount
			else null end as [SUN]
		, CASE DrawWeekday when 1 then dd.DrawRate
			else null end as [SUN_RATE]
		, CASE DrawWeekday when 2  then dd.DrawAmount
			else null end as [MON]
		, CASE DrawWeekday when 2  then dd.DrawRate
			else null end as [MON_RATE]
		, CASE DrawWeekday when 3  then dd.DrawAmount
			else null end as [TUE]	
		, CASE DrawWeekday when 3  then dd.DrawRate
			else null end as [TUE_RATE]	
		, CASE DrawWeekday when 4  then dd.DrawAmount
			else null end as [WED]
		, CASE DrawWeekday when 4  then dd.DrawRate
			else null end as [WED_RATE]
		, CASE DrawWeekday when 5  then dd.DrawAmount
			else null end as [THU]
		, CASE DrawWeekday when 5  then dd.DrawRate
			else null end as [THU_RATE]
		, CASE DrawWeekday when 6  then dd.DrawAmount
			else null end as [FRI]
		, CASE DrawWeekday when 6  then dd.DrawRate
			else null end as [FRI_RATE]
		, CASE DrawWeekday when 7  then dd.DrawAmount
			else null end as [SAT]
		, CASE DrawWeekday when 7  then dd.DrawRate
			else null end as [SAT_RATE]
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
	--and u.UserName = 'djose@dcmdistribution.com'
	union all
	select dw + 1
		, a.AccountId, p.PublicationId
		, CASE DrawWeekday when 1 then dd.DrawAmount
			else null end as [SUN]
		, CASE DrawWeekday when 1 then dd.DrawRate
			else null end as [SUN_RATE]
		, CASE DrawWeekday when 2  then dd.DrawAmount
			else null end as [MON]
		, CASE DrawWeekday when 2  then dd.DrawRate
			else null end as [MON_RATE]
		, CASE DrawWeekday when 3  then dd.DrawAmount
			else null end as [TUE]	
		, CASE DrawWeekday when 3  then dd.DrawRate
			else null end as [TUE_RATE]	
		, CASE DrawWeekday when 4  then dd.DrawAmount
			else null end as [WED]
		, CASE DrawWeekday when 4  then dd.DrawRate
			else null end as [WED_RATE]
		, CASE DrawWeekday when 5  then dd.DrawAmount
			else null end as [THU]
		, CASE DrawWeekday when 5  then dd.DrawRate
			else null end as [THU_RATE]
		, CASE DrawWeekday when 6  then dd.DrawAmount
			else null end as [FRI]
		, CASE DrawWeekday when 6  then dd.DrawRate
			else null end as [FRI_RATE]
		, CASE DrawWeekday when 7  then dd.DrawAmount
			else null end as [SAT]
		, CASE DrawWeekday when 7  then dd.DrawRate
			else null end as [SAT_RATE]
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
		, MAX(SUN_RATE) as SUN_RATE
		, MAX(MON) as MON
		, MAX(MON_RATE) as MON_RATE
		, MAX(TUE) as TUE
		, MAX(TUE_RATE) as TUE_RATE
		, MAX(WED) as WED
		, MAX(WED_RATE) as WED_RATE
		, MAX(THU) as THU
		, MAX(THU_RATE) as THU_RATE
		, MAX(FRI) as FRI
		, MAX(FRI_RATE) as FRI_RATE
		, MAX(SAT) as SAT
		, MAX(SAT_RATE) as SAT_RATE
				
	from cteDefaultDraw
	group by AccountID, PublicationID
)
, cteMfstAccts as (
	select
		a.AcctCode, MTCode, MTName
		, typ.ManifestTypeDescription as [Type]
		, PubShortName 
		, a.AccountId, p.PublicationId, ap.AccountPubID 
		, mst.ManifestSequenceTemplateId
	from nsPublications p
	join scAccountsPubs ap
		on p.PublicationID = ap.PublicationId
	join scManifestSequenceItems msi
		on ap.AccountPubID = msi.AccountPubId
	join scManifestSequenceTemplates mst
		on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId	
	join scManifestTemplates mt
		on mst.ManifestTemplateId = mt.ManifestTemplateId
	join scAccounts a
		on ap.AccountId = a.AccountID	
	join dd_scManifestTypes typ
		on mt.ManifestTypeId = typ.ManifestTypeId	
	--order by AcctCode
)
select '"' + a.AcctCode + '"', a.acctname, p.PubShortName
	, a.acctaddress, a.acctcity, a.acctstateprovince, a.acctpostalcode
	, m.MTCode as [Manifest]	
	, cte.SUN as [SUN_DRAW], cte.SUN_RATE
	, cte.MON as [MON_DRAW], cte.MON_RATE
	, cte.TUE as [TUE_DRAW], cte.TUE_RATE
	, cte.WED as [WED_DRAW], cte.WED_RATE
	, cte.THU as [THU_DRAW], cte.THU_RATE
	, cte.FRI as [FRI_DRAW], cte.FRI_RATE
	, cte.SAT as [SAT_DRAW], cte.SAT_RATE
	
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
left join cteMfstAccts m
	on a.AcctCode = m.AcctCode
	and p.PubShortName = m.PubShortName
order by 1
