begin tran

set nocount on

select MTCode as [Manifest]
into #mfstsToDelete
from scManifestTemplates
where MTCode = ''

select manifest
from #mfstsToDelete

--|Manifests
print 'deleting data from table [scManifestDownloadCancellations]'
delete [scManifestDownloadCancellations] 
from [scManifestDownloadCancellations] cxl
join scManifestTransfers mt
	on cxl.ManifestTransferId = mt.ManifestTransferId
join scManifests m
	on m.ManifestID = mt.ManifestID
join #mfstsToDelete tmp
	on m.MfstCode = tmp.Manifest	

print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestDownloadCancellations]'
print ''

print 'deleting data from table [scManifestTransferDrops]'
delete [scManifestTransferDrops]
from [scManifestTransferDrops] mtd
join scManifestTransfers mt
	on mtd.ManifestTransferId = mt.ManifestTransferId
join scManifests m
	on m.ManifestID = mt.ManifestID
join #mfstsToDelete tmp
	on m.MfstCode = tmp.Manifest	
print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestTransferDrops]'
print ''

print 'deleting data from table [scManifestTransfers]'
delete [scManifestTransfers]
from [scManifestTransfers] mt
join scManifests m
	on m.ManifestID = mt.ManifestID
join #mfstsToDelete tmp
	on m.MfstCode = tmp.Manifest	

print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestTransfers]'
print ''

print 'deleting data from table [scManifestHistory]'
delete [scManifestHistory]
from [scManifestHistory] mh
join scManifests m
	on m.ManifestID = mh.ManifestID
join #mfstsToDelete tmp
	on m.MfstCode = tmp.Manifest	

print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestHistory]'
print ''

print 'deleting data from table [scManifestSequences]'
delete [scManifestSequences]
from [scManifestSequences] ms
join scManifests m
	on m.ManifestID = ms.ManifestID
join #mfstsToDelete tmp
	on m.MfstCode = tmp.Manifest	

print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestSequences]'
print ''

print 'deleting data from table [scManifests]'
delete [scManifests]
from [scManifests] m
join #mfstsToDelete tmp
	on m.MfstCode = tmp.Manifest
print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifests]'
print ''

print 'deleting data from table [scManifestSequenceItems]'
delete [scManifestSequenceItems]
from [scManifestSequenceItems] msi
join scManifestSequenceTemplates mst
	on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
join scManifestTemplates mt
	on mst.ManifestTemplateId = mt.ManifestTemplateId
join #mfstsToDelete tmp
	on mt.MTCode = tmp.Manifest
	
print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestSequenceItems]'
print ''

print 'deleting data from table [scManifestSequenceTemplates]'
delete [scManifestSequenceTemplates]
from [scManifestSequenceTemplates] mst
join scManifestTemplates mt
	on mst.ManifestTemplateId = mt.ManifestTemplateId
join #mfstsToDelete tmp
	on mt.MTCode = tmp.Manifest
print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestSequenceTemplates]'
print ''

print 'deleting data from table [scManifestTemplates]'
delete [scManifestTemplates]
from [scManifestTemplates] mt
join #mfstsToDelete tmp
	on mt.MTCode = tmp.Manifest
print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestTemplates]'
print ''

--print 'deleting data from table [scManifestLoad]'
--delete from [scManifestLoad]
--print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestLoad]'
--print ''

--print 'deleting data from table [scManifestQueue]'
--delete from [scManifestQueue]
--print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestQueue]'
--print ''
                                                                         
rollback tran