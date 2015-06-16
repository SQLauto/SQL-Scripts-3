IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[scManifestLoad_View]'))
DROP VIEW [dbo].[scManifestLoad_View]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[scManifestLoad_View]
as
/*
	
*/

	select 		
		 DrawDate							as drawdate
		,DrawDate							as deliverydate
		,isnull( DrawAmount, 0 )			as drawamount
		--| nsPublications
		,isnull( ltrim( rtrim( PubCode ) ) , '' )		as publication
		,0.0								as drawrate
		--| scManifests
		,isnull( ltrim( rtrim( coalesce( MfstName, MfstCode ) ) ) , '' )		as mfstname
		,isnull( ltrim( rtrim( MfstCode ) ) , '' )		as mfstcode
		,N''								as mfstdescription
		,N''								as mfstnotes
		,N''								as mfstcustom1
		,N''								as mfstcustom2
		,N''								as mfstcustom3
		,N''								as mfstowner
		--| scAccounts
		,isnull( ltrim( rtrim( AcctName ) ) , '' )							as acctname
		,isnull( ltrim( rtrim( AcctCode ) ) , '' )							as acctcode
		,N''								as acctdescription
		,coalesce(AcctType,'UNKN')			as accttype
		,coalesce(AcctCategory,'NONE')		as acctcategory
		,N''								as acctnotes
		,isnull( ltrim( rtrim( AcctAddress ) ) , '' )						as acctaddress
		,isnull( ltrim( rtrim( AcctCity ) ) , '' )						as acctcity
		,N''								as acctstateprovince
		,isnull( ltrim( rtrim( AcctPostalCode ) ) , '' )						as acctpostalcode
		,N''								as acctcountry
		,N''								as AcctContact
		,N''								as AcctHours
		,N''								as AcctPhone
		,N''								as AcctCreditCardOnFile
		,N''								as acctcustom1
		,N''								as acctcustom2
		,N''								as acctcustom3
		,N''								as acctspecialinstructions
		,0									as acctrollup
		--| scDrops
		,N''								as dropname
		,N''								as dropsequence
		,N''								as dropdescription
		,N''								as dropaddress
		,N''								as dropcity
		,N''								as dropstateprovince
		,N''								as dropcountry
		,N''								as droppostalcode
		,N''								as dropdeliveryinstructions
		,N''								as acctcorporate
		-- New fields for 3.0 follow.  Until they start being included in
		-- a circulation system file, we use default values.
		--| scAccountsPubs
		,null								as DeliveryStartDate
		,null								as DeliveryStopDate
		,null								as ForecastStartDate
		,null								as ForecastStopDate
		,0									as ExcludeFromBilling
		,1									as AcctPubActive
		,N''								as APCustom1
		,N''								as APCustom2
		,N''								as APCustom3
		--| scDefaultDraws
		,1								as AllowForecasting
		,1								as AllowReturns
		,1								as AllowAdjustments
		,0								as ForecastMinDraw
		-- Application code uses Int32.MaxValue as highest possible ForecastMaxDraw
		,2147483647							as ForecastMaxDraw
	from dbo.support_adhoc_import_normalized()

GO


