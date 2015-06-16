


begin tran

declare @beginDateThreshold datetime
set @beginDateThreshold = '7/3/2014'

select m.ManifestDate, m.MfstCode, mst.Code, dups.AccountPubId
from scManifests m
join (
	select m.ManifestId, ManifestSequenceTemplateId, AccountPubId
	from scManifestSequences ms
	join scmanifests m
		on m.ManifestID = ms.ManifestId
	where ManifestDate > @beginDateThreshold	
	group by m.ManifestId, ManifestSequenceTemplateId, AccountPubId
	having count(*) > 1 
	) as dups
	on m.ManifestId = dups.ManifestId
join scManifestSequenceTemplates mst
	on mst.ManifestSequenceTemplateId = dups.ManifestSequenceTemplateId
order by m.ManifestDate, m.MfstCode

select ms.ManifestId, ms.ManifestSequenceTemplateId, ms.AccountPubId, ms.ManifestSequenceId
into #dups
from scManifestSequences ms
join 
	(
		select m.ManifestId, ManifestSequenceTemplateId, AccountPubId
		from scManifestSequences ms
		join scmanifests m
			on m.ManifestID = ms.ManifestId
		where ManifestDate > @beginDateThreshold	
		group by m.ManifestId, ManifestSequenceTemplateId, AccountPubId
		having count(*) > 1 
	) as dups
	on ms.ManifestId = dups.ManifestId
	and	ms.ManifestSequenceTemplateId = dups.ManifestSequenceTemplateId
	and ms.AccountPubId = dups.AccountPubId
join scManifestSequences ms2
	on ms2.ManifestId = dups.ManifestId
	and	ms2.ManifestSequenceTemplateId = dups.ManifestSequenceTemplateId
	and ms2.AccountPubId = dups.AccountPubId
where ms.ManifestSequenceId > ms2.ManifestSequenceId

delete scmanifestSequences
from scManifestSequences ms
join #dups dups
	on ms.ManifestSequenceId = dups.ManifestSequenceId
print cast(@@rowcount as varchar) + ' dulicates removed'

select ManifestId, ManifestSequenceTemplateId, AccountPubId
from scManifestSequences ms
group by ManifestId, ManifestSequenceTemplateId, AccountPubId
having count(*) > 1

--|  Cleanup
drop table #dups
 
commit tran