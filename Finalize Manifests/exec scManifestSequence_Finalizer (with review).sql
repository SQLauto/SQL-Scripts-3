

begin tran

select *
into #manifests
from scmanifests
where ManifestDate = '8/6/2012'

select mfstcode
from #manifests
group by MfstCode
having COUNT(*) > 1

exec scManifestSequence_Finalizer '8/6/2012'

select *
from scManifests m
where m.MfstCode in (
	select mfstcode
	from scmanifests
	where ManifestDate = '8/6/2012'
	group by MfstCode
	having COUNT(*) > 1
	) 
and m.manifestdate = '8/6/2012'
order by mfstcode

rollback tran