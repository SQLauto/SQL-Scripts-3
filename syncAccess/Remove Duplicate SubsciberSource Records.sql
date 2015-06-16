begin tran

;with cteDuplicateSubscriberSources as (
select s.UserId, ss.SubscriberSourceId
		, COUNT(ssk.SubscriberSourceKeyId) as [Count]
	from Subscribers s
	join (
		select UserId
		from SubscriberSources ss
		group by UserId
		having COUNT(*) > 1
		) dups
		on s.UserId = dups.UserId
	join SubscriberSources ss
		 on s.UserId = ss.UserId
	left join SubscriberSourceKeys ssk
		on ss.SubscriberSourceId = ssk.SubscriberSourceId 
	group by s.UserId, ss.SubscriberSourceId
	having COUNT(ssk.SubscriberSourceKeyId) = 0
	--order by s.UserId
)
select *
into #dups
from cteDuplicateSubscriberSources

delete SyncronizationDetail 
from SyncronizationDetail sd
join #dups cte
	on sd.SubscriberSourceId = cte.SubscriberSourceId

delete SubscriberSources
from SubscriberSources ss
join #dups cte
	on ss.UserId = cte.UserId
	and ss.SubscriberSourceId = cte.SubscriberSourceId
	


drop table #dups

commit tran	