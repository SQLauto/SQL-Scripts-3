
begin tran

set nocount on

/*
	Fix Split Sequences - Manifest Templates.sql

	This procedure consolidates the sequence order of publications for a given account
	using the following logic:

		1)  Min sequence from scManifestLoad_View (e.g. the host system of record)
			  * we use the MIN sequence in case there is more than one sequence 
			    in the load table for a given account 
		2)  Min sequence for the account from the templates

	Note:  If this is run just prior to running the Manifest Sequence Finalizer it should 
			not be necessary to clean up splits in the Manifest tables
	
*/

select splits.ManifestTemplateId, splits.ManifestSequenceTemplateId, splits.AccountId
	, msi.ManifestSequenceItemId 
	, ap.AccountPubId
	, ap.PublicationId
	, Sequence
into #splitDetails
from (  
	--|  splits
	select ManifestTemplateId, ManifestSequenceTemplateId, AccountId 
	from (
		--|  prelim
		select mt.ManifestTemplateId, mst.ManifestSequenceTemplateId, ap.AccountId, msi.Sequence  
		from scManifestTemplates mt
		join scManifestSequenceTemplates mst
			on mt.ManifestTemplateId = mst.ManifestTemplateId
		join scManifestSequenceItems msi
			on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
		join scAccountsPubs ap
			on msi.AccountPubId = ap.AccountPubId
		group by mt.ManifestTemplateId, mst.ManifestSequenceTemplateId, ap.AccountId, msi.Sequence
	 ) as [prelim]  
	group by ManifestTemplateId, ManifestSequenceTemplateId, AccountId 
	having count(*) > 1 
	) as [splits]
join scAccountsPubs ap
	on splits.AccountId = ap.AccountId
join scManifestSequenceItems msi
	on ap.AccountPubId = msi.AccountPubId
	and splits.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
order by 1, 2, 3

/*
select *
from #splitDetails
*/

--|Preview
select splitDetails.ManifestTemplateId, splitDetails.ManifestSequenceTemplateId, splitDetails.AccountId
	, splitDetails.ManifestSequenceItemId
	, splitDetails.Sequence
	, MinMax.MinSequence as [NewSequence]
	, 'Min/Max' as [NewSequence Source]
	, PrimaryPub.PrimaryPubSequenceMin
	, primarypub.PrimaryPubSequenceMax
into #preview
from #splitDetails splitDetails
join scAccounts a
	on splitDetails.AccountId = a.AccountId
join nsPublications p
	on splitDetails.PublicationId = p.PublicationId
join scManifestTemplates mt
	on splitDetails.ManifestTemplateId = mt.ManifestTemplateId
join (
		--| Get the Min/Max sequences from #splitDetails to be used in case scManifestLoad does not have a Sequence of record
		select ManifestTemplateId, AccountId, min(Sequence) as [MinSequence], max(Sequence) as [MaxSequence]
		from #splitDetails
		group by ManifestTemplateId, AccountId
	) as MinMax
	on splitDetails.ManifestTemplateId = MinMax.ManifestTemplateId
	and splitDetails.AccountId = MinMax.AccountId
left join (
		--| Get the sequence for the "primary" publication
		select ManifestTemplateId, AccountId, MIN(Sequence) as [PrimaryPubSequenceMin], MAX(Sequence) as [PrimaryPubSequenceMax]
		from #splitDetails
		where PublicationId = ( select PublicationId from nsPublications where PubShortName = 'ST' )
		group by ManifestTemplateId, AccountId
	) as PrimaryPub
	on splitDetails.ManifestTemplateId = PrimaryPub.ManifestTemplateId
	and splitDetails.AccountId = PrimaryPub.AccountId

/*
select *
from #preview
order by accountid
*/

--|Friendly Preview
--/*
select
	mt.MTCode as [Manifest]
	, mst.Code as [Manifest Sequence]
	, a.AcctCode
	, p.PubShortName
	, splitDetails.Sequence
	, MinMax.MaxSequence as [NewSequence]
	, 'Min/Max'
	, PrimaryPub.PrimaryPubSequenceMin
	, primarypub.PrimaryPubSequenceMax
from #splitDetails splitDetails
join scAccounts a
	on splitDetails.AccountId = a.AccountId
join nsPublications p
	on splitDetails.PublicationId = p.PublicationId
join (
		--| Get the Min/Max sequences from #splitDetails to be used in case scManifestLoad does not have a Sequence of record
		select ManifestTemplateId, AccountId, min(Sequence) as [MinSequence], max(Sequence) as [MaxSequence]
		from #splitDetails
		group by ManifestTemplateId, AccountId
	) as MinMax
	on splitDetails.ManifestTemplateId = MinMax.ManifestTemplateId
	and splitDetails.AccountId = MinMax.AccountId
left join (
		--| Get the sequence for the "primary" publication
		select ManifestTemplateId, AccountId, MIN(Sequence) as [PrimaryPubSequenceMin], MAX(Sequence) as [PrimaryPubSequenceMax]
		from #splitDetails
		where PublicationId = ( select PublicationId from nsPublications where PubShortName = 'ST' )
		group by ManifestTemplateId, AccountId
	) as PrimaryPub
	on splitDetails.ManifestTemplateId = PrimaryPub.ManifestTemplateId
	and splitDetails.AccountId = PrimaryPub.AccountId
join scManifestTemplates mt
	on splitDetails.ManifestTemplateId = mt.ManifestTemplateId
join scManifestSequenceTemplates mst
	on splitDetails.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
order by a.AcctCode, p.PubShortName
--*/

update scManifestSequenceItems
set Sequence = coalesce(new.PrimaryPubSequenceMax, newsequence)
from scManifestSequenceItems msi
join #preview new
	on msi.ManifestSequenceItemId = new.ManifestSequenceItemId
print cast(@@rowcount as varchar) + ' sequence item records updated'
	
--| Cleanup
drop table #splitDetails
drop table #preview

rollback tran