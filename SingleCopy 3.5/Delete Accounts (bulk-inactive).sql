begin tran

set nocount on

select AccountId
into #acctsToDelete
from scAccounts a
where AcctActive = 0	

--select DrawDate, DrawAmount, AdjAmount, AdjAdminAmount, RetAmount
--from scDraws d
--join #acctsToDelete tmp
--	on d.AccountId = tmp.AccountId

delete scDrawHistory 
from scDrawHistory dh
join #acctsToDelete tmp
	on dh.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scDrawHistory'

delete scDrawAdjustmentsAudit
from scDrawAdjustmentsAudit adj
join #acctsToDelete tmp
	on adj.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scDrawAdjustmentsAudit'

delete scReturnsAudit
from scReturnsAudit ret
join #acctsToDelete tmp
	on ret.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scReturnsAudit'

delete scConditionHistory
from scConditionHistory ch
join scDraws d
	on ch.DrawId = d.DrawId
join #acctsToDelete tmp
	on d.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scConditionHistory'

delete scProductLineItemDetails
from scProductLineItemDetails plid
join scDraws d
	on plid.DrawId = d.DrawId
join #acctsToDelete tmp
	on d.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scProductLineItemDetails'

delete scDraws
from scDraws d
join #acctsToDelete tmp
	on d.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scDraws'

delete scDefaultDrawHistory
from scDefaultDrawHistory ddh
join #acctsToDelete tmp
	on ddh.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scDefaultDrawHistory'

delete scDefaultDraws
from scDefaultDraws dd
join #acctsToDelete tmp
	on dd.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scDefaultDraws'

delete scManifestSequenceItems 
from scManifestSequenceItems msi
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubId
join #acctsToDelete tmp
	on ap.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scManifestSequenceItems'

delete scManifestSequences 
from scManifestSequences ms
join scAccountsPubs ap
	on ms.AccountPubId = ap.AccountPubId
join #acctsToDelete tmp
	on ap.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scManifestSequences'

delete scForecastAccountRules
from scForecastAccountRules far
join #acctsToDelete tmp
	on far.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scForecastAccountRules'

delete scAccountsPubs
from scAccountsPubs ap
join #acctsToDelete tmp
	on ap.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scAccountsPubs'

delete scAccountsCategories
from scAccountsCategories ac
join #acctsToDelete tmp
	on ac.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scAccountsCategories'

delete scInvoices
from scInvoices i
join #acctsToDelete tmp
	on i.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scInvoices'

delete scDeliveryReceipts
from scDeliveryReceipts dr
join #acctsToDelete tmp
	on dr.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scDeliveryReceipts'

delete scInvoiceLineItems 
from scInvoiceLineItems li 
join scInvoiceMasters im
	on li.invoiceid = im.invoiceid	
join #acctsToDelete tmp
	on im.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scInvoiceLineItems'

delete scInvoiceMastersARAccountBalances
from scInvoiceMastersARAccountBalances ab
join scInvoiceMasters im
	on ab.invoiceid = im.invoiceid	
join #acctsToDelete tmp
	on im.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scInvoiceMastersARAccountBalances'


delete scInvoiceHeaders
from scInvoiceHeaders ih
join scInvoiceMasters im
	on ih.invoiceid = im.invoiceid	
join #acctsToDelete tmp
	on im.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scInvoiceHeaders'


delete scInvoiceMasters 
from scInvoiceMasters im
join #acctsToDelete tmp
	on im.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scInvoiceMasters'

delete scARAccountBalances
from scARAccountBalances arab
join #acctsToDelete tmp
	on arab.AccountId = tmp.AccountID
print cast(@@rowcount as varchar) + ' deleted from scARAccountBalances'

delete scDeliveries
from scDeliveries d
join #acctsToDelete tmp
	on d.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scDeliveryReceipts'



delete scAccounts
from scAccounts a
join #acctsToDelete tmp
	on a.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scAccounts'

drop table #acctsToDelete

commit tran
