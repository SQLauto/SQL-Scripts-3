



--|generate sql to revert transfer back to normal
select ' update scmanifesttransfers' 
	+ ' set mfstdownloadstarted = ''' + convert(varchar, mfstdownloadstarted, 21) + ''''
	+ ', mfstdownloadfinished = ''' + convert(varchar, mfstdownloadfinished, 21) + ''''
	+ ', mfstuploadstarted = ''' + convert(varchar, mfstuploadstarted, 21) + ''''
	+ ', mfstuploadfinished = ''' + convert(varchar, mfstuploadfinished, 21) + ''''
	+ ', mfsttransferstatus = ' + cast(mfsttransferstatus as varchar)
	+ ' where manifesttransferid = ' + cast(manifesttransferid as varchar)
from scmanifesttransfers mt
join scmanifests m
	on mt.manifestid = m.manifestid
where manifestdate = '1/19/2010'
and m.mfstcode = 'c1g'

begin tran

update scmanifesttransfers
set mfstdownloadstarted = null
	, mfstdownloadfinished = null
	, mfstuploadstarted = null
	, mfstuploadfinished = null
	, mfsttransferstatus = ( 
		select processingstateid from dd_scprocessingstates where psname = 'cancelled' 
	)
from scmanifesttransfers mt
join scmanifests m
	on mt.manifestid = m.manifestid
where manifestdate = '1/19/2010'
and m.mfstcode = 'c1g'

commit tran