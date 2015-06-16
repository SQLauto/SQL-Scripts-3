begin tran

set nocount on

declare @pub nvarchar(5)
declare @invalid int

set @pub = 'SPW'

/*

	validation:  if an account is NOT split between manifests, then we can add PUB to all Manifest Sequence Templates that the
	account belongs to.
	
*/

;with cteCandidateAccounts  --|These are accounts that have the given publication assigned to them
as (

	select a.AccountID, ap.AccountPubID
	from scAccounts a
	join scAccountsPubs ap
		on a.AccountID = ap.AccountId
	join nsPublications p
		on ap.PublicationId = p.PublicationID	
	where p.PubShortName = @pub
), cteDeliveryManifests  
as (
	--|Get the Delivery Manifests that all pubs for the account are associated with
	select ap.AccountId, ap.AccountPubID, mst.ManifestSequenceTemplateId, mst.Frequency
	from cteCandidateAccounts ca
	join scAccountsPubs ap
			on ca.AccountID = ap.AccountId
	join scManifestSequenceItems msi
		on ap.AccountPubID = msi.AccountPubId
	join scManifestSequenceTemplates mst
		on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
	join scManifestTemplates mt
		on mst.ManifestTemplateId = mt.ManifestTemplateId
	where mt.ManifestTypeId = 1
)
--|validate, can't have any accounts whose publications are divided between manifests of a given type
select AccountId, ManifestSequenceTemplateId, COUNT(*)
from ( 
	select distinct AccountId, ManifestSequenceTemplateId
	from cteDeliveryManifests
	) as prelim
group by AccountId, ManifestSequenceTemplateId
having COUNT(*) > 1
set @invalid = @@ROWCOUNT
		

if @invalid = 0
begin

;with cteCandidateAccounts
as (

	select a.AccountID, ap.AccountPubID
	from scAccounts a
	join scAccountsPubs ap
		on a.AccountID = ap.AccountId
	join nsPublications p
		on ap.PublicationId = p.PublicationID	
	where p.PubShortName = @pub
),cteManifests
as (
	select distinct mt.ManifestTemplateId
	from cteCandidateAccounts ca
	join scAccountsPubs ap
			on ca.AccountID = ap.AccountId
	join nsPublications p
		on ap.PublicationId = p.PublicationID	

	join scManifestSequenceItems msi
		on ap.AccountPubID = msi.AccountPubId
	join scManifestSequenceTemplates mst
		on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
	join scManifestTemplates mt
		on mst.ManifestTemplateId = mt.ManifestTemplateId
	where mt.ManifestTypeId = 1
	and p.PubShortName = @pub
)
, cteDeliveryManifests
as (
	select ap.AccountId, ap.AccountPubID, mst.ManifestSequenceTemplateId, mst.Frequency
	from cteCandidateAccounts ca
	join scAccountsPubs ap
			on ca.AccountID = ap.AccountId
	join scManifestSequenceItems msi
		on ap.AccountPubID = msi.AccountPubId
	join scManifestSequenceTemplates mst
		on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
	join scManifestTemplates mt
		on mst.ManifestTemplateId = mt.ManifestTemplateId
	join cteManifests m
		on mt.ManifestTemplateId = m.ManifestTemplateId	
	where mt.ManifestTypeId = 1
)
select ca.AccountPubID, m.ManifestSequenceTemplateId, 0 as [Sequence]
into #itemsInserted
from cteCandidateAccounts ca
join ( 
	select distinct accountid, ManifestSequenceTemplateId
	from cteDeliveryManifests m
	) as m
	on ca.AccountID = m.AccountId
left join scManifestSequenceItems msi
	on ca.AccountPubID = msi.AccountPubId
	and m.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	
where msi.ManifestSequenceItemId is null		

--drop table support_scManifestSequenceItems_12132012
--drop table support_scManifestSequenceItems_ItemsInserted_12132012

select tmp.*
	, a.AcctCode, p.PubShortName
into support_scManifestSequenceItems_ItemsInserted_12132012
from #itemsInserted tmp
join scAccountsPubs ap
	on tmp.AccountPubID = ap.AccountPubID
join scAccounts a
	on ap.AccountId = a.AccountID
join nsPublications p	
	on ap.PublicationId = p.PublicationID	


	
select *
into support_scManifestSequenceItems_12132012
from scManifestSequenceItems	

insert into scManifestSequenceItems ( AccountPubId, ManifestSequenceTemplateId, Sequence )
select AccountPubId, ManifestSequenceTemplateId, Sequence
from #itemsInserted
print cast(@@rowcount as varchar) + ' records inserted into scManifestSequenceItems'

exec splitAcctPubs_Cleanup

end

drop table #itemsinserted

commit tran