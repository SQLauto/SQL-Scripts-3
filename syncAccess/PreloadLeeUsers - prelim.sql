

select *
from seplans
where Code = 'COMP'


select P.PropertyDisplayName, p.PropertyDescription, v.PropertyValue
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
	where p.PropertyDisplayName = 'API Base Url'


