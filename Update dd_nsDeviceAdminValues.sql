begin tran

select DeviceTypeName, DeviceAdminPropertyName, DeviceAdminValue
from dd_nsDeviceAdminValues v
join dd_nsDeviceAdminProperties p
	on v.DeviceAdminPropertyId = p.DeviceAdminPropertyId
join dd_nsDeviceTypes t
	on v.DeviceTypeId = t.DeviceTypeID
order by 1

update dd_nsDeviceAdminValues 
set DeviceAdminValue = 'true'
from dd_nsDeviceAdminValues v
join dd_nsDeviceAdminProperties p
	on v.DeviceAdminPropertyId = p.DeviceAdminPropertyId
join dd_nsDeviceTypes t
	on v.DeviceTypeId = t.DeviceTypeID
where DeviceAdminPropertyName = 'IncludeUserSecurity'

select DeviceTypeName, DeviceAdminPropertyName, DeviceAdminValue
from dd_nsDeviceAdminValues v
join dd_nsDeviceAdminProperties p
	on v.DeviceAdminPropertyId = p.DeviceAdminPropertyId
join dd_nsDeviceTypes t
	on v.DeviceTypeId = t.DeviceTypeID
order by 1

commit tran