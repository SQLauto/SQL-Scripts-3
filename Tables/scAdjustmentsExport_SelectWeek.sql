IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_scAdjustmentsExport_SelectWeek_Table]') AND type in (N'U'))
DROP TABLE [dbo].[support_scAdjustmentsExport_SelectWeek_Table]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[support_scAdjustmentsExport_SelectWeek_Table](
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
	[APCustom1] [nvarchar](50) NULL,
	[APCustom2] [nvarchar](50) NULL,
	[APCustom3] [nvarchar](50) NULL,
	[IsRollup] [tinyint] NULL,
	[PublicationID] [int] NOT NULL,
	[PubName] [nvarchar](50) NOT NULL,
	[PubShortName] [nvarchar](5) NOT NULL,
	[PubDescription] [nvarchar](128) NULL,
	[PubCustom1] [nvarchar](50) NULL,
	[PubCustom2] [nvarchar](50) NULL,
	[PubCustom3] [nvarchar](50) NULL,
	[StartDate] [datetime] NULL,
	[DrawId0] [int] NULL,
	[DrawDate0] [datetime] NULL,
	[DrawAmount0] [int] NULL,
	[AdjFullAmount0] [int] NULL,
	[AdjAdminFullAmount0] [int] NULL,
	[AdjAmount0] [int] NULL,
	[DrawId1] [int] NULL,
	[DrawDate1] [datetime] NULL,
	[DrawAmount1] [int] NULL,
	[AdjFullAmount1] [int] NULL,
	[AdjAdminFullAmount1] [int] NULL,
	[AdjAmount1] [int] NULL,
	[DrawId2] [int] NULL,
	[DrawDate2] [datetime] NULL,
	[DrawAmount2] [int] NULL,
	[AdjFullAmount2] [int] NULL,
	[AdjAdminFullAmount2] [int] NULL,
	[AdjAmount2] [int] NULL,
	[DrawId3] [int] NULL,
	[DrawDate3] [datetime] NULL,
	[DrawAmount3] [int] NULL,
	[AdjFullAmount3] [int] NULL,
	[AdjAdminFullAmount3] [int] NULL,
	[AdjAmount3] [int] NULL,
	[DrawId4] [int] NULL,
	[DrawDate4] [datetime] NULL,
	[DrawAmount4] [int] NULL,
	[AdjFullAmount4] [int] NULL,
	[AdjAdminFullAmount4] [int] NULL,
	[AdjAmount4] [int] NULL,
	[DrawId5] [int] NULL,
	[DrawDate5] [datetime] NULL,
	[DrawAmount5] [int] NULL,
	[AdjFullAmount5] [int] NULL,
	[AdjAdminFullAmount5] [int] NULL,
	[AdjAmount5] [int] NULL,
	[DrawId6] [int] NULL,
	[DrawDate6] [datetime] NULL,
	[DrawAmount6] [int] NULL,
	[AdjFullAmount6] [int] NULL,
	[AdjAdminFullAmount6] [int] NULL,
	[AdjAmount6] [int] NULL
) ON [PRIMARY]

GO



insert into support_scAdjustmentsExport_SelectWeek_Table
exec scAdjustmentsExport_SelectWeek '5/1/2013', '5/7/2013', 2, 1, 0
