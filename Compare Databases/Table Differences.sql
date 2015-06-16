/*
DIFFERENCES BETWEEN EXISTING TABLES
*/
begin tran

set nocount on

select db1.name, db1_col.name as [colname]
into #db1_cols
from db1..sysobjects db1
join db1..syscolumns db1_col
	on db1_col.id = db1.id
where db1.type = 'U'
order by db1.name

select db2.name, db2_col.name as [colname]
into #db2_cols
from db2..sysobjects db2
join db2..syscolumns db2_col
	on db2_col.id = db2.id
where db2.type = 'U'
order by db2.name

/*
list of tables that are different
*/
select distinct db2.name as [Tables that differ]
from #db1_cols db1
full outer join #db2_cols db2
	on db1.name = db2.name
	and db1.colname = db2.colname
where db1.colname is null
and db2.name in (select name from #db1_cols)

select db2.name as [Table], db2.colname as [New Column Name]
from #db1_cols db1
full outer join #db2_cols db2
	on db1.name = db2.name
	and db1.colname = db2.colname
where db1.colname is null
and db2.name in (select name from #db1_cols)


rollback tran

/*

drop table #db1_cols

*/
