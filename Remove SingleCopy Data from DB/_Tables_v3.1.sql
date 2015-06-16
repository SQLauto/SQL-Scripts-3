
if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TablesWithCustomerData_v3_1]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[TablesWithCustomerData_v3_1] (
	[ObjectName] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ContainsCustomerData] [bit] NULL ,
	[DeleteOrder] [int] NULL 
) ON [PRIMARY]
END
ELSE
BEGIN
	DELETE FROM [dbo].[TablesWithCustomerData_v3_1]
END


INSERT INTO [dbo].[TablesWithCustomerData_v3_1] ( ObjectName, ContainsCustomerData, DeleteOrder )
          SELECT 'bulkAcctCatLoad', 1, 0
UNION ALL SELECT 'dd_Colors', 0, 0
UNION ALL SELECT 'dd_nsChangeTypes', 0, 0
UNION ALL SELECT 'dd_nsDeviceAdminProperties', 0, 0
UNION ALL SELECT 'dd_nsDeviceAdminValues', 0, 0
UNION ALL SELECT 'dd_nsDeviceTypes', 0, 0
UNION ALL SELECT 'dd_nsSystemValues', 0, 0
UNION ALL SELECT 'dd_scAccountCategories', 1, 460
UNION ALL SELECT 'dd_scAccountTypes', 1, 470
UNION ALL SELECT 'dd_scCommScriptClasses', 0, 0
UNION ALL SELECT 'dd_scConditionCodeCategories', 0, 0
UNION ALL SELECT 'dd_scConditionCodes', 0, 0
UNION ALL SELECT 'dd_scDeviceFileCategories', 0, 0
UNION ALL SELECT 'dd_scDeviceFiles', 0, 0
UNION ALL SELECT 'dd_scExportTypes', 0, 0
UNION ALL SELECT 'dd_scForecastRuleTypes', 0, 0
UNION ALL SELECT 'dd_scManifestTypes', 0, 0
UNION ALL SELECT 'dd_scProcessingStates', 0, 0
UNION ALL SELECT 'dd_scStateTaxCategories', 0, 0
UNION ALL SELECT 'dd_scStateTaxRates', 0, 0
UNION ALL SELECT 'dd_scTaxCategories', 0, 0
UNION ALL SELECT 'dd_scTaxRates', 0, 0
UNION ALL SELECT 'dd_syncModules', 0, 0
UNION ALL SELECT 'dd_syncSeverities', 0, 0
UNION ALL SELECT 'GroupACL', 0, 0
UNION ALL SELECT 'GroupFlags', 0, 0
UNION ALL SELECT 'Groups', 0, 0
UNION ALL SELECT 'Logins', 0, 0
UNION ALL SELECT 'LoginsForPDA', 0, 0
UNION ALL SELECT 'merc_ControlPanel', 0, 0
UNION ALL SELECT 'MJSysLog', 0, 0
UNION ALL SELECT 'nsCompanies', 0, 0
UNION ALL SELECT 'nsCompanyContacts', 0, 0
UNION ALL SELECT 'nsDevices', 1, 450
UNION ALL SELECT 'nsDevicesUsers', 0, 0
UNION ALL SELECT 'nsDistributionCenters', 0, 0
UNION ALL SELECT 'nsEditions', 0, 0
UNION ALL SELECT 'nsMessages', 0, 10
UNION ALL SELECT 'nsOptions', 0, 0
UNION ALL SELECT 'nsPriorities', 0, 0
UNION ALL SELECT 'nsPublicationForecastCutoffs', 0, 0
UNION ALL SELECT 'nsPublications', 1, 440
UNION ALL SELECT 'nsStates', 0, 0
UNION ALL SELECT 'nsStatuses', 0, 0
UNION ALL SELECT 'nsTypes', 0, 0
UNION ALL SELECT 'nsUsers', 0, 0
UNION ALL SELECT 'nsVersionInfo', 0, 0
UNION ALL SELECT 'RuleACL', 0, 0
UNION ALL SELECT 'scAccountMappings', 1, 390
UNION ALL SELECT 'scAccounts', 1, 400
UNION ALL SELECT 'scAccountsCategories', 1, 360
UNION ALL SELECT 'scAccountsPubs', 1, 370
UNION ALL SELECT 'scBillingHistory', 1, 350
UNION ALL SELECT 'scCategoryForecastRules', 1, 0
UNION ALL SELECT 'scChildAccounts', 1, 380
UNION ALL SELECT 'scConditionHistory', 1, 520
UNION ALL SELECT 'scDataExchangeControls', 1, 480
UNION ALL SELECT 'scDataExportCache', 1, 0
UNION ALL SELECT 'scDataExportControls', 1, 490
UNION ALL SELECT 'scDefaultDrawHistory', 1, 300
UNION ALL SELECT 'scDefaultDraws', 1, 310
UNION ALL SELECT 'scDeliveries', 1, 330
UNION ALL SELECT 'scDeliveriesExportCache', 1, 0
UNION ALL SELECT 'scDeliveryReceipts', 1, 320
UNION ALL SELECT 'scDrawAdjustmentsAudit', 1, 240
UNION ALL SELECT 'scDrawForecasts', 1, 270
UNION ALL SELECT 'scDrawHistory', 1, 280
UNION ALL SELECT 'scDraws', 1, 290
UNION ALL SELECT 'scExportControls', 1, 500
UNION ALL SELECT 'scExportLocks', 0, 0
UNION ALL SELECT 'scExportMappingControls', 1, 510
UNION ALL SELECT 'scForecastAccountRules', 1, 120
UNION ALL SELECT 'scForecastCategoryRules', 1, 130
UNION ALL SELECT 'scForecastExceptionDates', 1, 140
UNION ALL SELECT 'scForecastExceptionDateTypes', 1, 150
UNION ALL SELECT 'scForecastPublicationRules', 1, 160
UNION ALL SELECT 'scForecastRule_SalesOverrides', 1, 170
UNION ALL SELECT 'scForecastRule_SelloutOverrides', 1, 180
UNION ALL SELECT 'scForecastRules', 1, 230
UNION ALL SELECT 'scForecastWeightingTables', 1, 190
UNION ALL SELECT 'scGatewayImportDraw', 0, 0
UNION ALL SELECT 'scGatewayImportNYTimes', 0, 0
UNION ALL SELECT 'scGatewayImportNYTimesBad', 0, 0
UNION ALL SELECT 'scGatewayImportUSAToday', 0, 0
UNION ALL SELECT 'scGatewayImportUSATodayBad', 0, 0
UNION ALL SELECT 'scGatewayLogDraw', 0, 0
UNION ALL SELECT 'scGatewayLogLoc', 0, 0
UNION ALL SELECT 'scGatewayLogMessages', 0, 0
UNION ALL SELECT 'scGatewayLogNotes', 0, 0
UNION ALL SELECT 'scGatewayLogRet', 0, 0
UNION ALL SELECT 'scGatewayLogSig', 0, 0
UNION ALL SELECT 'scGatewayManifestDeviceList', 0, 0
UNION ALL SELECT 'scInvoiceExportCache', 0, 0
UNION ALL SELECT 'scInvoices', 1, 340
UNION ALL SELECT 'scManifestDownloadCancellations', 1, 10
UNION ALL SELECT 'scManifestHistory', 1, 40
UNION ALL SELECT 'scManifestLoad', 1, 100
UNION ALL SELECT 'scManifestLoad_R1', 0, 0
UNION ALL SELECT 'scManifestLoad_R3', 0, 0
UNION ALL SELECT 'scManifestQueue', 1, 110
UNION ALL SELECT 'scManifests', 1, 60
UNION ALL SELECT 'scManifestSequenceItems', 1, 70
UNION ALL SELECT 'scManifestSequences', 1, 50
UNION ALL SELECT 'scManifestSequenceTemplates', 1, 80
UNION ALL SELECT 'scManifestTemplates', 1, 90
UNION ALL SELECT 'scManifestTransferDrops', 1, 20
UNION ALL SELECT 'scManifestTransfers', 1, 30
UNION ALL SELECT 'scPublicationDates', 1, 430
UNION ALL SELECT 'scReturnsAudit', 1, 250
UNION ALL SELECT 'scRollups', 1, 410
UNION ALL SELECT 'scSalesOverrideLevels', 1, 200
UNION ALL SELECT 'scSalesOverrides', 1, 210
UNION ALL SELECT 'scSelloutOverrides', 1, 220
UNION ALL SELECT 'scTemporaryDraws', 1, 260
UNION ALL SELECT 'scUSATodayExportDraw', 0, 0
UNION ALL SELECT 'scUSATodayPubs', 0, 0
UNION ALL SELECT 'scVariableDaysBack', 1, 420
UNION ALL SELECT 'SecuredObjects', 0, 0
UNION ALL SELECT 'SiteGroups', 0, 0
UNION ALL SELECT 'syncSystemLog', 0, 0
UNION ALL SELECT 'syncSystemProperties', 0, 0
UNION ALL SELECT 'syncUpgradeScripts', 0, 0
UNION ALL SELECT 't2k_Site', 0, 0
UNION ALL SELECT 'UnitHist', 0, 0
UNION ALL SELECT 'UserACL', 0, 0
UNION ALL SELECT 'UserGroups', 0, 0
UNION ALL SELECT 'Users', 0, 0
UNION ALL SELECT 'UserSettings', 0, 0

/*
SELECT 'UNION ALL SELECT ''' + ObjectName + ''', ' + cast(isnull(ContainsCustomerData,0) as varchar) + ', ' + cast(isnull(DeleteOrder,0) as varchar)
FROM [dbo].[TablesWithCustomerData_v3_1]
*/