declare @thresholdDate datetime


set @thresholdDate = '8/30/2010'

	declare @name nvarchar(100)
	select @name = db_name()

declare @cmd varchar(2048)
declare @sql varchar(2048)

		set @sql = 'select * from ' + @name + '..scInvoices where InvoiceDate < ''' + convert(varchar, @thresholdDate, 101) + ''''

		set @cmd = 'bcp "' + @sql + '" queryout "C:\Program Files\Syncronex\Support\DataArchive\scInvoices_' + 
		+ right('00' + cast(datepart(mm, getdate()) as varchar),2)
		+ right('00' + cast(datepart(DD, getdate()) as varchar),2)
		+ right('0000' + cast(datepart(yyyy, getdate()) as varchar),4)
		+ '_'
		+ right('00' + cast(datepart(hh, getdate()) as varchar),2)
		+ right('00' + cast(datepart(minute, getdate()) as varchar),2)
		+ right('0000' + cast(datepart(ss, getdate()) as varchar),2)
		+ '.txt" -c -U nsadmin -P nsadmin -t^|'

print @cmd
exec xp_cmdshell @cmd

