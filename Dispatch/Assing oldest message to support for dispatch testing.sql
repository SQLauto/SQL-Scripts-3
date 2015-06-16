
declare @messageid int
declare @messagetargetid int

select @messagetargetid = messagetargetid
from demessagetarget
where syncronexusername = 'support@syncronex.com'

select @messageid = messageid
from demessage
where messagedatetime = (
	select min(messagedatetime)
	from demessage
)

print @messageid
print @messagetargetid

update demessage
set messagestatusid = 0
	, messagetargetid = @messagetargetid
where messageid = @messageid
