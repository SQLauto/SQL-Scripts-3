begin tran

select mt.ManifestTemplateId, mst.ManifestSequenceTemplateId, ap.AccountId, msi.Sequence
into #prelim
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
join scManifestSequenceItems msi
	on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubId
group by mt.ManifestTemplateId, mst.ManifestSequenceTemplateId, ap.AccountId, msi.Sequence

select mt.ManifestTemplateId, mst.ManifestSequenceTemplateId, ap.AccountId, min(msi.Sequence) as [Sequence]
into #minSequence
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
join scManifestSequenceItems msi
	on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubId
join (
	select ManifestTemplateId, ManifestSequenceTemplateId, AccountId 
	from #prelim
	group by ManifestTemplateId, ManifestSequenceTemplateId, AccountId 
	having count(*) > 1
	) as split
on mt.ManifestTemplateId = split.ManifestTemplateId
and mst.ManifestSequenceTemplateId = split.ManifestSequenceTemplateId
and ap.AccountId = split.AccountId
group by mt.ManifestTemplateId, mst.ManifestSequenceTemplateId, ap.AccountId

--|  Preview
print 'Preview'
select mt.ManifestTemplateId, mt.MTCode, mst.ManifestSequenceTemplateId, mst.Code, ap.AccountId, ap.AccountPubid, a.AcctCode, p.PubShortName, msi.Sequence
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
join scManifestSequenceItems msi
	on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubId
join scAccounts a
	on a.AccountId = ap.AccountId
join nsPublications p
	on ap.PublicationId = p.PublicationId
join (
	select ManifestTemplateId, ManifestSequenceTemplateId, AccountId 
	from #prelim
	group by ManifestTemplateId, ManifestSequenceTemplateId, AccountId 
	having count(*) > 1
	) as split
on mt.ManifestTemplateId = split.ManifestTemplateId
and mst.ManifestSequenceTemplateId = split.ManifestSequenceTemplateId
and ap.AccountId = split.AccountId
group by mt.ManifestTemplateId, mt.MTCode, mst.ManifestSequenceTemplateId, mst.Code, ap.AccountId, ap.AccountPubid, a.AcctCode, p.PubShortName, msi.Sequence

update scManifestSequenceItems
set Sequence = tmp.Sequence
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
join scManifestSequenceItems msi
	on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubId
join 
	#minSequence tmp
on mt.ManifestTemplateId = tmp.ManifestTemplateId
and mst.ManifestSequenceTemplateId = tmp.ManifestSequenceTemplateId
and ap.AccountId = tmp.AccountId
where msi.Sequence <> tmp.Sequence

--|Review
print 'Review'
select mt.ManifestTemplateId, mt.MTCode, mst.ManifestSequenceTemplateId, mst.Code, ap.AccountId, ap.AccountPubid, a.AcctCode, p.PubShortName, msi.Sequence
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
join scManifestSequenceItems msi
	on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubId
join scAccounts a
	on a.AccountId = ap.AccountId
join nsPublications p
	on ap.PublicationId = p.PublicationId
join (
	select ManifestTemplateId, ManifestSequenceTemplateId, AccountId 
	from #prelim
	group by ManifestTemplateId, ManifestSequenceTemplateId, AccountId 
	having count(*) > 1
	) as split
on mt.ManifestTemplateId = split.ManifestTemplateId
and mst.ManifestSequenceTemplateId = split.ManifestSequenceTemplateId
and ap.AccountId = split.AccountId
group by mt.ManifestTemplateId, mt.MTCode, mst.ManifestSequenceTemplateId, mst.Code, ap.AccountId, ap.AccountPubid, a.AcctCode, p.PubShortName, msi.Sequence

drop table #prelim
drop table #minSequence

commit tran