USE [db_syncronex_prod]
GO

/****** Object:  Index [idx_scReturnsAudit_RetAuditDateEX]    Script Date: 03/13/2015 10:28:47 ******/
CREATE NONCLUSTERED INDEX [idx_scReturnsAudit_RetAuditDateEX] ON [dbo].[scReturnsAudit] 
(
	[RetAuditDate] ASC
)
INCLUDE ( [DrawId],
[ReturnsAuditId],
[RetAuditValue]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


USE [db_syncronex_prod]
GO

/****** Object:  Index [idx_scReturnsAudit_RetAuditDate]    Script Date: 03/13/2015 10:29:44 ******/
CREATE NONCLUSTERED INDEX [idx_scReturnsAudit_RetAuditDate] ON [dbo].[scReturnsAudit] 
(
	[RetAuditDate] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


USE [db_syncronex_prod]
GO

/****** Object:  Index [idx_scReturnsAudit_DrawiIdAuditId]    Script Date: 03/13/2015 10:30:04 ******/
CREATE NONCLUSTERED INDEX [idx_scReturnsAudit_DrawiIdAuditId] ON [dbo].[scReturnsAudit] 
(
	[DrawId] ASC,
	[ReturnsAuditId] ASC
)
INCLUDE ( [RetAuditValue]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


