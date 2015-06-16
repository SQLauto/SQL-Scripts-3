


begin tran

select *
into Syncronex_Settings..Calgary_scManifestSequenceItems_01262010
from scManifestSequenceItems

select ManifestSequenceTemplateId, AccountPubId
from scManifestSequenceItems msi
group by ManifestSequenceTemplateId, AccountPubId
having count(*) > 1

select msi.ManifestSequenceItemId, msi.ManifestSequenceTemplateId, msi.AccountPubId
into #dups
from scManifestSequenceItems msi
join 
	(
		select ManifestSequenceTemplateId, AccountPubId
		from scManifestSequenceItems msi
		group by ManifestSequenceTemplateId, AccountPubId
		having count(*) > 1
	) as dups
	on msi.ManifestSequenceTemplateId = dups.ManifestSequenceTemplateId
	and msi.AccountPubId = dups.AccountPubId
join scManifestSequenceItems msi2
	on msi.AccountPubId = msi2.AccountPubId
	and msi.ManifestSequenceTemplateId = msi2.ManifestSequenceTemplateId
where msi.ManifestSequenceItemId > msi2.ManifestSequenceItemId

select mst.code, frequency, dup.*
from #dups dup
join scManifestSequenceTemplates mst
	on mst.ManifestSequenceTemplateId = dup.ManifestSequenceTemplateId
order by AccountPubId

delete scmanifestSequenceItems
from scManifestSequenceItems msi
join #dups dup
	on msi.ManifestSequenceItemId = dup.ManifestSequenceItemId
print cast(@@rowcount as varchar) + ' dulicates removed'

select ManifestSequenceTemplateId, AccountPubId
from scManifestSequenceItems msi
group by ManifestSequenceTemplateId, AccountPubId
having count(*) > 1

--| below is testing
/*
print 'starting scmanifestaccountmove'
exec scmanifestaccountmove 1, 1

select ManifestSequenceTemplateId, AccountPubId
from scManifestSequenceItems msi
group by ManifestSequenceTemplateId, AccountPubId
having count(*) > 1
*/


--|  Cleanup
drop table #dups
 
rollback tran