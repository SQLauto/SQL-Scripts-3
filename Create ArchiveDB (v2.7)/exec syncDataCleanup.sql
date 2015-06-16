





select min(drawdate), max(drawdate) as [production]
from nsdb..scdraws

exec syncdatacleanup_daterange @beginDate='1/1/2008', @endDate='3/31/2008', @archivedb='nsdb_archive_2008_Qtr1'
--exec syncDataCleanup_DeleteDateRange @beginDate='1/1/2007', @endDate='12/31/2007', @archiveData=1, @archivedb='nsdb_archive_2007'
--exec syncdatacleanup_deletedaterange @beginDate='1/1/2007', @endDate='12/31/2007'
 
select min(drawdate), max(drawdate) as [production]
from nsdb..scdraws

select min(drawdate), max(drawdate)
from nsdb_archive_2007..scdraws