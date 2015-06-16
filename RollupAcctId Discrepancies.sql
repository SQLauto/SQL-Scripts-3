begin tran

select DrawId, DrawDate, DATENAME(dw, drawdate) as [dow], RetAmount, RetExportLastAmt, RetExpDateTime
	, case when ca.AccountID is not null then 'Child Account' else '' end as [IsChildAccount]
	, RollupAcctID as [RollupAcctId (scDraws)]
	, ca.AccountID as [RollupAcctId]
from scDraws d
join scAccounts a
	on d.AccountID = a.AccountID
left join scChildAccounts ca
	on a.AccountID = ca.ChildAccountID
where DrawDate between '11/14/2011' and '11/20/2011'
--and DATENAME(dw, drawdate) in ('thursday', 'saturday', 'sunday')
and ( 
	(ca.AccountID is not null and RollupAcctID is null)
	or
	(ca.AccountID <> RollupAcctID)
	)
order by DrawDate


update scDraws
set RollupAcctID = ca.AccountID
from scDraws d
join scAccounts a
	on d.AccountID = a.AccountID
left join scChildAccounts ca
	on a.AccountID = ca.ChildAccountID
where DrawDate between '11/14/2011' and '11/20/2011'
--and DATENAME(dw, drawdate) in ('thursday', 'saturday', 'sunday')
and ( 
	(ca.AccountID is not null and RollupAcctID is null)
	or
	(ca.AccountID <> RollupAcctID)
	)


rollback tran