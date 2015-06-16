IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_DrawEntryByManifest]') AND type in (N'U'))
DROP TABLE [dbo].[support_DrawEntryByManifest]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[support_DrawEntryByManifest](
	[AccountId]			[int] NULL,
	[PublicationId]		[int] NULL,
	[DrawId]			[int] NULL,
	[MfstCode]			[nvarchar](20) NULL,
	[MfstName]			[nvarchar](50) NULL,
	[ManifestOwner]		[nvarchar](100) NULL,
	[DropSequence]		[int] NULL,
	[AcctCode]			[nvarchar](20) NULL,
	[AcctName]			[nvarchar](50) NULL,
	[AcctAddress]		[nvarchar](128) NULL,
	[AcctCity]			[nvarchar](50) NULL,
	[AcctStateProvince]	[nvarchar](5) NULL,
	[AcctPostalCode]	[nvarchar](15) NULL,
	[PubShortName]		[nvarchar](5) NULL,
	[DrawAmount]		[int] NULL,
	[DrawDate]			[datetime] NULL,
	[OverThreshold]		[int] NULL,
	[AdjAmount]			[int] NULL,
	[AdjAdminAmount]	[int] NULL,
	[RetAmount]			[int] NULL,
	[NetSales]			[int] NULL,
	[ATName]			[nvarchar](50) NULL,
	[ManifestSequenceId]	[int] NULL,
	[RollupAcctId]		[int] NULL,
	[RollupAcctCode]		[nvarchar](20) NULL,
	[AllowReturns]		[int] NULL,
	[AllowAdjustments]	[int] NULL
) ON [PRIMARY]

GO

