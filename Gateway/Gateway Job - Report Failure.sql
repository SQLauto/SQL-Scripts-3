set nocount on

/*
	If the Gateway process completes successfully, the EOJ_YYYYMMDD.DAT should be archived.  If an EOJ
	file does exist this indicates the process did not complete successfully.  This step will ensure that the scheduled job
	reports a failure.
*/

declare @msg nvarchar(512)
declare @filename nvarchar(50)
declare @filename_full nvarchar(100)


set @filename = 'EOJ_' 
	+ cast(DATEPART(yyyy, dateadd(d, 1, getdate())) as varchar)
	+ RIGHT( '00' +  cast(DATEPART(MM, dateadd(d, 1, getdate())) as varchar), 2 )
	+ RIGHT( '00' +  cast(DATEPART(DD, dateadd(d, 1, getdate())) as varchar), 2 )
	+ '.DAT'

set @filename_full = 'D:\Syncronex\PD\fromhost\' + @filename
	
print @filename

create table #eojFileExists ( file_exists int, is_file_directory int, parent_directory_exists int )


insert into #eojFileExists
exec master..xp_fileexist @filename_full

if exists (
	select file_exists
	from #eojFileExists
	where file_exists = 1
)
begin
	set @msg = 'Gateway process failed!  ' + @filename + ' exists in output directory.'
	print @msg
	exec nsSystemLog_Insert @ModuleId=2, @SeverityId=2, @Message=@msg
	
	raiserror ( 
		  @msg
		, 11
		, 1
	)	
end
else
begin
	set @msg = 'Gateway process completed successfully.'
	print @msg
	exec nsSystemLog_Insert @ModuleId=2, @SeverityId=2, @Message=@msg

end

drop table #eojFileExists
