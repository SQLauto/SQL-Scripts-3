/*
	Use this script to troubleshoot BCP issues 

	The destination table is assumed to have all columns defined as character columns.

	1) create a staging table that can hold data from file
	2) import data into staging table
	1) create temp table to hold column names
	2) fill table with column names and length of data
	
	4) fill table with max lenghth of data in staging table

*/
begin tran

set nocount on

declare @tablename varchar(256)
declare @colname nvarchar(256)
declare @sql varchar(4096)
declare @createStagingTable bit

--| @tablename is the name of the destination table
set @tablename = 'scManifestLoad_R1'

set @createStagingTable = 0	--|  (0|1)  0 = Don't create table, 1 = Create table

--|  Temp table to hold column information for the destination table
create table #destTableInfo (
	  [name] varchar(256)
	, length int
)

--|  Fill temp table with column length info for the destination table
set @sql = 'insert into #destTableInfo ( 
	[name], length
	)
	select col.[name], col.length
	from syscolumns col
	where id = object_id(''' + @tablename + ''')
	/*and ( xprec = 0 and xscale = 0 )*/
	'
exec(@sql)

if @createStagingTable = 1	
	goto CreateStagingTable

Main:


--|  Temp table to hold the max length of data in the staging table for each column
create table #sourceDataInfo ( 
	  [name] 	varchar(256)
	, maxdatalength int
)

--|  Fill temp table
declare col_cursor cursor
for
	select [name] 
	from #destTableInfo 

open col_cursor
fetch next from col_cursor into @colname
while @@fetch_status = 0
begin
	set @sql = 'insert into #sourceDataInfo 
		select ''' + @colname + ''',  max( len( ' + @colname + ') ) as [' + @colname + ']
		from ' + @tablename + '_stage 
		'
	exec(@sql)

	fetch next from col_cursor into @colname
end

close col_cursor
deallocate col_cursor

select t1.[name] as [colname], t1.length, t2.MaxDataLength
	, case  
		when t2.MaxDataLength > t1.length then 'Data in staging table exceeds maximum length allowed'
		else 'Ok'
		end as [Source Data]
from #destTableInfo t1
left join #sourceDataInfo t2
	on t1.[name] = t2.[name]
--where t2.MaxDataLength > t1.length

goto cleanup
return

CreateStagingTable:

set @sql = 'if exists ( select 1 from sysobjects where id = object_id(''' + @tablename + '_stage'') 
	begin drop table ' + @tablename + '_stage end
	create table ' + @tablename + '_stage ( temp_column int )'

declare col_cursor cursor
for
	select [name] 
	from #destTableInfo 

open col_cursor
fetch next from col_cursor into @colname
while @@fetch_status = 0
begin
	set @sql = 'alter table ' + @tablename + '_stage add ' + @colname + ' varchar(8000)'
	exec(@sql)
	fetch next from col_cursor into @colname
end

close col_cursor
deallocate col_cursor

set @sql = 'alter table ' + @tablename + '_stage drop column temp_column
	select * from ' + @tablename + '_stage'
exec(@sql)

GOTO Main
return

Cleanup:

drop table #destTableInfo
drop table #sourceDataInfo

commit tran

return
