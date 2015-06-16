

--| 3 manifests we corrected are:  C07C, E01E, N02B

select time, i.page, i.querystring, *
from iis0506 i
join 	(
	select page, querystring, count(*) as [Occurrences]
	from iis0506
	where page like '%/toronto/getDeliveryDrop%'
	and substring(querystring, 8, 3) = '468'
	group by page, querystring
	having count(*) > 1
--	order by 2
	) as tmp
on i.page = tmp.page
and i.querystring = tmp.querystring
order by 3, 1 asc


/*
SELECT substring(querystring, 8, 3) 
from iis0510
where page like '%/toronto/getDeliveryDrop%'
*/