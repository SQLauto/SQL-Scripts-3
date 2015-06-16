
CREATE PROCEDURE sp_spaceUsedByTable
	@orderby	 varchar(50)='reserved_MB desc'
AS

/*
NOTE: you may need to run (takes a long time) DBCC UPDATEUSAGE('database') 
You can also specify an @orderby
Example: sp_spaceUsedByTable @orderby='rows desc'
bytable
Louis Nguyen
*/

set nocount on
set ansi_warnings off
set transaction isolation level read uncommitted

create table #S
(
[name] varchar(50) null,
[rows] varchar(50) null,
[reserved] varchar(50) null,
[data] varchar(50) null,
[index_size] varchar(50) null,
[unused] varchar(50) null
)

-- Create a cursor to loop through the user tables
declare @name varchar(50)
declare c_tables cursor for
select	name from sysobjects where xtype = 'U'

open c_tables
fetch next from c_tables
into @name

while @@fetch_status = 0 begin
insert into #S
exec sp_spaceUsed @name
fetch next from c_tables	into @name
end

close c_tables deallocate c_tables

select [name],[rows],reserved_MB,data_MB,[index_MB],unused_MB
into #T
from(
select [name]
,[rows]=cast([rows] as int)
,reserved_MB=cast(replace(reserved,'KB','') as int)/1000
,data_MB=cast(replace(data,'KB','') as int)/1000
,[index_MB]=cast(replace(index_size,'KB','') as int)/1000
,unused_MB=cast(replace(unused,'KB','') as int)/1000
from #S 
) as XX
order by reserved_MB desc 

exec ('select * from #T order by '+@orderby)

drop table #S
drop table #T
GO

exec sp_spaceUsedByTable
GO