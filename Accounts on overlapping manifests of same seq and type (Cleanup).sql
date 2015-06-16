begin tran
/*
	Accounts in violation of the rule that AccountPubs cannot be on two
	manifests of the same type and frequency
*/

select a.AcctCode, a.AcctName
	, mt.MTCode, mt.MTName
	, mst.Code, typ.ManifestTypeDescription, mst.Frequency
	, p.PubShortName
	, a.AccountID, ap.AccountPubId, mt.ManifestTemplateId, mt.ManifestTypeId, mst.ManifestSequenceTemplateId
into #tmp
from scAccountsPubs ap
join scManifestSequenceItems msi
	on ap.AccountPubId = msi.AccountPubId
join scManifestSequenceTemplates mst
	on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
join scManifestTemplates mt
	on mst.ManifestTemplateId = mt.ManifestTemplateId
join scAccounts a
	on ap.AccountId = a.AccountId
join nsPublications p
	on ap.PublicationId = p.PUblicationId
join dd_scManifestTypes typ
	on mt.ManifestTypeId = typ.ManifestTypeId

select t1.AcctCode, t1.AcctName, t1.PubShortName
	, t1.MTCode as [MTCode1], t1.Code as [Seq1], t1.Frequency as [Freq1]
	, t2.MTCode as [MTCode2], t2.Code as [Seq2], t2.Frequency as [Freq2]
	, t1.AccountPubId, t1.ManifestSequenceTemplateId
	, t2.ManifestSequenceTemplateId 
from #tmp t1
join #tmp t2
	on t1.AccountPubId = t2.AccountPubId
	and t1.ManifestTypeId = t2.ManifestTypeId
where t1.ManifestSequenceTemplateId <> t2.ManifestSequenceTemplateId
and t1.Frequency & t2.Frequency > 0
and t1.ManifestTemplateId > t2.ManifestTemplateId --|  eliminate duplicates from recordset 
order by t1.AcctCode, t1.PubShortName, t1.MTCode

delete scManifestSequenceItems
from scManifestSequenceItems msi
join (
	select 	t1.AccountPubId, t1.ManifestSequenceTemplateId
	from #tmp t1
	join #tmp t2
		on t1.AccountPubId = t2.AccountPubId
		and t1.ManifestTypeId = t2.ManifestTypeId
	where t1.ManifestSequenceTemplateId <> t2.ManifestSequenceTemplateId
	and t1.Frequency & t2.Frequency > 0
	and t1.ManifestTemplateId > t2.ManifestTemplateId --|  eliminate duplicates from recordset 
	--order by t1.AcctCode, t1.PubShortName, t1.MTCode
	) as dups
	on msi.AccountPubId = dups.accountpubid
	and msi.ManifestSequenceTemplateId = dups.manifestsequencetemplateid

drop table #tmp

select a.AcctCode, a.AcctName
	, mt.MTCode, mt.MTName
	, mst.Code, typ.ManifestTypeDescription, mst.Frequency
	, p.PubShortName
	, a.AccountID, ap.AccountPubId, mt.ManifestTemplateId, mt.ManifestTypeId, mst.ManifestSequenceTemplateId
into #tmp2
from scAccountsPubs ap
join scManifestSequenceItems msi
	on ap.AccountPubId = msi.AccountPubId
join scManifestSequenceTemplates mst
	on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
join scManifestTemplates mt
	on mst.ManifestTemplateId = mt.ManifestTemplateId
join scAccounts a
	on ap.AccountId = a.AccountId
join nsPublications p
	on ap.PublicationId = p.PUblicationId
join dd_scManifestTypes typ
	on mt.ManifestTypeId = typ.ManifestTypeId

select t1.AcctCode, t1.AcctName, t1.PubShortName
	, t1.MTCode as [MTCode1], t1.Code as [Seq1], t1.Frequency as [Freq1]
	, t2.MTCode as [MTCode2], t2.Code as [Seq2], t2.Frequency as [Freq2]
	, t1.AccountPubId, t1.ManifestSequenceTemplateId
	, t2.ManifestSequenceTemplateId 
from #tmp2 t1
join #tmp2 t2
	on t1.AccountPubId = t2.AccountPubId
	and t1.ManifestTypeId = t2.ManifestTypeId
where t1.ManifestSequenceTemplateId <> t2.ManifestSequenceTemplateId
and t1.Frequency & t2.Frequency > 0
and t1.ManifestTemplateId > t2.ManifestTemplateId --|  eliminate duplicates from recordset 
order by t1.AcctCode, t1.PubShortName, t1.MTCode

drop table #tmp2

rollback tran

