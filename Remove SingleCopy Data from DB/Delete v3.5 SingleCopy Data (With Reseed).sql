begin tran

set nocount on 

declare @manifests int
declare @manifestTemplates int
declare @accounts int
declare @invoices int
declare @forecastRules int
declare @pubs int
declare @users int
declare @devices int
declare @draws int
declare @defaultdraws int
declare @misc int
declare @types int
declare @categories int

set @manifests = 1
set @manifestTemplates = 1
set @accounts = 1
set @invoices = 1
set @forecastRules = 0
set @pubs = 0
set @users = 0
set @devices = 0
set @draws = 1
set @defaultdraws = 1
set @types = 0
set @categories = 0


--|Manifests
if @manifests = 1
begin
	
	select MTCode, MTOwner, UserName, DeviceId
	into support_scManifestTemplates
	from scManifestTemplates mt
	join Users u
		on mt.MTOwner = u.UserID

	print 'deleting data from table [scManifestDownloadCancellations]'
	delete from [scManifestDownloadCancellations]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestDownloadCancellations]'
	print ''

	print 'deleting data from table [scManifestTransferDrops]'
	delete from [scManifestTransferDrops]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestTransferDrops]'
	print ''

	print 'deleting data from table [scManifestTransfers]'
	delete from [scManifestTransfers]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestTransfers]'
	print ''

	print 'deleting data from table [scManifestHistory]'
	delete from [scManifestHistory]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestHistory]'
	print ''

	print 'deleting data from table [scManifestSequences]'
	delete from [scManifestSequences]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestSequences]'
	print ''

	print 'deleting data from table [scManifests]'
	delete from [scManifests]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifests]'
	print ''
end	

--|ManifestTemplates
if @manifestTemplates = 1
begin
	print 'deleting data from table [scManifestSequenceItems]'
	delete from [scManifestSequenceItems]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestSequenceItems]'
	print ''

	print 'deleting data from table [scManifestSequenceTemplates]'
	delete from [scManifestSequenceTemplates]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestSequenceTemplates]'
	print ''

	print 'deleting data from table [scManifestTemplates]'
	delete from [scManifestTemplates]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestTemplates]'
	print ''

	print 'deleting data from table [scManifestLoad]'
	delete from [scManifestLoad]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestLoad]'
	print ''

	print 'deleting data from table [scManifestQueue]'
	delete from [scManifestQueue]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestQueue]'
	print ''
end

--|Forecasting
if @forecastRules = 1
begin
	print 'deleting data from table [scForecastAccountRules]'
	delete from [scForecastAccountRules]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastAccountRules]'
	print ''

	print 'deleting data from table [scForecastCategoryRules]'
	delete from [scForecastCategoryRules]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastCategoryRules]'
	print ''

	print 'deleting data from table [scForecastExceptionDates]'
	delete from [scForecastExceptionDates]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastExceptionDates]'
	print ''

	print 'deleting data from table [scForecastExceptionDateTypes]'
	delete from [scForecastExceptionDateTypes]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastExceptionDateTypes]'
	print ''

	print 'deleting data from table [scForecastPublicationRules]'
	delete from [scForecastPublicationRules]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastPublicationRules]'
	print ''

	print 'deleting data from table [scForecastRule_SalesOverrides]'
	delete from [scForecastRule_SalesOverrides]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastRule_SalesOverrides]'
	print ''

	print 'deleting data from table [scForecastRule_SelloutOverrides]'
	delete from [scForecastRule_SelloutOverrides]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastRule_SelloutOverrides]'
	print ''

	print 'deleting data from table [scForecastWeightingTables]'
	delete from [scForecastWeightingTables]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastWeightingTables]'
	print ''

	print 'deleting data from table [scSalesOverrideLevels]'
	delete from [scSalesOverrideLevels]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scSalesOverrideLevels]'
	print ''

	print 'deleting data from table [scSalesOverrides]'
	delete from [scSalesOverrides]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scSalesOverrides]'
	print ''

	print 'deleting data from table [scSelloutOverrides]'
	delete from [scSelloutOverrides]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scSelloutOverrides]'
	print ''

	print 'deleting data from table [scForecastRules]'
	delete from [scForecastRules]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastRules]'
	print ''

	print 'deleting data from table [nsPublicationForecastCutoffs]...'
	delete from [nsPublicationForecastCutoffs]
	print cast(@@rowcount as varchar) + ' rows deleted from [nsPublicationForecastCutoffs]...'
	print ''

