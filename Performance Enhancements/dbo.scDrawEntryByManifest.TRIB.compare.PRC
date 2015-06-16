USE [NSDB_CHI]
GO
/****** Object:  StoredProcedure [dbo].[scDrawEntryByManifest]    Script Date: 09/09/2013 12:51:11 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[scDrawEntryByManifest]
	 @CompanyID		        INT
	,@DistributionCenterID 	INT
	,@ManifestID		    INT
	,@FIRSTDATE		        DATETIME
	,@LASTDATE		        DATETIME
	,@SELECTEDDATE			DATETIME		--used for determining the which drop sequence to use, given that this can vary from day to day depending on manifest sequence
    ,@SortColumn            tinyint = 0
AS
/*=========================================================
    scDrawEntryByManifest
        Selects the Draw information for a given date range
    for the given manifest

    Returns Draw as well as any existing Adj and Return information

    Date:   11/28/2003
    Author: robcom
    
    $History: /SingleCopy/Branches/SC_3.1.4/Core/Database/Scripts/Sprocs/dbo.scDrawEntryByManifest.PRC $
-- 
-- ****************** Version 24 ****************** 
-- User: jpeaslee   Date: 2010-05-14   Time: 08:38:21-07:00 
-- Updated in: /SingleCopy/Branches/SC_3.1.4/Core/Database/Scripts/Sprocs 
-- Case 13208 weekly returns page timing out due to SQL server parameter 
-- sniffing in dbo.scDrawEntryByManifest.prc. 
-- 
-- ****************** Version 22 ****************** 
-- User: mmisantone   Date: 2009-01-21   Time: 09:34:55-05:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 7483 
-- 
-- ****************** Version 21 ****************** 
-- User: mmisantone   Date: 2008-12-10   Time: 13:18:06-05:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 6557 
-- 
-- ****************** Version 20 ****************** 
-- User: rreffner   Date: 2008-09-18   Time: 13:46:11-04:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 5954 
-- 
-- ****************** Version 19 ****************** 
-- User: rreffner   Date: 2008-06-12   Time: 12:01:17-04:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 4128 
-- 
-- ****************** Version 18 ****************** 
-- User: rreffner   Date: 2008-06-06   Time: 11:35:21-04:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 4128 
    
-- ****************** Version 16 ****************** 
-- User: rreffner   Date: 2008-06-03   Time: 09:30:12-04:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 4128 
-- 
-- ****************** Version 17 ****************** 
-- User: jboardman   Date: 2008-05-27   Time: 14:16:24-04:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 4213 
-- 
-- ****************** Version 16 ****************** 
-- User: rreffner   Date: 2008-05-20   Time: 09:30:12-04:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 2724 

    Change History
    -------------------------------------------------------
    Date        Author      Reference       Description
    -------------------------------------------------------
    1/19/04     robcom      customer fdbk   Added new column to scDrawAdjustments
                                            to track adjustments made by admins for 
                                            recovery, reconciliation, etc.
                                            Modifed srproc to return this column
    2/3/04      robcom      customer fdbk   Added a check for only Active Accounts
    03/30/04    robcom      BUG000224       Added support for 'closed accounts'
    03/30/04    robcom      CHG000225       Added 'sorting' flag to allow users to choose
                                            the order of their data
    07/21/04	robcom		Gazette V2		Moving this script to separate file and modifying
											to support PDA downloads for PDA version 1.0

	12/28/04	robcom		SLC Upgrade		Added Drop Completion Date/time to output
	06/14/05	robcom		Rollup Acct		Added filter to restrict selection to NON-rollup
											accounts only
											Added addtl column for 'rollup acct'
	11/09/2005	robcom		V2.5			Fixed support for closed accounts to work with multiple
											date range
	11/10/2005	robcom		V2.5			Added support to check Return Threshhold value from System Properties
											to restrict data entry passed certain date
											Removed "lastDraw" column - this was a PDA 1.0 only column and is no
											longer needed (plus, the computation for lastdraw would break down if
											more than one day was passed into sproc)
	11/10/2005	robcom		V2.5			Added additional sort column to make sure data is sorted by drawdate
	12/02/2005	robcom		v2.5			Fixed small bug where too many records were returned for Collector routes
	01/23/2006	johnp		v2.5			Change sysprop name to 'ReturnThreshhold', as required by new Sys Config page
	03/30/2006	johnp		REQ00052		Show bulldog accounts only on Sunday
	06/20/2006	johnp		BUG00044		Duplicate data in weekly returns
    08/22/2006  robcom      bug             Changed sort columns to allow for multi accounts with same seq #                                            
	11/07/2006	johnp		REQ00083		Implement variable days back
	03/27/2007	johnp		Case 245		Variable days back by pub and account type
	04/24/2008  boardman    Case 3746       scDraw/adj/rtn normalization
	05/12/2008	Reffner		Case 2724		Added GetCompanyDate() functionality
    	05/22/2008    	jimb        	Case 4213       	Rollup Overhaul
    	06/03/2008	Reffner		Case 4128		Rollup Overhaul
==========================================================*/
BEGIN
SET NOCOUNT ON

	declare
		 @maskCompanyID		        INT
		,@maskDistributionCenterID 	INT
		,@maskManifestID		    INT
		,@maskFIRSTDATE		        DATETIME
		,@maskLASTDATE		        DATETIME
		,@maskSELECTEDDATE			DATETIME
		,@maskSortColumn            tinyint

	set	@maskCompanyID = @CompanyID
	set	@maskDistributionCenterID = @DistributionCenterID
	set	@maskManifestID = @ManifestID
	SET @maskFIRSTDATE = DATEADD( DAY, DATEDIFF( DAY, 0, @FIRSTDATE ), 0 )
	SET @maskLASTDATE  = DATEADD( DAY, DATEDIFF( DAY, 0, @LASTDATE  ), 0 )
	set	@maskSELECTEDDATE = DATEADD( DAY, DATEDIFF( DAY, 0, @SELECTEDDATE ), 0 )
	set	@maskSortColumn = @SortColumn

	DECLARE  @LastDateMod		datetime
			,@RollupType		int
			,@dayOfWeek			int
			,@restrictBulldogs	varchar(1)	-- 'Y' or 'N' to show bulldogs only on Sunday
			,@dtNow				datetime	-- used for threshold checks

	-- dates were normalized above (had their time components removed) but we
	-- need to add 23Hours, 59minutes and 59seconds to our 'last date' to ensure
	-- complete coverage
	SET @LastDateMod   = DATEADD( SECOND, 86399 , @maskLASTDATE )

