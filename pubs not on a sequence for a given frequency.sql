

/*

	how many ajcbd pubs are not on a sunday delivery manifest 
*/

select *
from scAccountsPubs ap
join nsPublications p
	on ap.PublicationId = p.PublicationID
join scAccountsCategories ac
	on ap.AccountId = ac.AccountID	

join (
	select msi.AccountPubId, MTCode, mt.ManifestTypeId, mst.Frequency, MTDeleted
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	where mst.Frequency & 1 > 0
	and mt.ManifestTypeId = 1	
	) as m
	on m.AccountPubId = ap.AccountPubID
	
where PubShortName = 'ajcbd'
and ac.CategoryID in (
	select CategoryID
	from dd_scAccountCategories
	where CatShortName in ('pblx','pix')	
	)