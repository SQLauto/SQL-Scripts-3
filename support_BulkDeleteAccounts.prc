IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_BulkDeleteAccounts]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_BulkDeleteAccounts]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[support_BulkDeleteAccounts]
	  @acctsToDelete acctTableType readonly
AS
/*
	[dbo].[support_BulkDeleteAccounts]
	
	$History:  $
*/
BEGIN
set nocount on


	delete scDrawHistory 
	from scDrawHistory dh
	join @acctsToDelete tmp
		on dh.AccountId = tmp.AccountId
	print cast(@@rowcount as varchar) + ' deleted from scDrawHistory'

	delete scDrawAdjustmentsAudit
	from scDrawAdjustmentsAudit adj
	join @acctsToDelete tmp
		on adj.AccountId = tmp.AccountId
	print cast(@@rowcount as varchar) + ' deleted from scDrawAdjustmentsAudit'

	delete scReturnsAudit
	from scReturnsAudit ret
	join @acctsToDelete tmp
		on ret.AccountId = tmp.AccountId
	print cast(@@rowcount as varchar) + ' deleted from scReturnsAudit'

	delete scConditionHistory
	from scConditionHistory ch
	join scDraws d
		on ch.DrawId = d.DrawId
	join @acctsToDelete tmp
		on d.AccountId = tmp.AccountId
	print cast(@@rowcount as varchar) + ' deleted from scConditionHistory'

	delete scDraws
	from scDraws d
	join @acctsToDelete tmp
		on d.AccountId = tmp.AccountId
	print cast(@@rowcount as varchar) + ' deleted from scDraws'

	delete scDefaultDrawHistory
	from scDefaultDrawHistory ddh
	join @acctsToDelete tmp
		on ddh.AccountId = tmp.AccountId
	print cast(@@rowcount as varchar) + ' deleted from scDefaultDrawHistory'

	delete scDefaultDraws
	from scDefaultDraws dd
	join @acctsToDelete tmp
		on dd.AccountId = tmp.AccountId
	print cast(@@rowcount as varchar) + ' deleted from scDefaultDraws'

	delete scManifestSequenceItems 
	from scManifestSequenceItems msi
	join scAccountsPubs ap
		on msi.AccountPubId = ap.AccountPubId
	join @acctsToDelete tmp
		on ap.AccountId = tmp.AccountId
	print cast(@@rowcount as varchar) + ' deleted from scManifestSequenceItems'

	delete scManifestSequences 
	from scManifestSequences ms
	join scAccountsPubs ap
		on ms.AccountPubId = ap.AccountPubId
	join @acctsToDelete tmp
		on ap.AccountId = tmp.AccountId
	print cast(@@rowcount as varchar) + ' deleted from scManifestSequences'

	delete scForecastAccountRules
	from scForecastAccountRules far
	join @acctsToDelete tmp
		on far.AccountId = tmp.AccountId
	print cast(@@rowcount as varchar) + ' deleted from scForecastAccountRules'

	delete scAccountsPubs
	from scAccountsPubs ap
	join @acctsToDelete tmp
		on ap.AccountId = tmp.AccountId
	print cast(@@rowcount as varchar) + ' deleted from scAccountsPubs'

	delete scAccountsCategories
	from scAccountsCategories ac
	join @acctsToDelete tmp
		on ac.AccountId = tmp.AccountId
	print cast(@@rowcount as varchar) + ' deleted from scAccountsCategories'

	delete scInvoices
	from scInvoices i
	join @acctsToDelete tmp
		on i.AccountId = tmp.AccountId
	print cast(@@rowcount as varchar) + ' deleted from scInvoices'

	delete scDeliveryReceipts
	from scDeliveryReceipts dr
	join @acctsToDelete tmp
		on dr.AccountId = tmp.AccountId
	print cast(@@rowcount as varchar) + ' deleted from scDeliveryReceipts'

	delete scDeliveries
	from scDeliveries d
	join @acctsToDelete tmp
		on d.AccountId = tmp.AccountId
	print cast(@@rowcount as varchar) + ' deleted from scDeliveryReceipts'

	delete scAccounts
	from scAccounts a
	join @acctsToDelete tmp
		on a.AccountId = tmp.AccountId
	print cast(@@rowcount as varchar) + ' deleted from scAccounts'

	
END
GO	



