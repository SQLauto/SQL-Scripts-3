use sdmconfig
set nocount on

select description, attributevalue
from merc_controlpanel
where attributename = 'SystemLock'

update merc_controlpanel
set description = 0, attributevalue = 'False'
where attributename = 'SystemLock'

select description, attributevalue
from merc_controlpanel
where attributename = 'SystemLock'

