begin tran

select *
from scmanifesttemplates
where deviceid not in (
	select deviceid
	from nsdevices
)
	
update scmanifesttemplates
set deviceid = null
where deviceid not in (
	select deviceid
	from nsdevices
)
	

select *
from scmanifesttemplates
where deviceid not in (
	select deviceid
	from nsdevices
)

commit tran