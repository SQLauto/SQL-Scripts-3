
	declare @userId int
	declare @sql nvarchar(1000)

	declare crsr cursor
	for
		select s.UserId
			--, m.email
			--, m.createddate
			--, s.firstname, s.lastname
		from subscribers s
		join sememberships m
			on s.userid = m.userid
		where datediff(d, createddate, '4/8/2015') = 0
		--and createddate > '2015-04-06 17:59:58.817'
		and s.Userid <> 10
		order by createddate desc

	open crsr
	fetch next from crsr into @userId
	while @@fetch_status = 0
	begin
		set @sql = 'exec SyncAccess_po_dth_prod.Subscribers_Delete ' + cast(@userId as varchar)
		exec(@sql)

		set @sql = 'exec SyncAccess_po_dth_prod.seUsers_Delete ' + cast(@userId as varchar)
		exec(@sql)
		fetch next from crsr into @userId
	end

	close crsr
	deallocate crsr

	select *
	from seusers

