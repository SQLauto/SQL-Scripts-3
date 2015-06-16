IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[scDefaultDraws_UPDATE]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[scDefaultDraws_UPDATE]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[scDefaultDraws_UPDATE]
	@CompanyID	            int,
	@DistributionCenterID	int,
	@AccountID	            int,
	@PublicationID	        int,
    @SunDraw                int,
    @MonDraw                int,
    @TueDraw                int,
    @WedDraw                int,
    @ThuDraw                int,
    @FriDraw                int,
    @SatDraw                int,
    @SunRate                money,
    @MonRate                money,
    @TueRate                money,
    @WedRate                money,
    @ThuRate                money,
    @FriRate                money,
    @SatRate                money,
    @SunMinDraw			int,
    @MonMinDraw			int,
    @TueMinDraw			int,
    @WedMinDraw			int,
    @ThuMinDraw			int,
    @FriMinDraw			int,
    @SatMinDraw			int,
    @SunMaxDraw			int,
    @MonMaxDraw			int,
    @TueMaxDraw			int,
    @WedMaxDraw			int,
    @ThuMaxDraw			int,
    @FriMaxDraw			int,
    @SatMaxDraw			int,
    @SunAllowReturn		tinyint,
    @MonAllowReturn		tinyint,
    @TueAllowReturn		tinyint,
    @WedAllowReturn		tinyint,
    @ThuAllowReturn		tinyint,
    @FriAllowReturn		tinyint,
    @SatAllowReturn		tinyint,
    @SunAllowAdj		tinyint,
    @MonAllowAdj		tinyint,
    @TueAllowAdj		tinyint,
    @WedAllowAdj		tinyint,
    @ThuAllowAdj		tinyint,
    @FriAllowAdj		tinyint,
    @SatAllowAdj		tinyint,
    @SunAllowForecast		tinyint,
    @MonAllowForecast		tinyint,
    @TueAllowForecast		tinyint,
    @WedAllowForecast		tinyint,
    @ThuAllowForecast		tinyint,
    @FriAllowForecast		tinyint,
    @SatAllowForecast		tinyint

AS

/*=========================================================
     scDefaultDraws_UPDATE
        Update the draw. Takes all 7 draw/rate values and
     updates using a "last in wins" approach to conflict
     resolution


     Date:   11/30/2003
     Author: robcom

     Change History
     -------------------------------------------------------
     Date    Author      Reference       Description
     -------------------------------------------------------
==========================================================*/
BEGIN
set nocount on

