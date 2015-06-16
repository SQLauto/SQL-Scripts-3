IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[scManifestLoad_View]'))
DROP VIEW [dbo].[scManifestLoad_View]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE    view [dbo].[scManifestLoad_View] --with schemabinding
as
/********************************************************************************************************

	scManifestLoad_View
	
		scManifestLoad_View is responsible for filtering out "future" data (e.g. Data with a 
		DeliveryDate greater than "tomorrow") from the data currently being processed.  
		scManifestLoad_View is also responsible for combining this data with the appropriate 
		data from scManifestLoad_FutureDates (e.g. DeliveryDate = "tomorrow").
		
		Changes to field mapping are now done in scManifestLoad_View_Prelim.
	
	$History: /SingleCopy/Branches/SC_3.1.4/Customers/TRIB/Database/Scripts/Views/dbo.scManifestLoad_View.SQL $
-- 
-- ****************** Version 11 ****************** 
-- User: kerry   Date: 2010-12-07   Time: 09:42:50-05:00 
-- Updated in: /SingleCopy/Branches/SC_3.1.4/Customers/TRIB/Database/Scripts/Views 
-- Case 15529 - Modify Import Process at Tribune to handle future changes 

********************************************************************************************************/
	select 
		  v.drawdate
		, v.deliverydate
		, datepart(dw, v.deliverydate) as [drawweekday]
		, v.publication
		, v.drawamount
		, v.drawrate
		, v.mfstname
		, v.mfstcode
		, v.mfstdescription
		, v.mfstnotes
		, v.mfstcustom1
		, v.mfstcustom2
		, v.mfstcustom3
		, v.mfstowner
		, v.acctname
		, v.acctcode
		, v.acctdescription
		, v.accttype
		, v.acctcategory
		, v.acctnotes
		, v.acctaddress
		, v.acctcity
		, v.acctstateprovince
		, v.acctpostalcode
		, v.acctcountry
		, v.acctcustom1
		, v.acctcustom2
		, v.acctcustom3
		, v.acctspecialinstructions
		, v.acctcontact
		, v.acctphone
		, v.acctcreditcardonfile
		, v.accthours
		, v.acctrollup
		, v.dropname
		, v.dropsequence
		, v.dropdescription
		, v.dropaddress
		, v.dropcity
		, v.dropstateprovince
		, v.dropcountry
		, v.droppostalcode
		, v.dropdeliveryinstructions
		, v.DeliveryStartDate
		, v.DeliveryStopDate
		, v.ForecastStartDate
		, v.ForecastStopDate
		, v.ExcludeFromBilling
		, v.AcctPubActive
		, v.APCustom1
		, v.APCustom2
		, v.APCustom3
		, v.AllowForecasting
		, v.AllowReturns
		, v.AllowAdjustments
		, v.ForecastMinDraw
		, v.ForecastMaxDraw
		
		, a.AccountID
		, p.PublicationID
		, ap.AccountPubID
		, d.DrawID
		, dd.AccountID as [DefaultDraw_AccountId]
	from dbo.scManifestLoad_View_Prelim v
	left join scAccounts a
		on v.AcctCode = a.AcctCode
	left join nsPublications p
		on v.publication = p.PubShortName
	left join scAccountsPubs ap
		on a.CompanyID = ap.CompanyID
		and a.DistributionCenterID = ap.DistributionCenterID
		and a.AccountID = ap.AccountId
		and p.PublicationID = ap.PublicationId
	left join scDraws d
		on a.CompanyID = d.CompanyID
		and a.DistributionCenterID = d.DistributionCenterID
		and a.AccountID = d.AccountID
		and p.PublicationID = d.PublicationID
		and v.DrawDate = d.DrawDate		
	left join scDefaultDraws dd
		on dd.CompanyID = 1
		and dd.DistributionCenterID = 1
		and dd.AccountID = a.AccountID
		and dd.PublicationID = p.PublicationID
		and dd.DrawWeekday = datepart(dw, v.drawdate)		
/*	where DATEDIFF(d, DATEADD(d, 1, convert(nvarchar, getdate(), 1)), DeliveryDate) <= 0
	
	union all 
	select 	
		  drawdate
		, deliverydate
		, publication
		, drawamount
		, drawrate
		, mfstname
		, mfstcode
		, mfstdescription
		, mfstnotes
		, mfstcustom1
		, mfstcustom2
		, mfstcustom3
		, mfstowner
		, acctname
		, acctcode
		, acctdescription
		, accttype
		, acctcategory
		, acctnotes
		, acctaddress
		, acctcity
		, acctstateprovince
		, acctpostalcode
		, acctcountry
		, acctcustom1
		, acctcustom2
		, acctcustom3
		, acctspecialinstructions
		, acctcontact
		, acctphone
		, acctcreditcardonfile
		, accthours
		, acctrollup
		, dropname
		, dropsequence
		, dropdescription
		, dropaddress
		, dropcity
		, dropstateprovince
		, dropcountry
		, droppostalcode
		, dropdeliveryinstructions
		, DeliveryStartDate
		, DeliveryStopDate
		, ForecastStartDate
		, ForecastStopDate
		, ExcludeFromBilling
		, AcctPubActive
		, APCustom1
		, APCustom2
		, APCustom3
		, AllowForecasting
		, AllowReturns
		, AllowAdjustments
		, ForecastMinDraw
		, ForecastMaxDraw
	from dbo.scManifestLoad_FutureDates
	where DATEDIFF(d, DATEADD(d, 1, convert(nvarchar, getdate(), 1)), DeliveryDate) = 0
	and AppliedDateTime is null
*/



GO


