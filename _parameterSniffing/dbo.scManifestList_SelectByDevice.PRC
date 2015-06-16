SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[scManifestList_SelectByDevice]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[scManifestList_SelectByDevice]
GO


create procedure dbo.scManifestList_SelectByDevice
(
	 @deviceCode	nvarchar(20)
	,@mfstDate		datetime
)
As
/*=========================================================
    scManifestList_SelectByDevice
        Used by SCSynchronizer module to get the list of 
    active manifests for the given identifying data. Sproc
    takes an NVARCHAR arg that identifies the Device that is
    asking for data.

    Args:
		@deviceCode				unique identifier for particular device making the request
		@Date					The date for which to pull the manifest
		
    08/06/2004
    robcom
	
--	$History: /Gazette/Database/Scripts/Sprocs/dbo.scManifestList_SelectByDevice.PRC $    
-- 
-- ****************** Version 10 ****************** 
-- User: kerry   Date: 2009-12-28   Time: 16:09:31-05:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 11766 - "Empty" Manifest can be download to PDA under certain 
-- circumstances 
-- 
-- ****************** Version 9 ****************** 
-- User: mmisantone   Date: 2009-01-13   Time: 13:28:29-05:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 6564 
-- 
-- ****************** Version 8 ****************** 
-- User: rreffner   Date: 2008-06-25   Time: 10:02:47-04:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 4588 
-- 
-- ****************** Version 7 ****************** 
-- User: jpeaslee   Date: 2008-02-12   Time: 09:08:18-08:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 2075 Out of Memory Error message on PDA - No drops associated with 
-- collection manifest 
-- Case 2829 Manifest list selection must use delivery date not draw date 
-- 

    02/09/2006      robcom      Modified sproc to return details about manifest
                                candidates (i.e., already downloaded, not processed, not found,etc)
                                Allows more specific error message to get to PDA
                                
    05/23/2006      robcom      Support for Billing/Collection. Now returning the 'type' of manifest
                                within the list.     
    09/01/2006      robcom      Removed restriction for "already downloaded" so that it applies to both
                                delivery AND collection manifests.                   

==========================================================*/
begin
set nocount on

        declare @deviceid int
        select @deviceid = DeviceId from nsDevices where DeviceCode = @deviceCode
        
		declare @mfst_date datetime
		set @mfst_date = @mfstDate


        create table #manifests(
             companyid              int             not null
            ,distributioncenterid   int             not null
            ,manifestid             int             not null
            ,mfstcode               nvarchar(20)    not null
            ,mfstName               nvarchar(50)    not null
            ,mfstType               int             not null    -- new for billing. From dd_scManifestTypes
            ,mfstOKtodownload       tinyint         not null    -- indicator (0 or 1) as to whether the mfst can be downloaded (0=false)
            ,mfstStatusMsg          nvarchar(250)   null        -- this will hold a msg to be passed along to device. keep it small
        )                                                       -- since we weill probably be appending info together
        
        --  First step is to pull a list of likely manifest
        --  candidates based purely on device association
        insert #manifests(
             companyid
            ,distributioncenterid
            ,manifestid
            ,mfstcode
            ,mfstname
            ,mfstType
            ,mfstOKtodownload
            ,mfstStatusMsg
        )
        select
			 mfst.companyid
			,mfst.distributioncenterid
			,mfst.manifestid
			,mfst.mfstcode
			,mfst.MfstName
            ,mfst.ManifesttypeId
            ,1                              -- by default, all mfsts can be downloaded
            ,null
        from
            scManifests mfst
        Where
            mfst.DeviceId = @deviceId
		And mfst.ManifestDate = @mfst_date

        --  No reason to continue if we didn't get any data
        if ( @@ROWCOUNT = 0 )            
            return
            

        --  Update the candidate table with manifest history status
        update   #manifests
        set      mfstOkToDownload = 0
                ,mfstStatusMsg    = N'Manifest was already downloaded to this device today'
        from
            #manifests  tmp
        inner join
            scManifestTransfers xfer On ( tmp.ManifestId = xfer.ManifestId )
        where
            tmp.mfstOktoDownload = 1
        and xfer.MfstDate = @mfst_date
        and xfer.DeviceId = @deviceid
        and xfer.MfstTransferStatus in ( 12,13 )    -- No download if mfst is uploading or uploaded

        --  We can't Allow a manifest to be downloaded
        --  if it's already been downloaded to some other device...
        update   #manifests
        set      mfstOkToDownload = 0
                ,mfstStatusMsg    = N'Manifest has already been downloaded to device: ' + CAST(xfer.DeviceId as nvarchar) + '(' + isnull(dev.devicecode,'deleted') + ')'
        from
            #manifests  tmp
        inner join
            scManifestTransfers xfer On ( tmp.ManifestId = xfer.ManifestId )
        left join
            nsDevices dev On (xfer.DeviceId = dev.DeviceId)
        where
            tmp.mfstOktoDownload = 1
        and xfer.MfstDate = @mfst_date
        and xfer.DeviceId != @deviceid
        and xfer.MfstTransferStatus not in ( 0,7 )    -- if xfer is NOT new or Cancelled
        
        
		--
		--	Case 2075. We need to see if this Manifest has at least one location
		--	create a list of manifests with at least one active location and then
		--	check that list against our temp mfst list
		select
			m.manifestid
		into
			#manifestsWithDrops
		from
			#manifests tmp
		join 
			scmanifests m on tmp.ManifestId = m.ManifestId
		join
			scManifestSequences ms on m.ManifestID = ms.ManifestID
		join
			scAccountsPubs ap on ms.AccountPubID = ap.AccountPubID
		where
			AP.Active = 1
		and	m.ManifestDate = @mfst_date
		group by m.manifestid

		--	Modify our working list for any manifests NOT found in our manifestwithdrops table
		update	#manifests
		set		mfstOkToDownload = 0
			   ,mfstStatusMsg = N'No locations found on Manifest ' + tmp.mfstCode + ' for ' + convert(nvarchar(8),@mfst_date,1)
		from
				#manifests tmp
		left join
				#manifestsWithDrops md on tmp.manifestId = md.manifestid
		where
				mfstOkToDownload = 1
		and		md.manifestid is null

		--
		--	Now, check for Draws (extension to Case 2075). Even if the manifest has
		--	active drops, if there is no draw for those drops, the same error is reported
		--	as indicated by case 2075.
		--
		select 
			m.manifestid
		into #manifestsWithDraw
		from
			#manifests tmp
		join 
			scmanifests m on tmp.ManifestId = m.ManifestId
		join
			scManifestSequences ms on m.ManifestID = ms.ManifestID
		join
			scAccountsPubs ap on ms.AccountPubID = ap.AccountPubID
		join
			scDraws D on ap.accountId = D.AccountId 
			and ap.PublicationId = D.PublicationId 
			and D.DeliveryDate = @mfst_date
		where
			m.ManifestDate = @mfst_date
		group by m.manifestid
		having sum(d.DrawAmount)  > 0

		--	Modify our working list for any manifests NOT found in our manifestwithDraws table
		update	#manifests
		set		mfstOkToDownload = 0
			   ,mfstStatusMsg = N'No Draw found for any drops on Manifest ' + tmp.mfstCode + ' for ' + convert(nvarchar(8),@mfst_date,1)
		from
				#manifests tmp
		left join
				#manifestsWithDraw md on tmp.manifestId = md.manifestid
		where
				mfstOkToDownload = 1
		and		md.manifestid is null

		
        --  New for billing: We're including collection manifests but we don't want to 
        --  download a collection manifest that doesn't have any valid invoices
        --  In cases where there might be more than one unpaid invoice for a given account,we
        --  need to make sure we only pull the most recent invoice (downstream systems--namely
        --  the PDAs-- expect a 1:1 relationship between Invoice and Account
        SELECT
             I.CompanyId            as [CompanyId]
            ,I.distributioncenterid as [DistributionCenterId]
            ,tmp.ManifestId         as [ManifestId]
            ,I.AccountId            as [AccountId]
            ,MAX(I.InvoiceDate)     as [InvoiceDate]
        INTO #LatestInvoices
        FROM
            #manifests tmp
		JOIN
			scManifestSequences ms on (ms.ManifestID = tmp.ManifestID)
		JOIN
			scAccountsPubs ap     on  ( ap.CompanyId = tmp.CompanyId
									AND ap.DistributionCenterId = tmp.DistributionCenterId
									AND ap.AccountPubId = ms.AccountPubID)
        JOIN
            scInvoices        I ON  (   I.CompanyId = ap.CompanyId
                                    AND I.DistributionCenterId = ap.DistributionCenterId
                                    AND I.AccountId = ap.AccountId )
        WHERE
            I.InvoiceDate <= @mfst_date
		AND	tmp.mfstType = 2
        GROUP BY I.CompanyId,I.DistributionCenterID,tmp.ManifestId,I.AccountId


		SELECT
			 LI.CompanyId				as [CompanyId]
			,LI.distributionCenterId	as [DistributionCenterId]
			,LI.ManifestId				as [ManifestId]
		INTO
			#UnpaidInvoices
		FROM
			#LatestInvoices LI
		JOIN
			scInvoices I		ON	(	I.CompanyId = LI.CompanyId
                                    AND I.DistributionCenterId = LI.DistributionCenterId
                                    AND I.AccountId = LI.AccountId 
				    AND I.InvoiceDate = LI.InvoiceDate )
		JOIN 
			scAccounts     Act	ON   (Act.CompanyId = I.CompanyID
				AND Act.DistributionCenterId = I.DistributionCenterID
				AND Act.AccountId = I.AccountID
				AND Act.AcctActive = 1)

		WHERE
			I.DatePaid IS NULL

        UPDATE   #manifests
        SET      mfstOkToDownload = 0
                ,mfstStatusMsg = N'No Invoice data found.'
        FROM
            #manifests tmp
        LEFT JOIN
            #UnpaidInvoices UI
                                ON  (   UI.CompanyId = tmp.CompanyId
                                    AND UI.DistributionCenterId = tmp.DistributionCenterID
                                    AND UI.ManifestId = tmp.ManifestId )
        WHERE
			tmp.mfstType = 2
		AND
        	UI.ManifestId IS NULL

        --  Return the complete recordset to caller...
        select
             companyid
            ,distributioncenterid
            ,manifestid
            ,mfstcode
            ,mfstname
            ,mfstType
            ,mfstOKtodownload
            ,mfstStatusMsg
            ,@mfst_date      As mfstdate
        from
            #manifests

		order by mfstcode

set nocount off
end



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[scManifestList_SelectByDevice]  TO [nsUser]
GO
