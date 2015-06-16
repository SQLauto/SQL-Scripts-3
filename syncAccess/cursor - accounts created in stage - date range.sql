create table #tempUsers ( 
	  db nvarchar(50)
	, email nvarchar(256)
	, createdDate_UTC datetime
	, createdDate datetime
	, firstname nvarchar(128)
	, lastname nvarchar(128)
	, username nvarchar(256)
)

declare @sql nvarchar(max)
declare @db nvarchar(50)

declare db_cursor cursor for 
	select 'scripps_ca_stage' as [dbcatalog]
	union all select 'fed_elk_stage'
	union all select 'scripps_tcp_stage'
	union all select 'scripps_vcs_stage'
	union all select 'scripps_sast_stage'
	--union all select 'po_rg_stage'
	--union all select 'scripps_bsun_stage'

open db_cursor
fetch next from db_cursor into @db
while @@FETCH_STATUS = 0 
begin 

	set @sql = '
		insert into #tempUsers
		select ''' + @db + ''' as [db], m.Email
			, createddate as [CreatedDate_UTC]
			, dateadd(hour, -7, CreatedDate) as [CreatedDate (PST)]
			, u.FirstName, u.LastName, u.UserName
		from ' + @db + '..seMemberships m
		join ' + @db + '..seUsers u
			on m.UserID = u.UserId
		where dateadd(hour, -7, CreatedDate) between ''9/23/2014 13:30:00'' and ''9/24/2014 5:53:00''
		order by CreatedDate'
	
	print @sql
	exec(@sql)		
	fetch next from db_cursor into @db
end		

close db_cursor
deallocate db_cursor

select *
from #tempUsers
order by db, createdDate

drop table #tempUsers