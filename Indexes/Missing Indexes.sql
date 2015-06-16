select db_name(d.database_id) dbname, object_name(d.object_id) tablename, d.index_handle,
d.equality_columns, d.inequality_columns, d.included_columns, d.statement as fully_qualified_object, gs.*
from  sys.dm_db_missing_index_groups g
       join sys.dm_db_missing_index_group_stats gs on gs.group_handle = g.index_group_handle
       join sys.dm_db_missing_index_details d on g.index_handle = d.index_handle
where  d.database_id =  d.database_id and d.object_id =  d.object_id 
   and object_name(d.object_id) = 'scDrawHistory'