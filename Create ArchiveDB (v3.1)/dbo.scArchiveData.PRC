if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[scArchiveData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[scArchiveData]
go

create procedure [dbo].[scArchiveData]
	  @archive_min datetime
	, @archive_max datetime
	, @reseed int = 0
as
/*

*/
begin
	set nocount on 

/*
	db stats/shrink
*/
declare @name nvarchar(100)
declare @msg    nvarchar(1024)
	declare @src	nvarchar(50)
	declare @count	int

declare @dbname nvarchar(256)
declare @dbsize nvarchar(25)


select @name = db_name()
set @src = 'scArchiveData'

  ---------------------------
--|	Database Statistics		|--
  ---------------------------
	CREATE TABLE #helpdb (
		[name] nvarchar(100)
		,[dbsize] nvarchar(25)
		,[owner] nvarchar(25)
		,[dbid] int
		,[created] datetime
		,[status] nvarchar(256)
		,[compatiblity_level] int
	   )

	INSERT INTO #helpdb
	EXEC sp_helpdb

	select @dbname = [name]
			,@dbsize = [dbsize]
	from #helpdb
	where [name] = ( select db_name() )
	
	set @msg = @src + ': database size is ' + @dbsize
	print @msg
	exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src


	--|Manifests
	print 'archiving data in table [scManifestDownloadCancellations]'
		delete 
		from scManifestDownloadCancellations
		where MfstDownloadCancelled not between @archive_min and @archive_max
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestDownloadCancellations]'
	--print ''

	print 'archiving data in table [scManifestTransferDrops]'
		delete scManifestTransferDrops
		from scManifestTransfers mt
		join scManifestTransferDrops mtd
			on mt.ManifestTransferId = mtd.ManifestTransferId
		where MfstDate not between @archive_min and @archive_max
		

	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestTransferDrops]'
	--print ''

	print 'archiving data in table [scManifestTransfers]'
		delete 
		from scManifestTransfers
		where MfstDate not between @archive_min and @archive_max
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestTransfers]'
	--print ''

	print 'archiving data in table [scManifestHistory]'
		delete 
		from scManifestHistory
		where MHEffectiveDate not between @archive_min and @archive_max
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestHistory]'
	--print ''

	print 'archiving data in table [scManifestSequences]'
		delete scManifestSequences
		from scManifests m
		join scManifestSequences ms
			on m.ManifestId = ms.ManifestId
		where ManifestDate not between @archive_min and @archive_max
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestSequences]'
	--print ''

	print 'archiving data in table [scManifests]'
		delete 
		from scManifests
		where ManifestDate not between @archive_min and @archive_max
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifests]'
	--print ''

	print 'archiving data in table [scManifestLoad]'
		delete 
		from scManifestLoad
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestLoad]'
	--print ''

	print 'archiving data in table [scManifestQueue]'
		delete 
		from scManifestQueue
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestQueue]'
	--print ''

	--|Forecasting
/*
	print 'archiving data in table [scForecastAccountRules]'
	delete from [scForecastAccountRules]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastAccountRules]'
	--print ''

	print 'archiving data in table [scForecastCategoryRules]'
	delete from [scForecastCategoryRules]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastCategoryRules]'
	--print ''
*/
	print 'archiving data in table [scForecastExceptionDates]'
		delete 
		from scForecastExceptionDates
		where ExceptionDate not between @archive_min and @archive_max		
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastExceptionDates]'
	--print ''
/*
	print 'archiving data in table [scForecastExceptionDateTypes]'
	delete from [scForecastExceptionDateTypes]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastExceptionDateTypes]'
	--print ''

	print 'archiving data in table [scForecastPublicationRules]'
	delete from [scForecastPublicationRules]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastPublicationRules]'
	--print ''

	print 'archiving data in table [scForecastRule_SalesOverrides]'
	delete from [scForecastRule_SalesOverrides]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastRule_SalesOverrides]'
	--print ''

	print 'archiving data in table [scForecastRule_SelloutOverrides]'
	delete from [scForecastRule_SelloutOverrides]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastRule_SelloutOverrides]'
	--print ''

	print 'archiving data in table [scForecastWeightingTables]'
	delete from [scForecastWeightingTables]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastWeightingTables]'
	--print ''

	print 'archiving data in table [scSalesOverrideLevels]'
	delete from [scSalesOverrideLevels]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scSalesOverrideLevels]'
	--print ''

	print 'archiving data in table [scSalesOverrides]'
	delete from [scSalesOverrides]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scSalesOverrides]'
	--print ''

	print 'archiving data in table [scSelloutOverrides]'
	delete from [scSelloutOverrides]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scSelloutOverrides]'
	--print ''

	print 'archiving data in table [scForecastRules]'
	delete from [scForecastRules]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastRules]'
	--print ''
*/
	--|Draws
	print 'archiving data in table [scDrawAdjustmentsAudit]'
		delete scDrawAdjustmentsAudit
		from scDraws d
		join scDrawAdjustmentsAudit da
			on d.DrawId = da.DrawId
		where DrawDate not between @archive_min and @archive_max
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDrawAdjustmentsAudit]'
	--print ''

	print 'archiving data in table [scReturnsAudit]'
		delete scReturnsAudit
		from scDraws d
		join scReturnsAudit ra
			on d.DrawId = ra.DrawId
		where DrawDate not between @archive_min and @archive_max
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scReturnsAudit]'
	--print ''

	print 'archiving data in table [scTemporaryDraws]'
		delete 
		from scTemporaryDraws
		where EffectiveDateStart not between @archive_min and @archive_max
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scTemporaryDraws]'
	--print ''

	print 'archiving data in table [scDrawForecasts]'
		delete 
		from scDrawForecasts
		where DFDate not between @archive_min and @archive_max
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDrawForecasts]'
	--print ''

	print 'archiving data in table [scDrawHistory]'
		delete 
		from scDrawHistory
		where DrawDate not between @archive_min and @archive_max
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDrawHistory]'
	--print ''

	print 'archiving data in table [scDraws]'
		delete 
		from scDraws
		where DrawDate not between @archive_min and @archive_max
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDraws]'
	--print ''

	print 'archiving data in table [scDefaultDrawHistory]'
		delete 
		from scDefaultDrawHistory
		where DrawHistoryDate not between @archive_min and @archive_max
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDefaultDrawHistory]'
	--print ''
