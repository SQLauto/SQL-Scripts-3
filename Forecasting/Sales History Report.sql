declare @drawDate datetime
declare @acct nvarchar(20)
--declare @pub nvarchar(5)
declare @pub int
declare @manifestType nvarchar(80)
declare @freq int

set @drawDate = '2/8/2011'
set @acct = null
--set @pub = 'OL'
set @pub = -1
set @manifestType = 'Delivery'

set @freq = case datepart(dw, @drawDate)
	when 1 then 1
	when 2 then 2
	when 3 then 4
	when 4 then 8
	when 5 then 16
	when 6 then 32
	when 7 then 64
	end

select
	  hist.AcctCode, hist.PubShortName as [pub]
	, convert(varchar, hist.DrawDate, 1) as [DrawDate]
	, hist.Draw 
	, fr.FRName as [Rule]
	, FRReturnTargetPercent as [Ret Tgt %]
	, FRBasedOnWeeks as [Wks]
	, isnull(SalesOverrideName, 'n/a') as [SalesLevelOverride]
	, isnull(SelloutOverrideName, 'n/a') as [SelloutOverride]
	, typ.ChangeTypeDescription
	, case isnull(FRBasedOnWeeks,0)
		when 0 then
			''
		when 1 then 
			DrawDate1 + ' [' + cast(Net1 as varchar) + ')'
		when 2 then 
			convert(varchar, dateadd(d, -7, @drawDate), 1) + ' [' + isnull( cast(Net1 as varchar),0) + ']'	
			+ ', ' + convert(varchar, dateadd(d, -14, @drawDate), 1) + ' [' + isnull( cast(Net2 as varchar),0) + ']'	
		when 3 then 
			convert(varchar, dateadd(d, -7, @drawDate), 1) + ' [' + cast( isnull(Net1,0) as varchar) + ']'	
			+ ', ' + convert(varchar, dateadd(d, -14, @drawDate), 1) + ' [' + cast( isnull(Net2,0) as varchar) + ']'	
			+ ', ' + convert(varchar, dateadd(d, -21, @drawDate), 1) + ' [' + cast( isnull(Net3,0) as varchar) + ']'		
		when 4 then 
			convert(varchar, dateadd(d, -7, @drawDate), 1) + ' [' + cast( isnull(Net1,0) as varchar) + ']'	
			+ ', ' + convert(varchar, dateadd(d, -14, @drawDate), 1) + ' [' + cast( isnull(Net2,0) as varchar) + ']'	
			+ ', ' + convert(varchar, dateadd(d, -21, @drawDate), 1) + ' [' + cast( isnull(Net3,0) as varchar) + ']'		
			+ ', ' + convert(varchar, dateadd(d, -28, @drawDate), 1) + ' [' + cast( isnull(Net4,0) as varchar) + ']'		
		when 5 then 
			convert(varchar, dateadd(d, -7, @drawDate), 1) + ' [' + cast( isnull(Net1,0) as varchar) + ']'	
			+ ', ' + convert(varchar, dateadd(d, -7*2, @drawDate), 1) + ' [' + cast( isnull(Net2,0) as varchar) + ']'	
			+ ', ' + convert(varchar, dateadd(d, -7*3, @drawDate), 1) + ' [' + cast( isnull(Net3,0) as varchar) + ']'		
			+ ', ' + convert(varchar, dateadd(d, -7*4, @drawDate), 1) + ' [' + cast( isnull(Net4,0) as varchar) + ']'		
			+ ', ' + convert(varchar, dateadd(d, -7*5, @drawDate), 1) + ' [' + cast( isnull(Net5,0) as varchar) + ']'		
		when 6 then 
			convert(varchar, dateadd(d, -7, @drawDate), 1) + ' [' + cast( isnull(Net1,0) as varchar) + ']'	
			+ ', ' + convert(varchar, dateadd(d, -7*2, @drawDate), 1) + ' [' + cast( isnull(Net2,0) as varchar) + ']'	
			+ ', ' + convert(varchar, dateadd(d, -7*3, @drawDate), 1) + ' [' + cast( isnull(Net3,0) as varchar) + ']'		
			+ ', ' + convert(varchar, dateadd(d, -7*4, @drawDate), 1) + ' [' + cast( isnull(Net4,0) as varchar) + ']'		
			+ ', ' + convert(varchar, dateadd(d, -7*5, @drawDate), 1) + ' [' + cast( isnull(Net5,0) as varchar) + ']'		
			+ ', ' + convert(varchar, dateadd(d, -7*6, @drawDate), 1) + ' [' + cast( isnull(Net6,0) as varchar) + ']'		
		when 7 then 
			convert(varchar, dateadd(d, -7, @drawDate), 1) + ' [' + cast( isnull(Net1,0) as varchar) + ']'	
			+ ', ' + convert(varchar, dateadd(d, -7*2, @drawDate), 1) + ' [' + cast( isnull(Net2,0) as varchar) + ']'	
			+ ', ' + convert(varchar, dateadd(d, -7*3, @drawDate), 1) + ' [' + cast( isnull(Net3,0) as varchar) + ']'		
			+ ', ' + convert(varchar, dateadd(d, -7*4, @drawDate), 1) + ' [' + cast( isnull(Net4,0) as varchar) + ']'		
			+ ', ' + convert(varchar, dateadd(d, -7*5, @drawDate), 1) + ' [' + cast( isnull(Net5,0) as varchar) + ']'		
			+ ', ' + convert(varchar, dateadd(d, -7*6, @drawDate), 1) + ' [' + cast( isnull(Net6,0) as varchar) + ']'		
			+ ', ' + convert(varchar, dateadd(d, -7*7, @drawDate), 1) + ' [' + cast( isnull(Net7,0) as varchar) + ']'		
		else
			convert(varchar, dateadd(d, -7, @drawDate), 1) + ' [' + cast( isnull(Net1,0) as varchar) + ']'	
			+ ', ' + convert(varchar, dateadd(d, -7*2, @drawDate), 1) + ' [' + cast( isnull(Net2,0) as varchar) + ']'	
			+ ', ' + convert(varchar, dateadd(d, -7*3, @drawDate), 1) + ' [' + cast( isnull(Net3,0) as varchar) + ']'		
			+ ', ' + convert(varchar, dateadd(d, -7*4, @drawDate), 1) + ' [' + cast( isnull(Net4,0) as varchar) + ']'		
			+ ', ' + convert(varchar, dateadd(d, -7*5, @drawDate), 1) + ' [' + cast( isnull(Net5,0) as varchar) + ']'		
			+ ', ' + convert(varchar, dateadd(d, -7*6, @drawDate), 1) + ' [' + cast( isnull(Net6,0) as varchar) + ']'		
			+ ', ' + convert(varchar, dateadd(d, -7*7, @drawDate), 1) + ' [' + cast( isnull(Net7,0) as varchar) + ']'		
			+ '  * Sales History older than 7 wks has been filtered'
		end as [Sales History]
	, mfst.MfstCode		
from dbo.scSalesHistory(@drawDate, @acct, @pub) hist
left join scdrawhistory dh
	on hist.DrawId = dh.DrawId
left join dd_nsChangeTypes typ
	on dh.ChangeTypeid = typ.ChangeTypeid
left join scForecastRules fr
	on dh.ForecastRuleid = fr.ForecastRuleid
left join scForecastRule_SalesOverrides frsa
	 on fr.ForecastRuleId = frsa.ForecastRuleId
left join scSalesOverrides sa
	on frsa.SalesOverrideId = sa.SalesOverrideId
left join scForecastRule_SelloutOverrides frso
	on fr.ForecastRuleId = frso.ForecastRuleId
left join scSelloutOverrides so
	on frso.SelloutOverrideId = so.SelloutOverrideId
left join listMfstsAccts(@manifestType,@acct,@pub) mfst
	on hist.AccountId = mfst.AccountId
	and hist.PublicationId = mfst.PublicationId
	and @freq & mfst.Frequency > 0
