--	The view gets executed every time a DB upgrade is run (like the stored procedures)
--	However, this particular view is highly customizable and dependent on a given Customer setup
--	therefore, we DON'T want to re-run this view because of the risk of overwriting an existing 
--	Customer-specific implementation.  We only want to execute this if there is no view there currently.
--	NOTE:
--		Of course, this means we can 'update' the view by simply changing the code and upgrading. We'll have
--		to come up with some specific mechanisms for doing that.
--
BEGIN TRAN
GO

IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[scManifestLoad_View]') and OBJECTPROPERTY(id, N'IsView') = 1)
	DROP VIEW dbo.scManifestLoad_View
GO

CREATE VIEW dbo.scManifestLoad_View
AS
/********************************************************************************************************

	This new 'default' view will be used for clean installs. It's a simplified version used to
	match to the BCP format file and default scManifestLoad table structure. We'll reduce this
	to some of the minimal data points needed to demonstrate/test a manifest import.
		
	$History: /Gazette/Database/Scripts/Views/dbo.scManifestLoad_View.SQL $
-- 
-- ****************** Version 8 ****************** 
-- User: robcom   Date: 2009-04-22   Time: 15:21:02-07:00 
-- Updated in: /Gazette/Database/Scripts/Views 
-- Case 6756 
-- 
-- ****************** Version 7 ****************** 
-- User: jpeaslee   Date: 2008-10-09   Time: 13:38:55-07:00 
-- Updated in: /Gazette/Database/Scripts/Views 
-- Case 6260 
-- 
-- ****************** Version 6 ****************** 
-- User: rreffner   Date: 2008-06-06   Time: 11:35:21-04:00 
-- Updated in: /Gazette/Customer Specific/Template/Standard/Database 
-- Case 4128 
-- 
-- ****************** Version 5 ****************** 
-- User: jboardman   Date: 2008-05-27   Time: 14:19:53-04:00 
-- Updated in: /Gazette/Database/Scripts/Views 
-- Case 4213 
-- 
-- ****************** Version 4 ****************** 
-- User: robcom   Date: 2007-08-09   Time: 13:58:34-07:00 
-- Updated in: /Gazette/Customer Specific/Template/Standard/Database 
-- Case 403 

	update: 01/20/2007 to match up with standard *.fmt and scManifestLoad Tables for
						default installation

********************************************************************************************************/

	SELECT
		--	---------------------------------------------------------------------
		--	Draw and Delivery dates. [Date] is required and expected
		--	in a valid date format (MM/DD/YYYY). Delivery Date is optional
		--	if provided, it should be in MM/DD/YYYY format. If not provided
		--	then we return [Date] as Delivery Date.
		--	---------------------------------------------------------------------
		CAST( [Date]	AS DATETIME )								AS [Date]		
	,	CAST( [Date]	AS DATETIME )								AS DeliveryDate
		--	---------------------------------------------------------------------
		--	Publication data. Pub Code is required from the import file
		--	---------------------------------------------------------------------
	,	LTRIM( RTRIM( PubShortName ) )								AS Publication
		--	---------------------------------------------------------------------
		--	Draw Information. Draw is required (even if it's zero). Rate is Optional
		--	---------------------------------------------------------------------
	,	CAST( Draw AS INT )											AS DrawAmount
	,	0.0														AS DrawRate
		--	---------------------------------------------------------------------
		--	Manifest Data. Only required fields in default import is the CODE.
		--  Upstream processes take care of defaulting the Name if necessary
		--	---------------------------------------------------------------------
	,	LTRIM( RTRIM( MfstCode ) )								AS MfstCode
	,	LTRIM( RTRIM( TruckName ) )								AS MfstName
	,	N''															AS MfstDescription
	,	N''															AS MfstNotes
	,	N''															AS MfstCustom1
	,	N''															AS MfstCustom2
	,	N''															AS MfstCustom3
	,	N''															AS MfstOwner
		--	---------------------------------------------------------------------
		--	Account Data.  We require Account Code and Account Name but the other
		--	Fields are optional.
		--	---------------------------------------------------------------------
	,	LTRIM( RTRIM( AcctCode ) )									AS AcctCode
	,	LTRIM( RTRIM( AcctName ) )									AS AcctName
	,	N''															AS AcctDescription
	,	LTRIM( RTRIM( LocationType ) )									AS AcctType
	,	LTRIM( RTRIM( LocationCat ) )								AS AcctCategory
	,	N''															AS AcctNotes
	,	LTRIM( RTRIM( AcctAddress ) )								AS AcctAddress
	,	LTRIM( RTRIM( AcctCity ) )									AS AcctCity
	,	N''															AS AcctStateProvince
	,	LTRIM( RTRIM( AcctZip ) )									AS AcctPostalCode
	,	N''															AS AcctCountry
	,	N''															AS AcctContact
	,	N''															AS AcctHours
	,	N''															AS AcctPhone
	,	N''															AS AcctCreditCardOnFile
	,	N''															AS AcctCustom1
	,	N''															AS AcctCustom2
	,	N''															AS AcctCustom3
	,	N''															AS AcctSpecialInstructions
	,	CASE RollupAcct
			WHEN 'Y'	THEN 1
			WHEN 'N'	THEN 0
			ELSE 0
		END															AS acctrollup
		--	---------------------------------------------------------------------
		--	'Drop' information. This is just the relationship between an account
		--	(location) and a manifest. Specifically, a delivery Sequence order.
		--	Delivery Sequence is not required from the import file.
		--	The other columns here are left over from earlier versions and are left
		--	in for backward compatibility. The only field that is used is 
		--	DropSequence
		--	---------------------------------------------------------------------
	,	LTRIM( RTRIM( LocationSeq ) )							AS DropSequence
--	,	N''													as dropname
--	,	N''													as dropdescription
--	,	N''													as dropaddress
--	,	N''													as dropcity
--	,	N''													as dropstateprovince
--	,	N''													as dropcountry
--	,	N''													as droppostalcode
--	,	N''													as dropdeliveryinstructions
		--	---------------------------------------------------------------------
		--	New fields for 3.0 follow.  Until they start being included in
		--	a circulation system file, we use default values.
		--	When/If these values ARE provided in a Customer Import file, then
		--	the defaults shown below should be used whenever the import data
		--	is blank (i.e., customer file includes a column for AllowForecasting
		--	but doesn't provide an actual value in the column)
		--	---------------------------------------------------------------------
	,	NULL												AS DeliveryStartDate
	,	NULL												AS DeliveryStopDate
	,	NULL												AS ForecastStartDate
	,	NULL												AS ForecastStopDate
	,	0													AS ExcludeFromBilling
	,	1													AS AcctPubActive
	,	N''													AS APCustom1
	,	N''													AS APCustom2
	,	N''													AS APCustom3
	,	1													AS AllowForecasting
	,	1													AS AllowReturns
	,	1													AS AllowAdjustments
	,	0													AS ForecastMinDraw
	-- Application code uses Int32.MaxValue as highest possible ForecastMaxDraw
	,	2147483647											AS ForecastMaxDraw
	FROM 
		dbo.scManifestLoad
GO

GRANT SELECT ON dbo.scManifestLoad_View TO nsUser
GO

COMMIT TRAN
GO
