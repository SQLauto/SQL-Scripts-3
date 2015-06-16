

begin tran

select *
from demessage
where messagestatusid not in (5, 6)
and datediff(d, messagedatetime, '2/1/05') = 0

update demessage
set messagestatusid = 5
	,extensionattribute5 = 'Manually "completed" 2/2/2005 by KK'
where datediff(d, messagedatetime, '2/1/05') = 0
and messagestatusid not in (5,6)

select *
from demessage
where extensionattribute5 = 'Manually "completed" 2/2/2005 by KK'
and datediff(d, messagedatetime, '2/1/05') = 0

commit tran