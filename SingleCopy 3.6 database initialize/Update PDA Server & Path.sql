begin tran

select p.ConfigurationPropertyId
	, p.PropertyName
	--, p.*
	, v.PropertyValue
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where p.PropertyName in ( 'PDAServer', 'PDASErverPath' )

update syncConfigurationPropertyValues
set PropertyValue = 'mclatchy.syncronex.com'
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where p.PropertyName = 'PDAServer'

update syncConfigurationPropertyValues
set PropertyValue = '/' + db_name()
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where p.PropertyName = 'PDASErverPath'

select p.ConfigurationPropertyId
	, p.PropertyName
	--, p.*
	, v.PropertyValue
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where p.PropertyName in ( 'PDAServer', 'PDASErverPath' )

commit tran
	