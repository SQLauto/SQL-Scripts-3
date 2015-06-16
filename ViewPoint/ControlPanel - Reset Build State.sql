use sdmconfig
set nocount on

select attributevalue  as [Old Build State]
from merc_controlpanel
where attributename = 'BuildState'

update merc_controlpanel
set attributevalue = 0
where attributename = 'BuildState'

select attributevalue  as [New Build State]
from merc_controlpanel
where attributename = 'BuildState'
