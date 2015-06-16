begin tran

declare @uploaded datetime
declare @prevuploaded datetime

create table #upload ( diff_in_seconds int )

declare upload_cursor cursor
for
	select dropuploaded
	from scmanifesttransferdrops
	where manifesttransferid = 20311
	order by dropuploaded asc
open upload_cursor
fetch next from upload_cursor into @uploaded
while @@fetch_status = 0
begin
	if @prevuploaded is null
	begin
		set @prevuploaded = @uploaded
		fetch next from upload_cursor into @uploaded
	end

	insert into #upload 
	select datediff(second, @prevuploaded, @uploaded)

	set @prevuploaded = @uploaded
	
	fetch next from upload_cursor into @uploaded
end

close upload_cursor
deallocate upload_cursor

select *
from #upload

drop table #upload

rollback tran
