begin tran

select a.AcctCode, p.PubShortName, ap.AccountPubID, a.AccountId, p.PublicationID
into #acctPubsToDelete
from scAccounts a
join scAccountsPubs ap
	on a.AccountID = ap.AccountId
join nsPublications p
	on ap.PublicationId = p.PublicationID	
where a.AcctCode like '007%'
and p.PubShortName in ('AJC','TL')

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
into scDraws_Backup_01302012
from scDraws d
join #acctPubsToDelete tmp
	on d.AccountId = tmp.AccountId
	and d.publicationid = tmp.PublicationID

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

delete scManifestSequenceItems 
from scManifestSequenceItems msi
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubId
join #acctPubsToDelete tmp
	on ap.AccountId = tmp.AccountId
	and ap.publicationid = tmp.PublicationID
print cast(@@rowcount as varchar) + ' deleted from scManifestSequenceItems'

delete scManifestSequences 
from scManifestSequences ms
join scAccountsPubs ap
	on ms.AccountPubId = ap.AccountPubId
join #acctPubsToDelete tmp
	on ap.AccountId = tmp.AccountId
	and ap.publicationid = tmp.PublicationID
print cast(@@rowcount as varchar) + ' deleted from scManifestSequences'

delete scForecastAccountRules
from scForecastAccountRules far
join #acctPubsToDelete tmp
	on far.AccountId = tmp.AccountId
	and far.publicationid = tmp.PublicationID
print cast(@@rowcount as varchar) + ' deleted from scForecastAccountRules'

delete scAccountsPubs
from scAccountsPubs ap
join #acctPubsToDelete tmp
	on ap.AccountId = tmp.AccountId
	and ap.publicationid = tmp.PublicationID
print cast(@@rowcount as varchar) + ' deleted from scAccountsPubs'

--delete scInvoices
--from scInvoices i
--join #acctPubsToDelete tmp
--	on i.AccountId = tmp.AccountId
--print cast(@@rowcount as varchar) + ' deleted from scInvoices'

delete scDeliveryReceipts
from scDeliveryReceipts dr
join #acctPubsToDelete tmp
	on dr.AccountId = tmp.AccountId
	and dr.PublicationID = tmp.PublicationID
print cast(@@rowcount as varchar) + ' deleted from scDeliveryReceipts'

--delete scInvoiceLineItems 
--from scInvoiceLineItems li 
--join scInvoiceMasters im
--	on li.invoiceid = im.invoiceid	
--join #acctPubsToDelete tmp
--	on im.AccountId = tmp.AccountId
--print cast(@@rowcount as varchar) + ' deleted from scInvoiceLineItems'

--delete scInvoiceMastersARAccountBalances
--from scInvoiceMastersARAccountBalances ab
--join scInvoiceMasters im
--	on ab.invoiceid = im.invoiceid	
--join #acctPubsToDelete tmp
--	on im.AccountId = tmp.AccountId
--print cast(@@rowcount as varchar) + ' deleted from scInvoiceMastersARAccountBalances'

--delete scInvoiceHeaders
--from scInvoiceHeaders ih
--join scInvoiceMasters im
--	on ih.invoiceid = im.invoiceid	
--join #acctPubsToDelete tmp
--	on im.AccountId = tmp.AccountId
--print cast(@@rowcount as varchar) + ' deleted from scInvoiceHeaders'

--delete scInvoiceMastersPayments
--from scInvoiceMastersPayments p
--join scInvoiceMasters im
--	on p.InvoiceId = im.InvoiceId
--join #acctPubsToDelete tmp
--	on tmp.AccountID = im.AccountId	
--print '  ' + cast(@@rowcount as varchar) + ' deleted from scInvoiceMastersPayments'

--delete scPaymentsARAccountBalances
--from scPaymentsARAccountBalances ab
--join scPayments p
--	on ab.PaymentId = p.PaymentID
--join #acctPubsToDelete tmp
--	on p.AccountID = tmp.AccountID
--print cast(@@rowcount as varchar) + ' deleted from scPaymentsARAccountBalances'

--delete scPayments 
--from scPayments p
--join #acctPubsToDelete tmp
--	on p.AccountID = tmp.AccountID
--print cast(@@rowcount as varchar) + ' deleted from scPayments'

--delete scInvoiceMasters 
--from scInvoiceMasters im
--join #acctPubsToDelete tmp
--	on im.AccountId = tmp.AccountId
--print cast(@@rowcount as varchar) + ' deleted from scInvoiceMasters'

--delete scARAccountBalances
--from scARAccountBalances arab
--join #acctPubsToDelete tmp
--	on arab.AccountId = tmp.AccountID
--print cast(@@rowcount as varchar) + ' deleted from scARAccountBalances'

--delete scDeliveries
--from scDeliveries d
--join #acctPubsToDelete tmp
--	on d.AccountId = tmp.AccountId
--print cast(@@rowcount as varchar) + ' deleted from scDeliveryReceipts'

--delete scAccounts
--from scAccounts a
--join #acctPubsToDelete tmp
--	on a.AccountId = tmp.AccountId
--print cast(@@rowcount as varchar) + ' deleted from scAccounts'

drop table #acctPubsToDelete


rollback tran