begin tran

set nocount on

declare @accountId int

select @accountId = AccountId
from scAccounts
where AcctCode like '79600204'

select DrawDate, DrawAmount, AdjAmount, AdjAdminAmount, RetAmount
from scDraws d
where AccountId = @accountId

delete from scDrawHistory
where AccountId = @accountId
print cast(@@rowcount as varchar) + ' deleted from scDrawHistory'

delete from scDrawAdjustmentsAudit
where AccountId = @accountId
print cast(@@rowcount as varchar) + ' deleted from scDrawAdjustmentsAudit'

delete from scReturnsAudit
where AccountId = @accountId
print cast(@@rowcount as varchar) + ' deleted from scReturnsAudit'

delete from scDraws
where AccountId = @accountId
print cast(@@rowcount as varchar) + ' deleted from scDraws'

delete from scDefaultDrawHistory
where AccountId = @accountId
print cast(@@rowcount as varchar) + ' deleted from scDefaultDrawHistory'

delete from scDefaultDraws
where AccountId = @accountId
print cast(@@rowcount as varchar) + ' deleted from scDefaultDraws'

delete scManifestSequenceItems 
from scManifestSequenceItems msi
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubId
where AccountId = @accountId
print cast(@@rowcount as varchar) + ' deleted from scManifestSequenceItems'

delete scManifestSequences 
from scManifestSequences ms
join scAccountsPubs ap
	on ms.AccountPubId = ap.AccountPubId
where AccountId = @accountId
print cast(@@rowcount as varchar) + ' deleted from scManifestSequences'

delete from scForecastAccountRules
where AccountId = @accountId
print cast(@@rowcount as varchar) + ' deleted from scForecastAccountRules'

delete from scAccountsPubs
where AccountId = @accountId
print cast(@@rowcount as varchar) + ' deleted from scAccountsPubs'

delete from scAccountsCategories
where AccountId = @accountId
print cast(@@rowcount as varchar) + ' deleted from scAccountsCategories'

delete from scInvoices
where AccountID = @accountId
print cast(@@rowcount as varchar) + ' deleted from scInvoices'

delete from scAccounts
where AccountId = @accountId
print cast(@@rowcount as varchar) + ' deleted from scAccounts'


commit tran

