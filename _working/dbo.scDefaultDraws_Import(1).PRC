	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[scDefaultDraws_Import]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[scDefaultDraws_Import]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[scDefaultDraws_Import]
As
/*

	dd_update
		Update existing default draws, inserting a record into scDefaultDrawHistory

	dd_insert
		Insert records into scDefaultDraws for new accounts, inserting a record into scDefaultDrawHistory

	dr_update
		Update existing scDraws records

	dr_insert
		All accounts from the file now have a Default Draw (dd_insert) so fill in scDraws for accounts in the import file
		
	dr_insert_2
		Insert a 0 draw record into scDraws	for all accounts that were not encountered in the import file.  
		e.g. missing draw (has default draw but not in file)
	
	$History: /SingleCopy/Branches/SC_3.1.4/Customers/TRIB/Database/Scripts/Sprocs/dbo.scDefaultDraws_Import.PRC $
-- 
-- ****************** Version 23 ****************** 
-- User: kerry   Date: 2012-05-31   Time: 10:10:25-04:00 
-- Updated in: /SingleCopy/Branches/SC_3.1.4/Customers/TRIB/Database/Scripts/Sprocs 
-- Case 19564 - Default Draws Import enhancements 
	
*/
begin
	set nocount on

	declare @msg    nvarchar(512)
	declare @strlist varchar(256)
	declare @cnt    int
	declare @cntprint    int
	declare @err	int
	declare @importChangeType int
	select @importChangeType = ChangeTypeId from dd_nsChangeTypes where ChangeTypeName = 'DataImport'
	
	declare @start datetime
	declare @elapsed datetime

	set @start = getdate()
	set @elapsed = @start

	set @msg = 'scDefaultDraws_Import starting...' 
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	--print 'scDefaultDraws_Import starting...'	
	set @elapsed = getdate()
	
	
	create table #ProcessingDates(
		  [date] datetime not null
		, [drawweekday] int not null
		constraint pk_date_drawweekday primary key clustered ([date], [drawweekday])
	)
	insert	#ProcessingDates( [date], [drawweekday] )
	select distinct deliverydate, datepart(dw, deliverydate) from scmanifestload_view
	declare @datestr nvarchar(1024)
	
	select @datestr = COALESCE(@datestr+',' ,'') + convert(nvarchar(10),[date],101)
	from #ProcessingDates
	
	set @msg = 'scDefaultDraws_Import found the following delivery dates within the source file: ' + @datestr 
		--+ '.  (Elapsed: ' + dbo.support_Duration(@start, getdate()) + ')'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()


	--Multiple Weekday Validation
	if exists (	
		select DrawWeekday
		from (
			select DATEPART(dw, drawdate) as [DrawWeekday], drawdate 
			from scManifestLoad_View
			group by DATEPART(dw, drawdate), drawdate
			) as tmp
		group by DrawWeekday 
		having count(*) > 1
	 )
	begin
			--	this is a case when the file contains multiple weekday's (i.e., two different Fridays) worth of data
		select @strlist = COALESCE(@strlist +',' ,'') + convert(nvarchar(10),drawdate,101)
		from (
			select distinct drawdate
			from scManifestLoad_View v
			join (
				select DrawWeekday
				from (
					select DATEPART(dw, drawdate) as [DrawWeekday], drawdate 
					from scManifestLoad_View
					group by DATEPART(dw, drawdate), drawdate
					) as tmp
				group by DrawWeekday 
				having count(*) > 1
			) as err
			on v.drawweekday = err.DrawWeekday
		) as tmp	
				
		set @msg = N'Manifest Import File contains multiple records for the same weekday.  Draw Dates ' + @strlist
		goto error
	end
	
		--Multiple Weekday Validation
	if exists (	
		select DrawWeekday
		from (
			select DATEPART(dw, drawdate) as [DrawWeekday], drawdate 
			from scManifestLoad_View
			group by DATEPART(dw, drawdate), drawdate
			) as tmp
		group by DrawWeekday 
		having count(*) > 1
	 )
	begin
			--	this is a case when the file contains multiple weekday's (i.e., two different Fridays) worth of data
		select @strlist = COALESCE(@strlist +',' ,'') + convert(nvarchar(10),deliverydate,101)
		from (
			select distinct deliverydate
			from scManifestLoad_View v
			join (
				select DrawWeekday
				from (
					select DATEPART(dw, drawdate) as [DrawWeekday], deliverydate
					from scManifestLoad_View
					group by DATEPART(dw, drawdate), deliverydate
					) as tmp
				group by DrawWeekday 
				having count(*) > 1
			) as err
			on v.drawweekday = err.DrawWeekday
		) as tmp	
				
		set @msg = N'Manifest Import File contains multiple records for the same weekday.  Delivery Dates ' + @strlist
		goto error
	end
	
	
	--	Look for new Publication Codes provided by the Import File
	--	this is typically only seen during the first few imports, but
	--	it can happen subsequently. old system errored out, but new
	--	version will add the publication if needed.
	
	exec nsPublications_Import


