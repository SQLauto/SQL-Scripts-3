USE [nsdb27]
GO
/****** Object:  StoredProcedure [dbo].[scDeliveryReceipts_Select]    Script Date: 01/21/2011 12:09:23 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[scDeliveryReceipts_Select]
	@CompanyID			int,
	@DistributionCenterID		int,
	@AccountId			int,
	@ManifestID			int,
	@DeviceID			int,
	@startDate			datetime,
	@endDate			datetime

AS
/*=========================================================
	dbo.scDeliveryReceipts_Select

$History: /Gazette/Database/Scripts/Sprocs/dbo.scDeliveryReceipts_Select.prc $
-- 
-- ****************** Version 2 ****************** 
-- User: rreffner   Date: 2009-01-21   Time: 09:34:34-05:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 7008 
-- 
-- ****************** Version 1 ****************** 
-- User: rreffner   Date: 2008-11-10   Time: 09:55:16-05:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 2189 

==========================================================*/
BEGIN
	exec NormalizeStartStopDates @startDate, @endDate, @startDate output, @endDate output

declare @pCompanyId int
declare @pDistributionCenterId int
declare @pAccountId int
declare @pManifestId int
declare @pDeviceId int
declare @pStartDate datetime
declare @pEndDate datetime

set @pCompanyId = @CompanyId
set @pDistributionCenterId = @DistributionCenterId 
set @pAccountId = @AccountId
set @pManifestId = @ManifestId
set @pDeviceId = @DeviceId
set @pStartDate = @StartDate
set @pEndDate = @EndDate 


	set nocount on
	SELECT 
		DR.CompanyID,
		DR.DistributionCenterID,
		DV.DeviceCode,
		MF.MfstCode,
		MF.MfstName,
		A.AcctCode,
		A.AcctName,
		A.AcctAddress,
		A.AcctCity,
		A.AcctStateProvince,
		A.AcctPostalCode,
		DR.ReceiptDate,
		MF.ManifestID,
		A.AccountID,
		"" AS PubDescription,
		(GetDate()) AS Drawdate,
		0 AS DrawQty,
		0 AS ReturnQty,
		"" AS SignatureFilePath

		
		
	FROM
		scDeliveryReceipts DR
	JOIN 
		nsPublications P ON (DR.PublicationID = P.PublicationID)
	JOIN
		scAccounts A ON (DR.AccountID = A.AccountID)
	JOIN
		nsDevices DV ON (DR.DeviceID = DV.DeviceID)
	JOIN
		scManifests MF ON (DR.ManifestID = MF.ManifestID)
	JOIN
		scManifestTemplates MT ON (MT.ManifestTemplateId = MF.ManifestTemplateId)
	JOIN
		scDraws D ON (DR.AccountID = D.AccountID) AND (DR.PublicationID = D.PublicationID) AND (DR.DrawDate = D.DrawDate)
	WHERE
		DR.CompanyID = @pCompanyID 		AND
		DR.DistributionCenterID = @pDistributionCenterID	
AND
		((A.AccountId = @pAccountId) OR (@pAccountId = -1))	
AND
		((DV.DeviceID = @pDeviceID) OR (@pDeviceID = -1)) 
AND
		((MT.ManifestTemplateId = @pManifestID) OR (@pManifestId = -1)) AND
		(DR.ReceiptDate BETWEEN @pStartDate AND @pEndDate)
	GROUP BY
		DR.CompanyID, DR.DistributionCenterID, DV.DeviceCode, MF.MfstCode, MF.MfstName, A.AcctCode, A.AcctName, A.AcctAddress, A.AcctCity, A.AcctStateProvince, A.AcctPostalCode, DR.ReceiptDate, MF.ManifestID, A.AccountID
	ORDER BY 
		DR.ReceiptDate DESC, A.AcctName ASC
END	


