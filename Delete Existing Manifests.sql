--|Manifests
print 'deleting data from table [scManifestDownloadCancellations]'
delete from [scManifestDownloadCancellations]
print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestDownloadCancellations]'
print ''

print 'deleting data from table [scManifestTransferDrops]'
delete from [scManifestTransferDrops]
print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestTransferDrops]'
print ''

print 'deleting data from table [scManifestTransfers]'
delete from [scManifestTransfers]
print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestTransfers]'
print ''

print 'deleting data from table [scManifestHistory]'
delete from [scManifestHistory]
print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestHistory]'
print ''

print 'deleting data from table [scManifestSequences]'
delete from [scManifestSequences]
print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestSequences]'
print ''

print 'deleting data from table [scManifests]'
delete from [scManifests]
print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifests]'
print ''

print 'deleting data from table [scManifestSequenceItems]'
delete from [scManifestSequenceItems]
print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestSequenceItems]'
print ''

print 'deleting data from table [scManifestSequenceTemplates]'
delete from [scManifestSequenceTemplates]
print '  ' + cast(@@rowcount as varchar) + ' rows deleted from [scManifestSequenceTemplates]'
print ''

print 'deleting data from table [scManifestTemplates]'
delete from [scManifestTemplates]
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
                                                                         