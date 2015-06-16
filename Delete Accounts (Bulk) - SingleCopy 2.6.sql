begin tran

set nocount on


select a.accountid, a.acctcode, a.acctactive, d.drawid, d.drawdate, d.drawamount, r.retamount, adj.adjamount, adj.adjadminamount
into bkpDrawHistoryForDuplicateAccts
from scaccounts a
join (
	select acctcode
	from scaccounts
	group by acctcode
	having count(*) > 1
	) as [dups]
	on a.acctcode = dups.acctcode
--order by a.acctcode
join scdraws d
	on a.accountid = d.accountid
left join screturns r
	on d.drawid = r.drawid
left join scdrawadjustments adj
	on d.drawid = adj.drawid
where a.acctactive = 0
and (
	d.drawamount > 0 
	or r.retamount > 0
	or adj.adjamount > 0 
	or adj.adjadminamount > 0
) 


select AccountId
into #acctsToDelete
from scaccounts a
join (
	select acctcode
	from scaccounts
	group by acctcode
	having count(*) > 1
	) as [dups]
	on a.acctcode = dups.acctcode
where a.acctactive = 0

/*
delete scDrawHistory 
from scDrawHistory dh
join #acctsToDelete tmp
	on dh.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scDrawHistory'
*/

delete scDrawAdjustmentsAudit
from scDrawAdjustmentsAudit adj
join #acctsToDelete tmp
	on adj.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scDrawAdjustmentsAudit'

delete scDrawAdjustments
from scDrawAdjustments adj
join #acctsToDelete tmp
	on adj.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scDrawAdjustments'

delete scReturnsAudit
from scReturnsAudit ret
join #acctsToDelete tmp
	on ret.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scReturnsAudit'

delete scReturns
from scReturns ret
join #acctsToDelete tmp
	on ret.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scReturns'

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

delete scAccountDrops
from scAccountDrops ad
join #acctsToDelete tmp
	on ad.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scAccountsDrops'


/*
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
*/

delete scAccountForecastRules
from scAccountForecastRules far
join #acctsToDelete tmp
	on far.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scForecastAccountRules'

/*
delete scAccountsPubs
from scAccountsPubs ap
join #acctsToDelete tmp
	on ap.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scAccountsPubs'
*/

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

/*
delete scDeliveryReceipts
from scDeliveryReceipts dr
join #acctsToDelete tmp
	on dr.AccountId = tmp.AccountId
print cast(@@rowcount as varchar) + ' deleted from scDeliveryReceipts'
*/

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


select a.accountid, a.acctcode, a.acctactive, d.drawdate, d.drawamount, r.retamount, adj.adjamount
from scaccounts a
join (
	select acctcode
	from scaccounts
	group by acctcode
	having count(*) > 1
	) as [dups]
	on a.acctcode = dups.acctcode
--order by a.acctcode
join scdraws d
	on a.accountid = d.accountid
left join screturns r
	on d.drawid = r.drawid
left join scdrawadjustments adj
	on d.drawid = adj.drawid
where a.acctactive = 0
and ( r.retamount > 0
	or adj.adjamount > 0 ) 

commit tran
