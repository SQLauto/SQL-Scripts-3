USE [NSDB_CHI]
GO
/****** Object:  StoredProcedure [dbo].[support_DuplicateDeliveryDate_Cleanup]    Script Date: 10/16/2013 16:09:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[support_DuplicateDeliveryDate_Cleanup]
	  @drawdate datetime = null
AS
/*
	[dbo].[support_DuplicateDeliveryDate_Cleanup]
	
	$History:  $
*/
BEGIN
	set nocount on
	
	--|  Declarations
	declare @msg nvarchar(1024)
	
	set @msg = 'support_DuplicateDeliveryDate_Cleanup procedure starting...'
    print @msg
    exec nsSystemLog_Insert @ModuleId=2, @SeverityId=0, @Message=@msg

	delete scDrawHistory
	from scDrawHistory dh
	join (
		select d.DrawID
		from scDraws d
		join (
			select d.AccountID, d.PublicationID, d.DeliveryDate
			from scDraws d
			where (
				( @deliveryDate is null and DeliveryDate in ( select distinct DeliveryDate from scManifestLoad_View ) )
				or 
				( @deliveryDate is not null and datediff(d, DeliveryDate, @deliveryDate) = 0 )
			)
			group by d.AccountID, d.PublicationID, d.DeliveryDate
			having COUNT(*) > 1
			) prelim
			on d.AccountID = prelim.AccountID
			and d.PublicationID = prelim.PublicationID
			and d.DeliveryDate = prelim.DeliveryDate
		where d.DrawDate = d.DeliveryDate
		and d.DrawAmount = 0
	) d
		on d.DrawID = dh.drawid
		
	set @msg = 'support_DuplicateDeliveryDate_Cleanup removed ' + CAST(@@rowcount as varchar) + ' records from scDrawHistory.'
    print @msg
    exec nsSystemLog_Insert @ModuleId=2, @SeverityId=0, @Message=@msg


	delete scDraws
	from scDraws d
	join (
		select d.AccountID, d.PublicationID, d.DeliveryDate
		from scDraws d
		where (
			( @deliveryDate is null and DeliveryDate in ( select distinct DeliveryDate from scManifestLoad_View ) )
			or 
			( @deliveryDate is not null and datediff(d, DeliveryDate, @deliveryDate) = 0 )
		)
		group by d.AccountID, d.PublicationID, d.DeliveryDate
		having COUNT(*) > 1
		) prelim
		on d.AccountID = prelim.AccountID
		and d.PublicationID = prelim.PublicationID
		and d.DeliveryDate = prelim.DeliveryDate
	where d.DrawDate = d.DeliveryDate
	and d.DrawAmount = 0		

	set @msg = 'support_DuplicateDeliveryDate_Cleanup removed ' + CAST(@@rowcount as varchar) + ' records from scDraws.'
    print @msg
    exec nsSystemLog_Insert @ModuleId=2, @SeverityId=0, @Message=@msg

	
	set @msg = 'support_DuplicateDeliveryDate_Cleanup completed successfully'
    print @msg
    exec nsSystemLog_Insert @ModuleId=2, @SeverityId=0, @Message=@msg


END
