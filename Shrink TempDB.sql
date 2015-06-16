dbcc shrinkfile (tempdev, 8)

dbcc freesystemcache('all')

dbcc shrinkfile (templog, 8)