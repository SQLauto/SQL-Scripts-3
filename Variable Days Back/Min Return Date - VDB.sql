
declare @dtNow datetime
set @dtNow = dbo.GetCompanyDate(GetDate())


SELECT VDB.PublicationId
	, vdb.PeriodStartDate, datename(dw, vdb.PeriodStartDate) as [StartDayOfWeek]
	, vdb.PeriodLength
	, vdb.PeriodCutoffDay, datename(dw, vdb.PeriodCutoffDay) as [CutoffDayOfWeek]
	, CASE 
		WHEN ( datediff(day, (dateadd(day, ( (floor((datediff(day, VDB.periodStartDate, @dtNow)) / VDB.periodLength)) * VDB.periodLength), VDB.periodStartDate) ), @dtNow) + 1 ) >= VDB.PeriodCutoffDay 
		THEN dateadd(day, ((floor((datediff(day, VDB.periodStartDate, @dtNow)) / VDB.periodLength)) * VDB.periodLength), VDB.periodStartDate)
		ELSE dateadd(day, (VDB.periodLength * -1),(dateadd(day, ((floor((datediff(day, VDB.periodStartDate, @dtNow)) / VDB.periodLength)) * VDB.periodLength), VDB.periodStartDate)))
	END	AS MinDate
	FROM	scVariableDaysBack VDB
		JOIN	nsPublications P ON P.PublicationId = VDB.PublicationId