

select a.AcctCode, convert(varchar, d.DrawDate, 1) as [DrawDate], p.PubShortName, d.DrawAmount, a.AcctImported, a.AcctActive, ap.Active
	, r.RollupID
from scDraws d
join scAccounts a
	on d.accountid = a.AccountID
join nsPublications p
	on d.publicationid = p.PublicationID
left join scChildAccounts ca
		on a.AccountID = ca.ChildAccountID
join scRollups r
		on ca.AccountID = r.RollupID
join scAccountsPubs ap
	on d.AccountID = ap.AccountId
	and d.PublicationID = ap.PublicationId	
where d.DrawDate between '11/11/2011' and '11/11/2011'
and r.rollupCode = 'R52951'
and a.AcctActive = 1
order by a.AcctCode, d.DrawDate

select a.AcctCode, convert(varchar, d.DrawDate, 1) as [DrawDate], p.PubShortName, d.DrawAmount, a.AcctImported, a.AcctActive, ap.Active
from scDraws d
join scAccounts a
	on d.accountid = a.AccountID
join nsPublications p
	on d.publicationid = p.PublicationID
left join scChildAccounts ca
		on a.AccountID = ca.ChildAccountID
join scRollups r
		on ca.AccountID = r.RollupID
join scAccountsPubs ap
	on d.AccountID = ap.AccountId
	and d.PublicationID = ap.PublicationId	
where d.DrawDate between '11/18/2011' and '11/18/2011'
and r.rollupCode = 'R52951'
and a.AcctActive = 1
order by a.AcctCode, d.DrawDate