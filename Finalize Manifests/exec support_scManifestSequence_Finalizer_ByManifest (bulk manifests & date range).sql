begin tran

declare @begindate datetime
declare @enddate datetime
declare @mfstcode nvarchar(25)

set @begindate = '11/13/2013'
set @enddate = '11/13/2013'


	if @begindate = @enddate
	begin
		exec support_scmanifestsequence_finalizer_bymanifest @begindate, @mfstCode
	end
	else
	begin
		while @begindate <> @enddate
		begin

			declare manifest_cursor cursor
			for 
				SELECT 'c-SC1201A' as [mtcode]
			 
			open manifest_cursor
			fetch next from manifest_cursor into @mfstcode
			while @@FETCH_STATUS = 0
			begin
				print 'finalizing manifest ' + @mfstCode + ' for ' + convert(varchar, @beginDate, 1)
				exec support_scmanifestsequence_finalizer_bymanifest @begindate, @mfstCode
				fetch next from manifest_cursor into @mfstcode
			end
			
			close manifest_cursor
			deallocate manifest_cursor
			
			set @begindate = dateadd(d, 1, @begindate)
		end
	end	

rollback tran

