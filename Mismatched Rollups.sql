begin tran

;with cteMismatchedRollups
as (
	select d.AccountID, d.PublicationID, d.DrawDate, d.DrawAmount
		, d.RollupAcctID as [scDraws_RollupAcctID], ca.AccountID as [scChildAccounts_RollupID]
	from scDraws d
	join scChildAccounts ca
		on d.AccountID = ca.ChildAccountID
	where isnull(d.RollupAcctID,0) <> ca.AccountID
	and d.DrawDate = '3/25/2013'
)
select a.acctcode
	, p.PubShortName
	--, r.RollupCode--, ap.APCustom3
	, cte.scDraws_RollupAcctID, dr.RollupCode
	, cte.scChildAccounts_RollupID, cr.RollupCode
	--, typ.ATName
from cteMismatchedRollups cte
join scAccounts a
	on cte.AccountID = a.AccountID
join nsPublications p
	on cte.PublicationId = p.PublicationID
join scAccountsPubs ap
	on a.AccountID = ap.AccountId
	and p.PublicationID = ap.PublicationId	
--join dd_scAccountTypes typ
--	on a.AccountTypeID = typ.AccountTypeID		
left join scChildAccounts ca
	on a.AccountID = ca.ChildAccountID
--left join scRollups r
--	on ca.AccountID = r.RollupID			
left join scRollups dr
	on cte.scDraws_RollupAcctID = dr.RollupID
left join scRollups cr
	on cte.scChildAccounts_RollupID = cr.RollupID
order by cr.RollupCode, a.AcctCode

/*	
;with cteMismatchedRollups
as (
	select d.AccountID, d.PublicationID, d.DrawID, d.DrawDate, d.DrawAmount
		, d.RollupAcctID as [scDraws_RollupAcctID], ca.AccountID as [scChildAccounts_RollupID]
	from scDraws d
	join scChildAccounts ca
		on d.AccountID = ca.ChildAccountID
	where isnull(d.RollupAcctID,0) <> ca.AccountID
	and d.DrawDate >= '3/4/2013'
)
update scDraws
set RollupAcctID = cte.scChildAccounts_RollupID
from cteMismatchedRollups cte
join scDraws d
	on cte.DrawID = d.DrawID
*/	
rollback tran