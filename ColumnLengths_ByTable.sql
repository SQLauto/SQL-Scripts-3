select name, length
from syscolumns
where id = OBJECT_ID('scManifests')
--order by [name]
union all
select name, length
from syscolumns
where id = OBJECT_ID('scAccounts')
union all
select name, length
from syscolumns
where id = OBJECT_ID('dd_scAccounttypes')
order by 1	

