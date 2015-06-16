IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_ResetExportStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_ResetExportStatus]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[support_ResetExportStatus]
AS
BEGIN
	select *
	from (
		select SysPropertyValue as [Running]
		from syncSystemProperties 
		where SysPropertyName = 'DataExportRunning'
		) as running
	join (
		select SysPropertyValue as [Requested]
		from syncSystemProperties 
		where SysPropertyName = 'RunDataExport'
		) as requested
	on 1 = 1
	
	update syncSystemProperties
	set SysPropertyValue = 'false'
	where SysPropertyName = 'DataExportRunning'


	update syncSystemProperties
	set SysPropertyValue = 'false'
	where SysPropertyName = 'RunDataExport'

	select *
	from (
		select SysPropertyValue as [Running]
		from syncSystemProperties 
		where SysPropertyName = 'DataExportRunning'
		) as running
	join (
		select SysPropertyValue as [Requested]
		from syncSystemProperties 
		where SysPropertyName = 'RunDataExport'
		) as requested
	on 1 = 1
END
GO	