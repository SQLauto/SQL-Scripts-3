/*
DIFFERENCES REPORT
*/
begin tran

set nocount on

select nsdb.name, nsdbcol.name as [colname]
into #nsdbcols
from nsdb..sysobjects nsdb
join nsdb..syscolumns nsdbcol
	on nsdbcol.id = nsdb.id
where nsdb.type = 'U'
order by nsdb.name

select nsdb26.name, nsdb26col.name as [colname]
into #nsdb26cols
from nsdb26..sysobjects nsdb26
join nsdb26..syscolumns nsdb26col
	on nsdb26col.id = nsdb26.id
where nsdb26.type = 'U'
order by nsdb26.name

select *
from #nsdbcols nsdb
full outer join #nsdb26cols nsdb26
	on nsdb.name = nsdb26.name
	and nsdb.colname = nsdb26.colname
where nsdb.colname is null
and nsdb26.name in (select name from #nsdbcols)


rollback tran

