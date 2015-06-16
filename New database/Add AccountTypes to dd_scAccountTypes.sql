IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_AddImportAccountTypes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_AddImportAccountTypes]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[support_AddImportAccountTypes]
AS
/*
	[dbo].[support_AddImportAccountTypes]
	
	$History:  $
*/
BEGIN
	set nocount on

	declare @ident int

	select @ident = MAX(AccountTypeId)
	from dd_scAccountTypes

	dbcc checkident ('dd_scAccountTypes', reseed, @ident) 

	insert into dd_scAccountTypes (ATName, ATDescription, [System])
	select distinct AcctType as [ATName], AcctType as [ATDescription], 0 as [System]
	from scManifestLoad_View v
	left join dd_scAccountTypes typ
		on v.AcctType = typ.ATName
	where typ.AccountTypeId is null
	print cast(@@rowcount as nvarchar) + ' Account Types Added'

END
GO	