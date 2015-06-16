begin tran
	

	set nocount on

	declare @delete table (
		userid int
		, planid int
		, subscriberplanid int
	)

	insert into @delete
	select sp.userid, sp.planid, max(sp.subscriberplanid) as [subscriberplanid]
	from subscriberplans sp
	join (
		select	sp.userid, planid
		from	SubscriberPlans sp
		where	sp.ExpirationDate > GETUTCDATE()
		and		sp.CancelledDate IS NULL
		group by sp.userid, planid
		having count(*) > 1
	) dups
		on sp.userid = dups.userid
		and sp.planid = dups.planid
	group by sp.userid, sp.planid

	
	select u.username [Users w/ Duplicate Plans]
	from @delete d
	join seUsers u
		on d.userid = u.userid

	delete sp
	from	SubscriberPlans sp
	join @delete d
		on sp.userid = d.userid
		and sp.planid = d.planid
		and sp.subscriberplanid = d.subscriberplanid
	print cast(@@rowcount as varchar) + ' records deleted from SubscriberPlans'

rollback tran
