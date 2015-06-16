IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_BackupTable]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_BackupTable]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[support_BackupTable]
	  @tablename nvarchar(250) = null
	, @include_timestamp int = null
	, @bkp_name nvarchar(500) output
AS
BEGIN
	set nocount on

	if not exists (
		select id
		from sysobjects
		where name = @tablename
	)
	begin
		print 'Table [' + @tablename + '] does not exist so it cannot be backed up.'
		return
	end
	
	--declare @bkp_name nvarchar(500)
	declare @sql nvarchar(4000)

	set @bkp_name = @tablename + '_' + right('00' + cast(datepart(mm, getdate()) as varchar),2)
	+ right('00' + cast(datepart(DD, getdate()) as varchar),2)
	+ right('0000' + cast(datepart(yyyy, getdate()) as varchar),4)
	
	if @include_timestamp = 1
	begin
		set @bkp_name = @bkp_name + '_'
			+ right('00' + cast(datepart(hh, getdate()) as varchar),2)
			+ right('00' + cast(datepart(minute, getdate()) as varchar),2)
			+ right('0000' + cast(datepart(ss, getdate()) as varchar),2)
	end

	set @sql = 'select *
				into ' + @bkp_name + '
				from ' + @tablename
	
	exec (@sql)
	print cast(@@rowcount as varchar) + ' rows backed up to ' + @bkp_name
	--set @sql = 'select *
	--		from ' + @bkp_name
	--exec(@sql)		
	
	--return @bkp_name	

END
GO	

--sample execution
declare @backup nvarchar(500)
exec support_BackupTable @tablename='dd_scAccountTypes', @include_timestamp=1, @bkp_name=@backup output
print @backup
