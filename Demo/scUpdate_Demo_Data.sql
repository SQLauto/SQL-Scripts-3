use nsdb

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'scUpdate_Demo_Data' 
	   AND 	  type = 'P')
    DROP PROCEDURE [dbo].[scUpdate_Demo_Data]
GO

CREATE PROCEDURE [dbo].[scUpdate_Demo_Data]
AS
	set nocount on

	--|Run the import for "Today"
	update scmanifestload
	set date = cast( datepart(yyyy, getdate()) as varchar(4) )
		+ cast( right( '00' + cast( datepart(m, getdate()) as varchar(2) ), 2 ) as varchar(2) )
		+ cast( right( '00' + cast( datepart(d, getdate()) as varchar(2) ), 2 ) as varchar(2) )

	exec scmanifest_data_load

	--|Create Return/Adjustment Data
	declare @date datetime
	
	set @date = getdate()
	
	declare @companyid int
		, @distributioncenterid int
		, @accountid int
		, @publicationid int
		, @drawweekday int
		, @drawid int
		, @drawamount int
		, @retamount int
		, @adjamount int
	
	declare draw_cursor cursor
	for
		select companyid, distributioncenterid, accountid, publicationid, drawweekday, drawid, drawamount
		from scdraws
		where datediff(d, drawdate, @date) = 0
	
	open draw_cursor
	fetch next from draw_cursor into @companyid, @distributioncenterid, @accountid, @publicationid, @drawweekday, @drawid, @drawamount
	
	while @@fetch_status = 0
	begin
		--Determine random return and adj amount
		if @drawamount <> 0
		begin 
			set @retamount = right( rand( datepart(ms,getdate() ) ), 1 )
			if @retamount > @drawamount
			begin 
				set @retamount = right( rand( datepart(ms,getdate() ) ), 1 )
			end
	
			set @adjamount = cast( right( rand( datepart(ms,getdate() ) ), 1 ) as int ) - cast( right( rand( datepart(ms,getdate() ) ), 1 ) as int )
		end
		else
		begin
			set @retamount = 0
		end
	
	if not exists (
		select *
		from scdrawadjustments
		where companyid = @companyid
			and distributioncenterid = @distributioncenterid
			and accountid = @accountid
			and publicationid = @publicationid
			and drawweekday = @drawweekday
			and drawid = @drawid
			and datediff(d, adjeffectivedate, @date) = 0
		)
	begin
		insert into scdrawadjustments (
			companyid
			,distributioncenterid
			,accountid
			,publicationid
			,drawweekday
			,drawid
			,drawadjustmentid
			,adjentrydate
			,adjeffectivedate
			,adjamount
			)
		select @companyid, @distributioncenterid, @accountid, @publicationid, @drawweekday, @drawid, 
			1, @date, @date, @adjamount
	end
	
	if not exists (
		select *
		from screturns
		where companyid = @companyid
			and distributioncenterid = @distributioncenterid
			and accountid = @accountid
			and publicationid = @publicationid
			and drawweekday = @drawweekday
			and drawid = @drawid
			and datediff(d, reteffectivedate, @date ) = 0
		)
	begin
		insert into screturns (
			companyid
			,distributioncenterid
			,accountid
			,publicationid
			,drawweekday
			,drawid
			,returnid
			,retentrydate
			,reteffectivedate
			,retamount
			)
		select @companyid, @distributioncenterid, @accountid, @publicationid, @drawweekday, @drawid, 
			1, @date, @date, @retamount
	end
	
	fetch next from draw_cursor into @companyid, @distributioncenterid, @accountid, @publicationid, @drawweekday, @drawid, @drawamount
	end
	
	close draw_cursor
	deallocate draw_cursor
	
GO

