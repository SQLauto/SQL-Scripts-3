IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_RetAdjAudit]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_RetAdjAudit]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[support_RetAdjAudit]
	  @beginDrawDate datetime = null
	, @endDrawDate datetime = null
AS
BEGIN
	set nocount on
	
	--| if both parameters are null, run for "last 7 days"
	if ( @beginDrawDate is null and @endDrawDate is null )
	begin
		set @beginDrawDate = dateadd(d, -7, convert(varchar, getdate()))
		set @endDrawDate = dateadd(d, -1, convert(varchar, getdate()))
	end
	
	if ( @beginDrawDate is null and @endDrawDate is not null )
		set @beginDrawDate = dateadd(d, -6, convert(varchar, @endDrawDate))
	
	if ( @beginDrawDate is not null and @endDrawDate is null )	
		set @endDrawDate = dateadd(d, 6, convert(varchar, @beginDrawDate))
		
	print @beginDrawDate
	print @endDrawDate
	
	if @beginDrawDate > @endDrawDate
	begin
		print 'Begin Date (' + convert(varchar,@beginDrawDate) + ') cannot be greater than End Date(' + convert(varchar,@endDrawDate) + ')'
		return
	end

	/*
		Get the current Manifest/Account associations 
	*/	
		if exists (select * from sys.objects where object_id = OBJECT_ID(N'[dbo].[tmpAcctsMfsts]') AND type in (N'U'))
		begin
			drop table [dbo].[tmpAcctsMfsts]
		end

		create table tmpAcctsMfsts (
			  AccountId int
			, AcctCode nvarchar(20)
			, PublicationId int
			, PubShortName nvarchar(5)
			, MfstCode nvarchar(20)
			, ManifestTypeId int
			, ManifestTypeDescription nvarchar(128)
			, ManifestOwner int
			, Frequency int
			)
		
		insert into tmpAcctsMfsts (
			  AccountId
			, AcctCode 
			, PublicationId
			, PubShortName
			, MfstCode
			, ManifestTypeId
			, ManifestTypeDescription
			, ManifestOwner
			, Frequency
		)	
		select AccountId
			, AcctCode 
			, PublicationId
			, PubShortName
			, MfstCode
			, ManifestTypeId
			, ManifestTypeDescription
			, ManifestOwner
			, Frequency
		from dbo.listMfstsAccts('Delivery',null, null, -1, null) 

	/*
		Use a recursive cte to get the "difference" between succesive Return entries, this is the actual Return amount entered.  
		We need the actual Return amount entered so we can sum the owner entered returns and the admin entered returns
	*/
	;with cteReturns_Prelim ( DrawId, DrawDate, AccountId, PublicationId, ReturnsAuditId, RetAuditUser, RetAuditValue, RetAuditDate, Diff )
	as 
		(
		select d.DrawId, d.DrawDate, d.AccountId, d.PublicationId, ra.ReturnsAuditId, u.UserName, ra.RetAuditValue, ra.RetAuditDate, cast(ra.RetAuditValue as int)
		from scDraws d
		join scReturnsAudit ra
			on d.DrawId = ra.DrawId
		join Users u
			on ra.RetAuditUserId = u.UserID	
		where d.DrawDate between @beginDrawDate and @endDrawDate
		and ReturnsAuditId = 1
		union all 
			select d.DrawId, d.DrawDate, d.AccountId, d.PublicationId, ra.ReturnsAuditId, u.UserName, ra.RetAuditValue, ra.RetAuditDate, cast(ra.RetAuditValue as int) - cast(cte.RetAuditValue as int) as [Diff]
			from scDraws d
			join scReturnsAudit ra
				on d.DrawId = ra.DrawId
			join Users u
				on ra.RetAuditUserId = u.UserID	
			join cteReturns_Prelim cte
				on cte.DrawId = d.DrawId
				and cte.ReturnsAuditId + 1 = ra.ReturnsAuditId
		)
	select m.MfstCode, ra.DrawId, ra.DrawDate, ra.AccountId, ra.PublicationId, ra.ReturnsAuditId, ra.RetAuditUser, Diff--, m.AcctCode, m.PubShortName
	into #cteReturns_Prelim
	from cteReturns_Prelim ra
	join tmpAcctsMfsts m  --|need to join with Manifests to determine owner
		on ra.AccountId = m.AccountId
		and ra.PublicationId = m.PublicationId
		and dbo.scGetDayFrequency(ra.DrawDate) & m.Frequency > 0
		
	--select *
	--from #cteReturns_Prelim
	--order by DrawId

	;with cteAdjustments_Prelim ( DrawId, AccountId, PublicationId, DrawAdjustmentAuditId, AdjAuditUser, AdjAuditValue, AdjAuditDate, Diff )
	as 
		(
		select d.DrawId, d.AccountId, d.PublicationId, da.DrawAdjustmentAuditId, u.UserName, da.AdjAuditValue, da.AdjAuditDate, cast(da.AdjAuditValue as int)
		from scDraws d
		join scDrawAdjustmentsAudit da
			on d.DrawId = da.DrawId
		join Users u
			on da.AdjAuditUserId = u.UserID	
		where d.DrawDate between @beginDrawDate and @endDrawDate
		and DrawAdjustmentAuditId = 1
		
		union all 
			select d.DrawId, d.AccountId, d.PublicationId, da.DrawAdjustmentAuditId, u.UserName, da.AdjAuditValue, da.AdjAuditDate, cast(da.AdjAuditValue as int) - cast(cte.AdjAuditValue as int) as [Diff]
			from scDraws d
			join scDrawAdjustmentsAudit da
				on d.DrawId = da.DrawId
			join Users u
				on da.AdjAuditUserId = u.UserID	
			join cteAdjustments_Prelim cte
				on cte.DrawId = d.DrawId
				and cte.DrawAdjustmentAuditId + 1 = da.DrawAdjustmentAuditId
		)
	select
		da.DrawId, da.AccountId, da.PublicationId, da.DrawAdjustmentAuditId, da.AdjAuditUser, Diff
	into #cteAdjustments_Prelim
	from cteAdjustments_Prelim da
		
	--select *
	--from #cteAdjustments_Prelim
	--order by DrawId		


