--VERSION 2
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[scDefaultDraws_Import]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[scDefaultDraws_Import]
GO

create procedure dbo.scDefaultDraws_Import
As
/*=========================================================
    scDefaultDraws_Import
        Loads default draw for accounts that are newly
    imported into the system

	LOADS BOTH DEFAULT DRAWS AND REGULAR DRAWS (scDraws records)
	from import file

    01/01/04
    robcom

--$History: /Gazette/Database/Scripts/Sprocs/dbo.scDefaultDraws_Import.PRC $
-- 
-- ****************** Version 20 ****************** 
-- User: cbeagle   Date: 2009-09-15   Time: 08:48:59-04:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 8204 - Manifest Import Process Does not create Draw History records 
-- for New Draw values 
-- 
-- ****************** Version 19 ****************** 
-- User: robcom   Date: 2009-07-06   Time: 08:54:07-07:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 9167 - Import Bulk (rollup) draw 
-- 
-- ****************** Version 18 ****************** 
-- User: robcom   Date: 2009-06-25   Time: 13:02:06-07:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- case 9935 - removed @Delivery arg from scDefaultDraws_Import 
-- 
-- ****************** Version 17 ****************** 
-- User: mmisantone   Date: 2009-05-27   Time: 11:07:18-04:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 8507 
-- 
-- ****************** Version 16 ****************** 
-- User: kerry   Date: 2009-02-25   Time: 20:58:06-05:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 7799 - scDefaultDraws_Import process breaks when Adding New 
-- Publications to system 
-- 
-- ****************** Version 15 ****************** 
-- User: jpeaslee   Date: 2008-12-08   Time: 07:40:31-08:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 6555 Implement changes to Import Process for new Manifest Management 
-- 
-- ****************** Version 14 ****************** 
-- User: jpeaslee   Date: 2008-12-01   Time: 07:10:21-08:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 6853 Improve diagnostic output of some stored procedures used for 
-- import 
-- 
-- ****************** Version 13 ****************** 
-- User: jpeaslee   Date: 2008-10-09   Time: 13:38:37-07:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 6260 
-- 
-- ****************** Version 12 ****************** 
-- User: rreffner   Date: 2008-05-20   Time: 09:30:12-04:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 2724 
-- 
-- ****************** Version 9 ****************** 
-- User: robcom   Date: 2007-08-09   Time: 13:39:42-07:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 401 
-- 
-- ****************** Version 8 ****************** 
-- User: jpeaslee   Date: 2007-07-09   Time: 11:47:49-07:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 359 
-- 
-- ****************** Version 7 ****************** 
-- User: jpeaslee   Date: 2007-06-15   Time: 11:17:21-07:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Case 236 - replace ##tempDraws with local temp table 
--
    Mods
    Date        author      ref         desc
    ----------  ---------   ----------- ------------------
    02/05/04    robcom      CHG000199   If imported Draw Value does
                                        not match Deflt Draw in Sync, we will
                                        now overwrite the Syncronex value
                                        instead of ignoring the new value
                                        We'll continue to log a warning message however
    02/11/04    robcom      CHG000199   Backing out the previous change. We want to 
                                        ignore GEAC draw amounts until we go live
                                        otherwise, the zero values within GEAC will
                                        overwrite the numbers that Wichita is coming up
                                        with during the rollout period.
    04/02/04    robcom      CHG000229   Officially making GEAC the system of record. That is, overwrite
                                        Syncronex values if GEAC import values are different...
    11/11/04	robcom		SANJOSE		Adding new Company/DC hardcoded values
    02/07/05	robcom		misc		Setting default Company back to 1 to make this a 'general' script file.
    
    02/09/05	robcom		sLC			Modified for SLC specific data import
    03/21/05	Kerry		ADN			Modified for ADN specific data import
    06/2/05		Kerry		ADN			Resolved issue converting datetime to varchar which caused draws not to be imported.
    Jan 06		Kerry		n/a			Modified to use scmanifestload_view
	04/07/06	johnp		Billing		Include draw rate in scDefaultDrawHistory
	08/01/06	johnp		CHG00047	Handle draw values in invoice import
	05/12/08	Reffner		Case 2724	Added GetCompanyDate() functionality
==========================================================*/
begin
set nocount on
    declare @companycode int, @dccode int
    set		@companycode = 1
    set		@dccode      = 1
    
    declare @msg    nvarchar(512)
    declare @cnt    int
    declare @cntprint    int
    declare @err	int
    declare @importChangeType int
	declare @companyDate datetime
	declare @start datetime
	declare @elapsed datetime

	set @start = getdate()
	set @elapsed = @start


	set @msg = 'scDefaultDraws_Import starting... (Elapsed: ' + dbo.support_Duration(@start, getdate()) + ')'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	--print 'scDefaultDraws_Import starting...'	
	set @elapsed = getdate()

	--	Preprocessing to ensure that our import data looks reasonable
	--	(i.e., no more than one week's worth of data)
	if exists(	select	count(drawamount)
				from	scManifestLoad_View	
				group by	acctcode,publication,datepart(dw,drawdate)
				having count(drawamount) > 1 )
	begin
		--	this is a case when the file contains multiple weekday's (i.e., two different Fridays) worth of data
/*  --Commented out @msg due to a bug
		select	top 1 @msg = (datename(dw,drawdate) + ' for account: ' + acctcode + ' and pub: ' + publication)
		from	scManifestLoad_View
				group by	acctcode,publication,drawdate,datename(dw,drawdate)
				having count(drawamount) > 1
*/
		--set @msg = N'Manifest Import File contains multiple records for the same weekday. First occurrence: ' + @msg
		set @msg = N'Manifest Import File contains multiple records for the same weekday'
		goto error
	end
	if exists(	select	count(drawamount)
				from	scManifestLoad_View	
				group by	acctcode,publication,datepart(dw,deliverydate)
				having count(drawamount) > 1 )
	begin
		--	this is a case when the file contains multiple weekday's (i.e., two different Fridays) worth of data (based on delivery date)		
		select	top 1 @msg = (datename(dw,deliverydate) + ' for account: ' + acctcode + ' and pub: ' + publication)
		from	scManifestLoad_View
				group by	acctcode,publication,deliverydate,datename(dw,deliverydate)
				having count(drawamount) > 1

		set @msg = N'Manifest Import File contains multiple records for the same delivery weekday. First occurrence: ' + @msg
		goto error
	end

	set @msg = ''

	--	Look for new Publication Codes provided by the Import File
	--	this is typically only seen during the first few imports, but
	--	it can happen subsequently. old system errored out, but new
	--	version will add the publication if needed.
	exec nsPublications_Import

	
	--	What dates are we processing?  Here, we want the delivery dates
	--	as we'll be using these dates later to 'fill in gaps' in draw to 
	--	ensure that PDAs/Laydown Sheets get account details even when those
	--	accounts don't have draw for a given day (this is the situation with
	--	'missing accounts'
	
	create table #ProcessingDates(
		  [date] datetime not null
		, [drawweekday] int not null
		constraint pk_date_drawweekday primary key clustered ([date], [drawweekday])
	)
	insert	#ProcessingDates( [date], [drawweekday] )
	select distinct deliverydate, datepart(dw, deliverydate) from scmanifestload_view
	
	--	Create a comma-sep list of dates for logging purposes
	declare @datestr nvarchar(1024)
