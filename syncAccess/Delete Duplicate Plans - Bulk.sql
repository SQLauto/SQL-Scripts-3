begin tran

	set nocount on

	declare @username varchar(256)
	declare @userid int
	declare @msg nvarchar(500)

	if not exists (
		select u.userid, sp.planid, count(*)
		from seusers u
		join subscriberplans sp
			on u.userid = sp.userid
		where sp.ExpirationDate > GETUTCDATE()
		and sp.CancelledDate IS NULL
		group by u.userid, sp.planid
		having count(*) > 1
	)
	begin
		print 'No users with duplicate plans found.'
	end
	else
	begin
		select u.userid, u.username, count(*) as [planCount]
		from seusers u
			left join subscriberplans sp
				on u.userid = sp.userid
			left join planTransactions pt
				on sp.subscriberplanid = pt.subscriberplanid
			join (
				select u.userid, sp.planid
				from seusers u
				join subscriberplans sp
					on u.userid = sp.userid
				where sp.ExpirationDate > GETUTCDATE()
					and sp.CancelledDate IS NULL
				group by u.userid, sp.planid
				having count(*) > 1
			) dups	
				on sp.userid = dups.userid
				and sp.planid = dups.planid
			where pt.plantransactionid is null
		group by u.userid, u.username
		having count(*) > 1

			select u.userid, sp.planid, sp.subscriberplanid 
				, pt.planTransactionId
			from seusers u
			left join subscriberplans sp
				on u.userid = sp.userid
			left join planTransactions pt
				on sp.subscriberplanid = pt.subscriberplanid
			join (
				select u.userid, sp.planid
				from seusers u
				join subscriberplans sp
					on u.userid = sp.userid
				where sp.ExpirationDate > GETUTCDATE()
					and sp.CancelledDate IS NULL
				group by u.userid, sp.planid
				having count(*) > 1
			) dups	
				on sp.userid = dups.userid
				and sp.planid = dups.planid
			where pt.plantransactionid is null
			--group by u.userid, sp.planid

		;with cteSubscriberPlanToDelete as (
			select u.userid, sp.planid, max(sp.subscriberplanid) as subscriberplanid 
			from seusers u
			left join subscriberplans sp
				on u.userid = sp.userid
			left join planTransactions pt
				on sp.subscriberplanid = pt.subscriberplanid
			join (
				select u.userid, sp.planid
				from seusers u
				join subscriberplans sp
					on u.userid = sp.userid
				where sp.ExpirationDate > GETUTCDATE()
					and sp.CancelledDate IS NULL
				group by u.userid, sp.planid
				having count(*) > 1
			) dups	
				on sp.userid = dups.userid
				and sp.planid = dups.planid
			where pt.plantransactionid is null
			group by u.userid, sp.planid
		)
		delete sp
		--select sp.subscriberplanid
		from subscriberplans sp
		join cteSubscriberplanToDelete del
			on sp.userid = del.userid
			and sp.planid = del.planid
			and sp.subscriberplanid = del.subscriberplanid
		print cast(@@rowcount as varchar) + case when @@rowcount=1 then ' record deleted from SubscriberPlans' else ' records deleted from SubscriberPlans' end

		select u.userid, u.username, count(*) as [planCount]
		from seusers u
			left join subscriberplans sp
				on u.userid = sp.userid
			left join planTransactions pt
				on sp.subscriberplanid = pt.subscriberplanid
			join (
				select u.userid, sp.planid
				from seusers u
				join subscriberplans sp
					on u.userid = sp.userid
				where sp.ExpirationDate > GETUTCDATE()
					and sp.CancelledDate IS NULL
				group by u.userid, sp.planid
				having count(*) > 1
			) dups	
				on sp.userid = dups.userid
				and sp.planid = dups.planid
			where pt.plantransactionid is null
		group by u.userid, u.username
		having count(*) > 1

	end

commit tran