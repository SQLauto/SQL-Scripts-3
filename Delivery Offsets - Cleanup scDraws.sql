begin tran

select COUNT(*)
from scDraws d
join (
	select d.AccountID, d.PublicationID, d.DeliveryDate
	from scDraws d
	where d.DrawDate > '9/1/2013'
	group by d.AccountID, d.PublicationID, d.DeliveryDate
	having COUNT(*) > 1
	) prelim
	on d.AccountID = prelim.AccountID
	and d.PublicationID = prelim.PublicationID
	and d.DeliveryDate = prelim.DeliveryDate
where d.DrawDate = d.DeliveryDate
and d.DrawAmount = 0		
--order by 1, 4

select d.*
from (
	select d.DrawID
	from scDraws d
	join (
		select d.AccountID, d.PublicationID, d.DeliveryDate
		from scDraws d
		where d.DrawDate > '9/1/2013'
		group by d.AccountID, d.PublicationID, d.DeliveryDate
		having COUNT(*) > 1
		) prelim
		on d.AccountID = prelim.AccountID
		and d.PublicationID = prelim.PublicationID
		and d.DeliveryDate = prelim.DeliveryDate
	where d.DrawDate = d.DeliveryDate
	and d.DrawAmount = 0
) d
join scDrawHistory dh
	on d.DrawID = dh.drawid

delete scDrawHistory
from scDrawHistory dh
join (
	select d.DrawID
	from scDraws d
	join (
		select d.AccountID, d.PublicationID, d.DeliveryDate
		from scDraws d
		where d.DrawDate > '9/1/2013'
		group by d.AccountID, d.PublicationID, d.DeliveryDate
		having COUNT(*) > 1
		) prelim
		on d.AccountID = prelim.AccountID
		and d.PublicationID = prelim.PublicationID
		and d.DeliveryDate = prelim.DeliveryDate
	where d.DrawDate = d.DeliveryDate
	and d.DrawAmount = 0
) d
	on d.DrawID = dh.drawid

delete scDraws
from scDraws d
join (
	select d.AccountID, d.PublicationID, d.DeliveryDate
	from scDraws d
	where d.DrawDate > '9/1/2013'
	group by d.AccountID, d.PublicationID, d.DeliveryDate
	having COUNT(*) > 1
	) prelim
	on d.AccountID = prelim.AccountID
	and d.PublicationID = prelim.PublicationID
	and d.DeliveryDate = prelim.DeliveryDate
where d.DrawDate = d.DeliveryDate
and d.DrawAmount = 0		

select d.AccountID, d.PublicationID, d.DrawDate, d.DeliveryDate, d.DrawAmount
from scDraws d
join (
	select d.AccountID, d.PublicationID, d.DeliveryDate
	from scDraws d
	where d.DrawDate > '9/1/2013'
	group by d.AccountID, d.PublicationID, d.DeliveryDate
	having COUNT(*) > 1
	) prelim
	on d.AccountID = prelim.AccountID
	and d.PublicationID = prelim.PublicationID
	and d.DeliveryDate = prelim.DeliveryDate
where d.DrawDate = d.DeliveryDate
and d.DrawAmount = 0		
order by 1, 4

rollback tran