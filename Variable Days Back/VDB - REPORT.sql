--vdb report
declare @DateStart datetime
declare @DateEnd datetime
set @DateStart = '9/7/2013'
set @DateEnd = '9/9/2013'

;with cteDates
as (
	SELECT num.N-1 + @DateStart as [date]
	FROM dbo.NumberTable num
	WHERE num.N-1 + @DateStart <= @DateEnd
)
SELECT vdb.PublicationId
	, cte.date as [CurrentDate]
	, vdb.PeriodStartDate, datename(dw, vdb.PeriodStartDate) as [StartDayOfWeek]
	, vdb.PeriodLength
	, vdb.PeriodCutoffDay, datename(dw, vdb.PeriodCutoffDay) as [CutoffDayOfWeek]
	, CASE 
		WHEN ( datediff(day, (dateadd(day, ( (floor((datediff(day, vdb.periodStartDate, [date])) / vdb.periodLength)) * vdb.periodLength), vdb.periodStartDate) ), [date]) + 1 ) >= vdb.PeriodCutoffDay 
		THEN dateadd(day, ((floor((datediff(day, vdb.periodStartDate, [date])) / vdb.periodLength)) * vdb.periodLength), vdb.periodStartDate)
		ELSE dateadd(day, (vdb.periodLength * -1),(dateadd(day, ((floor((datediff(day, vdb.periodStartDate, [date])) / vdb.periodLength)) * vdb.periodLength), vdb.periodStartDate)))
	END	AS MinDate
FROM	scVariableDaysBack vdb
JOIN	nsPublications P 
	ON P.PublicationId = vdb.PublicationId
join cteDates cte
	on 1 = 1	
