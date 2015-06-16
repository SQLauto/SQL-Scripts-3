begin tran
/*
	Displays Accounts that do not have all of their pubs assigned to a manifest 
	for a given day of the week.  These pubs are eligible to be assigned to a manifest 
	to fill in the "gaps".  
	
	Note:  These accounts may be spread over multiple manifests so it may not be apparent
	which manifest these accounts should be added to.
*/

select AccountID, AcctCode, ManifestTypeId, Frequency, SUM(PubCount) as [PubCount (Assigned)]
into #seqPubCount
from (
	select a.AccountID, a.AcctCode, mt.ManifestTypeId, mst.Frequency, COUNT(*) as [PubCount]
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	join scAccountsPubs ap
		on msi.AccountPubId = ap.AccountPubID
	join scAccounts a
		on ap.AccountId = a.AccountID
	where mt.ManifestTypeId = 1	
	group by a.AccountID, a.AcctCode, mt.ManifestTypeId, mst.Frequency	
) as [seqPubCount]
group by AccountID, AcctCode, ManifestTypeId, Frequency
order by AccountID, ManifestTypeId, Frequency

--/*
select seq.*, pubCount.PubCount as [PubCount (Total)]
from #seqPubCount seq
join (
	select a.AccountID, a.AcctCode, COUNT(*) as [PubCount]
	from scAccounts a
	join scAccountsPubs ap
		on a.AccountID = ap.AccountId
	group by a.AccountID, a.AcctCode
	--order by a.AccountID	
	) as [pubCount]
	on seq.AccountID = pubCount.AccountID	
where seq.[PubCount (Assigned)] <> pubCount.PubCount	
--*/	
rollback tran