/*
	dd_update
		Update existing default draws, inserting a record into scDefaultDrawHistory
*/
	set @msg = 'scDefaultDraws_Import:  Beginning Default Draw Update (dd_update)...'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	
	begin tran dd_update
	
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
			,dd.AccountId
			,dd.PublicationId
			,dd.DrawWeekday
			,(select isnull(max(DrawhistoryId),0) + 1 from dbo.scDefaultDrawHistory	where	companyid=1
															and     distributioncenterid = 1
															and     accountid = dd.AccountId
															and     publicationid = dd.PublicationId
															and     drawweekday = dd.drawweekday )
			,dbo.GetCompanyDate(GetDate())
			,dd.DrawAmount
			,v.drawamount
			,dd.DrawRate
			,v.DrawRate
			,1		-- Change by Import
		from scDefaultDraws dd
		join scManifestLoad_View v
			on dd.CompanyID = 1
			and dd.DistributionCenterID = 1
			and dd.AccountID = v.AccountID
			and dd.PublicationID = v.PublicationID
			and dd.DrawWeekday = v.drawweekday
		where ( 
			   dd.DrawAmount <> v.drawamount
			or dd.DrawRate <> v.drawrate 
		)
		
		select	@cnt = @@rowcount, @cntprint=@@rowcount, @err = @@error
		set @msg = cast(@cntprint as varchar) +  ' scDefaultDrawHistory records added (dd_update).  '
			 --+ '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
		exec nsSystemLog_Insert 2,0,@msg
		raiserror(@msg, 0, 1) with nowait
		set @elapsed = getdate()			
	
		update scDefaultDraws
		set DrawAmount = v.drawamount
			, DrawRate = v.drawrate
		from scDefaultDraws dd
		join scManifestLoad_View v
			on dd.CompanyID = 1
			and dd.DistributionCenterID = 1
			and dd.AccountID = v.AccountID
			and dd.PublicationID = v.PublicationID
			and dd.DrawWeekday = v.drawweekday
		where ( 
			   dd.DrawAmount <> v.drawamount
			or dd.DrawRate <> v.drawrate 
		)

		select @cnt = (@cnt - @@rowcount), @cntprint=@@rowcount, @err = @@error
		
		set @msg = cast(@cntprint as varchar) +  ' scDefaultDraw records updated (dd_update).  '
			 --+ '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
		exec nsSystemLog_Insert 2,0,@msg
		raiserror(@msg, 0, 1) with nowait
		set @elapsed = getdate()			


		if @err <> 0
		begin
			rollback tran dd_update
			set @msg = 'An error occurred while trying to update records in scDefaultDraws (dd_update).  Error is: '
					 + (select description from master..sysmessages where error = @err and msglangid=1033)
			goto error
		end
		if @cnt <> 0	-- means that our two rowcounts didn't match up!
		begin
			rollback tran dd_update
			set @msg = 'The rowcount for updating scDefaultDraws did not match rowcount from scDefaultDrawHistory Insert! (dd_update)'
			goto error
		end

	commit tran dd_update

	set @msg = 'scDefaultDraws_Import:  Default Draw Update (dd_update) completed successfully.'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait


