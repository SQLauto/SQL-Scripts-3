begin tran

select p.ConfigurationPropertyId
	, p.PropertyName
	--, p.*
	, v.PropertyValue
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where p.PropertyName = 'ReportServer'

update syncConfigurationPropertyValues
set PropertyValue = 'http://localhost:80/ReportServer'
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where p.PropertyName = 'ReportServer'

commit tran