--	declare date_cursor cursor for select date from #ProcessingDates

	select @datestr = COALESCE(@datestr+',' ,'') + convert(nvarchar(10),[date],101)
	from #ProcessingDates
	
	set @msg = 'scDefaultDraws_Import found the following delivery dates within the source file: ' + @datestr
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()


	--	this table will hold imported data for accounts/pubs/weekdays that
	--	have been previously imported (or perhaps an account that was
	--	also created manually in Syncronex and given draw via forecasting)
	create table #ExistingDefaultDraw (
		 accountid		int not null
		,publicationid	int not null
		,draw			int	not null
		,drawdate		datetime not null
		,deliverydate	datetime not null
		,drawweekday	tinyint not null
		,drawrate		decimal(8,5) not null
		,allowforecasting	tinyint
		,allowreturns		tinyint
		,allowadjustments	tinyint
		,forecastmindraw	int not null
		,forecastmaxdraw	int not null
		constraint pk_#ExistingDefaultDraw primary key clustered (accountid, publicationid, drawweekday, drawdate, deliverydate)
	)
/*
	create table #ExistingDraw (
		 accountid		int not null
		,publicationid	int not null
		,drawdate		datetime not null
		,deliverydate	datetime not null
		,drawweekday	tinyint not null
		,drawid int not null
		constraint pk_#ExistingDraw primary key clustered (accountid, publicationid, drawweekday, drawdate, deliverydate, drawid)
	)
*/
	--	collect 'new' data (NOTE: We're assuming that previous
	--	processes have handled the inserts of new accounts/manifests,etc
	--	so although we have new data, we can be sure that an scAccounts record
	--	already exists for these
	create table #NewDrawData(
		 accountid		int	not null
		,publicationid	int not null
		,draw			int not null		-- by defn, this is new data coming from import...there had better be data there
		,drawdate		datetime not null
		,deliverydate	datetime not null
		,drawweekday	tinyint not null
		,drawrate		decimal(8,5) not null	
		,allowforecasting	tinyint
		,allowreturns		tinyint
		,allowadjustments	tinyint
		,forecastmindraw	int not null
		,forecastmaxdraw	int not null
		constraint pk_#newdraw primary key clustered (accountid, publicationid, drawweekday, drawdate, deliverydate)
	)	
	
	--	this table will hold imported data for accounts/pubs/weekdays that
	--	have corresponding scDefaultDraws records but do not have scDraws
	--	records
	--
	--	it will be used to capture scDraw record information for creating
	--	scDrawHistory records for newly created scDraws records
	create table #InsertedDraw (
		 accountid		int not null
		,publicationid	int not null
		,drawdate		datetime not null
		,deliverydate	datetime not null
		,drawweekday	tinyint not null
		constraint pk_#inserted primary key clustered (accountid, publicationid, drawweekday, drawdate, deliverydate)
	)

	--
	-- Retreive the existing draw data
	--	

	set @msg = 'Creating Indexes on temp tables...'
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()

	CREATE NONCLUSTERED INDEX idx_#ExistingDefaultDraw_convering
	ON #ExistingDefaultDraw ([AccountID],[PublicationId],[DrawWeekday],[DrawDate], [DeliveryDate])
	include ( Draw, DrawRate )

	set @msg = 'Indexes on temp tables created successfully.  '
		 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()


	set @msg = 'Inserting data into #ExistingDefaultDraw...'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()

	insert #ExistingDefaultDraw(
		 accountid
		,publicationid
		,draw
		,drawdate
		,deliverydate
		,drawweekday
		,drawrate
		,allowforecasting
		,allowreturns
		,allowadjustments
		,forecastmindraw
		,forecastmaxdraw
	)
	select
		 a.accountid
		,p.publicationid
		,v.drawamount
		,v.drawdate
		,v.deliverydate
		,datepart(dw, v.drawdate)
		,v.drawrate		
		,v.allowforecasting
		,v.allowreturns
		,v.allowadjustments
		,v.forecastmindraw
		,v.forecastmaxdraw
	from
		scManifestLoad_View	v
	join
		scAccounts a on ( v.acctcode = a.acctcode )
	join
		nsPublications p on ( v.publication = p.pubshortname )
	join
		scDefaultDraws dd 
	on (
			dd.CompanyID = 1
			and dd.DistributionCenterID = 1 
			and a.accountid = dd.accountid 
			and dd.publicationid = p.publicationid 
			and datepart(dw,v.drawdate) = dd.drawweekday
		)
			
	where
		v.acctrollup = 0	-- case 9167 - We don't want rollup account's here

	set @msg = cast(@@rowcount as varchar) +  ' records inserted into #ExistingDefaultDraw.  '
		 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()

	--	Get New records -- new accounts+pub combos. NOTE: We assume here that
	--	previous steps in the import process have taken care of creating valid
	--	scAccounts records so we know we have AccountId available to us here

	set @msg = 'Inserting data into #NewDrawData...'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()
	
	insert #NewDrawData(
		 accountid
		,publicationid
		,draw
		,drawdate
		,deliverydate
		,drawweekday
		,drawrate
		,allowforecasting
		,allowreturns
		,allowadjustments
		,forecastmindraw
		,forecastmaxdraw
	)
	select
		 a.accountid
		,p.publicationid
		,v.drawamount
		,v.drawdate
		,v.deliverydate
		,datepart(dw, v.drawdate)
		,v.drawrate		
		,v.allowforecasting
		,v.allowreturns
		,v.allowadjustments
		,v.forecastmindraw
		,v.forecastmaxdraw
	from
		scManifestLoad_View	v
	join
		scAccounts a on ( v.acctcode = a.acctcode )
	join
		nsPublications p on ( v.publication = p.pubshortname )
	left join
		scDefaultDraws dd 
	on (
			dd.CompanyID = 1
			and dd.DistributionCenterID = 1 
			and a.accountid = dd.accountid 
			and dd.publicationid = p.publicationid 
			and datepart(dw,v.drawdate) = dd.drawweekday
		)
	where 
		dd.accountid is null
	and	v.acctrollup = 0		-- case 9167 - We don't want rollup account's here

	set @msg = cast(@@rowcount as varchar) +  ' records inserted into #NewDrawData.  '
		 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()


