/*
DIFFERENCES REPORT

To use this script SEARCH/REPLACE db_new and db_old
	db_new should be a database that is the same version to which you will be upgrading 
	db_old should be the existing database which will be upgraded

*/
begin tran

set nocount on

select name as [New Tables]
from db_new..sysobjects
where type = 'U'
and name not in (
	select name
	from db_old..sysobjects db_old
	where type = 'U'
	)
order by name

rollback tran

/*
*/
