IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[support_EngineStatus]'))
DROP VIEW [dbo].[support_EngineStatus]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[support_EngineStatus]
as


	select 'Export' as [Engine]
		, cast(running.SysPropertyValue as bit) | cast(requested.SysPropertyValue as bit) as [Running]
		, ExportType as [Type]
		, BeginDate, EndDate
		, DATEDIFF(d, getdate(), BeginDate) as beginDateOffset_RelativeToRunOnDay
		, DATEDIFF(d, getdate(), EndDate) as endDateOffset_RelativeToRunOnDay
	from (
		select SysPropertyValue
		from syncSystemProperties 
		where SysPropertyName = 'DataExportRunning'
		) as running
	join (
		select SysPropertyValue
		from syncSystemProperties 
		where SysPropertyName = 'RunDataExport'
		) as requested
		on 1 = 1
	join (
		select left( SysPropertyValue, CHARINDEX('"', SysPropertyValue) - 2 ) as [ExportType]
			, SUBSTRING( SysPropertyValue
				, CHARINDEX( 'StartDate=', SysPropertyValue ) + LEN('StartDate=') 
				, 8 ) as [BeginDate]
			, SUBSTRING( SysPropertyValue
				, CHARINDEX( 'StopDate=', SysPropertyValue ) + LEN('StopDate=') 
				, 8 )	as [EndDate]
		from syncSystemProperties
		where SysPropertyName = 'DataExportCommandArgs'
		) as info
		on 1 = 1

	union all 



	select 'Forecast' as [Engine]
		, cast(running.AttributeValue as bit) | cast(requested.AttributeValue as bit) as [Running]
		, null as [Type]
		, BeginDate, EndDate
		, DATEDIFF(d, getdate(), BeginDate) as beginDateOffset_RelativeToRunOnDay
		, DATEDIFF(d, getdate(), EndDate) as endDateOffset_RelativeToRunOnDay		
	from (
		select AttributeName, AttributeValue
		from merc_ControlPanel 
		where AppLayer = 'ForecastEngine' 
		and AttributeName = 'EngineLock'
		) as running
	join (
		select AttributeName, AttributeValue
		from merc_ControlPanel 
		where AppLayer = 'ForecastEngine' 
		and AttributeName = 'EngineRequest'
		) as requested
		on 1 = 1
	join (
		select BeginDate, EndDate
		from (
			select AttributeValue as BeginDate
			from merc_ControlPanel m1
			where AttributeName = 'BeginDate'
		) as bd
		join (
			select AttributeValue as EndDate
			from merc_ControlPanel m2
			where AttributeName = 'EndDate'
		) as ed
		on 1 = 1	
		) as info		
		on 1 = 1	

GO



select *
from support_EngineStatus