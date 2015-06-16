begin tran
set nocount on
	select ManifestTemplateId
	into #manifestToDelete
	from scmanifesttemplates mt
	left join (
		select distinct mfstcode
		from scmanifestload_view v
		) as v
		on v.mfstcode = mt.mtcode
	where v.mfstcode is null	

	select COUNT(*)
	from #manifestToDelete

	--|Manifests
	print 'deleting data from table [scManifestDownloadCancellations]'
	delete [scManifestDownloadCancellations] 
	from [scManifestDownloadCancellations] mdc
	join scManifestTransfers mt
		on mdc.ManifestTransferId = mt.ManifestTransferId
	join scManifests m
		on mt.ManifestID = m.ManifestID
	join #manifestToDelete tmp
		on m.ManifestTemplateId = tmp.ManifestTemplateId
			
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestDownloadCancellations]'
	print ''

	print 'deleting data from table [scManifestTransferDrops]'
	delete [scManifestTransferDrops]
	from [scManifestTransferDrops] mtd
	join scManifestTransfers mt
		on mtd.ManifestTransferId = mt.ManifestTransferId
	join scManifests m
		on mt.ManifestID = m.ManifestID
	join #manifestToDelete tmp
		on m.ManifestTemplateId = tmp.ManifestTemplateId
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestTransferDrops]'
	print ''

	print 'deleting data from table [scManifestTransfers]'
	delete [scManifestTransfers]
	from [scManifestTransfers] mt
	join scManifests m
		on mt.ManifestID = m.ManifestID
	join #manifestToDelete tmp
		on m.ManifestTemplateId = tmp.ManifestTemplateId

	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestTransfers]'
	print ''

	print 'deleting data from table [scManifestHistory]'
	delete [scManifestHistory]
	from [scManifestHistory] mh
	join scManifests m
		on mh.ManifestID = m.ManifestID
	join #manifestToDelete tmp
		on m.ManifestTemplateId = tmp.ManifestTemplateId
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestHistory]'
	print ''

	print 'deleting data from table [scManifestSequences]'
	delete [scManifestSequences]
	from [scManifestSequences] ms
	join scManifests m
		on ms.ManifestID = m.ManifestID
	join #manifestToDelete tmp
		on m.ManifestTemplateId = tmp.ManifestTemplateId

	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestSequences]'
	print ''


	print 'deleting data from table [scConditionHistory]'
	delete [scConditionHistory]
	from [scConditionHistory] ch
	join [scManifests] m
		on ch.ManifestId = m.ManifestId
	join #manifestToDelete tmp
		on m.ManifestTemplateId = tmp.ManifestTemplateId

	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scConditionHistory]'
	print ''

	print 'deleting data from table [scManifests]'
	delete [scManifests]
	from [scManifests] m
	join #manifestToDelete tmp
		on m.ManifestTemplateId = tmp.ManifestTemplateId

	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifests]'
	print ''

	print 'deleting data from table [scManifestSequenceItems]'
	delete [scManifestSequenceItems]
	from [scManifestSequenceItems] msi
	join scManifestSequenceTemplates mst
		on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
	join #manifestToDelete tmp
		on mst.ManifestTemplateId = tmp.ManifestTemplateId	


	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestSequenceItems]'
	print ''

	print 'deleting data from table [scManifestSequenceTemplates]'
	delete [scManifestSequenceTemplates]
	from [scManifestSequenceTemplates] mst
	join #manifestToDelete tmp
		on mst.ManifestTemplateId = tmp.ManifestTemplateId
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestSequenceTemplates]'
	print ''

	print 'deleting data from table [scManifestTemplates]'
	delete [scManifestTemplates]
	from [scManifestTemplates] mt
	join #manifestToDelete tmp
		on tmp.ManifestTemplateId = mt.ManifestTemplateId
		
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestTemplates]'
	print ''

	--print 'deleting data from table [scManifestLoad]'
	--delete from [scManifestLoad]
	--print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestLoad]'
	--print ''

	print 'deleting data from table [scManifestQueue]'
	delete from [scManifestQueue]
	print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestQueue]'
	print ''
	                                                                         
rollback tran	                                                                         