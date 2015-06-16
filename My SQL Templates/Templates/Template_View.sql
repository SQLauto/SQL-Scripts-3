IF EXISTS (select * from dbo.sysobjects where id = object_id(N'<schema_name, sysname, dbo>.<view_name, sysname, sample_view>') and OBJECTPROPERTY(id, N'IsView') = 1)
	DROP VIEW <schema_name, sysname, dbo>.<view_name, sysname, sample_view>
GO

CREATE VIEW <schema_name, sysname, dbo>.<view_name, sysname, sample_view>
AS
/*
	$History:  $
	
*/

	select *
	from sysobjects
	
GO

/*
GRANT SELECT ON <schema_name, sysname, dbo>.<view_name, sysname, sample_view> TO <user_name, sysname, nsUser>
GO
*/

