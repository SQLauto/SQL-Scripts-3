/*

	1)  Save off threshold amounts into temp tables
	2)  Drop FK References so tables can be truncated
	3)  Enable identity insert and insert data back
*/

declare @drawsToDelete table (
	DrawId int
)

insert into @drawsToDelete
select d.DrawID
from scdraws d
where DrawDate > dateadd(year, -2, getdate())

--select d.*
--into scDraws_Temp
--from scdraws d
--join @drawsToDelete tmp
--	on d.DrawID = tmp.DrawId

select dh.*
into scDrawHistory_Temp
from scDrawHistory dh
join @drawsToDelete tmp
	on tmp.DrawId = dh.DrawId

select ra.*
into scReturnsAudit_Temp
from scReturnsAudit ra
join @drawsToDelete tmp
	on ra.DrawId = tmp.DrawId

select da.*
into scDrawAdjustmentsAudit_Temp
from scDrawAdjustmentsAudit da
join @drawsToDelete tmp
	on da.DrawId = tmp.DrawId

--| 2 years retained - 18:00 minutes


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


set identity_insert dbo.scDraws on

insert into scDraws ( CompanyID, DistributionCenterID, AccountID, PublicationID, DrawWeekday, DrawID, DrawDate, DeliveryDate, DrawAmount, DrawRate, BillingHistoryID, AdjAmount, AdjAdminAmount, AdjExpDateTime, AdjExportLastAmt, RetAmount, RetExpDateTime, RetExportLastAmt, RollupAcctID, LastChangeType, BillingDate )
select CompanyID, DistributionCenterID, AccountID, PublicationID, DrawWeekday, DrawID, DrawDate, DeliveryDate, DrawAmount, DrawRate, BillingHistoryID, AdjAmount, AdjAdminAmount, AdjExpDateTime, AdjExportLastAmt, RetAmount, RetExpDateTime, RetExportLastAmt, RollupAcctID, LastChangeType, BillingDate
from scDraws_Temp

set identity_insert dbo.scDraws off

insert into dbo.scDrawHistory ( companyid, distributioncenterid, accountid, publicationid, drawid, drawweekday, changeddate, drawdate, olddraw, newdraw, oldrate, newrate, olddeliverydate, newdeliverydate, changetypeid, userid, forecastruleid )
select companyid, distributioncenterid, accountid, publicationid, drawid, drawweekday, changeddate, drawdate, olddraw, newdraw, oldrate, newrate, olddeliverydate, newdeliverydate, changetypeid, userid, forecastruleid
from dbo.scDrawHistory_Temp


insert into dbo.scReturnsAudit (CompanyId, DistributionCenterId, AccountId, PublicationId, DrawWeekday, DrawId, ReturnsAuditId, RetAuditDate, RetAuditUserId, RetAuditField, RetAuditValue  )
select CompanyId, DistributionCenterId, AccountId, PublicationId, DrawWeekday, DrawId, ReturnsAuditId, RetAuditDate, RetAuditUserId, RetAuditField, RetAuditValue
from dbo.scReturnsAudit_Temp


insert into dbo.scDrawAdjustmentsAudit( CompanyId, DistributionCenterId, AccountID, PublicationId, DrawWeekday, DrawId, DrawAdjustmentAuditId, AdjAuditDate, AdjAuditUserId, AdjAuditField, AdjAuditValue )
select CompanyId, DistributionCenterId, AccountID, PublicationId, DrawWeekday, DrawId, DrawAdjustmentAuditId, AdjAuditDate, AdjAuditUserId, AdjAuditField, AdjAuditValue
from dbo.scDrawAdjustmentsAudit_Temp 

drop table dbo.scDraws_Temp
drop table dbo.scDrawHistory_Temp
drop table dbo.scReturnsAudit_Temp
drop table dbo.scDrawAdjustmentsAudit_Temp



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
