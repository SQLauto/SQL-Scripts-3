if not exists (select * from master..syslogins where name = 'dmconfig')
begin
	exec sp_addlogin 'dmconfig', 'dmconfig', 'SDMConfig'
end

if not exists (select * from master..syslogins where name = 'dmweb')
begin
	exec sp_addlogin 'dmweb', 'dmweb', 'SDMData'
end

--|SDMConfig
use sdmconfig
go

--|dmconfig
if exists (select * from sysusers where name = N'dmconfig')
begin
	exec sp_dropuser 'dmconfig'
end
go

if not exists (select * from sysusers where name = N'dmconfig')
begin
	exec sp_grantdbaccess N'dmconfig', N'dmconfig'
end
go

exec sp_addrolemember N'db_owner',N'dmconfig'
go

--|dmweb
if exists (select * from sysusers where name = N'dmweb')
begin
	exec sp_dropuser 'dmweb'
end
go

if not exists (select * from sysusers where name = N'dmweb')
begin
	exec sp_grantdbaccess N'dmweb', N'dmweb'
end
go

exec sp_addrolemember N'db_owner',N'dmweb'
go


--|SDMData
use sdmdata
go

--|dmconfig
if exists (select * from sysusers where name = N'dmconfig')
begin
	exec sp_dropuser 'dmconfig'
end
go

if not exists (select * from sysusers where name = N'dmconfig')
begin
	exec sp_grantdbaccess N'dmconfig', N'dmconfig'
end
go

exec sp_addrolemember N'db_owner',N'dmconfig'
go

--|dmweb
if exists (select * from sysusers where name = N'dmweb')
begin
	exec sp_dropuser 'dmweb'
end
go

if not exists (select * from sysusers where name = N'dmweb')
begin
	exec sp_grantdbaccess N'dmweb', N'dmweb'
end
go

exec sp_addrolemember N'db_owner',N'dmweb'
go
