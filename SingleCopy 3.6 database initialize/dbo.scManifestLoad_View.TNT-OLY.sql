IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[scManifestLoad_View]'))
DROP VIEW [dbo].[scManifestLoad_View]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE  VIEW [dbo].[scManifestLoad_View]
as
/********************************************************************************************************

	trim values
	trap for null values 
	
	$History: /SingleCopy/Branches/SC_3.1.4/Customers/TNT/Database/Scripts/Views/dbo.scManifestLoad_View.SQL $
-- 
-- ****************** Version 11 ****************** 
-- User: kerry   Date: 2010-08-20   Time: 15:35:57-04:00 
-- Updated in: /SingleCopy/Branches/SC_3.1.4/Customers/TNT/Database/Scripts/Views 
-- Case 14357 - Default new imported accounts to allow forecasting for NT/OL 
-- only 
-- 
-- ****************** Version 6 ****************** 
-- User: kerry   Date: 2009-10-08   Time: 12:49:31-04:00 
-- Updated in: /Gazette/Customer Specific/TNT/Database/Views 
-- Case 11007 - Default new imported accounts to not allow forecasting 
-- 
-- ****************** Version 5 ****************** 
-- User: kerry   Date: 2009-10-08   Time: 12:48:21-04:00 
-- Updated in: /Gazette/Customer Specific/TNT/Database/Views 
-- Customer Specific usage of import fields 
--
-- ****************** Version 3 ****************** 
-- User: kerry   Date: 2009-09-10   Time: 10:15:00-04:00 
-- Updated in: /Gazette/Customer Specific/PBS/Database/views 
-- 
-- ****************** Version 2 ****************** 
-- User: kerry   Date: 2009-08-31   Time: 11:38:33-04:00 
-- Updated in: /Gazette/Customer Specific/PBS/Database/views 
-- Case 10229 - Update DTI (PBS) interfaces for 3.1 
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

	select 		
		cast( RunDate as datetime )							as drawdate
		--| If customer's source file does not contain delivery date, then just
		--| return the same date that is used for drawdate (that is, make both
		--| the draw date and the delivery date refer to same input date from 
		--| manifest file.
		,cast( RunDate as datetime )						as deliverydate

		--| nsPublications
		,isnull( ltrim( rtrim( left(productid, 5) ) ) , '' )			as publication
		,isnull( DrawTotal, 0 )								as drawamount
		--| drawrate column must return a data type of decimal(8,5) so the appropriate
		--| data conversion/cast must be done here to ensure proper handling
		--| of customer's rate value.  If customer file contains no Rate information
		--| then simply return 0.0 here
		,N'0.0' 							as drawrate

		--| scManifests
		,isnull( ltrim( rtrim( truckname ) ), '' )			as mfstname
		,isnull( ltrim( rtrim( truckid ) ), '' ) 			as mfstcode
		,N''								as mfstdescription
		,N''								as mfstnotes
		,N''								as mfstcustom1
		,N''								as mfstcustom2
		,N''								as mfstcustom3
		,N''								as mfstowner
		--| scAccounts
		,isnull( ltrim( rtrim( droplocation ) ), '' )		as acctname
		,isnull( ltrim( rtrim( routeid ) ), '' )			as acctcode
		,N''								as acctdescription
		,isnull( ltrim( rtrim( routetype ) ), '' )			as accttype
		,isnull( ltrim( rtrim( depotid ) ), '' )			as acctcategory
		,N''								as acctnotes
		,isnull( left( ltrim( rtrim( dropinstructions ) ), 128), '' )	as acctaddress
		,N''								as acctcity
		,N''								as acctstateprovince
		,N''								as acctpostalcode
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
		,isnull( ltrim( rtrim( truckdroporder ) ), '' )			as dropsequence
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
		,/*case db_name()
			when 'Tacoma_SN' then
				case when ltrim( rtrim( left(productid, 5) ) ) = 'NT'
					then null
					else '12/31/9999'
				end
			when 'Olympia_SN' then	
				case when ltrim( rtrim( left(productid, 5) ) ) = 'OL'
					then null
					else '12/31/9999'
				end	
			else null
			end*/ null									as DeliveryStartDate
		,/*case db_name()
			when 'Tacoma_SN' then
				case when ltrim( rtrim( left(productid, 5) ) ) = 'NT'
					then null
					else '1/1/1900'
				end
			when 'Olympia_SN' then	
				case when ltrim( rtrim( left(productid, 5) ) ) = 'OL'
					then null
					else '1/1/1900'
				end	
			else null
			end*/null								as DeliveryStopDate
		,null								as ForecastStartDate
		,null								as ForecastStopDate
		,0								as ExcludeFromBilling
		,1								as AcctPubActive
		,N''								as APCustom1
		,N''								as APCustom2
		,N''								as APCustom3
		--| scDefaultDraws
		,case db_name()
			when 'NSDB_TNT' then
				case ltrim( rtrim( left(productid, 5) ) )
					when 'NT' then 1
					else 0
				end
			when 'NSDB_OLY' then	
				case ltrim( rtrim( left(productid, 5) ) )
					when 'OL' then 1
					else 0
				end	
			else 0
			end													AS AllowForecasting
		,1								as AllowReturns
		,1								as AllowAdjustments
		,0								as ForecastMinDraw
		-- Application code uses Int32.MaxValue as highest possible ForecastMaxDraw
		,2147483647							as ForecastMaxDraw
		--	---------------------------------------------------------------------
		--	AcctCorporate flag.  Input data must be mapped as follows:
		--	- value mapped to 1 indicates a Corporate Account
		--	- value mapped to 0 indicates a Regular Account
		--	- NULL value indicates no change
		--	Will set to NULL so that no change is made by default
		-------------------------------------------------------------------------
	,	NULL														AS AcctCorporate 

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
	FROM 
		dbo.scManifestLoad




GO


