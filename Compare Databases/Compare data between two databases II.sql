

/*
Compare data between two tables
*/

begin tran

declare @db1 nvarchar(25)
declare @db2 nvarchar(25)
declare @table nvarchar(50)
declare @sql varchar(4096)

set @db1 = 'nsdb'
set @db2 = 'nsdb27_07'
set @table = 'dd_scforecastruletypes'
	
	set @sql  = ' select * from ' + @db1 + '..' + @table 
	exec(@sql)

	set @sql  = ' select * from ' + @db2 + '..' + @table 
	exec(@sql)


rollback tran