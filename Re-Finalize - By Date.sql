
begin tran


declare @date datetime
set @date = '6/10/2010'--|  convert(nvarchar, getdate(), 101)

select manifestdate, count(*) as [ManifestCount]
from scmanifests
where datediff(d, manifestdate, @date) = 0
group by manifestdate


delete scmanifestsequences
from scmanifestsequences ms
join scmanifests m
	on m.manifestid = ms.manifestid
where datediff(d, manifestdate, @date) = 0

delete scmanifesthistory 
from scmanifesthistory mh
join scmanifests m
	on m.manifestid = mh.manifestid
where datediff(d, manifestdate, @date) = 0


delete scmanifesttransferdrops
from scmanifesttransferdrops mtd
join scmanifesttransfers mt
	on mtd.manifesttransferid = mt.manifesttransferid
join scmanifests m
	on m.manifestid = mt.manifestid
where datediff(d, manifestdate, @date) = 0



delete scmanifesttransfers
from scmanifesttransfers mt
join scmanifests m
	on m.manifestid = mt.manifestid
where datediff(d, manifestdate, @date) = 0


delete from scmanifests
where datediff(d, manifestdate, @date) = 0

select manifestdate, count(*) as [ManifestCount]
from scmanifests
where datediff(d, manifestdate, @date) = 0
group by manifestdate

exec scManifestSequence_Finalizer @date

select manifestdate, count(*) as [ManifestCount]
from scmanifests
where datediff(d, manifestdate, @date) = 0
group by manifestdate

commit tran