begin tran

declare @acct nvarchar(20)
declare @date datetime
declare @pub nvarchar(5)
declare @rate decimal(8,5)

set @acct = '40018860'
set @pub = 'FNTEE'
set @date = '4/4/2011'
set @rate = 0.00

select a.AcctCode, p.PubShortName, d.DrawDate, d.DrawRate as [Rate (before)]
from scDraws d
join scAccounts a
	on d.AccountID = a.AccountID
join nsPublications p
	on d.PublicationID = p.PublicationID
where a.AcctCode = @acct
and p.PubShortName = @pub
and d.DrawDate = @date

update scDraws
set DrawRate = @rate
from scDraws d
join scAccounts a
	on d.AccountID = a.AccountID
join nsPublications p
	on d.PublicationID = p.PublicationID
where a.AcctCode = @acct
and p.PubShortName = @pub
and d.DrawDate = @date

select a.AcctCode, p.PubShortName, d.DrawDate, d.DrawRate as [Rate (after)]
from scDraws d
join scAccounts a
	on d.AccountID = a.AccountID
join nsPublications p
	on d.PublicationID = p.PublicationID
where a.AcctCode = @acct
and p.PubShortName = @pub
and d.DrawDate = @date

commit tran

