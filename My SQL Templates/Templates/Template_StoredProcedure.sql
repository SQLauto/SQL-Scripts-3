IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[<Procedure_Name, sysname, stored_procedure_name>]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[<Procedure_Name, sysname, stored_procedure_name>]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[<Procedure_Name, sysname, stored_procedure_name>]
	  @param1 nvarchar(20) = null
	, @param2 int = null
	, @param3 datetime = null
AS
/*
	[dbo].[<Procedure_Name, sysname, stored_procedure_name>]
	
	$History:  $
*/
BEGIN
	
END
GO	