print 'last date is ' + convert(varchar(20),@lastDateMod,101)
			
	set @dtNow = dbo.GetCompanyDate(GetDate())
	set DATEFIRST 7                                     -- force Sunday = day 1

/*
	-- Create a list of account types to include, honoring the bulldogs-on-Sunday-only rules, and always eliminating rollups.
	create table #accttypes (AccountTypeId int not null, ATName varchar(50))
	insert #accttypes select AccountTypeId, ATName from dd_scAccountTypes 
*/

	-- Different manifest sequences for the same manifest means that you can have different drop numbers assigned for the same
	-- account for different days of the week.  We'll determine which drop number we'll use based on the manifest sequence
	-- for the date entered when accessing the data entry page.
	create table #custdrops(
		 accountid int not null
		,sequence int not null
		)
	insert into #custdrops(
		 accountid
		,sequence)
		select distinct
				ap.accountid,
				ms.sequence
		from scManifests m
		join scmanifestSequences ms on (ms.manifestid = m.manifestid)
		join scACcountsPubs ap on (ap.accountpubid = ms.accountpubid)
		where m.manifestdate = @maskSELECTEDDATE
		and m.manifesttemplateid = @maskManifestID
print 'found ' + cast(@@ROWCOUNT as varchar) + ' accounts for  ' + CONVERT(VARCHAR(20),@maskSelecteddate,100)
	set @dayOfWeek = datepart(dw, @maskFIRSTDATE)