--select * from #NewDrawData		
--select * from #ExistingDefaultDraw
--drop table #NewDrawData
--drop table #ExistingDefaultDraw
--return 1
	
	--	Update existing data from the import file. Note, we might have the following
	--	cases:
	--	1) scDefaultDraws record exists but no scDraws record exists ( this is most common )
	--	2) scDefaultDraws record exists and scDraws record exists (would happen due to forecasting or a previous import)
	--	
	--	For case 1: Insert the scDraw record as given in the import file
	--	For case 2: If scDraw amount is different from import amount, then change the draw amount in syncronex
	--				and change forecasted draw amount in scDrawForecasts (if it exists)


	--	Insert new data from the import file. By definition, these are cases where
	--	there was no existing scDefaultDraws record and, therefore, no scDraws so
	--	it's a relatively simple 'insert' in both cases

	set @msg = 'Beginning d2 transaction (new data)...'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()
	
	begin tran d2
	
	insert	scDefaultDraws (
		 CompanyID
		,DistributionCenterID
        ,AccountID
        ,PublicationID
        ,DrawWeekday
        ,DrawAmount
        ,DrawRate
		,AllowForecasting
		,AllowReturns
		,AllowAdjustments
		,ForecastMinDraw
		,ForecastMaxDraw
	)
	select
		 1
		,1
		,nd.accountid
		,nd.publicationid
		,nd.drawweekday
		,nd.draw
		,nd.drawrate
		,nd.allowforecasting
		,nd.allowreturns
		,nd.allowadjustments
		,nd.forecastmindraw
		,nd.forecastmaxdraw
	from
		#NewDrawData nd
		
	select	@cnt = @@rowcount, @cntprint=@@rowcount, @err = @@error
	set @msg = cast(@cntprint as varchar) +  ' records inserted into scDefaultDraws.  '
		 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()

	if @err <> 0
		begin
			rollback tran d2
			set @msg = 'An error occurred while trying to add new Default Draw Records '
					 + 'Error is: ' 
					 + (select description from master..sysmessages where error = @err and msglangid=1033)
			drop table #NewDrawData
			goto error
		end

	select @importChangeType = ChangeTypeId from dd_nsChangeTypes where ChangeTypeName = 'DataImport'

	insert	scDraws(
		 CompanyID
		,DistributionCenterID
		,AccountID
		,PublicationID
		,DrawWeekday
		,DrawDate
		,DeliveryDate
		,DrawAmount
		,DrawRate
		,LastChangeType)
	select
		 1
		,1
		,nd.accountid
		,nd.publicationid
		,nd.drawweekday
		,nd.drawdate
		,nd.deliverydate
		,nd.draw
		,nd.drawrate
		,@importChangeType
	from
		#NewDrawData nd

	select	@cnt = @@rowcount, @cntprint = @@rowcount, @err = @@error

	set @msg = cast(@cntprint as varchar) +  ' records inserted into scDraws.  '
		 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()
	
	if @err <> 0
		begin
			rollback tran d2
			set @msg = 'An error occurred while trying to add new Draw Records '
					 + 'Error is: ' 
					 + (select description from master..sysmessages where error = @err and msglangid=1033)
			drop table #NewDrawData
			goto error
		end

