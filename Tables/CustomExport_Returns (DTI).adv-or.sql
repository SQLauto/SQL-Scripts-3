begin tran

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CustomExport_Returns]') AND type in (N'U'))
DROP TABLE [dbo].[CustomExport_Returns]
GO

create table CustomExport_Returns (
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
	, [PubDescription] nvarchar(128)
	, [PubCustom1] nvarchar(50)
	, [PubCustom2] nvarchar(50)
	, [PubCustom3] nvarchar(50)
	, [DrawDate] datetime
	, [ABCDrawDate] datetime
	, [DrawAmount] int
	, [RetFullAmount] int
	, [RetAmount] int
)

insert into CustomExport_Returns 
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
	, [PubDescription]
	, [PubCustom1]
	, [PubCustom2]
	, [PubCustom3]
	, [DrawDate]
	, [ABCDrawDate]
	, [DrawAmount]
	, [RetFullAmount]
	, [RetAmount]
)
exec CustomExport_Returns_Select '4/9/2013','4/30/2013', 1, 1

rollback tran
