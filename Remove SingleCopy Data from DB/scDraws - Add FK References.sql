

--DefaultDraws
ALTER TABLE [dbo].[scDraws]  WITH CHECK ADD  CONSTRAINT [FK_scDraws_scDefaultDraws] FOREIGN KEY([CompanyID], [DistributionCenterID], [AccountID], [PublicationID], [DrawWeekday])
REFERENCES [dbo].[scDefaultDraws] ([CompanyID], [DistributionCenterID], [AccountID], [PublicationID], [DrawWeekday])
GO

ALTER TABLE [dbo].[scDraws] CHECK CONSTRAINT [FK_scDraws_scDefaultDraws]
GO

--DrawHistory
ALTER TABLE [dbo].[scDrawHistory]  WITH CHECK ADD  CONSTRAINT [FK_scDrawHistory_scDraws] FOREIGN KEY([drawid])
REFERENCES [dbo].[scDraws] ([DrawID])
GO

ALTER TABLE [dbo].[scDrawHistory] CHECK CONSTRAINT [FK_scDrawHistory_scDraws]
GO


--scSBTSales
ALTER TABLE [dbo].[scSBTSales]  WITH CHECK ADD  CONSTRAINT [FK_scSBTSales_scDraws] FOREIGN KEY([DrawId])
REFERENCES [dbo].[scDraws] ([DrawID])
GO

ALTER TABLE [dbo].[scSBTSales] CHECK CONSTRAINT [FK_scSBTSales_scDraws]
GO


--|scDrawAdjustmentsAudit
ALTER TABLE [dbo].[scDrawAdjustmentsAudit]  WITH CHECK ADD  CONSTRAINT [FK_scDrawAdjustmentsAudit_scDraws] FOREIGN KEY([DrawId])
REFERENCES [dbo].[scDraws] ([DrawID])
GO

ALTER TABLE [dbo].[scDrawAdjustmentsAudit] CHECK CONSTRAINT [FK_scDrawAdjustmentsAudit_scDraws]
GO

--|scReturnsAudit
ALTER TABLE [dbo].[scReturnsAudit]  WITH CHECK ADD  CONSTRAINT [FK_scReturnsAudit_scDraws] FOREIGN KEY([DrawId])
REFERENCES [dbo].[scDraws] ([DrawID])
GO

ALTER TABLE [dbo].[scReturnsAudit] CHECK CONSTRAINT [FK_scReturnsAudit_scDraws]
GO

--|scConditionHistory

ALTER TABLE [dbo].[scConditionHistory]  WITH CHECK ADD  CONSTRAINT [FK_scCondistionHistory_scDraws] FOREIGN KEY([DrawID])
REFERENCES [dbo].[scDraws] ([DrawID])
GO

ALTER TABLE [dbo].[scConditionHistory] CHECK CONSTRAINT [FK_scCondistionHistory_scDraws]
GO

--|scProductLineItemDetails
ALTER TABLE [dbo].[scProductLineItemDetails]  WITH CHECK ADD  CONSTRAINT [FK_scProductLineItemDetails_scDraws] FOREIGN KEY([DrawId])
REFERENCES [dbo].[scDraws] ([DrawID])
GO

ALTER TABLE [dbo].[scProductLineItemDetails] CHECK CONSTRAINT [FK_scProductLineItemDetails_scDraws]
GO

