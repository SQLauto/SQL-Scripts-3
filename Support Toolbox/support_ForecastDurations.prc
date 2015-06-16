IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_ForecastDurations]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_ForecastDurations]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[support_ForecastDurations]
	  @daysBack int = 7
AS
BEGIN
	declare @forecastStarted int
	declare @forecastCompleted int
	
	select ForecastId = identity(int,1,1)
		, sltimestamp as [ForecastStartTime]
	into #forecastStartTimes
	from syncSystemLog
	where LogMessage = 'ForecastEngine: Forecasting start'
	and SLTimeStamp > dateadd(d, -1*@daysBack, convert(varchar, getdate(),1))
	order by SLTimeStamp asc
	set @forecastStarted = @@rowcount

	select ForecastId = identity(int,1,1)
		, sltimestamp as [ForecastEndTime]
	into #forecastEndTimes	
	from syncSystemLog
	where LogMessage = 'ForecastEngine: Forecasting complete'
	and SLTimeStamp > dateadd(d, -1*@daysBack, convert(varchar, getdate(),1))
	order by SLTimeStamp asc
	set @forecastCompleted = @@rowcount

	select ForecastId = identity(int,1,1)
		, replace(logmessage, 'ForecastEngine: Final count: ', '') as [ForecastFinalCount]
	into #forecastCounts
	from syncSystemLog
	where LogMessage like 'ForecastEngine: Final count: %'
	and SLTimeStamp > dateadd(d, -1*@daysBack, convert(varchar, getdate(),1))
	order by SLTimeStamp asc

	--if @forecastStarted <> @forecastCompleted
	--begin
	--	print 'Cannot determine forecast durations. Forecasts started: ' + cast(@forecastStarted as nvarchar)
	--		+ '.  Forecasts completed: ' + cast(@forecastCompleted as nvarchar) + '.'
	--end
	--else 
	--begin
			select s.ForecastId, s.ForecastStartTime, e.ForecastEndTime, c.ForecastFinalCount
				, cast( DATEDIFF(	SECOND, ForecastStartTime, ForecastEndTime) / 3600 as varchar)
				+ 'h ' + 
				+ right('00' + cast( DATEDIFF(	SECOND, ForecastStartTime, ForecastEndTime) % 3600 / 60 as varchar), 2)
				+ 'm ' + 
				+ right('00' + cast( DATEDIFF(	SECOND, ForecastStartTime, ForecastEndTime) % 60 as varchar), 2)
				+ 's ' AS [Duration]
			from #forecastStartTimes s
			join #forecastEndTimes e
				on s.ForecastId = e.ForecastId	
			left join #forecastCounts c
				on s.ForecastId = c.ForecastId
	--end
	
	--|cleanup
	drop table #forecastStartTimes
	drop table #forecastEndTimes
	drop table #forecastCounts	
	
END
GO	

exec support_ForecastDurations @daysBack=7
GO