---------------------------------------------------------------

	-- insert scDrawHistory Records for new scDraws records being created
	-- when must create new scDefautDraws records
	set @companyDate = dbo.GetCompanyDate(GetDate())
	insert dbo.scDrawHistory(
		 CompanyID
		,DistributionCenterID
		,accountid
		,publicationid
		,drawid
		,drawweekday
		,changeddate
		,drawdate
		,olddraw
		,newdraw
		,oldrate
		,newrate
		,olddeliverydate
		,newdeliverydate
		,changetypeid)
	select
		 1
		,1
		,D.AccountId
		,D.PublicationId
		,D.DrawId
		,D.Drawweekday
		,@companyDate
		,D.DrawDate
		,D.DrawAmount
		,D.DrawAmount
		,D.DrawRate
		,D.DrawRate
		,D.DeliveryDate
		,D.DeliveryDate
		,@importChangeType
	from
		#NewDrawData nd
	join
		dbo.scDraws D 
		on (
			1 = D.CompanyID
			and 1 = D.DistributionCenterID
			and nd.Accountid = D.AccountId 
			and	nd.PublicationId = D.PublicationId
			and	nd.drawweekday = D.drawweekday
			and	nd.DrawDate = D.DrawDate 
		)

	select @cnt = (@cnt - @@rowcount), @cntprint=@@rowcount, @err = @@error

	set @msg = cast(@cntprint as varchar) +  ' records inserted into scDrawHistory.  '
		 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()

	if @err <> 0
	begin
		rollback tran d2
		set @msg = 'An error occurred while trying to add records to scDrawHistory. Error is: '
				 + (select description from master..sysmessages where error = @err and msglangid=1033)
		goto error
	end --if @err<>0

	if @cnt <> 0	-- means that our two rowcounts didn't match up!
	begin
		rollback tran d2
		set @msg = 'The rowcount for inserting scDraws did not match rowcount from scDrawHistory Insert! '
		goto error
	end --if @cnt<>0


------------------------------------------------------------------------------



	--print 'Inserted ' + cast(@cntprint as varchar) + ' draw records for new data'




	commit tran d2	-- insertion of draw/dfltdraw	


	set @msg = 'd2 Transaction completed.  '
		 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()
	

	--	Deal with the draw that we've already got (that is, we've got matching
	--	default draw records)
	--	This gives us two cases to deal with:
	--	1)	scDraws records exists (i.e., previous import or a forecasting run)
	--	2)	scDraws don't exist ( this is our normal situation if there is no forecasting)
	--	For #1, compare both dflt draw and draw and change if different
	--	For #2, just compare dflt draw and change if necessary then insert the draw record
-- Debug section
-- print 'Existing Records Processing Start: ' + convert( varchar, dbo.GetCompanyDate(GetDate()), 14 ) -- print out start time
-- End Debug section


	set @msg = 'Beginning T1 transaction (existing data)...'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()


