declare @sql nvarchar(500)
declare @db nvarchar(20)

set @db = 'nsdb_ric'
--set @server = 'MGSYNCRONEX1'
--bcp nsdb_sun.dbo.CustomExport_AccountInfo_View out C:\inetpub\ftproot\LocalUser\mcsun\AccountInfo1.txt -S S1 -U nsadmin -P nsadmin -c -t^|

set @sql = 'bcp ' + @db + '..bcpSales out C:\Inetpub\Syncronex\ric\out\bcpSales.txt'
set @sql = @sql + ' -S ' + @@servername
set @sql = @sql + ' -U nsadmin -P nsadmin -c -t^|'

print @sql
exec xp_cmdshell @sql 
