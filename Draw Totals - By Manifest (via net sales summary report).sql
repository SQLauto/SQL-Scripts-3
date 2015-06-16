begin tran

CREATE TABLE #NetSalesResults1 (
	MfstID int
	,AccountID int
	,MFSTCode nvarchar(20)
	,AcctCode nvarchar(20)
	,AcctName nvarchar(50)
	,AcctCity nvarchar(50)
	,AcctPostalCode nvarchar(15)
	,AcctCustom1 nvarchar(50)
	,AcctCustom2 nvarchar(50)
	,AcctCustom3 nvarchar(50)
	,PublicationId int
	,PubShortName nvarchar(5)
	,Net int
	,DrawAmount int
	,Adj int
	,Ret int
	,AcctStateProvince  nvarchar(5)
	--,RetPct money
	,AcctActive int
	,RollupId int
	,MfstName nvarchar(50)
	,DrawDate datetime
	)
	
insert into #NetSalesResults1	
exec SSRS_Dataset_NetSalesSummary @start='2013-02-17 00:00:00',@stop='2013-02-23 00:00:00',@mfstowner=N'7',@mfstId=N'24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63',@ManifestType=N'1',@acctcode=N'',@accttypelist=N'6,5,3,7,8,4,1,2,0',@Categories=N'2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,1,18,19,20,21,22,23,24,25,26,27,28,29,30,0,31,32,53,43,44,45,54,46,47,48,49,50,51,52,33,34,35,36,37,38,39,40,41,42',@acctname=N'',@city=N'',@state=N'',@zip=N'',@cust1=N'',@cust2=N'',@cust3=N'',@Pub=N'12,8,9,3,11,7,4,5,6,2,1,10',@freq=127,@Deactive=N'1',@RollupDetail=0

;with cte
as (
	select 1 as dw
		, MfstCode, MfstName, AcctCode, PubShortName
		, CASE DATEPART(dw, DrawDate) when 1 then DrawAmount
			else null end as [SUN]
		, CASE DATEPART(dw, DrawDate) when 2  then DrawAmount
			else null end as [MON]
		, CASE DATEPART(dw, DrawDate) when 3  then DrawAmount
			else null end as [TUE]	
		, CASE DATEPART(dw, DrawDate) when 4  then DrawAmount
			else null end as [WED]
		, CASE DATEPART(dw, DrawDate) when 5  then DrawAmount
			else null end as [THU]
		, CASE DATEPART(dw, DrawDate) when 6  then DrawAmount
			else null end as [FRI]
		, CASE DATEPART(dw, DrawDate) when 7  then DrawAmount
			else null end as [SAT]
	from #NetSalesResults1
	where DATEPART(dw, DrawDate) = 1
	union all 
		select dw + 1
		, tmp.MFSTCode, tmp.MfstName, tmp.AcctCode, tmp.PubShortName
		, CASE DATEPART(dw, DrawDate) when 1 then DrawAmount
			else null end as [SUN]
		, CASE DATEPART(dw, DrawDate) when 2  then DrawAmount
			else null end as [MON]
		, CASE DATEPART(dw, DrawDate) when 3  then DrawAmount
			else null end as [TUE]	
		, CASE DATEPART(dw, DrawDate) when 4  then DrawAmount
			else null end as [WED]
		, CASE DATEPART(dw, DrawDate) when 5  then DrawAmount
			else null end as [THU]
		, CASE DATEPART(dw, DrawDate) when 6  then DrawAmount
			else null end as [FRI]
		, CASE DATEPART(dw, DrawDate) when 7  then DrawAmount
			else null end as [SAT]	
		from #NetSalesResults1 tmp
		join cte 
			on tmp.AcctCode = cte.AcctCode	
			and tmp.PubShortName = cte.PubShortName
		where datepart(dw, DrawDate) = dw + 1
		and dw + 1 <= 7
	)
	select MfstCode, MfstName, PubShortName
		, SUM(SUN) as SUN
		, SUM(MON) as MON
		, SUM(TUE) as TUE
		, SUM(WED) as WED
		, SUM(THU) as THU
		, SUM(FRI) as FRI
		, SUM(SAT) as SAT
	from cte
	group by MfstCode, MfstName, PubShortName
	order by MFSTCode, PubShortName

rollback tran

