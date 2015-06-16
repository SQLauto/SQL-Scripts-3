begin tran

;with cteDelete as (
select tmp.Manifest, a.AcctCode, p.PubShortName
	, a.AccountID, ap.AccountPubID, p.PublicationID
from support_AccountsToDelete tmp
join scAccounts a
	on tmp.[Route #] = a.AcctCode
join scAccountsPubs ap
	on a.AccountID = ap.AccountId
join nsPublications p
	on ap.PublicationId = p.PublicationID
where tmp.Pubs = 'ALL'

union all 

select tmp.Manifest, a.AcctCode, p.PubShortName
	, a.AccountID, ap.AccountPubID, p.PublicationID
from support_AccountsToDelete tmp
join scAccounts a
	on tmp.[Route #] = a.AcctCode
join nsPublications p
	on tmp.Pubs = p.PubShortName
join scAccountsPubs ap
	on a.AccountID = ap.AccountId
	and p.PublicationID = ap.PublicationId
where tmp.Pubs <> 'ALL'
)
select *
into #acctPubsToDelete
from cteDelete
/*
delete scDrawHistory 
from scDrawHistory dh
join #acctPubsToDelete tmp
	on dh.AccountId = tmp.AccountId
	and dh.publicationid = tmp.PublicationID
print cast(@@rowcount as varchar) + ' deleted from scDrawHistory'

delete scDrawAdjustmentsAudit
from scDrawAdjustmentsAudit adj
join #acctPubsToDelete tmp
	on adj.AccountId = tmp.AccountId
	and adj.publicationid = tmp.PublicationID
print cast(@@rowcount as varchar) + ' deleted from scDrawAdjustmentsAudit'

delete scReturnsAudit
from scReturnsAudit ret
join #acctPubsToDelete tmp
	on ret.AccountId = tmp.AccountId
	and ret.publicationid = tmp.PublicationID
print cast(@@rowcount as varchar) + ' deleted from scReturnsAudit'

delete scConditionHistory
from scConditionHistory ch
join scDraws d
	on ch.DrawId = d.DrawId
join #acctPubsToDelete tmp
	on d.AccountId = tmp.AccountId
	and d.PublicationID = tmp.PublicationID
print cast(@@rowcount as varchar) + ' deleted from scConditionHistory'

delete scProductLineItemDetails
from scProductLineItemDetails plid
join scDraws d
	on plid.DrawId = d.DrawId
join #acctPubsToDelete tmp
	on d.AccountId = tmp.AccountId
	and d.publicationid = tmp.PublicationID
print cast(@@rowcount as varchar) + ' deleted from scProductLineItemDetails'


select d.*
into scDraws_Backup_08282013
from scDraws d
join #acctPubsToDelete tmp
	on d.AccountId = tmp.AccountId
	and d.publicationid = tmp.PublicationID

delete scSBTSalesUploadedRecords
from scSBTSalesUploadedRecords u
join scSBTSales s
	on u.SBTSaleId = s.SBTSaleId
join scDraws_Backup_08282013 tmp
	on s.DrawId = tmp.DrawID
print cast(@@rowcount as varchar) + ' deleted from scSBTSalesUploadedRecords'

delete from scSBTSales
from scSBTSales sbts
join scDraws_Backup_08282013 tmp
	on sbts.DrawId = tmp.DrawID
print cast(@@rowcount as varchar) + ' deleted from scSBTSales'

delete scDraws
from scDraws d
join #acctPubsToDelete tmp
	on d.AccountId = tmp.AccountId
	and d.publicationid = tmp.PublicationID
print cast(@@rowcount as varchar) + ' deleted from scDraws'

delete scDefaultDrawHistory
from scDefaultDrawHistory ddh
join #acctPubsToDelete tmp
	on ddh.AccountId = tmp.AccountId
	and ddh.publicationid = tmp.PublicationID
print cast(@@rowcount as varchar) + ' deleted from scDefaultDrawHistory'

delete scDefaultDraws
from scDefaultDraws dd
join #acctPubsToDelete tmp
	on dd.AccountId = tmp.AccountId
	and dd.PublicationID = tmp.PublicationID
print cast(@@rowcount as varchar) + ' deleted from scDefaultDraws'
*/
delete scManifestSequenceItems 
from scManifestSequenceItems msi
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubId
join #acctPubsToDelete tmp
	on ap.AccountId = tmp.AccountId
	and ap.publicationid = tmp.PublicationID
print cast(@@rowcount as varchar) + ' deleted from scManifestSequenceItems'

--delete scManifestSequences 
--from scManifestSequences ms
--join scAccountsPubs ap
--	on ms.AccountPubId = ap.AccountPubId
--join #acctPubsToDelete tmp
--	on ap.AccountId = tmp.AccountId
--	and ap.publicationid = tmp.PublicationID
--print cast(@@rowcount as varchar) + ' deleted from scManifestSequences'

--delete scForecastAccountRules
--from scForecastAccountRules far
--join #acctPubsToDelete tmp
--	on far.AccountId = tmp.AccountId
--	and far.publicationid = tmp.PublicationID
--print cast(@@rowcount as varchar) + ' deleted from scForecastAccountRules'

update scAccountsPubs 
set Active = 0
from scAccountsPubs ap
join #acctPubsToDelete tmp
	on ap.AccountId = tmp.AccountId
	and ap.publicationid = tmp.PublicationID
print cast(@@rowcount as varchar) + ' deactivated from scAccountsPubs'


--delete scAccountsPubs
--from scAccountsPubs ap
--join #acctPubsToDelete tmp
--	on ap.AccountId = tmp.AccountId
--	and ap.publicationid = tmp.PublicationID
--print cast(@@rowcount as varchar) + ' deleted from scAccountsPubs'

--delete scDeliveryReceipts
--from scDeliveryReceipts dr
--join #acctPubsToDelete tmp
--	on dr.AccountId = tmp.AccountId
--	and dr.PublicationID = tmp.PublicationID
--print cast(@@rowcount as varchar) + ' deleted from scDeliveryReceipts'

drop table #acctPubsToDelete


commit tran