begin tran T1
	--
	--	First, check the scDefaultDraws table for differences. If 
	--	differences are found we: A) Insert a history record and B) modify scDefaultDraws
	--	no differences = no changes to scDefaultDraws at all
	insert dbo.scDefaultDrawHistory(
         CompanyID
        ,DistributionCenterID
        ,AccountID
        ,PublicationID
        ,DrawWeekday
        ,DrawHistoryID
        ,DrawHistoryDate
        ,DrawHistOldDraw
        ,DrawHistNewDraw
        ,DrawHistOldRate
        ,DrawHistNewRate
        ,ChangeTypeID
	)
	select
		 1
		,1
		,DD.AccountId
		,DD.PublicationId
		,DD.DrawWeekday
		,(select isnull(max(DrawhistoryId),0) + 1 from dbo.scDefaultDrawHistory	where	companyid=1
														and     distributioncenterid = 1
														and     accountid = ED.AccountId
														and     publicationid = ED.PublicationId
														and     drawweekday = ED.drawweekday )
		,@companyDate
		,DD.DrawAmount
		,ED.Draw
		,DD.DrawRate
		,ED.DrawRate
		,1		-- Change by Import
	from
		#ExistingDefaultDraw ED
	join
		dbo.scDefaultDraws DD on (	
								1 = dd.CompanyID
								and 1 = dd.DistributionCenterID
								and ED.AccountId	= DD.AccountID
								and	ED.PublicationId= DD.PublicationId
								and ED.DrawWeekday	= DD.DrawWeekday )
	where
		(	DD.DrawAmount <> ED.Draw	)
	or	(	DD.DrawRate	  <> ED.DrawRate)
	
	select	@cnt = @@rowcount, @cntprint=@@rowcount, @err = @@error
	set @msg = cast(@cntprint as varchar) +  ' records inserted into scDefaultDrawsHistory.  '
		 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()
	
	
	if @err <> 0
	begin
		rollback tran T1
		set @msg = 'An error occurred while trying to add records to scDefaultDrawHistory. Error is: '
				 + (select description from master..sysmessages where error = @err and msglangid=1033)
		goto error
	end --if @err<>0

	Update	dbo.scDefaultDraws
	Set		DrawAmount	=	ED.Draw
		,	DrawRate	=	ED.DrawRate
	from
		#ExistingDefaultDraw ED
		join
		dbo.scDefaultDraws DD on (	
								1 = dd.CompanyID
								and 1 = dd.DistributionCenterID
								and ED.AccountId	= DD.AccountID
								and	ED.PublicationId= DD.PublicationId
								and ED.DrawWeekday	= DD.DrawWeekday )
	where
		(	DD.DrawAmount <> ED.Draw	)
	or	(	DD.DrawRate	  <> ED.DrawRate)

	select @cnt = (@cnt - @@rowcount), @cntprint=@@rowcount, @err = @@error
	
	set @msg = cast(@cntprint as varchar) +  ' records updated in scDefaultDraws.  '
		 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()
	
	if @err <> 0
	begin
		rollback tran T1
		set @msg = 'An error occurred while trying to update records in scDefaultDraws. Error is: '
				 + (select description from master..sysmessages where error = @err and msglangid=1033)
		goto error
	end --if @err<>0
	if @cnt <> 0	-- means that our two rowcounts didn't match up!
	begin
		rollback tran T1
		set @msg = 'The rowcount for updating scDefaultDraws did not match rowcount from scDefaultDrawHistory Insert! '
		goto error
	end --if @cnt<>0
	
	set @companyDate = dbo.GetCompanyDate(GetDate())
	insert dbo.scDrawHistory(
		 accountid
		,publicationid
		,drawid
		,drawweekday
		,changeddate
		,drawdate
		,olddraw
		,newdraw
		,oldrate
		,newrate
		,olddeliverydate
		,newdeliverydate
		,changetypeid)
	select
		 D.AccountId
		,D.PublicationId
		,D.DrawId
		,D.Drawweekday
		,@companyDate
		,D.DrawDate
		,D.DrawAmount
		,ED.Draw
		,D.DrawRate
		,ED.DrawRate
		,D.DeliveryDate
		,ED.DeliveryDate
		,@importChangeType
	from
		#ExistingDefaultDraw ED
	join
		dbo.scDraws D 
		on (
			1 = d.CompanyID
			and 1 = d.DistributionCenterID
			and ED.Accountid = D.AccountId 
			and	ED.PublicationId = D.PublicationId
			and ED.DrawDate = D.DrawDate )
	where
		(	D.DrawAmount <> ED.Draw	)
	or	(	D.DrawRate   <> ED.DrawRate )
	or	(	D.DeliveryDate <> ED.DeliveryDate )

	select	@cnt = @@rowcount, @cntprint=@@rowcount, @err = @@error
	set @msg = cast(@cntprint as varchar) +  ' records inserted into scDrawHistory.  '
		 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()
	
	if @err <> 0
	begin
		rollback tran T1
		set @msg = 'An error occurred while trying to add records to scDrawHistory. Error is: '
				 + (select description from master..sysmessages where error = @err and msglangid=1033)
		goto error
	end --if @err<>0

	update	dbo.scDraws
	set		DrawAmount	= ED.Draw
		,	DrawRate	= ED.DrawRate
		,	DeliveryDate= ED.DeliveryDate
		,	LastChangeType = @importChangeType
	from
		#ExistingDefaultDraw ED
	join
		dbo.scDraws D 
		on (
			1 = d.CompanyID
			and 1 = d.DistributionCenterID
			and ED.Accountid = D.AccountId 
			and	ED.PublicationId = D.PublicationId
			and ED.DrawDate = D.DrawDate )
	where
		(	D.DrawAmount <> ED.Draw	)
	or	(	D.DrawRate   <> ED.DrawRate )
	or	(	D.DeliveryDate <> ED.DeliveryDate )

	select @cnt = (@cnt - @@rowcount), @err = @@error
		
	set @msg = cast(@cntprint as varchar) +  ' records updated in scDraws.  '
		 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()

	
	if @err <> 0
	begin
		rollback tran T1
		set @msg = 'An error occurred while trying to update records in scDraws. Error is: '
				 + (select description from master..sysmessages where error = @err and msglangid=1033)
		goto error
	end --if @err<>0
	if @cnt <> 0	-- means that our two rowcounts didn't match up!
	begin
		rollback tran T1
		set @msg = 'The rowcount for updating scDefaultDraws did not match rowcount from scDefaultDrawHistory Insert! '
		goto error
	end --if @cnt<>0
	
