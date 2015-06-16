/*
	[date] [datetime] NULL,
	[time] [datetime] NULL ,
	[c-ip] [varchar] (50) NULL ,
	[cs-method] [varchar] (50) NULL ,
	[cs-uri-stem] [varchar] (255) NULL ,
	[cs-uri-query] [varchar] (2048) NULL ,
	[sc-status] [int] NULL ,
	[sc-bytes] [int] NULL ,
	[time-taken] [int] NULL ,
	[cs(User-Agent)] [varchar] (255) NULL ,
	[cs(Cookie)] [varchar] (2048) NULL ,
	[cs(Referer)] [varchar] (2048) NULL 
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IISLogs]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
	DROP TABLE [dbo].[IISLogs]
END	
GO

CREATE TABLE [dbo].[IISLogs] (
	[date] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[time] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[server-ip] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[method] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[page]  [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[querystring] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[port] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[username] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[client-ip] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[user-agent] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[status] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[substatus] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[win32-status] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[timetaken] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	
) ON [PRIMARY]

GO


