;with cteWk1
as (
select DrawId, d.AccountID, DrawDate, DATENAME(dw, drawdate) as [Weekday], DrawAmount
	, case when ca.AccountID is not null then 1 else 0 end as [IsChildAccount]
	, RollupAcctID
	, ca.AccountID as [RollupAcct]
from scDraws d
join scAccounts a
	on d.AccountID = a.AccountID
left join scChildAccounts ca
	on a.AccountID = ca.ChildAccountID
where DrawDate = '11/18/2011'
), cteWk2
as (
select DrawId, d.AccountID, DrawDate, DATENAME(dw, drawdate) as [Weekday], DrawAmount
	, case when ca.AccountID is not null then 1 else 0 end as [IsChildAccount]
	, RollupAcctID
	, ca.AccountID as [RollupAcct]
from scDraws d
join scAccounts a
	on d.AccountID = a.AccountID
left join scChildAccounts ca
	on a.AccountID = ca.ChildAccountID
where DrawDate = '11/11/2011'
)
, cteWk3
as (
select DrawId, d.AccountID, DrawDate, DATENAME(dw, drawdate) as [Weekday], DrawAmount
	, case when ca.AccountID is not null then 1 else 0 end as [IsChildAccount]
	, RollupAcctID
	, ca.AccountID as [RollupAcct]
from scDraws d
join scAccounts a
	on d.AccountID = a.AccountID
left join scChildAccounts ca
	on a.AccountID = ca.ChildAccountID
where DrawDate = '11/04/2011'
)
select w1.AccountID, w1.RollupAcctID, w2.RollupAcctID, w3.RollupAcctID, w1.RollupAcct
from cteWk1 w1
join cteWk2 w2
	on w1.AccountID = w2.AccountID
left join cteWk3 w3
	on w2.AccountID = w3.AccountID
where ( 
	isnull(w1.RollupAcctID,'') <> isnull(w2.RollupAcctID,'')
	or isnull(w2.RollupAcctID,'') <> isnull(w3.RollupAcctID,'')
	)
	