if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[scDeleteData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[scDeleteData]
go

create procedure [dbo].[scDeleteData]
	  @archive_min datetime
	, @archive_max datetime
	, @reseed int = 0
as
/*

*/
begin
	set nocount on 

	declare @dbname nvarchar(256)
	declare @dbsize nvarchar(25)
	declare @msg    nvarchar(1024)
	declare @src	nvarchar(50)

	set @src = 'scDeleteData'
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
		print 'deleting data from table [scManifestDownloadCancellations]'
			delete scManifestDownloadCancellations 
			from scManifestDownloadCancellations cxl
			join scManifestTransfers mt
				on cxl.ManifestTransferId = mt.ManifestTransferId
			where MfstDate between @archive_min and @archive_max
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestDownloadCancellations]'
		--print ''

		print 'deleting data from table [scManifestTransferDrops]'
			delete scManifestTransferDrops
			from scManifestTransfers mt
			join scManifestTransferDrops mtd
				on mt.ManifestTransferId = mtd.ManifestTransferId
			where MfstDate between @archive_min and @archive_max
			

		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestTransferDrops]'
		--print ''

		print 'deleting data from table [scManifestTransfers]'
			delete 
			from scManifestTransfers
			where MfstDate between @archive_min and @archive_max
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestTransfers]'
		--print ''

		print 'deleting data from table [scManifestHistory]'
			delete 
			from scManifestHistory
			where MHEffectiveDate between @archive_min and @archive_max
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestHistory]'
		--print ''

		print 'deleting data from table [scManifestSequences]'
			delete scManifestSequences
			from scManifests m
			join scManifestSequences ms
				on m.ManifestId = ms.ManifestId
			where ManifestDate between @archive_min and @archive_max
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestSequences]'
		--print ''

		print 'deleting data from table [scManifests]'
			delete 
			from scManifests
			where ManifestDate between @archive_min and @archive_max
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifests]'
		--print ''

		print 'deleting data from table [scManifestLoad]'
			delete 
			from scManifestLoad
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestLoad]'
		--print ''

		print 'deleting data from table [scManifestQueue]'
			delete 
			from scManifestQueue
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestQueue]'
		--print ''

		--|Forecasting
	/*
		print 'deleting data from table [scForecastAccountRules]'
		delete from [scForecastAccountRules]
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastAccountRules]'
		--print ''

		print 'deleting data from table [scForecastCategoryRules]'
		delete from [scForecastCategoryRules]
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastCategoryRules]'
		--print ''
	*/
		print 'deleting data from table [scForecastExceptionDates]'
			delete 
			from scForecastExceptionDates
			where ExceptionDate between @archive_min and @archive_max		
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastExceptionDates]'
		--print ''
	/*
		print 'deleting data from table [scForecastExceptionDateTypes]'
		delete from [scForecastExceptionDateTypes]
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastExceptionDateTypes]'
		--print ''

		print 'deleting data from table [scForecastPublicationRules]'
		delete from [scForecastPublicationRules]
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastPublicationRules]'
		--print ''

		print 'deleting data from table [scForecastRule_SalesOverrides]'
		delete from [scForecastRule_SalesOverrides]
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastRule_SalesOverrides]'
		--print ''

		print 'deleting data from table [scForecastRule_SelloutOverrides]'
		delete from [scForecastRule_SelloutOverrides]
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastRule_SelloutOverrides]'
		--print ''

		print 'deleting data from table [scForecastWeightingTables]'
		delete from [scForecastWeightingTables]
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastWeightingTables]'
		--print ''

		print 'deleting data from table [scSalesOverrideLevels]'
		delete from [scSalesOverrideLevels]
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scSalesOverrideLevels]'
		--print ''

		print 'deleting data from table [scSalesOverrides]'
		delete from [scSalesOverrides]
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scSalesOverrides]'
		--print ''

		print 'deleting data from table [scSelloutOverrides]'
		delete from [scSelloutOverrides]
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scSelloutOverrides]'
		--print ''

		print 'deleting data from table [scForecastRules]'
		delete from [scForecastRules]
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scForecastRules]'
		--print ''
	*/
		--|Draws
		print 'deleting data from table [scDrawAdjustmentsAudit]'
			delete scDrawAdjustmentsAudit
			from scDraws d
			join scDrawAdjustmentsAudit da
				on d.DrawId = da.DrawId
			where DrawDate between @archive_min and @archive_max
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDrawAdjustmentsAudit]'
		--print ''

		print 'deleting data from table [scReturnsAudit]'
			delete scReturnsAudit
			from scDraws d
			join scReturnsAudit ra
				on d.DrawId = ra.DrawId
			where DrawDate between @archive_min and @archive_max
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scReturnsAudit]'
		--print ''

		print 'deleting data from table [scTemporaryDraws]'
			delete 
			from scTemporaryDraws
			where EffectiveDateStart between @archive_min and @archive_max
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scTemporaryDraws]'
		--print ''

		print 'deleting data from table [scDrawForecasts]'
			delete 
			from scDrawForecasts
			where DFDate between @archive_min and @archive_max
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDrawForecasts]'
		--print ''

		print 'deleting data from table [scDrawHistory]'
			delete 
			from scDrawHistory
			where DrawDate between @archive_min and @archive_max
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDrawHistory]'
		--print ''

		print 'deleting data from table [scDraws]'
			delete 
			from scDraws
			where DrawDate between @archive_min and @archive_max
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDraws]'
		--print ''

		print 'deleting data from table [scDefaultDrawHistory]'
			delete 
			from scDefaultDrawHistory
			where DrawHistoryDate between @archive_min and @archive_max
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDefaultDrawHistory]'
		--print ''
	/*
		print 'deleting data from table [scDefaultDraws]'
			delete 
			from scDefaultDraws
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDefaultDraws]'
		--print ''
	*/
		print 'deleting data from table [scDeliveryReceipts]'
			delete 
			from scDeliveryReceipts
			where DrawDate between @archive_min and @archive_max
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDeliveryReceipts]'
		--print ''

		--|Billing
		print 'deleting data from table [scDeliveries]'
			delete 
			from scDeliveries
			where DrawDate between @archive_min and @archive_max
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDeliveries]'
		--print ''

		print 'deleting data from table [scInvoices]'
			delete 
			from scInvoices
			where InvoiceDate between @archive_min and @archive_max
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scInvoices]'
		--print ''

		print 'deleting data from table [scBillingHistory]'
			delete 
			from scBillingHistory
			where DatesCoveredStart between @archive_min and @archive_max
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scBillingHistory]'
		--print ''

		--|Accounts
	/*
		print 'deleting data from table [scAccountsCategories]'
		delete from [scAccountsCategories]
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scAccountsCategories]'
		--print ''

		print 'deleting data from table [scAccountsPubs]'
		delete from [scAccountsPubs]
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scAccountsPubs]'
		--print ''

		print 'deleting data from table [scChildAccounts]'
		delete from [scChildAccounts]
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scChildAccounts]'
		--print ''

		print 'deleting data from table [scAccountMappings]'
		delete from [scAccountMappings]
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scAccountMappings]'
		--print ''

		print 'deleting data from table [scAccounts]'
		delete from [scAccounts]
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scAccounts]'
		--print ''

		print 'deleting data from table [scRollups]'
		delete from [scRollups]
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scRollups]'
		--print ''
	*/

		--|Publications
	/*
		print 'deleting data from table [scVariableDaysBack]'
		delete from [scVariableDaysBack]
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scVariableDaysBack]'
		--print ''
	*/
		print 'deleting data from table [scPublicationDates]'
			delete 
			from scPublicationDates
			where DrawDate between @archive_min and @archive_max
			
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scPublicationDates]'
		--print ''
	/*
		print 'deleting data from table [nsPublications]'
		delete from [nsPublications]
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [nsPublications]'
		--print ''

		--|Devices
		print 'deleting data from table [nsDevices]'
		delete from [nsDevices]
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [nsDevices]'
		--print ''


		--|Misc

		print 'deleting data from table [dd_scAccountCategories]'
		delete from [dd_scAccountCategories] where System <> 1
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [dd_scAccountCategories]'
		--print ''

		print 'deleting data from table [dd_scAccountTypes]'
		delete from [dd_scAccountTypes] where System <> 1
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [dd_scAccountTypes]'
		--print ''
	*/
		print 'deleting data from table [scDataExchangeControls]'
			delete 
			from scDataExchangeControls
			where CriteriaStart between @archive_min and @archive_max
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDataExchangeControls]'
		--print ''

		print 'deleting data from table [scDataExportControls]'
			delete 
			from scDataExportControls
			where DEControlDate between @archive_min and @archive_max
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scDataExportControls]'
		--print ''

		print 'deleting data from table [scExportControls]'
			delete 
			from scExportControls
			where ExportCtrlDateTime between @archive_min and @archive_max
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scExportControls]'
		--print ''

	/*
		print 'deleting data from table [scExportMappingControls]'
		delete from [scExportMappingControls]
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scExportMappingControls]'
		--print ''
	*/

		print 'deleting data from table [scConditionHistory]'
			delete 
			from scConditionHistory
			where ConHistoryDate between @archive_min and @archive_max
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scConditionHistory]'
		--print ''

		print 'deleting data from table [bulkAcctCatLoad]'
		delete from [bulkAcctCatLoad]
		print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [bulkAcctCatLoad]'
		--print ''

	if @reseed = 1
	begin
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
end