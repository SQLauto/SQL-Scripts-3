declare @sql nvarchar(500)
declare @db nvarchar(20)

set @db = 'nsdb_dal'

set @sql = 'bcp ' + @db + '..CustomExport_AccountInfo_View out C:\inetpub\ftproot\LocalUser\tdmnftp\AccountDump.txt'
set @sql = @sql + ' -S ' + @@servername
set @sql = @sql + ' -U nsadmin -P nsadmin -c -t^|'

print @sql
exec xp_cmdshell @sql 
