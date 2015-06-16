begin tran

update scmanifesttransfers
set mfsttransferstatus = ( select processingstateid from dd_scprocessingstates where psname = 'Critical Error' )
where manifesttransferid = 9

select psname, mt.*
from scmanifesttransfers mt
join dd_scprocessingstates ps
	on mt.mfsttransferstatus = ps.processingstateid
where datediff(d, mfstdate, getdate()) = 0

commit tran