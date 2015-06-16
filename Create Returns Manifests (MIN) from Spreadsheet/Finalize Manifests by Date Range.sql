begin tran

declare @begindate datetime
declare @enddate datetime

set @begindate = '5/27/2013'
set @enddate = '5/31/2013'

select *
from scmanifests
where ManifestDate between @begindate and @enddate
and MfstCode in ('202-ret', '203-ret')

while @begindate <= @enddate
begin
	print 'finalizing for ' + convert(varchar, @begindate, 1)
	exec support_scManifestSequence_Finalizer_ByManifest @begindate, '202-ret'
	exec support_scManifestSequence_Finalizer_ByManifest @begindate, '203-ret'
	
	set @begindate = dateadd(d, 1, @begindate)
end


set @begindate = '5/27/2013'
set @enddate = '5/31/2013'

select *
from scmanifests
where ManifestDate between @begindate and @enddate
and MfstCode in ('202-ret', '203-ret')

commit tran


