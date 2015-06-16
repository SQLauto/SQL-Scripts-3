
/*
	Find gaps in ManifestSequenceItems

*/
begin tran
	set nocount on
	
	select *
	into scManifestSequenceItems_BACKUP_04142010
	from scManifestSequenceItems
	print cast(@@rowcount as nvarchar) + ' scManifestSequenceItems records backed up'
	
	select mt.MTCode, mst.ManifestSequenceTemplateId, mst.Code, mst.Frequency, tmp.AccountId, a.AcctCode, ap.PublicationId, PubShortName, ap.AccountPubId, tmp.Sequence
	into #gaps
	from (
		select msi.ManifestSequenceTemplateId, ap.AccountId, msi.Sequence
		from scAccountsPubs ap
		join scManifestSequenceItems msi
			on ap.AccountPubId = msi.AccountPubId
		--where ap.AccountId = 32
		group by msi.ManifestSequenceTemplateId, ap.AccountId, msi.Sequence
		) as tmp
	join scAccountsPubs ap
		on tmp.AccountId = ap.AccountId
	left join scManifestSequenceItems msi
		on ap.AccountPubId = msi.AccountPubId
		and tmp.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	join scManifestSequenceTemplates mst
		on tmp.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
	join scManifestTemplates mt
		on mst.ManifestTemplateId = mt.ManifestTemplateId
	join nsPublications p
		on ap.PublicationId = p.PublicationId
	join scAccounts a
		on tmp.AccountId = a.AccountId
	where msi.ManifestSequenceItemId is null	
	order by tmp.ManifestSequenceTemplateId, a.AcctCode, p.PubShortName

	insert into scManifestSequenceItems ( ManifestSequenceTemplateId, AccountPubId, Sequence )
	select gaps.ManifestSequenceTemplateId, gaps.AccountPubId, gaps.Sequence
	from #gaps gaps
	left join scManifestSequenceItems msi
		on gaps.AccountPubId = msi.AccountPubId
		and gaps.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	left join scManifestSequenceTemplates mst
		on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
	where ( msi.ManifestSequenceTemplateId is null 
		or gaps.Frequency & mst.Frequency = 0 )
	order by gaps.ManifestSequenceTemplateId, gaps.AccountPubId
	print 'inserted ' + cast(@@rowcount as nvarchar) + ' scManifestSequenceItems'

	drop table #gaps

commit tran