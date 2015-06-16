declare @date datetime

declare finalizer_cursor cursor
for 
	select distinct DrawDate
	from scDraws d
	left join (
		select distinct ManifestDate
		from scManifests
		) as [m]
		on d.DrawDate = m.ManifestDate
	where m.ManifestDate is null

open finalizer_cursor
fetch next from finalizer_cursor into @date	
while @@FETCH_STATUS = 0
begin
	print 'finalizing for ' + convert(varchar, @date, 1)
	exec scManifestSequence_Finalizer @manifestdate=@date	
	
	fetch next from finalizer_cursor into @date	
end


close finalizer_cursor
deallocate finalizer_cursor