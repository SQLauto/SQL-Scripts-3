begin tran

declare @begindate datetime
declare @enddate datetime
declare @mfstCode nvarchar(20)

set @mfstCode = 'a0104'

--| get the date range of manifests that need to be finalized

select @begindate = dateadd(d, 1, max(manifestdate))
	, @enddate = convert(varchar, getdate(), 1)
from scmanifests
where mfstcode = @mfstCode

if @begindate = @enddate
begin
	print 'finalizing manifest ' + @mfstCode + ' for ' + convert(varchar, @beginDate, 1)
	exec support_scmanifestsequence_finalizer_bymanifest @begindate, @mfstCode
end
else
begin
	while @begindate <> @enddate
	begin
		print 'finalizing manifest ' + @mfstCode + ' for ' + convert(varchar, @beginDate, 1)
		exec support_scmanifestsequence_finalizer_bymanifest @begindate, @mfstCode
		
		set @begindate = dateadd(d, 1, @begindate)
	end
end

commit tran