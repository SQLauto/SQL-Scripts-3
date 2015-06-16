begin tran

;with cte as (
	select p.ConfigurationPropertyId, p.PropertyDisplayName, p.PropertyDescription,   v.PropertyValue
	from syncConfigurationProperties p
	join nsdb_state..syncConfigurationPropertyValues v
		on p.ConfigurationPropertyId = v.ConfigurationPropertyId
)
update syncConfigurationPropertyValues
set PropertyValue = cte.PropertyValue
from syncConfigurationPropertyValues v
join cte 		
	on v.ConfigurationPropertyId = cte.ConfigurationPropertyId
	
	
	
select p.ConfigurationPropertyId, p.PropertyDisplayName, p.PropertyDescription,   v.PropertyValue
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
	
commit tran	