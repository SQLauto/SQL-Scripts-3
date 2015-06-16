begin tran

declare @SQLServerName varchar(50)
declare @NewSQLServerName varchar(50)
set @NewSQLServerName = '(local)'

select @SQLServerName = right(
	left( connectionstring, charindex( ';', connectionstring, charindex('Data Source', connectionstring, 0) ) - 1 )
	, len( left( connectionstring, charindex( ';', connectionstring, charindex('Data Source', connectionstring, 0) ) - 1 ) )
	- ( charindex( 'Data Source=', connectionstring, 0)
	+ len( 'Data Source=' ) - 1 )
	)
from sdmconfig..merc_datasource
where datasourceid = 1

select connectionstring as [Old Merc_Datasource ConnectionString]
from sdmconfig..merc_datasource

update sdmconfig..merc_datasource
set connectionstring = replace(connectionstring, @SQLServerName, @NewSQLServerName)

select connectionstring as [Old Merc_Datasource ConnectionString]
from sdmconfig..merc_datasource

commit tran