/*
	print 'archiving data in table [scDefaultDraws]'
		delete 
		from scDefaultDraws
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDefaultDraws]'
	--print ''
*/
	print 'archiving data in table [scDeliveryReceipts]'
		delete 
		from scDeliveryReceipts
		where DrawDate not between @archive_min and @archive_max
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDeliveryReceipts]'
	--print ''

	--|Billing
	print 'archiving data in table [scDeliveries]'
		delete 
		from scDeliveries
		where DrawDate not between @archive_min and @archive_max
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDeliveries]'
	--print ''

	print 'archiving data in table [scInvoices]'
		delete 
		from scInvoices
		where InvoiceDate not between @archive_min and @archive_max
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scInvoices]'
	--print ''

	print 'archiving data in table [scBillingHistory]'
		delete 
		from scBillingHistory
		where DatesCoveredStart not between @archive_min and @archive_max
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scBillingHistory]'
	--print ''

	--|Accounts
/*
	print 'archiving data in table [scAccountsCategories]'
	delete from [scAccountsCategories]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scAccountsCategories]'
	--print ''

	print 'archiving data in table [scAccountsPubs]'
	delete from [scAccountsPubs]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scAccountsPubs]'
	--print ''

	print 'archiving data in table [scChildAccounts]'
	delete from [scChildAccounts]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scChildAccounts]'
	--print ''

	print 'archiving data in table [scAccountMappings]'
	delete from [scAccountMappings]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scAccountMappings]'
	--print ''

	print 'archiving data in table [scAccounts]'
	delete from [scAccounts]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scAccounts]'
	--print ''

	print 'archiving data in table [scRollups]'
	delete from [scRollups]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scRollups]'
	--print ''
*/

	--|Publications
/*
	print 'archiving data in table [scVariableDaysBack]'
	delete from [scVariableDaysBack]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scVariableDaysBack]'
	--print ''
*/
	print 'archiving data in table [scPublicationDates]'
		delete 
		from scPublicationDates
		where DrawDate not between @archive_min and @archive_max
		
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scPublicationDates]'
	--print ''
/*
	print 'archiving data in table [nsPublications]'
	delete from [nsPublications]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [nsPublications]'
	--print ''

	--|Devices
	print 'archiving data in table [nsDevices]'
	delete from [nsDevices]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [nsDevices]'
	--print ''


	--|Misc

	print 'archiving data in table [dd_scAccountCategories]'
	delete from [dd_scAccountCategories] where System <> 1
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [dd_scAccountCategories]'
	--print ''

	print 'archiving data in table [dd_scAccountTypes]'
	delete from [dd_scAccountTypes] where System <> 1
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [dd_scAccountTypes]'
	--print ''
*/
	print 'archiving data in table [scDataExchangeControls]'
		delete 
		from scDataExchangeControls
		where CriteriaStart not between @archive_min and @archive_max
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDataExchangeControls]'
	--print ''

	print 'archiving data in table [scDataExportControls]'
		delete 
		from scDataExportControls
		where DEControlDate not between @archive_min and @archive_max
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDataExportControls]'
	--print ''

	print 'archiving data in table [scExportControls]'
		delete 
		from scExportControls
		where ExportCtrlDateTime not between @archive_min and @archive_max
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scExportControls]'
	--print ''

/*
	print 'archiving data in table [scExportMappingControls]'
	delete from [scExportMappingControls]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scExportMappingControls]'
	--print ''
*/

	print 'archiving data in table [scConditionHistory]'
		delete 
		from scConditionHistory
		where ConHistoryDate not between @archive_min and @archive_max
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scConditionHistory]'
	--print ''

	print 'archiving data in table [bulkAcctCatLoad]'
	delete from [bulkAcctCatLoad]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [bulkAcctCatLoad]'
	--print ''

if @reseed = 1
begin
	--|Reseed Tables with Identity Columns
	declare @sql varchar(1024)
	--declare @name varchar(50)
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
	--print ''
	print @name + '(' + @colname + ')'
	print '---------------------------------------------------------------------------'
	set @sql = 'declare @ident int select @ident = isnull( max(' + @colname + '), 1 ) from ' + @name + ' dbcc checkident (''' + @name + ''', reseed, @ident )' 
	--set @sql = 'declare @ident int select @ident = isnull( max(' + @colname + '), 1 ) from ' + @name + ' dbcc checkident (''' + @name + ''' )' 
	exec(@sql)

	fetch next from ident_cursor into @name, @colname
	end

	close ident_cursor
	deallocate ident_cursor

	drop table #identcols
end

	--|  Shrink
	set @sql = 'DBCC SHRINKFILE(''' +  @dbname + ''', 0 )'
	print @sql
	exec(@sql)
	set @sql = 'DBCC SHRINKFILE(''' +  @dbname + '_log'', 0 )'
	print @sql
	exec(@sql)

	truncate table #helpdb
	insert into #helpdb
	exec sp_helpdb

	select @dbname = [name]
			,@dbsize = [dbsize]
	from #helpdb
	where [name] = ( select db_name() )
	
	set @msg = @src + ': database size is ' + @dbsize
	print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

end	