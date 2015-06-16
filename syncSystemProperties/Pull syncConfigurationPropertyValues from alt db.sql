
begin tran

select p.PropertyDisplayName, p.PropertyDescription, v.PropertyValue, tv.PropertyValue
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId =v.ConfigurationPropertyId
join nsdb_tam..syncConfigurationPropertyValues tv
	on p.ConfigurationPropertyId = tv.ConfigurationPropertyId

update syncConfigurationPropertyValues
	set PropertyValue = tv.PropertyValue
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId =v.ConfigurationPropertyId
join nsdb_tam..syncConfigurationPropertyValues tv
	on p.ConfigurationPropertyId = tv.ConfigurationPropertyId
	
select p.PropertyDisplayName, p.PropertyDescription, v.PropertyValue, tv.PropertyValue
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId =v.ConfigurationPropertyId
join nsdb_tam..syncConfigurationPropertyValues tv
	on p.ConfigurationPropertyId = tv.ConfigurationPropertyId

	
commit tran

begin tran

select p.PropertyDisplayName, p.PropertyDescription, v.PropertyValue
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId =v.ConfigurationPropertyId
where v.PropertyValue like '%tam%'

update syncConfigurationPropertyValues
set PropertyValue = REPLACE(propertyvalue, 'Tamp', 'Greensboro')

update syncConfigurationPropertyValues
set PropertyValue = REPLACE(propertyvalue, '_tam', '_gre')

select p.PropertyDisplayName, p.PropertyDescription, v.PropertyValue
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId =v.ConfigurationPropertyId
where v.PropertyValue like '%tam%'
or v.PropertyValue like '%gre%'


commit tran