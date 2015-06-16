

;with cteDB1
as
(
	select db_obj.name as [obj_name], db_col.name as [col_name]
	from nsdb_3_1_4..sysobjects db_obj
	join nsdb_3_1_4..syscolumns db_col
		on db_col.id = db_obj.id
	where db_obj.type = 'U'
)
, cteDB2
as (
	select db_obj.name as [obj_name], db_col.name as [col_name]
	from nsdb_3_5_0..sysobjects db_obj
	join nsdb_3_5_0..syscolumns db_col
		on db_col.id = db_obj.id
	where db_obj.type = 'U'
)

select *
from cteDB1 db1
full outer join cteDB2 db2
	on db1.[col_name] = db2.[col_name]
	and db1.[obj_name] = db2.[obj_name]
where db1.[col_name] is null	
or db2.[col_name] is null	
order by db2.[obj_name], db1.[obj_name]