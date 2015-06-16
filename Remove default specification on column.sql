--|  Drop the default specification on RollupAcctId
declare @default_colname nvarchar(256)
select @default_colname = object_name(cdefault)
from syscolumns
where [id] = object_id('scDraws')
and [name] = 'RollupAcctId'

declare @sql nvarchar(2000)
set @sql = 'alter table scDraws drop constraint ' + @default_colname 
exec (@sql)

--|  Set RollupAcctId = null where RollupAcctId = 0
update scDraws
set RollupAcctId = null
where RollupAcctId = 0


