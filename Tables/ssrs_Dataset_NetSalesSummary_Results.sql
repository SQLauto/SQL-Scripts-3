IF OBJECT_ID('dbo.ssrs_Dataset_NetSalesSummary_Results', 'U') IS NOT NULL
  DROP TABLE dbo.ssrs_Dataset_NetSalesSummary_Results
GO

CREATE TABLE dbo.ssrs_Dataset_NetSalesSummary_Results 
(
		MfstID			int
,		AccountID		int
,		MFSTCode		nvarchar(20)
,		AcctCode		nvarchar(20)
,		AcctName		nvarchar(50)
,		AcctCity		nvarchar(50)
,		AcctPostalCode	nvarchar(15)
,		AcctCustom1		nvarchar(50)
,		AcctCustom2		nvarchar(50)
,		AcctCustom3		nvarchar(50)
,		PublicationId	int
,		PubShortName	nvarchar(5)
,		Net				int
,		DrawAmount		int
,		Adj				int
,		Ret				int
,		AcctStateProvince 	nvarchar(5)
,		AcctActive		int
,		RollupId		int
,		MfstName		nvarchar(50)
,		DrawDate		datetime
)
GO

GRANT SELECT ON [dbo.ssrs_Dataset_NetSalesSummary_Results] TO [nsUser]
GO



--insert into ssrs_Dataset_NetSalesSummary_Results
--exec SSRS_Dataset_NetSalesSummary @start='2013-05-05 00:00:00',@stop='2013-05-05 00:00:00',@mfstowner=N'1,19,27,38,49,14,47,22,33,31,29,30,37,57,23,7,6,51,24,58,54,55,53,10,40,43,34,52,50,21,32,17,28,13,42,5,25,9,12,8,2,44,4,48,46,39,20,18,26,3,56,15,41,45,35',@mfstId=N'22,24,25,28,29,30,31,34,35,36,38,39,40,41,42,43,44,47,48,49,51,52,53,54,55,58,59,60,61,62,64,78,79,80,89,137,138,141,77,71,75,74,76,73,72,147,136,135,145,20,1,3,7,19,5,17,18,21,10,6,15,11,13,2,8,16,23,12,14,4,9,146',@ManifestType=N'1',@acctcode=N'',@accttypelist=N'6,11,3,4,1,2,0',@Categories=N'2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,1,18,19,20,21,22,23,24,25,26,27,28,29,30,61,0,31,32,53,59,58,60,43,44,45,62,63,54,56,46,47,48,49,50,51,57,52,33,34,35,36,37,38,55,39,40,41,42',@acctname=N'',@city=N'',@state=N'',@zip=N'',@cust1=N'',@cust2=N'',@cust3=N'',@Pub=N'1',@freq=127,@Deactive=N'1',@RollupDetail=1

