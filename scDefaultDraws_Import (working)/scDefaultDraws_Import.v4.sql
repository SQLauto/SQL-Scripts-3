USE [NSDB_CHI]
GO

/****** Object:  StoredProcedure [dbo].[scDefaultDraws_Import]    Script Date: 03/15/2012 07:40:03 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[scDefaultDraws_Import]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[scDefaultDraws_Import]
GO

USE [NSDB_CHI]
GO

/****** Object:  StoredProcedure [dbo].[scDefaultDraws_Import]    Script Date: 03/15/2012 07:40:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[scDefaultDraws_Import]
As
/*
	update scdefaultdraws from file
		--defaultdrawhistory
	new default draw  from file
		--defaultdrawhistory
	
		
	update draw from file
	new draw from file
	missing	draw (has default draw but not in file)
*/
begin
	set nocount on

	declare @msg    nvarchar(512)
	declare @cnt    int
	declare @cntprint    int
	declare @err	int
	declare @importChangeType int
	select @importChangeType = ChangeTypeId from dd_nsChangeTypes where ChangeTypeName = 'DataImport'
	
	declare @start datetime
	declare @elapsed datetime

	set @start = getdate()
	set @elapsed = @start

	set @msg = 'scDefaultDraws_Import starting... (Elapsed: ' + dbo.support_Duration(@start, getdate()) + ')'  
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
	
	set @msg = 'scDefaultDraws_Import found the following delivery dates within the source file: ' + @datestr + '.  (Elapsed: ' + dbo.support_Duration(@start, getdate()) + ')'  
	exec nsSystemLog_Insert 2,0,@msg
	raiserror(@msg, 0, 1) with nowait
	set @elapsed = getdate()

	
	
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
		set @msg = cast(@cntprint as varchar) +  ' scDefaultDrawHistory records added.  '
			 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
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
		
		set @msg = cast(@cntprint as varchar) +  ' scDefaultDraw records updated.  '
			 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
		exec nsSystemLog_Insert 2,0,@msg
		raiserror(@msg, 0, 1) with nowait
		set @elapsed = getdate()			


		if @err <> 0
		begin
			rollback tran dd_update
			set @msg = 'An error occurred while trying to update records in scDefaultDraws. Error is: '
					 + (select description from master..sysmessages where error = @err and msglangid=1033)
			goto error
		end
		if @cnt <> 0	-- means that our two rowcounts didn't match up!
		begin
			rollback tran dd_update
			set @msg = 'The rowcount for updating scDefaultDraws did not match rowcount from scDefaultDrawHistory Insert! '
			goto error
		end

	commit tran dd_update

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
		set @msg = cast(@cntprint as varchar) +  ' scDefaultDraw records added.  '
			 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
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
		set @msg = cast(@cntprint as varchar) +  ' scDefaultDrawHistory records added for new account/pubs.  '
			 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
		exec nsSystemLog_Insert 2,0,@msg
		raiserror(@msg, 0, 1) with nowait
		set @elapsed = getdate()

		if @err <> 0
		begin
			rollback tran dd_insert
			set @msg = 'An error occurred while trying to insert records into scDefaultDrawHistory. Error is: '
					 + (select description from master..sysmessages where error = @err and msglangid=1033)
			goto error
		end
		if @cnt <> 0	-- means that our two rowcounts didn't match up!
		begin
			rollback tran dd_insert
			set @msg = 'The rowcount for inserting scDefaultDraws did not match rowcount from scDefaultDrawHistory Insert! '
			goto error
		end	
	
	commit tran dd_insert

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
		set @msg = cast(@cntprint as varchar) +  ' records inserted into scDrawHistory for scDraws update.  '
			 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
		exec nsSystemLog_Insert 2,0,@msg
		raiserror(@msg, 0, 1) with nowait
		set @elapsed = getdate()
		
		if @err <> 0
		begin
			rollback tran dr_update
			set @msg = 'An error occurred while trying to add records to scDrawHistory. Error is: '
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
			
		set @msg = cast(@cntprint as varchar) +  ' records updated in scDraws.  '
			 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
		exec nsSystemLog_Insert 2,0,@msg
		raiserror(@msg, 0, 1) with nowait
		set @elapsed = getdate()
		
			if @err <> 0
		begin
			rollback tran dr_update
			set @msg = 'An error occurred while trying to update records in scDraws. Error is: '
					 + (select description from master..sysmessages where error = @err and msglangid=1033)
			goto error
		end --if @err<>0
		if @cnt <> 0	-- means that our two rowcounts didn't match up!
		begin
			rollback tran dr_update
			set @msg = 'The rowcount for updating scDraws did not match rowcount from scDrawHistory Insert! '
			goto error
		end --if @cnt<>0
		
	commit tran dr_update
	
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
		from #NewDrawData v --scManifestLoad_View v
		--where v.DrawID is null

		select	@cnt = @@rowcount, @cntprint = @@rowcount, @err = @@error
			
		set @msg = 'Inserted ' + cast(@cntprint as varchar) + ' draw records into scDraws for new imported data.  '
			 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
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
			dbo.scDraws D --cteDraws d
			on (
				d.CompanyID = 1
				and d.DistributionCenterID = 1
				and nd.Accountid = d.AccountId 
				and	nd.PublicationId = d.PublicationId
				and	nd.drawweekday = d.drawweekday
				and	nd.DrawDate = d.DrawDate 
			)

		select @cnt = (@cnt - @@rowcount), @cntprint=@@rowcount , @err = @@error
			
		set @msg = 'Inserted ' + cast(@cntprint as varchar) + ' draw records into scDrawHistory for new imported data.  '
			 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
		exec nsSystemLog_Insert 2,0,@msg
		raiserror(@msg, 0, 1) with nowait
		set @elapsed = getdate()

		if @err <> 0
		begin
			rollback tran dr_insert
			set @msg = 'An error occurred while trying to add records to scDrawHistory. Error is: '
					 + (select description from master..sysmessages where error = @err and msglangid=1033)
			goto error
		end --if @err<>0

		if @cnt <> 0	-- means that our two rowcounts didn't match up!
		begin
			rollback tran dr_insert
			set @msg = 'The rowcount for inserting scDraws did not match rowcount from scDrawHistory Insert! '
			goto error
		end --if @cnt<>0
			
	commit tran dr_insert

	begin tran dr_insert_2
	
		truncate table #NewDrawData
		
		;with cteDraws
		as (
			select CompanyID, DistributionCenterID, AccountID, PublicationID, d.DrawWeekday, d.DrawID
			from scDraws d
			join #ProcessingDates pd
				on d.DrawDate = pd.date
		)
		insert into #NewDrawData
		select dd.AccountID, dd.PublicationID, dd.DrawWeekday, pd.date, pd.date, dd.DrawAmount, dd.DrawRate
		from scDefaultDraws dd
		join #ProcessingDates pd  --|need to join here to get dates
			on dd.DrawWeekday = pd.drawweekday
		left join cteDraws d
			on dd.CompanyID = d.CompanyID
			and dd.DistributionCenterID = d.DistributionCenterID
			and dd.AccountID = d.AccountID
			and dd.PublicationID = d.PublicationID
			and dd.DrawWeekday = d.DrawWeekday
		where d.DrawID is null
		
		--;with cteDraws
		--as (
		--	select CompanyID, DistributionCenterID, AccountID, PublicationID, d.DrawWeekday, d.DrawID
		--	from scDraws d
		--	join #ProcessingDates pd
		--		on d.DrawDate = pd.date
		--)
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
		--select 1
		--	, 1
		--	, dd.AccountID
		--	, dd.PublicationID
		--	, dd.DrawWeekday
		--	, pd.date
		--	, pd.date
		--	, dd.DrawAmount
		--	, dd.DrawRate
		--	, @importChangeType
		--from scDefaultDraws dd
		--join #ProcessingDates pd
		--	on dd.DrawWeekday = pd.drawweekday
		--left join cteDraws d
		--	on dd.CompanyID = d.CompanyID
		--	and dd.DistributionCenterID = d.DistributionCenterID
		--	and dd.AccountID = d.AccountID
		--	and dd.PublicationID = d.PublicationID
		--	and dd.DrawWeekday = d.DrawWeekday
		--where d.DrawID is null
		
		select	@cnt = @@rowcount, @cntprint = @@rowcount, @err = @@error
			
		set @msg = 'Inserted ' + cast(@cntprint as varchar) + ' draw records into scDraws for missing data.  '
			 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
		exec nsSystemLog_Insert 2,0,@msg
		raiserror(@msg, 0, 1) with nowait
		set @elapsed = getdate()
		
		--insert scdrawhistory...
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
			cteDraws d--dbo.scDraws D 
			on (
				nd.Accountid = d.AccountId 
				and	nd.PublicationId = d.PublicationId
				and	nd.drawweekday = d.drawweekday
				and	nd.DrawDate = d.DrawDate 
			)
		
		select @cnt = (@cnt - @@rowcount), @cntprint=@@rowcount , @err = @@error
			
		set @msg = 'Inserted ' + cast(@cntprint as varchar) + ' draw records into scDrawHistory for missing data.  '
			 + '( Elapsed: ' + dbo.support_Duration(@elapsed, getdate()) + ')'  
		exec nsSystemLog_Insert 2,0,@msg
		raiserror(@msg, 0, 1) with nowait
		set @elapsed = getdate()

		if @err <> 0
		begin
			rollback tran dr_insert
			set @msg = 'An error occurred while trying to add records to scDrawHistory. Error is: '
					 + (select description from master..sysmessages where error = @err and msglangid=1033)
			goto error
		end --if @err<>0

		if @cnt <> 0	-- means that our two rowcounts didn't match up!
		begin
			rollback tran dr_insert
			set @msg = 'The rowcount for inserting scDraws did not match rowcount from scDrawHistory Insert! '
			goto error
		end --if @cnt<>0
		
	commit tran dr_insert_2
	

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


