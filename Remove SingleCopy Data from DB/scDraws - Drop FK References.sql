


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_scDraws_scDefaultDraws]') AND parent_object_id = OBJECT_ID(N'[dbo].[scDraws]'))
ALTER TABLE [dbo].[scDraws] DROP CONSTRAINT [FK_scDraws_scDefaultDraws]
GO


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_scDrawHistory_scDraws]') AND parent_object_id = OBJECT_ID(N'[dbo].[scDrawHistory]'))
ALTER TABLE [dbo].[scDrawHistory] DROP CONSTRAINT [FK_scDrawHistory_scDraws]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_scSBTSales_scDraws]') AND parent_object_id = OBJECT_ID(N'[dbo].[scSBTSales]'))
ALTER TABLE [dbo].[scSBTSales] DROP CONSTRAINT [FK_scSBTSales_scDraws]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_scDrawAdjustmentsAudit_scDraws]') AND parent_object_id = OBJECT_ID(N'[dbo].[scDrawAdjustmentsAudit]'))
ALTER TABLE [dbo].[scDrawAdjustmentsAudit] DROP CONSTRAINT [FK_scDrawAdjustmentsAudit_scDraws]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_scReturnsAudit_scDraws]') AND parent_object_id = OBJECT_ID(N'[dbo].[scReturnsAudit]'))
ALTER TABLE [dbo].[scReturnsAudit] DROP CONSTRAINT [FK_scReturnsAudit_scDraws]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_scCondistionHistory_scDraws]') AND parent_object_id = OBJECT_ID(N'[dbo].[scConditionHistory]'))
ALTER TABLE [dbo].[scConditionHistory] DROP CONSTRAINT [FK_scCondistionHistory_scDraws]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_scProductLineItemDetails_scDraws]') AND parent_object_id = OBJECT_ID(N'[dbo].[scProductLineItemDetails]'))
ALTER TABLE [dbo].[scProductLineItemDetails] DROP CONSTRAINT [FK_scProductLineItemDetails_scDraws]
GO

truncate table scdraws
truncate table scDrawHistory
truncate table scDrawAdjustmentsAudit
truncate table scReturnsAudit