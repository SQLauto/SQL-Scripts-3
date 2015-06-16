IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tmpReturnsImport]') AND type in (N'U'))
DROP TABLE [dbo].[tmpReturnsImport]
GO

create table tmpReturnsImport (
	AcctCode nvarchar(255)
	, Pub nvarchar(10)
	, DrawDate datetime
	, DrawAmount int
	, DrawRate money
	, RetAmount int
	, DrawId int
	, AccountId int
	, PublicationId int
)

