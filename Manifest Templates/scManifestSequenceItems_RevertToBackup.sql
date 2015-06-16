begin tran

select pubshortname, COUNT(*)
from scManifestSequenceItems msi
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubID
join nsPublications p
	on ap.PublicationId = p.PublicationID	
where PubShortName = 'spw'	
group by PubShortName
order by PubShortName


select COUNT(*)
from scManifestSequenceItems msi
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubID
join nsPublications p
	on ap.PublicationId = p.PublicationID	
--group by PubShortName	
--order by PubShortName


delete scManifestSequenceItems 
from scManifestSequenceItems msi
left join support_scManifestSequenceItems_12132012 tmp
	on tmp.ManifestSequenceItemId = msi.ManifestSequenceItemId
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubID
join nsPublications p
	on ap.PublicationId = p.PublicationID	
where tmp.ManifestSequenceItemId is null

select COUNT(*)
from scManifestSequenceItems msi
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubID
join nsPublications p
	on ap.PublicationId = p.PublicationID	
--group by PubShortName
--order by PubShortName

select pubshortname, COUNT(*)
from scManifestSequenceItems msi
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubID
join nsPublications p
	on ap.PublicationId = p.PublicationID	
where PubShortName = 'spw'	
group by PubShortName
order by PubShortName


commit tran