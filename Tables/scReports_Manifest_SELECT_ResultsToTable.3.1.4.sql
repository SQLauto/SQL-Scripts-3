
create table scReports_Manifest_SELECT_ResultsToTable (
  ManifestTemplateID	int
, MfstName				nvarchar(50)
, MfstCustom1			nvarchar(50)
, MfstCustom2			nvarchar(50)
, MfstCustom3			nvarchar(50)
, MfstDescription		nvarchar(128)
, DropSequence			int
, Instructions			nvarchar(256)
, PubShortName			nvarchar(5)
, PublicationID			int
, AcctCode			nvarchar(20)
, AcctName			nvarchar(50)
, AcctAddress			nvarchar(128)
, AcctCity			nvarchar(50)
, AcctStateProvince			nvarchar(5)
, AcctPostalCode			nvarchar(15)
, AcctCustom1			nvarchar(50)
, AcctCustom2			nvarchar(50)
, AcctCustom3			nvarchar(50)
, ATName			nvarchar(50)
, DrawAmount		int
, RetAmount			int
, AdjAdminAmount	int
, AdjAmount			int
, DeliveryDate		datetime
, PubName			nvarchar(50)
, PrintSortOrder	int
)

insert into scReports_Manifest_SELECT_ResultsToTable
exec scReports_Manifest_SELECT 6,'2014-03-23 00:00:00','214','7, 6, 9, 8, 43, 33, 25, 26, 37, 36, 34, 32, 41, 23, 24, 47, 46, 22, 21, 4, 3, 1, 2, 5, 13, 12, 10, 11, 14, 15, 16, 28, 30, 50, 48, 27, 29, 51, 49, 42, 19, 20, 18, 17','off','off',0,'','','','','',0
