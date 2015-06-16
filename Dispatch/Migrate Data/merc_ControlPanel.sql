begin tran

select sjm.AttributeName, sjm.AttributeValue as [Current Value], cct.AttributeValue as [CCT Value]
into #controlPanel
from sdmconfig_cct..merc_controlpanel cct
join sdmconfig..merc_controlpanel sjm
	on cct.attributename = sjm.attributename
where sjm.AttributeValue <> cct.AttributeValue 

update sdmconfig..merc_controlpanel
set AttributeValue = [CCT Value]
from sdmconfig..merc_controlpanel cp
join #controlPanel tmp
	on cp.AttributeName = tmp.AttributeName

select cp.AttributeName, cp.AttributeValue, tmp.[Current Value] as [Old Value]
from sdmconfig..merc_controlpanel cp
join #controlPanel tmp
	on cp.AttributeName = tmp.AttributeName

drop table #controlPanel

commit tran