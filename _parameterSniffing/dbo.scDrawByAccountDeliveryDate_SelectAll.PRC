IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[scDrawByAccountDeliveryDate_SelectAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[scDrawByAccountDeliveryDate_SelectAll]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[scDrawByAccountDeliveryDate_SelectAll]
    @AccountId      int,
    @Date           datetime,
	@ManifestId		int			-- pub for account can be on separate manifest so need manifest id
AS
/*=========================================================
	scDrawByAccountDeliveryDate_SelectAll
        Retrieves all draw records that apply to the given
    account for a given delivery date. Used to pull 'current'
    date's delivery info for the PDA download. Historical draw
    information is still provided by the older scDrawByAccountDate_SelectAll
    procedure.
        
    args:
        @AccountId      Specific Account being retreived
        @Date           Date for current draw information
                                
	Date:   06/26/2006
	Author: robcom

	$History: /Gazette/Database/Scripts/Sprocs/dbo.scDrawByAccountDeliveryDate_SelectAll.prc $
-- 
-- ****************** Version 8 ****************** 
-- User: mmisantone   Date: 2009-01-13   Time: 13:28:29-05:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 6564 
-- 
-- ****************** Version 7 ****************** 
-- User: rreffner   Date: 2008-10-14   Time: 15:54:10-04:00 
-- Updated in: /Gazette/Source/DeviceTransfer/Syncronex.DeviceSyncLib/Database 
-- Case 6028 
-- 
-- ****************** Version 6 ****************** 
-- User: rreffner   Date: 2008-10-14   Time: 15:50:04-04:00 
-- Updated in: /Gazette/Source/DeviceTransfer/Syncronex.DeviceSyncLib/Database 
-- Case 5955 
-- 
-- ****************** Version 5 ****************** 
-- User: rreffner   Date: 2008-09-26   Time: 08:32:36-04:00 
-- Updated in: /Gazette/Source/DeviceTransfer/Syncronex.DeviceSyncLib/Database 
-- Case 6028 
-- 
-- ****************** Version 4 ****************** 
-- User: mmisantone   Date: 2008-06-17   Time: 12:27:40-04:00 
-- Updated in: /Gazette/Source/DeviceTransfer/Syncronex.DeviceSyncLib/Database 
-- Case 4579 - Syncronize DeviceTransfer from 2.7 
-- 
-- ****************** Version 4 ****************** 
-- User: robcom   Date: 2008-06-03   Time: 20:14:25-07:00 
-- Updated in: /Gazette 2.7/Source/DeviceTransfer/Syncronex.DeviceSyncLib/Database 
-- Case 3913 
-- 
-- ****************** Version 2 ****************** 
-- User: robcom   Date: 2007-07-06   Time: 09:11:18-07:00 
-- Updated in: /Gazette/Source/DeviceTransfer/Syncronex.DeviceSyncLib/Database 
-- Case 359 
-- 
-- ****************** Version 1 ****************** 
-- User: robcom   Date: 2007-07-06   Time: 08:57:17-07:00 
-- Updated in: /Gazette/Source/DeviceTransfer/Syncronex.DeviceSyncLib/Database 
-- Added for Case 359 
	
	==========================================================*/
BEGIN

	declare @maskAccountID int
	declare @maskManifestID int
	declare @maskDate datetime

	set @maskAccountID = @AccountID
	set @maskManifestID = @ManifestID
	set @maskDate = @Date


--
--	Requirement for Case 359 is to make it backward compatible with versions that may not
--	have the new DeliveryDate column in the DB.  We do a quick check to see if we have DeliveryDate
--	and fall back to using the normal DrawDate column if DeliveryDate is missing...
--
if exists(select 1 from dbo.syscolumns where id=object_id(N'[dbo].[scDraws]') and name = 'DeliveryDate')
begin
		--	Select list needs to match that of scDrawbyAccountDate_SelectAll since the code
		--	in Syncronex.DeviceTransfer.dll treats both current and historical draws
		--	the same
    select
        dr.DrawId,
        dr.PublicationId,
        dr.DrawDate,
        dr.DrawAmount,
        dr.DrawRate,
        dbo.scGetDayFrequency( dr.DrawDate ) as [ratefrequency],
        0   											as [Returns],									-- Current day's delivery can't have returns. This can have unintended consequences if historical delivery info is pulled (via default.aspx)
        isnull(dr.AdjAmount,0)   as [adjustment],
        isnull(dr.AdjAdminAmount,0) as [admadjustment],
		0.0	as [taxrate1],
		0.0 as [taxrate2],			-- tax rate columns added for case 3913
	DD.AllowReturns 	AS RetAllowed,
	DD.AllowAdjustments	AS AdjAllowed

    from
        dbo.scDraws dr
 	inner join scAccountsPubs ap
	on ( ap.CompanyID = dr.CompanyID
	    and ap.DistributionCenterID = dr.DistributionCenterID
	    and ap.PublicationID = dr.PublicationID
	    and ap.AccountId = dr.AccountId)

    JOIN scDefaultDraws DD
    ON (DD.CompanyID = dr.CompanyID
	AND DD.DistributionCenterID = dr.DistributionCenterID
	AND DD.PublicationID = dr.PublicationID
    	AND DD.AccountId = dr.AccountId
	AND DD.DrawWeekday = DATEPART(dw,@maskDate))

	join scManifestSequences ms on (ms.AccountPubId = ap.AccountPubId)

    where
        dr.AccountId = @maskAccountId
    and dr.DeliveryDate = @maskDate
	and (
		(  
			--Delivery has been stopped for a beginning and ending date range
			dr.DrawAmount <> 0 AND (dr.DeliveryDate NOT BETWEEN ap.DeliveryStopDate and  ap.DeliveryStartDate)
		)
		OR ( 
			--Delivery has not been stopped
			(ap.DeliveryStopDate IS NULL) AND (ap.DeliveryStartDate IS NULL) 
		)
		OR  (
			-- Delivery has a stop date but not restart date 
			NOT ((dr.DrawAmount = 0) AND  (DATEDIFF(d, dr.DeliveryDate, ap.DeliveryStopDate) <= 0) AND (ap.DeliveryStartDate IS NULL) )
		)
	)
	and ms.ManifestId = @maskManifestId

end
else
begin
    select
        dr.DrawId,
        dr.PublicationId,
        dr.DrawDate,
        dr.DrawAmount,
        dr.DrawRate,
        dbo.scGetDayFrequency( dr.DrawDate ) as [ratefrequency],
        0   											as [Returns],									-- Current day's delivery can't have returns. This can have unintended consequences if historical delivery info is pulled (via default.aspx)
        isnull(dr.AdjAmount,0)   as [adjustment],
        isnull(dr.AdjAdminAmount,0) as [admadjustment],
		0.0	as [taxrate1],
		0.0 as [taxrate2],			-- tax rate columns added for case 3913
	DD.AllowReturns 	AS RetAllowed,
	DD.AllowAdjustments	AS AdjAllowed
    from
        dbo.scDraws dr
    inner join scAccountsPubs ap
    on ( ap.CompanyID = dr.CompanyID
    	and ap.DistributionCenterID = dr.DistributionCenterID
    	and ap.PublicationID = dr.PublicationID
    	and ap.AccountId = dr.AccountId)
    JOIN scDefaultDraws DD
    ON (DD.CompanyID = dr.CompanyID
	AND DD.DistributionCenterID = dr.DistributionCenterID
	AND DD.PublicationID = dr.PublicationID
    	AND DD.AccountId = dr.AccountId
	AND DD.DrawWeekday = DATEPART(dw,@maskDate))

	join scManifestSequences ms on (ms.AccountPubId = ap.AccountPubId)

    where
        dr.AccountId = @maskAccountId
    and dr.DrawDate = @maskDate
	and (
		(  
			--Delivery has been stopped for a beginning and ending date range
			dr.DrawAmount <> 0 AND (dr.DrawDate NOT BETWEEN ap.DeliveryStopDate and  ap.DeliveryStartDate)
		)
		OR ( 
			--Delivery has not been stopped
			(ap.DeliveryStopDate IS NULL) AND (ap.DeliveryStartDate IS NULL) 
		)
		OR  (
			-- Delivery has a stop date but not restart date 
			NOT (dr.DrawAmount = 0) AND  (DATEDIFF(d, dr.DrawDate, ap.DeliveryStopDate) <= 0) AND (ap.DeliveryStartDate IS NULL)
		)
	)
	and ms.ManifestId = @maskManifestId

end    
    
END



GO

GRANT EXECUTE ON [dbo].[scDrawByAccountDeliveryDate_SelectAll] TO [nsUser]
GO

