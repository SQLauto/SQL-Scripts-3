begin tran

select *
from scmanifesttransfers
where deviceid = ( select deviceid from nsdevices where devicecode = 'fl7704' )
and mfstdownloadfinished is not null
and mfstuploadfinished is null

update scmanifesttransfers
set mfstdownloadstarted = null
	,mfstdownloadfinished = null
	,mfsttransferstatus = ( select processingstateid from dd_scprocessingstates where psname = 'cancelled' )
where deviceid = ( select deviceid from nsdevices where devicecode = 'fl7704' )
and mfstdownloadfinished is not null
and mfstuploadfinished is null

select *
from scmanifesttransfers
where deviceid = ( select deviceid from nsdevices where devicecode = 'fl7704' )
and mfstdownloadfinished is not null
and mfstuploadfinished is null

commit tran