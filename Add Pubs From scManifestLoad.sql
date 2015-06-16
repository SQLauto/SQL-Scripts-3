BEGIN TRAN
set nocount on

    declare @companycode int, @dccode int
    set		@companycode = 1
    set		@dccode      = 1
    
    declare @msg    nvarchar(512)
    declare @cnt    int
    declare @cntprint    int
    declare @err	int
    declare @importChangeType int

create table #newpubs( publication nvarchar(5) )
	insert #newpubs( publication )
	select distinct v.publication
	from
		scManifestLoad_view v
	left join
		nsPublications p on ( v.publication = p.pubshortname )
	where
		p.publicationid is null
--select * from #newpubs
--drop table #newpubs
--return 1
	if exists( select 1 from #newpubs )
	begin
		declare @pubcode nvarchar(5)

		--  Create a temporary table to hold a value for each day of the week
		--  We'll use this to add rows to the nsPublicationForecastCutoffs table
		create table #weekdays(
			[weekday] tinyint
		)
		insert into #weekdays(
			[weekday]
		)
		select 0				-- Sunday
		union all select 1		-- Monday
		union all select 2		-- Tuesday
		union all select 3		-- Wednesday
		union all select 4		-- Thursday
		union all select 5		-- Friday
		union all select 6		-- Saturday
		
		declare pub_cursor CURSOR for select publication from #newpubs
		Open pub_cursor
		fetch next from pub_cursor into @pubcode
		while @@fetch_status = 0
			begin
				begin tran p
				set @msg = 'The Manifest import process encountered a new publication “' + @pubcode + '” and will automatically add it to the current list of publications.'
				exec nsSystemLog_Insert 2,1,@msg
				print @msg
				declare @newid int
				select @newid = isnull(max(publicationid),0)+1 from nsPublications where companyid=1 and distributioncenterid=1
				insert nsPublications(
					 CompanyID, DistributionCenterID, PublicationID, PubName, PubShortName, PubDescription
					,PubFrequency, PubCustom1, PubCustom2, PubCustom3, PubActive, TaxCategoryId, PrintSortOrder )
				values(1,1,@newid,@pubcode,@pubcode,N'',0,N'',N'',N'',1,0,0)
				set @err = @@error
				if @err <> 0
					begin
						rollback tran
						set @msg = 'An error occurred while trying to add new publication '
								 + @pubcode + ' to the Publications table. Error is: ' 
								 + (select description from master..sysmessages where error = @err and msglangid=1033)
						drop table #newpubs
						--goto error
				end
				
				--	Add a row to nsPublicationForecastCutoffs for each weekday
				insert nsPublicationForecastCutoffs(
					 PublicationId
					,PublicationWeekday
					,ForecastCutoffDays
					,ForecastCutofftime
				)
				select	 @newid
						,w.[weekday]
						,0
						,'1/1/1900 0:0'			-- set the time to midnight on 1/1/1900 (compromise minimum date)
				from #weekdays w

				set @err = @@error
				if @err <> 0
					begin
						rollback tran
						set @msg = 'An error occurred while trying to add new records for '
								 + @pubcode + ' to the nsPublicationForecastCutoff table. Error is: ' 
								 + (select description from master..sysmessages where error = @err and msglangid=1033)
						drop table #newpubs
						--goto error
				end
								
				commit tran p
				fetch next from pub_cursor into @pubcode
			end

	end -- if exists
	
	CLOSE pub_cursor
	deallocate pub_cursor

	drop table #newpubs
	drop table #weekdays
	
COMMIT TRAN