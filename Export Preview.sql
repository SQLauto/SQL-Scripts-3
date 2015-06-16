
declare @startDate datetime
declare @endDate datetime


set @startDate = '12/20/2010'
set @endDate = '12/26/2010'

--|  Return Export
select a.AcctCode, p.PubShortName, d.DrawDate, d.DrawAmount
	, d.RetAmount, RetExpDateTime, RetExportLastAmt
from scDraws d
join scAccounts a
	on d.AccountID = a.AccountID
join nsPublications p
	on d.PublicationID = p.PublicationID
where DrawDate between @startDate and @endDate
and ( 
	isnull(RetAmount,0) <> isnull(RetExportLastAmt,0)
	)

select d.DrawDate, p.PubShortName, sum(d.RetAmount) as [Total Returns]
from scDraws d
join nsPublications p
	on d.PublicationID = p.PublicationID
where DrawDate between @startDate and @endDate
and ( 
	isnull(RetAmount,0) <> isnull(RetExportLastAmt,0)
	)
group by d.DrawDate, p.PubShortName

--|  Adjustments Export
/*
select a.AcctCode, p.PubShortName, d.DrawDate, d.DrawAmount
	, d.AdjAmount, d.AdjAdminAmount, AdjExpDateTime, AdjExportLastAmt
from scDraws d
join scAccounts a
	on d.AccountID = a.AccountID
join nsPublications p
	on d.PublicationID = p.PublicationID
where DrawDate between @startDate and @endDate
and ( 
	isnull(AdjExportLastAmt,0) <> ( isnull(AdjAmount,0) + isnull(AdjAdminAmount,0) )
	)
*/