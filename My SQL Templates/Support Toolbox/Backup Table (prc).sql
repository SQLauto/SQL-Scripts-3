
declare @backup nvarchar(500)
exec support_BackupTable @tablename='scDefaultDraws', @include_timestamp=1, @bkp_name=@backup output
print @backup
