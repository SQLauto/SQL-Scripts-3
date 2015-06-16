IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_RetAudit]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_RetAudit]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[support_RetAudit]
	  @beginDrawDate datetime = null
	, @endDrawDate datetime = null
	, @mfstCode nvarchar(20) = null
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
		from dbo.listMfstsAccts('Delivery',@mfstCode, null, -1, null) 

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
	select m.MfstCode, ra.DrawId, ra.DrawDate, ra.AccountId, ra.PublicationId, ra.ReturnsAuditId, ra.RetAuditUser, ra.RetAuditDate, Diff--, m.AcctCode, m.PubShortName
	into #cteReturns_Prelim
	from cteReturns_Prelim ra
	join tmpAcctsMfsts m  --|need to join with Manifests to determine owner
		on ra.AccountId = m.AccountId
		and ra.PublicationId = m.PublicationId
		and dbo.scGetDayFrequency(ra.DrawDate) & m.Frequency > 0
		
	--select *
	--from #cteReturns_Prelim
	--order by DrawId



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
		, d.Net
		, rd.*
	from cteDraws d
	left join cteReturnsByOwnerAdmin r
		on d.DrawId = r.DrawID
	left join #cteReturns_Prelim rd
		on d.DrawId = rd.DrawID
	where (
		rd.DrawId is not null
	)	
	order by d.MfstCode, d.DrawDate, d.AcctCode, d.PubShortName

	drop table #returns_by_Owner_Admin
	drop table #cteReturns_Prelim


	
	if exists ( select id from sysobjects where id = object_id('RetAuditValues') )
		drop table RetAuditValues
	if exists ( select id from sysobjects where id = object_id('RetAuditUsers') )
		drop table RetAuditUsers
	if exists ( select id from sysobjects where id = object_id('returnsAuditDetails') )
		drop table returnsAuditDetails
	
END
GO	


--exec support_RetAudit '2/10/2014', '2/10/2014', '200550CT'