end

--|Draws
if @draws = 1 
begin
	print 'deleting data from table [scDrawAdjustmentsAudit]'
	delete from [scDrawAdjustmentsAudit]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDrawAdjustmentsAudit]'
	print ''

	print 'deleting data from table [scReturnsAudit]'
	delete from [scReturnsAudit]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scReturnsAudit]'
	print ''

	print 'deleting data from table [scTemporaryDraws]'
	delete from [scTemporaryDraws]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scTemporaryDraws]'
	print ''

	print 'deleting data from table [scDrawForecasts]'
	delete from [scDrawForecasts]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDrawForecasts]'
	print ''

	print 'deleting data from table [scDrawHistory]'
	delete from [scDrawHistory]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDrawHistory]'
	print ''

	print 'deleting data from table [scDraws]'
	delete from [scDraws]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDraws]'
	print ''
end

--|DefaultDraws
if @defaultdraws = 1
begin
	print 'deleting data from table [scDefaultDrawHistory]'
	delete from [scDefaultDrawHistory]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDefaultDrawHistory]'
	print ''

	print 'deleting data from table [scDefaultDraws]'
	delete from [scDefaultDraws]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDefaultDraws]'
	print ''
end


if @invoices = 1
begin
	print 'deleting data from table [scDeliveryReceipts]'
	delete from [scDeliveryReceipts]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDeliveryReceipts]'
	print ''

	--|Billing
	print 'deleting data from table [scDeliveries]'
	delete from [scDeliveries]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDeliveries]'
	print ''

	print 'deleting data from table [scInvoices]'
	delete from [scInvoices]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scInvoices]'
	print ''

	print 'deleting data from table [scDeliveryReceipts]'
	delete scDeliveryReceipts
	print '  ' + cast(@@rowcount as varchar) + ' deleted from scDeliveryReceipts'
	print ''

	print 'deleting data from table [scDeliveryReceipts]'
	delete scInvoiceLineItems 
	print '  ' + cast(@@rowcount as varchar) + ' deleted from scInvoiceLineItems'
	print ''

	print 'deleting data from table [scInvoiceMastersARAccountBalances]'
	delete scInvoiceMastersARAccountBalances
	print '  ' + cast(@@rowcount as varchar) + ' deleted from scInvoiceMastersARAccountBalances'
	print ''

	print 'deleting data from table [scInvoiceHeaders]'
	delete scInvoiceHeaders
	print '  ' + cast(@@rowcount as varchar) + ' deleted from scInvoiceHeaders'
	print ''

	print 'deleting data from table [scInvoiceMasters]'
	delete scInvoiceMasters 
	print '  ' + cast(@@rowcount as varchar) + ' deleted from scInvoiceMasters'
	print ''

	print 'deleting data from table [scARAccountBalances]'
	delete scARAccountBalances
	print '  ' + cast(@@rowcount as varchar) + ' deleted from scARAccountBalances'
	print ''
	
	--print 'deleting data from table [scBillingHistory]'
	--delete from [scBillingHistory]
	--print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scBillingHistory]'
	--print ''
end

	--|Accounts
