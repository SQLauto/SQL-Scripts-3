begin tran

/*
	Removes Duplicate Manifest Sequence Items (Templates) 
	created by scManifestAccountMove
*/

--|Preview
select mt.ManifestTemplateId, mt.MTCode, mst.ManifestSequenceTemplateId, mst.Code, dups.AccountPubId, a.AccountId, a.AcctCode
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
join (
		select ManifestSequenceTemplateId, AccountPubId
		from scManifestSequenceItems msi
		group by ManifestSequenceTemplateId, AccountPubId
		having count(*) > 1
	) as dups
	on mst.ManifestSequenceTemplateId = dups.ManifestSequenceTemplateId
join scAccountsPubs ap
	on ap.AccountPubId = dups.AccountPubId
join scAccounts a
	on ap.AccountId = a.AccountId
order by mt.MTCode

select msi.ManifestSequenceTemplateId, msi.AccountPubId, msi.ManifestSequenceItemId
into #dups
from scManifestSequenceItems msi
join 
	(
		select ManifestSequenceTemplateId, AccountPubId
		from scManifestSequenceItems msi
		group by ManifestSequenceTemplateId, AccountPubId
		having count(*) > 1
	) as dups
	on	msi.ManifestSequenceTemplateId = dups.ManifestSequenceTemplateId
	and msi.AccountPubId = dups.AccountPubId
join scManifestSequenceItems msi2
	on	msi2.ManifestSequenceTemplateId = dups.ManifestSequenceTemplateId
	and msi2.AccountPubId = dups.AccountPubId
where msi.ManifestSequenceItemId > msi2.ManifestSequenceItemId

delete scManifestSequenceItems
from scManifestSequenceItems ms
join #dups dups
	on ms.ManifestSequenceItemId = dups.ManifestSequenceItemId
print cast(@@rowcount as varchar) + ' dulicates removed'

--|  Review (should be empty since all dups have been resolved)
select mt.ManifestTemplateId, mt.MTCode, mst.ManifestSequenceTemplateId, mst.Code, dups.AccountPubId, a.AcctCode
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
join (
		select ManifestSequenceTemplateId, AccountPubId
		from scManifestSequenceItems msi
		group by ManifestSequenceTemplateId, AccountPubId
		having count(*) > 1
	) as dups
	on mst.ManifestSequenceTemplateId = dups.ManifestSequenceTemplateId
join scAccountsPubs ap
	on ap.AccountPubId = dups.AccountPubId
join scAccounts a
	on ap.AccountId = a.AccountId
order by mt.MTCode


--|  Cleanup
drop table #dups
 
commit tran