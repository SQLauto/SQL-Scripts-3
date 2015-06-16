

select date, time, page, querystring
	, substring( 
		querystring
		, charindex('dropid=', querystring, 0) + len('dropid=')
		, charindex('&',  querystring, charindex('dropid=', querystring, 0) )  - ( charindex('dropid=', querystring, charindex('dropid=', querystring, 0)) + len('dropid=') )  
		) as [DropId]
from iis0606
where (
	page like '%getDeliveryDrop.aspx'
	or page like '%ManifestAck.aspx'
	)
and (
	querystring like 'mfstid=395%'
	)
and substring( 
		querystring
		, charindex('dropid=', querystring, 0) + len('dropid=')
		, charindex('&',  querystring, charindex('dropid=', querystring, 0) )  - ( charindex('dropid=', querystring, charindex('dropid=', querystring, 0)) + len('dropid=') )  
		) = '5490'
order by time desc

select date, time, page, querystring
	, substring( 
		querystring
		, charindex('dropid=', querystring, 0) + len('dropid=')
		, charindex('&',  querystring, charindex('dropid=', querystring, 0) )  - ( charindex('dropid=', querystring, charindex('dropid=', querystring, 0)) + len('dropid=') )  
		) as [DropId]
from iis0606
where (
	page like '%getDeliveryDrop.aspx'
	or page like '%ManifestAck.aspx'
	)
and (
	querystring like 'mfstid=395%'
	)
order by time desc