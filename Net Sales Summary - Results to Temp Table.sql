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
	,Net int
	,DrawAmount int
	,Adj int
	,Ret int
	,AcctStateProvince  nvarchar(5)
	,RetPct money
	,AcctActive int
	,RollupId int
	)

insert into #NetSalesResults1
exec scReports_NetSales_Summary 
	@start='Mar  7 2010 12:00:00:000AM'
	,@stop='Mar 13 2010 12:00:00:000AM'
	,@mfstowner=NULL
	,@mfstid=927
	,@acctname=NULL
	,@acctcode=NULL
	,@categories=NULL
	,@acctTypeList=NULL
	,@pub=NULL
	,@zip=NULL
	,@city=NULL
	,@state=NULL
	,@cust1=NULL
	,@cust2=NULL
	,@cust3=NULL
	,@freq=127
	,@Deactive=1
	,@RollupDetail=0


/*
select *
from #netsales tmp1
join (
	select actid, pub
	from #netsales
	group by actid, pub
	having count(*) > 1
	) as [tmp2]
on tmp1.actid = tmp2.actid
and tmp1.pub = tmp2.pub	
*/

rollback tran