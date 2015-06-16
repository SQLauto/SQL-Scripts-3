begin tran

declare @coname nvarchar(50)
,@codbcatalog nvarchar(50)
,@codescription nvarchar(128)
,@conotes nvarchar(256)

set @coname = 'San Diego Union-Tribune'
set @codbcatalog = 'nsdb_sdut'
set @codescription = ''
set @conotes = ''

--/* Optional - Reseed CompanyId
declare @ident int
select @ident = isnull( max(companyid), 0 )
from nssession..nssessioncompanies

dbcc checkident ('nssession..nssessioncompanies', reseed, @ident )
--*/

if not exists ( select 1 from nssession..nssessioncompanies where CoDbCatalog = @codbcatalog )
begin
insert into nssession..nssessioncompanies (coname, codbcatalog, codescription, conotes, coactive)
select @coname, @codbcatalog, @codescription, @conotes, 1
end
else
begin
update nssession..nssessioncompanies 
set coname = @coname 
, codbcatalog = @codbcatalog
, codescription = @codescription
, conotes = @conotes
, coactive = 1
where CoDbCatalog = @codbcatalog
end

select *
from nssession..nssessioncompanies 
where CoDbCatalog = @codbcatalog

declare @sql nvarchar(2048)
set @sql = 'update ' + @codbcatalog + '..nsCompanies set cocustom2=''' + @coname + ' (' + @codbcatalog + ')'''
exec(@sql)

set @sql = 'select * from  ' + @codbcatalog + '..nsCompanies'
exec(@sql)

--rollback tran
commit tran 