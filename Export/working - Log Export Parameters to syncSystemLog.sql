begin tran

exec syncSystemProperties_Update @SystemPropertyID=64,@SysPropertyValue=N'Custom "C:\Program Files\Syncronex\SingleCopy\DataIO\nsdb_sample\CustomExport_Adjustments_CHR.xml" /p "StartDate=05/01/2011","StopDate=05/31/2011","UserID=8" /w '
exec syncSystemProperties_Update @SystemPropertyID=65,@SysPropertyValue=N'True'

rollback tran


select *
from syncSystemProperties
where SystemPropertyId = 64
