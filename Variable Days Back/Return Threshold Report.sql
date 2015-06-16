--vdb report
declare @DateStart datetime
declare @DateEnd datetime
set @DateStart = '7/17/2014'
set @DateEnd = '7/17/2014'

declare @altcutoff int
set @altcutoff = 5

;with cteDates
as (
	SELECT num.N-1 + @DateStart as [date]
	FROM dbo.NumberTable num
	WHERE num.N-1 + @DateStart <= @DateEnd
)
select PubShortName
	, convert(varchar, PeriodStartDate, 101) as PeriodStartDate
	, PeriodLength
	, PeriodCutoffDay
	, '    '
	--, dbo.scOverThreshhold( CurrentDate,  )	
	, convert(varchar, CurrentDate, 101) as [CurrentDate]
	, convert(varchar, MinDate, 101) as [ReturnThresholdDate]
	, DATEDIFF(d, MinDate, CurrentDate) as [DaysBackReturnsAllowed]
	, convert(varchar, dateadd(d, 
		( DATEDIFF(d, PeriodStartDate, CurrentDate) / PeriodLength ) * PeriodLength
		, PeriodStartDate ), 101)
		as [CurrentPeriodStartDate]--[ThisPeriodStart ( Add PeriodNum * PeriodLength to PeriodStart )]
	, DayInPeriod - 1 as [DayInPeriod]--1 based
	, PeriodCutoffDay - 1 as [PeriodCutoffDay]--1 based
	, dateadd(d, ( PeriodCutoffDay - 1 ), 
		dateadd(d, 
			( DATEDIFF(d, PeriodStartDate, CurrentDate) / PeriodLength ) * PeriodLength
			, PeriodStartDate )
		) as [PeriodDateCutoff]
	, DATENAME( dw, dateadd(d, ( PeriodCutoffDay - 1 ), 
		dateadd(d, 
			( DATEDIFF(d, PeriodStartDate, CurrentDate) / PeriodLength ) * PeriodLength
			, PeriodStartDate )
		) ) as [PeriodDateCutoffDay]
from (
	SELECT vdb.PublicationId, P.PubShortName
		, vdb.PeriodStartDate --as [OriginalPeriodStartDateSetting]
		, vdb.PeriodLength
		, vdb.PeriodCutoffDay
		, cte.date as [CurrentDate]
		, CASE 
			WHEN ( datediff(day, (dateadd(day, ( (floor((datediff(day, vdb.periodStartDate, [date])) / vdb.periodLength)) * vdb.periodLength), vdb.periodStartDate) ), [date]) + 1 ) >= vdb.PeriodCutoffDay 
			THEN dateadd(day, ((floor((datediff(day, vdb.periodStartDate, [date])) / vdb.periodLength)) * vdb.periodLength), vdb.periodStartDate)
			ELSE dateadd(day, (vdb.periodLength * -1),(dateadd(day, ((floor((datediff(day, vdb.periodStartDate, [date])) / vdb.periodLength)) * vdb.periodLength), vdb.periodStartDate)))
		END	AS MinDate
		, ( datediff(day, (dateadd(day, ( (floor((datediff(day, vdb.periodStartDate, [date])) / vdb.periodLength)) * vdb.periodLength), vdb.periodStartDate) ), [date]) + 1 ) as [DayInPeriod]
	FROM	scVariableDaysBack vdb
	JOIN	nsPublications P 
		ON P.PublicationId = vdb.PublicationId
	join cteDates cte
		on 1 = 1
	--where PubName in ('Longmont Times Call', 'Reporter-Herald', 'Coloradoan', 'Gazette', 'Canon City Record' )		
) prelim
