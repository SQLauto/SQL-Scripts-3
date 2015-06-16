IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_ExportLocked]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_ExportLocked]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[support_ExportLocked]
	@locked int output	
AS
BEGIN

	select @locked = cast(running.SysPropertyValue as bit) | cast(requested.SysPropertyValue as bit)
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

	select @locked output
END
GO	
	
GRANT EXECUTE ON [dbo].[support_ExportLocked] TO [nsUser]	
GO