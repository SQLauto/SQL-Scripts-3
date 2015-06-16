begin tran
set nocount on

/*
	consolidate multi-day sequences into a single 7-day sequence
	
	get all acctpubs for a given manifest template
	delete existing sequences
	add full week manifest sequence
	add manifest sequence items
*/
create table templatesToConsolidate ( 
	  tmpId int identity(10,10) not null
	, ManifestTemplateId int
	, MTCode nvarchar(20)
	, ManifestTypeId int
	, AccountPubId int
	, AccountId int
	, PublicationId int
	, Sequence int
	)
	
insert into templatesToConsolidate (ManifestTemplateId, MTCode, ManifestTypeId, AccountPubId, AccountId, PublicationId, Sequence)
select distinct mt.ManifestTemplateId, mt.MTCode, mt.ManifestTypeId, ap.AccountPubID, ap.AccountId, ap.PublicationId, seq.Sequence
from (
	select mst.ManifestTemplateId
	from scManifestSequenceTemplates mst
	group by mst.ManifestTemplateId
	having count(*) > 1
	) as multiSequenceMT
join scManifestTemplates mt
	on mt.ManifestTemplateId = multiSequenceMT.ManifestTemplateId
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
left join scManifestSequenceItems msi
	on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
left join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubID	
join (
	select mt.ManifestTemplateId, ap.AccountId, min(msi.Sequence) as [Sequence]
	from (	
		select mst.ManifestTemplateId
		from scManifestSequenceTemplates mst
		group by mst.ManifestTemplateId
		having count(*) > 1
	) as multiSequenceMT
	join scManifestTemplates mt
		on mt.ManifestTemplateId = multiSequenceMT.ManifestTemplateId
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	join scAccountsPubs ap
		on msi.AccountPubId = ap.AccountPubID	
	group by mt.ManifestTemplateId, ap.accountId
	) as seq
on mt.ManifestTemplateId = seq.ManifestTemplateId
and ap.AccountId = seq.AccountId
where MTCode in ( '010' )
order by mt.ManifestTemplateId, ap.AccountId

select *
from templatesToConsolidate
order by sequence

--|  Clear out existing sequences	
delete scManifestSequenceItems 
from scManifestTemplates mt
join templatesToConsolidate tmp
	on mt.ManifestTemplateId = tmp.ManifestTemplateId
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
join scManifestSequenceItems msi
	on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
print 'Deleted ' + cast(@@rowcount as varchar) + ' ManifestSequenceItems'

delete scManifestSequenceTemplates
from scManifestTemplates  mt
join templatesToConsolidate tmp
	on mt.ManifestTemplateId = tmp.ManifestTemplateId
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
print 'Deleted ' + cast(@@rowcount as varchar) + ' ManifestSequenceTemplates'

--|  Add full frequency sequence
insert into scManifestSequenceTemplates ( ManifestTemplateId, Code, [Description], Frequency )
select distinct ManifestTemplateId, MTCode + '_Seq', 'Everyday Sequence for ' + MTCode, 127
from templatesToConsolidate tmp
print 'Added ' + cast(@@rowcount as varchar) + ' ManifestSequenceTemplates'

--|  Get the new ManifestSequenceTemplateId (we have everything we now need to insert these into scManifestSequenceItems
create table #candidates ( 
	  AccountPubId int
	, ManifestTemplateId int
	, ManifestTypeId int
	, ManifestSequenceTemplateId int
	, Frequency int
	, Sequence int
	)

insert into #candidates ( AccountPubId, ManifestTemplateId, ManifestTypeId, ManifestSequenceTemplateId, Frequency, Sequence )	
select tmp.AccountPubId, tmp.ManifestTemplateId, tmp.ManifestTypeId, mst.ManifestSequenceTemplateId, mst.Frequency, Sequence 
from templatesToConsolidate tmp
join scManifestSequenceTemplates mst
	on tmp.MTCode + '_Seq' = mst.Code
order by Sequence