/*
	dd_insert
		Insert records into scDefaultDraws for new accounts, inserting a record into scDefaultDrawHistory
*/
	set @msg = 'scDefaultDraws_Import:  Beginning Default Draw Insert (dd_insert)...'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait

	begin tran dd_insert
	
		create table #newDefaultDraw ( 
			  AccountId int
			, Publicationid int
			, DrawWeekday int
			, DrawAmount int
			, DrawRate decimal(8,5)
			, AllowForecasting int
			, AllowReturns int
			, AllowAdjustments int
			, ForecastMinDraw int
			, ForecastMaxDraw int
			, constraint pk_#newdefaultDraw primary key clustered ( AccountID, PublicationId, DrawWeekday)
			)
	
	
		insert into #newDefaultDraw
		select
			 v.AccountId
			,v.PublicationId
			,v.DrawWeekday
			,v.drawamount
			,v.DrawRate
			,v.AllowForecasting
			,v.AllowReturns
			,v.AllowAdjustments
			,v.ForecastMinDraw
			,v.ForecastMaxDraw
		from scManifestLoad_View v
		where v.DefaultDraw_AccountId is null

	
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
			,v.AccountId
			,v.PublicationId
			,v.DrawWeekday
			,v.drawamount
			,v.DrawRate
			,v.AllowForecasting
			,v.AllowReturns
			,v.AllowAdjustments
			,v.ForecastMinDraw
			,v.ForecastMaxDraw
		from #newDefaultDraw v

		select	@cnt = @@rowcount, @cntprint=@@rowcount, @err = @@error
		set @msg = cast(@cntprint as varchar) +  ' scDefaultDraw records added (dd_insert).'
			 --+ '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
		exec nsSystemLog_Insert 2,0,@msg
		raiserror(@msg, 0, 1) with nowait
		set @elapsed = getdate()
		
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
			,v.AccountId
			,v.PublicationId
			,v.DrawWeekday
			,1
			,getdate() --dbo.GetCompanyDate(GetDate())
			,0				--old
			,v.drawamount	--new
			,0.0			--old
			,v.DrawRate		--new
			,1		-- Change by Import
		from #newDefaultDraw v
			
		select @cnt = (@cnt - @@rowcount), @cntprint=@@rowcount, @err = @@error		
		set @msg = cast(@cntprint as varchar) +  ' scDefaultDrawHistory records added for new account/pubs (dd_insert).  '
			 --+ '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
		exec nsSystemLog_Insert 2,0,@msg
		raiserror(@msg, 0, 1) with nowait
		set @elapsed = getdate()

		if @err <> 0
		begin
			rollback tran dd_insert
			set @msg = 'An error occurred while trying to insert records into scDefaultDrawHistory (dd_insert). Error is: '
					 + (select description from master..sysmessages where error = @err and msglangid=1033)
			goto error
		end
		if @cnt <> 0	-- means that our two rowcounts didn't match up!
		begin
			rollback tran dd_insert
			set @msg = 'The rowcount for inserting scDefaultDraws did not match rowcount from scDefaultDrawHistory Insert!  (dd_insert)'
			goto error
		end	
	
	commit tran dd_insert

	set @msg = 'scDefaultDraws_Import:  Default Draw Insert (dd_insert) completed successfully.'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait

/*
	dr_update
		Update existing scDraws records 
*/
	set @msg = 'scDefaultDraws_Import:  Beginning Draw Update (dr_update)....'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait

	begin tran dr_update
	
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
			 d.AccountId
			,d.PublicationId
			,d.DrawId
			,d.Drawweekday
			,GetDate()  --not using "company date" because import should reflect the server time
			,d.DrawDate
			,d.DrawAmount
			,v.drawamount
			,d.DrawRate
			,v.DrawRate
			,d.DeliveryDate
			,v.DeliveryDate
			,@importChangeType
		from scManifestLoad_View v
		join scDraws d
			on v.DrawID = d.DrawID	
		where
			(	d.DrawAmount <> v.drawamount	)
		or	(	d.DrawRate   <> v.DrawRate )
		or	(	d.DeliveryDate <> v.DeliveryDate )
		
		select	@cnt = @@rowcount, @cntprint=@@rowcount, @err = @@error
		set @msg = cast(@cntprint as varchar) +  ' records inserted into scDrawHistory for scDraws update (dr_update).  '
			 --+ '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
		exec nsSystemLog_Insert 2,0,@msg
		raiserror(@msg, 0, 1) with nowait
		set @elapsed = getdate()
		
		if @err <> 0
		begin
			rollback tran dr_update
			set @msg = 'An error occurred while trying to add records to scDrawHistory (dr_update). Error is: '
					 + (select description from master..sysmessages where error = @err and msglangid=1033)
			goto error
		end --if @err<>0
		
		update	dbo.scDraws
		set		DrawAmount	= v.drawamount
			,	DrawRate	= v.DrawRate
			,	DeliveryDate= v.DeliveryDate
			,	LastChangeType = @importChangeType
		from scManifestLoad_View v
		join scDraws d
			on v.DrawID = d.DrawID	
		where
			(	d.DrawAmount <> v.drawamount	)
		or	(	d.DrawRate   <> v.DrawRate )
		or	(	d.DeliveryDate <> v.DeliveryDate )
	
		select @cnt = (@cnt - @@rowcount), @err = @@error
			
		set @msg = cast(@cntprint as varchar) +  ' records updated in scDraws (dr_update).  '
			 --+ '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
		exec nsSystemLog_Insert 2,0,@msg
		raiserror(@msg, 0, 1) with nowait
		set @elapsed = getdate()
		
		if @err <> 0
		begin
			rollback tran dr_update
			set @msg = 'An error occurred while trying to update records in scDraws (dr_update). Error is: '
					 + (select description from master..sysmessages where error = @err and msglangid=1033)
			goto error
		end
		if @cnt <> 0	-- means that our two rowcounts didn't match up!
		begin
			rollback tran dr_update
			set @msg = 'The rowcount for updating scDraws did not match rowcount from scDrawHistory Insert! (dr_update)'
			goto error
		end
		
	commit tran dr_update

	set @msg = 'scDefaultDraws_Import:  Draw Update (dr_update) completed successfully.'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait


