/*

compare data in the tables

*/

/*
	find the tables that are common
*/
begin tran

set nocount on

declare @table nvarchar(255)
set @table = 'DSIMessageLoad'

select db1.name, db1col.name as [colname]
into #db1
from SDMData..sysobjects db1
join SDMData..syscolumns db1col
	on db1col.id = db1.id
where db1.type = 'U'
and (
	( @table is null and db1.id > 0 )
	or db1.name = @table
	)
order by db1.name

select db2.name, db2col.name as [colname]
into #db2
from SDMData_CCT..sysobjects db2
join SDMData_CCT..syscolumns db2col
	on db2col.id = db2.id
where db2.type = 'U'
and (
	( @table is null and db2.id > 0 )
	or db2.name = @table
	)
order by db2.name

select db1.name, db1.colname, db2.colname
from #db1 db1
full outer join #db2 db2
	on db1.name = db2.name
	and db1.colname = db2.colname

rollback tran


