declare @dtNow datetime
set @dtNow = GETDATE()
	
	--|  Using temp tables instead of the inline function call to dbo.scOverThreshhold()
	CREATE TABLE #PubVDB( PublicationId INT Primary Key, MinDate DATETIME )
	CREATE TABLE #ATVDB ( AccountTypeId INT Primary Key, MinDate DATETIME )

	INSERT #PubVDB
	SELECT VDB.PublicationId
	,	CASE WHEN ( datediff(day, (dateadd(day, ( (floor((datediff(day, VDB.periodStartDate, @dtNow)) / VDB.periodLength)) * VDB.periodLength), VDB.periodStartDate) ), @dtNow) + 1 ) >= VDB.PeriodCutoffDay 
	THEN	dateadd(day, ((floor((datediff(day, VDB.periodStartDate, @dtNow)) / VDB.periodLength)) * VDB.periodLength), VDB.periodStartDate)
	ELSE dateadd(day, (VDB.periodLength * -1),(dateadd(day, ((floor((datediff(day, VDB.periodStartDate, @dtNow)) / VDB.periodLength)) * VDB.periodLength), VDB.periodStartDate)))
	END	AS MinDate
	FROM	scVariableDaysBack VDB
	JOIN	nsPublications P ON P.PublicationId = VDB.PublicationId

	INSERT #ATVDB
	SELECT
	VDB.AccountTypeId
	,	CASE WHEN ( datediff(day, (dateadd(day, ( (floor((datediff(day, VDB.periodStartDate, @dtNow)) / VDB.periodLength)) * VDB.periodLength), VDB.periodStartDate) ), @dtNow) + 1 ) >= VDB.PeriodCutoffDay 
	THEN	dateadd(day, ((floor((datediff(day, VDB.periodStartDate, @dtNow)) / VDB.periodLength)) * VDB.periodLength), VDB.periodStartDate)
	ELSE dateadd(day, (VDB.periodLength * -1),(dateadd(day, ((floor((datediff(day, VDB.periodStartDate, @dtNow)) / VDB.periodLength)) * VDB.periodLength), VDB.periodStartDate)))
	END	AS MinDate
	FROM	scVariableDaysBack VDB
	JOIN	dd_scAccountTypes A ON A.AccountTypeID = VDB.AccountTypeId


	declare @returnThreshold int
	select @returnThreshold = isnull( sysPropertyValue, 7 )
	from syncSystemProperties
	where sysPropertyName = 'ReturnThreshhold'




--select *
--from #PubVDB

--select *
--from #ATVDB

	select a.AcctCode
		, p.PubShortName
		, avdb.MinDate as [vdb_accttype_mindate]
		, pvdb.MinDate as [vdb_pub_mindate]
		, DATEADD(dd, -1*@returnThreshold, @dtNow) as [sys_returnThreshold]
		, COALESCE( avdb.minDate, pvdb.minDate, DATEADD(dd, -1*@returnThreshold, @dtNow) ) as [returnThreshold]
	from scAccountsPubs ap
	join scAccounts a
		on ap.AccountID = a.AccountId
	join nsPublications p
		on ap.PublicationId = p.PublicationID
	left join #pubVDB pvdb 
		on pvdb.PublicationId = ap.PublicationId
	left join #ATVDB avdb 
		on avdb.AccountTypeId = a.AccountTypeId

drop table #PubVDB
drop table #ATVDB