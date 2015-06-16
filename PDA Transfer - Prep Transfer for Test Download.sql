
/*

Instructions:

1)  Set the variables to the appropriate values
2)  Run the first query to generate the sql to set the transfer back to it's current values.
3)  Copy the results so they can be run once testing has been completed
4)  The run the 2nd query to "cancel" the existing download
5)  Finally run the copied code to reset the transfer

*/

declare @mfst varchar(25)
declare @date datetime

set @mfst = 'S503B1DN'
set @date = '12/15/2010'


--|generate sql to revert transfer back to normal
--/*
--|  Query #1

select ' update scmanifesttransfers' 
	+ ' set mfstdownloadstarted = ''' + convert(varchar, mfstdownloadstarted, 21) + ''''
	+ ', mfstdownloadfinished = ''' + convert(varchar, mfstdownloadfinished, 21) + ''''
	+ ', mfstuploadstarted = ''' + isnull( convert(varchar, mfstuploadstarted, 21), '' ) + ''''
	+ ', mfstuploadfinished = ''' + isnull( convert(varchar, mfstuploadfinished, 21), '') + ''''
	+ ', mfsttransferstatus = ' + cast(mfsttransferstatus as varchar)
	+ ' where manifesttransferid = ' + cast(manifesttransferid as varchar)
from scmanifesttransfers mt
join scmanifests m
	on mt.manifestid = m.manifestid
where manifestdate = @date
and m.mfstcode = @mfst

--*/

/*
--|  Query #2
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
where manifestdate = @date
and m.mfstcode = @mfst
*/

/*
--|  Paste results of Query #1 here
 update scmanifesttransfers set mfstdownloadstarted = '2010-01-27 01:23:38.593', mfstdownloadfinished = '2010-01-27 01:59:43.517', mfstuploadstarted = '2010-01-27 05:46:43.033', mfstuploadfinished = '2010-01-27 05:51:17.937', mfsttransferstatus = 13 where manifesttransferid = 47212
*/