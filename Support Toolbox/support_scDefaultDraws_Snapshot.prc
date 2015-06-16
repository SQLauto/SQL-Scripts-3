IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_scDefaultDraws_Snapshot]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_scDefaultDraws_Snapshot]
GO

CREATE PROCEDURE [dbo].[support_scDefaultDraws_Snapshot]
	  @bkp_name nvarchar(500) = null output
	, @returnResults int = 0 
AS
BEGIN
	set nocount on

	
	declare @sql nvarchar(4000)

	set @bkp_name = 'dbo.scDefaultDraws_Snapshot_' + right('00' + cast(datepart(mm, getdate()) as varchar),2)
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
	
	if @returnResults = 1
	begin
		set @sql = 'select *
				from ' + @bkp_name
		exec(@sql)		
	end

END
GO

GRANT EXECUTE ON [dbo].[support_scDefaultDraws_Snapshot] to [nsUser]
GO

/*

begin tran

    declare @backup nvarchar(500)
    
    exec support_scDefaultDraws_Snapshot @bkp_Name=@backup output, @returnResults=1

	print @backup
	
rollback tran	

*/
