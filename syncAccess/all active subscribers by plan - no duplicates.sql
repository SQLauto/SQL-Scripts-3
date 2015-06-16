--|  note, used all_active_subs_by_plan to populate the table [support_all_active_subs_by_plan]

--drop/create table support_all_active_subs_by_plan
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_all_active_subs_by_plan]') AND type in (N'U'))
DROP TABLE [dbo].[support_all_active_subs_by_plan]
GO

CREATE TABLE [dbo].[support_all_active_subs_by_plan](
	[UserId] [int] NOT NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[Email] [nvarchar](256) NOT NULL,
	[PhoneNumber] [nvarchar](20) NOT NULL,
	[PurchaseDate] [datetime] NOT NULL,
	[OriginalPlanCode] [nvarchar](10) NOT NULL,
	[SubscriberPlanId] [int] NOT NULL,
	[OriginalPlanName] [nvarchar](100) NOT NULL,
	[OccupantID] [nvarchar](200) NULL,
	[AddressID] [nvarchar](200) NULL
) ON [PRIMARY]

GO

begin tran

	;with ctePlan1 as (
		select tmp.userid, tmp.SubscriberPlanId, tmp.originalplancode, tmp.OriginalPlanName, PurchaseDate
		from support_all_active_subs_by_plan tmp
		join (
			select email
			from support_all_active_subs_by_plan
			group by email having COUNT(*) > 1
			) dups
			on tmp.email = dups.email
	)
	, ctePlan2 as (
		select tmp.userid, tmp.SubscriberPlanId, tmp.originalplancode, tmp.OriginalPlanName, PurchaseDate
		from support_all_active_subs_by_plan tmp
		join (
			select email
			from support_all_active_subs_by_plan
			group by email having COUNT(*) > 1
			) dups
			on tmp.email = dups.email
	)
	select p1.UserId
		, p1.OriginalPlanCode + ', ' + p2.OriginalPlanCode as [Plans]
		, p1.OriginalPlanName + ', ' + p2.OriginalPlanName as [PlanNames]
		, cast(p1.PurchaseDate as varchar) + ', ' + cast(p2.PurchaseDate as varchar) as [PurchaseDates]
		, cast(p1.SubscriberPlanId as varchar) + ', ' + cast(p2.SubscriberPlanId as varchar) as [SubscriberPlanIds]
	into #dups
	from ctePlan1 p1
	join ctePlan2 p2 
		on p1.UserId = p2.UserId
	where p1.OriginalPlanCode <> p2.OriginalPlanCode		
	and p1.SubscriberPlanId	> p2.SubscriberPlanId

	select UserId, FirstName, LastName, Email, PhoneNumber, cast(PurchaseDate as varchar) as [PurchaseDate], OriginalPlanCode, OriginalPlanName, cast(SubscriberPlanId as varchar) as [SubscriberPlanId], OccupantID, AddressID
	from support_all_active_subs_by_plan
	where UserId not in (
		select UserId
		from #dups
	)
	union all
	select prelim.UserId, FirstName, LastName, Email, PhoneNumber, PurchaseDates, d.Plans, d.PlanNames, SubscriberPlanIds, OccupantID, AddressID
	from (
	select  distinct UserId, FirstName, LastName, Email, PhoneNumber, OccupantID, AddressID
	from support_all_active_subs_by_plan tmp
	) prelim
	join #dups d
		on prelim.UserId = d.UserId
		

rollback tran