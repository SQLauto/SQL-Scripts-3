begin tran

/*

	validation:  if an account is NOT split between manifests, then we can add PUB to all Manifest Sequence Templates that the
	account belongs to.
	
*/

exec support_account '60008517'

;with cteCandidateAccounts  --|These are accounts that have the given publication assigned to them
as (

	select ap.AccountId, ap.AccountPubID
		, a.AcctCode
	from scAccounts a
	join scAccountsPubs ap
		on a.AccountID = ap.AccountId
	join nsPublications p
		on ap.PublicationId = p.PublicationID	
	where p.PubShortName in (
		--'HCSE'
		select PubShortName
		from nsPublications 
	)
)
, cteDeliveryManifests  
as (
	--|Get the Delivery Manifests that all pubs for the account are associated with
	select distinct ca.AccountId, ca.AccountPubID, mt.ManifestTemplateId
		--, mst.ManifestSequenceTemplateId
		, ca.AcctCode, MTCode
		--, mst.Code, mst.Frequency
	from cteCandidateAccounts ca
	join scManifestSequenceItems msi
		on ca.AccountPubID = msi.AccountPubId
	join scManifestSequenceTemplates mst
		on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
	join scManifestTemplates mt
		on mst.ManifestTemplateId = mt.ManifestTemplateId
	where mt.ManifestTypeId = 1
)
select cte.*
into #acctsmfsts
from cteDeliveryManifests cte
join (
		select accountpubid
		from cteDeliveryManifests
		group by accountpubid
		having COUNT(*) = 1
	) prelim
	on cte.AccountPubID = prelim.AccountPubID

--select *
--from #acctsmfsts
--order by AccountId

;with cteManifestSequenceTemplates
as (
	select mst.*
	from scManifestSequenceTemplates mst
	join (
		select distinct ManifestTemplateId
		from #acctsmfsts
	) tmp
		on mst.ManifestTemplateId = tmp.ManifestTemplateId	
)
select tmp.AccountPubID, mst.ManifestSequenceTemplateId
into #acctsToAdd
from #acctsmfsts tmp
join cteManifestSequenceTemplates mst
	on tmp.ManifestTemplateId = mst.ManifestTemplateId

/*
select a.AccountPubID, a.ManifestSequenceTemplateId, 0
	, ac.AcctCode, p.PubShortName
from #acctsToAdd a
left join scManifestSequenceItems msi
	on a.AccountPubID = msi.AccountPubId
	and a.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
join scAccountsPubs ap
	on a.AccountPubID = ap.AccountPubID
join nsPublications p
	on ap.PublicationId = p.PublicationID		
join scAccounts ac
	on ap.AccountId = ac.AccountID
where msi.ManifestSequenceItemId is null
and ac.AcctCode = 'SC737003'
order by a.AccountPubID
*/

select *
into support_scManifestSequenceItems_Backup_04282014
from scManifestSequenceItems	

insert into scManifestSequenceItems ( AccountPubId, ManifestSequenceTemplateId, Sequence )
select a.AccountPubID, a.ManifestSequenceTemplateId, 0
from #acctsToAdd a
left join scManifestSequenceItems msi
	on a.AccountPubID = msi.AccountPubId
	and a.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
where msi.ManifestSequenceItemId is null
order by a.AccountPubID
print cast(@@rowcount as varchar) + ' records inserted into scManifestSequenceItems'

exec support_splitAcctPubs_Cleanup 'max'

exec support_account '60008517'

--select AccountPubId, ManifestSequenceTemplateId, COUNT(*)
--from scManifestSequenceItems msi
--group by AccountPubId, ManifestSequenceTemplateId

--having COUNT(*) > 1

commit tran