
begin tran

select *
from scmanifests m
join scmanifesttemplates mt
	on m.manifesttemplateid = mt.manifesttemplateid
where datediff(d, manifestdate, getdate()) = 0
and isnull(m.deviceid,0) <> mt.deviceid

update scmanifests
set deviceid = mt.deviceid
from scmanifests m
join scmanifesttemplates mt
	on m.manifesttemplateid = mt.manifesttemplateid
where datediff(d, manifestdate, getdate()) = 0
and isnull(m.deviceid,0) <> mt.deviceid

select *
from scmanifests m
join scmanifesttemplates mt
	on m.manifesttemplateid = mt.manifesttemplateid
where datediff(d, manifestdate, getdate()) = 0
and isnull(m.deviceid,0) <> mt.deviceid

commit tran