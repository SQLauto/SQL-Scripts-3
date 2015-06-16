use NSDB_COSP

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
	, MinMax.MaxSequence as [NewSequence]
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

/*
select *
from #preview
order by accountid
*/

--|Friendly Preview
/*
select
	mt.MTCode as [Manifest]
	, mst.Code as [Manifest Sequence]
	, a.AcctCode
	, p.PubShortName
	, splitDetails.Sequence
	, MaxSequence as [NewSequence]
	, 'Account/Pub ' + a.AcctCode + '/' + p.PubShortName + ' was consolidated on sequence ' + cast(MaxSequence as varchar)+ ' on Manifest/Sequence ' + mt.MTCode + '/' + mst.Code + '.  Old sequence ' + cast(splitDetails.Sequence as varchar) + '.'

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
join scManifestTemplates mt
	on splitDetails.ManifestTemplateId = mt.ManifestTemplateId
join scManifestSequenceTemplates mst
	on splitDetails.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
where splitDetails.Sequence <> MaxSequence	
order by MTCode--a.AcctCode, p.PubShortName
*/


insert into syncSystemLog ( 
	  LogMessage
	, SLTimeStamp
	, ModuleId
	, SeverityId
	, CompanyId
	, [Source]
	--, GroupId 
	)
select 
	 'Account ''' + a.AcctCode + ''' on Manifest/Sequence ''' + mt.MTCode + '/' + mst.Code
	  + ''' was split between drop sequences.  Publication ''' + p.PubShortName + ''' was moved to drop sequence ' + cast(MaxSequence as varchar)
	  + '.  (ManifestTemplates).'
		as [LogMessage]
	, getdate() as [SLTimeStamp]
	, 2 as [ModuleId]	--|2=SingleCopy
	, 1 as [SeverityId] --|1=Warning
	, 1 as [CompanyId]
	, N'' as [Source]   --|nvarchar(100)
	--, newid() as [GroupId]
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
join scManifestTemplates mt
	on splitDetails.ManifestTemplateId = mt.ManifestTemplateId
join scManifestSequenceTemplates mst
	on splitDetails.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
where splitDetails.Sequence <> MaxSequence	
order by MTCode--a.AcctCode, p.PubShortName
update scManifestSequenceItems
set Sequence = new.NewSequence
from scManifestSequenceItems msi
join #preview new
	on msi.ManifestSequenceItemId = new.ManifestSequenceItemId

print cast(@@rowcount as varchar) + ' sequence item records updated'
	
--| Cleanup
drop table #splitDetails
drop table #preview

select LogMessage
from syncSystemLog
where DATEDIFF(d, sltimestamp, getdate()) = 0
order by SLTimeStamp desc

rollback tran