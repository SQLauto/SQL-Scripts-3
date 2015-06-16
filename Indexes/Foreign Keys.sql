
SELECT o.name, k.name, i.name 
	, tmp.*
FROM sys.foreign_keys k
left join sys.sysindexes i
	on k.referenced_object_id = i.id
	and k.key_index_id = i.indid
join sysobjects o
	on k.parent_object_id = o.id	
join #indexes tmp
	on i.name = tmp.IndexName	
WHERE [parent_object_id] = OBJECT_ID( N'scDraws' )