/*
	dr_insert
		All accounts from the file now have a Default Draw (dd_insert) so insert a record into scDraws 
		for accounts in the import file
*/	
	set @msg = 'scDefaultDraws_Import:  Beginning Draw Insert (dr_insert)...'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait

	begin tran dr_insert

		create table #NewDrawData(
			 accountid		int	not null
			,publicationid	int not null
			,drawweekday	tinyint not null
			,drawdate		datetime not null
			,deliverydate	datetime not null
			,drawamount	int not null
			,drawrate		decimal(8,5) not null
			constraint pk_#newdraw primary key clustered (accountid, publicationid, drawweekday, drawdate)
		)
		
			
	CREATE NONCLUSTERED INDEX idx_#NewDrawData_Covering
	ON #NewDrawData (AccountID,PublicationId, drawweekday, drawdate)
	INCLUDE (deliverydate, drawamount, drawrate)

		insert into #NewDrawData
		select 
			  v.AccountID
			, v.PublicationID
			, v.drawweekday
			, v.drawdate
			, v.deliverydate
			, v.drawamount
			, v.drawrate
		from scManifestLoad_View v
		where v.DrawID is null
		
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
		select 1
			, 1
			, v.AccountID
			, v.PublicationID
			, v.drawweekday
			, v.drawdate
			, v.deliverydate
			, v.drawamount
			, v.drawrate
			, @importChangeType
		from #NewDrawData v

		select	@cnt = @@rowcount, @cntprint = @@rowcount, @err = @@error
			
		set @msg = 'Inserted ' + cast(@cntprint as varchar) + ' draw records into scDraws for new imported data (dr_insert).  '
			 --+ '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
		exec nsSystemLog_Insert 2,0,@msg
		raiserror(@msg, 0, 1) with nowait
		set @elapsed = getdate()
		
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
			,getdate()--dbo.GetCompanyDate(GetDate())
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
			dbo.scDraws d
			on (
				d.CompanyID = 1
				and d.DistributionCenterID = 1
				and nd.Accountid = d.AccountId 
				and	nd.PublicationId = d.PublicationId
				and	nd.drawweekday = d.drawweekday
				and	nd.DrawDate = d.DrawDate 
			)

		select @cnt = (@cnt - @@rowcount), @cntprint=@@rowcount , @err = @@error
			
		set @msg = 'Inserted ' + cast(@cntprint as varchar) + ' draw records into scDrawHistory for new imported data (dr_insert).  '
			 --+ '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
		exec nsSystemLog_Insert 2,0,@msg
		raiserror(@msg, 0, 1) with nowait
		set @elapsed = getdate()

		if @err <> 0
		begin
			rollback tran dr_insert
			set @msg = 'An error occurred while trying to add records to scDrawHistory (dr_insert). Error is: '
					 + (select description from master..sysmessages where error = @err and msglangid=1033)
			goto error
		end --if @err<>0

		if @cnt <> 0	-- means that our two rowcounts didn't match up!
		begin
			rollback tran dr_insert
			set @msg = 'The rowcount for inserting scDraws did not match rowcount from scDrawHistory Insert! (dr_insert)'
			goto error
		end
			
	commit tran dr_insert

	set @msg = 'scDefaultDraws_Import:  Draw Insert (dr_insert) completed successfully.'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait

