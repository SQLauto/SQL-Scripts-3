
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
	,Net int
	,DrawAmount int
	,Adj int
	,Ret int
	,AcctStateProvince  nvarchar(5)
	,AcctActive int
	,RollupId int
	,MfstName nvarchar(50)
	)

insert into #NetSalesResults1
exec scReports_NetSales_Summary 'Mar  7 2010 12:00:00:000AM','Mar 13 2010 12:00:00:000AM',NULL,927,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,127,1,0,4
