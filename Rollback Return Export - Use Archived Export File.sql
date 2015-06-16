
begin tran

select tmp.*, d.RetAmount, RetExportLastAmt, RetExpDateTime
from support_ReturnExportRollback_06112012 tmp
join scAccounts a
	on tmp.AcctCode = a.AcctCode
join nsPublications p
	on tmp.PubShortName = p.PubShortName
join scDraws d
	on a.AccountID = d.AccountID
	and p.PublicationID = d.PublicationID
	and tmp.DrawDate = d.DrawDate
order by tmp.AcctCode, tmp.PubShortName

update scDraws
set RetExportLastAmt = d.RetAmount
from support_ReturnExportRollback_06112012 tmp
join scAccounts a
	on tmp.AcctCode = a.AcctCode
join nsPublications p
	on tmp.PubShortName = p.PubShortName
join scDraws d
	on a.AccountID = d.AccountID
	and p.PublicationID = d.PublicationID
	and tmp.DrawDate = d.DrawDate

select tmp.*, d.RetAmount, RetExportLastAmt, RetExpDateTime
from support_ReturnExportRollback_06112012 tmp
join scAccounts a
	on tmp.AcctCode = a.AcctCode
join nsPublications p
	on tmp.PubShortName = p.PubShortName
join scDraws d
	on a.AccountID = d.AccountID
	and p.PublicationID = d.PublicationID
	and tmp.DrawDate = d.DrawDate
where d.RetAmount <> d.RetExportLastAmt
order by tmp.AcctCode, tmp.PubShortName

commit tran