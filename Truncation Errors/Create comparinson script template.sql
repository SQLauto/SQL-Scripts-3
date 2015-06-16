
select 'union all select ''' + [name] + ''' as [ColumnName], max(len( ' + [name] + ') ) as [' + name + '] from scManifestLoad_View'
from syscolumns
where id = OBJECT_ID('scmanifestload_view')