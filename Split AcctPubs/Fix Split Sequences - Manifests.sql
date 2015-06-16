
begin tran

declare @mfstdate datetime
declare @mfstcode varchar(25)

set @mfstdate = null
set @mfstcode = null

select splits.ManifestId, splits.ManifestSequenceTemplateId, splits.AccountId
	, ap.AccountPubId
	, ap.PublicationId
	, Sequence
	, MinSequence
	, MaxSequence
into #splitDetails
from (  
	--|  splits
	select ManifestId, ManifestSequenceTemplateId, AccountId, Min(Sequence) as [MinSequence], max(Sequence) as [MaxSequence]
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

--| Preview
select tmp.*
	, coalesce( MinSequence, msi.Sequence ) as [NewSequence]
into #preview
from #splitDetails tmp
left join scManifestSequenceItems msi
	on tmp.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	and tmp.AccountPubId = msi.AccountPubId

--
--select *
--from #preview

--|Friendly Preview
select prv.ManifestId, m.ManifestDate, m.MfstCode, prv.AccountId, a.AcctCode, prv.PublicationId, p.PubShortName, prv.Sequence, prv.NewSequence
from #preview prv
join scManifests m
	on prv.ManifestId = m.ManifestId
join scManifestSequenceTemplates mst
	on prv.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
join scAccounts a
	on prv.AccountId = a.AccountId
join nsPublications p
	on prv.PublicationId = p.PublicationId
order by a.AcctCode, p.PubShortName

update scManifestSequences
set Sequence = NewSequence
from scManifests m
join scManifestSequences ms
	on m.ManifestId = ms.ManifestId
join #preview new
	on m.ManifestId = new.ManifestId
	and ms.ManifestSequenceTemplateId = new.ManifestSequenceTemplateId
	and ms.AccountPubId = new.AccountPubId
print cast(@@rowcount as varchar) + ' sequence records updated'

--|Review
/*
select m.ManifestId, m.ManifestDate, m.MfstCode, a.accountId, a.AcctCode
from scManifests m
join (
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
	on m.ManifestId = splits.ManifestId
join scAccounts a
	on a.AccountId = splits.AccountId
*/

drop table #preview
drop table #splitDetails

rollback tran