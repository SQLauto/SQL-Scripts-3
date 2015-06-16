
begin tran

	update scdraws
	set retexportlastamt = 28
	where drawid = 124970

	declare @CustomExport_Returns_Select_DSI_ResultsToTable table (
		 [DrawID] int
		, [ATName] nvarchar(50)
		, [ATDescription] nvarchar(128)
		, [AccountID] int
		, [Code]  nvarchar(20)
		, [Name] nvarchar(50)
		, [Description] nvarchar(50)
		, [Address] nvarchar(128)
		, [City] nvarchar(50)
		, [StateProvince] nvarchar(5)
		, [PostalCode] nvarchar(15)
		, [Country] nvarchar(50)
		, [Contact] nvarchar(50)
		, [Phone] nvarchar(20)
		, [Hours] nvarchar(20)
		, [SpecialInstructions] nvarchar(256)
		, [Custom1] nvarchar(50)
		, [Custom2] nvarchar(50)
		, [Custom3] nvarchar(50)
		, [Notes] nvarchar(256)
		, [IsRollup] int
		, [APCustom1] nvarchar(50)
		, [APCustom2] nvarchar(50)
		, [APCustom3] nvarchar(50)
		, [PublicationID] int
		, [PubName] nvarchar(50)
		, [PubShortName] nvarchar(5)
		, [Edition] nvarchar(5)
		, [PubDescription] nvarchar(128)
		, [PubCustom1] nvarchar(50)
		, [PubCustom2] nvarchar(50)
		, [PubCustom3] nvarchar(50)
		, [DrawDate] datetime
		, [DrawAmount] int
		, [RetFullAmount] int
		, [RetAmount] int
	)

	insert into @CustomExport_Returns_Select_DSI_ResultsToTable 
	(
		 [DrawID]
		, [ATName]
		, [ATDescription]
		, [AccountID]
		, [Code]
		, [Name]
		, [Description]
		, [Address]
		, [City]
		, [StateProvince]
		, [PostalCode]
		, [Country]
		, [Contact]
		, [Phone]
		, [Hours]
		, [SpecialInstructions]
		, [Custom1]
		, [Custom2]
		, [Custom3]
		, [Notes]
		, [IsRollup]
		, [APCustom1]
		, [APCustom2]
		, [APCustom3]
		, [PublicationID]
		, [PubName]
		, [PubShortName]
		, [Edition] 
		, [PubDescription]
		, [PubCustom1]
		, [PubCustom2]
		, [PubCustom3]
		, [DrawDate]
		, [DrawAmount]
		, [RetFullAmount]
		, [RetAmount]
	)
	exec CustomExport_Returns_Select_DSI '5/23/2015', '5/23/2015'

	select *
	from @CustomExport_Returns_Select_DSI_ResultsToTable
	where code = '80003195'

rollback tran
