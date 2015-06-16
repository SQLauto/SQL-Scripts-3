

declare @beginDate nvarchar(10)
declare @endDate nvarchar(10)

set @beginDate = '5/16/2011'
set @endDate = '5/19/2011'

	update merc_ControlPanel
	set AttributeValue = case AttributeName
		when 'BeginDate' then @beginDate
		when 'EndDate' then @endDate
		when 'LoggingLevel' then '0'
		when 'LogFile' then NULL
		when 'DiagnosticOutput' then 'False'
		when 'EngineRequest' then 'true'
		when 'UserName' then 'Scheduled Job'
		when 'UserId' then '-1'
		when 'OverwriteUserEdits' then 'False'
		else AttributeValue
		end
	where AppLayer = 'ForecastEngine'