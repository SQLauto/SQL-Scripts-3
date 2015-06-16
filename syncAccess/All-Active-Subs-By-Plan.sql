declare	@BeginDate		DATETIME
,	@EndDate		DATETIME
select	@BeginDate = '1/1/1900',
			@EndDate   = '2/28/2014'


	-- Normalize the dates
	DECLARE	@myBeginDate NVARCHAR(20), 
			@myEndDate NVARCHAR(20), 
			@myEndDate1 DATETIME



	SET	@myBeginDate = CONVERT(NVARCHAR(20),DATEADD(DAY,DATEDIFF(DAY,0,@BeginDate),0),101)
	SET @myEndDate1  = DATEADD(DAY,DATEDIFF(DAY,0,@EndDate),0)
	SET @myEndDate   = CONVERT(NVARCHAR(20),DATEADD(S,86399,@myEndDate1),101)


	/*
		Get list of our currently active subs
	*/	
	IF OBJECT_ID('tempdb..#activeSubs') IS NOT NULL DROP TABLE #activeSubs
	SELECT	DISTINCT SP.UserId
	INTO	#activeSubs
	FROM	dbo.SubscriberPlans SP
	WHERE	SP.Active > 0 AND SP.ExpirationDate > CAST(@myEndDate AS DATETIME)

	/*
		Get a list of Subs that bought a plan via syncAccess and then got linked to
		generic Qual plan later. This represents 'confirmed purchases' That is, user
		bought plan 'A',it was sent to circ, circ recorded it and we then mapped back
		plan 'B' (aka "Qualified Plan").  In this case, we can say that Plan 'A' was 
		successfully purchased even though it would should up as 'inactive' in syncAccess
	*/
	IF OBJECT_ID('tempdb..#linkedplans') IS NOT NULL DROP TABLE #linkedplans
	select	
		UserId
	,	SUM(CASE WHEN LEFT(sp.OriginalPlanName,1) = '*' THEN 0	-- 0 for any linked plan
		ELSE 1													-- 1 for any purchased plan
		END)			AS A									-- Sum is > 0 for 'round-trip' purchase-to-link
	into	#linkedplans
	from	SubscriberPlans sp
	where	sp.PlanId NOT IN (1,2,11,13)
	group by Userid
	having SUM(CASE WHEN LEFT(sp.OriginalPlanName,1) = '*' THEN 0
		ELSE 1
		END) > 0

	IF OBJECT_ID('tempdb..#confirmedPurchasedPlans') IS NOT NULL DROP TABLE #confirmedPurchasedPlans
	select	LP.UserId,SP.SubscriberPlanID 
	into	#confirmedPurchasedPlans
	from	#linkedplans lp
	join	SubscriberPlans sp on lp.UserId = sp.UserId
	where	sp.Active = 0
	
	-- Get the list of primary key fields we've got
	IF OBJECT_ID('tempdb..#PKs') IS NOT NULL DROP TABLE #PKs
	SELECT	DISTINCT KeyField 
	INTO	#PKs 
	FROM	dbo.SubscriberSourceKeys 
	WHERE KeyType='Primary'

	--	Create our select columns clause
	--	This creates a value like '[OccupantId],[AddressId]...'
	DECLARE @columns NVARCHAR(MAX)
	SELECT @columns = STUFF(
		(SELECT ', ' + QUOTENAME(KeyField, '[') AS [text()]
		   FROM  #PKs 
		   FOR XML PATH ('')
		), 1, 1, '');

	PRINT @columns

	--	Create our dynamic SQL statement containing a PIVOT clause
	--	that transforms the Source PK rows into columns
	DECLARE @SQLStatement NVARCHAR(4000);
	SELECT @SQLStatement = 
		'SELECT *
		FROM(
			SELECT	S.UserId
			,		S.FirstName
			,		S.LastName
			,		M.Email
			--,		M.CreatedDate
			,		P.PhoneNumber
			,		SP.PurchaseDate
			--,		SP.ExpirationDate
			--,		SP.CancelledDate
			,		SP.OriginalPlanCode
			--,		SP.SubscriberPlanId
			--,		CP.SubscriberPlanId		AS PurchasedId
			,		SP.OriginalPlanName
			--,		SP.OriginalPlanRate
			--,		SP.Active	[PlanActive]
			--,		S.IsActive	AS [SubscriberActive]
			--,		CASE WHEN LEFT(SP.OriginalPlanName,1) = ''*'' THEN CAST(0x01 AS BIT) ELSE CAST(0x00 AS BIT) END AS [LinkedPlan]
			,		SSK.KeyField
			,		SSK.KeyValue
			FROM	dbo.Subscribers S
			JOIN	#activeSubs A ON A.UserId = S.UserId
			JOIN	dbo.seMemberships M	ON S.UserID = M.UserId
			JOIN	dbo.PhoneNumbers P ON P.UserID = S.UserId
			JOIN	dbo.SubscriberPlans SP ON SP.UserId = S.UserId
			LEFT JOIN #confirmedPurchasedPlans CP ON ( CP.UserId = SP.UserId  )
			LEFT JOIN dbo.SubscriberSources SS ON SS.UserId = S.UserId
			LEFT JOIN dbo.SubscriberSourceKeys SSK ON SS.SubscriberSourceId = SSK.SubscriberSourceId
			WHERE	SP.PurchaseDate  BETWEEN ''' + @myBeginDate + ''' AND ''' + @myEndDate + '''
			AND		( SSK.KeyType IS NULL OR SSK.KeyType = ''Primary'' )
			AND		SP.PlanID NOT IN (2,11,13,1)   -- Not COMP,PP,TEMP,TEST		
			AND		S.IsActive > 0	
			AND		(
						CP.SubscriberPlanId IS NOT NULL AND SP.Active = 0 
						OR
						CP.SubscriberPlanId IS NULL
					)
		) AS SRC
		PIVOT ( MAX(KeyValue) FOR [KeyField] IN ( ' + @columns + ' ) ) AS PVT
		
		ORDER BY 1, 7	-- UserId,PurchaseDate'

	PRINT @SQLStatement
	-- Execute the query
	EXEC sp_executeSQL @SQLStatement
