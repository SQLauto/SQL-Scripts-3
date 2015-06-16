declare @begindate as datetime
set @begindate = CONVERT(varchar, getdate(), 1)

;with cteThresholds_VDB_Pub as (
	SELECT
		0 as [counter]
		, @begindate as [Date]  
		, vdb.PublicationId
		, null as [AccountTypeId]
		, CASE WHEN ( datediff(day, (dateadd(day, ( (floor((datediff(day, vdb.periodStartDate, @begindate)) / vdb.periodLength)) * vdb.periodLength), vdb.periodStartDate) ), @begindate) + 1 ) >= vdb.PeriodCutoffDay 
	THEN	dateadd(day, ((floor((datediff(day, vdb.periodStartDate, @begindate)) / vdb.periodLength)) * vdb.periodLength), vdb.periodStartDate)
	ELSE dateadd(day, (vdb.periodLength * -1),(dateadd(day, ((floor((datediff(day, vdb.periodStartDate, @begindate)) / vdb.periodLength)) * vdb.periodLength), vdb.periodStartDate)))
	END	AS MinDate
	
	FROM	scVariableDaysBack vdb
	join nsPublications p
		on vdb.PublicationId = p.PublicationID
	
	union all 
	
	select [counter] + 1 
		, dateadd(d, -1*([counter]+1), @begindate)
		, vdb.PublicationId
		, null as [AccountTypeId]
		, CASE WHEN ( datediff(day, (dateadd(day, ( (floor((datediff(day, vdb.periodStartDate, dateadd(d, -1*([counter]+1), @begindate))) / vdb.periodLength)) * vdb.periodLength), vdb.periodStartDate) ), dateadd(d, -1*([counter]+1), @begindate)) + 1 ) >= vdb.PeriodCutoffDay 
	THEN	dateadd(day, ((floor((datediff(day, vdb.periodStartDate, dateadd(d, -1*([counter]+1), @begindate))) / vdb.periodLength)) * vdb.periodLength), vdb.periodStartDate)
	ELSE dateadd(day, (vdb.periodLength * -1),(dateadd(day, ((floor((datediff(day, vdb.periodStartDate, dateadd(d, -1*([counter]+1), @begindate))) / vdb.periodLength)) * vdb.periodLength), vdb.periodStartDate)))
	END	AS MinDate
	from scVariableDaysBack vdb
	join nsPublications p
		on vdb.PublicationId = p.PublicationID
	join cteThresholds_VDB_Pub cte
		on vdb.PublicationId = cte.PublicationId
	
	where [counter] + 1 < 42

)
, cteThresholds_VDB_AcctType as (
	SELECT
		0 as [counter]
		, @begindate as [Date]  
		, null as [PublicationId]
		, vdb.AccountTypeId
		,	CASE WHEN ( datediff(day, (dateadd(day, ( (floor((datediff(day, VDB.periodStartDate, @begindate)) / VDB.periodLength)) * VDB.periodLength), VDB.periodStartDate) ), @begindate) + 1 ) >= VDB.PeriodCutoffDay 
	THEN	dateadd(day, ((floor((datediff(day, VDB.periodStartDate, @begindate)) / VDB.periodLength)) * VDB.periodLength), VDB.periodStartDate)
	ELSE dateadd(day, (VDB.periodLength * -1),(dateadd(day, ((floor((datediff(day, VDB.periodStartDate, @begindate)) / VDB.periodLength)) * VDB.periodLength), VDB.periodStartDate)))
	END	AS MinDate
	FROM	scVariableDaysBack VDB
	JOIN	dd_scAccountTypes A ON A.AccountTypeID = VDB.AccountTypeId

	union all 
	
	select [counter] + 1 
		, dateadd(d, -1*([counter]+1), dateadd(d, -1*(counter+1), @begindate))
		, null as [PublicationId]
		, vdb.AccountTypeId
			,	CASE WHEN ( datediff(day, (dateadd(day, ( (floor((datediff(day, VDB.periodStartDate, dateadd(d, -1*(counter+1), @begindate))) / VDB.periodLength)) * VDB.periodLength), VDB.periodStartDate) ), dateadd(d, -1*(counter+1), @begindate)) + 1 ) >= VDB.PeriodCutoffDay 
		THEN	dateadd(day, ((floor((datediff(day, VDB.periodStartDate, dateadd(d, -1*(counter+1), @begindate))) / VDB.periodLength)) * VDB.periodLength), VDB.periodStartDate)
		ELSE dateadd(day, (VDB.periodLength * -1),(dateadd(day, ((floor((datediff(day, VDB.periodStartDate, dateadd(d, -1*(counter+1), @begindate))) / VDB.periodLength)) * VDB.periodLength), VDB.periodStartDate)))
		END	AS MinDate
		FROM	scVariableDaysBack VDB
		JOIN	dd_scAccountTypes A ON A.AccountTypeID = VDB.AccountTypeId
		join cteThresholds_VDB_AcctType cte
			on vdb.AccountTypeId = cte.AccountTypeId
)			
select *, 'Pub' as [Source]
from cteThresholds_VDB_Pub
union all
select *, 'AcctType'
from cteThresholds_VDB_AcctType

