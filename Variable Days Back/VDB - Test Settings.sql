
declare @DateStart datetime
declare @DateEnd datetime
set @DateStart = '4/15/2013'
set @DateEnd = '5/15/2013'

--|vdb settings
declare @PeriodStartDate datetime
declare @PeriodLength int
declare @PeriodCutoffDate int

set @PeriodStartDate = '4/15/2013'
set @PeriodLength = 14
set @PeriodCutoffDate = 3

;with vdb
as (
	select 
		case when datediff(d, getdate(), dt.date) = 0 
			then '** Today **'
			else convert(varchar, dt.date, 101) end as [Date]
	, convert(varchar, dt.date, 101) as [CurrentDate]
	, datename(dw,dt.date) as [CurrentDate_DayofWeek]
	, convert(varchar, @PeriodStartDate, 101) as [PeriodStartDate]
	, datename(dw, @PeriodStartDate) as [StartDayOfWeek]
	, @PeriodLength as [PeriodLength]
	, @PeriodCutoffDate as [PeriodCutoffDate]
	, datename(dw, @PeriodCutoffDate) as [CutoffDayOfWeek]
	, convert(varchar, CASE 
		WHEN ( datediff(day, (dateadd(day, ( (floor((datediff(day, @PeriodStartDate, [date])) / @periodLength)) * @periodLength), @PeriodStartDate) ), [date]) + 1 ) >= @PeriodCutoffDate 
		THEN dateadd(day, ((floor((datediff(day, @PeriodStartDate, [date])) / @periodLength)) * @periodLength), @PeriodStartDate)
		ELSE dateadd(day, (@periodLength * -1),(dateadd(day, ((floor((datediff(day, @PeriodStartDate, [date])) / @periodLength)) * @periodLength), @PeriodStartDate)))
	END, 101)	AS MinDate
	, datename(dw, CASE 
		WHEN ( datediff(day, (dateadd(day, ( (floor((datediff(day, @PeriodStartDate, [date])) / @periodLength)) * @periodLength), @PeriodStartDate) ), [date]) + 1 ) >= @PeriodCutoffDate 
		THEN dateadd(day, ((floor((datediff(day, @PeriodStartDate, [date])) / @periodLength)) * @periodLength), @PeriodStartDate)
		ELSE dateadd(day, (@periodLength * -1),(dateadd(day, ((floor((datediff(day, @PeriodStartDate, [date])) / @periodLength)) * @periodLength), @PeriodStartDate)))
	END ) as [MinDate_DayOfWeek]
FROM (
	SELECT num.N-1 + @DateStart as [date]
	FROM dbo.NumberTable num
	WHERE num.N-1 + @DateStart <= @DateEnd
	) dt
)
select Date, CurrentDate_DayofWeek, vdb.MinDate, vdb.MinDate_DayOfWeek
	, datediff(d, CurrentDate, MinDate)
	,'' as [                       ]
	, vdb.PeriodLength, vdb.PeriodCutoffDate, CutoffDayOfWeek
from vdb
