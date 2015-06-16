IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_scDefaultDraws_Snapshot]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_scDefaultDraws_Snapshot]
GO

CREATE PROCEDURE [dbo].[support_scDefaultDraws_Snapshot]
AS
BEGIN
	set nocount on

	
	declare @bkp_name nvarchar(500)
	declare @sql nvarchar(4000)

	set @bkp_name = 'scDefaultDraws_Snapshot_' + right('00' + cast(datepart(mm, getdate()) as varchar),2)
		+ right('00' + cast(datepart(DD, getdate()) as varchar),2)
		+ right('0000' + cast(datepart(yyyy, getdate()) as varchar),4)
		+ '_'
		+ right('00' + cast(datepart(hh, getdate()) as varchar),2)
		+ right('00' + cast(datepart(minute, getdate()) as varchar),2)
		+ right('0000' + cast(datepart(ss, getdate()) as varchar),2)

	set @sql = 'select getdate() as [SnapshotDateTime], dd.*
				into ' + @bkp_name + '
				from scDefaultDraws dd'
	
	exec (@sql)
	print cast(@@rowcount as varchar) + ' rows backed up to ' + @bkp_name
	--set @sql = 'select *
	--		from ' + @bkp_name
	--exec(@sql)		
	
	--return @bkp_name	

END
GO

GRANT EXECUTE ON [dbo].[support_scDefaultDraws_Snapshot] to [nsUser]
GO