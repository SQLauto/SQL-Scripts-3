begin tran
use sdmconfig

declare @SessionTimeout int
set @SessionTimeout = 1800  --|minutes 

if not exists
	(
	select *
	from sdmconfig..merc_controlpanel
	where attributename = 'SessionTimeout'
	)
begin
	insert merc_controlpanel (AppLayer, AttributeName, Description, AttributeValue, LastUpdated, IsActive)
	Select 'COM', 'SessionTimeout', 'Session Timeout', @SessionTimeout, Current_Timestamp, 1
end
else
begin
	update merc_controlpanel
	set AttributeValue = @SessionTimeout
	where AttributeName = 'SessionTimeout'
end

select *
from sdmconfig..merc_controlpanel
where attributename = 'SessionTimeout'

commit tran