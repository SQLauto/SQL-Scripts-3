declare @objectName	varchar(256)

set @objectname = 'scManifests'

create table #indexes (
	  IndexName nvarchar(256)
	, IndexDescription nvarchar(1024)
	, IndexKeys nvarchar(2048)
)
insert into #indexes
exec sp_helpindex @objectName
		
select o.[name], i.[name]
	, tmp.*
	from sysindexes i
join sysobjects o
	on i.id = o.id
join #indexes tmp
	on i.[name]	= tmp.IndexName
where o.type = 'u'
and o.[name] = @objectname
order by o.[name]


--select *
--from #indexes

drop table #indexes


