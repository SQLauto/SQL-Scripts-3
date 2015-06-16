IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_scAdjustmentsExport_SelectDaily_Table]') AND type in (N'U'))
DROP TABLE [dbo].[support_scAdjustmentsExport_SelectDaily_Table]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[support_scAdjustmentsExport_SelectDaily_Table](
	[DrawID] [int] NULL,
	[ATName] [nvarchar](50) NULL,
	[ATDescription] [nvarchar](128) NULL,
	[AccountID] [int] NULL,
	[Code] [nvarchar](20) NULL,
	[Name] [nvarchar](50) NULL,
	[Description] [nvarchar](128) NULL,
	[Address] [nvarchar](128) NULL,
	[City] [nvarchar](50) NULL,
	[StateProvince] [nvarchar](5) NULL,
	[PostalCode] [nvarchar](15) NULL,
	[Country] [nvarchar](50) NULL,
	[Contact] [nvarchar](50) NULL,
	[Phone] [nvarchar](20) NULL,
	[Hours] [nvarchar](20) NULL,
	[SpecialInstructions] [nvarchar](256) NULL,
	[Custom1] [nvarchar](50) NULL,
	[Custom2] [nvarchar](50) NULL,
	[Custom3] [nvarchar](50) NULL,
	[Notes] [nvarchar](256) NULL,
	[IsRollup] [tinyint] NULL,
	[APCustom1] [nvarchar](50) NULL,
	[APCustom2] [nvarchar](50) NULL,
	[APCustom3] [nvarchar](50) NULL,
	[PublicationID] [int] NOT NULL,
	[PubName] [nvarchar](50) NOT NULL,
	[PubShortName] [nvarchar](5) NOT NULL,
	[PubDescription] [nvarchar](128) NULL,
	[PubCustom1] [nvarchar](50) NULL,
	[PubCustom2] [nvarchar](50) NULL,
	[PubCustom3] [nvarchar](50) NULL,
	[DrawDate] [datetime] NULL,
	[DrawAmount] [int] NULL,
	[AdjFullAmount] [int] NULL,
	[AdjAdminFullAmount] [int] NULL,
	[AdjAmount] [int] NULL
) ON [PRIMARY]

GO



insert into support_scAdjustmentsExport_SelectDaily_Table
exec scAdjustmentsExport_SelectDaily '5/1/2013', '6/1/2013', 1, 0