------------------------------------------------------------------------------------------

	--
	--	save scDraws record key information for records that will be added
	--	where scDefaulDraws records exist but no scDraws ones for imported
	--	records for inserting draw history records
	--	

	set @msg = 'Inserting data into #InsertedDraw...'
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()
	
	insert #InsertedDraw(
		 accountid
		,publicationid
		,drawdate
		,deliverydate
		,drawweekday

	)
	select
		DD.AccountId
		,DD.PublicationId
		,ED.DrawDate
		,ED.DeliveryDate
		,DD.DrawWeekday
	from
		#ExistingDefaultDraw ED
	join
		dbo.scDefaultDraws DD 
	On (
		1 = DD.CompanyID
		and 1 = DD.DistributionCenterID
		and ED.Accountid = DD.AccountId 
		and	ED.PublicationId = DD.PublicationId
		and ED.Drawweekday = DD.Drawweekday )
	left join
		dbo.scDraws D	
	On (	
		1 = D.CompanyID
		and 1 = D.DistributionCenterID
		and ED.Accountid = D.AccountId 
		and	ED.PublicationId = D.PublicationId
		and ED.DrawDate = D.DrawDate )
	where
		D.DrawId is null


	set @msg = 'Inserted ' + cast(@@rowcount as varchar) + ' records into #InsertedDraw.  '
		 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()

/*
	set @msg = 'Creating indexes on #InsertedDraw...'
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()

	CREATE NONCLUSTERED INDEX idx_#InsertedDraw
	ON #InsertedDraw ([AccountID],[PublicationId],[DrawDate])
		
	set @msg = 'Indexes created successfully.  '
		 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()
	--
	--	insert scDraws records where scDefaulDraws records exist but no scDraws ones 
	--	for imported records 
	--	
*/
;with cteDraws 
as 
(
	select CompanyId, DistributionCenterId, AccountId, PublicationId, DrawId, DrawDate, d.DrawWeekday 
	from scDraws d
	join #ProcessingDates pd
		on d.DrawDate = pd.date
)

	insert scDraws(
		 CompanyID
		,DistributionCenterID
		,AccountID
		,PublicationID
		,DrawWeekday
		,DrawDate
		,DeliveryDate
		,DrawAmount
		,DrawRate
		,LastChangeType
	)
	select
		 1
		,1
		,DD.AccountId
		,DD.PublicationId
		,DD.DrawWeekday
		,ED.DrawDate
		,ED.DeliveryDate
		,ED.Draw
		,ED.DrawRate
		,@importChangeType
	from
		#ExistingDefaultDraw ED
		
	join
		dbo.scDefaultDraws DD 
	On (
		1 = DD.CompanyID
		and 1 = DD.DistributionCenterID
		and ED.Accountid = DD.AccountId 
		and	ED.PublicationId = DD.PublicationId
		and ED.Drawweekday = DD.Drawweekday )
	left join
		cteDraws d--dbo.scDraws D	
	On (	
		1 = D.CompanyID
		and 1 = D.DistributionCenterID
		and ED.Accountid = D.AccountId 
		and	ED.PublicationId = D.PublicationId
		and ED.DrawDate = D.DrawDate )
	where
		D.DrawId is null

	select	@cnt = @@rowcount, @cntprint = @@rowcount, @err = @@error
		
	set @msg = 'Inserted ' + cast(@cntprint as varchar) + ' draw records into scDraws (1).  '
		 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()
	
	if (@err <> 0)
		begin
			rollback tran T1
			set @msg = 'An error occurred in scDefaultDraws_Import while trying to insert records into the scDraws table. '
					 + 'The error is: ' 
					 + (select description from master..sysmessages where error = @err and msglangid=1033)
			goto error
		end

	
	-- insert scDrawHistory Records for new scDraws records being created
	set @companyDate = dbo.GetCompanyDate(GetDate())
	;with cteDraws 
	as 
	(
		select CompanyId, DistributionCenterId, AccountId, PublicationId, DrawId, DrawDate, d.DrawWeekday
			, d.DrawAmount, d.DrawRate, d.DeliveryDate
		from scDraws d
		join #ProcessingDates pd
			on d.DrawDate = pd.date
	)
	insert dbo.scDrawHistory(
		 CompanyID
		,DistributionCenterID
		,accountid
		,publicationid
		,drawid
		,drawweekday
		,changeddate
		,drawdate
		,olddraw
		,newdraw
		,oldrate
		,newrate
		,olddeliverydate
		,newdeliverydate
		,changetypeid)
	select
		 1
		,1
		,D.AccountId
		,D.PublicationId
		,D.DrawId
		,D.Drawweekday
		,@companyDate
		,D.DrawDate
		,D.DrawAmount
		,D.DrawAmount
		,D.DrawRate
		,D.DrawRate
		,D.DeliveryDate
		,D.DeliveryDate
		,@importChangeType
	from
		#InsertedDraw nd
	join
		cteDraws d--dbo.scDraws D 
	on (
		D.CompanyID = 1
		and D.DistributionCenterID = 1
		and nd.Accountid = D.AccountId 
		and nd.PublicationId = D.PublicationId
		and nd.DrawDate = D.DrawDate 
	)

	select @cnt = (@cnt - @@rowcount), @cntprint=@@rowcount , @err = @@error
		
	set @msg = 'Inserted ' + cast(@cntprint as varchar) + ' draw records into scDrawHistory.  '
		 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()

	if @err <> 0
	begin
		rollback tran T1
		set @msg = 'An error occurred while trying to add records to scDrawHistory. Error is: '
				 + (select description from master..sysmessages where error = @err and msglangid=1033)
		goto error
	end --if @err<>0

	if @cnt <> 0	-- means that our two rowcounts didn't match up!
	begin
		rollback tran T1
		set @msg = 'The rowcount for inserting scDraws did not match rowcount from scDrawHistory Insert! '
		goto error
	end --if @cnt<>0

