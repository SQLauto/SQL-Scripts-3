
declare @objectName	varchar(128)
declare @id int

set @objectName = 'scManifestHistory'

Select @id = object_id(@objectName)

dbcc dbreindex(@objectName)
exec sp_recompile @objectname