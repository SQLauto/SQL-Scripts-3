

begin tran

update scmanifesthistory
set mheffectivedate = dateadd(d, ( datediff(d, mheffectivedate, getdate())/7 ) * 7 , mheffectivedate ) + datediff(d, mheffectivedate, getdate()) % 7

select manifestid, mheffectivedate
from scmanifesthistory
group by manifestid, mheffectivedate
order by 2 desc

select manifestid
	, datediff(d, mheffectivedate, getdate()), datediff(d, mheffectivedate, getdate())/7
	, ( datediff(d, mheffectivedate, getdate())/7 ) * 7
	,datediff(d, mheffectivedate, getdate() ) % 7 
from scmanifesthistory

rollback tran

