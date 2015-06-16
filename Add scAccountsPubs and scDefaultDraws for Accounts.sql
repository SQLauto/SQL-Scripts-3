
begin tran
set nocount on

	declare @pubId int
	select @pubId = PublicationId
	from nsPublications 
	where PubShortName = 'UT'
	
	;with cte as (
		select '3511C029' as acctcode
		union all select '3543C005'
		union all select '3556C004'
		union all select '3569C009'
		union all select '3578C007'
		union all select '3604C002'
		union all select '3609C008'
		union all select '3615C005'
		union all select '3626C003'
		union all select '3634C005'
		union all select '3701C003'
		union all select '3701C005'
		union all select '3701C008'
		union all select '3702C007'
		union all select '3703C004'
		union all select '3709C010'
		union all select '3710C007'
		union all select '3710C014'
		union all select '3710C016'
		union all select '3755C004'
		union all select '3759C003'
		union all select '3761C003'
		union all select '3761C004'
		union all select '3762C002'
		union all select '3762C005'
		union all select '3764C004'
		union all select '3771C009'
		union all select '3771C019'
		union all select '3772C005'
		union all select '3774C006'
		union all select '3781C011'
		union all select '4613C013'
		union all select '4639C006'
		union all select '4652C009'
		union all select '4655C005'
		union all select '4655C011'
		union all select '4668C011'
		union all select '4677C003'
		union all select '4683C002'
		union all select '4684C011'
		union all select '4685C001'
		union all select '4689C005'
		union all select '4695C001'
	)
	select a.AccountID, a.AcctCode
	into #acctsToAdd
	from cte
	join scAccounts a
		on cte.acctcode = a.AcctCode
		
	--/*	
	insert scAccountsPubs (
		 companyid
		,distributioncenterid
		,accountid
		,publicationid
		,deliverystartdate
		,deliverystopdate
		,forecaststartdate
		,forecaststopdate
		,excludefrombilling
		,active
		,apcustom1
		,apcustom2
		,apcustom3
		,apowner
	)
	select
		 1
		,1
		, tmp.AccountID
		, @pubId
		,null
		,null
		,null
		,null
		,0
		,1
		,null
		,null
		,'ZeroDraw'
		,1
	from #acctsToAdd tmp
	left join scAccountsPubs ap
		on tmp.AccountID = ap.AccountId
		and ap.PublicationId = @pubId
	where ap.AccountPubID is null
	print 'Added ' + cast(@@rowcount as varchar) + ' scAccountsPubs records'
	
	;with cteDayOfWeek as (
		select 1 as DrawWeekday
		union all select 2
		union all select 3
		union all select 4
		union all select 5
		union all select 6
		union all select 7
	)
	insert into scdefaultdraws (
		 companyid
		,distributioncenterid
		,accountid
		,publicationid
		,drawweekday
		,drawamount
		,drawrate
		,allowforecasting
		,allowreturns
		,allowadjustments
		,forecastmindraw
		,forecastmaxdraw
	)
	select 
		  1
		, 1
		, tmp.accountid
		, @pubId
		, dow.DrawWeekday
		, 3 as [drawamount]
		, 0.0 as [drawrate]
		, 1 as allowforecasting
		, 1 as allowreturns
		, 1 as allowadjustments
		, 0 as forecastmindraw
		, 2147483647 as forecastmaxdraw
	from #acctsToAdd tmp
	join cteDayOfWeek dow
		on 1 = 1
	left join scDefaultDraws dd
		on tmp.AccountID = dd.AccountID
		and dd.PublicationID = @pubId
		and dd.DrawWeekday = dow.DrawWeekday
	where dd.CompanyID is null
	order by 3,4,5	
	print 'Added ' + cast(@@rowcount as varchar) + ' scDefaultDraw records'
	
commit tran		