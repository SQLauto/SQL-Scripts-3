IF OBJECT_ID('dbo.CustomExport_Forecast_Select_FullDraw_Results', 'U') IS NOT NULL
  DROP TABLE dbo.CustomExport_Forecast_Select_FullDraw_Results
GO

CREATE TABLE dbo.CustomExport_Forecast_Select_FullDraw_Results 
(
	  [code] nvarchar(20)
	, [PubShortName] nvarchar(5)
	, [StartDate] datetime
	, [DrawAmount0] int
	, [PrevDrawAmount0] int
	, [DrawChange0] int
	, [DrawAmount1] int
	, [PrevDrawAmount1] int
	, [DrawChange1] int
	, [DrawAmount2] int
	, [PrevDrawAmount2] int
	, [DrawChange2] int
	, [DrawAmount3] int
	, [PrevDrawAmount3] int
	, [DrawChange3] int
	, [DrawAmount4] int
	, [PrevDrawAmount4] int
	, [DrawChange4] int
	, [DrawAmount5] int
	, [PrevDrawAmount5] int
	, [DrawChange5] int
	, [DrawAmount6] int
	, [PrevDrawAmount6] int
	, [DrawChange6] int	
)
GO

GRANT SELECT ON [dbo].[CustomExport_Forecast_Select_FullDraw_Results] TO [nsUser]
GO
	