-- Debug section
-- print 'Existing Records Processing End: ' + convert( varchar, dbo.GetCompanyDate(GetDate()), 14 ) -- print out start time
-- End Debug section
	

------------------------------------------------------------------------------------------

	--	Last step is to make sure we've got no 'holes' in the scDraws table for the delivery dates given in the import file
	--	(Generally, the delivery dates in the import will all be the same and will represent the 'next' day's deliveries but
	--	this is not 100%).  To make sure that PDAs have all account details (even for accounts+pubs with no draw on the given
	--	delivery date, we run this script to fill in the gaps with 'zero' draw records. This is a safety net more than anything
	--	else.

	--	delete from #InsertedDraw previous records processed

	delete #InsertedDraw

	--
	--	save scDraws record key information for records that will be added
	--	where scDefaulDraws records exist but no scDraws ones for non-imported
	--	records for inserting draw history records
	--	

	insert #InsertedDraw(
		 accountid
		,publicationid
		,drawdate
		,deliverydate
		,drawweekday
	)
	select
		D1.AccountId
		,D1.PublicationId
		,PD.Date
		,PD.Date
		,D1.DrawWeekday
	from
		dbo.scdefaultdraws      		d1
		join	#ProcessingDates		pd  on ( d1.drawweekday = pd.drawweekday )
		join	dbo.scAccounts			A	on ( d1.AccountId = A.AccountId )
		left join dbo.scdraws   		d2 	on ( d1.companyid = d2.companyid
		                                and	d1.distributioncenterid = d2.distributioncenterid
		                                and	d1.accountid = d2.accountid
		                                and	d1.publicationid = d2.publicationid
		                                and	d1.drawweekday = d2.drawweekday
		                                and ( d2.deliverydate = pd.date or d2.drawdate = pd.date)  )
	where
		d2.drawid is null
	and A.acctImported = 1
		
	set @msg = 'Inserted ' + cast(@@rowcount as varchar) + ' records into #InsertedDraw for missing draw.  '
		 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()
	
	--
	--	insert scDraws records where scDefaulDraws records exist but no scDraws ones 
	--	for non-imported records 
	--	

	--insert into #ExistingDraw ( accountid, publicationid, drawdate, deliverydate, drawweekday, drawid)
	--select AccountId, PublicationId, DrawDate, DeliveryDate, d.DrawWeekday, d.DrawID 
	--from scDraws d
	--join #ProcessingDates pd
	--	on d.DrawDate = pd.date

