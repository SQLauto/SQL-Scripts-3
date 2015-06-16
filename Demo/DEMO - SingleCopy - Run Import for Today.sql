	update scmanifestload
	set date = cast( datepart(yyyy, getdate()) as varchar(4) )
		+ cast( right( '00' + cast( datepart(m, getdate()) as varchar(2) ), 2 ) as varchar(2) )
		+ cast( right( '00' + cast( datepart(d, getdate()) as varchar(2) ), 2 ) as varchar(2) )

	exec scmanifest_data_load