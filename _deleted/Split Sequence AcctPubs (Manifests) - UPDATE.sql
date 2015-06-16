begin tran

set nocount on

--|First we identify  Accounts that appear more than once on a Manifest Sequence
select M.ManifestDate, m.ManifestId, mst.ManifestSequenceTemplateId, a.AccountId, Sequence
into #prelim
from scmanifests m
join scmanifestsequences ms
	on m.manifestid = ms.manifestid
join scaccountspubs ap
	on ms.accountpubid = ap.accountpubid
join scaccounts a
	on ap.accountid = a.accountid
join scmanifestsequencetemplates mst
	on ms.manifestsequencetemplateid = mst.manifestsequencetemplateid
group by M.ManifestDate, m.ManifestId, mst.ManifestSequenceTemplateId, a.AccountId, Sequence

--|Then we identify Accounts that have more than one Sequence 

--|  Preview of Data
select convert(varchar,m.ManifestDate,1) as [ManifestDate], m.MfstCode, mst.Code, a.AcctCode, p.PubShortName, ms.Sequence
from scmanifests m
join scmanifestsequences ms
	on m.manifestid = ms.manifestid
join scaccountspubs ap
	on ms.accountpubid = ap.accountpubid
join scaccounts a
	on ap.accountid = a.accountid
join scmanifestsequencetemplates mst
	on ms.manifestsequencetemplateid = mst.manifestsequencetemplateid
join nspublications p
	on ap.publicationid = p.publicationid
join (
	select ManifestDate, ManifestId, ManifestSequenceTemplateId, AccountId
	from #prelim
	group by ManifestDate, ManifestId, ManifestSequenceTemplateId, AccountId
	having count(*) > 1
	) as tmp
on m.ManifestDate = tmp.ManifestDate
and m.ManifestId = tmp.ManifestId
and mst.ManifestSequenceTemplateId = tmp.ManifestSequenceTemplateId
and a.AccountId = tmp.AccountId
order by ManifestDate, MfstCode, Code, AcctCode, ms.Sequence

--|  Use the min(sequence) as the sequence of record
select tmp.ManifestDate, tmp.ManifestId, tmp.ManifestSequenceTemplateId, tmp.AccountId, min(ms.Sequence) as [Sequence]
into #minSequence
from scmanifests m
join scmanifestsequences ms
	on m.manifestid = ms.manifestid
join scaccountspubs ap
	on ms.accountpubid = ap.accountpubid
join scaccounts a
	on ap.accountid = a.accountid
join scmanifestsequencetemplates mst
	on ms.manifestsequencetemplateid = mst.manifestsequencetemplateid
join (
	select ManifestDate, ManifestId, ManifestSequenceTemplateId, AccountId
	from #prelim
	group by ManifestDate, ManifestId, ManifestSequenceTemplateId, AccountId
	having count(*) > 1
	) as tmp
on m.ManifestDate = tmp.ManifestDate
and m.ManifestId = tmp.ManifestId
and mst.ManifestSequenceTemplateId = tmp.ManifestSequenceTemplateId
and a.AccountId = tmp.AccountId
group by tmp.ManifestDate, tmp.ManifestId, tmp.ManifestSequenceTemplateId, tmp.AccountId

update scManifestSequences
set Sequence = tmp.Sequence
from scmanifests m
join scmanifestsequences ms
	on m.manifestid = ms.manifestid
join scaccountspubs ap
	on ms.accountpubid = ap.accountpubid
join scaccounts a
	on ap.accountid = a.accountid
join scmanifestsequencetemplates mst
	on ms.manifestsequencetemplateid = mst.manifestsequencetemplateid
join #minSequence tmp
	on m.ManifestDate = tmp.ManifestDate
	and m.ManifestId = tmp.ManifestId
	and mst.ManifestSequenceTemplateId = tmp.ManifestSequenceTemplateId
	and a.AccountId = tmp.AccountId
where ms.Sequence <> tmp.Sequence
print 'Updated ' + cast(@@rowcount as varchar) + ' Sequences.'


--|  Review of Data
select convert(varchar,m.ManifestDate,1) as [ManifestDate], m.MfstCode, mst.Code, a.AcctCode, ms.Sequence
from scmanifests m
join scmanifestsequences ms
	on m.manifestid = ms.manifestid
join scaccountspubs ap
	on ms.accountpubid = ap.accountpubid
join scaccounts a
	on ap.accountid = a.accountid
join scmanifestsequencetemplates mst
	on ms.manifestsequencetemplateid = mst.manifestsequencetemplateid
join (
	select ManifestDate, ManifestId, ManifestSequenceTemplateId, AccountId
	from #prelim
	group by ManifestDate, ManifestId, ManifestSequenceTemplateId, AccountId
	having count(*) > 1
	) as tmp
on m.ManifestDate = tmp.ManifestDate
and m.ManifestId = tmp.ManifestId
and mst.ManifestSequenceTemplateId = tmp.ManifestSequenceTemplateId
and a.AccountId = tmp.AccountId
group by convert(varchar,m.ManifestDate,1), m.MfstCode, mst.Code, a.AcctCode, ms.Sequence
having count(*) > 1
order by a.AcctCode, m.ManifestDate, ms.Sequence

drop table #prelim
drop table #minSequence

rollback tran