IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_RunForecastByDateRange]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_RunForecastByDateRange]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[support_RunForecastByDateRange]
	  @beginDate datetime
	, @endDate datetime
	, @overwrite nvarchar(5) = 'False'
AS
BEGIN
	set nocount on
	
		if not ( @overwrite = 'True'
			 or @overwrite = 'False' )
		begin
			print '@overwrite must be ''True'' or ''False'''
			return
		end
		else
		begin
			print 'forecasting for dates ' + convert(varchar, @beginDate, 1)
				+ ' through ' + convert(varchar, @endDate, 1)
		end

		update merc_ControlPanel
		set AttributeValue = case AttributeName
			when 'BeginDate' then convert(varchar, @beginDate, 1)
			when 'EndDate' then convert(varchar, @endDate, 1)
			when 'LoggingLevel' then '0'
			when 'LogFile' then NULL
			when 'DiagnosticOutput' then 'False'
			when 'EngineRequest' then 'true'
			when 'UserName' then 'Scheduled Job'
			when 'UserId' then '-1'
			when 'OverwriteUserEdits' then @overwrite
			else AttributeValue
			end
		where AppLayer = 'ForecastEngine'
END
GO	

/*
exec support_RunForecastByDateRange @beginDate='10/3/2012', @endDate='10/3/2012', @overwrite='True'
GO
*/