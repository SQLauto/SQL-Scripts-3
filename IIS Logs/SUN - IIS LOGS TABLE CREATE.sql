if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IIS0606]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
 BEGIN
CREATE TABLE [dbo].[IIS0606] (
	[DATE] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[TIME] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Col003] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Col004] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[METHOD] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PAGE] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[QUERYSTRING] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PORT] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Col009] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[IP] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[RESPONSE] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Col012] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Col013] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Col014] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Col015] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Col016] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
END

GO


