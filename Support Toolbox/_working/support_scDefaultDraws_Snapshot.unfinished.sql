IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_scDefaultDraws_Snapshot]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_scDefaultDraws_Snapshot]
GO

CREATE PROCEDURE [dbo].[support_scDraws_Snapshot]
	  @minDrawDate datetime = null
	, @maxDrawDate datetime = null
AS
BEGIN
	set nocount on

	
	declare @bkp_name nvarchar(500)
	declare @beginDate datetime
	declare @endDate datetime
	
	if ( @minDrawDate is null and @maxDrawDate is null )
	return
	
	set @beginDate = convert(varchar, getdate(), 1)
	select @endDate = max(DrawDate)
	from scDraws 
	
	print @beginDate
	print @endDate
	
	declare @sql nvarchar(4000)

	set @bkp_name = 'scDraws_Snapshot_' + right('00' + cast(datepart(mm, getdate()) as varchar),2)
		+ right('00' + cast(datepart(DD, getdate()) as varchar),2)
		+ right('0000' + cast(datepart(yyyy, getdate()) as varchar),4)
		+ '_'
		+ right('00' + cast(datepart(hh, getdate()) as varchar),2)
		+ right('00' + cast(datepart(minute, getdate()) as varchar),2)
		+ right('0000' + cast(datepart(ss, getdate()) as varchar),2)

	set @sql = 'select getdate() as [SnapshotDateTime], d.*
				into ' + @bkp_name + '
				from scDraws d
				where DrawDate between ''' + convert(varchar,@beginDate,1) + ''' and ''' + convert(varchar,@endDate,1) + ''''
	
	exec (@sql)
	print cast(@@rowcount as varchar) + ' rows backed up to ' + @bkp_name
	--set @sql = 'select *
	--		from ' + @bkp_name
	--exec(@sql)		
	
	--return @bkp_name	

END
GO

GRANT EXECUTE ON [dbo].[support_scDraws_Snapshot] to [nsUser]
GO

exec support_scDraws_Snapshot