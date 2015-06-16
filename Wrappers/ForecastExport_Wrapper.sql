IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[syncDBMaint_Wrapper]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[syncDBMaint_Wrapper]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[syncDBMaint_Wrapper]
AS
/*
	[dbo].[syncDBMaint_Wrapper]
	
	$History:  $
*/
BEGIN
	exec syncIndexMaintenance @db_name='nsdb_sdut'
	
	
END
GO	