--;with cteDraws 
--as 
--(
--	select CompanyId, DistributionCenterId, AccountId, PublicationId, DrawId, DrawDate, DeliveryDate, d.DrawWeekday 
--	from scDraws d
--	join #ProcessingDates pd
--		on d.DrawDate = pd.date
--	join #ProcessingDates pd2
--		on d.DeliveryDate = pd2.date	
--)
	insert	dbo.scDraws(
		 companyid
		,distributioncenterid
		,accountid
		,publicationid
		,drawweekday
		,drawdate
		,deliverydate
		,drawamount
		,drawrate
		,lastchangetype )
	select
		 1
		,1
		,d1.accountid
		,d1.publicationid
		,d1.drawweekday
		,pd.date
		,pd.date			-- use the processing date from #ProcessingDates for both draw and delivery since we're just filling in missing data anyhow
		,0
		,0.0
		,@importChangeType
	from #InsertedDraw d1
	join	#ProcessingDates		pd  on ( d1.drawweekday = pd.drawweekday )
	--from
	--	dbo.scdefaultdraws      		d1
	--	join	#ProcessingDates		pd  on ( d1.drawweekday = pd.drawweekday )
	--	join	dbo.scAccounts			A	on ( d1.AccountId = A.AccountId )
	--	left join cteDraws d2 --dbo.scdraws   		d2 	
	--		on ( d1.companyid = d2.companyid
	--	                                and	d1.distributioncenterid = d2.distributioncenterid
	--	                                and	d1.accountid = d2.accountid
	--	                                and	d1.publicationid = d2.publicationid
	--	                                and	d1.drawweekday = d2.drawweekday
	--	                                --and ( d2.deliverydate = pd.date or d2.drawdate = pd.date)  
	--	                                )
	--where
	--	d2.drawid is null
	--and A.acctImported = 1

	select	@cnt = @@rowcount, @cntprint = @@rowcount
		
	set @msg = 'Inserted ' + cast(@cntprint as varchar) + ' draw records into scDraws for missing data.  '
		 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()
	-- insert scDrawHistory Records for new scDraws records being created

	set @companyDate = dbo.GetCompanyDate(GetDate())
	;with cteDraws 
	as 
	(
		select CompanyId, DistributionCenterId, AccountId, PublicationId, DrawId, DrawDate, d.DrawWeekday 
			, d.DrawAmount, d.DrawRate, d.DeliveryDate
		from scDraws d
		join #ProcessingDates pd
			on d.DrawDate = pd.date
	)
	insert dbo.scDrawHistory(
		 CompanyID
		,DistributionCenterID
		,accountid
		,publicationid
		,drawid
		,drawweekday
		,changeddate
		,drawdate
		,olddraw
		,newdraw
		,oldrate
		,newrate
		,olddeliverydate
		,newdeliverydate
		,changetypeid)
	select
		 1
		,1
		,D.AccountId
		,D.PublicationId
		,D.DrawId
		,D.Drawweekday
		,@companyDate
		,D.DrawDate
		,D.DrawAmount
		,D.DrawAmount
		,D.DrawRate
		,D.DrawRate
		,D.DeliveryDate
		,D.DeliveryDate
		,@importChangeType
	from
		#InsertedDraw nd
	join
		cteDraws d--dbo.scDraws D 
	on (
		D.CompanyID = 1
		and D.DistributionCenterID = 1
		and nd.Accountid = D.AccountId 
		and nd.PublicationId = D.PublicationId
		and nd.DrawDate = D.DrawDate 
	)		


	select @cnt = (@cnt - @@rowcount), @cntprint = @@rowcount, @err = @@error
		
	set @msg = 'Inserted ' + cast(@cntprint as varchar) + ' draw records into scDrawHistory for missing data.  '
		 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()

	if @err <> 0
	begin
		rollback tran T1
		set @msg = 'An error occurred while trying to add records to scDrawHistory. Error is: '
				 + (select description from master..sysmessages where error = @err and msglangid=1033)
		goto error
	end --if @err<>0

	if @cnt <> 0	-- means that our two rowcounts didn't match up!
	begin
		rollback tran T1
		set @msg = 'The rowcount for inserting scDraws did not match rowcount from scDrawHistory Insert! '
		goto error
	end --if @cnt<>0


	
commit tran T1


	set @msg = 'scDefaultDraws_Import completed successfully.  '
		 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait

goto done

error:
	print @msg
	exec nsSystemLog_Insert 2,2,@msg
	
	--	clean up temp tables if they haven't been...
	if exists( select 1 from tempdb..sysobjects where name like '#ExistingDefaultDraw%')
		drop table #tempDraws

	if exists( select 1 from tempdb..sysobjects where name like '#NewDrawData%')
		drop table #NewDrawData

	if exists( select 1 from tempdb..sysobjects where name like '#InsertedDraw%')
		drop table #InsertedDraw 

	if exists( select 1 from tempdb..sysobjects where name like '#newpubs%')
		drop table #newpubs

	if exists( select 1 from tempdb..sysobjects where name like '#ProcessingDates%')
		drop table #ProcessingDates

	print ''
	return 1

done:
	print ''
	return 0
end
GO

grant execute on [dbo].[scDefaultDraws_Import] to [nsUser]
GO