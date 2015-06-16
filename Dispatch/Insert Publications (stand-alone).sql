
DELETE from nspublications


	--|  Publications
	declare @maxId int

	select @maxId = isnull( max(SDM_PubId), 0 )
	from nsPublications

	select SDM_PubId=identity(int,1,1)
		, Pub as [SDM_PubAbbreviation]
		, Pub as [SDM_PubName]
	into #pubs
	from (
		select 'PT' as [Pub]
		union all 
		select 'BG'
		union all 
		select 'NY'
		union all 
		select 'FT'
		union all 
		select 'US'
		union all 
		select 'WJ'
		union all 
		select 'KJ'
		union all 
		select 'MS'
		) as [Pubs]
	
	
	insert into nsPublications ( SDM_PubId, SDM_PubAbbreviation, SDM_PubName, SDM_IsActive )
	select @maxId + tmp.SDM_PubId as [SDM_PubId]
		, tmp.SDM_PubAbbreviation
		, tmp.SDM_PubName
		, 1
	from nsPublications p
	right join #pubs tmp
		on p.SDM_PubAbbreviation = tmp.SDM_PubAbbreviation
	where p.SDM_PubId is null
	order by tmp.SDM_PubAbbreviation
		
	drop table #pubs	
		
	select *
	from nspublications
