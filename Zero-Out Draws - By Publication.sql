begin tran

select d.DrawDate, p.PubShortName, sum(d.DrawAmount + isnull(d.AdjAmount,0) + isnull(d.AdjAdminAmount,0)) as [DrawTotal]
from scdraws d
join nspublications p
	on d.publicationid = p.publicationid
where datediff(d, drawdate, getdate()) = 0
and pubshortname in ('FTL', 'IBD', 'WSJ')
--and d.DrawAmount + isnull(d.AdjAmount,0) + isnull(d.AdjAdminAmount,0) > 0
group by d.DrawDate, p.PubShortName

update scdraws
set adjadminamount = -1*drawamount
from scdraws d
join nspublications p
	on d.publicationid = p.publicationid
where datediff(d, drawdate, getdate()) = 0
and pubshortname in ('FTL', 'IBD', 'WSJ')
and d.DrawAmount + isnull(d.AdjAmount,0) + isnull(d.AdjAdminAmount,0) > 0


select d.DrawDate, p.PubShortName, sum(d.DrawAmount + isnull(d.AdjAmount,0) + isnull(d.AdjAdminAmount,0)) as [DrawTotal]
from scdraws d
join nspublications p
	on d.publicationid = p.publicationid
where datediff(d, drawdate, getdate()) = 0
and pubshortname in ('FTL', 'IBD', 'WSJ')
--and d.DrawAmount + isnull(d.AdjAmount,0) + isnull(d.AdjAdminAmount,0) > 0
group by d.DrawDate, p.PubShortName

commit tran