if @accounts = 1
begin	

	select AcctCode, a.AcctOwner, ua.UserName as [AcctOwnerName], ap.APOwner, uap.UserName as [AcctPubOwnerName]
	into support_Account_Ownership
	from scAccounts a
	join scAccountsPubs ap
		on a.AccountID = ap.AccountId
	join Users ua
		on a.AcctOwner = ua.UserID
	join Users uap
		on ap.APOwner = uap.UserID	

	print 'deleting data from table [scAccountsCategories]'
	delete from [scAccountsCategories]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scAccountsCategories]'
	print ''

	print 'deleting data from table [scAccountsPubs]'
	delete from [scAccountsPubs]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scAccountsPubs]'
	print ''

	print 'deleting data from table [scChildAccounts]'
	delete from [scChildAccounts]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scChildAccounts]'
	print ''

	print 'deleting data from table [scAccountMappings]'
	delete from [scAccountMappings]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scAccountMappings]'
	print ''

	print 'deleting data from table [scAccounts]'
	delete from [scAccounts]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scAccounts]'
	print ''

	print 'deleting data from table [scRollups]'
	delete from [scRollups]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scRollups]'
	print ''
end

	--|Publications
if @pubs = 1
begin	
	print 'deleting data from table [scVariableDaysBack]'
	delete from [scVariableDaysBack]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scVariableDaysBack]'
	print ''

	print 'deleting data from table [scPublicationDates]'
	delete from [scPublicationDates]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scPublicationDates]'
	print ''

	print 'deleting data from table [nsPublications]'
	delete from [nsPublications]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [nsPublications]'
	print ''
end

	--|Devices
if @devices = 1
begin 
	print 'deleting data from table [nsDevices]'
	delete from [nsDevices]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [nsDevices]'
	print ''
end

	--|Misc
if @categories = 1
begin
	print 'deleting data from table [dd_scAccountCategories]'
	delete from [dd_scAccountCategories] where System <> 1
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [dd_scAccountCategories]'
	print ''
end

if @types = 1
begin
	print 'deleting data from table [dd_scAccountTypes]'
	delete from [dd_scAccountTypes] where System <> 1
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [dd_scAccountTypes]'
	print ''
end
	print 'deleting data from table [scDataExchangeControls]'
	delete from [scDataExchangeControls]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDataExchangeControls]'
	print ''

	--print 'deleting data from table [scDataExportControls]'
	--delete from [scDataExportControls]
	--print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDataExportControls]'
	--print ''

	print 'deleting data from table [scExportControls]'
	delete from [scExportControls]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scExportControls]'
	print ''


	print 'deleting data from table [scExportMappingControls]'
	delete from [scExportMappingControls]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scExportMappingControls]'
	print ''


	print 'deleting data from table [scConditionHistory]'
	delete from [scConditionHistory]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scConditionHistory]'
	print ''

	print 'deleting data from table [bulkAcctCatLoad]'
	delete from [bulkAcctCatLoad]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [bulkAcctCatLoad]'
	print ''

	print 'deleting data from table [nsMessages]...'
	delete from [nsMessages]
	print cast(@@rowcount as varchar) + ' rows deleted from [nsMessages]...'
	print ''



	--|Reseed Tables with Identity Columns
	declare @sql varchar(1024)
	declare @name varchar(50)
	declare @colname varchar(50)
	declare @ident int

	select sysobj.name as [tablename], syscol.name as [colname]
	into #identcols
	from syscolumns syscol
	join systypes systyp
		on syscol.xtype = systyp.xtype
	join sysobjects sysobj
		on syscol.id = sysobj.id
	where sysobj.type = 'U'
	and syscol.colstat = 1

	--/*
	declare ident_cursor cursor
	for 
	select *
	from #identcols

	open ident_cursor
	fetch next from ident_cursor into @name, @colname
	while @@fetch_status = 0
	begin
	print ''
	print @name + '(' + @colname + ')'
	print '---------------------------------------------------------------------------'
	set @sql = 'declare @ident int select @ident = isnull( max(' + @colname + '), 0 ) from ' + @name + ' dbcc checkident (''' + @name + ''', reseed, @ident )' 
	--set @sql = 'declare @ident int select @ident = isnull( max(' + @colname + '), 1 ) from ' + @name + ' dbcc checkident (''' + @name + ''' )' 
	exec(@sql)

	fetch next from ident_cursor into @name, @colname
	end

	close ident_cursor
	deallocate ident_cursor

	drop table #identcols

rollback tran