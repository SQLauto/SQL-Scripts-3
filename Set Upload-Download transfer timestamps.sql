begin tran


select manifestid, mfstdate, max(mfstdownloadstarted) as mfstdownloadstarted
			, min(dropdownloaded) as [min dropdownloaded]
	, max(mfstdownloadfinished) as mfstdownloadfinished
			, max(dropdownloaded) as [max dropdownloaded]
	, max(mfstuploadstarted) as mfstuploadstarted
		, min(dropuploaded) as [min drop uploaded]
	, max(mfstuploadfinished) as mfstuploadfinished
		, max(dropuploaded) as [max drop uploaded]
into #tfr
from scmanifesttransfers mt
join scmanifesttransferdrops mtd
	on mt.manifesttransferid = mtd.manifesttransferid
where mt.deviceid = ( select deviceid from nsdevices where devicecode = '123' )
and mfsttransferstatus in ( select processingstateid from dd_scprocessingstates where psname in ('critical error', 'downloading' ) )
group by manifestid, mfstdate
order by mfstdate desc


update scmanifesttransfers 
set mfstdownloadstarted = [min dropdownloaded]
	, mfstdownloadfinished = [max dropdownloaded]
	, mfstuploadstarted = [min drop uploaded]
	, mfstuploadfinished = [max drop uploaded]
	, mfsttransferstatus = ( select processingstateid from dd_scprocessingstates where psname = 'uploaded' )
from scmanifesttransfers mt
join #tfr tfr
	on mt.manifestid = tfr.manifestid
	and mt.mfstdate = tfr.mfstdate
where mt.deviceid = ( select deviceid from nsdevices where devicecode = '123' )
--and mfsttransferstatus in ( select processingstateid from dd_scprocessingstates where psname in ('critical error', 'downloading' ) )
 

select mt.*
from scmanifesttransfers mt
join #tfr tfr
	on mt.manifestid = tfr.manifestid
	and mt.mfstdate = tfr.mfstdate
where mt.deviceid = ( select deviceid from nsdevices where devicecode = '123' )
--and mfsttransferstatus in ( select processingstateid from dd_scprocessingstates where psname in ('critical error', 'downloading' ) )
order by mt.mfstdate desc

drop table #tfr

commit tran