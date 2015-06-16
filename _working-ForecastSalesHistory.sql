
/*
join an account to it's forecast rule to get based on weeks
join the account to the draw history for a range of forecast dates
*/
declare @acct nvarchar(20)
declare @pub nvarchar(5)

set @acct = 'AC7'
set @pub = 'TRIB'

select
	fr.AcctCode, fr.PubShortName, fr.AccountId, fr.PublicationId, fr.CategoryId, fr.ForecastRuleId
	, fr.RuleType
	, max(fwt.wtWeek) as [BasedOnWeeks]
from scForecastWeightingTables fwt
join (
	select a.AcctCode, p.PubShortName, a.AccountId, p.PublicationId, ac.CategoryId 
		, coalesce(far.ForecastRuleId, fcr.ForecastRuleId, fr.ForecastRuleId) as [ForecastRuleId]
		, case 
			when far.ForecastRuleId is not null then 'Forecast Account Rule'
			when fcr.ForecastRuleId is not null then 'Forecast Category Rule'
			when fr.ForecastRuleId is not null then 'Pub Default Rule'
			else 'No Associated Forecast Rule'
			end as [RuleType]
	from scAccounts a
	join scAccountsPubs ap
		on a.AccountId = ap.AccountId
	join scAccountsCategories ac
		on a.AccountId = ac.AccountId
	join nsPublications p
		on ap.PublicationId = p.PublicationId	
	left join scForecastAccountRules far
		on a.AccountId = far.AccountId
		and ap.PublicationId = far.PublicationId
	left join scForecastCategoryRules fcr
		on ac.CategoryId = fcr.CategoryId
	left join scForecastRules fr
		on ap.PublicationId = fr.PublicationId
	where a.acctCode = @acct
	and p.PubShortName = @pub
	) as fr
on fwt.ForecastRuleId = fr.ForecastRuleId
group by fr.AcctCode, fr.PubShortName, fr.AccountId, fr.PublicationId, fr.CategoryId, fr.ForecastRuleId
, fr.RuleType
/*
exec dbo.scForecastEngine_AcctPubRules_Select @accountid=563,@pubid=1,@forecastdate='Nov  8 2010 12:00:00:000AM'

exec dbo.scForecastEngine_SalesHistory_Select @AccountId=563,@PublicationId=2,@ForecastDate='Nov  8 2010 12:00:00:000AM',@BasedOnWeeks=6

exec dbo.scForecastEngine_scDraw_Select @AccountId=563,@PublicationId=1,@DrawDate='Nov  8 2010 12:00:00:000AM'
exec dbo.scForecastEngine_scAccountsPubs_Select @startDate='Nov  8 2010 12:00:00:000AM',@stopDate='Nov  8 2010 12:00:00:000AM',@pubid=-1,@AccountId=563
exec dbo.scForecastEngine_GetRules 

exec dbo.scForecastEngine_scForecastWeightingTables_Select @RuleId=7
*/