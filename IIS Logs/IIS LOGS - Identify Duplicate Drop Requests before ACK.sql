/*
select charindex('mfstid=', querystring, 0) + len('mfstid='), charindex('&',  querystring, 0)
from iis0606
where page like '%ManifestAck.aspx'
*/

/*
	looking for duplicate drops before the manifest ack.
*/

begin tran

select distinct substring( querystring, charindex('mfstid=', querystring, 0) + len('mfstid='), charindex('&',  querystring, 0)  - ( charindex('mfstid=', querystring, 0) + len('mfstid=') )  ) as [ManifestId]
	, substring( page, 2, charindex('/', page, 2) - 2 ) as [Company]
	, page
	, querystring
	, time
into #transfers
from iis0606
where page like '%/ManifestAck.aspx'

/*
select substring( querystring, charindex('mfstid=', querystring, 0) + len('mfstid='), charindex('&',  querystring, 0)  - ( charindex('mfstid=', querystring, 0) + len('mfstid=') )  ) as [ManifestId]
	, substring( page, 2, charindex('/', page, 2) - 2 ) as [Company]
	, QueryString
from iis0606
where (
	page like '%/getDeliveryDrop.aspx'
	)
group by substring( querystring, charindex('mfstid=', querystring, 0) + len('mfstid='), charindex('&',  querystring, 0)  - ( charindex('mfstid=', querystring, 0) + len('mfstid=') )  )
	, substring( page, 2, charindex('/', page, 2) - 2 )
	, QueryString
having count(*) > 1
order by 1, 2
*/

select substring( querystring, charindex('mfstid=', querystring, 0) + len('mfstid='), charindex('&',  querystring, 0)  - ( charindex('mfstid=', querystring, 0) + len('mfstid=') )  ) as [ManifestId]
	, substring( page, 2, charindex('/', page, 2) - 2 ) as [Company]
	, QueryString
into #dups
from iis0606
where (
	page like '%/getDeliveryDrop.aspx'
	)
group by substring( querystring, charindex('mfstid=', querystring, 0) + len('mfstid='), charindex('&',  querystring, 0)  - ( charindex('mfstid=', querystring, 0) + len('mfstid=') )  )
	, substring( page, 2, charindex('/', page, 2) - 2 )
	, QueryString
having count(*) > 1
order by 1, 2

--/*
select *
from #transfers
order by manifestId, company
--*/

select d.*
	, substring( 
		i.querystring
		, charindex('dropid=', i.querystring, 0) + len('dropid=')
		, charindex('&',  i.querystring, charindex('dropid=', i.querystring, 0) )  - ( charindex('dropid=', i.querystring, charindex('dropid=', i.querystring, 0)) + len('dropid=') )  
		) as [DropId]
	, i.time
from #dups d
join iis0606 i
	on d.querystring = i.querystring
order by company, manifestid, dropid

select d.*
	, substring( 
		i.querystring
		, charindex('dropid=', i.querystring, 0) + len('dropid=')
		, charindex('&',  i.querystring, charindex('dropid=', i.querystring, 0) )  - ( charindex('dropid=', i.querystring, charindex('dropid=', i.querystring, 0)) + len('dropid=') )  ) as [DropId]
	, i.time
	, trx.time as [ack]
from #dups d
join iis0606 i
	on d.querystring = i.querystring
join #transfers trx
	on d.company = trx.company
	and d.manifestid = trx.manifestid
order by d.company, d.manifestid, dropid


rollback tran