begin tran

/*
	Delete true duplicates (AccountPubs on the same ManifestSequenceTemplate)
*/

--select *
--into supportBackup_scManifestSequenceItems_06142011
--from scManifestSequenceItems

select MTCode, mst.Code, mst.Frequency
	, a.AcctCode, p.PubShortName
	, COUNT(*)

from scmanifestSequenceItems msi
join (
	select AccountPubId, ManifestSequenceTemplateId
	from scManifestSequenceItems 
	group by AccountPubId, ManifestSequenceTemplateId
	having count(*) > 1
	) as [dups]
	on msi.AccountPubId = dups.AccountPubId
	and msi.ManifestSequenceTemplateId = dups.ManifestSequenceTemplateId
join scManifestSequenceTemplates mst
	on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
join scManifestTemplates mt
	on mst.ManifestTemplateId = mt.ManifestTemplateId	
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubID
join scAccounts a
	on ap.AccountId = a.AccountID
join nsPublications p
	on ap.PublicationId = p.PublicationID			
group by MTCode, mst.Code, mst.Frequency
	, a.AcctCode, p.PubShortName	
order by MTCode, mst.Frequency
			
--select msi1.ManifestSequenceItemId, msi1.AccountPubId
delete scmanifestSequenceItems
from scmanifestSequenceItems msi1
join (
	select msi.*
	from scmanifestSequenceItems msi
	join (
		select AccountPubId, ManifestSequenceTemplateId
		from scManifestSequenceItems 
		group by AccountPubId, ManifestSequenceTemplateId
		having count(*) > 1
		) as [dups]
		on msi.AccountPubId = dups.AccountPubId
		and msi.ManifestSequenceTemplateId = dups.ManifestSequenceTemplateId
	) as msi2
	on msi1.AccountPubId = msi2.AccountPubId
	and msi1.ManifestSequenceTemplateId = msi2.ManifestSequenceTemplateId
where msi1.ManifestSequenceItemId > msi2.ManifestSequenceItemId
--order by 2

select msi.*
from scmanifestSequenceItems msi
join (
	select AccountPubId, ManifestSequenceTemplateId
	from scManifestSequenceItems 
	group by AccountPubId, ManifestSequenceTemplateId
	having count(*) > 1
	) as [dups]
	on msi.AccountPubId = dups.AccountPubId
	and msi.ManifestSequenceTemplateId = dups.ManifestSequenceTemplateId
order by msi.AccountPubId


commit tran