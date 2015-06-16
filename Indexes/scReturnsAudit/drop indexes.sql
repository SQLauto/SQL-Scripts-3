USE [db_syncronex_prod]
GO

/****** Object:  Index [idx_scReturnsAudit_DrawiIdAuditId]    Script Date: 03/13/2015 10:30:36 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[scReturnsAudit]') AND name = N'idx_scReturnsAudit_DrawiIdAuditId')
DROP INDEX [idx_scReturnsAudit_DrawiIdAuditId] ON [dbo].[scReturnsAudit] WITH ( ONLINE = OFF )
GO

USE [db_syncronex_prod]
GO

/****** Object:  Index [idx_scReturnsAudit_RetAuditDate]    Script Date: 03/13/2015 10:30:51 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[scReturnsAudit]') AND name = N'idx_scReturnsAudit_RetAuditDate')
DROP INDEX [idx_scReturnsAudit_RetAuditDate] ON [dbo].[scReturnsAudit] WITH ( ONLINE = OFF )
GO

USE [db_syncronex_prod]
GO

/****** Object:  Index [idx_scReturnsAudit_RetAuditDateEX]    Script Date: 03/13/2015 10:31:01 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[scReturnsAudit]') AND name = N'idx_scReturnsAudit_RetAuditDateEX')
DROP INDEX [idx_scReturnsAudit_RetAuditDateEX] ON [dbo].[scReturnsAudit] WITH ( ONLINE = OFF )
GO

