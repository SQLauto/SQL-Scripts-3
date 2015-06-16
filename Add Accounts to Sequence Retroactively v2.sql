begin tran

set nocount on

create table #accounts ( AcctCode varchar(50) )

declare @mfstcode varchar(50)
declare @beginDate datetime

--|  Variables
set @beginDate = '8/12/2009'
--set @mfstcode = 'mfst1'

insert into #accounts ( AcctCode )
select '00011051'

--|Get the ManifestSequenceTemplates that the Account currently belongs to
select ap.AccountPubid, msi.ManifestSequenceTemplateId, msi.Sequence
into #manifestAccounts
from #accounts tmp
join scAccounts a
	on tmp.AcctCode = a.AcctCode
join scAccountsPubs ap
	on a.Accountid = ap.AccountId
join scManifestSequenceItems msi
	on ap.AccountPubId = msi.AccountPubid

insert into scmanifestsequences (manifestid, manifestsequencetemplateid, accountpubid, sequence)
select distinct m.ManifestId, ms.ManifestSequenceTemplateId, tmp.AccountPubId, tmp.Sequence
from scManifests m
join scManifestSequences ms
	on m.ManifestId = ms.ManifestId
join (
	select distinct m.ManifestDate, m.ManifestId, ms.ManifestSequenceTemplateId, tmp.AccountPubId, tmp.Sequence
	from scManifests m
	join scManifestSequences ms
		on m.ManifestId = ms.ManifestId
	join #manifestAccounts tmp
		on ms.ManifestSequenceTemplateId = tmp.ManifestSequenceTemplateId
	where ManifestDate >= @beginDate
) tmp
on  m.ManifestId = tmp.ManifestId
and ms.ManifestSequenceTemplateId = tmp.ManifestSequenceTemplateId
left join (
	select distinct m.ManifestDate, m.ManifestId, ms.ManifestSequenceTemplateId
	from scManifests m
	join scManifestSequences ms
		on m.ManifestId = ms.ManifestId
	join #manifestAccounts tmp
		on ms.ManifestSequenceTemplateId = tmp.ManifestSequenceTemplateId
		and ms.AccountPubId = tmp.AccountPubId
	where ManifestDate >= @beginDate
	) existing
	on m.ManifestId = existing.ManifestId
where existing.ManifestId is null
print cast(@@rowcount as varchar) + ' sequence records added'

rollback tran

