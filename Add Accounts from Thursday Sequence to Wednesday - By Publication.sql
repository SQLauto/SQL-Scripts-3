begin tran

;with cteThur 
as (
	select ap.AccountPubID, mst.Frequency, mt.ManifestTypeId, mt.ManifestTemplateId, mt.MTCode, DBO.frequency_to_dayList(mst.Frequency) as [DayList]
	from nsPublications p
	join scAccountsPubs ap
		on p.PublicationID = ap.PublicationId
	join scManifestSequenceItems msi
		on ap.AccountPubId = msi.AccountPubId
	join scManifestSequenceTemplates mst
		on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
	join scManifestTemplates mt
		on mst.ManifestTemplateId = mt.ManifestTemplateId
	where ap.Active > 0
	and mst.Frequency & 16 > 0	
	and p.PubShortName = 'MH'
)
, cteWed as (
	select ap.AccountPubID, mst.Frequency, mt.ManifestTypeId, mt.ManifestTemplateId, mt.MTCode, DBO.frequency_to_dayList(mst.Frequency) as [DayList]
	from nsPublications p
	join scAccountsPubs ap
		on p.PublicationID = ap.PublicationId
	join scManifestSequenceItems msi
		on ap.AccountPubId = msi.AccountPubId
	join scManifestSequenceTemplates mst
		on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
	join scManifestTemplates mt
		on mst.ManifestTemplateId = mt.ManifestTemplateId
	where ap.Active > 0
	and mst.Frequency & 8 > 0	
	and p.PubShortName = 'MH'
	)
, cteManifestTemplates
as (
	select mt.ManifestTemplateId, mst.ManifestSequenceTemplateId
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	where mst.Frequency & 8 > 0	
)
insert into scManifestSequenceItems ( AccountPubId, ManifestSequenceTemplateId, Sequence )	
select t.AccountPubID
	--, t.ManifestTemplateId
	--, w.ManifestTemplateId
	, m.ManifestSequenceTemplateId as [TargetSequence]
	, 0
from cteThur t
left join cteWed w
	on t.AccountPubID = w.AccountPubID
	and t.ManifestTypeId = w.ManifestTypeId
left join cteManifestTemplates m
	on t.ManifestTemplateId = m.ManifestTemplateId
where w.MTCode is null
and m.ManifestSequenceTemplateId is not null

exec splitAcctPubs_Cleanup

/*
--| get the existing Drop Sequence for the accountpub on the target sequence
select ap.AccountId, ap.AccountPubID, tmp.TargetSequence
	, msi.Sequence
from #acctsToAdd tmp
join scAccountsPubs ap
	on tmp.AccountPubID = ap.AccountPubID
join scManifestSequenceTemplates mst
	on tmp.TargetSequence = mst.ManifestSequenceTemplateId
left join scManifestSequenceItems msi
	on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	and ap.AccountPubID = msi.AccountPubId	
order by AccountId
*/
rollback tran