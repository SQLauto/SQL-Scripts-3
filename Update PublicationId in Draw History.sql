begin tran

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[fk_scDrawHistory_scDraws]') AND type = 'F')
ALTER TABLE [dbo].[scDrawHistory] DROP CONSTRAINT [fk_scDrawHistory_scDraws]

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_scDefaultDraws_nsPublications]') AND type = 'F')
ALTER TABLE [dbo].[scDefaultDraws] DROP CONSTRAINT [FK_scDefaultDraws_nsPublications]

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_scDraws_scDefaultDraws]') AND type = 'F')
ALTER TABLE [dbo].[scDraws] DROP CONSTRAINT [FK_scDraws_scDefaultDraws]

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_scDrawAdjustmentsAudit_scDraws]') AND type = 'F')
ALTER TABLE [dbo].[scDrawAdjustmentsAudit] DROP CONSTRAINT [FK_scDrawAdjustmentsAudit_scDraws]

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_scReturnsAudit_scDraws]') AND type = 'F')
ALTER TABLE [dbo].[scReturnsAudit] DROP CONSTRAINT [FK_scReturnsAudit_scDraws]

--|forecast rules
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK__scForecastAccoun__0C50D423]') AND type = 'F')
ALTER TABLE [dbo].[scForecastAccountRules] DROP CONSTRAINT [FK__scForecastAccoun__0C50D423]

--| 1
update scDefaultDraws
set publicationid = 6
where publicationid = 4

--| 2
update scDrawHistory
set publicationid = 6
where publicationid = 4

--| 3
update scDrawAdjustmentsAudit
set publicationid = 6
where publicationid = 4

--| 4
update scReturnsAudit
set publicationid = 6
where publicationid = 4

--| 5
update scdraws
set publicationid = 6
where publicationid = 4

--| 6
update scAccountspubs
set publicationid = 6
where publicationid = 4

--| 7
update scforecastpublicationrules
set publicationid = 6
where publicationid = 4

--| 8
update scforecastrules
set publicationid = 6
where publicationid = 4


IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[fk_scDrawHistory_scDraws]') AND type = 'F')
ALTER TABLE [dbo].[scDrawHistory]  WITH CHECK ADD  CONSTRAINT [fk_scDrawHistory_scDraws] FOREIGN KEY([companyid], [distributioncenterid], [accountid], [publicationid], [drawweekday], [drawid])
REFERENCES [dbo].[scDraws] ([CompanyID], [DistributionCenterID], [AccountID], [PublicationID], [DrawWeekday], [DrawID])
GO
ALTER TABLE [dbo].[scDrawHistory] CHECK CONSTRAINT [fk_scDrawHistory_scDraws]

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_scDefaultDraws_nsPublications]') AND type = 'F')
ALTER TABLE [dbo].[scDefaultDraws]  WITH CHECK ADD  CONSTRAINT [FK_scDefaultDraws_nsPublications] FOREIGN KEY([CompanyID], [DistributionCenterID], [PublicationID])
REFERENCES [dbo].[nsPublications] ([CompanyID], [DistributionCenterID], [PublicationID])
GO
ALTER TABLE [dbo].[scDefaultDraws] CHECK CONSTRAINT [FK_scDefaultDraws_nsPublications]

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_scDraws_scDefaultDraws]') AND type = 'F')
ALTER TABLE [dbo].[scDraws]  WITH CHECK ADD  CONSTRAINT [FK_scDraws_scDefaultDraws] FOREIGN KEY([CompanyID], [DistributionCenterID], [AccountID], [PublicationID], [DrawWeekday])
REFERENCES [dbo].[scDefaultDraws] ([CompanyID], [DistributionCenterID], [AccountID], [PublicationID], [DrawWeekday])
GO
ALTER TABLE [dbo].[scDraws] CHECK CONSTRAINT [FK_scDraws_scDefaultDraws]

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_scDrawAdjustmentsAudit_scDraws]') AND type = 'F')
ALTER TABLE [dbo].[scDrawAdjustmentsAudit]  WITH CHECK ADD  CONSTRAINT [FK_scDrawAdjustmentsAudit_scDraws] FOREIGN KEY([CompanyId], [DistributionCenterId], [AccountID], [PublicationId], [DrawWeekday], [DrawId])
REFERENCES [dbo].[scDraws] ([CompanyID], [DistributionCenterID], [AccountID], [PublicationID], [DrawWeekday], [DrawID])
GO
ALTER TABLE [dbo].[scDrawAdjustmentsAudit] CHECK CONSTRAINT [FK_scDrawAdjustmentsAudit_scDraws]

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_scReturnsAudit_scDraws]') AND type = 'F')
ALTER TABLE [dbo].[scReturnsAudit]  WITH CHECK ADD  CONSTRAINT [FK_scReturnsAudit_scDraws] FOREIGN KEY([CompanyId], [DistributionCenterId], [AccountId], [PublicationId], [DrawWeekday], [DrawId])
REFERENCES [dbo].[scDraws] ([CompanyID], [DistributionCenterID], [AccountID], [PublicationID], [DrawWeekday], [DrawID])
GO
ALTER TABLE [dbo].[scReturnsAudit] CHECK CONSTRAINT [FK_scReturnsAudit_scDraws]

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK__scForecastAccoun__0C50D423]') AND type = 'F')
ALTER TABLE [dbo].[scForecastAccountRules]  WITH CHECK ADD FOREIGN KEY([CompanyId], [DistributionCenterId], [AccountId], [PublicationId])
REFERENCES [dbo].[scAccountsPubs] ([CompanyID], [DistributionCenterID], [AccountId], [PublicationId])

rollback tran

/*
select *
from scdrawhistory
where publicationid = 4

select publicationid, count(*)
from scdraws
group by publicationid

*/

