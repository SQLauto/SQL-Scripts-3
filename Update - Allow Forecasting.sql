
begin tran

	--|  Create a temp table to hold the Accts to protect
	create table #protectedAccts (AcctCode nvarchar(50))
	insert into #protectedAccts (AcctCode)
	select 'W2212102'
	union all select 'W2212310'
	union all select 'W2213610'
	union all select 'W2220106'
	union all select 'W2220132'
	union all select 'W2220157'
	union all select 'W2220159'
	union all select 'W2224126'
	union all select 'W2224129'
	union all select 'W2224141'
	union all select 'W2225117'
	union all select 'W2225118'
	union all select 'W2225142'
	union all select 'W2225313'
	union all select 'W2225314'
	union all select 'W2225604'
	union all select 'W2226188'
	union all select 'W2228116'
	union all select 'W2228600'
	union all select 'W2280602'
	union all select 'W2401001'
	union all select 'W3206107'
	union all select 'W3230101'
	union all select 'W3230119'
	union all select 'W3234602'
	union all select 'W3234603'
	union all select 'W3235625'
	union all select 'W3235626'
	union all select 'W3236171'
	union all select 'W3236612'
	union all select 'W3236650'
	union all select 'W3238610'
	union all select 'W3238611'
	union all select 'W3401001'
	union all select 'W4206106'
	union all select 'W4206107'
	union all select 'W4206111'
	union all select 'W4210138'
	union all select 'W4210159'
	union all select 'W4210300'
	union all select 'W4210636'
	union all select 'W4210639'
	union all select 'W4210643'
	union all select 'W4211303'
	union all select 'W4214139'
	union all select 'W4214154'
	union all select 'W4215120'
	union all select 'W4216129'
	union all select 'W4216134'
	union all select 'W4216402'
	union all select 'W4216633'
	union all select 'W4217105'
	union all select 'W4217614'
	union all select 'W4217615'
	union all select 'W4218109'
	union all select 'W4218119'
	union all select 'W4218129'
	union all select 'W4218602'
	union all select 'W4218604'
	union all select 'W4218618'
	union all select 'W4232626'
	union all select 'W4280600'
	union all select 'W4281600'
	union all select 'W4401001'
	union all select 'W5206106'
	union all select 'W5206111'
	union all select 'W5250106'
	union all select 'W5250149'
	union all select 'W5250183'
	union all select 'W5250608'
	union all select 'W5250613'
	union all select 'W5250650'
	union all select 'W5251114'
	union all select 'W5251306'
	union all select 'W5251600'
	union all select 'W5251610'
	union all select 'W5251611'
	union all select 'W5251624'
	union all select 'W5251650'
	union all select 'W5252607'
	union all select 'W5256161'
	union all select 'W5256226'
	union all select 'W5256623'
	union all select 'W5256624'
	union all select 'W5256625'
	union all select 'W5256650'
	union all select 'W5280600'
	union all select 'W5401001'
	union all select 'W6233186'
	union all select 'W6233190'
	union all select 'W6233302'
	union all select 'W6233318'
	union all select 'W6233608'
	union all select 'W6233609'
	union all select 'W6233650'
	union all select 'W6237301'
	union all select 'W6280601'
	union all select 'W6401001'

	--|  Backup the relevant data from scDefaultDraws
	if not exists ( select 1 from sysobjects where id = object_id('scDefaultDraws_AllowForecasting_BACKUP') and type = 'U' )
	begin
		select dd.AccountId, dd.PublicationId, dd.Drawweekday, dd.AllowForecasting
		into scDefaultDraws_AllowForecasting_BACKUP
		from scDefaultDraws dd
		join scAccounts a
			on dd.AccountId = a.AccountId
		join #protectedAccts tmp
			on a.AcctCode = tmp.AcctCode
	end
	else
	begin
		--|  If the table already exists, clean it out
		delete scDefaultDraws_AllowForecasting_BACKUP

		select dd.AccountId, dd.PublicationId, dd.Drawweekday, dd.AllowForecasting
		from scDefaultDraws dd
		join scAccounts a
			on dd.AccountId = a.AccountId
		join #protectedAccts tmp
			on a.AcctCode = tmp.AcctCode
	end

	--|  Update AllowForecasting flag in scDefaultDraws
	update scDefaultDraws
	set AllowForecasting = 0
	from scDefaultDraws dd
	join scAccountsPubs ap
		on ap.Accountid = dd.Accountid
		and ap.Publicationid = dd.Publicationid
	join scAccounts a
		on ap.AccountId = a.AccountId
	join #protectedAccts tmp
		on a.AcctCode = tmp.AcctCode

	--|  Review the data
	select tmp.AccountId, a.AcctCode, tmp.PublicationId, tmp.Drawweekday, tmp.AllowForecasting as [AllowForecasting (Before)], dd.AllowForecasting as [AllowForecasting (After)]
	from scDefaultDraws_AllowForecasting_BACKUP tmp
	join scDefaultDraws dd
		on tmp.AccountId = dd.AccountId
		and tmp.PublicationId = dd.PublicationId
		and tmp.Drawweekday = dd.Drawweekday
	join scAccounts a
		on tmp.AccountId = a.AccountId
	order by tmp.AccountId

	drop table #protectedAccts

rollback tran