/*
	set @restrictBulldogs = (select syspropertyvalue FROM dbo.syncsystemproperties 
								WHERE syspropertyname = N'BulldogReturnsSundayOnly')

	if upper(@restrictBulldogs) = 'Y'
	begin
		if @dayOfWeek <> 1 -- Sunday
		begin
			-- Accounts with bulldog account type are included only on Sunday
			delete from #accttypes where AccountTypeId in
				( select atyp.AccountTypeId from dd_scAccountTypes atyp
				  join syncSystemProperties sp on (atyp.ATName = sp.SysPropertyValue and sp.SysPropertyName like 'BullDogType%') )
		end
	end
*/

	-- First, identify the candidate account records based on our criteria...
	-- (we're using scManifestSequences and scAccountsPubs to link Accounts & Manifests)
	create table #tempaccounts(
		 companyid int not null
		,distributioncenterid int not null
		,accountid int not null
		,manifestid int not null
		,manifestSequenceId int not null
		,rollupAccountId int null
		--,accttype nvarchar(5)
		--,accttypeid int not null
		--,instruct nvarchar(256)
--		,constraint pk_temp_account primary key(companyid,distributioncenterid,accountid,manifestid)
		)
	insert #tempaccounts( 
		companyid
		,distributioncenterid
		,accountid
		,manifestid
		,manifestSequenceId
		,rollupAccountId
	 )
	select distinct
		 1
		,1
		,acct.accountid
		,mfst.manifestid
		,MS.Sequence
		,ca.AccountId				-- get the rollup account if it exists...
	from
			scManifests 		MFST
		INNER JOIN
			scManifestSequences MS		ON MFST.ManifestId = MS.ManifestId
		INNER JOIN
			scAccountsPubs		AP		ON (AP.companyId = MFST.CompanyID
										AND AP.DistributionCenterID = MFST.DistributionCenterID
										AND AP.AccountPubID	= MS.AccountPubID )
		INNER JOIN
			scAccounts			ACCT 	ON (ACCT.CompanyID = AP.CompanyID
										AND ACCT.DistributionCenterID = AP.DistributionCenterID
				            			AND ACCT.AccountID = AP.AccountID)
		LEFT JOIN
			scChildAccounts		ca 		on (ca.companyid = acct.companyid
										and ca.distributioncenterid = acct.distributioncenterid
										and ca.ChildAccountId = acct.AccountId )
			
	where
		MFST.CompanyID 		    	= 1
	AND	MFST.DistributionCenterID   = 1
	AND	MFST.ManifestTemplateID     = @maskManifestID
	AND MFST.ManifestDate			BETWEEN @maskFIRSTDATE AND @LastDateMod
	AND ACCT.AcctActive             = 1


	print 'found ' + cast(@@ROWCOUNT as varchar) + ' accounts. '

	--	then, retrieve the actual data
	SELECT distinct
		ta.AccountId			AS [AccountId]
		,PUBS.PublicationId		AS [PublicationId]
		,DRAW.DrawId			AS [DrawId]
		,MFST.MfstCode			AS [MfstCode]
		,MFST.MfstName			AS [MfstName]
		,U.UserName				AS [MfstOwner]
		,CD.Sequence			AS [DropSequence]	
		,ACCT.AcctCode			AS [AcctCode]
		,ACCT.AcctName			AS [AcctName]
		,ACCT.AcctAddress		AS [AcctAddress]
		,ACCT.AcctCity			AS [AcctCity]
		,ACCT.AcctStateProvince	AS [AcctStateProvince]
		,ACCT.AcctPostalCode	AS [AcctPostalCode]
		,PUBS.PubShortName		AS [PubShortName]
		,DRAW.DrawAmount		AS [DrawAmount]
		,DRAW.DrawDate			AS [DrawDate]


		,dbo.scOverThreshhold( @dtNow, DRAW.DrawDate, ACCT.AccountTypeID, PUBS.PublicationId ) 
								AS [overdatathreshhold]   /* is this draw too 'old' for any data entry? */


   		,ISNULL(DRAW.AdjAmount,0)			AS [AdjAmount]
   		,ISNULL(DRAW.AdjAdminAmount,0)       AS [AdjAdminAmount]
		,ISNULL(DRAW.RetAmount,0)			AS [RetAmount]
		,( DRAW.DrawAmount
		+ ISNULL(DRAW.AdjAmount,0)
     		+ ISNULL(DRAW.AdjAdminAmount,0) )
		- ISNULL(DRAW.RetAmount,0)	        AS [NetSales]
		,AT.ATName				AS [AcctType]
		,TA.manifestSequenceId			AS [ManifestSequenceID]
		,ta.RollupAccountID				AS [RollupAccount]
		,(SELECT RU.RollupCode FROM scRollups RU Where RollupId = ta.RollupAccountId) AS [RollupAcctCode]
		,(SELECT AllowReturns FROM scDefaultDraws WHERE CompanyId = 1 AND DistributionCenterId = 1 AND AccountId = ACCT.AccountId AND PublicationId = DRAW.PublicationId AND DrawWeekday = DRAW.DrawWeekday) AS AllowReturns
		,(SELECT AllowAdjustments FROM scDefaultDraws WHERE CompanyId = 1 AND DistributionCenterId = 1 AND AccountId = ACCT.AccountId AND PublicationId = DRAW.PublicationId AND DrawWeekday = DRAW.DrawWeekday) AS AllowAdjustments
	INTO #unsorted
	FROM
		#tempaccounts	as TA
	INNER JOIN
		scAccounts 	AS ACCT ON (ACCT.CompanyID = ta.CompanyID
								AND ACCT.DistributionCenterID = ta.DistributionCenterID
			            		AND ACCT.AccountID = ta.AccountID)
	INNER JOIN
		scAccountsPubs AS AP ON (AP.CompanyID = ta.CompanyID
								 AND AP.DistributionCenterID = ta.DistributionCenterId
								 AND AP.AccountId = ACCT.accountId)
	JOIN dd_scAccountTypes AT ON (ACCT.AccountTypeID = AT.AccountTypeID)