/*
	dd_insert_2
		Insert a 0 draw record into scDraws	for all accounts that were not encountered in the import file.  
		e.g. missing draw (has default draw but not in file)

*/
	set @msg = 'scDefaultDraws_Import:  Beginning Draw Insert for Missing Data (dr_insert_2)...'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait

	begin tran dr_insert_2
	
		truncate table #NewDrawData
		
		;with cteDraws
		as (
			select CompanyID, DistributionCenterID, AccountID, PublicationID, d.DrawWeekday, d.DrawID
			from scDraws d
			join #ProcessingDates pd_drawdate
				on d.DrawDate = pd_drawdate.date
			union
			select CompanyID, DistributionCenterID, AccountID, PublicationID, d.DrawWeekday, d.DrawID
			from scDraws d
			join #ProcessingDates pd_deliverydate
				on d.DeliveryDate = pd_deliverydate.date	
		)
		insert into #NewDrawData
		select dd.AccountID, dd.PublicationID, dd.DrawWeekday, pd.date, pd.date, 0/*dd.DrawAmount*/, 0/*dd.DrawRate*/
		from scDefaultDraws dd
		join scAccountsPubs ap
			on dd.AccountID = ap.AccountId
			and dd.PublicationID = ap.PublicationId
		join #ProcessingDates pd  --|need to join here to get dates
			on dd.DrawWeekday = pd.drawweekday
		left join cteDraws d
			on dd.CompanyID = d.CompanyID
			and dd.DistributionCenterID = d.DistributionCenterID
			and dd.AccountID = d.AccountID
			and dd.PublicationID = d.PublicationID
			and dd.DrawWeekday = d.DrawWeekday
		where d.DrawID is null
		
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
		
		select 1
			, 1
			, nd.AccountID
			, nd.PublicationID
			, nd.DrawWeekday
			, nd.drawdate
			, nd.deliverydate
			, nd.DrawAmount
			, nd.DrawRate
			, @importChangeType
		from #NewDrawData nd	
		
		select	@cnt = @@rowcount, @cntprint = @@rowcount, @err = @@error
			
		set @msg = 'Inserted ' + cast(@cntprint as varchar) + ' draw records into scDraws for missing data (dr_insert_2).  '
			 --+ '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
		exec nsSystemLog_Insert 2,0,@msg
		raiserror(@msg, 0, 1) with nowait
		set @elapsed = getdate()
		
		--insert scdrawhistory for 0 draw records being inserted...
		;with cteDraws
		as
		(
			select
				d.AccountId
				,d.PublicationId
				,d.DrawId
				,d.Drawweekday
				,d.DrawDate
				,d.DrawAmount
				,d.DrawRate
				,d.DeliveryDate 
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
			,getdate()
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
			cteDraws d
			on (
				nd.Accountid = d.AccountId 
				and	nd.PublicationId = d.PublicationId
				and	nd.drawweekday = d.drawweekday
				and	nd.DrawDate = d.DrawDate 
			)
		
		select @cnt = (@cnt - @@rowcount), @cntprint=@@rowcount , @err = @@error
			
		set @msg = 'Inserted ' + cast(@cntprint as varchar) + ' draw records into scDrawHistory for missing data (dr_insert_2).  '
			 --+ '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
		exec nsSystemLog_Insert 2,0,@msg
		raiserror(@msg, 0, 1) with nowait
		set @elapsed = getdate()

		if @err <> 0
		begin
			rollback tran dr_insert
			set @msg = 'An error occurred while trying to add records to scDrawHistory (dr_insert_2). Error is: '
					 + (select description from master..sysmessages where error = @err and msglangid=1033)
			goto error
		end --if @err<>0

		if @cnt <> 0	-- means that our two rowcounts didn't match up!
		begin
			rollback tran dr_insert_2
			set @msg = 'The rowcount for inserting scDraws did not match rowcount from scDrawHistory Insert! (dr_insert_2)'
			goto error
		end --if @cnt<>0
		
	commit tran dr_insert_2
	
	set @msg = 'scDefaultDraws_Import:  Missing Draw Insert (dr_insert_2) completed successfully.'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait


	set @msg = 'scDefaultDraws_Import completed successfully'
	exec nsSystemLog_Insert 2,0,@msg
	print @msg

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

