
set identity_insert deMessageTarget on

insert into SDMData..deMessageTarget ( MessageTargetId, SyncronexUserName, MessageTargetDisplayName)
select MessageTargetId, EmailAddress, Name
from SDMData_CCT..MessageTarget
order by MessageTargetId

set identity_insert deMessageTarget off