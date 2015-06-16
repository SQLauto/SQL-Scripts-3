begin tran

	set nocount on

	declare @username varchar(256)
	declare @userid int
	declare @msg nvarchar(500)

	set @username = 'joannaterri'

	
	--select u.userid, sp.planid, count(*)
	--from seusers u
	--join subscriberplans sp
	--	on u.userid = sp.userid
	--where username = @username
	--group by u.userid, sp.planid
	--having count(*) > 1

	if not exists (
		select u.userid, sp.planid, count(*)
		from seusers u
		join subscriberplans sp
			on u.userid = sp.userid
		where username = @username
		group by u.userid, sp.planid
		having count(*) > 1
	)
	begin
		print 'No duplicate plans found.'
		select u.userid, sp.planid, count(*)
		from seusers u
		join subscriberplans sp
			on u.userid = sp.userid
		where username = @username
		group by u.userid, sp.planid
		--having count(*) > 1
	end
	else
	begin
		select @msg = 'Duplicate plans found.  Rowcount=' + cast(count(*) as varchar) + '.'
		from seusers u
		join subscriberplans sp
			on u.userid = sp.userid
		where username = @username
		group by u.userid, sp.planid
		having count(*) > 1
		print @msg

		;with cteSubscriberPlanToDelete as (
			select u.userid, sp.planid, max(sp.subscriberplanid) as subscriberplanid
			from seusers u
			join subscriberplans sp
				on u.userid = sp.userid
			join (
				select u.userid, sp.planid
				from seusers u
				join subscriberplans sp
					on u.userid = sp.userid
				where username = @username
				group by u.userid, sp.planid
				having count(*) > 1
			) dups	
				on sp.userid = dups.userid
				and sp.planid = dups.planid
			where username = @username
			group by u.userid, sp.planid
		)
		delete sp
		from subscriberplans sp
		join cteSubscriberplanToDelete del
			on sp.userid = del.userid
			and sp.planid = del.planid
			and sp.subscriberplanid = del.subscriberplanid
		print cast(@@rowcount as varchar) + case when @@rowcount=1 then ' record deleted from SubscriberPlans' else ' records deleted from SubscriberPlans' end

		

	end

commit tran