/*-------------------------------------------------------------------------------------------------	
	Returns Details  

	Use dynamic sql to create tables with the appropriate number of columns to hold all of the
	return audit details in a single row.
	
	#cteReturns_Prelim holds the "difference" between successive Return entries
-------------------------------------------------------------------------------------------------*/
declare @maxReturnsId int
declare @counter int

set @counter = 1

select @maxReturnsId = max(ReturnsAuditId)
from #cteReturns_Prelim

--print '@maxReturnsId=' + cast(@maxReturnsId as varchar)

declare @cols nvarchar(2000)
declare @createTableCols nvarchar(2000)
declare @createFinalTableCols nvarchar(2000)
declare @selectValueCols nvarchar(2000)
declare @selectUserCols nvarchar(2000)
declare @selectDateCols nvarchar(2000)
declare @finalSelectCols nvarchar(2000)

if @maxReturnsId is not null
begin
	while @counter <= @maxReturnsId
	begin
		set @cols = coalesce(@cols + ',[' + cast(@counter as varchar) + ']', '[' + cast(@counter as varchar) + ']' )

		set @createTableCols = coalesce( @createTableCols 
			+ ',[RetAuditValue' + cast(@counter as varchar) + '] varchar(50)'
			 , '[RetAuditValue' + cast(@counter as varchar) + '] varchar(50)' )

		set @selectUserCols = coalesce( @selectUserCols
			+ ',[' + cast(@counter as varchar) + '] as [RetAuditUser' + cast(@counter as varchar) + ']'
			 , '[' + cast(@counter as varchar) + '] as [RetAuditUser' + cast(@counter as varchar) + ']' )
		set @selectValueCols = coalesce( @selectValueCols
			+ ',[' + cast(@counter as varchar) + '] as [RetAuditValue' + cast(@counter as varchar) + ']'
			 , '[' + cast(@counter as varchar) + '] as [RetAuditValue' + cast(@counter as varchar) + ']' )
		set @selectDateCols = coalesce( @selectDateCols
			+ ',[' + cast(@counter as varchar) + '] as [RetAuditDate' + cast(@counter as varchar) + ']'
			 , '[' + cast(@counter as varchar) + '] as [RetAuditDate' + cast(@counter as varchar) + ']' )	 

		set @createFinalTableCols = coalesce( @createFinalTableCols
			+ ', [RetAuditUser' + cast(@counter as varchar) + '] nvarchar(50)
			   , [RetAuditValue' + cast(@counter as varchar) + '] nvarchar(50)'
			 , ' [RetAuditUser' + cast(@counter as varchar) + '] nvarchar(50)
			   , [RetAuditValue' + cast(@counter as varchar) + '] nvarchar(50)' )
		
		set @finalSelectCols = coalesce( @finalSelectCols
			+ ', [RetAuditUser' + cast(@counter as varchar) + '], [RetAuditValue' + cast(@counter as varchar) + ']'
			 , ' [RetAuditUser' + cast(@counter as varchar) + '], [RetAuditValue' + cast(@counter as varchar) + ']' )
		
		set @counter = @counter + 1
	end	

	declare @sql varchar(4000)
	set @sql = N'create table RetAuditValues ( DrawId int, ' + @createTableCols + ')'
	--print @sql
	exec (@sql)

	set @sql = N'
		insert into RetAuditValues
		select DrawId, ' + @selectValueCols + '
		from (
			select ra.DrawId, ra.ReturnsAuditId, Diff
			from #cteReturns_Prelim ra
			) as t
		pivot (
			sum(Diff)
			for ReturnsAuditId in (' + @cols + ')
			) as pvtValues
	'
	--print @sql
	exec(@sql)

	--| 
	set @sql = N'create table RetAuditUsers ( DrawId int, ' + replace(@createTableCols,'Value','User') + ')'
	--print @sql
	exec (@sql)

	set @sql = N'
		insert into RetAuditUsers
		select DrawId, ' + @selectUserCols + '
		from (
			select ra.DrawId, ra.ReturnsAuditId, ra.RetAuditUser
			from #cteReturns_Prelim ra
			) as t
		pivot (
			max(RetAuditUser)
			for ReturnsAuditId in (' + @cols + ')
			) as pvtValues'
	exec(@sql)

	set @sql = N'create table returnsAuditDetails ( DrawId int, ' + @createFinalTableCols + ')'
	--print @sql
	exec (@sql)

	set @sql = N'
		insert into returnsAuditDetails
		select u.DrawId, ' + @finalSelectCols + '
		from RetAuditUsers u
		join RetAuditValues v
			on u.DrawId = v.DrawId'
		
	--print @sql
	exec (@sql)
end
else
begin
	--|  No Returns data, but we still need the table to exist 
	set @sql = N'create table returnsAuditDetails ( DrawId int )'
	print @sql
	exec (@sql)
end	

-------------------------------------------------------------------------------------------------	
/*
	pivot the raw data, users
*/
declare @maxDrawAdjustmentAuditId int

--|Reset variables
set @counter = 1
set @cols = null
set @createTableCols = null
set @selectUserCols = null
set @selectValueCols = null
set @selectDateCols = null
set @createFinalTableCols = null
set @finalSelectCols = null

select @maxDrawAdjustmentAuditId = max(DrawAdjustmentAuditId)
from #cteAdjustments_Prelim

--print '@maxDrawAdjustmentsAuditId=' + cast(@maxDrawAdjustmentAuditId as varchar)

if @maxDrawAdjustmentAuditId is not null
begin
	while @counter <= @maxDrawAdjustmentAuditId
	begin
		set @cols = coalesce(@cols + ',[' + cast(@counter as varchar) + ']', '[' + cast(@counter as varchar) + ']' )

		set @createTableCols = coalesce( @createTableCols 
			+ ',[AdjAuditValue' + cast(@counter as varchar) + '] varchar(50)'
			 , '[AdjAuditValue' + cast(@counter as varchar) + '] varchar(50)' )

		set @selectUserCols = coalesce( @selectUserCols
			+ ',[' + cast(@counter as varchar) + '] as [AdjAuditUser' + cast(@counter as varchar) + ']'
			 , '[' + cast(@counter as varchar) + '] as [AdjAuditUser' + cast(@counter as varchar) + ']' )
		set @selectValueCols = coalesce( @selectValueCols
			+ ',[' + cast(@counter as varchar) + '] as [AdjAuditValue' + cast(@counter as varchar) + ']'
			 , '[' + cast(@counter as varchar) + '] as [AdjAuditValue' + cast(@counter as varchar) + ']' )
		set @selectDateCols = coalesce( @selectDateCols
			+ ',[' + cast(@counter as varchar) + '] as [AdjAuditDate' + cast(@counter as varchar) + ']'
			 , '[' + cast(@counter as varchar) + '] as [AdjAuditDate' + cast(@counter as varchar) + ']' )	 

		set @createFinalTableCols = coalesce( @createFinalTableCols
			+ ', [AdjAuditUser' + cast(@counter as varchar) + '] nvarchar(50)
			   , [AdjAuditValue' + cast(@counter as varchar) + '] nvarchar(50)'
			 , ' [AdjAuditUser' + cast(@counter as varchar) + '] nvarchar(50)
			   , [AdjAuditValue' + cast(@counter as varchar) + '] nvarchar(50)' )
		
		set @finalSelectCols = coalesce( @finalSelectCols
			+ ', [AdjAuditUser' + cast(@counter as varchar) + '], [AdjAuditValue' + cast(@counter as varchar) + ']'
			 , ' [AdjAuditUser' + cast(@counter as varchar) + '], [AdjAuditValue' + cast(@counter as varchar) + ']' )
		
		set @counter = @counter + 1
	end	

	--declare @sql varchar(4000)
	set @sql = N'create table AdjAuditValues ( DrawId int, ' + @createTableCols + ')'
	print @sql
	exec (@sql)

	set @sql = N'
		insert into AdjAuditValues
		select DrawId, ' + @selectValueCols + '
		from (
			select da.DrawId, da.DrawAdjustmentAuditId, Diff
			from #cteAdjustments_Prelim da
			) as t
		pivot (
			sum(Diff)
			for DrawAdjustmentAuditId in (' + @cols + ')
			) as pvtValues
	'
	print @sql
	exec(@sql)

	--| 
	set @sql = N'create table AdjAuditUsers ( DrawId int, ' + replace(@createTableCols,'Value','User') + ')'
	print @sql
	exec (@sql)

	set @sql = N'
		insert into AdjAuditUsers
		select DrawId, ' + @selectUserCols + '
		from (
			select da.DrawId, da.DrawAdjustmentAuditId, da.AdjAuditUser
			from #cteAdjustments_Prelim da
			) as t
		pivot (
			max(AdjAuditUser)
			for DrawAdjustmentAuditId in (' + @cols + ')
			) as pvtValues'
	exec(@sql)

	set @sql = N'create table adjustmentsAuditDetails ( DrawId int, ' + @createFinalTableCols + ')'
	print @sql
	exec (@sql)

	set @sql = N'
		insert into adjustmentsAuditDetails
		select u.DrawId, ' + @finalSelectCols + '
		from AdjAuditUsers u
		join AdjAuditValues v
			on u.DrawId = v.DrawId'
		
	print @sql
	exec (@sql)
end
else
begin
	--|  No Adjustments data, but we still need the table to exist 
	set @sql = N'create table adjustmentsAuditDetails ( DrawId int )'
	print @sql
	exec (@sql)
end	

	/*
		Get a distinct list of the possible "owners" of a given manifest.
		We need to identify the "owners" so we can filter out Owner Updates vs. Admin Updates
	*/
	;with cteOwners ( MfstCode, OwnerId, OwnerName )
	as
		(
		select distinct MfstCode, ManifestOwner as [UserId], u.UserName
		from tmpAcctsMfsts tmp
		join Users u
			on tmp.ManifestOwner = u.UserID
		union 
		select distinct mt.MTCode, u.UserID, u.UserName
		from tmpAcctsMfsts tmp
		join scManifestTemplates mt
			on mt.MTCode = tmp.MfstCode
		join nsDevices d
			on MT.DeviceId = d.DeviceId
		join nsDevicesUsers du
			on d.DeviceId = du.DeviceID	
		join Users u
			on du.UserId = u.UserID
		join UserGroups ug
			on du.UserId = ug.UserID
		join Groups g
			on ug.GroupID = g.GroupID
		where g.GroupName = 'PDAuser'	
	)
	select 
		  ra.DrawId
		, ra.DrawDate
		, ra.AccountId
		, ra.PublicationId
		, Diff
 		, case 
			when ra.RetAuditUser = o.OwnerName then 'Owner'
			else 'Admin' end as [RetAuditUserRole]
	into #returns_by_Owner_Admin	
	from #cteReturns_Prelim ra
	left join cteOwners o
		on ra.RetAuditUser = o.OwnerName
		and ra.MfstCode = o.MfstCode

--select *
--from #returns_by_Owner_Admin
--order by DrawId

	/*
		Pivot the Owner/Admin Returns so they are in a single row
		
		join with Adjustments
		join with Manifests
	*/
	;with cteDraws 
	as (
		select d.DrawId, d.DrawDate
			, d.DrawAmount, isnull(d.AdjAmount,0) as [AdjAmount], isnull(d.AdjAdminAmount,0) as [AdjAdminAmount]
			, d.DrawAmount + isnull(d.AdjAmount,0) + isnull(d.AdjAdminAmount,0) - isnull(d.RetAmount,0) as [Net] 
			, m.MfstCode, m.AcctCode, m.PubShortName
		from scDraws d
		join tmpAcctsMfsts m
			on d.AccountID = m.AccountId
			and d.PublicationID = m.PublicationId
			and dbo.scGetDayFrequency(d.DrawDate) & m.Frequency > 0
		where d.DrawDate between @beginDrawDate and @endDrawDate
	)
	,cteReturnsByOwnerAdmin ( DrawId, [OwnerReturns], [AdminReturns] )
	as (
		select DrawId, [Owner] as [OwnerReturns], [Admin] as [AdminReturns]
		from (
			select DrawId, RetAuditUserRole, sum(Diff) as [Returns]
			from #returns_by_Owner_Admin ret
			group by DrawId, RetAuditUserRole	
			) as r
		pivot (
			max([Returns])
			for RetAuditUserRole in ([Owner], [Admin])
			) as p
	)
	select d.MfstCode
		, d.DrawDate, d.AcctCode, d.PubShortName, d.DrawAmount
		, r.OwnerReturns
		, r.AdminReturns
		, d.AdjAmount as [OwnerAdjustments]
		, d.AdjAdminAmount as [AdminAdjustments]
		, d.Net
		, rd.*
		, ad.*
	from cteDraws d
	left join cteReturnsByOwnerAdmin r
		on d.DrawId = r.DrawID
	left join returnsAuditDetails rd
		on d.DrawId = rd.DrawID
	left join adjustmentsAuditDetails ad
		on d.DrawId = ad.DrawID	
	where (
		rd.DrawId is not null
		or ad.DrawId is not null )	
	order by d.MfstCode, d.DrawDate, d.AcctCode, d.PubShortName

	drop table #returns_by_Owner_Admin
	drop table #cteReturns_Prelim
	drop table #cteAdjustments_Prelim
	
	if exists ( select id from sysobjects where id = object_id('RetAuditValues') )
		drop table RetAuditValues
	if exists ( select id from sysobjects where id = object_id('RetAuditUsers') )
		drop table RetAuditUsers
	if exists ( select id from sysobjects where id = object_id('returnsAuditDetails') )
		drop table returnsAuditDetails
	if exists ( select id from sysobjects where id = object_id('AdjAuditValues') )
		drop table AdjAuditValues
	if exists ( select id from sysobjects where id = object_id('AdjAuditUsers') )
		drop table AdjAuditUsers
	if exists ( select id from sysobjects where id = object_id('adjustmentsAuditDetails') )
		drop table adjustmentsAuditDetails
END
GO	
