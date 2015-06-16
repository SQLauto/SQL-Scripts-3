set nocount on

--| enable xp_cmdshell
	EXEC sp_configure 'show advanced options', 1
	GO
	RECONFIGURE
	GO
	EXEC sp_configure 'xp_cmdshell', 1
	GO
	RECONFIGURE
	GO

--|  create table
	if object_id('[lee_woo_prod].[dbo].[support_subscribers_prelim]', 'U') is not null
		drop table [lee_woo_prod].[dbo].[support_subscribers_prelim]
	GO

	CREATE table [lee_woo_prod].[dbo].[support_subscribers_prelim] (
		[UserId] varchar(50),
		[FirstName] varchar(50),
		[LastName] varchar(50),
		[Email] varchar(50),
		[CreatedDate] varchar(50),
		[PhoneNumber] varchar(50),
		[HouseNumber] varchar(50),
		[PreDirection] varchar(50),
		[StreetName] varchar(50),
		[StreetSuffix] varchar(50),
		[PostDirection] varchar(50),
		[City] varchar(50),
		[State] varchar(50),
		[PostalCode] varchar(50),
		[PostalCodeExtension] varchar(50),
		[PurchaseDate] varchar(50),
		[ExpirationDate] varchar(50),
		[CancelledDate] varchar(50),
		[OriginalPlanCode] varchar(50),
		[OriginalPlanName] varchar(50),
		[OriginalPlanRate] varchar(50),
		[Code] varchar(50),
		[HostPlan] varchar(50),
		[PlanActive] varchar(50),
		[SubscriberActive] varchar(50),
		[LinkedPlan] varchar(50),
		[ID_Provider] varchar(50),
		[IDP_ID] varchar(50),
		[IDP_ScreenName] varchar(50),
		[AccountNumber] varchar(50)
	)
	GO

--|  load files (loads the most recent file matching the naming convention
	if object_id('[lee_woo_prod].[dbo].[fileToLoad]', 'U') is not null
		drop table [lee_woo_prod].[dbo].[fileToLoad]
	
	create table [lee_woo_prod].[dbo].[fileToLoad] (
		filename nvarchar(500)
	)

	declare @path varchar(256) = 'dir c:\inetpub\ftproot\LocalUser\leewooftp\*subscribers*.txt'
	declare @cmd varchar(1024) =  @path + ' /A-D  /B /o-D'
	declare @file varchar(256)

	insert into [lee_woo_prod].[dbo].[fileToLoad]
	exec master.dbo.xp_cmdshell @cmd

	
	set @file = ( 
		select top 1 filename
		from [lee_woo_prod].[dbo].[fileToLoad]
		where [filename] <> ''
	)

	if @file = 'File Not Found'
	begin
		print 'Could not find a file matching the naming schema.  Aborting.'
	end
	else
	begin

		--select top 1 * 
		--from [lee_woo_prod].[dbo].[fileToLoad]
		--where [filename] <> ''

		declare @sql As VARCHAR(8000);
		SET @sql = '';

		set @sql = replace('
			bulk insert [lee_woo_prod].[dbo].[support_subscribers_prelim] from ''c:\inetpub\ftproot\LocalUser\leewooftp\[file_name_token]''
			with (
				fieldterminator=''\t''
				,rowterminator=''\n''
				,firstrow=2
			)', '[file_name_token]',@file)

		--set @sql = ( select top 1 replace('
		--	bulk insert [lee_woo_prod].[dbo].[support_subscribers_prelim] from ''c:\inetpub\ftproot\LocalUser\leewooftp\[file_name_token]''
		--	with (
		--		fieldterminator=''\t''
		--		,rowterminator=''\n''
		--		,firstrow=2
		--	)', '[file_name_token]',filename)
		--from [lee_woo_prod].[dbo].[fileToLoad]
		--where filename <> ''
		--)

		PRINT @sql;
		EXEC(@sql);



		set @sql = 'use [lee_woo_prod]; exec (''
			if object_id(''''[lee_woo_prod].[dbo].[support_subscribers_prelim_view]'''', ''''V'''') is not null
				drop view [support_subscribers_prelim_view]'')
			'
		print @sql
		exec(@sql)

		set @sql = 'use [lee_woo_prod]; exec (''
			create view [support_subscribers_prelim_view] as select tmp.*, tx.TrxReference as [CC Token (Reference Number)], cast(pc.CardExpirationMonth as varchar) + ''''/'''' + cast(pc.CardExpirationYear as varchar) as [Expire Date], tx.TrxPaymentMethod as [Last 4 CC Digits], CardHolderName as [Name on CC] 
				from [support_subscribers_prelim] tmp 
				left join [lee_woo_prod].[dbo].[SubscriberTransactions] tx on tmp.UserId = tx.UserId and datediff(minute, 0, tmp.PurchaseDate) = datediff(minute, 0, tx.TrxDate) 
				left join [lee_woo_prod].[dbo].[PaymentCards] pc on tmp.UserId = pc.UserId and tx.TrxPaymentMethod = pc.CardNumber''
				)'
		print @sql
		exec(@sql)

		print 'view created...'
		--set @sql = 'select * from [lee_woo_prod].[dbo].[support_subscribers_prelim_view]'
		--exec(@sql)

		--| header
		set @sql = 'bcp "select ''UserId'', ''FirstName'', ''LastName'', ''Email'', ''CreatedDate'', ''PhoneNumber'', ''HouseNumber'', ''PreDirection'', ''StreetName'', ''StreetSuffix'', ''PostDirection'', ''City'', ''State'', ''PostalCode'', ''PostalCodeExtension'', ''PurchaseDate'', ''ExpirationDate'', ''CancelledDate'', ''OriginalPlanCode'', ''OriginalPlanName'', ''OriginalPlanRate'', ''Code'', ''HostPlan'', ''PlanActive'', ''SubscriberActive'', ''LinkedPlan'', ''ID_Provider'', ''IDP_ID'', ''IDP_ScreenName'', ''AccountNumber'', ''CCToken_ReferenceNumber'', ''Expire_Date'', ''Last_4_CC_Digits'', ''Name_on_CC'' union all select * from [lee_woo_prod].[dbo].[support_subscribers_prelim_view]" queryout "c:\inetpub\ftproot\LocalUser\leewooftp\sync_' + replace(@file, '.txt', '.csv') + '" -Solympus -T -c -t,'
		--| no header
		--set @sql = 'bcp "select * from [lee_woo_prod].[dbo].[support_subscribers_prelim_view]" queryout ""c:\inetpub\ftproot\LocalUser\leewooftp\sync_' + replace(@file, '.txt', '.csv') + '" -Solympus -T -c -t,'
		
		print @sql
		exec xp_cmdshell @sql 
	end
/*
select tmp.*
	, tx.TrxReference as [CC Token (Reference Number)]
	, right('00' + cast(pc.CardExpirationMonth as varchar), 2)
	+ '/' + cast(pc.CardExpirationYear as varchar) as [Expire Date]
	, tx.TrxPaymentMethod as [Last 4 CC Digits]
	,CardHolderName as [Name on CC]
	
from [lee_woo_prod].[dbo].[support_subscribers_prelim] tmp
left join SubscriberTransactions tx
	on tmp.UserId = tx.UserId
	and datediff(minute, 0, tmp.PurchaseDate) = datediff(minute, 0, tx.TrxDate)
left join PaymentCards pc
	on tmp.UserId = pc.UserId
	and tx.TrxPaymentMethod = pc.CardNumber
*/