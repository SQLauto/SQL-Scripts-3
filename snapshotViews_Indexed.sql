SET ANSI_NULLS ON
GO
SET ANSI_PADDING ON
GO
SET ANSI_WARNINGS ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ARITHABORT ON
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[scDraws_Snapshot_View]'))
DROP VIEW [dbo].[scDraws_Snapshot_View]
GO

CREATE    view [dbo].[scDraws_Snapshot_View] with schemabinding
as
	select d.AccountID, d.PublicationID, d.DrawID, d.DrawWeekday, d.DrawDate, d.DeliveryDate, DrawAmount, DrawRate
	from dbo.scDraws d
	join dbo.import_ProcessingDates p
		on d.DrawDate = p.DrawDate
	--where d.DrawDate between convert(datetime, '2/21/2012', 101) and convert(datetime, '2/21/2012', 101)
		
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[scDefaultDraws_Snapshot_View]'))
DROP VIEW [dbo].[scDefaultDraws_Snapshot_View]
GO

CREATE    view [dbo].[scDefaultDraws_Snapshot_View] with schemabinding
as
	select dd.AccountID, dd.PublicationID, dd.DrawWeekday, p.DrawDate, dd.DrawAmount, dd.DrawRate
	from dbo.import_ProcessingDates p
	join dbo.scDefaultDraws dd
		on dd.DrawWeekday = p.DrawWeekday
	--where d.DrawDate between convert(datetime, '2/21/2012', 101) and convert(datetime, '2/21/2012', 101)
		
GO

/*
create unique clustered index idx_scDraws_Snapshot_View 
on [dbo].[scDraws_Snapshot_View] (  AccountId, PublicationId, DrawWeekday, DrawDate ) 
GO

create nonclustered index idx_scDraws_Snapshot_View2 
on [dbo].[scDraws_Snapshot_View] (  AccountId, PublicationId, DrawWeekday ) include (DrawDate, DeliveryDate, DrawAmount, DrawRate, DrawId )
GO
*/