exec [dbo].[scForecastExport_SelectWeek] '3/7/2013', '3/13/2013', 1, 1, 1, 1


CREATE TABLE scForecastExport_SelectWeek_ResultsToTable
( 
	  [ATName] nvarchar(50)
	, [ATDescription] nvarchar(128)
	, [Code] nvarchar(20)
	, [Name] nvarchar(50)
	, [Description] nvarchar(128)
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
	, [APCustom1] nvarchar(50)
	, [APCustom2] nvarchar(50)
	, [APCustom3] nvarchar(50)
	, [PubName] nvarchar(50)
	, [PubShortName] nvarchar(5)
	, [PubDescription] nvarchar(128)
	, [PubCustom1] nvarchar(50)
	, [PubCustom2] nvarchar(50)
	, [PubCustom3] nvarchar(50)
	, [StartDate] datetime
	, [DrawAmount0] int
	, [DrawAmount1] int
	, [DrawAmount2] int
	, [DrawAmount3] int
	, [DrawAmount4] int
	, [DrawAmount5] int
	, [DrawAmount6] int
)