drop table support_DrawEntryByManifest

create table support_DrawEntryByManifest (
	AccountId int
	, PublicationId int
	, DrawId int
	, MfstCode nvarchar(20)
	, MfstName nvarchar(50)
	, ManifestOwner nvarchar(100)
	, DropSequence int
	, AcctCode nvarchar(20)
	, AcctName nvarchar(50)
	, AcctAddress nvarchar(128)
	, AcctCity nvarchar(50)
	, AcctStateProvince nvarchar(5)
	, AcctPostalCode nvarchar(15)
	, PubShortName nvarchar(5)
	, DrawAmount int
	, DrawDate datetime
	, OverThreshold int
	, AdjAmount int
	, AdjAdminAmount int
	, RetAmount int
	, NetSales int
	, ATName nvarchar(50)
	--, ManifestSequenceId int
	, RollupAcctId int
	, RollupAcctCode nvarchar(20)
	, AllowReturns int
	, AllowAdjustments int
)