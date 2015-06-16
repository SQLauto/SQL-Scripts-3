

select a.AcctCode, convert(varchar, d.DrawDate, 1) as [DrawDate], p.PubShortName, d.DrawAmount
from scDraws d
join scAccounts a
	on d.accountid = a.AccountID
join nsPublications p
	on d.publicationid = p.PublicationID
left join scChildAccounts ca
		on a.AccountID = ca.ChildAccountID
left join scRollups r
		on ca.AccountID = r.RollupID
where d.DrawDate between '11/10/2011' and '11/13/2011'
and a.AcctCode = 'D70901'
and a.AcctActive = 1


select a.AcctCode, convert(varchar, d.DrawDate, 1) as [DrawDate], p.PubShortName, d.DrawAmount
from scDraws d
join scAccounts a
	on d.accountid = a.AccountID
join nsPublications p
	on d.publicationid = p.PublicationID
left join scChildAccounts ca
		on a.AccountID = ca.ChildAccountID
left join scRollups r
		on ca.AccountID = r.RollupID
where d.DrawDate between '11/17/2011' and '11/20/2011'
and a.AcctCode = 'D70901'
and a.AcctActive = 1
and a.AcctImported = 1
