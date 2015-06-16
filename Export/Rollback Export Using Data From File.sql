begin tran

select *
into support_retexp_rollback_scDrawsBackup
from scDraws 
where DATEDIFF(d, RetExpDateTime, GETDATE()) = 0

select SUM(cast(RetExportAmt as int))
from support_retexp_rollback

select SUM(RetExportLastAmt)
from scDraws

select a.AccountID, p.PublicationID, d.DrawID, d.DrawDate
	, d.RetAmount, d.RetExportLastAmt, d.RetExpDateTime
	, tmp.RetExportAmt
	, d.RetExportLastAmt - tmp.RetExportAmt as [NewRetExportLastAmt]
into support_retexp_rollback_working
from support_retexp_rollback tmp
left join scaccountmappings map
	on tmp.Acct = map.CircSystemIdentifier
	and tmp.Pub + tmp.Edition = map.PubCode
join scAccounts a
	on map.MappedIdentifier = a.AcctCode
join nsPublications p	
	on map.PubCode = p.PubShortName	
join scDraws d
	on a.AccountID = d.AccountID
	and p.PublicationID = d.PublicationID
	and tmp.DrawDate = d.DrawDate	

select min(drawdate), MAX(drawdate)
from support_retexp_rollback_working
	
update scDraws
set RetExportLastAmt = tmp.NewRetExportLastAmt
from scDraws d
join support_retexp_rollback_working tmp
	on d.DrawID = tmp.drawid
		

update scDraws
set AdjExportLastAmt = 0
from scDraws
where AccountID = 2163
and publicationid = 4
and DrawDate = '20150204'		

select SUM(RetExportLastAmt)
from scDraws

--delete from CustomExport_Returns

--insert into CustomExport_Returns
--exec CustomExport_Returns_Select '1/25/2015', '2/3/2015'
		
commit tran		