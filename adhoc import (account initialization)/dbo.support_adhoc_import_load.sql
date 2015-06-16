/*
	This table should contain placeholders for the essential data 
	that is needed to initialize a database.
	
	
*/

IF OBJECT_ID('dbo.support_adhoc_import_load', 'U') IS NOT NULL
  DROP TABLE dbo.support_adhoc_import_load
GO

CREATE TABLE dbo.support_adhoc_import_load 
(
	--|  Account
	  AcctCode nvarchar(20)
	, AcctName nvarchar(50)
	, AcctDescription nvarchar(128)
	, AcctAddress nvarchar(128)
	, AcctCity nvarchar(50)
	, AcctStateProvince nvarchar(5)
	, AcctPostalCode nvarchar(15)
	, AcctType nvarchar(50)
	, AcctCategory nvarchar(50)
	
	, AcctNotes nvarchar(256)
	, AcctContact nvarchar(50)
	, AcctHours nvarchar(20)
	, AcctPhone nvarchar(20)
	, AcctCustom1 nvarchar(50)
	, AcctCustom2 nvarchar(50)
	, AcctCustom3 nvarchar(50)
	, AcctSpecialInstructions nvarchar(256)
	
	--|  Manifests
	, MfstCode nvarchar(20)
	, MfstName nvarchar(50)
	
	, DropSequence int

	--|  Publicaiton
	, PubCode nvarchar(5)
	, PubName nvarchar(50)
	
	--|  Draw
	, SUN int
	, MON int
	, TUE int
	, WED int
	, THU int
	, FRI int
	, SAT int
)
GO

GRANT SELECT ON [dbo].[support_adhoc_import_load] TO [nsUser]
GO
