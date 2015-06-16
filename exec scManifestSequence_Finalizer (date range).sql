begin tran

declare @begindate datetime
declare @enddate datetime

select @begindate = dateadd(d, 1, max(manifestdate))
	, @enddate = convert(varchar, getdate(), 1)
from scmanifests


while @begindate <> @enddate
begin
	exec scmanifestsequence_finalizer @begindate
	
	set @begindate = dateadd(d, 1, @begindate)
end

commit tran