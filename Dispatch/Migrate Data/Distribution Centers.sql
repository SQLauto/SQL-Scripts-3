

insert into SDMData.dbo.deDistributionCenter( SDM_Company, SDM_DistributionCenter, SDM_DistributionCenterDisplayName
	, SDM_ExtensionAttribute1, SDM_IsActive )
select 1, replace(Name, 'Contra Costa Times', 'CCT'), Name, DistributionCenterId, 1
from sdmdata_cct..distributioncenter
order by DistributionCenterId