/*
	INNER JOIN
		scManifestSequences	AS MS ON MS.AccountPubId = AP.AccountPubId
*/
	inner join
		scManifests	AS MFST on (MFST.CompanyID = 1
								AND MFST.DistributionCenterID = 1
								AND MFST.ManifestId = TA.manifestid)
	INNER JOIN
		Users		As U	ON (MFST.ManifestOwner = U.UserId)
	INNER JOIN
		nsPublications	AS PUBS	ON (ACCT.CompanyID = PUBS.CompanyID
								AND ACCT.DistributionCenterID = PUBS.DistributionCenterID
								AND AP.PublicationId = PUBS.PublicationID )
	INNER JOIN 
		scDraws 	AS DRAW ON (DRAW.CompanyID = ta.CompanyID
								AND DRAW.DistributionCenterId = ta.DistributionCenterID
								AND DRAW.AccountID = AP.AccountId
								AND DRAW.PublicationId = AP.PublicationId
								AND DRAW.DrawDate = MFST.ManifestDate)
	INNER JOIN
		#custdrops as CD on (CD.accountid = TA.accountid)			-- join against table of drops for date selected.  If account is not on manifest for selected date, it will not appear on wkly returns page.
	WHERE
		DRAW.DrawDate BETWEEN @maskFIRSTDATE AND @LastDateMod
	--	MFST.ManifestDate BETWEEN @maskFIRSTDATE AND @LastDateMod
	--AND	MFST.ManifestTemplateId = @maskManifestID						-- have to add this here as well to handle the case of collector routes (where an account may be on more than 1 mfst)

	-- finally sort the data and return...
	if @maskSortColumn = 1
		select * from #unsorted order by acctcode,pubshortname,drawdate
	else if @maskSortColumn = 2
		select * from #unsorted order by acctname,pubshortname,drawdate
	else
		select * from #unsorted order by dropsequence,acctcode,pubshortname,drawdate

	Drop Table #tempaccounts

SET NOCOUNT OFF

END


