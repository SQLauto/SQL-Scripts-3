
begin tran

update syncSystemProperties
set SysPropertyValue = '/' + db_name()
where SysPropertyName = 'PDAServerPath'

select *
from syncSystemProperties
where SysPropertyName = 'PDAServerPath'


update syncSystemProperties
set SysPropertyValue = 'rich-syncronex1'
where SysPropertyName = 'PDAServer'

select SysPropertyName, SysPropertyValue
from syncSystemProperties
where SysPropertyName in ( 'PDAServer', 'PDAServerPath' )

rollback tran