create table #resequence ( 
	  tmpId int identity(10,10) not null
	, ManifestTemplateId int
	, AccountId int
	)

declare @mfst int
declare mfst_cursor cursor
for
	select distinct ManifestTemplateId
	from #candidates

open mfst_cursor
fetch next from mfst_cursor into @mfst
while @@fetch_status = 0
begin
	insert into #resequence ( ManifestTemplateId, AccountId )
	select ManifestTemplateId, AccountId
	from templatesToConsolidate tmp
	where ManifestTemplateId = @mfst
	group by ManifestTemplateId, AccountId
	--order by tmp.Sequence
	
	update #candidates
	set Sequence = tmpId
	from #resequence tmp
	join scAccountsPubs ap
		on tmp.AccountId = ap.AccountId
	join #candidates c
		on ap.AccountPubID = c.AccountPubId
		and tmp.ManifestTemplateId = c.ManifestTemplateId	

	delete from #resequence
	dbcc checkident ('#resequence', reseed, 0) 

	fetch next from mfst_cursor into @mfst
end

close mfst_cursor
deallocate mfst_cursor

--select *
--from #candidates
--order by ManifestTemplateId, Sequence

--|  Do any conflicts exist?  A conflict will be AccountPubId, overlapping a frequency of the same manifest type
select a.AcctCode, p.PubShortName
	--, candidates.*
	, cmt.MTCode
	, cmst.Code, cmst.Frequency
	, mt.MTCode as [Conflicting ManifestTemplate]
	, mst.Code as [Conflicting ManifestSequenceTemplate]
	, mst.Frequency as [Conflicting Frequency]
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
join scManifestSequenceItems msi
	on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubID
join scAccounts a
	on ap.AccountId = a.AccountID
join nsPublications p
	on ap.PublicationId = p.PublicationID	
right join 
	--(
	--select tmp.AccountPubId, tmp.ManifestTemplateId, tmp.ManifestTypeId, mst.ManifestSequenceTemplateId, mst.Frequency, Sequence
	--from templatesToConsolidate tmp
	--join scManifestSequenceTemplates mst
	--	on tmp.MTCode + '_Seq' = mst.Code
	--) as candidates
	#candidates candidates
	on msi.AccountPubId = candidates.AccountPubId
	and mst.Frequency & candidates.Frequency > 0
	and mt.ManifestTypeId = candidates.ManifestTypeId
join scManifestTemplates cmt
	on candidates.ManifestTemplateId = cmt.ManifestTemplateId
join scManifestSequenceTemplates cmst
	on cmt.ManifestTemplateId = cmst.ManifestTemplateId
	and candidates.ManifestSequenceTemplateId = cmst.ManifestSequenceTemplateId
where msi.ManifestSequenceItemId is not null  --|not on any existing manifests

--insert into scManifestSequenceItems ( ManifestSequenceTemplateId, AccountPubId, Sequence )
select candidates.ManifestSequenceTemplateId, candidates.AccountPubId, candidates.Sequence
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
join scManifestSequenceItems msi
	on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubID
join scAccounts a
	on ap.AccountId = a.AccountID
right join 
	--(
	--select tmp.AccountPubId, tmp.ManifestTemplateId, tmp.ManifestTypeId, mst.ManifestSequenceTemplateId, mst.Frequency, Sequence
	--from templatesToConsolidate tmp
	--join scManifestSequenceTemplates mst
	--	on tmp.MTCode + '_Seq' = mst.Code
	--) as candidates
	#candidates candidates
	on msi.AccountPubId = candidates.AccountPubId
	and mst.Frequency & candidates.Frequency > 0
	and mt.ManifestTypeId = candidates.ManifestTypeId
where msi.ManifestSequenceItemId is null  --|not on any existing manifests
print 'Inserted ' + cast(@@rowcount as varchar) + ' manifest sequence items'

drop table templatesToConsolidate
drop table #candidates
drop table #resequence

rollback tran