BEGIN TRANSACTION

	;with cteDefaultDraw
	as (    
		select @AccountID as [AccountID], @PublicationID as [PublicationID]
			, 1 as [DrawWeekday]
			, @SunDraw as [NewDrawAmount]
			, @SunRate as [NewDrawRate]
			, @SunMinDraw as [NewForecastMinDraw]
			, @SunMaxDraw as [NewForecastMaxDraw]
			, @SunAllowAdj as [NewAllowAdjustments]
			, @SunAllowReturn as [NewAllowReturns]
			, @SunAllowForecast as [NewAllowForecasting]
		from scDefaultDraws
		where AccountId = @AccountID
		and PublicationId = @PublicationID
		and DrawWeekday = 1  
		union all
		select cte.AccountID, cte.PublicationID
			, cte.DrawWeekday + 1
			, case 
				when dd.DrawWeekday = 2 and @MonDraw >= 0 then @MonDraw 
				when dd.DrawWeekday = 3 and @TueDraw >= 0 then @TueDraw
				when dd.DrawWeekday = 4 and @WedDraw >= 0 then @WedDraw
				when dd.DrawWeekday = 5 and @ThuDraw >= 0 then @ThuDraw
				when dd.DrawWeekday = 6 and @FriDraw >= 0 then @FriDraw
				when dd.DrawWeekday = 7 and @SatDraw >= 0 then @SatDraw
				else dd.DrawAmount
				end as [NewDrawAmount]
			, case dd.DrawWeekday 
				when 2 then @MonRate
				when 3 then @TueRate
				when 4 then @WedRate
				when 5 then @ThuRate
				when 6 then @FriRate
				when 7 then @SatRate
				else cast(dd.DrawRate as money) end as [NewDrawRate]		
			, case dd.DrawWeekday 
				when 2 then @MonMinDraw 
				when 3 then @TueMinDraw
				when 4 then @WedMinDraw
				when 5 then @ThuMinDraw
				when 6 then @FriMinDraw
				when 7 then @SatMinDraw
				else dd.ForecastMinDraw end as [NewForecastMinDraw]
			, case dd.DrawWeekday 
				when 2 then @MonMaxDraw 
				when 3 then @TueMaxDraw
				when 4 then @WedMaxDraw
				when 5 then @ThuMaxDraw
				when 6 then @FriMaxDraw
				when 7 then @SatMaxDraw
				else dd.ForecastMaxDraw end as [NewForecastMaxDraw]
			, case dd.DrawWeekday 
				when 2 then @MonAllowAdj
				when 3 then @TueAllowAdj
				when 4 then @WedAllowAdj
				when 5 then @ThuAllowAdj
				when 6 then @FriAllowAdj
				when 7 then @SatAllowAdj
				else dd.AllowAdjustments end as [NewAllowAdjustments]
			, case dd.DrawWeekday 
				when 2 then @MonAllowReturn
				when 3 then @TueAllowReturn
				when 4 then @WedAllowReturn
				when 5 then @ThuAllowReturn
				when 6 then @FriAllowReturn
				when 7 then @SatAllowReturn
				else dd.AllowReturns end as [NewAllowReturns]		
			, case dd.DrawWeekday 
				when 2 then @MonAllowForecast
				when 3 then @TueAllowForecast
				when 4 then @WedAllowForecast
				when 5 then @ThuAllowForecast
				when 6 then @FriAllowForecast
				when 7 then @SatAllowForecast
				else dd.AllowForecasting end as [NewAllowForecasting]							
		from cteDefaultDraw cte
		join scDefaultDraws dd
			on cte.AccountID = dd.AccountID
			and cte.PublicationID = dd.PublicationID
			and cte.DrawWeekday + 1 = dd.DrawWeekday
		where cte.DrawWeekday + 1 <= 7
	)
	select 1 as [CompanyID], 1 as [DistributionCenterID]
		, dd.AccountID, dd.PublicationID, dd.DrawWeekday
		, GETDATE() as [DrawHistoryDate]
		, dd.DrawAmount
		, cte.NewDrawAmount
		, dd.DrawRate
		, cte.NewDrawRate
		, 2 as [ChangeTypeId] --|  ChangeType 2=User Edit
		, NewForecastMinDraw
		, NewForecastMaxDraw
		, NewAllowAdjustments
		, NewAllowReturns
		, NewAllowForecasting
	into #dd	
	from cteDefaultDraw cte
	join scDefaultDraws dd
		on cte.AccountID = dd.AccountID
		and cte.PublicationID = dd.PublicationID
		and cte.DrawWeekday = dd.DrawWeekday
	where dd.DrawAmount <> cte.NewDrawAmount
	or dd.DrawRate <> cte.NewDrawRate
	or dd.ForecastMinDraw <> cte.NewForecastMinDraw
	or dd.ForecastMaxDraw <> cte.NewForecastMaxDraw
	or dd.AllowAdjustments <> cte.NewAllowAdjustments
	or dd.AllowReturns <> cte.NewAllowReturns
	or dd.AllowForecasting <> cte.NewAllowForecasting

	insert into scDefaultDrawHistory ( CompanyID, DistributionCenterID, AccountID, PublicationID, DrawWeekday, DrawHistoryID, DrawHistoryDate, DrawHistOldDraw, DrawHistNewDraw, DrawHistOldRate, DrawHistNewRate, ChangeTypeID )
	select CompanyID, DistributionCenterID, tmp.AccountID, tmp.PublicationID, tmp.DrawWeekday, NextID, DrawHistoryDate, DrawAmount, NewDrawAmount, DrawRate, NewDrawRate, ChangeTypeID
	from #dd tmp
	join (
		select dd.AccountID, dd.PublicationID, dd.DrawWeekday, isnull( MAX(DrawHistoryID), 0) + 1 as [NextID]
		from scDefaultDraws dd
		left join scDefaultDrawHistory dh
			on dd.AccountID = dh.AccountID
			and dd.PublicationID = dh.PublicationID
			and dd.DrawWeekday = dh.DrawWeekday
		where dd.AccountID = @AccountID
		and dd.PublicationID = @PublicationID
		group by dd.AccountID, dd.PublicationID, dd.DrawWeekday
	) dh
		on tmp.AccountID = dh.AccountID
		and tmp.PublicationID = dh.PublicationID
		and tmp.DrawWeekday = dh.DrawWeekday

	update scDefaultDraws
	set DrawAmount = tmp.NewDrawAmount
		, DrawRate = tmp.NewDrawRate
		, ForecastMinDraw = tmp.NewForecastMinDraw
		, ForecastMaxDraw = tmp.NewForecastMaxDraw
		, AllowAdjustments = tmp.NewAllowAdjustments
		, AllowReturns = tmp.NewAllowReturns
		, AllowForecasting = tmp.NewAllowForecasting
	from scDefaultDraws dd
	join #dd tmp
		on dd.AccountID = tmp.AccountID
		and dd.PublicationID = tmp.PublicationID
		and dd.DrawWeekday = tmp.DrawWeekday


COMMIT TRANSACTION

END




GO


GRANT EXECUTE ON [dbo].[scDefaultDraws_UPDATE] TO [nsUser]
GO
