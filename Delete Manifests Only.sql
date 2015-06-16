begin tran

set nocount on

select m.manifestid
into #mfstsToDelete
from scManifests m
where MfstCode = 'Newminded'
and ManifestOwner = 64

select *
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
	on m.ManifestID = tmp.manifestId	

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
	on m.ManifestId = tmp.manifestId	
print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestTransferDrops]'
print ''

print 'deleting data from table [scManifestTransfers]'
delete [scManifestTransfers]
from [scManifestTransfers] mt
join scManifests m
	on m.ManifestID = mt.ManifestID
join #mfstsToDelete tmp
	on m.ManifestId = tmp.manifestId	

print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestTransfers]'
print ''

print 'deleting data from table [scManifestHistory]'
delete [scManifestHistory]
from [scManifestHistory] mh
join scManifests m
	on m.ManifestID = mh.ManifestID
join #mfstsToDelete tmp
	on m.ManifestId = tmp.manifestId	

print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestHistory]'
print ''

print 'deleting data from table [scManifestSequences]'
delete [scManifestSequences]
from [scManifestSequences] ms
join scManifests m
	on m.ManifestID = ms.ManifestID
join #mfstsToDelete tmp
	on m.ManifestId = tmp.manifestId	

print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestSequences]'
print ''

print 'deleting data from table [scManifests]'
delete [scManifests]
from [scManifests] m
join #mfstsToDelete tmp
	on m.ManifestId = tmp.manifestId
print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifests]'
print ''

--print 'deleting data from table [scManifestLoad]'
--delete from [scManifestLoad]
--print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestLoad]'
--print ''

--print 'deleting data from table [scManifestQueue]'
--delete from [scManifestQueue]
--print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestQueue]'
--print ''
                                                                         
commit tran