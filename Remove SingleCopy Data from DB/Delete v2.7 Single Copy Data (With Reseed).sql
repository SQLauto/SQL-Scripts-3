begin tran

delete from scaccountdrops
delete from scaccountscategories
delete from sccategoryforecastrules
delete from scdrawadjustmentsaudit
delete from scdrawadjustments
delete from screturnsaudit
delete from screturns
delete from sctemporarydraws
delete from scdraws
delete from scdefaultdrawhistory
delete from scdefaultdraws
delete from scaccountmappings
delete from scaccountforecastrules
delete from scchildaccounts
delete from scaccounts
delete from dd_scaccountcategories where system <> 1
delete from dd_scaccounttypes where system <> 1
delete from scdrophistory
delete from scdrops
delete from scmanifesthistory
delete from scmanifestuploaddata
delete from scmanifesttransferdrops
delete from scmanifesttransfers
delete from scmanifestdownloadtrx
delete from scmanifestdownloadcancellations
delete from scmanifestsdrivers
delete from scmanifestqueue
delete from scmanifestcache
delete from scexportcontrols
delete from scdrawforecasts
delete from scmanifests
delete from nsdevices
delete from scvariabledaysback
delete from nspublications
delete from syncsystemlog

--|Reseed Tables with Identity Columns
declare @sql varchar(1024)
declare @name varchar(50)
declare @colname varchar(50)
declare @ident int

select sysobj.name as [tablename], syscol.name as [colname]
into #identcols
from syscolumns syscol
join systypes systyp
	on syscol.xtype = systyp.xtype
join sysobjects sysobj
	on syscol.id = sysobj.id
where sysobj.type = 'U'
and syscol.colstat = 1

--/*
declare ident_cursor cursor
for 
select *
from #identcols

open ident_cursor
fetch next from ident_cursor into @name, @colname
while @@fetch_status = 0
begin
print ''
print @name + '(' + @colname + ')'
print '---------------------------------------------------------------------------'
set @sql = 'declare @ident int select @ident = isnull( max(' + @colname + '), 1 ) from ' + @name + ' dbcc checkident (''' + @name + ''', reseed, @ident )' 
--set @sql = 'declare @ident int select @ident = isnull( max(' + @colname + '), 1 ) from ' + @name + ' dbcc checkident (''' + @name + ''' )' 
exec(@sql)

fetch next from ident_cursor into @name, @colname
end

close ident_cursor
deallocate ident_cursor

drop table #identcols

commit tran