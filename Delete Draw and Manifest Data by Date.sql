begin tran
--|clear out draw and manifest date

declare @date datetime
set @date = '12/26/2009'

delete scdrawhistory
from scdrawhistory dh
join scdraws d
	on dh.drawid = d.drawid
where datediff(d, d.drawdate, @date) = 0

delete 
from scdraws
where datediff(d, drawdate, @date) = 0

delete scmanifestsequences 
from scmanifestsequences ms
join scmanifests m
	on ms.manifestid = m.manifestid
where datediff(d, m.manifestdate, @date) = 0

delete 
from scmanifests
where datediff(d, manifestdate, @date) = 0

commit tran

--exec scmanifestsequence_finalizer '12/10/2009'