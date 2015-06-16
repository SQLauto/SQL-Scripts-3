IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[scManifestLoad_View]'))
DROP VIEW [dbo].[scManifestLoad_View]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[scManifestLoad_View]
as
/********************************************************************************************************

	trim values
	trap for null values 

********************************************************************************************************/

	select 		
		rundate							as drawdate
		, rundate							as deliverydate
		--| nsPublications
		,isnull( ltrim( rtrim( productid ) ), '' )		as publication
		--| scDraws
		,isnull( drawtotal, 0 )					as drawamount
		,coalesce( drawrate, 0.0 )				as drawrate
		--| scManifests
		,isnull( ltrim( rtrim( truckname ) ), '' )		as mfstname
		,isnull( ltrim( rtrim( truckid ) ), '' ) 		as mfstcode
		,N''							as mfstdescription
		,N''							as mfstnotes
		,N''							as mfstcustom1
		,N''					 		as mfstcustom2
		,N'' 							as mfstcustom3
		,N''							as mfstowner
		--| scAccounts
		,isnull( ltrim( rtrim( carriername ) ), '' )		as acctname
		,isnull( ltrim( rtrim( routeid ) ), '' )		as acctcode
		,N''							as acctdescription
		,isnull( ltrim( rtrim( routetype ) ), '' )		as accttype
		,N''							as acctcategory
		,N''							as acctnotes
		,isnull( ltrim( rtrim( droplocation ) ), '' )		as acctaddress
		,N'' 							as acctcity
		,N''							as acctstateprovince
		,N''							as acctpostalcode
		,N''							as acctcountry
		,N''								as AcctContact
		,N''								as AcctHours
		,N''								as AcctPhone
		,N''								as AcctCreditCardOnFile
		,N''							as acctcustom1
		,N''							as acctcustom2
		,N''							as acctcustom3
		,isnull( ltrim( rtrim( dropinstructions ) ), '' )	as acctspecialinstructions
		,0								as acctrollup
		--	---------------------------------------------------------------------
		--	AcctCorporate flag.  Input data must be mapped as follows:
		--	- value mapped to 1 indicates a Corporate Account
		--	- value mapped to 0 indicates a Regular Account
		--	- NULL value indicates no change
		--	Will set to NULL so that no change is made by default
		-------------------------------------------------------------------------
		, case RouteType
			when 'CORP' then 1
			else 0
			end								as AcctCorporate		
		--| scDrops
		,N''								as dropname
		,isnull( ltrim( rtrim( truckdroporder ) ), '' )	as dropsequence
		,N''								as dropdescription
		,N''								as dropaddress
		,N''								as dropcity
		,N''								as dropstateprovince
		,N''								as dropcountry
		,N''								as droppostalcode
		,N''								as dropdeliveryinstructions

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
		,1									as AllowForecasting
		,1									as AllowReturns
		,1									as AllowAdjustments
		,0									as ForecastMinDraw
		-- Application code uses Int32.MaxValue as highest possible ForecastMaxDraw
		,2147483647							as ForecastMaxDraw

		/*
		-- When 3.0 fields show up in a file, suggested mappings are:
		--| scAccountsPubs
		,cast(DeliveryStartDate as datetime)				as DeliveryStartDate
		,cast(DeliveryStopDate as datetime)					as DeliveryStopDate
		,cast(ForecastStartDate as datetime)				as ForecastStartDate
		,cast(ForecastStopDate as datetime)					as ForecastStopDate
		,isnull( ltrim( rtrim(ExcludeFromBilling) ), 0 )	as ExcludeFromBilling
		,isnull( ltrim( rtrim(AcctPubActive) ), 1 )			as AcctPubActive
		,isnull( ltrim(	rtrim(APCustom1) ), '' )			as APCustom1
		,isnull( ltrim(	rtrim(APCustom2) ), '' )			as APCustom2
		,isnull( ltrim(	rtrim(APCustom3) ), '' )			as APCustom3
		--| scDefaultDraws
		,isnull( ltrim( rtrim(AllowForecasting) ), 1 )		as AllowForecasting
		,isnull( ltrim( rtrim(AllowReturns) ), 1 )			as AllowReturns
		,isnull( ltrim( rtrim(AllowAdjustments) ), 1 )		as AllowAdjustments

		,isnull( ltrim( rtrim(ForecastMinDraw) ), 0 )		as ForecastMinDraw
		-- Application code uses Int32.MaxValue as highest possible ForecastMaxDraw
		,isnull( ltrim( rtrim(ForecastMaxDraw) ), 2147483647 )	as ForecastMaxDraw
		*/		
	from scmanifestload



GO


