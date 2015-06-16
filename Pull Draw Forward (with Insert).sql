begin tran

;with cteSource
as (
	select d.*
	from scDraws d
	join nsPublications p
		on d.PublicationID = p.PublicationID
	where DrawDate = '3/24/2013'
	and p.PubShortName in ('OPCES')
),
cteTarget
as (
	select d.*
	from scDraws d
	join nsPublications p
		on d.PublicationID = p.PublicationID
	where DrawDate = '3/31/2013'
	and p.PubShortName in ('OPCES')
)
insert into scDraws( CompanyID, DistributionCenterID, AccountID, PublicationID, DrawWeekday, DrawDate, DeliveryDate, DrawAmount, DrawRate, BillingHistoryID, AdjAmount, AdjAdminAmount, AdjExpDateTime, AdjExportLastAmt, RetAmount, RetExpDateTime, RetExportLastAmt, RollupAcctID, LastChangeType, BillingDate )
select src.CompanyID, src.DistributionCenterID, src.AccountID, src.PublicationID, src.DrawWeekday, '3/31/2013', '3/31/2013', src.DrawAmount, src.DrawRate, src.BillingHistoryID, src.AdjAmount, src.AdjAdminAmount, src.AdjExpDateTime, src.AdjExportLastAmt, src.RetAmount, src.RetExpDateTime, src.RetExportLastAmt, src.RollupAcctID, src.LastChangeType, src.BillingDate
from cteSource src
left join cteTarget tgt
	on src.AccountID = tgt.AccountID
	and src.PublicationID = tgt.PublicationID
	and src.DrawWeekday = tgt.DrawWeekday
join scAccounts a
	on src.AccountID = a.AccountID	
where tgt.DrawID is null
--and a.AcctCode = '1660033'

commit tran