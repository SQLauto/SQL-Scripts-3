
insert into scManifestLoad (
	  AcctAddress
	, AcctCity
	, AcctCode
	, AcctName
	, AcctState
	, AcctZip
	, [Date]
	, Draw
	, LocationCat
	, LocationSeq
	, LocationType
	, MfstCode
	, PubShortName
	, RollupAcct
	, TruckName
	)
select
	'123 Main St'	--|AcctAddress
	, 'Hartford'		--|AcctCity
	, 'Acct_' + cast( max(AccountId) as nvarchar) --|AcctCode
	, 'Acct_' + cast( max(AccountId) as nvarchar) --|AcctName
	, 'State'  --|AcctState
	, '99999'  --|AcctZip
	, convert(nvarchar, getdate(), 1)  --|Date
	, CONVERT(INT, (100+1)*RAND())  --|Draw
	, ''  --|LocationCat
	, 10 * CONVERT(INT, (50+1)*RAND())  --|LocationSeq
	, ''  --|LocationType
	, 'CENTER'  --|MfstCode
	, 'GAZ'  --|PubShortName
	, 'N'  --|RollupAcct
	, 'CENTER'  --|TruckName
from scAccounts
