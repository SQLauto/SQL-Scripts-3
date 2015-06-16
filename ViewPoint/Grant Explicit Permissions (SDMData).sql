use sdmdata
begin tran
declare @name varchar(256)
	,@type char(2)
	,@sql varchar(255)

declare sysobjects_cursor cursor
for 
	select [name], type
	from sdmdata..sysobjects
	where type in ('p', 'u')

open sysobjects_cursor
fetch next from sysobjects_cursor into @name, @type
while @@fetch_status = 0
begin
	select @sql = case @type
		when 'p' then 'grant execute on dbo.' + @name
		when 'u' then 'grant select, update, insert on dbo.' + @name
	end

	exec(@sql + ' to dmconfig')
	exec(@sql + ' to dmweb')

fetch next from sysobjects_cursor into @name, @type
end

close sysobjects_cursor
deallocate sysobjects_cursor

rollback tran