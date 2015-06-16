
select t1.AccountId
, [csv] = 
stuff((
select ',' + p.PubShortName as [text()]
from scAccountsPubs csv
join nspublications p
on csv.PublicationId = p.PublicationID
where csv.AccountId = t1.AccountId
order by p.PubShortName
for xml path('')

), 1, 1, '')

from scAccounts t1