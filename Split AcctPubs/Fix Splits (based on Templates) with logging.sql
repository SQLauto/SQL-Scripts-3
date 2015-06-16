use NSDB_COSP

begin tran

set nocount on

declare @mfstdate datetime
declare @mfstcode varchar(25)

set @mfstdate = null
set @mfstcode = null

select splits.ManifestId, splits.ManifestSequenceTemplateId, splits.AccountId
	, ap.AccountPubId
	, ap.PublicationId
	, Sequence
into #splitDetails
from (  
	--|  splits
	select ManifestId, ManifestSequenceTemplateId, AccountId
	from (
		--|  prelim
		select  m.ManifestId, ManifestSequenceTemplateId, ap.AccountId, ms.Sequence  
		from scManifests m
		join scManifestSequences ms
			on m.ManifestId = ms.ManifestId
		join scAccountsPubs ap
			on ms.AccountPubId = ap.AccountPubId
		where
			(
				( @mfstdate is null and m.ManifestId > 0 )
				or 
				( @mfstdate is not null and datediff(d, m.ManifestDate, @mfstdate) = 0 )
			)
		and ( 
				( @mfstcode is null and m.ManifestId > 0 )
				or
				( @mfstcode is not null and m.MfstCode = @mfstcode )
			)
		group by m.ManifestId, ManifestSequenceTemplateId, ap.AccountId, ms.Sequence  
	 ) as [prelim]  
	group by ManifestId, ManifestSequenceTemplateId, AccountId 
	having count(*) > 1 
	) as [splits]
join scAccountsPubs ap
	on splits.AccountId = ap.AccountId
join scManifestSequences ms
	on ap.AccountPubId = ms.AccountPubId
	and splits.ManifestSequenceTemplateId = ms.ManifestSequenceTemplateId
	and splits.ManifestId = ms.ManifestId
order by 1, 2, 3

/*
select *
from #splitDetails
*/

if exists (
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
)
begin
	print 'Cannot fix splits in Manifest Sequences because Manifests Templates also have splits'
	rollback tran
	return
end

;with cteTemplates
as (
	select mt.ManifestTemplateId, mst.ManifestSequenceTemplateId, Frequency, ap.AccountPubId, msi.Sequence  
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	join scAccountsPubs ap
		on msi.AccountPubId = ap.AccountPubId
	where ( 
				( @mfstcode is null and mt.ManifestTemplateId > 0 )
				or
				( @mfstcode is not null and mt.MTCode = @mfstcode )
			)		
)
--| Preview
select tmp.*
	, msi.Sequence as [TemplateSequence]
	, MinMax.MinSequence, MinMax.MaxSequence
into #preview
from #splitDetails tmp
left join scManifestSequenceItems msi
	on tmp.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	and tmp.AccountPubId = msi.AccountPubId
join (
	select ManifestID, AccountId, min(Sequence) as [MinSequence], max(Sequence) as [MaxSequence]
	from #splitDetails
	group by ManifestID, AccountId
	) as MinMax
	on tmp.ManifestID = MinMax.ManifestID
	and tmp.AccountId = MinMax.AccountId
--
--select *
--from #preview

--|Friendly Preview
select prv.ManifestId, m.ManifestDate, m.MfstCode, prv.AccountId, a.AcctCode, prv.PublicationId, p.PubShortName, prv.Sequence, prv.[TemplateSequence]
	, prv.MinSequence, prv.MaxSequence
from #preview prv
join scManifests m
	on prv.ManifestId = m.ManifestId
join scManifestSequenceTemplates mst
	on prv.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
join scAccounts a
	on prv.AccountId = a.AccountId
join nsPublications p
	on prv.PublicationId = p.PublicationId
where prv.Sequence <> coalesce(prv.TemplateSequence, prv.MaxSequence)
order by a.AcctCode, m.MfstCode, m.ManifestDate, p.PubShortName

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
	 'Account ''' + a.AcctCode + ''' on Manifest ''' + m.MfstCode + ' for ''' + CONVERT(varchar, m.ManifestDate, 1)
	  + ''' was split between drop sequences.  Publication ''' + p.PubShortName + ''' was moved to drop sequence ' + cast( coalesce(prv.TemplateSequence, prv.MaxSequence) as varchar)
	  + '.'
		as [LogMessage]
	, getdate() as [SLTimeStamp]
	, 2 as [ModuleId]	--|2=SingleCopy
	, 1 as [SeverityId] --|1=Warning
	, 1 as [CompanyId]
	, N'' as [Source]   --|nvarchar(100)
	--, newid() as [GroupId]
from #preview prv
join scManifests m
	on prv.ManifestId = m.ManifestId
join scManifestSequenceTemplates mst
	on prv.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
join scAccounts a
	on prv.AccountId = a.AccountId
join nsPublications p
	on prv.PublicationId = p.PublicationId
where prv.Sequence <> coalesce(prv.TemplateSequence, prv.MaxSequence)
order by a.AcctCode, m.MfstCode, m.ManifestDate, p.PubShortName

update scManifestSequences
set Sequence = coalesce(new.[TemplateSequence], new.MaxSequence)
from scManifests m
join scManifestSequences ms
	on m.ManifestId = ms.ManifestId
join #preview new
	on m.ManifestId = new.ManifestId
	and ms.ManifestSequenceTemplateId = new.ManifestSequenceTemplateId
	and ms.AccountPubId = new.AccountPubId
where new.Sequence <> coalesce(new.TemplateSequence, new.MaxSequence)	
print cast(@@rowcount as varchar) + ' sequence records updated'

drop table #preview
drop table #splitDetails

select LogMessage
from syncSystemLog
where DATEDIFF(d, sltimestamp, getdate()) = 0
order by SLTimeStamp desc

commit tran