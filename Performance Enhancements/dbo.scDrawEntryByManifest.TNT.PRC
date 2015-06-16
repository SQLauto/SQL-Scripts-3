if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[scDrawEntryByManifest]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[scDrawEntryByManifest]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[scDrawEntryByManifest]
	@CompanyID	 INT
	,@DistributionCenterID INT
	,@ManifestID	 INT
	,@FIRSTDATE	 DATETIME
	,@LASTDATE	 DATETIME
	,@SELECTEDDATE	 DATETIME	 --used for determining the which drop sequence to use, given that this can vary from day to day depending on manifest sequence
	,@SortColumn tinyint = 0
AS
/*=========================================================
	scDrawEntryByManifest_sniff
	Selects the Draw information for a given date range
	for the given manifest

	Returns Draw as well as any existing Adj and Return information

	Date: 11/28/2003
	Author: robcom

	$History: /Gazette/Database/Scripts/Sprocs/dbo.scDrawEntryByManifest_sniff.PRC $
==========================================================*/
BEGIN
SET NOCOUNT ON

declare @maskCompanyID	 INT
declare @maskDistributionCenterID INT
declare @maskManifestID	 INT
declare @maskFIRSTDATE	 DATETIME
declare @maskLASTDATE	 DATETIME
declare @maskSELECTEDDATE	 DATETIME
declare @maskSortColumn tinyint
declare @returnThreshold int
	
	set	@maskCompanyID = @CompanyID
	set	@maskDistributionCenterID = @DistributionCenterID
	set	@maskManifestID = @ManifestID
	set 	@maskFIRSTDATE = DATEADD( DAY, DATEDIFF( DAY, 0, @FIRSTDATE ), 0 )
	
	--set 	@maskLASTDATE = DATEADD( DAY, DATEDIFF( DAY, 0, @LASTDATE ), 0 )
	set	@maskLASTDATE = case 
					when datediff(d, getdate(), @LASTDATE) > 0 then DATEADD( DAY, DATEDIFF( DAY, 0, GETDATE() ), 0 )
					else DATEADD( DAY, DATEDIFF( DAY, 0, @LASTDATE ), 0 )
					end

	set	@maskSELECTEDDATE = DATEADD( DAY, DATEDIFF( DAY, 0, @SELECTEDDATE ), 0 )
	set	@maskSortColumn = @SortColumn

	declare @dtNow datetime
	set @dtNow = dbo.GetCompanyDate(GetDate())

	--set DATEFIRST 7

	--Get the drop sequences for accounts based on the "Selected Date"
	create table #sequence (
		AccountId int
		, DropSequence int
		, MfstCode nvarchar(20)
		, MfstName nvarchar(50)
		, ManifestOwner int
	primary key (accountid)
	)
	
	insert into #sequence(
		  AccountId
		, DropSequence
		, MfstCode
		, MfstName
		, ManifestOwner
	)
	select 
		ap.AccountId
		, max(ms.Sequence)
		, MfstCode
		, MfstName
		, ManifestOwner
	from scManifests m
	join scManifestSequences ms 
		on m.ManifestId = ms.ManifestId
	join scAccountsPubs ap 
		on ap.AccountPubId = ms.AccountPubId
	where m.ManifestDate = @maskSELECTEDDATE
	and m.ManifestTemplateid = @maskManifestID
	group by ap.AccountId, MfstCode, MfstName, ManifestOwner


	--|  Get draw for accounts/pubs on the Manifest for the Selected Date
	create table #tempAcctDraw (
		  AccountId int
		, PublicationId int
		, DrawWeekday int
		, DrawDate datetime
		, DrawId int
		, DrawAmount int
		, RetAmount int
		, AdjAmount int
		, AdjAdminAmount int
		, RollupAcctId int
	primary key ( AccountId, PublicationId, DrawWeekday )
	)

	insert into #tempAcctDraw ( AccountID, PublicationId, DrawWeekday, DrawDate, DrawId, DrawAmount, RetAmount, AdjAmount, AdjAdminAmount, RollupAcctId )
	select  prelim.AccountID, prelim.PublicationId, DrawWeekday, DrawDate, DrawId, DrawAmount, RetAmount, AdjAmount, AdjAdminAmount, RollupAcctId 
	from (
		select 
			ap.AccountId, ap.PublicationId
		from scManifests m
		join scManifestSequences ms 
			on m.ManifestId = ms.ManifestId
		join scAccountsPubs ap
			on ms.AccountPubId = ap.AccountPubId
		join scAccounts a
			on a.AccountId = ap.AccountId
		where m.ManifestDate = @maskSELECTEDDATE
		and m.ManifestTemplateid = @maskManifestID
		and a.AcctActive = 1
		) prelim  
	join scDraws d
		on prelim.AccountId = d.AccountId
		and prelim.PublicationId = d.PublicationId 
	where d.drawdate between @maskFIRSTDATE and @maskLASTDATE
	
	
	--|  Using temp tables instead of the inline function call to dbo.scOverThreshhold()
	CREATE TABLE #PubVDB( PublicationId INT Primary Key, MinDate DATETIME )
	CREATE TABLE #ATVDB ( AccountTypeId INT Primary Key, MinDate DATETIME )

	INSERT #PubVDB
	SELECT VDB.PublicationId
	,	CASE WHEN ( datediff(day, (dateadd(day, ( (floor((datediff(day, VDB.periodStartDate, @dtNow)) / VDB.periodLength)) * VDB.periodLength), VDB.periodStartDate) ), @dtNow) + 1 ) >= VDB.PeriodCutoffDay 
	THEN	dateadd(day, ((floor((datediff(day, VDB.periodStartDate, @dtNow)) / VDB.periodLength)) * VDB.periodLength), VDB.periodStartDate)
	ELSE dateadd(day, (VDB.periodLength * -1),(dateadd(day, ((floor((datediff(day, VDB.periodStartDate, @dtNow)) / VDB.periodLength)) * VDB.periodLength), VDB.periodStartDate)))
	END	AS MinDate
	FROM	scVariableDaysBack VDB
	JOIN	nsPublications P ON P.PublicationId = VDB.PublicationId

	INSERT #ATVDB
	SELECT
	VDB.AccountTypeId
	,	CASE WHEN ( datediff(day, (dateadd(day, ( (floor((datediff(day, VDB.periodStartDate, @dtNow)) / VDB.periodLength)) * VDB.periodLength), VDB.periodStartDate) ), @dtNow) + 1 ) >= VDB.PeriodCutoffDay 
	THEN	dateadd(day, ((floor((datediff(day, VDB.periodStartDate, @dtNow)) / VDB.periodLength)) * VDB.periodLength), VDB.periodStartDate)
	ELSE dateadd(day, (VDB.periodLength * -1),(dateadd(day, ((floor((datediff(day, VDB.periodStartDate, @dtNow)) / VDB.periodLength)) * VDB.periodLength), VDB.periodStartDate)))
	END	AS MinDate
	FROM	scVariableDaysBack VDB
	JOIN	dd_scAccountTypes A ON A.AccountTypeID = VDB.AccountTypeId

	select @returnThreshold = isnull( sysPropertyValue, 7 )
	from syncSystemProperties
	where sysPropertyName = 'ReturnThreshhold'

	--Return the results
	select d.AccountId, d.PublicationId, p.PrintSortOrder, d.DrawId
		, seq.MfstCode, seq.MfstName
		, u.UserName
		, seq.DropSequence
		, a.AcctCode, a.AcctName, a.AcctAddress, a.AcctCity, a.AcctStateProvince, a.AcctPostalCode
		, p.PubShortName
		, d.DrawAmount, d.DrawDate
		--	 ,dbo.scOverThreshhold( @dtNow, DRAW.DrawDate, ACCT.AccountTypeID, PUBS.PublicationId ) 
		--AS [overdatathreshhold] /* is this draw too 'old' for any data entry? */
		,CASE WHEN d.DrawDate < COALESCE( avdb.minDate, pvdb.minDate, DATEADD(dd, -1*@returnThreshold, @dtNow) )
			THEN 1
			ELSE 0
			END AS [overdatathreshhold]
		, isnull(d.AdjAmount,0) as [AdjAmount]
		, isnull(d.AdjAdminAmount,0) as [AdjAdminAmount]
		, isnull(d.RetAmount,0) as [RetAmount]
	, d.DrawAmount + isnull(d.AdjAmount,0) + isnull(d.AdjAdminAmount,0) - isnull(d.RetAmount,0) as [NetSales]
	, typ.ATName as [AcctType]
	, NULL as [ManifestSequenceId]
	, d.RollupAcctId as [RollupAccount]
	, r.RollupCode as [RollupAcctCode]
	, dd.AllowReturns, dd.AllowAdjustments
	into #unsorted
	from #tempAcctDraw d
	join scDefaultDraws dd
		on d.AccountId = dd.AccountId
		and d.PublicationId = dd.PublicationId
		and d.DrawWeekday = dd.DrawWeekday
	join #sequence seq
		on d.AccountId = seq.Accountid
	left join Users u
		on seq.ManifestOwner = u.UserId
	join scAccounts a
		on seq.AccountId = a.AccountId
	join nsPublications p
		on d.PublicationId = p.PublicationId
	join dd_scAccountTypes typ
		on a.AccountTypeId = typ.AccountTypeId
	left join scRollups r
		on d.RollupAcctId = r.RollupId
	left join #pubVDB pvdb 
		on pvdb.PublicationId = p.PublicationId
	left join #ATVDB avdb 
		on avdb.AccountTypeId = a.AccountTypeId
	--order by cast(seq.DropSequence as int), a.AcctCode, p.PrintSortOrder, d.DrawDate
	order by cast(seq.DropSequence as int), a.AcctCode, p.PubShortName, d.DrawDate


	-- finally sort the data and return...
	if @maskSortColumn = 1
		select * from #unsorted order by acctcode,printsortorder,drawdate
	else if @maskSortColumn = 2
		select * from #unsorted order by acctname,printsortorder,drawdate
	else
		select * from #unsorted order by dropsequence,acctcode,printsortorder,drawdate

	drop table #unsorted
	drop table #sequence
	drop table #tempAcctDraw

SET NOCOUNT OFF

END

GO
GRANT EXECUTE ON [dbo].[scDrawEntryByManifest] TO [nsuser] AS [dbo]