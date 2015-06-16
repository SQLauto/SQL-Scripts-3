insert into nsPublications ( SDM_PubID, SDM_PubAbbreviation, SDM_PubName, SDM_ExtensionAttribute1 )
select distinct 1, publicationabbrev, publicationabbrev, publicationcode
from SDMData_CCT..message
order by publicationabbrev